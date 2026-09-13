import gleam/option.{None, Some}
import gleam/time/timestamp.{type Timestamp}
import gleeunit
import rhm/gleam_toml
import rhm/locate
import rhm/score

pub fn main() -> Nil {
  gleeunit.main()
}

const snapshot_seconds = 1_789_257_600

fn snapshot() -> Timestamp {
  timestamp.from_unix_seconds(snapshot_seconds)
}

fn days_ago(days: Int) -> Timestamp {
  timestamp.from_unix_seconds(snapshot_seconds - days * 86_400)
}

// --- thresholds from practices/formalization.md ------------------------------

pub fn stars_thresholds_test() {
  assert score.stars(Some(200)) == score.Strong
  assert score.stars(Some(199)) == score.Fine
  assert score.stars(Some(100)) == score.Fine
  assert score.stars(Some(99)) == score.Weak
  assert score.stars(Some(10)) == score.Weak
  assert score.stars(Some(9)) == score.Bad
  assert score.stars(None) == score.Unknown
}

pub fn license_thresholds_test() {
  assert score.license(Some("MIT")) == score.Fine
  assert score.license(Some("Apache-2.0")) == score.Fine
  assert score.license(Some("BSD-3-Clause")) == score.Fine
  assert score.license(Some("bsd-3-clause")) == score.Fine
  assert score.license(Some("Unlicense")) == score.Fine
  assert score.license(Some("GPL-3.0")) == score.Bad
  assert score.license(Some("MPL-2.0")) == score.Bad
  assert score.license(Some("NOASSERTION")) == score.Bad
  // The provider said "no license declared", which is a negative signal …
  assert score.license(Some("none")) == score.Bad
  // … whereas "we could not find out" is not a signal at all.
  assert score.license(None) == score.Unknown
}

pub fn compat_thresholds_test() {
  assert score.compat(Some(">= 0.44.0 and < 2.0.0")) == score.Fine
  assert score.compat(Some(">= 0.58.0 and < 1.0.0")) == score.Bad
  assert score.compat(Some("~> 0.24")) == score.Bad
  assert score.compat(Some("1.2.3")) == score.Bad
  assert score.compat(None) == score.Unknown
}

pub fn maintenance_thresholds_test() {
  assert score.maintenance(Some(days_ago(0)), snapshot()) == score.Strong
  assert score.maintenance(Some(days_ago(29)), snapshot()) == score.Strong
  assert score.maintenance(Some(days_ago(30)), snapshot()) == score.Fine
  assert score.maintenance(Some(days_ago(182)), snapshot()) == score.Fine
  assert score.maintenance(Some(days_ago(183)), snapshot()) == score.Weak
  assert score.maintenance(Some(days_ago(364)), snapshot()) == score.Weak
  assert score.maintenance(Some(days_ago(365)), snapshot()) == score.Bad
  assert score.maintenance(None, snapshot()) == score.Unknown
}

pub fn age_thresholds_test() {
  assert score.age(Some(days_ago(1095)), snapshot()) == score.Strong
  assert score.age(Some(days_ago(1094)), snapshot()) == score.Fine
  assert score.age(Some(days_ago(365)), snapshot()) == score.Fine
  assert score.age(Some(days_ago(364)), snapshot()) == score.Weak
  assert score.age(Some(days_ago(90)), snapshot()) == score.Weak
  assert score.age(Some(days_ago(89)), snapshot()) == score.Bad
  assert score.age(None, snapshot()) == score.Unknown
}

pub fn leaderboard_points_test() {
  assert score.points(score.Strong) == 2
  assert score.points(score.Fine) == 1
  assert score.points(score.Weak) == 0
  assert score.points(score.Bad) == -1
  assert score.points(score.Unknown) == 0
}

// --- gleam.toml extraction ---------------------------------------------------

pub fn gleam_toml_test() {
  let parsed =
    gleam_toml.parse(
      "name = \"pog\"
target = \"javascript\"
licences = [\"Apache-2.0\"]

[dependencies]
gleam_stdlib = \">= 0.51.0 and < 2.0.0\"
gleam_erlang = \"~> 0.24\"

[dev-dependencies]
gleeunit = \">= 1.0.0 and < 2.0.0\"
",
    )

  assert parsed.gleam_stdlib == Some(">= 0.51.0 and < 2.0.0")
  assert parsed.target == Some("javascript")
  assert parsed.licence == Some("Apache-2.0")
  // Dev-dependencies are not counted.
  assert parsed.dep_count == Some(2)
}

pub fn gleam_toml_table_dependency_test() {
  let parsed =
    gleam_toml.parse(
      "[dependencies]
gleam_stdlib = { version = \"~> 1.0\" }
",
    )
  assert parsed.gleam_stdlib == Some("~> 1.0")
  assert score.compat(parsed.gleam_stdlib) == score.Bad
}

// --- target parsing ----------------------------------------------------------

pub fn locate_test() {
  let assert Ok(bare) = locate.parse("lpil/pog", [])
  assert bare.provider == "github"
  assert bare.path == "lpil/pog"

  let assert Ok(codeberg) =
    locate.parse("https://codeberg.org/ninanonemon/shork", [])
  assert codeberg.provider == "forgejo"
  assert codeberg.path == "ninanonemon/shork"

  let assert Ok(srht) = locate.parse("https://git.sr.ht/~tpjg/dnd", [])
  assert srht.provider == "sourcehut"
  assert srht.owner == "~tpjg"
  assert srht.repo == "dnd"

  // GitLab subgroups survive; the `/-/` view marker does not.
  let assert Ok(nested) =
    locate.parse("https://gitlab.com/group/sub/repo/-/tree/main", [])
  assert nested.provider == "gitlab"
  assert nested.path == "group/sub/repo"

  // `--forgejo` skips the network probe for an unknown host.
  let assert Ok(forced) =
    locate.parse("https://git.example.org/a/b.git", ["git.example.org"])
  assert forced.provider == "forgejo"
  assert forced.repo == "b"
}
