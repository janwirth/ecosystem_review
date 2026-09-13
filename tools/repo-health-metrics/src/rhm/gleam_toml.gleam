//// Just enough `gleam.toml` reading for the rubric: the `gleam_stdlib`
//// constraint, the declared `target`, the dependency count, and the first
//// declared licence. Deliberately not a TOML parser — line-and-quote
//// extraction covers every `gleam.toml` shape the registry produces.

import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string

pub type GleamToml {
  GleamToml(
    gleam_stdlib: Option(String),
    target: Option(String),
    dep_count: Option(Int),
    licence: Option(String),
  )
}

pub fn empty() -> GleamToml {
  GleamToml(None, None, None, None)
}

type State {
  State(toml: GleamToml, section: String, deps: Int)
}

pub fn parse(source: String) -> GleamToml {
  let state =
    string.split(source, "\n")
    |> list.fold(State(empty(), "", 0), line)
  GleamToml(..state.toml, dep_count: Some(state.deps))
}

fn line(state: State, raw: String) -> State {
  case string.trim(raw) {
    "" -> state
    "#" <> _ -> state
    "[" <> rest -> State(..state, section: string.replace(rest, "]", ""))
    text -> assignment(state, text)
  }
}

fn assignment(state: State, text: String) -> State {
  case string.split_once(text, "=") {
    Error(_) -> state
    Ok(#(key, value)) ->
      case state.section, string.trim(key) {
        "dependencies", "gleam_stdlib" ->
          State(
            ..state,
            toml: GleamToml(..state.toml, gleam_stdlib: quoted(value)),
            deps: state.deps + 1,
          )
        "dependencies", _ -> State(..state, deps: state.deps + 1)
        "", "target" ->
          State(..state, toml: GleamToml(..state.toml, target: quoted(value)))
        "", "licences" | "", "licenses" ->
          State(..state, toml: GleamToml(..state.toml, licence: quoted(value)))
        _, _ -> state
      }
  }
}

/// The first double-quoted run in a value, which works equally for
/// `">= 1.0.0 and < 2.0.0"`, `["MIT"]` and `{ version = "~> 1.0" }`.
fn quoted(value: String) -> Option(String) {
  case string.split(value, "\"") {
    [_, found, ..] -> Some(found)
    _ -> None
  }
}

pub fn describe_deps(toml: GleamToml) -> String {
  case toml.dep_count {
    Some(count) -> int.to_string(count)
    None -> "⬜"
  }
}
