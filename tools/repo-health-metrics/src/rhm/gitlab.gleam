//// GitLab REST v4 — gitlab.com and any self-hosted instance on a `gitlab.*`
//// host. `GITLAB_TOKEN` is optional for public projects, but note that
//// `open_issues_count` is withheld from anonymous callers.

import gleam/option.{type Option, None, Some}
import gleam/string
import rhm/fetch
import rhm/files
import rhm/locate.{type Location}
import rhm/metrics.{type Metrics, Metrics}

pub fn fetch(location: Location) -> Metrics {
  let headers = fetch.auth("GITLAB_TOKEN", fn(t) { #("private-token", t) })
  let base =
    "https://"
    <> location.host
    <> "/api/v4/projects/"
    <> string.replace(location.path, "/", "%2F")
  let empty =
    metrics.new(
      provider: "gitlab",
      host: location.host,
      slug: location.path,
      url: location.url,
    )

  case fetch.get_body(base <> "?license=true", headers) {
    Error(reason) -> metrics.note(empty, "GitLab API unreachable: " <> reason)
    Ok(body) ->
      case fetch.parse(body) {
        Error(reason) -> metrics.note(empty, "GitLab API: " <> reason)
        Ok(data) -> {
          let branch =
            option.unwrap(fetch.string_field(data, ["default_branch"]), "main")
          let raw_url = fn(path) {
            base <> "/repository/files/" <> path <> "/raw?ref=" <> branch
          }
          let issues = fetch.int(data, ["open_issues_count"])
          Metrics(
            ..empty,
            stars: fetch.int(data, ["star_count"]),
            license: fetch.string_field(data, ["license", "key"]),
            created_at: fetch.time(data, ["created_at"]),
            // GitLab has no `pushed_at`; `last_activity_at` is the closest
            // field and also moves on issue/MR activity, so it can read
            // fresher than the code actually is.
            pushed_at: fetch.time(data, ["last_activity_at"]),
            open_issues: issues,
            default_branch: Some(branch),
            latest_release: fetch.first_field_of(
              fetch.get_body(base <> "/repository/tags?per_page=1", headers),
              ["name"],
            ),
            archived: fetch.bool(data, ["archived"]),
          )
          |> issue_note(issues)
          |> metrics.note(
            "maintenance date is GitLab's `last_activity_at`, which includes "
            <> "issue and merge-request activity, not only pushes",
          )
          |> files.apply(headers, raw_url)
        }
      }
  }
}

fn issue_note(data: Metrics, issues: Option(Int)) -> Metrics {
  case issues {
    Some(_) -> data
    None ->
      metrics.note(
        data,
        "open issue count is withheld from anonymous GitLab API callers — set "
          <> "GITLAB_TOKEN to read it",
      )
  }
}
