//// Forgejo / Gitea API v1 — codeberg.org and any self-hosted instance that
//// answers `/api/v1/version`. `CODEBERG_TOKEN` is optional for public repos.
////
//// The repository object has no licence field, so the licence comes from
//// `gleam.toml`'s `licences` key when the project declares one.

import gleam/option.{Some}
import rhm/fetch
import rhm/files
import rhm/locate.{type Location}
import rhm/metrics.{type Metrics, Metrics}

pub fn fetch(location: Location) -> Metrics {
  let headers =
    fetch.auth("CODEBERG_TOKEN", fn(t) { #("authorization", "token " <> t) })
  let base = "https://" <> location.host <> "/api/v1/repos/" <> location.path
  let empty =
    metrics.new(
      provider: "forgejo",
      host: location.host,
      slug: location.path,
      url: location.url,
    )

  case fetch.get_body(base, headers) {
    Error(reason) -> metrics.note(empty, "Forgejo API unreachable: " <> reason)
    Ok(body) ->
      case fetch.parse(body) {
        Error(reason) -> metrics.note(empty, "Forgejo API: " <> reason)
        Ok(data) -> {
          let branch =
            option.unwrap(fetch.string_field(data, ["default_branch"]), "main")
          let raw_url = fn(path) {
            base <> "/raw/" <> path <> "?ref=" <> branch
          }
          Metrics(
            ..empty,
            stars: fetch.int(data, ["stars_count"]),
            created_at: fetch.time(data, ["created_at"]),
            // Forgejo's `updated_at` tracks repository updates generally, not
            // pushes alone.
            pushed_at: fetch.time(data, ["updated_at"]),
            open_issues: fetch.int(data, ["open_issues_count"]),
            default_branch: Some(branch),
            latest_release: fetch.first_field_of(
              fetch.get_body(base <> "/tags?limit=1", headers),
              ["name"],
            ),
            archived: fetch.bool(data, ["archived"]),
          )
          |> disabled_issues_note(data)
          |> metrics.note(
            "licence is read from `gleam.toml` — the Forgejo repository API "
            <> "exposes no licence field",
          )
          |> files.apply(headers, raw_url)
        }
      }
  }
}

fn disabled_issues_note(data: Metrics, raw) -> Metrics {
  case fetch.bool(raw, ["has_issues"]) {
    Some(False) ->
      metrics.note(
        data,
        "the Issues tab is disabled on this repository — distinct from "
          <> "\"0 open\", which is a positive signal",
      )
    _ -> data
  }
}
