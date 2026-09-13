//// Thin HTTP GET/POST wrapper over gleam_httpc, plus JSON field pluckers.
//// Every provider module talks to the network through here.

import envoy
import gleam/dynamic.{type Dynamic}
import gleam/dynamic/decode
import gleam/http
import gleam/http/request
import gleam/httpc
import gleam/json
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string
import gleam/time/timestamp

const user_agent = "repo-health-metrics (ecosystem_review)"

fn send(
  method: http.Method,
  url: String,
  headers: List(#(String, String)),
  body: String,
) -> Result(#(Int, String), String) {
  use req <- result.try(
    request.to(url) |> result.replace_error("malformed URL: " <> url),
  )

  let req =
    list.fold(
      [#("user-agent", user_agent), ..headers],
      request.set_body(request.set_method(req, method), body),
      fn(r, h) { request.set_header(r, h.0, h.1) },
    )

  httpc.configure()
  |> httpc.follow_redirects(True)
  |> httpc.timeout(30_000)
  |> httpc.dispatch(req)
  |> result.map(fn(resp) { #(resp.status, resp.body) })
  |> result.map_error(fn(e) { url <> ": " <> string.inspect(e) })
}

/// GET returning status and body, whatever the status is.
pub fn get(
  url: String,
  headers: List(#(String, String)),
) -> Result(#(Int, String), String) {
  send(http.Get, url, headers, "")
}

/// GET that treats any non-2xx status as an error.
pub fn get_body(
  url: String,
  headers: List(#(String, String)),
) -> Result(String, String) {
  use #(status, body) <- result.try(get(url, headers))
  case status >= 200 && status < 300 {
    True -> Ok(body)
    False -> Error(url <> ": HTTP " <> string.inspect(status))
  }
}

/// POST a JSON body, treating any non-2xx status as an error.
pub fn post_json(
  url: String,
  headers: List(#(String, String)),
  body: String,
) -> Result(String, String) {
  use #(status, response) <- result.try(send(
    http.Post,
    url,
    [#("content-type", "application/json"), ..headers],
    body,
  ))
  case status >= 200 && status < 300 {
    True -> Ok(response)
    False -> Error(url <> ": HTTP " <> string.inspect(status))
  }
}

// --- JSON plucking -----------------------------------------------------------
//
// The provider payloads are large and we want half a dozen fields out of each,
// so rather than write a full decoder per provider we parse once to a Dynamic
// and pull individual paths. A missing/null/wrong-typed field becomes `None`,
// which the scorer renders as ⬜.

pub fn parse(body: String) -> Result(Dynamic, String) {
  json.parse(body, decode.dynamic)
  |> result.replace_error("response was not JSON")
}

pub fn int(data: Dynamic, path: List(String)) -> Option(Int) {
  at(data, path, decode.int)
}

pub fn string_field(data: Dynamic, path: List(String)) -> Option(String) {
  at(data, path, decode.string)
}

pub fn bool(data: Dynamic, path: List(String)) -> Option(Bool) {
  at(data, path, decode.bool)
}

fn at(data: Dynamic, path: List(String), of: decode.Decoder(a)) -> Option(a) {
  case decode.run(data, decode.at(path, of)) {
    Ok(value) -> Some(value)
    Error(_) -> None
  }
}

/// An RFC-3339 timestamp field, which is how all four forges report dates.
pub fn time(data: Dynamic, path: List(String)) -> Option(timestamp.Timestamp) {
  case string_field(data, path) {
    None -> None
    Some(text) -> option.from_result(timestamp.parse_rfc3339(text))
  }
}

/// Pull one string field out of a response body that may not have arrived.
pub fn field_of(
  body: Result(String, String),
  path: List(String),
) -> Option(String) {
  case result.try(body, parse) {
    Error(_) -> None
    Ok(data) -> string_field(data, path)
  }
}

/// Same, but for endpoints (tag listings) that return a JSON array.
pub fn first_field_of(
  body: Result(String, String),
  path: List(String),
) -> Option(String) {
  case result.try(body, parse) {
    Error(_) -> None
    Ok(data) ->
      case decode.run(data, decode.list(decode.dynamic)) {
        Ok([head, ..]) -> string_field(head, path)
        _ -> None
      }
  }
}

/// Build an auth header list from an environment variable, or no headers at
/// all when it is unset. Every provider here works unauthenticated for public
/// repositories; tokens only raise rate limits (and, on sourcehut, unlock the
/// API at all).
pub fn auth(
  variable: String,
  header: fn(String) -> #(String, String),
) -> List(#(String, String)) {
  case envoy.get(variable) {
    Ok(token) -> [header(token)]
    Error(_) -> []
  }
}
