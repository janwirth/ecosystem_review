//// repo-health-metrics — fetch the mechanically-fetchable repo-health
//// dimensions from a git forge and print them as the article table or as JSON.
////
////     gleam run -- <repo-url-or-owner/repo>... [--json] [--snapshot DATE]
////                                              [--forgejo HOST]

import argv
import gleam/io
import gleam/list
import gleam/result
import gleam/time/timestamp.{type Timestamp}
import rhm/forgejo
import rhm/github
import rhm/gitlab
import rhm/locate
import rhm/metrics.{type Metrics}
import rhm/render
import rhm/sourcehut

const usage = "repo-health-metrics — repo health dimensions from a git forge

  gleam run -- <repo>... [options]

  <repo>  a full URL (https://codeberg.org/owner/repo) or a bare owner/repo,
          which is assumed to be on GitHub.

Options
  --json               emit JSON instead of the markdown criterion table
  --snapshot <DATE>    evaluate recency against DATE (ISO, default: today)
  --forgejo <HOST>     treat HOST as a Forgejo/Gitea instance without probing
                       it first; repeatable

Environment
  GITHUB_TOKEN, GITLAB_TOKEN, CODEBERG_TOKEN, SRHT_TOKEN — all optional except
  on sourcehut, where the API is closed to anonymous callers."

type Options {
  Options(
    targets: List(String),
    json: Bool,
    snapshot: Timestamp,
    forgejo_hosts: List(String),
  )
}

pub fn main() {
  case parse(argv.load().arguments) {
    Error(message) -> {
      io.println_error(message)
      io.println_error("\n" <> usage)
    }
    Ok(options) -> {
      let repos = list.map(options.targets, fn(t) { evaluate(t, options) })
      case options.json {
        True -> io.println(render.to_json(repos, options.snapshot))
        False -> io.println(render.markdown(repos, options.snapshot))
      }
    }
  }
}

fn evaluate(target: String, options: Options) -> Metrics {
  case locate.parse(target, options.forgejo_hosts) {
    Error(reason) ->
      metrics.new(provider: "unknown", host: "", slug: target, url: target)
      |> metrics.note(reason)
    Ok(location) ->
      case location.provider {
        "github" -> github.fetch(location)
        "gitlab" -> gitlab.fetch(location)
        "forgejo" -> forgejo.fetch(location)
        "sourcehut" -> sourcehut.fetch(location)
        other ->
          metrics.new(
            provider: other,
            host: location.host,
            slug: location.path,
            url: location.url,
          )
          |> metrics.note("no provider implementation for `" <> other <> "`")
      }
  }
}

fn parse(arguments: List(String)) -> Result(Options, String) {
  let today = timestamp.system_time()
  use options <- result.try(
    arguments
    |> read(
      Options(targets: [], json: False, snapshot: today, forgejo_hosts: []),
    ),
  )
  case options.targets {
    [] -> Error("no repository given")
    targets -> Ok(Options(..options, targets: list.reverse(targets)))
  }
}

fn read(arguments: List(String), options: Options) -> Result(Options, String) {
  case arguments {
    [] -> Ok(options)
    ["--json", ..rest] -> read(rest, Options(..options, json: True))
    ["--snapshot", date, ..rest] -> {
      use snapshot <- result.try(parse_date(date))
      read(rest, Options(..options, snapshot:))
    }
    ["--forgejo", host, ..rest] ->
      read(
        rest,
        Options(..options, forgejo_hosts: [host, ..options.forgejo_hosts]),
      )
    ["--help", ..] | ["-h", ..] -> Error(usage)
    ["--" <> flag, ..] ->
      Error("unknown or incomplete option `--" <> flag <> "`")
    [target, ..rest] ->
      read(rest, Options(..options, targets: [target, ..options.targets]))
  }
}

/// `YYYY-MM-DD`, read as midnight UTC so recency is measured in whole days.
fn parse_date(input: String) -> Result(Timestamp, String) {
  timestamp.parse_rfc3339(input <> "T00:00:00Z")
  |> result.replace_error(
    "`--snapshot` expects an ISO date, got `" <> input <> "`",
  )
}
