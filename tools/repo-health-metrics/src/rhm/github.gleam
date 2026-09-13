//// GitHub REST v3. Every rubric dimension this tool covers is available
//// unauthenticated; `GITHUB_TOKEN` only raises the 60/hour rate limit.

import gleam/dynamic.{type Dynamic}
import gleam/option.{type Option, None, Some}
import rhm/fetch
import rhm/files
import rhm/locate.{type Location}
import rhm/metrics.{type Metrics, Metrics}

pub fn fetch(location: Location) -> Metrics {
  let headers =
    fetch.auth("GITHUB_TOKEN", fn(t) { #("authorization", "Bearer " <> t) })
  let base = "https://api.github.com/repos/" <> location.path
  let empty =
    metrics.new(
      provider: "github",
      host: location.host,
      slug: location.path,
      url: location.url,
    )

  case fetch.get_body(base, headers) {
    Error(reason) -> metrics.note(empty, "GitHub API unreachable: " <> reason)
    Ok(body) ->
      case fetch.parse(body) {
        Error(reason) -> metrics.note(empty, "GitHub API: " <> reason)
        Ok(data) -> {
          let branch =
            option.unwrap(fetch.string_field(data, ["default_branch"]), "main")
          let raw_url = fn(path) {
            "https://raw.githubusercontent.com/"
            <> location.path
            <> "/"
            <> branch
            <> "/"
            <> path
          }
          Metrics(
            ..empty,
            stars: fetch.int(data, ["stargazers_count"]),
            license: license(data),
            created_at: fetch.time(data, ["created_at"]),
            pushed_at: fetch.time(data, ["pushed_at"]),
            open_issues: fetch.int(data, ["open_issues_count"]),
            default_branch: Some(branch),
            latest_release: release(base, headers),
            archived: fetch.bool(data, ["archived"]),
          )
          |> files.apply(headers, raw_url)
        }
      }
  }
}

/// `license` is null when the repository declares none, which the rubric
/// scores 🟥 — distinct from "we could not find out", which is ⬜.
fn license(data: Dynamic) -> Option(String) {
  case fetch.string_field(data, ["license", "spdx_id"]) {
    Some(spdx) -> Some(spdx)
    None -> Some("none")
  }
}

/// Prefer a published release; fall back to the newest tag.
fn release(base: String, headers: List(#(String, String))) -> Option(String) {
  let release =
    fetch.get_body(base <> "/releases/latest", headers)
    |> fetch.field_of(["tag_name"])
  case release {
    Some(_) -> release
    None ->
      fetch.get_body(base <> "/tags?per_page=1", headers)
      |> fetch.first_field_of(["name"])
  }
}
