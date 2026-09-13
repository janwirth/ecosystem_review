//// Repository-file dimensions: the `gleam.toml` fields and the README size.
//// Providers supply a function that turns a file path into a raw-content URL;
//// the rest is identical everywhere.

import gleam/bit_array
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string
import rhm/fetch
import rhm/gleam_toml
import rhm/metrics.{type Metrics, Metrics}

pub fn apply(
  data: Metrics,
  headers: List(#(String, String)),
  raw_url: fn(String) -> String,
) -> Metrics {
  data
  |> with_gleam_toml(headers, raw_url)
  |> with_readme(headers, raw_url)
}

fn with_gleam_toml(
  data: Metrics,
  headers: List(#(String, String)),
  raw_url: fn(String) -> String,
) -> Metrics {
  case fetch.get_body(raw_url("gleam.toml"), headers) {
    Error(_) ->
      metrics.note(
        data,
        "no `gleam.toml` reachable — not a Gleam package, or "
          <> "the default branch could not be resolved",
      )
    Ok(source) -> {
      let toml = gleam_toml.parse(source)
      Metrics(
        ..data,
        gleam_stdlib: toml.gleam_stdlib,
        target: toml.target,
        dep_count: toml.dep_count,
        // Only used where the forge API has no license field of its own.
        license: option.or(data.license, toml.licence),
      )
      |> stdlib_cap_note(toml.gleam_stdlib)
    }
  }
}

/// A `gleam_stdlib` upper bound below 1.0 still satisfies the rubric's
/// "is it a range" test, but in practice it means the package was written
/// against pre-1.0 stdlib and usually fails to install in a current project.
/// The score is left alone; the reader gets told to reproduce the install.
fn stdlib_cap_note(data: Metrics, constraint: Option(String)) -> Metrics {
  case constraint {
    Some(text) ->
      case string.contains(text, "< 1.0.0") || string.contains(text, "<1.0.0") {
        True ->
          metrics.note(
            data,
            "`gleam_stdlib` is capped below 1.0.0 — this scores 🟩 on the "
              <> "range rule but is a known install-failure signal; reproduce "
              <> "`gleam add` in a fresh project before trusting the cell",
          )
        False -> data
      }
    None -> data
  }
}

fn with_readme(
  data: Metrics,
  headers: List(#(String, String)),
  raw_url: fn(String) -> String,
) -> Metrics {
  let body =
    fetch.get_body(raw_url("README.md"), headers)
    |> result.try_recover(fn(_) {
      fetch.get_body(raw_url("readme.md"), headers)
    })

  case body {
    Ok(text) ->
      Metrics(
        ..data,
        readme_bytes: Some(bit_array.byte_size(bit_array.from_string(text))),
      )
    Error(_) -> Metrics(..data, readme_bytes: None)
  }
}
