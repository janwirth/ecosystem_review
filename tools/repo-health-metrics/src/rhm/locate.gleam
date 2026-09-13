//// Turning whatever the user typed into a provider + host + owner/repo.

import gleam/list
import gleam/result
import gleam/string
import rhm/fetch

pub type Location {
  Location(
    /// `github` / `gitlab` / `forgejo` / `sourcehut`
    provider: String,
    host: String,
    owner: String,
    repo: String,
    /// Full namespace path — same as `owner/repo` everywhere except GitLab,
    /// where it may contain subgroups (`group/subgroup/repo`).
    path: String,
    url: String,
  )
}

/// `forced_forgejo` are hosts named with `--forgejo`, which skips the probe.
pub fn parse(
  input: String,
  forced_forgejo: List(String),
) -> Result(Location, String) {
  let trimmed =
    input
    |> string.replace("https://", "")
    |> string.replace("http://", "")
    |> string.trim

  let segments =
    string.split(trimmed, "/")
    |> list.filter(fn(s) { s != "" })

  case segments {
    [] -> Error("empty repo reference: " <> input)
    [first, ..rest] ->
      case string.contains(first, "."), rest {
        // `host/owner/repo`
        True, [owner, ..more] -> build(first, owner, more, forced_forgejo)
        True, [] -> Error("no owner/repo in: " <> input)
        // bare `owner/repo`, defaulting to GitHub
        False, _ -> build("github.com", first, rest, forced_forgejo)
      }
  }
}

fn build(
  host: String,
  owner: String,
  rest: List(String),
  forced_forgejo: List(String),
) -> Result(Location, String) {
  use repo <- result.try(case rest {
    [repo, ..] -> Ok(strip_git(repo))
    [] -> Error("no repository name after owner `" <> owner <> "`")
  })

  use provider <- result.try(provider_for(host, forced_forgejo))

  // GitLab allows subgroups, so keep every path segment up to the `/-/` marker.
  let path = case provider {
    "gitlab" ->
      [owner, ..rest]
      |> list.take_while(fn(s) { s != "-" })
      |> list.map(strip_git)
      |> string.join("/")
    _ -> owner <> "/" <> repo
  }

  Ok(Location(
    provider:,
    host:,
    owner:,
    repo:,
    path:,
    url: "https://" <> host <> "/" <> path,
  ))
}

fn strip_git(name: String) -> String {
  case string.ends_with(name, ".git") {
    True -> string.drop_end(name, 4)
    False -> name
  }
}

fn provider_for(
  host: String,
  forced_forgejo: List(String),
) -> Result(String, String) {
  case list.contains(forced_forgejo, host) {
    True -> Ok("forgejo")
    False ->
      case host {
        "github.com" | "www.github.com" -> Ok("github")
        "gitlab.com" -> Ok("gitlab")
        "codeberg.org" -> Ok("forgejo")
        "git.sr.ht" -> Ok("sourcehut")
        _ ->
          case string.starts_with(host, "gitlab.") {
            True -> Ok("gitlab")
            False -> probe(host)
          }
      }
  }
}

/// Unknown hosts get one probe of the Forgejo/Gitea version endpoint. Anything
/// else is reported rather than guessed at.
fn probe(host: String) -> Result(String, String) {
  case fetch.get_body("https://" <> host <> "/api/v1/version", []) {
    Ok(body) ->
      case string.contains(body, "\"version\"") {
        True -> Ok("forgejo")
        False ->
          Error(
            "unknown host `"
            <> host
            <> "` — /api/v1/version did not return JSON (gated or not a Forgejo/Gitea host)",
          )
      }
    Error(reason) ->
      Error("unknown host `" <> host <> "` — probe failed: " <> reason)
  }
}
