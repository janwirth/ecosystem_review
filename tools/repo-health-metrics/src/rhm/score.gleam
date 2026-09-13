//// The thresholds from `practices/formalization.md`, and nothing else.
////
//// README maturity and Idiomaticity are deliberately absent: they are human
//// judgement calls and the tool emits ⬜ for them rather than guessing.

import gleam/float
import gleam/option.{type Option, None, Some}
import gleam/string
import gleam/time/duration
import gleam/time/timestamp.{type Timestamp}

pub type Grade {
  /// 🟩🟩 — strong signal, +2 on the leaderboard sum
  Strong
  /// 🟩 — fine, +1
  Fine
  /// 🟨 — neutral, 0
  Weak
  /// 🟥 — negative signal, −1
  Bad
  /// ⬜ — not knowable from the data we could fetch
  Unknown
}

pub fn emoji(grade: Grade) -> String {
  case grade {
    Strong -> "🟩🟩"
    Fine -> "🟩"
    Weak -> "🟨"
    Bad -> "🟥"
    Unknown -> "⬜"
  }
}

/// Leaderboard weighting from formalization.md. `Unknown` contributes nothing.
pub fn points(grade: Grade) -> Int {
  case grade {
    Strong -> 2
    Fine -> 1
    Weak -> 0
    Bad -> -1
    Unknown -> 0
  }
}

/// 🟩🟩 ≥200 · 🟩 ≥100 · 🟨 ≥10 · 🟥 <10
pub fn stars(stars: Option(Int)) -> Grade {
  case stars {
    None -> Unknown
    Some(n) if n >= 200 -> Strong
    Some(n) if n >= 100 -> Fine
    Some(n) if n >= 10 -> Weak
    Some(_) -> Bad
  }
}

/// 🟩 MIT/Apache/BSD/Unlicense · 🟥 anything else, including none declared.
/// `None` means the provider could not tell us, which is ⬜ rather than 🟥.
pub fn license(license: Option(String)) -> Grade {
  case license {
    None -> Unknown
    Some(spdx) -> {
      let spdx = string.uppercase(spdx)
      case
        string.contains(spdx, "MIT")
        || string.contains(spdx, "APACHE")
        || string.contains(spdx, "BSD")
        || string.contains(spdx, "UNLICENSE")
      {
        True -> Fine
        False -> Bad
      }
    }
  }
}

/// 🟩 a `>= X and < Y` range · 🟥 a `~>` pin or any other shape.
pub fn compat(constraint: Option(String)) -> Grade {
  case constraint {
    None -> Unknown
    Some(text) ->
      case string.contains(text, ">=") && string.contains(text, "<") {
        // A `< 1.0.0` cap on gleam_stdlib breaks on current toolchains
        // (CLAUDE.md: carpenter / glemo / bravo / shork / migrant).
        True ->
          case string.contains(text, "< 1.0") {
            True -> Bad
            False -> Fine
          }
        False -> Bad
      }
  }
}

/// Recency half of the Maintenance dimension:
/// 🟩🟩 <1mo · 🟩 <6mo · 🟨 <1yr · 🟥 older.
///
/// The responsiveness half (owner reply latency) needs issue-timeline
/// traversal and is not implemented; see METHODOLOGY.md.
pub fn maintenance(pushed: Option(Timestamp), snapshot: Timestamp) -> Grade {
  case days_before(pushed, snapshot) {
    None -> Unknown
    Some(days) if days < 30 -> Strong
    Some(days) if days < 183 -> Fine
    Some(days) if days < 365 -> Weak
    Some(_) -> Bad
  }
}

/// 🟩🟩 ≥3yr · 🟩 ≥1yr · 🟨 ≥3mo · 🟥 younger.
pub fn age(created: Option(Timestamp), snapshot: Timestamp) -> Grade {
  case days_before(created, snapshot) {
    None -> Unknown
    Some(days) if days >= 1095 -> Strong
    Some(days) if days >= 365 -> Fine
    Some(days) if days >= 90 -> Weak
    Some(_) -> Bad
  }
}

/// Whole days between `moment` and `snapshot`. Negative gaps (a timestamp in
/// the future relative to the snapshot) clamp to 0.
pub fn days_before(
  moment: Option(Timestamp),
  snapshot: Timestamp,
) -> Option(Int) {
  case moment {
    None -> None
    Some(moment) -> {
      let seconds =
        timestamp.difference(moment, snapshot)
        |> duration.to_seconds
      case seconds <. 0.0 {
        True -> Some(0)
        False -> Some(float.truncate(seconds /. 86_400.0))
      }
    }
  }
}
