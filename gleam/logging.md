# Logging in Gleam

> [!NOTE]
> **Status:** DRAFT · **Authoring:** AI-assisted, human-reviewed.

Need to emit logs from your Gleam app — pretty in development, structured JSON in production, maybe on BEAM, maybe on JS?
This article maps out what's available.

## Table of Contents

1. [Summary](#summary)
2. [Research Method](#research-method)
   - [Scoring Dimensions](#scoring-dimensions)
   - [Discovery](#discovery)
3. [Categories](#categories)
   - [Erlang `logger` Adapters](#erlang-logger-adapters) — [logging](#logging) · [glog](#glog)
   - [Structured Loggers (Dual-Target)](#structured-loggers-dual-target) — [palabres](#palabres) · [glogg](#glogg) · [flash](#flash) · [woof](#woof)
   - [Structured Loggers (BEAM)](#structured-loggers-beam) — [glight](#glight) · [glimt](#glimt)
   - [Specialist Logs](#specialist-logs) — [gclog](#gclog) · [gbr_disk_log](#gbr_disk_log)
   - [Observability Suites](#observability-suites) — [viva_telemetry](#viva_telemetry)
   - [Adjacent](#adjacent) — [redact](#redact) · [stacky](#stacky)
4. [Leaderboard](#leaderboard)

## Summary

**Snapshot 2026-04-24.** The Gleam logging story splits cleanly on target: on BEAM, most libraries delegate to Erlang's OTP `logger`; on JS, everything falls back to `console.*`. **[logging](#logging)** (lpil) is the minimum-viable wrapper and the most widely-depended-on option. **[palabres](#palabres)** is the most polished dual-target structured logger. The rest is a long tail of experiments, some young, some abandoned.

A recurring pattern: Louis Pilfold (Gleam's creator) has filed issues against several libraries (`flash`, `woof`, `glimt`) pointing out they *print* rather than integrate with the BEAM `logger` — so log level filtering, `logger:add_handler`, and log forwarding don't work. Treat that as the defining line between "toy logger" and "production logger" on BEAM.

| Category | ☎️ BEAM | 📜 JS |
| --- | --- | --- |
| **[Erlang `logger` Adapters](#erlang-logger-adapters)** | · [🥇](#leaderboard) [logging](#logging) ([repo](https://github.com/lpil/logging), 12★) — *minimal OTP `logger` config wrapper*<br>· [glog](#glog) ([repo](https://github.com/defgenx/glog), 11★) — *Logrus-inspired fluent fields, dormant since 2024* | — |
| **[Structured Loggers (Dual-Target)](#structured-loggers-dual-target)** | · [🥇\*](#leaderboard) [woof](#woof) ([repo](https://github.com/lupodevelop/woof), 11★) — *highest raw score; default sink prints — opt in to `beam_logger_sink`*<br>· [🥇](#leaderboard) [palabres](#palabres) ([repo](https://github.com/ghivert/palabres), 9★) — *opinionated structured + JSON, Wisp integration*<br>· [🥈](#leaderboard) [glogg](#glogg) ([repo](https://github.com/webermarci/glogg), 1★) — *handler-based, hook pipelines*<br>· [🥈\*](#leaderboard) [flash](#flash) ([repo](https://github.com/larzconwell/flash), 18★) — *structured, but prints instead of logging on BEAM* | · [🥇\*](#leaderboard) [woof](#woof)<br>· [🥇](#leaderboard) [palabres](#palabres)<br>· [🥈](#leaderboard) [glogg](#glogg)<br>· [🥈\*](#leaderboard) [flash](#flash) |
| **[Structured Loggers (BEAM)](#structured-loggers-beam)** | · [🥇](#leaderboard) [glight](#glight) ([repo](https://github.com/distrill/glight), 4★) — *multi-transport, fluent context*<br>· [🥉](#leaderboard) [glimt](#glimt) ([repo](https://github.com/JohnBjrk/glimt), 31★) — *dispatcher/serializer split, dormant since 2024* | — |
| **[Specialist Logs](#specialist-logs)** | · [🥉](#leaderboard) [gbr_disk_log](#gbr_disk_log) ([repo](https://github.com/gleam-br/gbr_disk_log), 1★) — *typed wrapper for Erlang `disk_log`*<br>· [gclog](#gclog) ([repo](https://github.com/sam-kenney/gclog), 0★) — *GCP-compliant JSON entries* | · [gclog](#gclog) *(pure Gleam; infer JS support)* |
| **[Observability Suites](#observability-suites)** | · [viva_telemetry](#viva_telemetry) ([repo](https://github.com/gabrielmaialva33/viva_telemetry), 1★) — *logs + metrics + benchmarks* | — |
| **[Adjacent](#adjacent)** | · [redact](#redact) ([repo](https://gitlab.com/ericcodes/gleam-redact)) — *mask secrets before they hit any logger*<br>· [stacky](#stacky) ([repo](https://github.com/inoas/stacky), 12★) — *BEAM stack traces in typed Gleam* | · [redact](#redact) *(pure Gleam)* |

<a id="sink-callout"></a>
> [!IMPORTANT]
> **What "sink" means and why it's the load-bearing question on BEAM.** A *sink* is the final piece of code that actually writes log bytes somewhere — stdout, a file, OTP `logger`, etc. On BEAM the right sink is **OTP `logger`**, because routing through it gives you: runtime level filtering (`logger:set_module_level/2`), pluggable handlers (file rotation, syslog, journald, JSON formatters, log shippers like Datadog/Loki), shared output with library logs (`gleam_otp`, `ssl`, `inets`, Wisp middleware), per-process metadata (request IDs etc.), and OTP-native test capture/suppression. A sink that calls `io:format` straight to stdout skips all of that — your debug lines print no matter what config says, your shipper sees nothing, and your logs interleave with library logs in a mess.
>
> The gold-standard path on BEAM is: use [logging](#logging) for basic output, or [palabres](#palabres) if you need structured/JSON. Both route through OTP `logger` by default. [woof](#woof) (since v1.4) ships `woof.prod()` — a one-call preset that wires the OTP `logger` sink — so it's also gold-tier as long as you call it (the bare-`woof.info` quick-start path still bypasses OTP). [flash](#flash) currently has no opt-in escape and is the only library here that's unconditionally a stdout printer on BEAM ([upstream #4](https://github.com/larzconwell/flash/issues/4)).

> [!NOTE]
> On JS, OTP `logger` doesn't exist. Dual-target libraries fall back to `console.log` / `console.error` with a level prefix. That's a fine baseline, but don't expect parity with the BEAM side for things like handler routing — that's a platform gap, not a library gap.

> <details>
> <summary><strong>Dependency Graph</strong></summary>
>
> Arrows read "uses."
>
> **Erlang `logger` adapters:**
> - [logging](#logging) → Erlang OTP `logger` (built-in)
> - [glog](#glog) → Erlang OTP `logger`
>
> **Dual-target structured:**
> - [palabres](#palabres) → Erlang OTP `logger` + `json` (OTP 27+) / `console.*` on JS
> - [glogg](#glogg) → [logging](#logging) + custom JSON formatter / `console.*` on JS
> - [flash](#flash) → `io:format` on BEAM / `console.*` on JS (no OTP `logger` integration — [see issue #4](https://github.com/larzconwell/flash/issues/4))
> - [woof](#woof) → `io:format` by default; `woof.prod()` preset (or `set_sinks([beam_logger_sink])`) routes through OTP `logger` / `console.*` on JS
>
> **BEAM structured:**
> - [glight](#glight) → [logging](#logging) + Erlang `logger` + file transport
> - [glimt](#glimt) → Erlang `logger` (optional formatter) + custom dispatchers
>
> **Specialist:**
> - [gbr_disk_log](#gbr_disk_log) → Erlang `disk_log` (OTP built-in)
> - [gclog](#gclog) → `gleam_json` + stderr (pure Gleam)
>
> **Adjacent:**
> - [redact](#redact) → pure Gleam (filter before logging)
> - [stacky](#stacky) → Erlang `erlang:process_info`/`raise`
>
> </details>

## Research Method

### Scoring Dimensions

Same rubric as [web-apps.md](./web-and-http/web-apps.md#scoring-dimensions). Recap:

- **Stars:** 🟩🟩 ≥200★, 🟩 ≥100★, 🟨 ≥10★, 🟥 <10★.
- **License:** 🟩 permissive (MIT/Apache/BSD). 🟥 viral or missing.
- **Gleam compat:** `gleam_stdlib` constraint format. 🟩 range (`>= X and < Y`), 🟥 `~>` pin.
- **Maintenance:** max(recency, responsiveness). 🟩🟩 <1 mo / <2 d / clean tracker, 🟩 <6 mo / <1 wk, 🟨 <1 yr / <1 mo, 🟥 older / ignored.
- **Age:** 🟩🟩 ≥3 yrs, 🟩 ≥1 yr, 🟨 ≥3 mo, 🟥 <3 mo.
- **README maturity:** 🟩🟩 full guide + examples, 🟩 clear tagline + usage, 🟥 minimal.
- **Idiomaticity:** 🟩 typed/explicit, 🟥 magic directives or template extraction.

**Leaderboard scoring:** 🟥 = −1, 🟨 = 0, 🟩 = 1, 🟩🟩 = 2. Sum of 7 dimensions. Max = 13.

### Discovery

Searched [packages.gleam.run](https://packages.gleam.run/) and [gleam-lang/awesome-gleam](https://github.com/gleam-lang/awesome-gleam) — **11 repos included** (below), **5 disregarded**.

- [log](https://packages.gleam.run/?search=log)
- [logging](https://packages.gleam.run/?search=logging)
- [logger](https://packages.gleam.run/?search=logger)

> <details>
> <summary>5 disregarded — abandoned, hidden, or out-of-scope</summary>
>
> **Repository gone:**
> - **[tylerbutler/birch](https://github.com/tylerbutler/birch)** (hex: `birch` v0.2.1, pub 2026-02-15) — "A logging library for Gleam with cross-platform support." The hex package exists, the README is thorough, but **the GitHub repo returns 404** at snapshot. No way to evaluate commit history, issues, or source. Excluding until the repo surfaces.
>
> **Low-traction / docs-only hosts:**
> - **wolf** (hex: `wolf` v1.0.0, pub 2024-06-25, Apache-2.0) — "An user friendly logger." No repository URL on hex or hexdocs; source is hidden. 1 release, ~2 years old with no follow-up.
> - **pine** ([gitea.attum.co/wqtt/pine.git](https://gitea.attum.co/wqtt/pine.git)) — "configurable logger for gleam." Self-hosted Gitea instance, last hex release 2024-08-02. Off-GitHub, no star signal, no visible activity.
> - **glimpse_log** (hex: `glimpse_log` v0.2.0, pub 2024-09-28, Apache-2.0) — "A minimal logger for gleam on Erlang or Javascript." No repository URL on hex page. 0.2.0 still, no follow-up.
>
> **Out of scope — styling, not logging:**
> - **[Genekkion/the_stars](https://github.com/Genekkion/the_stars)** — "Gleam terminal styling and logging framework." README is explicit that it's "mainly for printing out text in the terminal with styles such as colors, bolding, underlining" — a Lipgloss clone. No log levels, sinks, or handler routing. 1★.
>
> </details>

## Categories

### Erlang `logger` Adapters

Thin wrappers that route Gleam calls into Erlang's OTP `logger`. Level filtering, handler config, and log forwarding from dependencies all Just Work because OTP does the heavy lifting.

| Criterion | [logging](https://github.com/lpil/logging) [🥇](#leaderboard) | [glog](https://github.com/defgenx/glog) |
| --- | --- | --- |
| Stars | 12★ · 🟨 | 11★ · 🟨 |
| License | Apache-2.0 · 🟩 | Apache-2.0 · 🟩 |
| Target | ☎️ BEAM | ☎️ BEAM |
| Deps | 1 (`gleam_stdlib`) | 2 |
| Gleam compat | `~> 0.34 or ~> 1.0` · 🟨 ([see note](#logging-compat)) | `~> 0.36` · 🟥 |
| Open issues | 0 · 🟩🟩 | 0 · 🟩🟩 |
| Maintenance | 🟩🟩 (last commit 2026-04-03, ~3 weeks) | 🟥 (last commit 2024-04-12, ~2 yrs dormant) |
| Age | ~2 yrs · 🟩 | ~3 yrs · 🟩🟩 |
| README maturity | 🟩 (tagline + install + usage + `NO_COLOUR` env note) | 🟩 (Logrus-style example + unfinished TODO list) |
| Idiomaticity | 🟩 (explicit `configure` + typed levels) | 🟩 (typed levels + fluent field builder) |

#### logging
[repo](https://github.com/lpil/logging) · [🥇](#leaderboard)

Minimal adapter to the OTP `logger`. Call `logging.configure()` once at startup; then `logging.log(Info, "…")` emits through the Erlang `logger` pipeline — handlers, formatters, levels, the lot. Authored by Louis Pilfold. Most downloaded logging package on hex; the implicit "canonical" BEAM choice for Gleam apps. 0 open issues at snapshot.

<a id="logging-compat"></a>
**Compat note:** `gleam.toml` pins `gleam_stdlib = "~> 0.34 or ~> 1.0"`. That's the `~>` pattern our rubric marks 🟥, but the `or ~> 1.0` disjunction widens it to cover all of Gleam 1.x. Marked 🟨 — functionally compatible, but worth re-evaluating when Gleam 2.0 ships.

```gleam
import logging.{Info}

pub fn main() {
  logging.configure()
  logging.log(Info, "Hello, Joe!")
}
```

#### glog
[repo](https://github.com/defgenx/glog)

Erlang `logger` wrapper with a fluent API deliberately modelled on Go's Logrus: attach typed fields to an entry, then call `infof`/`warnf` with a format string. Clever design, but last commit is April 2024 (~2 years dormant) and the README itself lists "documentation," "unit tests," and "configuration API" as TODO. 0 open issues but that's survivorship bias — nobody's filing against dead repos. The `~> 0.36` stdlib pin also excludes it from modern Gleam projects without an override.

### Structured Loggers (Dual-Target)

Pure-Gleam libraries that claim to run on both BEAM and JavaScript. All four ship JSON output and a field/context API; they diverge sharply on **how the BEAM side emits bytes** — the load-bearing question on this platform.

| Criterion | [palabres](https://github.com/ghivert/palabres) [🥇](#leaderboard) | [glogg](https://github.com/webermarci/glogg) [🥈](#leaderboard) | [flash](https://github.com/larzconwell/flash) [🥈\*](#leaderboard) | [woof](https://github.com/lupodevelop/woof) [🥇\*](#leaderboard) |
| --- | --- | --- | --- | --- |
| Stars | 9★ · 🟥 | 1★ · 🟥 | 18★ · 🟨 | 11★ · 🟨 |
| License | MIT · 🟩 | MIT · 🟩 | BSD-2-Clause-Patent · 🟩 | MIT · 🟩 |
| Target | ☎️📜 Both | ☎️📜 Both | ☎️📜 Both | ☎️📜 Both |
| Deps | few (inc. `gleam_json`) | few (inc. `logging`) | 2 | 1 (`gleam_stdlib`) |
| Gleam compat | `>= 0.60 and < 2.0` · 🟩 | `>= 0.44 and < 2.0` · 🟩 | `>= 0.65 and < 1.0` · 🟩 | `>= 0.44 and < 2.0` · 🟩 |
| Open issues | 1 · 🟩 | 1 (Renovate bot) · 🟩 | 1 · 🟥 ([prints instead of logs](#flash)) | 1 · 🟥 ([prints instead of logs](#woof)) |
| Maintenance | 🟩🟩 (last commit 2026-04-22, ~1 day) | 🟩🟩 (last commit 2026-02-09, ~2.5 mo) | 🟩 (last commit 2025-10-21, ~6 mo) | 🟩🟩 (last commit 2026-04-21, ~2 days) |
| Age | ~1.3 yrs (Dec 2024) · 🟩 | ~7 mo (Sep 2025) · 🟨 | ~1.5 yrs (Nov 2024) · 🟩 | ~1.1 yrs (Mar 2025) · 🟩 |
| README maturity | 🟩🟩 (guide, JSON example, Wisp integration, OTP 27 callout) | 🟩🟩 (features, handlers, hook pipelines, redaction example) | 🟩 (tagline + text/JSON writer examples + attribute types) | 🟩🟩 (levels, sinks, migrations, env config, instanced loggers) |
| Idiomaticity | 🟩 (pipe-chain field builder, typed options) | 🟩 (typed fields, explicit handler setup) | 🟩 (typed attrs/groups, writers) | 🟩 (typed levels, `set_level_from_env`) |
| | | | | |
| **Features** | | | | |
| Structured fields | ✅ | ✅ | ✅ | ✅ |
| JSON output | ✅ | ✅ (default) | ✅ | ✅ |
| Log levels | ✅ (debug..error) | ✅ | ✅ | ✅ (8 levels) |
| OTP `logger` integration | ✅ | ✅ (via `logging`) | ❌ (prints) | one-call (`woof.prod()`) or explicit (`beam_logger_sink`) |
| Hook / middleware pipeline | — | ✅ | — | — |
| Framework integration | Wisp (`palabres_wisp`) | — | — | — |

#### palabres
[repo](https://github.com/ghivert/palabres) · [🥇](#leaderboard)

"Opinionated logger for Gleam, targetting both BEAM and JS." Pipe-chain a message through `palabres.string/int/...` to attach structured fields, then `log`. On BEAM it goes through OTP `logger` (so `logger:add_handler`, `set_module_level`, etc. all work); on JS it falls back to `console`. Optional JSON output is first-class, and there's a dedicated `palabres_wisp` package that wires request logging into Wisp middleware. Requires OTP 27+ for the built-in `json` module. Most polished dual-target option at snapshot.

```gleam
import palabres
import palabres/options

pub fn main() {
  options.defaults()
  |> options.color(True)
  |> options.json(False)
  |> options.output(to: options.stdout())
  |> palabres.configure

  palabres.debug("Starting worker")
  |> palabres.string("worker_id", "wrk_3aa3")
  |> palabres.int("retries", 0)
  |> palabres.log
}
```

#### glogg
[repo](https://github.com/webermarci/glogg) · [🥈](#leaderboard)

"Named after the traditional Scandinavian mulled wine." Handler-based architecture: register one or more handlers with per-handler level filters and a hook pipeline for transforming events before they're written. The hook pipeline is the feature that distinguishes it — e.g., a hook that redacts `password` fields across every logger in the process. On BEAM, defers to lpil's `logging` package for the `logger` adapter. Only 1★ and a single open Renovate bot issue, but README is surprisingly thorough.

```gleam
import glogg
import glogg/level

pub fn main() {
  glogg.new()
  |> glogg.with_handler(glogg.stdout_handler(level.Info))
  |> glogg.with_hook(redact_password)
  |> glogg.setup

  glogg.info("user login")
  |> glogg.string("user_id", "usr_42")
  |> glogg.emit
}
```

#### flash
[repo](https://github.com/larzconwell/flash) · [🥈\*](#leaderboard)

"Gleam package enabling structured logging in both Erlang and JavaScript environments." Typed attributes, text and JSON writers, nested groups. On paper it ticks every structured-logging box.

<a id="flash-caveat"></a>
**Caveat ([#4](https://github.com/larzconwell/flash/issues/4)):** lpil filed an issue on 2025-08-08 titled *"Package is printing to the console instead of logging"* — on BEAM, flash writes to stdout via `io:format` rather than routing through OTP `logger`. That means OTP-level handlers, level filtering, and log forwarding don't see flash output. Unresolved at snapshot. Rules flash out of production BEAM use until fixed.

#### woof
[repo](https://github.com/lupodevelop/woof) · [🥇\*](#leaderboard)

"A straightforward logging library for Gleam. Dedicated to Echo, my dog." Eight log levels (Info..Emergency), typed fields that preserve Gleam types for pattern matching in tests, multi-sink dispatch, and instanced loggers for per-request scoped context. README is the most thorough of the four, and has the only built-in env-var level control (`set_level_from_env()`). Highest raw score in this review (8) — but see caveat below.

<a id="woof-caveat"></a>
**Caveat ([#6](https://github.com/lupodevelop/woof/issues/6)):** lpil filed *"implemented as a printing library instead of a logging library"* on 2026-03-15. The author responded in v1.4 (Apr 2026) by adding two one-call presets: `woof.dev()` (Debug level, text format, stdout — matches the pre-v1.4 default) and `woof.prod()` (Info level, JSON format, **OTP `logger` sink**). So the fix is in the library: call `woof.prod()` once at startup and woof routes through OTP `logger` like `logging`/`palabres` do — every concern in the [main callout above](#sink-callout) is addressed.

The only friction left: the README's opening quick-start (`woof.info(...)` with no setup) still defaults to the stdout path. One line at the top of `pub fn main()` — `woof.prod()` — flips it. Anyone shipping to prod will see the preset documented under "One-call setup" and use it.

```gleam
import woof

pub fn main() {
  // Production: OTP logger sink + JSON, one call.
  woof.prod()

  // — or, for explicit control —
  // woof.set_sinks([woof.beam_logger_sink])

  woof.info("cache hit", [woof.str("key", "user:42")])
}
```

### Structured Loggers (BEAM)

BEAM-only pure-Gleam loggers. Same shape as the dual-target group but narrower in scope.

| Criterion | [glight](https://github.com/distrill/glight) [🥇](#leaderboard) | [glimt](https://github.com/JohnBjrk/glimt) [🥉](#leaderboard) |
| --- | --- | --- |
| Stars | 4★ · 🟥 | 31★ · 🟨 |
| License | MIT · 🟩 | Apache-2.0 · 🟩 |
| Target | ☎️ BEAM | ☎️ BEAM |
| Deps | several (inc. `logging`) | several (inc. `gleam_json`, `gleam_otp`) |
| Gleam compat | `>= 0.62 and < 1.0` · 🟩 ([see caveat](#glight-compat)) | `~> 0.36` · 🟥 |
| Open issues | 0 · 🟩🟩 | 1 · 🟩 |
| Maintenance | 🟩🟩 (last commit 2026-03-28, ~1 mo) | 🟥 (last commit 2024-03-19, ~2 yrs dormant) |
| Age | ~1 yr (Apr 2025) · 🟩 | ~3 yrs (Dec 2022) · 🟩🟩 |
| README maturity | 🟩🟩 (transports, JSON/text outputs, context builder, fluent API) | 🟩🟩 (dispatcher/serializer docs, Erlang integration, roadmap) |
| Idiomaticity | 🟩 (fluent `with()` chaining, typed levels) | 🟩 (explicit dispatcher + serializer split) |

#### glight
[repo](https://github.com/distrill/glight) · [🥇](#leaderboard)

"Shining light onto your gleam applications." Fluent API — `glight.logger() |> glight.with("user_id", "42") |> glight.info("login")` — with multiple transports (console, JSON file), colour output, eight log levels, and configurable JSON field names. Builds on lpil's `logging` for the OTP `logger` hop, so it plays nicely with the rest of the BEAM ecosystem. Zero open issues, active (last commit March 2026).

<a id="glight-compat"></a>
**Compat caveat:** `gleam_stdlib` upper bound is `< 1.0.0`. Formally a range (🟩), but it'll conflict with any project already on Gleam 1.x stdlib — widen to `< 2.0.0` locally.

```gleam
import glight

pub fn main() {
  glight.logger()
  |> glight.with("request_id", "req_3aa3")
  |> glight.with("user_id", "usr_42")
  |> glight.info("request handled")
}
```

#### glimt
[repo](https://github.com/JohnBjrk/glimt) · [🥉](#leaderboard)

"Get a glimpse (glimt in Swedish) of what is going on inside your software." The most architecturally ambitious of the pure-Gleam loggers: explicit separation between *dispatcher* (sync vs actor-based async) and *serializer* (human-readable, JSON, Erlang `logger` formatter). Levels from trace to fatal, contextual data binding, async dispatch via BEAM actors. Highest star count (31★) in this review — but last commit March 2024, stdlib pinned to `~> 0.36`, and the single open issue (from lpil in 2022) is still *"Consider using the BEAM logger."* Interesting reference design; not currently a maintained choice.

### Specialist Logs

Narrow-purpose libraries outside the general-purpose logger shape.

| Criterion | [gbr_disk_log](https://github.com/gleam-br/gbr_disk_log) [🥉](#leaderboard) | [gclog](https://github.com/sam-kenney/gclog) |
| --- | --- | --- |
| Stars | 1★ · 🟥 | 0★ · 🟥 |
| License | Apache-2.0 · 🟩 | MIT · 🟩 |
| Target | ☎️ BEAM (Erlang `disk_log` NIF) | ☎️📜 Both (pure Gleam, inferred) |
| Open issues | 0 · 🟩🟩 | 1 · 🟩 |
| Maintenance | 🟩🟩 (last commit 2026-03-13, ~6 wks) | 🟥 (last commit 2024-12-05, ~17 mo dormant) |
| Age | ~6 wks (Mar 2026) · 🟥 | ~1.4 yrs (Dec 2024) · 🟩 |
| README maturity | 🟩🟩 (use cases, quickstart, honest limitations section) | 🟩🟩 (three usage tiers: simple, structured, full entry with traces/spans) |
| Idiomaticity | 🟩 (typed wrapper over OTP primitive) | 🟩 (typed severities, custom serializers) |

#### gbr_disk_log
[repo](https://github.com/gleam-br/gbr_disk_log) · [🥉](#leaderboard)

Type-safe Gleam wrapper around Erlang's `disk_log` — the OTP built-in for circular on-disk event persistence. Not a general logger; purpose-built for high-frequency, crash-safe event streams (audit trails, WALs, IoT telemetry). README is refreshingly honest about what it *isn't*: not human-readable, not distributed, single-node only. Zero open issues, active. Very young (~6 weeks), so 🟥 on age.

#### gclog
[repo](https://github.com/sam-kenney/gclog)

"A simple Google Cloud Platform compliant logging library for Gleam." Emits JSON matching GCP's LogEntry schema (severity, trace, span, source location, labels). Three usage tiers from plain string log to fully-decorated entry. Specialist output shape only worth using if you're shipping to Google Cloud Logging. 17 months dormant, 3 total commits, 1 open issue — low confidence.

### Observability Suites

Libraries that bundle logging with other observability primitives.

| Criterion | [viva_telemetry](https://github.com/gabrielmaialva33/viva_telemetry) |
| --- | --- |
| Stars | 1★ · 🟥 |
| License | Apache-2.0 · 🟩 |
| Target | ☎️ BEAM |
| Open issues | 0 · 🟩🟩 |
| Maintenance | ⬜ (/commits page shows "no commit history" at snapshot — [see note](#viva_telemetry-note)) |
| Age | ⬜ |
| README maturity | 🟩🟩 (RFC 5424 levels, context propagation, sampling, multi-handler output, metrics, benchmarks) |
| Idiomaticity | 🟩 (typed levels/handlers, lazy evaluation) |

<a id="viva_telemetry-note"></a>
#### viva_telemetry
[repo](https://github.com/gabrielmaialva33/viva_telemetry)

"Professional observability suite for Gleam: structured logging, metrics, and statistical benchmarking." Bundles three concerns into one package: RFC 5424 structured logging with sampling + lazy evaluation, counter/gauge/histogram metrics with Prometheus export, and statistical benchmarking (percentiles, confidence intervals).

**Access anomaly:** at snapshot, the `/commits/main` page returns "There isn't any commit history to show here," despite the repo being public and hex version 1.0.1 dated recently. Cannot assess maintenance recency or commit volume. Marked ⬜ on maintenance and age pending repo state clarification. Use at own risk until history is browsable.

### Adjacent

Not loggers themselves, but routinely paired with one.

| Criterion | [redact](https://gitlab.com/ericcodes/gleam-redact) | [stacky](https://github.com/inoas/stacky) |
| --- | --- | --- |
| Stars | ⬜ (GitLab) | 12★ · 🟨 |
| License | Apache-2.0 · 🟩 | MPL-2.0 · 🟩 |
| Target | ☎️📜 Both (inferred; pure Gleam) | ☎️ BEAM |
| Open issues | ⬜ | 2 |
| Maintenance | 🟩 (created Sep 2025, 3 commits) | 🟥 (last commit 2024-06-06, ~22 mo dormant) |
| Age | ~7 mo · 🟨 | ~2 yrs · 🟩 |
| README maturity | ⬜ (README not rendered on GitLab listing we could see) | 🟩 (clear usage + frame-record API) |
| Idiomaticity | — | 🟩 (typed `StackFrame` records, explicit capture) |

#### redact
[repo](https://gitlab.com/ericcodes/gleam-redact)

"Prevent secrets from accidentally being logged." Hex package first released Sep 2025. Concept is useful — wrap sensitive values in a type whose `Inspect`/`String` representation is masked — but GitLab-hosted with a sparse repo page and no browsable README in this review pass. Worth knowing exists; evaluate properly if you need secret masking.

#### stacky
[repo](https://github.com/inoas/stacky)

"BEAM stack trace in Gleam." Captures the current BEAM stack trace as typed `StackFrame` records (module, function, arity, file, line). Pair it with any logger in this article to attach a stack trace to error-level events. 22 months dormant, so treat as stable-but-frozen rather than actively evolving.

### Related Work

- **[logging](#logging)** (lpil) — a dependency of several libraries above (`glogg`, `glight`); acts as the ecosystem's shared OTP-logger shim.
- **[gleam_otp](https://github.com/gleam-lang/otp)** — not a logger, but many of its supervisors/actors emit via OTP `logger`. Using `logging` or `palabres` means you pick up that output automatically.
- **[wisp](./web-and-http/web-apps.md#wisp)** — pairs naturally with `palabres_wisp` for HTTP request logging. Wisp's own helpers use OTP `logger` under the hood.

## Leaderboard

Thanks to everyone writing Gleam logging primitives — the ecosystem is young and every serious attempt teaches the rest of us something.

Every entry below is ranked by raw score (tie-break: maintenance recency, then README maturity). Caveats — like woof's default sink bypassing OTP `logger` — are flagged inline rather than used to drop a repo out of the ranking.

**🥇 Gold**
- **woof\*** ([lupodevelop](https://github.com/lupodevelop)) — Highest raw score in the review (8) and the winner here. Eight log levels, typed fields, instanced loggers, env-var level control. *\*Call `woof.prod()` once at startup for OTP `logger` sink + JSON; the bare quick-start (`woof.info(...)`) defaults to stdout — see [caveat](#woof-caveat).*
- **palabres** ([ghivert](https://github.com/ghivert)) — Best-in-class dual-target structured logger. Real OTP integration on BEAM, sensible JS fallback, Wisp middleware.
- **logging** ([lpil](https://github.com/lpil)) — The canonical OTP `logger` wrapper. Small, current, the default import in many other Gleam projects.
- **glight** ([distrill](https://github.com/distrill)) — Fluent BEAM logger layered on `logging`. Multi-transport, zero open issues.

**🥈 Silver**
- **glogg** ([webermarci](https://github.com/webermarci)) — Handler + hook pipeline design is genuinely useful for redaction/transform pipelines. Low stars, thorough README.
- **flash\*** ([larzconwell](https://github.com/larzconwell)) — Typed attributes, JSON writer, nested groups. *\*Same default-sink problem as woof but no opt-in escape hatch yet — see [caveat](#flash-caveat).*

**🥉 Bronze**
- **gbr_disk_log** ([gleam-br](https://github.com/gleam-br)) — Niche but necessary: the only typed wrapper for Erlang's `disk_log`. Young (~6 weeks at snapshot).
- **glimt** ([JohnBjrk](https://github.com/JohnBjrk)) — Most architecturally ambitious of the pure-Gleam loggers (dispatcher/serializer split). 2 years dormant, pinned to old stdlib.

**No award (dormant or unverifiable)**
- **glog** ([defgenx](https://github.com/defgenx)) — Logrus-inspired fluent fields. Dormant since April 2024.
- **gclog** ([sam-kenney](https://github.com/sam-kenney)) — GCP-compliant JSON entries. Specialist output, 17 months dormant.
- **viva_telemetry** ([gabrielmaialva33](https://github.com/gabrielmaialva33)) — Logs + metrics + benchmarks bundle. Commit history not browsable at snapshot — can't verify maintenance.

| Position | Award | Repo | ★ | Lic | Compat | Maint | Age | README | Idiom | Score |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 🥇 | [lupodevelop/woof](https://github.com/lupodevelop/woof) | 🟨 | 🟩 | 🟩 | 🟩🟩 | 🟩 | 🟩🟩 | 🟩 | **8**\* ([caveat](#woof-caveat)) |
| 2 | 🥇 | [ghivert/palabres](https://github.com/ghivert/palabres) | 🟥 | 🟩 | 🟩 | 🟩🟩 | 🟩 | 🟩🟩 | 🟩 | **7** |
| 2 | 🥇 | [lpil/logging](https://github.com/lpil/logging) | 🟨 | 🟩 | 🟨 | 🟩🟩 | 🟩 | 🟩 | 🟩 | **7** |
| 2 | 🥇 | [distrill/glight](https://github.com/distrill/glight) | 🟥 | 🟩 | 🟩 | 🟩🟩 | 🟩 | 🟩🟩 | 🟩 | **7** |
| 3 | 🥈 | [webermarci/glogg](https://github.com/webermarci/glogg) | 🟥 | 🟩 | 🟩 | 🟩🟩 | 🟨 | 🟩🟩 | 🟩 | **6** |
| 3 | 🥈 | [larzconwell/flash](https://github.com/larzconwell/flash) | 🟨 | 🟩 | 🟩 | 🟩 | 🟩 | 🟩 | 🟩 | **6**\* ([caveat](#flash-caveat)) |
| 4 | 🥉 | [gleam-br/gbr_disk_log](https://github.com/gleam-br/gbr_disk_log) | 🟥 | 🟩 | 🟩 | 🟩🟩 | 🟥 | 🟩🟩 | 🟩 | **5** |
| 4 | 🥉 | [JohnBjrk/glimt](https://github.com/JohnBjrk/glimt) | 🟨 | 🟩 | 🟥 | 🟥 | 🟩🟩 | 🟩🟩 | 🟩 | **5** |
| 5 | | [sam-kenney/gclog](https://github.com/sam-kenney/gclog) | 🟥 | 🟩 | 🟩 | 🟥 | 🟩 | 🟩🟩 | 🟩 | **4** |
| 5 | | [defgenx/glog](https://github.com/defgenx/glog) | 🟨 | 🟩 | 🟥 | 🟥 | 🟩🟩 | 🟩 | 🟩 | **4** |
| 5 | | [gabrielmaialva33/viva_telemetry](https://github.com/gabrielmaialva33/viva_telemetry) | 🟥 | 🟩 | 🟩 | ⬜ | ⬜ | 🟩🟩 | 🟩 | **4** |

**\*Note on woof and flash:**

- **woof (raw score 8, position 1)** — the winner. The dimensional rubric rewards activity/README/compat, all of which woof nails. The asterisk is for an *integration* signal the rubric doesn't capture: a "sink" is the piece of code that actually writes log bytes somewhere, and woof's bare quick-start (`woof.info("...")`) writes straight to stdout (`io:format`) instead of handing the line to OTP `logger`. **Woof v1.4 (Apr 2026) shipped the fix:** call `woof.prod()` once at startup and you get OTP `logger` sink + JSON in one line. The README documents it under "One-call setup" — anyone deploying to prod will see and use it. Pending [upstream issue #6](https://github.com/lupodevelop/woof/issues/6) making `woof.prod()` the default, woof keeps its #1 ranking with this asterisk.
- **flash (raw score 6, position 3)** — same default-sink-bypassing-OTP problem as woof, but without the opt-in escape. Until [upstream issue #4](https://github.com/larzconwell/flash/issues/4) lands, flash on BEAM is a pretty stdout printer rather than a logger.

**By target:** ☎️ BEAM **11** · 📜 JS **5** (palabres, glogg, flash, woof, gclog; redact is pure Gleam but its practical use is pre-logger sanitization on either target).

[How scores are calculated →](#scoring-dimensions)
