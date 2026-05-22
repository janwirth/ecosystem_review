# YAML in Gleam

> [!NOTE]
> **Status:** DRAFT · **Authoring:** AI-assisted, human-reviewed.

So you want to parse a YAML file — a Kubernetes manifest, a GitHub Actions workflow, an OpenAPI spec, an `.env`-style config — or *emit* YAML from your Gleam data, written in Gleam?

YAML in Gleam is **two parser strategies, one emitter, no canonical**. Parsers split between **pure-Gleam dual-target** ([`yamleam`](#yamleam), [`taffy`](#taffy)) and **FFI to `yamerl`** ([`glaml`](#glaml), [`yay`](#yay)). Only [`cymbal`](#cymbal) builds YAML — and only `cymbal` emits at all. There is no first-party `gleam_yaml`; the package that exists at that name is a stale v0.0.1 from 2024 (see [Disregarded](#disregarded)).

If you're picking a tool for a specific job, jump to **[When to use what](#when-to-use-what)**.

> [!TIP]
> **Quick recipes — copy-paste starting points for the four most common jobs.**
>
> **1. Parse a YAML config file into a typed record** (Kubernetes / GitHub Actions / app config) → [`yamleam`](#yamleam) — pure-Gleam, dual-target, `gleam_json`-shape decoder API.
>
> ```gleam
> import gleam/dynamic/decode
> import yamleam
>
> pub type Config {
>   Config(name: String, port: Int)
> }
>
> pub fn load(source: String) -> Result(Config, _) {
>   let decoder = {
>     use name <- decode.field("name", decode.string)
>     use port <- decode.field("port", decode.int)
>     decode.success(Config(name:, port:))
>   }
>   yamleam.parse(source, decoder)
> }
> ```
>
> **2. Parse a YAML file in JS-target code** (Lustre / Deno / Bun) → [`yamleam`](#yamleam) or [`taffy`](#taffy) (pure-Gleam dual-target) or [`yay`](#yay) (FFI to `js-yaml` on JS, `yamerl` on BEAM). **Don't** reach for [`glaml`](#glaml) — yamerl is BEAM-only.
>
> **3. Emit a YAML document from Gleam data** (generate Kubernetes manifests, CI configs, `oaspec.yaml`) → [`cymbal`](#cymbal) — only option, by Louis Pilfold.
>
> ```gleam
> import cymbal.{block, array, string, int}
>
> let pod =
>   block([
>     #("apiVersion", string("v1")),
>     #("kind", string("Pod")),
>     #("metadata", block([#("name", string("example"))])),
>     #("spec", block([
>       #("containers", array([
>         block([
>           #("name", string("nginx")),
>           #("image", string("nginx:1.27")),
>           #("ports", array([block([#("containerPort", int(80))])])),
>         ]),
>       ])),
>     ])),
>   ])
>
> cymbal.encode(pod)
> ```
>
> **4. Load a YAML config file with `${VAR}` interpolation** → [`yodel`](env-vars.md#yodel) — covered in [env-vars.md](env-vars.md#yodel). Different job: env vars are *values inside the file*, not the primary source.
>
> Other jobs — parsing OpenAPI YAML, untrusted-input hardening, BEAM-only fast NIF parsing, Gleam→YAML for arbitrary records — see [When to use what](#when-to-use-what).

## Table of Contents

1. [Summary](#summary)
2. [State of the ecosystem](#state-of-the-ecosystem)
3. [Background: YAML in 2026](#background-yaml-in-2026)
4. [Research Method](#research-method)
   - [Scoring Dimensions](#scoring-dimensions)
   - [Discovery](#discovery)
5. [Disregarded](#disregarded)
6. [When to use what](#when-to-use-what)
7. [Categories](#categories)
   - [Parsers — pure-Gleam, dual-target](#parsers--pure-gleam-dual-target) — [yamleam](#yamleam) · [taffy](#taffy)
   - [Parsers — FFI](#parsers--ffi) — [yay](#yay) · [glaml](#glaml)
   - [Emitter](#emitter) — [cymbal](#cymbal)
   - [Domain-shaped](#domain-shaped) — [mb_rep_gleam](#mb_rep_gleam)
   - [Config-loaders (cross-link)](#config-loaders-cross-link) — [yodel](env-vars.md#yodel)
   - [What's missing](#whats-missing--ffi-escape-hatches)
8. [Leaderboards](#leaderboards)

## Summary

Snapshot: **2026-05-22**.

| Category | ☎️ BEAM | 📜 JS |
| --- | --- | --- |
| **[Parsers — pure-Gleam, dual-target](#parsers--pure-gleam-dual-target)** | · [🥇](#leaderboards) [taffy](#taffy) ([repo](https://github.com/qwexvf/taffy), 6★) — *YAML 1.2, alias-bomb + nesting limits, optional Erlang-only `fast_yaml` NIF for 3–4× speedup* <br>· [🥈](#leaderboards) [yamleam](#yamleam) ([repo](https://github.com/enveriumhq/yamleam), 3★) — *covers "95%+ of YAML files people actually write", `gleam_json`-shape decoder API, explicit-error on unsupported features (tags, complex keys, multi-line flow)* | · [taffy](#taffy) — *same package, pure-Gleam parser runs on JS* <br>· [yamleam](#yamleam) — *same package, pure-Gleam runs on JS* |
| **[Parsers — FFI](#parsers--ffi)** | · [🥈](#leaderboards) [yay](#yay) ([repo](https://github.com/Brickell-Research/yay), 2★) — *FFI to `yamerl` (BEAM) + `js-yaml`-style FFI (JS), dual-target, typed extraction errors, builds on glaml* <br>· [glaml](#glaml) ([repo](https://github.com/katekyy/glaml), 7★) — *BEAM-only `yamerl` wrapper, dot-notation selectors, **stale since 2025-02*** | · [yay](#yay) — *same package, uses `./yaml_ffi.mjs` on JS* |
| **[Emitter](#emitter)** | · [🥇](#leaderboards) [cymbal](#cymbal) ([repo](https://github.com/lpil/cymbal), 20★) — *pure-Gleam YAML construction + encode. Only emitter. By [Louis Pilfold](https://github.com/lpil)* | · [cymbal](#cymbal) — *pure-Gleam, dual-target* |
| **[Domain-shaped](#domain-shaped)** | · [mb_rep_gleam](#mb_rep_gleam) ([repo](https://github.com/escherize/mb_rep_gleam), 0★) — *parse + emit Metabase Representation Format (v1) YAML files. Typed model of the full Metabase schema. Wraps [`glaml`](#glaml)* | — |
| **[Config-loaders (cross-link)](#config-loaders-cross-link)** | · [yodel](env-vars.md#yodel) ([repo](https://github.com/SnakeDoc/yodel), 11★) — *load JSON/YAML/TOML config with `${VAR}` interpolation. Wraps [`glaml`](#glaml) for YAML. Full review in [env-vars.md](env-vars.md#yodel)* | — |

> [!IMPORTANT]
> **Pick by job, not by global leaderboard.** Parsers compete on the *same* job (decode YAML → Gleam data). The emitter ([`cymbal`](#cymbal)) and the config-loader ([`yodel`](env-vars.md#yodel)) are different jobs — they don't substitute for each other. A leaderboard ranks competing implementations; a "when to use what" table picks the right *kind* of tool.

### At-a-glance matrix

One row per package. Columns: parse / write, targets, spec adherence, hardening, key shape, score.

| Package | Parse | Write | ☎️ BEAM | 📜 JS | YAML spec | Hardened against untrusted input | API shape | Score |
| --- | :---: | :---: | :---: | :---: | --- | :---: | --- | :---: |
| [taffy](#taffy) | ✅ | ❌ | ✅ pure Gleam · ✅ opt-in `fast_yaml` NIF (3–4×) | ✅ pure Gleam | **YAML 1.2** | ✅ alias-bomb cap (10M nodes) + nesting cap (1024), configurable | `parse` → typed `Value` + accessors + `to_json_string` | **6** |
| [yamleam](#yamleam) | ✅ | ❌ | ✅ pure Gleam | ✅ pure Gleam | **YAML 1.2 subset** (~"95% real-world"); explicit-errors on tags / complex keys / multi-line flow / 1.1 variants | ❌ — README disclaims hardening | `parse(source, decoder)` mirrors `gleam_json` · also `parse_raw` | **5** |
| [yay](#yay) | ✅ | ❌ | ✅ FFI → `yamerl` | ✅ FFI → `js-yaml` (npm) | Inherits `yamerl` (1.1-leaning); supports tags + anchors + merge keys | Inherits `yamerl` defences | `parse_string` + typed extractors (`extract_string` / `extract_int` / …) + dot-`#N` selectors | **5** |
| [glaml](#glaml) | ✅ | ❌ | ✅ FFI → `yamerl` | ❌ | Inherits `yamerl` (1.1-leaning) | Inherits `yamerl` defences | `parse_string` → `document_root` + `select_sugar` dot path | **3** |
| [cymbal](#cymbal) | ❌ | ✅ | ✅ pure Gleam | ✅ pure Gleam | Emits block-style; no anchors, no comments, no flow, no multi-doc | n/a (emission only) | Typed constructors (`block` / `array` / `string` / `int` / `float` / `bool`) → `encode` | **7** |
| [mb_rep_gleam](#mb_rep_gleam) | ✅ | ✅ | ✅ via `glaml` | ❌ | **Metabase Representation Format v1** (not arbitrary YAML) — byte-for-byte round-trip on all 98 upstream fixtures | Inherits `glaml` / `yamerl` | Per-entity typed modules (Card / Dashboard / Segment / …) | **4** |
| [yodel](env-vars.md#yodel) | ✅ (loader) | ❌ | ✅ via `glaml` | ❌ | YAML inherits `glaml`; auto-detects JSON / YAML / TOML by extension; `${VAR}` interpolation inside the file | Inherits `glaml` / `yamerl` | `load(path)` → `get_string` / `get_int` by dotted path | **9** (per [env-vars.md](env-vars.md#leaderboard)) |

> [!NOTE]
> **No round-trip in one package.** Parse-then-modify-then-emit requires walking a parser's tree (`yamleam` / `taffy` / `yay` / `glaml`) and rebuilding via `cymbal` constructors. Comments and anchor structure are lost on the emit side.

## State of the ecosystem

YAML in Gleam is **functional but small**. Five general-purpose packages (four parsers + one emitter), one domain-specific package, one cross-link to a config-loader.

What's there:

- **Pure-Gleam dual-target parsing** is covered twice — [`taffy`](#taffy) (YAML 1.2 with security limits, optional NIF backend) and [`yamleam`](#yamleam) (the practical YAML subset, with a `gleam_json`-shape decoder API). Both are brand new (Mar–Apr 2026) and both ship `target = "erlang"` in `gleam.toml` but compile + run on both targets thanks to no FFI in the core parser.
- **`yamerl`-wrapping parsing** is covered twice — [`glaml`](#glaml) (BEAM-only, the original) and [`yay`](#yay) (dual-target by adding a JS FFI layer over its own JS parser; also adds typed extraction errors). `yay` explicitly supersedes `glaml` per its README.
- **One emitter** — [`cymbal`](#cymbal). Builds YAML from typed Gleam constructors (`block` / `array` / `string` / `int` / `bool` / `float`), then `encode/1` to a string. Pure-Gleam dual-target.
- **One domain-shaped parser/emitter** — [`mb_rep_gleam`](#mb_rep_gleam) covers Metabase Representation Format v1 with a fully-typed model of every entity in the spec.

What's missing entirely:

- **No package merges parser + emitter in one API.** If you need *round-trip* parse-then-modify-then-emit, you parse with one of `yamleam`/`taffy`/`yay`/`glaml`, walk the result, and rebuild with `cymbal`. The two halves don't share a type.
- **No comment preservation** in any package. Parse drops comments; emit produces no comments. Round-tripping configuration that humans annotate is lossy.
- **No streaming / event-based parser** (à la libyaml's SAX-style callbacks). All parsers materialise the full document.
- **No YAML schema validation** (e.g., JSON Schema applied to YAML — easy enough manually via [`json_blueprint`](serialization/runtime-bidirectional-json.md#json_blueprint), but no Gleam package wires the two together).
- **No anchor / alias *emission*** in `cymbal` — you can read them via the parsers, but `cymbal` only emits flat trees.
- **No YAML 1.1 compatibility mode** (legacy octals, `yes`/`no` booleans). Most modern files are 1.2; if you hit a 1.1 file, FFI to Erlang's `yamerl` directly.

Star counts are tiny — the busiest YAML repo is `cymbal` at 20★. Use these as **thin, replaceable layers**: if you outgrow them, FFI to Erlang's [`yamerl`](https://github.com/yakaz/yamerl) (the canonical BEAM YAML library, ~150★ and 10 years old) or Erlang's [`fast_yaml`](https://github.com/processone/fast_yaml) (NIF over libyaml, used by ejabberd in production).

## Background: YAML in 2026

YAML is a moving target. Six things make parsing it hard, and three of those split the Gleam packages into competing camps.

**Spec versions.** YAML **1.1** (2005) and YAML **1.2** (2009, revised 2021) are not the same language. 1.1 treats `yes`/`no`/`on`/`off` as booleans and supports sexagesimal numbers (`12:34:56` → number); 1.2 does not. Files that look fine on one parser misparse on another. Most modern files (Kubernetes, GitHub Actions, OpenAPI) target 1.2. [`taffy`](#taffy) claims YAML 1.2; [`yamleam`](#yamleam) explicitly rejects YAML 1.1 variants; [`glaml`](#glaml) / [`yay`](#yay) inherit whatever `yamerl` does (1.1-leaning historically).

**Anchors, aliases, merge keys.** `&anchor` / `*alias` / `<<:` let YAML reuse subtrees. They are common in CI/CD configs. [`yamleam`](#yamleam) supports them; [`taffy`](#taffy) supports them and defends against *alias bombs* (a denial-of-service trick where deeply-nested aliases expand to exponentially-large output — `taffy` caps at 10M nodes).

**Tags.** `!!int "42"`, `!CustomType {…}` — explicit type tags. None of the pure-Gleam parsers support them; [`yamleam`](#yamleam) errors explicitly on encountering one, [`taffy`](#taffy)'s README is unclear. [`glaml`](#glaml) / [`yay`](#yay) handle them via `yamerl`.

**Multi-document streams.** A single YAML file can contain multiple documents separated by `---`. Kubernetes uses this heavily (one Deployment + one Service + one Ingress in one file). [`yamleam`](#yamleam) supports it explicitly (`parse_documents_raw`); [`taffy`](#taffy) has `parse_all`; [`glaml`](#glaml) returns a list of documents.

**Flow vs block style.** YAML lets you write `{a: 1, b: 2}` (flow) or the indented block form. [`yamleam`](#yamleam) supports both flow and block but errors on *multi-line* flow collections; [`taffy`](#taffy) supports both fully.

**Untrusted input.** Most parsers in most languages have at some point shipped a CVE around YAML — alias bombs, billion-laughs–style nested-flow attacks, integer overflow on huge sequences. Only [`taffy`](#taffy) explicitly hardens (alias-bomb cap + nesting depth cap, both configurable). [`yamleam`](#yamleam)'s README says "**not** hardened for parsing arbitrary documents of unverified provenance." [`yay`](#yay) / [`glaml`](#glaml) inherit `yamerl`'s defences (which are reasonable but not exhaustive).

> [!CAUTION]
> **For parsing YAML from untrusted sources** (user uploads, third-party API responses, scraped content), use [`taffy`](#taffy) and tighten the limits, or FFI to `fast_yaml` with libyaml's hardening. Do **not** use `yamleam` — its README explicitly disclaims hardening.

## Research Method

### Scoring Dimensions

Same rubric as [databases.md#scoring-dimensions](databases.md#scoring-dimensions). Recap:

- **Stars:** 🟩🟩 ≥200★, 🟩 ≥100★, 🟨 ≥10★, 🟥 <10★. *YAML packages skew tiny — most land in 🟥.*
- **License:** 🟩 permissive (MIT/Apache/BSD), 🟥 viral (GPL/LGPL/AGPL) or missing.
- **Gleam compat:** `gleam_stdlib` constraint format. 🟩 range, 🟥 `~>` pin or missing.
- **Maintenance:** max(recency, responsiveness). 🟩🟩 <1 mo / clean tracker, 🟩 <6 mo, 🟨 <1 yr, 🟥 older.
- **Age:** 🟩🟩 ≥3 yrs, 🟩 ≥1 yr, 🟨 ≥3 mo, 🟥 <3 mo.
- **README maturity:** 🟩🟩 full guide + examples, 🟩 clear tagline + usage, 🟥 minimal/template.
- **Idiomaticity:** 🟩 typed/explicit, 🟥 magic or unsafe.

**Leaderboard:** 🟥 = −1, 🟨 = 0, 🟩 = 1, 🟩🟩 = 2. Sum of 7 dims, max 13.

### Discovery

Search terms run against the [Gleam packages registry](https://packages.gleam.run/), [hex.pm](https://hex.pm/), and GitHub `language:gleam`:

- [yaml](https://packages.gleam.run/?search=yaml) · [yml](https://packages.gleam.run/?search=yml)
- [config](https://packages.gleam.run/?search=config) (filtered for YAML loaders → [`yodel`](env-vars.md#yodel))
- [kubernetes](https://packages.gleam.run/?search=kubernetes) · [k8s](https://packages.gleam.run/?search=k8s) — *no Gleam-native results*
- [openapi](https://packages.gleam.run/?search=openapi) (parsers covered in [openapi.md](openapi.md))
- [parser](https://packages.gleam.run/?search=parser) (filtered for YAML — broader catalogue in [parse-and-generate-other-languages.md](parse-and-generate-other-languages.md))
- GitHub `language:gleam yaml` repository search surfaced [`mb_rep_gleam`](#mb_rep_gleam) and [`rohaquinlop/yaml_parser`](#disregarded).

## Disregarded

These turned up in searches but are **not recommended** for general use. Listed up-front so reviewers see "this corner has been considered, here's what was skipped and why" before drilling into per-category content.

| Package | Reason disregarded |
| --- | --- |
| [`gleam_yaml`](https://hex.pm/packages/gleam_yaml) | **Stale prototype.** v0.0.1 from 2024-03-18, 196 all-time downloads, by `xxninjabunnyxx`. Repo not linked from Hex. *Despite the name, this is not a first-party Gleam package.* Builds clean on a fresh project but feature coverage is below `yamleam`/`taffy` and there's no maintenance signal. **The cli.md cross-reference to `gleam_yaml` is stale guidance** — prefer [`yamleam`](#yamleam) or [`taffy`](#taffy) for new code. |
| [`rohaquinlop/yaml_parser`](https://github.com/rohaquinlop/yaml_parser) | **Placeholder.** 0★, single commit (2024-06-02), README contains the literal text "TODO: An example of the project in use", no license declared, never published to Hex. |
| [`yamerl`](https://hex.pm/packages/yamerl) | **Erlang library**, not Gleam. The canonical BEAM YAML parser, used transitively by [`glaml`](#glaml) and [`yay`](#yay) (BEAM target). Listed because Gleam users searching "yaml" on Hex will see it — reachable via `@external` if you want raw access to its API. |
| [`fast_yaml`](https://hex.pm/packages/fast_yaml) | **Erlang NIF** over libyaml, by ProcessOne (ejabberd). Used internally by [`taffy/native`](#taffy). Listed because it surfaces on Hex; not directly usable from Gleam without `@external` declarations. |

## When to use what

Pick by **the job you're doing**, not by the global leaderboard score. The categories aren't substitutable — an emitter can't parse, a config-loader can't be repurposed as a general parser without losing its interpolation feature.

| You want to… | Use | Notes |
| --- | --- | --- |
| **Parse a YAML config file into a typed record** (decoder pattern, BEAM or JS) | [`yamleam`](#yamleam) | Decoder API mirrors `gleam_json`. Errors loudly on unsupported features rather than misparsing. |
| **Parse YAML 1.2 strictly, with security hardening** (untrusted input) | [`taffy`](#taffy) | Alias-bomb + nesting-depth limits, configurable. Pure-Gleam dual-target; optional Erlang-only NIF for speed. |
| **Parse YAML with tags / YAML 1.1 / unusual features** | [`yay`](#yay) (dual) or [`glaml`](#glaml) (BEAM-only) | Inherits `yamerl`'s broader feature coverage. |
| **Parse a large YAML file fast on BEAM** | [`taffy/native`](#taffy) (when `fast_yaml` is installed) | 3–4× speedup over pure-Gleam parser per `taffy`'s benchmarks. Erlang-only. |
| **Emit a YAML document from Gleam data** (Kubernetes manifests, CI configs, `oaspec.yaml`) | [`cymbal`](#cymbal) | Only option. By Louis Pilfold. |
| **Round-trip: parse → modify → emit** | [`yamleam`](#yamleam) + [`cymbal`](#cymbal); walk the parser's tree and rebuild via cymbal constructors | No package does this in one API. Comments + anchors are lost on the emit side. |
| **Load a YAML config with `${VAR}` interpolation + JSON/TOML auto-detect** | [`yodel`](env-vars.md#yodel) | Different job from "parse YAML"; covered in [env-vars.md](env-vars.md#yodel). |
| **Read Metabase content-export YAML** (dashboards, cards, collections) | [`mb_rep_gleam`](#mb_rep_gleam) | Domain-specific. Typed model of the entire schema. |
| **Read an OpenAPI YAML spec** | [`oas`](openapi.md#oas) | Covered in [openapi.md](openapi.md). |
| **Stream-parse a huge YAML file** (events, not materialised tree) | FFI to `yamerl` directly | No Gleam package exposes a SAX-style API. |
| **Preserve comments through a round-trip** | Don't use Gleam for this | Nothing on BEAM does it well either; in Python you'd use `ruamel.yaml`. |
| **Validate a YAML file against JSON Schema** | Parse with `yamleam` → convert to a `gleam_json` `Json` value → run [`json_blueprint`](serialization/runtime-bidirectional-json.md#json_blueprint) or [`castor`](serialization/runtime-bidirectional-json.md#castor) | No single-step package. |

> [!IMPORTANT]
> **Two rules to take with you:**
> 1. **For untrusted input, use [`taffy`](#taffy) and tighten the limits.** Other parsers either disclaim hardening (`yamleam`) or inherit whatever `yamerl` does without exposing knobs.
> 2. **For JS-target apps, never `glaml`.** It FFIs to `yamerl` which is BEAM-only. [`yamleam`](#yamleam), [`taffy`](#taffy), [`yay`](#yay), [`cymbal`](#cymbal) are the dual-target choices.

## Categories

### Parsers — pure-Gleam, dual-target

Two parsers, both brand-new (2026), both no-FFI for the main API, both runnable on Erlang and JavaScript. They differ on **spec scope** vs **feature scope**: `taffy` aims at the YAML 1.2 spec with security limits; `yamleam` aims at "95% of real-world files" and errors explicitly on features it doesn't cover.

| Criterion | [taffy](#taffy) | [yamleam](#yamleam) |
| --- | --- | --- |
| Stars | 6★ · 🟥 | 3★ · 🟥 |
| License | Apache-2.0 · 🟩 | Apache-2.0 · 🟩 |
| Target | ☎️ BEAM + 📜 JS (pure Gleam); ☎️ BEAM-only opt-in `taffy/native` via `fast_yaml` | ☎️ BEAM + 📜 JS (pure Gleam) |
| Gleam compat | `gleam_stdlib >= 0.44 and < 2.0` · 🟩 | `gleam_stdlib >= 0.46 and < 2.0` · 🟩 |
| Open issues | 1 | 0 · *clean tracker* |
| Maintenance | 🟩🟩 (last push 2026-05-22 — *snapshot day*) | 🟩 (last push 2026-04-13 — ~5 wk before snapshot) |
| Age | 🟨 (created 2026-03-29, ~1.7 months) | 🟨 (created 2026-04-13, ~5 weeks) |
| README | 🟩🟩 (security defaults, benchmarks, usage examples, native backend docs) | 🟩🟩 (supported/unsupported features table, decoder + raw API examples, security caveat, roadmap) |
| Idiomaticity | 🟩 (typed `Value`, explicit options) | 🟩 (decoder API mirrors `gleam_json`) |
| **Score** | **6** | **5** |

#### taffy
[repo](https://github.com/qwexvf/taffy) · [hex](https://hex.pm/packages/taffy) · [hexdocs](https://hexdocs.pm/taffy/) · [🥇](#leaderboards)

A **YAML 1.2** parser written in pure Gleam, with an opt-in Erlang-only `fast_yaml` C NIF backend for speed. Three modules: `taffy` (main API: `parse`, `parse_all`, `parse_with_options`, `to_json_string`, accessors), `taffy/value` (the `Value` type), `taffy/native` (NIF wrapper, requires `gleam add fast_yaml`).

**Security defaults.** Rejects *alias bombs* exceeding 10M nodes and limits block nesting depth to 1024 levels. Both configurable via `parse_with_options`.

**Performance.** Per `taffy`'s benchmarks: pure-Gleam parser at 15k ops/s on small docs, 1.4k on medium, 400 on large. Native backend: 55k / 5.7k / 560 ops/s respectively (~3–4× speedup). Native is Erlang-only.

```gleam
import taffy

pub fn main() {
  let assert Ok(value) = taffy.parse("name: John\nage: 30")
  let assert Ok(name) = taffy.get(value, "name")
  let json = taffy.to_json_string(value)
}
```

For the native backend (Erlang only):

```gleam
import taffy/native

let assert Ok(value) = native.parse(input)
```

Both pure-Gleam and native paths expose the same `Value` type, so swapping is a one-import change.

#### yamleam
[repo](https://github.com/enveriumhq/yamleam) · [hex](https://hex.pm/packages/yamleam) · [hexdocs](https://hexdocs.pm/yamleam/) · [🥈](#leaderboards)

A pure-Gleam YAML parser targeting "**95%+ of YAML files people actually write**" — Kubernetes manifests, GitHub Actions workflows, app configs. Deliberate partial coverage of the YAML 1.2 spec, with **explicit errors** on the features it doesn't support rather than silent misparse.

The headline design choice is the **decoder API**, which mirrors `gleam_json`:

```gleam
import gleam/dynamic/decode
import yamleam

pub type Server {
  Server(name: String, port: Int, tls: Bool)
}

pub fn parse_config(source: String) -> Result(Server, _) {
  let decoder = {
    use name <- decode.field("name", decode.string)
    use port <- decode.field("port", decode.int)
    use tls <- decode.field("tls", decode.bool)
    decode.success(Server(name:, port:, tls:))
  }
  yamleam.parse(source, decoder)
}
```

Raw-tree access (`parse_raw`, `parse_documents_raw`) is also available if you need the untyped `YamlNode` tree.

**Supported (v1.0.0):** block + flow mappings, plain / single / double-quoted strings, literal + folded block scalars, multi-document streams, anchors / aliases / merge keys, null / bool / int / float, duplicate key rejection.

**Explicitly *not* supported (returns errors):** multi-line flow collections, explicit indent indicators, tags (`!!int`, `!Custom`), complex keys (maps-as-keys), YAML 1.1 variants (`yes`/`no` booleans, octal literals).

> [!CAUTION]
> **`yamleam` is not hardened for untrusted input.** No document-size or nesting-depth limits. Use [`taffy`](#taffy) for parsing data from the internet. `yamleam` is the right choice for trusted files (your own config, your own CI workflows, your own Kubernetes manifests) where the simpler decoder API earns its keep.

> [!NOTE]
> **Both `taffy` and `yamleam` ship `target = "erlang"` in `gleam.toml`.** This field is the default target for `gleam run`, not a restriction. Verified: both packages compile **and** run on `--target javascript` because the core parser is pure Gleam (no `@external` clauses in the parsing path). The field is misleading — file an issue upstream if you care.

### Parsers — FFI

Two parsers wrapping `yamerl` (the canonical BEAM YAML library, ~150★, 10 years old). `yay` adds a JS FFI path so it works on both runtimes and adds typed extraction errors; `glaml` is BEAM-only and stale. `yay` explicitly supersedes `glaml` per its README.

| Criterion | [yay](#yay) | [glaml](#glaml) |
| --- | --- | --- |
| Stars | 2★ · 🟥 | 7★ · 🟥 |
| License | MIT · 🟩 | MIT · 🟩 |
| Target | ☎️ BEAM (`yamerl`) + 📜 JS (`yaml_ffi.mjs`) | ☎️ BEAM only (`yamerl`) |
| Gleam compat | `gleam_stdlib >= 0.54 and < 2.0` · 🟩 | `gleam_stdlib >= 0.54 and < 2.0` · 🟩 |
| Open issues | 1 | 2 |
| Maintenance | 🟩 (last push 2025-12-01 — ~5.7 mo before snapshot, borderline) | 🟥 (last push 2025-02-11 — ~15 mo before snapshot) |
| Age | 🟨 (created 2025-11-25, ~6 months) | 🟩 (created 2024-06-05, ~2 years) |
| README | 🟩🟩 (installation per target, extraction helpers, error variants, attribution to glaml) | 🟩 (minimal: parse + select-sugar example) |
| Idiomaticity | 🟩 (pattern-matchable error types, typed extractors) | 🟩 (dot-notation selectors, `Result`-style) |
| **Score** | **5** | **3** |

> [!NOTE]
> **`yay` builds on `glaml`.** Per `yay`'s README: "*This project builds upon the earlier glaml library, extending it with improved error handling and cross-platform functionality.*" Treat `yay` as the active successor — same Erlang-side FFI (`yamerl`), plus a JS FFI path, plus typed extraction errors (`KeyMissing`, `KeyTypeMismatch`, `KeyValueEmpty`, `DuplicateKeysDetected`).

#### yay
[repo](https://github.com/Brickell-Research/yay) · [hex](https://hex.pm/packages/yay) · [🥈](#leaderboards)

Dual-target YAML parser with typed value extraction. On BEAM, FFIs to `yamerl`; on JS, FFIs to `js-yaml` (via `./yaml_ffi.mjs`). API mirrors `glaml` but adds:

- **Pattern-matchable error variants** with type information (which key, expected type, actual type).
- **Typed extractors**: `extract_string`, `extract_int`, `extract_float`, `extract_bool`, plus list and map variants.
- **Dot-notation + array-index selectors**: `"servers.#0.host"`.
- **Optional duplicate-key detection** (off by default — `yamerl` is permissive).

```gleam
import yay

pub fn main() {
  let assert Ok(doc) = yay.parse_string("
name: my-service
port: 8080
")
  let assert Ok(name) = yay.extract_string(doc, "name")
  let assert Ok(port) = yay.extract_int(doc, "port")
}
```

JS install requires `js-yaml`: `gleam add yay && npm install js-yaml`.

#### glaml
[repo](https://github.com/katekyy/glaml) · [hex](https://hex.pm/packages/glaml) · [hexdocs](https://hexdocs.pm/glaml/)

Simple Gleam wrapper around `yamerl`. **BEAM-only.** Parse a YAML string, query the result with `select_sugar` (dot-and-`#N` path notation).

```gleam
import glaml

pub fn main() {
  let assert Ok([doc]) = glaml.parse_string("
stars: 7
this-is-nil:
jobs:
  - being a cat
")
  let job = glaml.select_sugar(glaml.document_root(doc), "jobs.#0")
  // job == Ok(NodeStr("being a cat"))
}
```

**Status: stale.** Last commit 2025-02-11 (15 months before snapshot), 2 open issues. If you're on BEAM and OK with `yamerl`'s feature set, `glaml` still works — but for new code, prefer [`yay`](#yay) (active, dual-target, typed extractors) or [`yamleam`](#yamleam) (decoder API).

### Emitter

One emitter, no competition. If you need to emit YAML from Gleam, this is the package.

| Criterion | [cymbal](#cymbal) |
| --- | --- |
| Stars | 20★ · 🟨 |
| License | Apache-2.0 (declared in `gleam.toml`; no LICENSE file in repo) · 🟩 |
| Target | ☎️ BEAM + 📜 JS (pure Gleam, no `@external` clauses) |
| Gleam compat | `gleam_stdlib ~> 0.34 or ~> 1.0` · 🟩 |
| Open issues | 1 |
| Maintenance | 🟩 (last push 2026-03-09 — ~2.5 mo before snapshot) |
| Age | 🟩 (created 2024-02-13, ~2.3 years) |
| README | 🟩🟩 (Kubernetes Pod example, full constructor list, install + dev commands) |
| Idiomaticity | 🟩 (opaque `Yaml` type, typed constructors) |
| **Score** | **7** |

#### cymbal
[repo](https://github.com/lpil/cymbal) · [hex](https://hex.pm/packages/cymbal) · [hexdocs](https://hexdocs.pm/cymbal/) · [🥇](#leaderboards)

Build YAML in Gleam. Six typed constructors (`block`, `array`, `string`, `int`, `float`, `bool`) build an opaque `Yaml` value; `encode/1` turns it into a YAML string. By **Louis Pilfold** (Gleam's creator), which is unusual signal in a tiny-stars repo — it's a single-author personal project but the author maintains the language itself.

```gleam
import cymbal.{block, array, string, int}

let pod =
  block([
    #("apiVersion", string("v1")),
    #("kind", string("Pod")),
    #("metadata", block([#("name", string("nginx"))])),
    #("spec", block([
      #("containers", array([
        block([
          #("name", string("nginx")),
          #("image", string("nginx:1.27")),
          #("ports", array([block([#("containerPort", int(80))])])),
        ]),
      ])),
    ])),
  ])

cymbal.encode(pod)
// ---
// apiVersion: v1
// kind: Pod
// metadata:
//   name: nginx
// spec:
//   containers:
//     - name: nginx
//       image: nginx:1.27
//       ports:
//         - containerPort: 80
```

**Notable gaps:** no anchors / aliases (output is always a flat tree, no `&` / `*`), no comments (you can't annotate the emitted document), no flow style (always block), no multi-document streams (one document per `encode` call — wrap manually with `---` between).

### Domain-shaped

A *domain-shaped* YAML package targets one specific schema with a fully-typed model, not arbitrary YAML. It doesn't compete with the general-purpose parsers — its value is *the schema fidelity*, not the parsing.

| Criterion | [mb_rep_gleam](#mb_rep_gleam) |
| --- | --- |
| Stars | 0★ · 🟥 |
| License | Apache-2.0 · 🟩 |
| Target | ☎️ BEAM (depends on [`glaml`](#glaml)) |
| Gleam compat | `gleam_stdlib ~> 1.0` · 🟩 |
| Open issues | 0 |
| Maintenance | 🟩🟩 (last push 2026-05-12 — 10 days before snapshot) |
| Age | 🟥 (created 2026-05-12, **10 days old**) |
| README | 🟩 (clear scope, links to upstream Metabase spec) |
| Idiomaticity | 🟩 (typed entity models, byte-for-byte round-trip) |
| **Score** | **4** |

#### mb_rep_gleam
[repo](https://github.com/escherize/mb_rep_gleam) · [hex](https://hex.pm/packages/mb_rep_gleam)

Parse + emit **Metabase Representation Format (v1)** YAML files. The upstream spec is at [metabase/representations](https://github.com/metabase/representations); this package models every entity (Cards, Dashboards, Segments, Measures, Documents, Snippets, Collections) with its own typed Gleam module.

Per the README: parses all 98 example fixtures from upstream, **byte-for-byte fidelity** on encode → parse round-trips. MBQL queries, refs, parameters, dashcards, and document trees are all typed values, not opaque blobs.

```gleam
import mb_rep_gleam
// Use the typed modules for whichever entity you're modelling:
// mb_rep_gleam/card, mb_rep_gleam/dashboard, ...
```

Only useful if you're working with Metabase's portable representation format. Listed here so searchers for "Gleam YAML parser" find it and don't try to use it as a general parser.

### Config-loaders (cross-link)

A different job from parsing YAML: load a config **file** (JSON / YAML / TOML, auto-detected by extension) and let env vars be interpolated inside it.

#### yodel
[repo](https://github.com/SnakeDoc/yodel) · [hex](https://hex.pm/packages/yodel)

JSON/YAML/TOML config loader with `${VAR}` / `${VAR:default}` / nested `${VAR1:${VAR2:fallback}}` interpolation. Uses [`glaml`](#glaml) under the hood for YAML, so **BEAM-only**.

```yaml
# config.yaml
database:
  host: ${DATABASE_HOST:localhost}
  port: ${DATABASE_PORT:5432}
```

```gleam
import yodel

pub fn main() {
  let assert Ok(config) = yodel.load("config.yaml")
  let assert Ok(host) = yodel.get_string(config, "database.host")
}
```

**Full review in [env-vars.md#yodel](env-vars.md#yodel)** — covered there because the *job* is reading typed config with env-var fallbacks, not parsing YAML for its own sake.

### What's missing — FFI escape hatches

For gaps in Gleam-native YAML, the canonical Erlang/Elixir Hex package to FFI to:

| Capability | Gleam? | FFI to (Erlang/Elixir) |
| --- | --- | --- |
| **Streaming / SAX-style parser** (event callbacks, not materialised tree) | None | [`yamerl`](https://hex.pm/packages/yamerl) supports event mode — call `:yamerl_constr.string/2` with custom options |
| **Comment-preserving round-trip** (parse → modify → emit retaining comments) | None | Nothing on BEAM does this well either. Closest is Python `ruamel.yaml` via shell-out |
| **YAML 1.1 compatibility mode** (`yes`/`no` booleans, sexagesimal) | None directly — `yamerl` is 1.1-leaning so [`yay`](#yay)/[`glaml`](#glaml) handle most 1.1 input | [`yamerl`](https://hex.pm/packages/yamerl) directly with 1.1 schema option |
| **libyaml-grade performance for huge files** | Partial — [`taffy/native`](#taffy) wraps `fast_yaml` (libyaml NIF) on BEAM only | [`fast_yaml`](https://hex.pm/packages/fast_yaml) (ProcessOne, used by ejabberd) |
| **YAML schema validation** (JSON Schema applied to YAML) | None directly — manual chain: parse with [`yamleam`](#yamleam) → convert to JSON → validate with [`json_blueprint`](serialization/runtime-bidirectional-json.md#json_blueprint) or [`castor`](serialization/runtime-bidirectional-json.md#castor) | None on BEAM ships this in one step either |
| **Anchor / alias *emission*** (DRY output via `&` / `*`) | None — [`cymbal`](#cymbal) emits flat trees only | [`yamerl`](https://hex.pm/packages/yamerl)'s emitter (`yamerl_node_*` API) |
| **YAML diff / merge** (semantic, anchor-aware) | None | No good BEAM library; consider [`pyyaml`](https://pyyaml.org/) or [`yq`](https://github.com/mikefarah/yq) via shell-out |
| **Kubernetes-aware YAML manipulation** (kustomize-style overlays, JSON Patch on YAML) | None | Shell out to [`yq`](https://github.com/mikefarah/yq) or [`kustomize`](https://kustomize.io/) |
| **CRD / OpenAPI-schema-driven YAML validation** | None | Generate Gleam decoders from the schema via [`oaspec`](openapi.md#oaspec); decode the parsed YAML |

## Leaderboards

Two leaderboards — **parsers** (compete on the same job) and **emitter** (only one entry). Domain-shaped ([`mb_rep_gleam`](#mb_rep_gleam)) and config-loader ([`yodel`](env-vars.md#yodel)) are scored but listed separately since they don't substitute for parsing.

### Parsers

| Rank | Package | Score | Highlights |
| --- | --- | --- | --- |
| 🥇 | [taffy](#taffy) | **6** | YAML 1.2 · pure-Gleam dual-target · alias-bomb + nesting limits · optional Erlang NIF (3–4× speedup) · 🟩🟩 maintenance (last push snapshot day) · 🟩🟩 README (benchmarks, security docs) |
| 🥈 | [yamleam](#yamleam) | **5** | Decoder API mirrors `gleam_json` · explicit errors on unsupported features · clean issue tracker · 🟩🟩 README (supported/unsupported tables) |
| 🥈 | [yay](#yay) | **5** | FFI dual-target (`yamerl` + `js-yaml`) · typed extraction errors · supersedes [`glaml`](#glaml) · 🟩🟩 README |
| 4️⃣ | [glaml](#glaml) | **3** | Active in 2024, **stale since 2025-02** · BEAM-only · yay is the dual-target successor |

### Emitter

| Rank | Package | Score | Highlights |
| --- | --- | --- | --- |
| 🥇 | [cymbal](#cymbal) | **7** | Only YAML emitter · pure-Gleam dual-target · by Louis Pilfold (Gleam creator) · 🟩🟩 README · 20★ (highest in this article) |

### Other (not compared against general parsers)

| Package | Score | Why separate |
| --- | --- | --- |
| [mb_rep_gleam](#mb_rep_gleam) | **4** | Domain-shaped — only useful for Metabase Representation Format files |
| [yodel](env-vars.md#yodel) | **9** (per [env-vars.md leaderboard](env-vars.md#leaderboard)) | Config loader, not a parser — its value is `${VAR}` interpolation + format auto-detect, not YAML coverage |

---

*Snapshot 2026-05-22. Methodology: [../workflows/REVIEW_METHODOLOGY.md](../workflows/REVIEW_METHODOLOGY.md). Scoring rubric source: [databases.md#scoring-dimensions](databases.md#scoring-dimensions). Back to index: [README.md](README.md).*
