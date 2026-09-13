//// Output. Markdown reproduces the `| Criterion | repo |` table shape used by
//// the articles in this repository; JSON is the same data unrounded.

import gleam/int
import gleam/json
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string
import gleam/time/calendar
import gleam/time/timestamp.{type Timestamp}
import rhm/metrics.{type Metrics}
import rhm/score

// --- markdown ----------------------------------------------------------------

pub fn markdown(repos: List(Metrics), snapshot: Timestamp) -> String {
  let header =
    "| Criterion | "
    <> string.join(list.map(repos, heading), " | ")
    <> " |\n| --- |"
    <> string.repeat(" --- |", list.length(repos))

  let rows =
    [
      row("Stars", repos, fn(m) {
        with_grade(count(m.stars, "★"), score.stars(m.stars))
      }),
      row("License", repos, fn(m) {
        with_grade(option.unwrap(m.license, "⬜"), score.license(m.license))
      }),
      row("Target", repos, fn(m) { target(m) }),
      row("Deps", repos, fn(m) { count(m.dep_count, "") }),
      row("Gleam compat", repos, fn(m) {
        with_grade(code(m.gleam_stdlib), score.compat(m.gleam_stdlib))
      }),
      row("Open issues", repos, fn(m) { count(m.open_issues, "") }),
      row("Latest release", repos, fn(m) {
        option.unwrap(m.latest_release, "⬜")
      }),
      row("Maintenance", repos, fn(m) { maintenance(m, snapshot) }),
      row("Age", repos, fn(m) { age(m, snapshot) }),
      row("README maturity", repos, fn(m) { readme(m) }),
      row("Idiomaticity", repos, fn(_) { "⬜ (human judgement)" }),
    ]
    |> string.join("\n")

  let body = header <> "\n" <> rows

  case notes(repos) {
    "" -> body <> "\n"
    text -> body <> "\n\n" <> text <> "\n"
  }
}

fn heading(data: Metrics) -> String {
  "[" <> data.slug <> "](" <> data.url <> ")"
}

fn row(
  name: String,
  repos: List(Metrics),
  cell: fn(Metrics) -> String,
) -> String {
  "| " <> name <> " | " <> string.join(list.map(repos, cell), " | ") <> " |"
}

fn with_grade(text: String, grade: score.Grade) -> String {
  case grade {
    score.Unknown -> "⬜"
    _ -> text <> " · " <> score.emoji(grade)
  }
}

fn count(value: Option(Int), suffix: String) -> String {
  case value {
    Some(number) -> int.to_string(number) <> suffix
    None -> "⬜"
  }
}

fn code(value: Option(String)) -> String {
  case value {
    Some(text) -> "`" <> text <> "`"
    None -> "⬜"
  }
}

fn target(data: Metrics) -> String {
  case data.target, data.dep_count {
    Some("javascript"), _ -> "📜 JS"
    Some("erlang"), _ -> "☎️ BEAM"
    Some(other), _ -> other
    // A gleam.toml was read and simply does not declare a target, which
    // usually means dual-target — but confirming that needs an `@external`
    // scan, so the cell stays ⬜ rather than inferring.
    None, Some(_) -> "⬜ (no `target` in gleam.toml)"
    None, None -> "⬜"
  }
}

fn maintenance(data: Metrics, snapshot: Timestamp) -> String {
  let grade = score.maintenance(data.pushed_at, snapshot)
  case data.pushed_at, score.days_before(data.pushed_at, snapshot) {
    Some(moment), Some(days) ->
      score.emoji(grade)
      <> " (last activity "
      <> iso(moment)
      <> ", "
      <> span(days)
      <> " before "
      <> iso(snapshot)
      <> ")"
    _, _ -> "⬜"
  }
}

fn age(data: Metrics, snapshot: Timestamp) -> String {
  let grade = score.age(data.created_at, snapshot)
  case data.created_at, score.days_before(data.created_at, snapshot) {
    Some(moment), Some(days) ->
      score.emoji(grade)
      <> " ("
      <> span(days)
      <> ", created "
      <> iso(moment)
      <> ")"
    _, _ -> "⬜"
  }
}

/// README *size* is mechanical; README *maturity* is not, so the cell reports
/// the size and leaves the grade to a human.
fn readme(data: Metrics) -> String {
  case data.readme_bytes {
    Some(bytes) ->
      "⬜ (human judgement — README is " <> int.to_string(bytes) <> " bytes)"
    None -> "⬜ (human judgement — no README fetched)"
  }
}

fn span(days: Int) -> String {
  case days {
    d if d >= 365 -> "~" <> int.to_string(d / 365) <> "y"
    d if d >= 30 -> "~" <> int.to_string(d / 30) <> "mo"
    d -> int.to_string(d) <> "d"
  }
}

fn iso(moment: Timestamp) -> String {
  timestamp.to_rfc3339(moment, calendar.utc_offset) |> string.slice(0, 10)
}

fn notes(repos: List(Metrics)) -> String {
  repos
  |> list.flat_map(fn(data) {
    let archived = case data.archived {
      Some(True) -> ["repository is archived"]
      _ -> []
    }
    list.map(list.append(archived, list.reverse(data.notes)), fn(text) {
      "- **" <> data.slug <> "**: " <> text
    })
  })
  |> string.join("\n")
}

// --- json --------------------------------------------------------------------

pub fn to_json(repos: List(Metrics), snapshot: Timestamp) -> String {
  json.object([
    #("snapshot", json.string(iso(snapshot))),
    #("repos", json.array(repos, fn(data) { repo_json(data, snapshot) })),
  ])
  |> json.to_string
}

fn repo_json(data: Metrics, snapshot: Timestamp) -> json.Json {
  json.object([
    #("provider", json.string(data.provider)),
    #("host", json.string(data.host)),
    #("slug", json.string(data.slug)),
    #("url", json.string(data.url)),
    #("stars", json.nullable(data.stars, json.int)),
    #("license", json.nullable(data.license, json.string)),
    #(
      "created_at",
      json.nullable(option.map(data.created_at, iso), json.string),
    ),
    #("pushed_at", json.nullable(option.map(data.pushed_at, iso), json.string)),
    #("open_issues", json.nullable(data.open_issues, json.int)),
    #("default_branch", json.nullable(data.default_branch, json.string)),
    #("latest_release", json.nullable(data.latest_release, json.string)),
    #("archived", json.nullable(data.archived, json.bool)),
    #("gleam_stdlib", json.nullable(data.gleam_stdlib, json.string)),
    #("target", json.nullable(data.target, json.string)),
    #("dep_count", json.nullable(data.dep_count, json.int)),
    #("readme_bytes", json.nullable(data.readme_bytes, json.int)),
    #(
      "grades",
      json.object([
        grade("stars", score.stars(data.stars)),
        grade("license", score.license(data.license)),
        grade("gleam_compat", score.compat(data.gleam_stdlib)),
        grade("maintenance", score.maintenance(data.pushed_at, snapshot)),
        grade("age", score.age(data.created_at, snapshot)),
        #("readme_maturity", json.null()),
        #("idiomaticity", json.null()),
      ]),
    ),
    #("notes", json.array(list.reverse(data.notes), json.string)),
  ])
}

fn grade(name: String, grade: score.Grade) -> #(String, json.Json) {
  #(
    name,
    json.object([
      #("emoji", json.string(score.emoji(grade))),
      #("points", json.int(score.points(grade))),
    ]),
  )
}
