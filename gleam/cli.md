# CLI in Gleam

> [!NOTE]
> **Status:** DRAFT · **Authoring:** AI-assisted, human-reviewed.

So you want to build a command-line tool in Gleam — parse `--flags` and positional arguments, print colourised help, prompt the user, render a spinner during a long task, or paint a full-screen TUI?

The Gleam CLI surface splits into **two distinct concerns**: parsing `argv` into typed values (**[argument parsers](#argument-parsers)**) and rendering interactive output (**[interactive UI / CLI renderers](#interactive-ui--cli-renderers)** — colours, prompts, spinners, tables, full-screen TUIs). Argument parsing has a clear leader ([glint](#glint)) and several alternatives that each pick a different ergonomic axis (decoder-style, applicative, low-level POSIX). The rendering side is **thinner and more fragmented** — first-party ANSI colour is solid, but spinners, prompts, full-screen TUI frameworks, and tables each tend to be one or two small packages that don't compose into a single batteries-included story (no Bubble Tea / Ratatui equivalent at framework-completeness). Many gaps are reachable via FFI to Erlang/Elixir packages (Owl, Ratatouille, IO.ANSI).

If you're picking a tool for a specific job, jump to **[When to use what](#when-to-use-what)**.

> [!TIP]
> **Quick recipes — copy-paste starting points for the five most common jobs.**
>
> **1. Get `argv` cross-platform** (Erlang + Node + Deno + Bun) → use [`argv`](#argv).
>
> ```gleam
> import argv
>
> pub fn main() {
>   case argv.load().arguments {
>     ["hello", name] -> echo "Hello, " <> name
>     _ -> echo "usage: prog hello <name>"
>   }
> }
> ```
>
> **2. Parse `--flag value` with type-safety + auto-help** → [`glint`](#glint).
>
> ```gleam
> import argv
> import glint
>
> pub fn main() {
>   glint.new()
>   |> glint.with_name("prog")
>   |> glint.add(at: ["hello"], do: hello())
>   |> glint.run(argv.load().arguments)
> }
>
> fn hello() {
>   use <- glint.command_help("Greets someone")
>   use caps <- glint.flag(glint.bool_flag("caps"))
>   use _, args, flags <- glint.command()
>   let assert Ok(loud) = caps(flags)
>   case loud {
>     True -> echo "HELLO, " <> string.uppercase(string.join(args, " "))
>     False -> echo "Hello, " <> string.join(args, " ")
>   }
> }
> ```
>
> **3. Colourise terminal output** → [`gleam_community/ansi`](#gleam_communityansi).
>
> ```gleam
> import gleam_community/ansi
>
> pub fn main() {
>   echo ansi.green("ok ") <> "all checks passed"
>   echo ansi.red("err") <> " 1 test failing"
> }
> ```
>
> **4. Show a spinner during a long task** → [`spinner`](#spinner).
>
> ```gleam
> import spinner
>
> pub fn main() {
>   let spin =
>     spinner.new("Compiling…")
>     |> spinner.with_colour(ansi.cyan)
>     |> spinner.start
>
>   do_long_thing()
>
>   spinner.stop(spin)
> }
> ```
>
> **5. Prompt the user for input** → [`input`](#input) (single line) or [`survey`](#survey) (multi-question + confirmation).
>
> ```gleam
> import input
>
> pub fn main() {
>   let assert Ok(name) = input.input("Your name: ")
>   echo "Hi, " <> name
> }
> ```
>
> Other jobs — full-screen TUI, multi-select prompt, progress bars, formatted tables, missing FFI escape hatches — see [When to use what](#when-to-use-what).

## Table of Contents

1. [Summary](#summary)
2. [State of the ecosystem](#state-of-the-ecosystem)
3. [Research Method](#research-method)
   - [Scoring Dimensions](#scoring-dimensions)
   - [Discovery](#discovery)
4. [Disregarded](#disregarded)
5. [When to use what](#when-to-use-what)
6. [Categories](#categories)
   - [Argument parsers](#argument-parsers) — [argv](#argv) · [glint](#glint) · [clip](#clip) · [clad](#clad) · [hoist](#hoist) · [glap](#glap) · [outil](#outil) · [sheen](#sheen) · [cosmo_cli](#cosmo_cli)
   - [Interactive UI / CLI renderers](#interactive-ui--cli-renderers)
     - [Colour & ANSI](#colour--ansi) — [gleam_community/ansi](#gleam_communityansi) · [gleam_community/colour](#gleam_communitycolour) · [the_stars](#the_stars) · [gleamy_lights](#gleamy_lights) · [galant](#galant) · [chromatic](#chromatic) · [colored](#colored) · [colours](#colours) · [tulip](#tulip) · [hug](#hug)
     - [Spinners & progress](#spinners--progress) — [spinner](#spinner) · [glitzer](#glitzer)
     - [Prompts & input](#prompts--input) — [input](#input) · [in](#in) · [stdin](#stdin) · [survey](#survey) · [promptly](#promptly) · [question](#question)
     - [Tables](#tables) — [tobble](#tobble) · [gtabler](#gtabler) · [fabulous](#fabulous)
     - [Terminal info & helpers](#terminal-info--helpers) — [term_size](#term_size) · [string_width](#string_width) · [terminal_link](#terminal_link) · [gleave](#gleave)
     - [Full-screen TUI frameworks](#full-screen-tui-frameworks) — [shore](#shore) · [etch](#etch) · [pink](#pink) · [glink](#glink) · [shiny](#shiny) · [gtui](#gtui) · [glerm](#glerm)
7. [What's missing](#whats-missing)
8. [Comparison matrix](#comparison-matrix)
9. [Leaderboard](#leaderboard)

## Summary

Snapshot: **2026-05-12**.

| Category | Pick | Notes |
| --- | --- | --- |
| **Get `argv`** | [`argv`](#argv) (lpil) | First-party, cross-target (Erlang/Node/Deno/Bun). One-liner. |
| **Parse flags + subcommands + auto-help** | [`glint`](#glint) | The de-facto canonical; type-safe flags, subcommands, automated help. |
| **Decoder-style flag parsing** (gleam/json shape) | [`clad`](#clad) | If you like `decode.field(..)`, this matches the pattern. |
| **Applicative-style parser** | [`clip`](#clip) | Composable applicative chains, 0 open issues, recently active. |
| **Low-level POSIX/CLIG-compliant tokeniser** | [`hoist`](#hoist) | Foundation for building your own framework, not a framework itself. |
| **Colour & ANSI** | [`gleam_community/ansi`](#gleam_communityansi) | First-party, dual-target, the canonical pick. |
| **Spinner** | [`spinner`](#spinner) (lpil) | Stale (2025-01) but the only proven option. |
| **Progress bars** | [`glitzer`](#glitzer) | Only progress-bar package. **GPL-3.0** — caveat for proprietary. |
| **Single-line prompt** | [`input`](#input) | One function, fits 95% of CLI questions. |
| **Multi-question prompts + confirmation** | [`survey`](#survey) | Stale (2024) but the only structured prompt library. |
| **Formatted tables** | [`tobble`](#tobble) | Best-maintained table library, BSD-3-Clause. |
| **Full-screen TUI (BEAM)** | [`shore`](#shore) (103★) | TEA-style framework, Erlang-only, OTP 28+. |
| **Full-screen TUI (dual-target backend)** | [`etch`](#etch) | crossterm-style low-level backend, runs on JS via Bun/Node/Deno *and* on Erlang. |
| **Full-screen TUI (JS via React/Ink)** | [`pink`](#pink) | Wraps Node's `ink`. JS-only. |

> [!IMPORTANT]
> **The leaderboard is not a recommendation order.** A 9-score arg parser cannot render a spinner; a TUI framework cannot parse `argv`. Use the [When to use what](#when-to-use-what) table to pick by job; use the leaderboard to pick **between** competing implementations of the same role.

## State of the ecosystem

CLI tooling in Gleam is **two ecosystems with different shapes**:

**Argument parsing (mature plurality).** Five viable libraries with overlapping capability and distinct ergonomics. [`glint`](#glint) leads on stars, feature surface, and "official-looking" usage by many tools (it's used by Lustre's CLI). [`clip`](#clip), [`clad`](#clad), and [`hoist`](#hoist) are all actively maintained alternatives that pick different design points (applicative / decoder-style / low-level). [`argv`](#argv) is the cross-platform `argv`-getter that sits underneath any of them. The mature minority means there's a real **design choice** here — not a single canonical pick.

**Interactive rendering (thin and fragmented).** First-party `gleam_community/ansi` covers colours and basic styling well across BEAM and JS. After that the ecosystem fragments:

- **Spinners**: one canonical (`spinner`, lpil) — but stale since Jan 2025.
- **Progress bars**: one option (`glitzer`) — and it's **GPL-3.0**.
- **Prompts**: tiny — `input` is a single-question wrapper, `survey` is a 2024-stale multi-question library, `promptly` adds validation. **No multi-select**, **no password**, **no autocomplete**.
- **Tables**: three small packages (`tobble`, `gtabler`, `fabulous`) — `tobble` is the most maintained.
- **Full-screen TUI**: seven packages, each picking a different design point. [`shore`](#shore) is the most mature (TEA architecture, 103★, BEAM-only) but only one of three currently maintained. **No Ratatui-equivalent** with widget richness; **no Bubble Tea–equivalent** with the Charm-style component library polish. [`etch`](#etch) and [`pink`](#pink) cover the JS side via different bindings (crossterm-style vs React/Ink).

Many gaps — multi-select prompts, password input, completion-script generation, fuzzy finders (fzf-style), keyboard shortcut discovery, complex layouts — are reachable only via FFI to Erlang (`io_lib`, `cecho`) or Elixir (`Owl`, `Ratatouille`, `Optimus`).

## Research Method

### Scoring Dimensions

Same 7-dimension rubric as [databases.md#scoring-dimensions](databases.md#scoring-dimensions). Recap:

- **Stars:** 🟩🟩 ≥200★, 🟩 ≥100★, 🟨 ≥10★, 🟥 <10★.
- **License:** 🟩 permissive (MIT/Apache/BSD), 🟥 viral (GPL/LGPL/AGPL) or missing.
- **Gleam compat:** `gleam_stdlib` constraint format. 🟩 range, 🟥 `~>` pin or missing.
- **Maintenance:** max(recency, responsiveness). 🟩🟩 <1 mo / clean tracker, 🟩 <6 mo, 🟨 <1 yr, 🟥 older.
- **Age:** 🟩🟩 ≥3 yrs, 🟩 ≥1 yr, 🟨 ≥3 mo, 🟥 <3 mo.
- **README maturity:** 🟩🟩 full guide + examples, 🟩 clear tagline + usage, 🟥 minimal/template.
- **Idiomaticity:** 🟩 typed/explicit, 🟥 magic or unsafe.

**Leaderboard:** 🟥 = −1, 🟨 = 0, 🟩 = 1, 🟩🟩 = 2. Sum of 7 dims, max 13.

### Discovery

~25 search terms run against the [Gleam packages registry](https://packages.gleam.run/). Cross-checked against [hex.pm](https://hex.pm/), GitHub `language:gleam` searches, and GitLab.

**Argument-parser keywords:**
- [cli](https://packages.gleam.run/?search=cli) · [argv](https://packages.gleam.run/?search=argv) · [args](https://packages.gleam.run/?search=args) · [arguments](https://packages.gleam.run/?search=arguments) · [flag](https://packages.gleam.run/?search=flag) · [flags](https://packages.gleam.run/?search=flags) · [command](https://packages.gleam.run/?search=command) · [subcommand](https://packages.gleam.run/?search=subcommand) — *no results*
- [glint](https://packages.gleam.run/?search=glint) · [clip](https://packages.gleam.run/?search=clip) · [clap](https://packages.gleam.run/?search=clap) · [getopt](https://packages.gleam.run/?search=getopt) — *no results* · [parser](https://packages.gleam.run/?search=parser) (filtered for CLI-shaped)

**Interactive-UI keywords:**
- [ansi](https://packages.gleam.run/?search=ansi) · [color](https://packages.gleam.run/?search=color) · [colour](https://packages.gleam.run/?search=colour) · [terminal](https://packages.gleam.run/?search=terminal)
- [tui](https://packages.gleam.run/?search=tui) · [ratatui](https://packages.gleam.run/?search=ratatui) — *no results* · [bubble](https://packages.gleam.run/?search=bubble) — *no results* · [charm](https://packages.gleam.run/?search=charm) · [ink](https://packages.gleam.run/?search=ink) · [tea](https://packages.gleam.run/?search=tea)
- [prompt](https://packages.gleam.run/?search=prompt) · [interactive](https://packages.gleam.run/?search=interactive) · [input](https://packages.gleam.run/?search=input) · [stdin](https://packages.gleam.run/?search=stdin) · [ask](https://packages.gleam.run/?search=ask)
- [spinner](https://packages.gleam.run/?search=spinner) · [progress](https://packages.gleam.run/?search=progress) · [table](https://packages.gleam.run/?search=table) · [key](https://packages.gleam.run/?search=key) (filtered for keyboard-event)

GitHub `language:gleam` search confirmed no significant CLI/TUI packages absent from Hex.

## Disregarded

Surfaced in searches but **not** scored. Listed up-front so reviewers and readers see "this corner has been considered" before drilling into per-category content.

| Package | Reason disregarded |
| --- | --- |
| [`feature_flags`](https://hex.pm/packages/feature_flags) | **Runtime feature toggles**, not CLI flags. Surfaces under `flag` searches. |
| [`opt_args_with_defs_for_gleam`](https://hex.pm/packages/opt_args_with_defs_for_gleam) | **Function-argument** defaults workaround — not CLI argv. The author calls it "a cursed workaround." |
| [`lustre_dev_tools`](https://hex.pm/packages/lustre_dev_tools), [`g18n_dev`](https://hex.pm/packages/g18n_dev), [`mascarpone`](https://hex.pm/packages/mascarpone), [`glm_freebsd`](https://hex.pm/packages/glm_freebsd), [`scaffold_gleam`](https://hex.pm/packages/scaffold_gleam), [`protozoa_dev`](https://hex.pm/packages/protozoa_dev), [`novdom_dev_tools`](https://hex.pm/packages/novdom_dev_tools), [`gleeam_code`](https://hex.pm/packages/gleeam_code), [`gleamoire`](https://hex.pm/packages/gleamoire) | **CLI tools built in Gleam** rather than libraries for building CLIs. They use the libraries reviewed here, but aren't reusable themselves. |
| [`unitest`](https://hex.pm/packages/unitest), [`glacier_gleeunit`](https://hex.pm/packages/glacier_gleeunit), [`glacier`](https://hex.pm/packages/glacier) | Test runners — covered in [testing/general-testing.md](testing/general-testing.md). |
| [`funsies`](https://hex.pm/packages/funsies) | ORM with a CLI for codegen — covered in [databases.md](databases.md). |
| [`niji`](https://hex.pm/packages/niji), [`open_color`](https://hex.pm/packages/open_color), [`lumi`](https://hex.pm/packages/lumi), [`colorhash`](https://hex.pm/packages/colorhash) | Colour-space / colour-palette utilities — design-tool adjacent, not CLI rendering. |
| [`vec_dict_ansi`](https://hex.pm/packages/vec_dict_ansi) | Converts a vec-dict to ANSI strings — niche debug helper, not a general-purpose ANSI tool. |
| [`gliff`](https://hex.pm/packages/gliff) | Diff renderer that *uses* ANSI; not an ANSI library itself. |
| [`adglent`](https://hex.pm/packages/adglent), [`rcade_inputs`](https://hex.pm/packages/rcade_inputs), [`toon_codec`](https://hex.pm/packages/toon_codec) | "Input" matches but unrelated (Advent of Code helper · gamepad bindings · token-encoder). |
| [`nimiq_gleam`](https://hex.pm/packages/nimiq_gleam) | Nimiq blockchain primitives, with a side-quest CLI. Domain-specific, not a CLI library. |
| [`glance_armstrong`](https://hex.pm/packages/glance_armstrong) | Terminal-formatted Gleam parse-error diagnostics — niche dev tool. |
| [`alakazam`](https://hex.pm/packages/alakazam), [`glm_encrypted_file`](https://hex.pm/packages/glm_encrypted_file), [`gleamyshell`](https://hex.pm/packages/gleamyshell) | Shelling out to other commands — covered in [subprocesses.md](subprocesses.md). |
| [`starprnt`](https://hex.pm/packages/starprnt) | Star Micronics receipt-printer protocol — not a CLI library despite "command" in description. |
| [`dnalg`](https://hex.pm/packages/dnalg) | DNA-sequence algorithms with a side-quest CLI. Domain-specific. |

## When to use what

| You want to… | Use | Notes |
| --- | --- | --- |
| **Get the raw `argv` cross-platform** (Erlang, Node, Deno, Bun) | [`argv`](#argv) | First-party, one function, dual-target. |
| **Parse `--flag value` with type-safety + auto-help + subcommands** | [`glint`](#glint) | The de-facto canonical. |
| **Parse args using a `gleam/json`-style decoder** | [`clad`](#clad) | If `decode.field(..)` is your mental model. |
| **Parse args applicatively, composing many small parsers** | [`clip`](#clip) | Closest to Haskell's `optparse-applicative`. |
| **Build your own CLI framework** | [`hoist`](#hoist) | POSIX/CLIG-compliant low-level tokeniser. |
| **Write a tiny one-off CLI** with no help text | [`outil`](#outil) (stale) or just `argv` + pattern-match | Outil's author redirects you to glint for anything bigger. |
| **Exit with a status code** | [`gleave`](#gleave) | Wraps `erlang:halt/1` and `process.exit` — needed because there's no built-in. |
| **Print colourised output** (red/green/cyan, bold) | [`gleam_community/ansi`](#gleam_communityansi) | First-party, dual-target. |
| **Convert between colour models** (RGB / HSL / hex) | [`gleam_community/colour`](#gleam_communitycolour) | Companion to ansi. |
| **Show an animated spinner** during a long task | [`spinner`](#spinner) | The only proven option; **stale since 2025-01**. |
| **Render a progress bar** (with a known total) | [`glitzer`](#glitzer) | The only progress-bar package. **GPL-3.0** — incompatible with proprietary distribution. |
| **Prompt for a single line of input** | [`input`](#input) | Single function, idiomatic. |
| **Prompt with validation** (regex / non-empty / etc.) | [`promptly`](#promptly) | Wraps `input` with a validator callback. |
| **Multi-question form / yes-no confirmation** | [`survey`](#survey) | Stale (2024) but the only multi-question library. |
| **Read raw stdin (one line / iterator)** | [`stdin`](#stdin) (iterator, dual-target via Erlang/Node/Deno/Bun) or [`in`](#in) (line-at-a-time) | Both fill stdlib gaps. |
| **Render a formatted table** | [`tobble`](#tobble) | BSD-3-Clause, actively maintained until mid-2025. |
| **Discover the terminal's size** | [`term_size`](#term_size) | Stale (2024) but works across all targets. |
| **Measure printable width of a string with emoji / wide chars** | [`string_width`](#string_width) | Critical for any layout that depends on character width. |
| **Add a clickable hyperlink in terminal output** | [`terminal_link`](#terminal_link) | OSC 8 escape sequences. |
| **Build a full-screen TUI on BEAM** (TEA-style) | [`shore`](#shore) | The most mature TUI option; OTP 28+. |
| **Build a full-screen TUI dual-target** (Erlang + JS) | [`etch`](#etch) | crossterm-style low-level backend; bring your own widget layer. |
| **Build a full-screen TUI on Node.js using React** | [`pink`](#pink) (or [`glink`](#glink)) | Both wrap Ink; pink is more recent. |
| **Pretty-print errors / messages** (with a frame, an icon) | [`hug`](#hug) | Pre-styled message helpers. |
| **Multi-select prompt, password prompt, autocomplete prompt** | *(no Gleam package)* | FFI to Elixir's [`Owl`](https://hexdocs.pm/owl/) (`Owl.IO.select/2`, etc.) |
| **Render a Bubble Tea–style component-rich TUI** | *(no Gleam package)* | FFI to Elixir's [`Ratatouille`](https://hexdocs.pm/ratatouille/) (BEAM-only). |
| **Generate shell-completion scripts (bash/zsh/fish)** | *(no Gleam package)* | FFI to Elixir's [`Optimus`](https://hexdocs.pm/optimus/), or hand-roll. |
| **Fuzzy-find / interactive list (fzf-style)** | *(no Gleam package)* | Shell out to `fzf` via `subprocesses.md` tooling. |

> [!IMPORTANT]
> **Three rules to take with you:**
> 1. **Pair `argv` with one of the parsers.** All argument parsers (`glint`/`clip`/`clad`/`hoist`) take a `List(String)` — they don't fetch `argv` themselves. Use [`argv.load().arguments`](#argv) to get it.
> 2. **`gleave` exists because Gleam has no `System.exit`.** Without it, you'll be tempted to FFI directly to `erlang:halt/1`. Just use the package.
> 3. **`glitzer` is GPL-3.0.** Fine for personal tools, **incompatible with proprietary distribution**. The only Gleam progress-bar option — pick a different render strategy if licensing matters.

## Categories

### Argument parsers

The argument-parser landscape has **five actively-maintained options** and a few stale ones. They pick different design points: `glint` is a full framework with subcommands and auto-help; `clip` is applicative; `clad` is decoder-style (mirrors `gleam/json`); `hoist` is a low-level POSIX tokeniser; `outil` is a tiny one-off helper. Pair any of them with [`argv`](#argv) to get cross-target `argv`.

| Criterion | [argv](#argv) | [glint](#glint) | [clip](#clip) | [clad](#clad) | [hoist](#hoist) | [glap](#glap) | [outil](#outil) | [sheen](#sheen) | [cosmo_cli](#cosmo_cli) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Role | `argv` getter | Full framework | Applicative parser | Decoder-style parser | Low-level POSIX tokeniser | clap-inspired | Tiny one-off | Typed parser | "A simple CLI library" |
| Stars | 35 · 🟨 | 79 · 🟨 | 49 · 🟨 | 18 · 🟨 | 12 · 🟨 | 6 · 🟥 | 10 · 🟨 | 6 · 🟥 | (repo 404) · ⬜ |
| License | (none) · 🟥 | Apache-2.0 · 🟩 | (NOASSERTION — LICENSE present, type unclear) · 🟨 | (none) · 🟥 | Apache-2.0 · 🟩 | MIT · 🟩 | Apache-2.0 · 🟩 | MPL-2.0 · 🟨 | MIT · 🟩 |
| Target | dual (Erlang/Node/Deno/Bun) | dual (no `target` field) | dual (no `target` field) | dual (no `target` field) | dual (no `target` field) | dual | dual | dual | (unknown) · ⬜ |
| Gleam compat | `>= 0.0.0 and < 2.0.0` · 🟩 | `>= 0.43.0 and < 2.0.0` · 🟩 | `>= 0.45.0 and < 2.0.0` · 🟩 | `>= 0.34.0 and < 2.0.0` · 🟩 | (range) · 🟩 | (range) · 🟩 | (range) · 🟩 | (range) · 🟩 | (unknown) · ⬜ |
| Maintenance | 🟩🟩 (last commit 2026-05-11, 1 day before snapshot, 2 open) | 🟩🟩 (last commit 2026-05-03, 17 open) | 🟩🟩 (last commit 2026-05-10, 0 open) | 🟩 (last commit 2025-12-01, 0 open) | 🟩 (last commit 2026-03-17, 0 open) | 🟥 (last commit 2025-06-29, 0 open) | 🟥 (last commit 2023-11-16, 3 open) | 🟥 (last commit 2024-03-21, 0 open) | ⬜ (Hex 2025-05-08, repo deleted) |
| README | 🟩 (clear quickstart) | 🟩🟩 (full guide + flags + help text) | 🟩🟩 (full guide + applicative example) | 🟩🟩 (full guide + two patterns shown) | 🟩🟩 (full guide + POSIX/CLIG explainer) | 🟩 (clap-style example) | 🟩🟩 (full guide + changelog) | 🟩 (clear; pre-1.0 disclaimer) | ⬜ |
| Idiomaticity | 🟩 (typed) | 🟩 (typed flags + path-based subcommands) | 🟩 (applicative `\|>` chains, typed) | 🟩 (decoder pattern, typed) | 🟩 (typed, low-level) | 🟩 | 🟩 | 🟩 (fully typed, MPL-2.0) | ⬜ |

#### argv
[hex](https://hex.pm/packages/argv) · [repo](https://github.com/lpil/argv) · 35★

`lpil/argv` — **the cross-platform `argv` getter**. Calls `init:get_plain_arguments` on Erlang and unifies `process.argv` across Node/Deno/Bun on JavaScript. Single function, returns a `Loaded` record with `arguments: List(String)` and `program_name: String`. Use this **underneath** any of the parsers below — none of them fetch `argv` themselves.

```gleam
import argv

pub fn main() {
  let loaded = argv.load()
  case loaded.arguments {
    ["hello", name] -> echo "Hello, " <> name
    _ -> echo "usage: " <> loaded.program_name <> " hello <name>"
  }
}
```

No license declared in the GitHub sidebar — flagged as 🟥. Last commit 2026-05-11 (1 day before snapshot).

#### glint
[hex](https://hex.pm/packages/glint) · [repo](https://github.com/TanklesXL/glint) · [hexdocs](https://hexdocs.pm/glint) · 79★ · [🥇](#argument-parsers-leaderboard)

**The de-facto canonical Gleam CLI framework.** Type-safe flags (`int_flag`, `bool_flag`, `string_flag`, `floats_flag`, `strings_flag`, …), nested subcommands via path-based `glint.add(at: ["service", "start"], ..)`, **automated help-text generation**, flag constraints, and a clean `use`-callback API for command bodies. Apache-2.0, 79★, last commit 2026-05-03, 17 open issues (active tracker).

```gleam
import argv
import glint

pub fn main() {
  glint.new()
  |> glint.with_name("hello-world")
  |> glint.with_pretty_help(glint.default_pretty_help())
  |> glint.add(at: ["hello"], do: hello())
  |> glint.run(argv.load().arguments)
}

fn hello() {
  use <- glint.command_help("Greets someone")
  use caps <- glint.flag(glint.bool_flag("caps") |> glint.flag_default(False))
  use _, args, flags <- glint.command()
  let assert Ok(loud) = caps(flags)
  let name = string.join(args, " ")
  case loud {
    True -> echo "HELLO, " <> string.uppercase(name)
    False -> echo "Hello, " <> name
  }
}
```

The README is a comprehensive guide (~250 lines) covering core concepts, flag types, constraints, and help-text wrapping. Used by Lustre's CLI and many smaller Gleam tools — high "official-looking" social proof.

#### clip
[hex](https://hex.pm/packages/clip) · [repo](https://github.com/drewolson/clip) · [hexdocs](https://hexdocs.pm/clip) · 49★ · [🥈](#argument-parsers-leaderboard)

**Applicative-style CLI option parser.** Closest to Haskell's `optparse-applicative`: build small parsers for each option, then compose them with `clip.command(..)` into one parser that yields a typed record. Cross-cutting `clip/help` module for help-text. **0 open issues**, last commit 2026-05-10 (2 days before snapshot) — actively maintained.

```gleam
import argv
import clip
import clip/opt
import gleam/io

pub type Person {
  Person(name: String, age: Int)
}

pub fn main() {
  let parser =
    clip.command({
      use name <- clip.parameter
      use age <- clip.parameter
      Person(name, age)
    })
    |> clip.opt(opt.new("name") |> opt.help("Your name"))
    |> clip.opt(opt.new("age") |> opt.int |> opt.help("Your age"))

  case clip.run(parser, "person", argv.load().arguments) {
    Ok(person) -> io.println("Hello " <> person.name)
    Error(err) -> io.println(err)
  }
}
```

LICENSE file present but GitHub's API reports `NOASSERTION` (likely a non-standard SPDX header) — **🟨 unknown**, check the file directly before depending on it for proprietary work.

#### clad
[hex](https://hex.pm/packages/clad) · [repo](https://github.com/ryanmiville/clad) · 18★

**Argument decoder library — `gleam/json`-style decoder pattern applied to argv.** If you reach for `decode.field(..)` to parse JSON, this matches the same mental model for CLI flags. Inspired by Node's `minimist` plus `gleam/json`. Two API styles: a `decode`-style decoder, and a lower-level `clad.opt`/`clad.flag` style.

```gleam
import argv
import clad
import gleam/dynamic/decode

pub type Student {
  Student(name: String, age: Int, enrolled: Bool, classes: List(String))
}

pub fn main() {
  let decoder = {
    use name <- decode.field("name", decode.string)
    use age <- decode.field("age", decode.int)
    use enrolled <- decode.field("enrolled", decode.bool)
    use classes <- decode.field("class", decode.list(decode.string))
    decode.success(Student(name, age, enrolled, classes))
  }

  let assert Ok(student) = clad.decode(argv.load().arguments, decoder)
  echo student
}
```

Last commit 2025-12-01, 0 open issues. No license declared — flagged 🟥.

#### hoist
[hex](https://hex.pm/packages/hoist) · [repo](https://github.com/Pevensie/hoist) · 12★

**POSIX- and CLIG-compliant low-level option parser written in pure Gleam.** Explicitly **not a framework** — no help text, no command structure, no validation. Designed as a foundation that other Gleam CLI frameworks (or your one-off tool) can build on. Handles positional args, valued flags, toggles, counted flags (`-vvv`), short aliases, and POSIX legacy conventions. Apache-2.0, last commit 2026-03-17, 0 open issues.

```gleam
import argv
import hoist

pub fn main() {
  let target = hoist.new_flag("target") |> hoist.with_short_alias("t")
  let verbose = hoist.new_flag("verbose") |> hoist.with_short_alias("v") |> hoist.as_count
  let dry_run = hoist.new_flag("dry-run") |> hoist.with_short_alias("d") |> hoist.as_toggle

  let parsed = hoist.parse(argv.load().arguments, [target, verbose, dry_run])
  echo parsed
}
```

Reach for `hoist` if `glint`'s API is too opinionated and you'd rather build the help-text / subcommand layer yourself.

#### glap
[hex](https://hex.pm/packages/glap) · [repo](https://github.com/aintea4/glap) · 6★

**Small clap-inspired argument parser.** API resembles Rust's `clap` builder. Last commit 2025-06-29, 0 open issues, 6★ — niche; reach for `glint` or `clip` instead unless the clap mental model is what you want. MIT.

#### outil
[hex](https://hex.pm/packages/outil) · [repo](https://github.com/fabjan/outil) · 10★

"A library for writing **small** command line tools." Author explicitly recommends `glint` for anything more ambitious, and the README maintains a thoughtful changelog from v0.1 → v0.5. **Stale since 2023-11-16** but the README's pointer-to-glint is itself useful documentation. Apache-2.0.

#### sheen
[hex](https://hex.pm/packages/sheen) · [repo](https://github.com/ehllie/sheen) · 6★

"Fully typed library for constructing command line parsers." MPL-2.0 (mildly viral — file-level copyleft). README carries a **pre-1.0 API-unstable disclaimer**. Last commit 2024-03-21. Skip in favour of glint/clip/hoist unless type-construction style matters.

#### cosmo_cli
[hex](https://hex.pm/packages/cosmo_cli) · ~~[repo](https://github.com/Drumato/cosmo_cli)~~ (404) · ⬜

"A simple CLI library." Listed on Hex (last release 2025-05-08, 235 total downloads) but the **GitHub repository returns 404** — appears to have been deleted. Hex package is still installable but unsupported source-of-truth. Most metadata marked ⬜ until the repo is restored or the author confirms the package's status. **Avoid for new code** — broken upstream signal.

### Interactive UI / CLI renderers

Eight sub-areas, each thinner than the arg-parser landscape: ANSI/colour, spinners/progress, prompts/input, tables, terminal info, full-screen TUI frameworks, and one pretty-message helper.

#### Colour & ANSI

| Criterion | [gleam_community/ansi](#gleam_communityansi) | [gleam_community/colour](#gleam_communitycolour) | [the_stars](#the_stars) | [gleamy_lights](#gleamy_lights) | [colours](#colours) | [galant](#galant) | [chromatic](#chromatic) | [colored](#colored) | [tulip](#tulip) | [hug](#hug) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Role | ANSI colours + formatting | Colour types & conversion | Charm Lipgloss-style framework | Coloured logger-ish | Coloured strings | ANSI strings | Composable colours | Simple colours | 256-colour ANSI | Pretty CLI messages |
| Stars | 36 · 🟨 | 20 · 🟨 | 1 · 🟥 | 5 · 🟥 | 12 · 🟨 | 2 · 🟥 | 2 · 🟥 | 4 · 🟥 | 0 · 🟥 | 33 · 🟨 |
| License | Apache-2.0 · 🟩 | Apache-2.0 · 🟩 | (none) · 🟥 | Apache-2.0 · 🟩 | (none) · 🟥 | Apache-2.0 · 🟩 | MIT · 🟩 | MIT · 🟩 | MIT · 🟩 | (none) · 🟥 |
| Target | dual | dual | dual | dual | dual | dual | dual | dual | dual | dual |
| Maintenance | 🟩🟩 (2026-04-20) | 🟩🟩 (2026-04-20) | 🟩 (2026-03-08) | 🟥 (2025-05-20) | 🟥 (2024-02-06) | 🟥 (2022-12-23) | 🟥 (2024-03-13) | 🟥 (2024-03-15) | 🟥 (2024-05-16) | 🟥 (2024-05-01) |
| README | 🟩🟩 | 🟩🟩 | 🟩 | 🟩 | 🟩 | 🟩 | 🟩 | 🟩 | 🟩 | 🟩 |
| Idiomaticity | 🟩 | 🟩 | 🟩 | 🟩 | 🟩 | 🟩 | 🟩 | 🟩 | 🟩 | 🟩 |

##### gleam_community/ansi
[hex](https://hex.pm/packages/gleam_community_ansi) · [repo](https://github.com/gleam-community/ansi) · [hexdocs](https://hexdocs.pm/gleam_community_ansi) · 36★ · [🥇](#interactive-ui-leaderboard)

**The canonical ANSI library.** Foreground/background colours (named, 256-colour, 24-bit RGB), bold/italic/underline, cursor movement, screen clearing. Companion to [`gleam_community/colour`](#gleam_communitycolour) — both are first-party-ish (under the `gleam-community` GitHub org, Apache-2.0, used everywhere). Dual-target, 🟩🟩 maintenance, 2 open issues.

```gleam
import gleam_community/ansi

pub fn main() {
  echo ansi.green("ok ") <> "all checks passed"
  echo ansi.red(ansi.bold("err")) <> " 1 test failing"
  echo ansi.dim("(took 12.4s)")
}
```

##### gleam_community/colour
[hex](https://hex.pm/packages/gleam_community_colour) · [repo](https://github.com/gleam-community/colour) · 20★

**Colour types and conversions** — RGB ↔ HSL ↔ hex, named colours, alpha. Lower-level than `ansi`; you'd reach for it directly when building anything that maps to non-terminal colour (web hex strings, image processing). Companion package, Apache-2.0, 🟩🟩 maintenance.

##### the_stars
[hex](https://hex.pm/packages/the_stars) · [repo](https://github.com/Genekkion/the_stars) · 1★

**"Charm Lipgloss for Gleam"** — a styling and logging framework inspired by Go's [Charm Lipgloss](https://github.com/charmbracelet/lipgloss). Aims higher than `ansi` (composable styles, padding, borders, alignment) but is brand-new (1★, last commit 2026-03-08) and doesn't yet have license metadata. Watch this space — if it grows, it's the closest thing to a "designable" terminal output story in Gleam.

##### gleamy_lights
[hex](https://hex.pm/packages/gleamy_lights) · [repo](https://github.com/strawmelonjuice/gleamy_lights) · 5★

**Coloured terminal output** with a logger-flavoured API. 5★, last commit 2025-05-20, Apache-2.0. Niche — `gleam_community/ansi` covers the same ground with more polish.

##### colours
[hex](https://hex.pm/packages/colours) · [repo](https://github.com/Willyboar/colours) · 12★

Adds colour to terminal output. 12★ but **stale since 2024-02-06** and **no license declared**. Skip for `gleam_community/ansi`.

##### galant
[hex](https://hex.pm/packages/galant) · [repo](https://github.com/JohnBjrk/galant) · 2★

ANSI-escape string-styling library. Apache-2.0, 2★, **stale since 2022-12-23** — the oldest in this group.

##### chromatic
[hex](https://hex.pm/packages/chromatic) · [repo](https://github.com/joshocalico/chromatic) · 2★

"Beautiful, expressive and composable color and text formatting." MIT, 2★, last commit 2024-03-13. Niche.

##### colored
[hex](https://hex.pm/packages/colored) · [repo](https://github.com/dhruvdabhi101/colored) · 4★

"Simple CLI color library for gleam." MIT, 4★, last commit 2024-03-15. Niche.

##### tulip
[hex](https://hex.pm/packages/tulip) · [repo](https://github.com/johnnymayodev/tulip) · 0★

Adds 256-colour ANSI to terminal output. MIT, 0★, last commit 2024-05-16.

##### hug
[hex](https://hex.pm/packages/hug) · [repo](https://github.com/brettkolodny/gleam-hug) · 33★

**Helpful and pretty CLI messages** — pre-styled error / warning / info renderers with frames and icons. Higher-level than `gleam_community/ansi` — opinionated about the shape of a message. 33★ (one of the more popular CLI-render packages), but **no license declared** and stale since 2024-05-01.

#### Spinners & progress

| Criterion | [spinner](#spinner) | [glitzer](#glitzer) |
| --- | --- | --- |
| Role | Animated spinner | Progress bars + spinners |
| Stars | 28 · 🟨 | 14 · 🟨 |
| License | Apache-2.0 · 🟩 | **GPL-3.0** · 🟥 |
| Target | dual (depends on `gleam_community_ansi` + `repeatedly`) | dual |
| Maintenance | 🟥 (last commit 2025-01-08, ~16 mo) | 🟨 (last commit 2025-07-27) |
| README | 🟩 | 🟩 |
| Idiomaticity | 🟩 | 🟩 |

##### spinner
[hex](https://hex.pm/packages/spinner) · [repo](https://github.com/lpil/spinner) · 28★

**The canonical spinner.** `lpil`-authored. Builder API: `spinner.new(text) |> spinner.with_colour(..) |> spinner.start`, then `spinner.set_text(..)` to update mid-run, `spinner.stop(..)` to clean up. Depends on `gleam_community_ansi` and `repeatedly`. **Stale since 2025-01** — works fine, but no recent updates.

##### glitzer
[hex](https://hex.pm/packages/glitzer) · [repo](https://github.com/miampf/glitzer) · 14★

**Progress bars** (the only Gleam progress-bar package) plus spinners and "fancy stuff." 14★, last commit 2025-07-27.

> [!WARNING]
> `glitzer` is **GPL-3.0** — incompatible with closed-source distribution. If your CLI ships proprietary, render progress bars yourself with `gleam_community/ansi` cursor moves.

#### Prompts & input

| Criterion | [input](#input) | [in](#in) | [stdin](#stdin) | [survey](#survey) | [promptly](#promptly) | [question](#question) |
| --- | --- | --- | --- | --- | --- | --- |
| Role | Single-line prompt | stdin reading | Iterator over stdin | Multi-question prompts + confirmation | Validated single prompt | Q-and-A callback |
| Stars | 10 · 🟨 | 2 · 🟥 | 23 · 🟨 | 6 · 🟥 | 0 · 🟥 | 1 · 🟥 |
| License | (none) · 🟥 | (none) · 🟥 | (none) · 🟥 | Apache-2.0 · 🟩 | Apache-2.0 · 🟩 | (none) · 🟥 |
| Target | dual (Erlang + Node/Deno/Bun) | dual | dual (Erlang/Node/Deno/Bun) | BEAM (depends on `gleam_erlang`) | dual (depends on `input`) | dual |
| Maintenance | 🟨 (2025-07-08) | 🟨 (2025-08-27) | 🟥 (2025-05-27) | 🟥 (2024-03-24) | 🟨 (2025-09-09) | 🟥 (2024-03-25) |
| README | 🟩 | 🟩 | 🟩 | 🟩 | 🟩 | 🟩 |
| Idiomaticity | 🟩 | 🟩 | 🟩 | 🟩 | 🟩 | 🟩 |

##### input
[hex](https://hex.pm/packages/input) · [repo](https://github.com/bcpeinhardt/input) · 10★

"Provides a single function, `input`, that prints a prompt and then reads a user's input." That's it — and that's why it's the right pick for 95% of one-question CLIs. Dual-target. **No license declared** — caveat for proprietary, but the surface is small enough to vendor.

```gleam
import input

pub fn main() {
  let assert Ok(name) = input.input("Your name: ")
  echo "Hi, " <> name
}
```

##### in
[hex](https://hex.pm/packages/in) · [repo](https://github.com/evanlua/in) · 2★

"Input functions (stdin reading) missing from `gleam/io`." Sibling to `input` — a touch lower-level. 2★, no license declared.

##### stdin
[hex](https://hex.pm/packages/stdin) · [repo](https://github.com/olian04/gleam-stdin) · 23★

**Synchronous iterator over stdin** — supports all non-browser targets (Erlang, Node, Deno, Bun). Use this when you're processing piped input line-by-line. 23★, no license declared, **stale since 2025-05-27**.

##### survey
[hex](https://hex.pm/packages/survey) · [repo](https://github.com/calvinmclean/survey) · 6★

**Multi-question prompt library** — ask several questions in sequence, including yes/no confirmation. The only Gleam library with multi-prompt orchestration; modeled loosely on Go's [AlecAivazis/survey](https://github.com/AlecAivazis/survey). Apache-2.0, **stale since 2024-03-24**, **BEAM-only** (depends on `gleam_erlang`).

```gleam
import survey

pub fn main() {
  let questions = [
    survey.Question(prompt: "First name: ", help: None, default: None, transform: None, validate: None),
    survey.Question(prompt: "Last name: ", help: None, default: None, transform: None, validate: None),
    survey.Confirmation(prompt: "Are you a survey fan? [y/n] ", help: None, default: None),
  ]
  let answers = survey.ask_many(questions, help: False)
  echo answers
}
```

> [!IMPORTANT]
> **No multi-select, no password prompt, no autocomplete in any Gleam package.** For these, FFI to Elixir's [`Owl`](https://hexdocs.pm/owl/) — `Owl.IO.select/2`, `Owl.IO.input(secret: true)`, etc. See [What's missing](#whats-missing).

##### promptly
[hex](https://hex.pm/packages/promptly) · [repo](https://github.com/JosephTLyons/promptly) · 0★

**Validated user input** — wraps `input` with a validator callback. Apache-2.0, last commit 2025-09-09.

##### question
[hex](https://hex.pm/packages/question) · [repo](https://github.com/antonioxdias/question) · 1★

"Prompt user with question and return answer in callback." 1★, no license declared, last commit 2024-03-25. Skip for `input` + `promptly`.

#### Tables

| Criterion | [tobble](#tobble) | [gtabler](#gtabler) | [fabulous](#fabulous) |
| --- | --- | --- | --- |
| Role | Table renderer | Coloured table renderer | Simple table renderer |
| Stars | 11 · 🟨 | 0 · 🟥 | 4 · 🟥 |
| License | BSD-3-Clause · 🟩 | (none) · 🟥 | MIT · 🟩 |
| Target | dual | dual | dual |
| Maintenance | 🟥 (2025-06-11, ~11 mo) | 🟥 (2024-11-27) | 🟥 (2025-01-29) |
| README | 🟩 | 🟩 | 🟩 |
| Idiomaticity | 🟩 | 🟩 | 🟩 |

##### tobble
[hex](https://hex.pm/packages/tobble) · [repo](https://github.com/ollien/tobble) · 11★

**The most-maintained Gleam table library.** BSD-3-Clause, 11★, last commit 2025-06-11. Reach for this if you need to print a `kubectl get pods`–style aligned table.

##### gtabler
[hex](https://hex.pm/packages/gtabler) · [repo](https://github.com/eAntillon/gleam_table_printer) · 0★

"Customizable library for printing tables with colors and styles." 0★, no license declared, last commit 2024-11-27. Niche.

##### fabulous
[hex](https://hex.pm/packages/fabulous) · [repo](https://github.com/DeveloperSpoot/fabulous) · 4★

"Simple library for creating tables based on columns and rows." MIT, 4★, last commit 2025-01-29.

#### Terminal info & helpers

##### term_size
[hex](https://hex.pm/packages/term_size) · [repo](https://github.com/MystPi/term_size) · 3★

**Retrieve the terminal's rows and columns**, dual-target. Critical for any layout decision. Apache-2.0, **stale since 2024-04-13** but stable enough that lack of updates isn't alarming.

##### string_width
[hex](https://hex.pm/packages/string_width) · [repo](https://gitlab.com/arkandos/string-width) · BSD-3-Clause

**Measure the printable width of a string** in terminal cells, accounting for emoji, CJK characters, ANSI escape codes, and zero-width joiners. Critical for any layout that depends on character width (tables, padding, alignment). Last commit 2026-02-14. GitLab-hosted (star count not surfaced via the GitLab UI in this snapshot).

##### terminal_link
[hex](https://hex.pm/packages/terminal_link) · [repo](https://github.com/hougesen/terminal_link) · 4★

**Clickable terminal hyperlinks** via OSC 8 escape sequences. MIT, 4★, last commit 2025-03-20. Trivial library, useful pattern.

##### gleave
[hex](https://hex.pm/packages/gleave) · [repo](https://github.com/ollien/gleave) · 1★

**Exit your Gleam CLI with a status code.** Wraps `erlang:halt/1` and `process.exit` for dual-target. Trivially small but **necessary** — Gleam's stdlib doesn't ship `System.exit`. WTFPL.

```gleam
import gleave

pub fn main() {
  case do_thing() {
    Ok(_) -> gleave.exit(0)
    Error(_) -> gleave.exit(1)
  }
}
```

#### Full-screen TUI frameworks

The most fragmented sub-area in this article. Seven packages, each picking a different design point. Three are currently maintained (`shore`, `etch`, `pink`), four are stale.

| Criterion | [shore](#shore) | [etch](#etch) | [pink](#pink) | [glink](#glink) | [shiny](#shiny) | [gtui](#gtui) | [glerm](#glerm) |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Role | TEA framework | crossterm-style backend | Ink (React) bindings | Ink bindings | TUI library | TUI library | Terminal wrapper |
| Stars | 103 · 🟩 | 47 · 🟨 | 11 · 🟨 | 1 · 🟥 | 5 · 🟥 | 18 · 🟨 | 11 · 🟨 |
| License | MIT · 🟩 | MIT · 🟩 | (none) · 🟥 | Apache-2.0 · 🟩 | MIT · 🟩 | (none) · 🟥 | (none) · 🟥 |
| Target | **BEAM only** (OTP 28+) | dual (Bun/Node/Deno + Gleescript/Burrito) | **JS only** (`target = "javascript"`) | **JS only** | dual | dual | BEAM (depends on `gleam_erlang`) |
| Maintenance | 🟩🟩 (2026-04-26) | 🟩 (2026-03-05) | 🟨 (2025-09-12) | 🟥 (2025-05-19) | 🟨 (2025-08-25) | 🟥 (2024-06-14) | 🟥 (2024-12-08) |
| README | 🟩🟩 | 🟩🟩 | 🟩 | 🟩 | 🟩 | 🟩 | 🟩 |
| Idiomaticity | 🟩 | 🟩 | 🟩 | 🟩 | 🟩 | 🟩 | 🟩 |

##### shore
[hex](https://hex.pm/packages/shore) · [repo](https://github.com/bgwdotdev/shore) · 103★ · [🥇](#interactive-ui-leaderboard)

**The most mature Gleam TUI framework.** TEA architecture (`init` / `update` / `view`), built-in widgets (text, button, box, layout helpers), keybinding registration. **BEAM-only**, requires **OTP 28+**. MIT, 103★, last commit 2026-04-26. Sister package [`beach`](https://hex.pm/packages/beach) serves a Shore TUI over SSH — useful for ops dashboards.

```gleam
import shore

pub type Model { Model(count: Int) }
pub type Msg { Increment | Decrement }

fn init() -> Model { Model(count: 0) }
fn update(model: Model, msg: Msg) -> Model {
  case msg {
    Increment -> Model(count: model.count + 1)
    Decrement -> Model(count: model.count - 1)
  }
}
fn view(model: Model) {
  shore.box([
    shore.text("Count: " <> int.to_string(model.count)),
    shore.button("+", on_click: Increment),
    shore.button("-", on_click: Decrement),
  ])
}

pub fn main() {
  shore.spec(init: init, update: update, view: view, keybindings: [#("+", Increment), #("-", Decrement)])
  |> shore.start
}
```

##### etch
[hex](https://hex.pm/packages/etch) · [repo](https://github.com/bananaofhappiness/etch) · 47★

**crossterm-style low-level TUI backend.** Inspired by Rust's [`crossterm`](https://github.com/crossterm-rs/crossterm) — provides cursor positioning, colour setting, event handling, and screen clearing as direct commands (with `execute()` / `queue()` / `flush()`). **Bring your own widget layer.** Dual-target — `gleam.toml` declares `target = "javascript"` but the README explicitly documents Bun, Node, Deno **and** Gleescript / Burrito (Erlang) targets. Last commit 2026-03-05, MIT. **47★ and growing.**

##### pink
[hex](https://hex.pm/packages/pink) · [repo](https://github.com/Massolari/pink) · 11★

**Bindings to [Ink](https://github.com/vadimdemedes/ink)** — the React-style terminal-UI library for Node.js. Compose your TUI with React components from Gleam. **JS-only** — Ink is a Node library; `gleam.toml` declares `target = "javascript"`. 11★, last commit 2025-09-12, no license declared.

##### glink
[hex](https://hex.pm/packages/glink) · [repo](https://github.com/han-tyumi/glink) · 1★

**Sibling/competitor to pink** — also Ink bindings. 1★, last commit 2025-05-19. Pink is more recent and more starred — prefer pink.

> [!NOTE]
> **Why both `pink` and `glink` exist** — both wrap Node's [Ink](https://github.com/vadimdemedes/ink), both target JavaScript only. `glink` (han-tyumi, v0.3.0, last published 2025-05-19) is older and less complete; `pink` (Massolari, v2.1.0, last published 2025-09-12) is the more-maintained one. No cross-reference between the READMEs — looks like **parallel discovery** rather than supersession or competition.

##### shiny
[hex](https://hex.pm/packages/shiny) · [repo](https://github.com/gleemers/shiny) · 5★

"A cute tui library." MIT, 5★, last commit 2025-08-25. Niche.

##### gtui
[hex](https://hex.pm/packages/gtui) · [repo](https://github.com/sanchit1053/gleam_tui) · 18★

A TUI library for Gleam. 18★ but **stale since 2024-06-14**, no license declared.

##### glerm
[hex](https://hex.pm/packages/glerm) · [repo](https://github.com/rawhat/glerm) · 11★

"A terminal wrapper for Gleam." 11★, no license declared, **stale since 2024-12-08**, BEAM-only (depends on `gleam_erlang`).

## What's missing

Capabilities with **no Gleam package** today. For each, the path is direct FFI to the corresponding Erlang/Elixir Hex package — these are battle-tested and callable as `@external(erlang, ..)` declarations.

| Missing | Why you might want it | FFI escape hatch |
| --- | --- | --- |
| **Multi-select prompt** (checkbox list) | Letting the user toggle several options | Elixir [`Owl.IO.select/2`](https://hexdocs.pm/owl/Owl.IO.html#select/2) — supports multi-select. |
| **Password prompt** (silent input, no echo) | Secret entry | Elixir [`Owl.IO.input(secret: true)`](https://hexdocs.pm/owl/Owl.IO.html#input/1); or set tty-raw via `:io_lib`. |
| **Autocomplete prompt** (typeahead from a list) | UX polish | Elixir [`Owl.IO.select/2`](https://hexdocs.pm/owl/Owl.IO.html#select/2) plus your own filter. |
| **Fuzzy finder (fzf-style)** | Interactive list filtering | **Shell out to `fzf`** via [`subprocesses.md`](subprocesses.md) tooling — no in-process Gleam alternative. |
| **Bubble Tea–style framework** (Charm / Lipgloss / Bubbles ecosystem) | Component-rich TUI with stylable widgets | Elixir [`Ratatouille`](https://hexdocs.pm/ratatouille/) (BEAM-only) — the closest analogue. |
| **Ratatui-style widget library** (Rust ecosystem polish) | Tabs, charts, sparklines, gauges | None on BEAM — your closest path is `shore` + custom widgets, or `etch` + your own widget layer. |
| **Shell-completion script generation** (bash / zsh / fish) | First-class user-facing CLI tool | Elixir [`Optimus`](https://hexdocs.pm/optimus/) generates completion scripts. Or hand-write per shell. |
| **Manpage generation from CLI definitions** | Linux distro packaging | None on BEAM. Hand-write `.1` files or use Pandoc Markdown→manpage. |
| **Configuration-file fallback** (TOML / YAML / JSON args from a config file) | Defaults from `~/.config/<tool>.toml` | Use [`tom`](https://hex.pm/packages/tom) (TOML) or one of the YAML parsers in [yaml.md](yaml.md) ([`yamleam`](yaml.md#yamleam) for typed decoders, [`taffy`](yaml.md#taffy) for hardened parsing); merge into your typed config record before parsing argv. |
| **Environment-variable fallback** for flags | `MY_TOOL_VERBOSE=1` ↔ `--verbose` | Hand-roll: `os.get_env(..)` → patch the parsed result. None of `glint`/`clip`/`clad`/`hoist` automate this. |
| **`stty` / raw-mode toggling** | Single-keypress reads, no Enter required | FFI to Erlang's `:io` interface flags (`set_raw`, etc.) or shell out to `stty`. |
| **Mouse-event capture in TUI** | Click handling in shore/etch apps | Not in `shore` or `etch` widget layers; would require terminal-input-mode escapes. |
| **Line editor (readline-equivalent)** with history + completion | Repls, interactive shells | Erlang `:edlin` (BEAM-internal); or shell out to `rlwrap`. |
| **Pager integration** (auto-pipe long output to `less`) | `git diff`-style behaviour | Shell out via `subprocesses.md` tooling; no Gleam wrapper. |
| **Emoji-aware string truncation / wrapping** | Polished output for international users | Pair [`string_width`](#string_width) with hand-rolled truncation; no all-in-one wrapper. |

## Comparison matrix

All scored packages, all 7 dimensions, one row per package.

| Package | Stars | License | Compat | Maintenance | Age | README | Idiomaticity | Score |
| --- | ---: | --- | --- | --- | --- | --- | --- | ---: |
| [glint](#glint) | 🟨 | 🟩 | 🟩 | 🟩🟩 | 🟩🟩 | 🟩🟩 | 🟩 | **9** |
| [clip](#clip) | 🟨 | 🟨 | 🟩 | 🟩🟩 | 🟩 | 🟩🟩 | 🟩 | **8** |
| [argv](#argv) | 🟨 | 🟥 | 🟩 | 🟩🟩 | 🟩 | 🟩 | 🟩 | **5** |
| [clad](#clad) | 🟨 | 🟥 | 🟩 | 🟩 | 🟩 | 🟩🟩 | 🟩 | **5** |
| [hoist](#hoist) | 🟨 | 🟩 | 🟩 | 🟩 | 🟨 | 🟩🟩 | 🟩 | **6** |
| [glap](#glap) | 🟥 | 🟩 | 🟩 | 🟥 | 🟩 | 🟩 | 🟩 | **2** |
| [outil](#outil) | 🟨 | 🟩 | 🟩 | 🟥 | 🟩🟩 | 🟩🟩 | 🟩 | **6** |
| [sheen](#sheen) | 🟥 | 🟨 | 🟩 | 🟥 | 🟩🟩 | 🟩 | 🟩 | **3** |
| [cosmo_cli](#cosmo_cli) | ⬜ | 🟩 | ⬜ | ⬜ | 🟩 | ⬜ | ⬜ | **n/a** |
| [gleam_community/ansi](#gleam_communityansi) | 🟨 | 🟩 | 🟩 | 🟩🟩 | 🟩🟩 | 🟩🟩 | 🟩 | **9** |
| [gleam_community/colour](#gleam_communitycolour) | 🟨 | 🟩 | 🟩 | 🟩🟩 | 🟩🟩 | 🟩🟩 | 🟩 | **9** |
| [hug](#hug) | 🟨 | 🟥 | 🟩 | 🟥 | 🟩🟩 | 🟩 | 🟩 | **3** |
| [the_stars](#the_stars) | 🟥 | 🟥 | 🟩 | 🟩 | 🟨 | 🟩 | 🟩 | **1** |
| [gleamy_lights](#gleamy_lights) | 🟥 | 🟩 | 🟩 | 🟥 | 🟩 | 🟩 | 🟩 | **2** |
| [colours](#colours) | 🟨 | 🟥 | 🟩 | 🟥 | 🟩🟩 | 🟩 | 🟩 | **3** |
| [galant](#galant) | 🟥 | 🟩 | 🟩 | 🟥 | 🟩🟩 | 🟩 | 🟩 | **3** |
| [chromatic](#chromatic) | 🟥 | 🟩 | 🟩 | 🟥 | 🟩🟩 | 🟩 | 🟩 | **3** |
| [colored](#colored) | 🟥 | 🟩 | 🟩 | 🟥 | 🟩🟩 | 🟩 | 🟩 | **3** |
| [tulip](#tulip) | 🟥 | 🟩 | 🟩 | 🟥 | 🟩🟩 | 🟩 | 🟩 | **3** |
| [spinner](#spinner) | 🟨 | 🟩 | 🟩 | 🟥 | 🟩🟩 | 🟩 | 🟩 | **5** |
| [glitzer](#glitzer) | 🟨 | 🟥 | 🟩 | 🟨 | 🟩🟩 | 🟩 | 🟩 | **4** |
| [input](#input) | 🟨 | 🟥 | 🟩 | 🟨 | 🟩 | 🟩 | 🟩 | **3** |
| [in](#in) | 🟥 | 🟥 | 🟩 | 🟨 | 🟩 | 🟩 | 🟩 | **1** |
| [stdin](#stdin) | 🟨 | 🟥 | 🟩 | 🟥 | 🟩 | 🟩 | 🟩 | **2** |
| [survey](#survey) | 🟥 | 🟩 | 🟩 | 🟥 | 🟩🟩 | 🟩 | 🟩 | **3** |
| [promptly](#promptly) | 🟥 | 🟩 | 🟩 | 🟨 | 🟩 | 🟩 | 🟩 | **3** |
| [question](#question) | 🟥 | 🟥 | 🟩 | 🟥 | 🟩🟩 | 🟩 | 🟩 | **1** |
| [tobble](#tobble) | 🟨 | 🟩 | 🟩 | 🟥 | 🟩 | 🟩 | 🟩 | **3** |
| [gtabler](#gtabler) | 🟥 | 🟥 | 🟩 | 🟥 | 🟩 | 🟩 | 🟩 | **0** |
| [fabulous](#fabulous) | 🟥 | 🟩 | 🟩 | 🟥 | 🟩 | 🟩 | 🟩 | **2** |
| [term_size](#term_size) | 🟥 | 🟩 | 🟩 | 🟥 | 🟩🟩 | 🟩 | 🟩 | **3** |
| [string_width](#string_width) | ⬜ | 🟩 | 🟩 | 🟩 | 🟩 | 🟩 | 🟩 | **6** (excl. stars) |
| [terminal_link](#terminal_link) | 🟥 | 🟩 | 🟩 | 🟥 | 🟩 | 🟩 | 🟩 | **2** |
| [gleave](#gleave) | 🟥 | 🟩 | 🟩 | 🟩 | 🟩 | 🟩 | 🟩 | **4** |
| [shore](#shore) | 🟩 | 🟩 | 🟩 | 🟩🟩 | 🟩 | 🟩🟩 | 🟩 | **9** |
| [etch](#etch) | 🟨 | 🟩 | 🟩 | 🟩 | 🟩 | 🟩🟩 | 🟩 | **7** |
| [pink](#pink) | 🟨 | 🟥 | 🟩 | 🟨 | 🟩 | 🟩 | 🟩 | **3** |
| [glink](#glink) | 🟥 | 🟩 | 🟩 | 🟥 | 🟩 | 🟩 | 🟩 | **2** |
| [shiny](#shiny) | 🟥 | 🟩 | 🟩 | 🟨 | 🟩 | 🟩 | 🟩 | **3** |
| [gtui](#gtui) | 🟨 | 🟥 | 🟩 | 🟥 | 🟩🟩 | 🟩 | 🟩 | **3** |
| [glerm](#glerm) | 🟨 | 🟥 | 🟩 | 🟥 | 🟩🟩 | 🟩 | 🟩 | **3** |

## Leaderboard

Per-category leaderboards — argument parsers and interactive UI score against different rubrics in practice (UI tools are tinier, fewer stars, less feature surface), so they're ranked separately. **Not a recommendation order** — pick by job, not by score.

### Argument parsers leaderboard

| Rank | Package | Score | Highlights |
| --- | --- | ---: | --- |
| 🥇 | [glint](#glint) | **9** | The de-facto canonical · type-safe flags + subcommands + auto-help · 79★ · used by Lustre's CLI |
| 🥈 | [clip](#clip) | **8** | Applicative-style · 0 open issues · actively maintained · the choice if you like `optparse-applicative` |
| 🥉 | [hoist](#hoist) | **6** | POSIX/CLIG-compliant low-level tokeniser · designed as a foundation, not a framework |
| 🥉 | [outil](#outil) | **6** | Tiny one-off helper · stale but author redirects you to glint · honest README |
| 5 | [argv](#argv) | **5** | Cross-target `argv`-getter · pair with any of the above · no license declared |
| 5 | [clad](#clad) | **5** | Decoder-style (mirrors `gleam/json`) · the right pick if you live in `decode.field(..)` |
| 7 | [sheen](#sheen) | **3** | Typed parser with pre-1.0 disclaimer · MPL-2.0 · stale |
| 8 | [glap](#glap) | **2** | clap-inspired · niche · stale |
| n/a | [cosmo_cli](#cosmo_cli) | **n/a** | **GitHub repo deleted (404)** · Hex package still installable · avoid for new code |

### Interactive UI leaderboard

| Rank | Package | Score | Highlights |
| --- | --- | ---: | --- |
| 🥇 | [gleam_community/ansi](#gleam_communityansi) | **9** | First-party ANSI · dual-target · used everywhere · the canonical pick for colour |
| 🥇 | [gleam_community/colour](#gleam_communitycolour) | **9** | Colour types & conversion · companion to ansi · use when you want non-terminal colour |
| 🥇 | [shore](#shore) | **9** | TEA-style TUI framework · 103★ · OTP 28+ · BEAM-only · the most mature TUI |
| 4 | [etch](#etch) | **7** | crossterm-style backend · dual-target (Bun/Node/Deno + Erlang) · bring your own widget layer |
| 5 | [spinner](#spinner) | **5** | The canonical spinner · stale but works · `lpil`-authored |
| 5 | [string_width](#string_width) | **6** | Emoji/CJK/ANSI-aware width measurement · BSD-3-Clause · GitLab-hosted (stars not surfaced) |
| 7 | [glitzer](#glitzer) | **4** | The only progress-bar package · **GPL-3.0** · proprietary-incompatible |
| 7 | [gleave](#gleave) | **4** | Exit with status code · trivially small but necessary · WTFPL |
| 9 | [hug](#hug) | **3** | Pre-styled CLI messages · 33★ · stale · no license |
| 9 | [colours](#colours) | **3** | Coloured terminal output · stale · no license |
| 9 | [galant](#galant) | **3** | ANSI-string styler · oldest in the colour group · Apache-2.0 |
| 9 | [chromatic](#chromatic) | **3** | Composable colours · niche · MIT |
| 9 | [colored](#colored) | **3** | Simple colours · niche · MIT |
| 9 | [tulip](#tulip) | **3** | 256-colour ANSI · niche · MIT |
| 9 | [input](#input) | **3** | Single-line prompt · the right pick for 95% of one-question CLIs |
| 9 | [survey](#survey) | **3** | Multi-question prompts + confirmation · stale (2024) · BEAM-only |
| 9 | [promptly](#promptly) | **3** | Validated input · wraps `input` |
| 9 | [tobble](#tobble) | **3** | Best-maintained table library · BSD-3-Clause |
| 9 | [term_size](#term_size) | **3** | Terminal rows × columns · stable across all targets |
| 9 | [pink](#pink) | **3** | Ink (React) bindings · JS-only · 11★ |
| 9 | [shiny](#shiny) | **3** | "Cute" TUI library · niche |
| 9 | [gtui](#gtui) | **3** | TUI library · 18★ but stale · no license |
| 9 | [glerm](#glerm) | **3** | Terminal wrapper · 11★ but stale · no license · BEAM-only |
| 24 | [gleamy_lights](#gleamy_lights) | **2** | Coloured logger-ish output · niche |
| 24 | [stdin](#stdin) | **2** | Synchronous stdin iterator · 23★ but stale · no license |
| 24 | [terminal_link](#terminal_link) | **2** | OSC 8 hyperlinks · trivial library, useful pattern |
| 24 | [fabulous](#fabulous) | **2** | Simple table renderer · niche · MIT |
| 24 | [glink](#glink) | **2** | Older Ink bindings · prefer pink |
| 29 | [the_stars](#the_stars) | **1** | Charm Lipgloss-style framework · brand new (1★) · no license · watch this space |
| 29 | [in](#in) | **1** | stdin reading helpers · niche |
| 29 | [question](#question) | **1** | Q-and-A callback · stale · niche |
| 32 | [gtabler](#gtabler) | **0** | Coloured tables · 0★, no license, niche |

> [!IMPORTANT]
> **Two rules to take with you:**
> 1. **Argument parsing has plurality; interactive rendering has thinness.** Pick a parser confidently from `glint` / `clip` / `clad` / `hoist`. For rendering, expect to combine 2-4 packages (ansi + spinner + input + table) and accept gaps (multi-select, password, autocomplete) by FFI to Elixir's [`Owl`](https://hexdocs.pm/owl/).
> 2. **Star counts in this article skew low.** A 79★ arg parser and a 103★ TUI framework are the *category leaders*. Don't dismiss something at 11★ — that's a normal "actively-used" magnitude here.
