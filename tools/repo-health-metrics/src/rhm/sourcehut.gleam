//// SourceHut. The GraphQL API at `/query` rejects anonymous callers outright,
//// so without `SRHT_TOKEN` the tool falls back to the two endpoints sr.ht
//// serves publicly: the per-branch RSS commit log (for the last commit date)
//// and `/blob/` (for `gleam.toml` and the README).
////
//// SourceHut has no stars and no per-repository issue tracker — tickets live
//// on todo.sr.ht as a separate resource — so both dimensions are always ⬜.

import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string
import gleam/time/timestamp.{type Timestamp}
import rhm/fetch
import rhm/files
import rhm/locate.{type Location}
import rhm/metrics.{type Metrics, Metrics}

pub fn fetch(location: Location) -> Metrics {
  let headers =
    fetch.auth("SRHT_TOKEN", fn(t) { #("authorization", "Bearer " <> t) })
  let root = "https://" <> location.host <> "/" <> location.path
  let branch = default_branch(root)
  let empty =
    metrics.new(
      provider: "sourcehut",
      host: location.host,
      slug: location.path,
      url: location.url,
    )
    |> metrics.note(
      "sourcehut has no star count and no per-repository issue tracker "
      <> "(tickets live on todo.sr.ht), so both are ⬜ by construction",
    )

  let #(created, pushed, note) = dates(location, root, branch, headers)

  Metrics(
    ..empty,
    created_at: created,
    pushed_at: pushed,
    default_branch: Some(branch),
  )
  |> metrics.note(note)
  |> files.apply(headers, fn(path) { root <> "/blob/" <> branch <> "/" <> path })
}

fn default_branch(root: String) -> String {
  case fetch.get_body(root <> "/log/main/rss.xml", []) {
    Ok(_) -> "main"
    Error(_) -> "master"
  }
}

fn dates(
  location: Location,
  root: String,
  branch: String,
  headers: List(#(String, String)),
) -> #(Option(Timestamp), Option(Timestamp), String) {
  case headers {
    [] -> #(
      None,
      last_commit(root, branch),
      "SRHT_TOKEN unset — age is ⬜ and maintenance comes from the public RSS "
        <> "commit log rather than the API",
    )
    _ -> {
      let query =
        "{\"query\":\"{user(username:\\\""
        <> string.replace(location.owner, "~", "")
        <> "\\\"){repository(name:\\\""
        <> location.repo
        <> "\\\"){created updated}}}\"}"
      let path = ["data", "user", "repository"]
      case fetch.post_json(root_query(location), headers, query) {
        Error(reason) -> #(
          None,
          last_commit(root, branch),
          "sourcehut GraphQL failed (" <> reason <> ") — fell back to RSS",
        )
        Ok(body) ->
          case fetch.parse(body) {
            Error(_) -> #(
              None,
              last_commit(root, branch),
              "sourcehut GraphQL returned no JSON — fell back to RSS",
            )
            Ok(data) -> #(
              fetch.time(data, list.append(path, ["created"])),
              fetch.time(data, list.append(path, ["updated"])),
              "dates from the sourcehut GraphQL API",
            )
          }
      }
    }
  }
}

fn root_query(location: Location) -> String {
  "https://" <> location.host <> "/query"
}

/// The newest `<pubDate>` in the branch's RSS log, which sr.ht serves to
/// anonymous callers.
fn last_commit(root: String, branch: String) -> Option(Timestamp) {
  case fetch.get_body(root <> "/log/" <> branch <> "/rss.xml", []) {
    Error(_) -> None
    Ok(feed) ->
      case string.split(feed, "<pubDate>") {
        [_, rest, ..] ->
          case string.split(rest, "</pubDate>") {
            [date, ..] -> option.from_result(parse_rfc822(date))
            _ -> None
          }
        _ -> None
      }
  }
}

/// `Thu, 04 Jun 2026 14:15:47 +0200` → a Timestamp. `timestamp.parse_http_date`
/// only accepts `GMT`, and sr.ht emits real numeric offsets, so the date is
/// rewritten into RFC-3339 first.
fn parse_rfc822(input: String) -> Result(Timestamp, Nil) {
  case string.split(string.trim(input), " ") {
    [_weekday, day, month, year, time, offset] -> {
      use month <- result.try(month_number(month))
      let offset = case offset {
        "GMT" | "UTC" | "Z" -> "Z"
        _ -> string.slice(offset, 0, 3) <> ":" <> string.slice(offset, 3, 2)
      }
      timestamp.parse_rfc3339(
        year <> "-" <> month <> "-" <> pad(day) <> "T" <> time <> offset,
      )
    }
    _ -> Error(Nil)
  }
}

fn month_number(name: String) -> Result(String, Nil) {
  let months = [
    "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov",
    "Dec",
  ]
  months
  |> list.index_map(fn(month, index) { #(month, index + 1) })
  |> list.key_find(name)
  |> result.map(fn(number) { pad(int.to_string(number)) })
}

fn pad(value: String) -> String {
  case string.length(value) {
    1 -> "0" <> value
    _ -> value
  }
}
