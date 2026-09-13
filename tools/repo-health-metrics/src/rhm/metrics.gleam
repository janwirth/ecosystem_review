//// The provider-neutral record every provider module maps onto, plus the
//// small amount of shared vocabulary the renderer and scorer need.

import gleam/option.{type Option, None}
import gleam/time/timestamp.{type Timestamp}

pub type Metrics {
  Metrics(
    /// `github` / `gitlab` / `forgejo` / `sourcehut`
    provider: String,
    host: String,
    /// `owner/repo`, or `~owner/repo` on sourcehut
    slug: String,
    url: String,
    stars: Option(Int),
    /// `Some("MIT")` when known, `Some("none")` when the provider explicitly
    /// reports no license, `None` when the provider cannot tell us.
    license: Option(String),
    created_at: Option(Timestamp),
    pushed_at: Option(Timestamp),
    open_issues: Option(Int),
    default_branch: Option(String),
    latest_release: Option(String),
    archived: Option(Bool),
    /// `[dependencies].gleam_stdlib` constraint string from `gleam.toml`
    gleam_stdlib: Option(String),
    /// `target` field from `gleam.toml` (absent means "not declared")
    target: Option(String),
    dep_count: Option(Int),
    readme_bytes: Option(Int),
    /// Human-readable explanations for any ⬜ cell above.
    notes: List(String),
  )
}

pub fn new(
  provider provider: String,
  host host: String,
  slug slug: String,
  url url: String,
) -> Metrics {
  Metrics(
    provider:,
    host:,
    slug:,
    url:,
    stars: None,
    license: None,
    created_at: None,
    pushed_at: None,
    open_issues: None,
    default_branch: None,
    latest_release: None,
    archived: None,
    gleam_stdlib: None,
    target: None,
    dep_count: None,
    readme_bytes: None,
    notes: [],
  )
}

pub fn note(metrics: Metrics, text: String) -> Metrics {
  Metrics(..metrics, notes: [text, ..metrics.notes])
}
