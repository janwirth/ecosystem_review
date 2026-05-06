# Syntax highlighting in Gleam

> [!NOTE]
> **Status:** DRAFT · **Authoring:** AI-assisted, human-reviewed.

So you want to show pretty code on your blog, in your CLI, or inside a Lustre app?
Pick the right highlighter here.

## Table of Contents

1. [Summary](#summary)
2. [Research Method](#research-method)
   - [Scoring Dimensions](#scoring-dimensions)
   - [Discovery](#discovery)
3. [Categories](#categories)
   - [Per-Language Lexers](#per-language-lexers) — [contour](#contour) · [just](#just) · [pearl](#pearl) · [tear](#tear)
   - [Multi-Language Highlighters](#multi-language-highlighters) — [smalto](#smalto)
   - [Native (Tree-sitter NIF)](#native-tree-sitter-nif) — [glimra](#glimra)
4. [Leaderboard](#leaderboard)

## Summary

**Snapshot 2026-04-21.** Gleam has a small but healthy set of syntax highlighters. Most are pure-Gleam per-language lexers with the same three-output pattern (tokens, ANSI, HTML). Two broader options exist: smalto for many languages in pure Gleam, glimra for tree-sitter via NIFs.

| Category | ☎️ BEAM | 📜 JS |
| --- | --- | --- |
| **[Per-Language Lexers](#per-language-lexers)** | · [🥇](#leaderboard) [contour](#contour) ([repo](https://github.com/lpil/contour), 23★) — *Gleam highlighter by Gleam's creator*<br>· [🥇](#leaderboard) [just](#just) ([repo](https://github.com/GearsDatapacks/just), 18★) — *JavaScript lexer + highlighter*<br>· [🥈](#leaderboard) [pearl](#pearl) ([repo](https://github.com/GearsDatapacks/pearl), 8★) — *Erlang lexer + highlighter*<br>· [🥉](#leaderboard) [tear](#tear) ([repo](https://gitlab.com/arkandos/tear)) — *Elixir lexer + highlighter* | · [🥇](#leaderboard) [contour](#contour), [just](#just) — *same packages, pure Gleam, dual-target*<br>· [🥈](#leaderboard) [pearl](#pearl), [🥉](#leaderboard) [tear](#tear) — *dual-target* |
| **[Multi-Language Highlighters](#multi-language-highlighters)** | · [🥉](#leaderboard) [smalto](#smalto) ([repo](https://github.com/veeso/smalto), 5★) — *36 languages, regex grammars; + `smalto_lustre` + `smalto_lustre_themes`* | · [🥉](#leaderboard) [smalto](#smalto) — *dual-target* |
| **[Native (Tree-sitter NIF)](#native-tree-sitter-nif)** | · [🥇](#leaderboard) [glimra](#glimra) ([repo](https://github.com/ollema/glimra), 11★) — *tree-sitter NIFs, zero-runtime for lustre/ssg* | — |

> [!IMPORTANT]
> For highlighting Gleam code specifically, [contour](#contour) is the obvious pick — it's maintained by Louis Pilfold (Gleam's creator) and used across the Gleam docs ecosystem.

> <details>
> <summary><strong>Dependency Graph</strong></summary>
>
> Arrows read "uses."
>
> **Per-language lexers** share a common dependency pattern (`gleam_community_ansi` for terminal colors, `houdini` for HTML escaping):
> - [contour](#contour) → `glexer` (Gleam lexer) + `gleam_community_ansi` + `houdini`
> - [just](#just), [pearl](#pearl), [tear](#tear) → `splitter` + `gleam_community_ansi` + `houdini` (each bundles its own hand-written lexer)
>
> **Multi-language:**
> - [smalto](#smalto) → `gleam_community_ansi` + `houdini` — regex grammars generated from Prism.js at build time, but executed in pure Gleam at runtime
> - `smalto_lustre` → [smalto](#smalto) + `lustre` — Lustre element output
> - `smalto_lustre_themes` → `smalto_lustre` — 45 pre-built themes
>
> **Native:**
> - [glimra](#glimra) → `lustre` + `lustre_ssg` + Rust NIFs (tree-sitter, tree-sitter-highlight) — BEAM target only
>
> </details>

## Research Method

### Scoring Dimensions

- **Stars:** 🟩🟩 = ≥200★, 🟩 = ≥100★, 🟨 = ≥10★, 🟥 = <10★. ⬜ = not shown by host (e.g. GitLab).
- **License:** 🟩 = permissive OSS (MIT, Apache-2.0, BSD). 🟥 = viral or missing.
- **Gleam compat:** Range constraint (`>= X and < Y`) = 🟩, non-range (`~>`) = 🟥.
- **Maintenance:** `max(recency, responsiveness)`. Recency: 🟩🟩 <1mo, 🟩 <6mo, 🟨 <1y, 🟥 >1y. Responsiveness: 🟩🟩 <2d or clean tracker, 🟩 <1w, 🟨 <1mo, 🟥 >1mo/ignored.
- **Age:** First commit to snapshot. 🟩🟩 ≥3y, 🟩 ≥1y, 🟨 ≥3mo, 🟥 <3mo.
- **README maturity:** 🟩🟩 guide + examples + feature docs, 🟩 clear with usage, 🟥 minimal.
- **Idiomaticity:** 🟩 typed, explicit, no magic. 🟥 magic directives, implicit behavior.

**Leaderboard scoring:** 🟥 = −1, 🟨/⬜ = 0, 🟩 = 1, 🟩🟩 = 2. Sum of all 7 dimensions. Max = 13.

### Discovery

Searched [Gleam packages registry](https://packages.gleam.run/) — **6 unique repos included** (8 packages; `smalto`, `smalto_lustre`, `smalto_lustre_themes` share one repo). **6 disregarded** from `lexer` search (pure lexers, not highlighters).

- [syntax+highlighting](https://packages.gleam.run/?search=syntax+highlighting)
- [highlighter](https://packages.gleam.run/?search=highlighter)
- [lexer](https://packages.gleam.run/?search=lexer)

> <details>
> <summary>6 disregarded — pure lexers, not syntax highlighters</summary>
>
> These emit tokens but do not produce ANSI/HTML highlighted output. Useful as building blocks, not for the use case of this review.
>
> - **[DanielleMaywood/glexer](https://github.com/DanielleMaywood/glexer)** — Lexer for Gleam source. Used as a dependency by [contour](#contour).
> - **[hayleigh-dot-dev/gleam-nibble](https://github.com/hayleigh-dot-dev/gleam-nibble)** — Parser combinators + lexer. General-purpose parsing library.
> - **[MystPi/chomp](https://github.com/MystPi/chomp)** — Nibble fork with better error messages.
> - **[mewfinity06/gecko-gleam](https://github.com/mewfinity06/gecko-gleam)** — Type-agnostic lexer.
> - **[vaphes/glex](https://github.com/vaphes/glex)** — Lexer generator.
> - **[leonardo-toffalini/shimmy](https://github.com/leonardo-toffalini/shimmy)** — Gleam lexer (no highlighting output).
>
> </details>

## Categories

### Per-Language Lexers

Pure-Gleam, hand-written lexers for a single target language. All four follow the same shape: `new(code)` → `tokenise` → `highlight_ansi` / `highlight_html` / raw tokens. No native code, no build step.

| Criterion | [contour](https://github.com/lpil/contour) [🥇](#leaderboard) | [just](https://github.com/GearsDatapacks/just) [🥇](#leaderboard) | [pearl](https://github.com/GearsDatapacks/pearl) [🥈](#leaderboard) | [tear](https://gitlab.com/arkandos/tear) [🥉](#leaderboard) |
| --- | --- | --- | --- | --- |
| Highlights | Gleam | JavaScript | Erlang | Elixir |
| Stars | 23★ · 🟨 | 18★ · 🟨 | 8★ · 🟥 | ⬜ (GitLab) |
| License | Apache-2.0 · 🟩 | Apache-2.0 · 🟩 | Apache-2.0 · 🟩 | BSD-3-Clause · 🟩 |
| Target | ☎️📜 Both | ☎️📜 Both | ☎️📜 Both | ☎️📜 Both |
| Deps | 4 | 4 | 4 | 4 |
| Gleam compat | `>= 0.44 and < 2.0` · 🟩 | `>= 0.44 and < 2.0` · 🟩 | `>= 0.44 and < 2.0` · 🟩 | `>= 0.44 and < 2.0` · 🟩 |
| Maintenance | 🟩🟩 (0 issues, 0 PRs) | 🟩🟩 (0 issues, 0 PRs) | 🟩🟩 (2026-04-10, 0 issues) | 🟩 (2025-11-25) |
| Age | ~13mo (Mar 2025) · 🟩 | ~13mo (Mar 2025) · 🟩 | ~12mo (Apr 2025) · 🟩 | ~6mo (Oct 2025) · 🟨 |
| README maturity | 🟩 (clear, 3-API usage) | 🟩 (clear, 3-API usage) | 🟩 (clear, 3-API usage) | 🟩 (clear, usage + limits) |
| Idiomaticity | 🟩 | 🟩 | 🟩 | 🟩 |

#### contour
[repo](https://github.com/lpil/contour) · [🥇](#leaderboard)

"A Gleam syntax highlighter in Gleam." Maintained by [Louis Pilfold](https://github.com/lpil), Gleam's creator. Three outputs: ANSI, HTML with CSS classes, raw tokens. Built on `glexer` (the official Gleam lexer). The de facto choice for highlighting Gleam code.

```gleam
import contour

pub fn main() {
  let code = "pub fn main() { io.println(\"hi\") }"

  let ansi = contour.to_ansi(code)
  let html = contour.to_html(code)
  let tokens = contour.to_tokens(code)
}
```

#### just
[repo](https://github.com/GearsDatapacks/just) · [🥇](#leaderboard)

"A JavaScript lexer and syntax highlighter for Gleam!" Same three-output shape as contour. README notes three deliberate simplifications: no regex backtracking, partial Unicode identifier support, no identifier escape-sequence handling — fine for highlighting, not for a full JS parser.

```gleam
import just

pub fn main() {
  let code = "const greet = (name) => `Hello, ${name}!`"

  let html = just.highlight_html(code)
  let ansi = just.highlight_ansi(code)
}
```

#### pearl
[repo](https://github.com/GearsDatapacks/pearl) · [🥈](#leaderboard)

"An Erlang lexer and syntax highlighter for Gleam!" Same author and shape as [just](#just). README claims it successfully lexes all valid Erlang programs; implementation is based on Erlang docs and existing parsers, not an official spec.

```gleam
import pearl

pub fn main() {
  let code = "-module(hello). hello() -> io:format(\"hi~n\")."

  let html = pearl.highlight_html(code)
  let ansi = pearl.highlight_ansi(code)
}
```

#### tear
[repo](https://gitlab.com/arkandos/tear) · [🥉](#leaderboard)

"A lexer and syntax highlighter for Elixir, written in Gleam." Inspired by [contour](#contour). Young (~6 months). GitLab-hosted — star count not surfaced on the public page. Deliberately relaxes some of Elixir's strict rules (Unicode identifier classes, NFC normalization, spacing between functions/arguments) — highlighting-focused, not a compliant Elixir parser.

```gleam
import tear
import simplifile

pub fn main() {
  let assert Ok(input) = simplifile.read("/dev/stdin")

  input
  |> tear.highlight
  |> tear.to_ansi
}
```

### Multi-Language Highlighters

General-purpose highlighters covering many languages in pure Gleam.

| Criterion | [smalto](https://github.com/veeso/smalto) [🥉](#leaderboard) |
| --- | --- |
| Stars | 5★ · 🟥 |
| License | MIT · 🟩 |
| Target | ☎️📜 Both |
| Deps | 3 |
| Gleam compat | `>= 0.44 and < 2.0` · 🟩 |
| Maintenance | 🟩🟩 (2026-03-17, 0 issues) |
| Age | ~1.4mo (Mar 2026) · 🟥 |
| README maturity | 🟩🟩 (guide, feature table, Lustre integration, theme docs) |
| Idiomaticity | 🟩 (explicit grammar imports) |

#### smalto
[repo](https://github.com/veeso/smalto) · [🥉](#leaderboard)

"A general-purpose syntax highlighting library for Gleam, with regex-based grammars for 36+ languages." Tokenizer inspired by Prism.js — grammars are generated from Prism.js definitions via a Node.js converter tool, then shipped as pure-Gleam regex grammars (runtime, not codegen-per-project). Supports language inheritance (TypeScript extends JavaScript) and nested tokenization (CSS-in-HTML). Ships with:

- **smalto** — core library, three outputs (tokens / ANSI / HTML)
- **smalto_lustre** — Lustre element conversion
- **smalto_lustre_themes** — 45 pre-built themes

36 languages including Bash, C/C++/C#, CSS, Dart, Dockerfile, Elixir, Erlang, F#, Gleam, Go, Haskell, HTML, Java, JavaScript, JSON, Kotlin, Lua, Markdown, PHP, Python, Ruby, Rust, Scala, SQL, Swift, TOML, TypeScript, YAML, Zig.

```gleam
import smalto
import smalto/languages/python

pub fn main() {
  let code = "def greet(name: str) -> str:\n    return f'Hello, {name}!'"

  let html = smalto.to_html(code, python.grammar())
  let ansi = smalto.to_ansi(code, python.grammar())
  let tokens = smalto.to_tokens(code, python.grammar())
}
```

### Native (Tree-sitter NIF)

Pre-compiled native highlighters exposed to Gleam via Erlang NIFs. Not pure Gleam — ships a Rust binary per platform.

| Criterion | [glimra](https://github.com/ollema/glimra) [🥇](#leaderboard) |
| --- | --- |
| Stars | 11★ · 🟨 |
| License | MIT · 🟩 |
| Target | ☎️ BEAM only (`target = "erlang"`) |
| Deps | 4 |
| Gleam compat | `>= 0.65 and < 1.0` · 🟩 |
| Maintenance | 🟩 (2026-01-13, 5 open issues) |
| Age | ~20mo (Aug 2024) · 🟩 |
| README maturity | 🟩🟩 (platform matrix, config, lustre/ssg integration examples) |
| Idiomaticity | 🟩 (builder pattern) |

#### glimra
[repo](https://github.com/ollema/glimra) · [🥇](#leaderboard)

"Zero runtime syntax highlighter for lustre/ssg." Wraps the Rust crates `tree-sitter` and `tree-sitter-highlight` via NIFs. "Zero runtime" means the highlighting work happens at site build time (via lustre_ssg), not in the browser or server request path. Pre-compiled binaries ship for Linux x86_64, macOS aarch64/x86_64, Windows x86_64 — BEAM target only; no JS.

```gleam
import glimra
import glimra/theme
import lustre/ssg

pub fn main() {
  let highlighter =
    glimra.new_syntax_highlighter()
    |> glimra.set_theme(theme.default_theme())

  ssg.new("dist")
  |> ssg.add_static_stylesheet(glimra.to_css(highlighter))
  |> ssg.build
}
```

## Leaderboard
Every contribution is invaluable and appreciated.

**🥇 Gold**
Thanks to the folks keeping Gleam code pretty wherever it shows up:
- **contour** ([lpil](https://github.com/lpil)) — the Gleam highlighter by Gleam's creator. Powers the docs ecosystem.
- **just** ([GearsDatapacks](https://github.com/GearsDatapacks)) — clean JavaScript highlighter, same shape as contour. Dual-target.
- **glimra** ([ollema](https://github.com/ollema)) — tree-sitter via NIFs, zero-runtime pipeline for static sites. Different class of tool.

**🥈 Silver**
- **pearl** ([GearsDatapacks](https://github.com/GearsDatapacks)) — Erlang highlighter, same polish as just. Just a bit younger and with fewer stars.

**🥉 Bronze**
- **smalto** ([veeso](https://github.com/veeso)) — 36 languages + Lustre themes in pure Gleam. Young (~6 weeks), but the only multi-language option that doesn't need NIFs.
- **tear** ([arkandos](https://gitlab.com/arkandos)) — Elixir highlighter. GitLab-hosted, young, fills the last gap in the BEAM-language quartet.

| Position | Award | Repo | ★ | Lic | Compat | Maint | Age | README | Idiom | Score |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 🥇 | · [lpil/contour](https://github.com/lpil/contour)<br>· [GearsDatapacks/just](https://github.com/GearsDatapacks/just)<br>· [ollema/glimra](https://github.com/ollema/glimra) | 🟨<br>🟨<br>🟨 | 🟩<br>🟩<br>🟩 | 🟩<br>🟩<br>🟩 | 🟩🟩<br>🟩🟩<br>🟩 | 🟩<br>🟩<br>🟩 | 🟩<br>🟩<br>🟩🟩 | 🟩<br>🟩<br>🟩 | **7** |
| 2 | 🥈 | [GearsDatapacks/pearl](https://github.com/GearsDatapacks/pearl) | 🟥 | 🟩 | 🟩 | 🟩🟩 | 🟩 | 🟩 | 🟩 | **6** |
| 3 | 🥉 | · [veeso/smalto](https://github.com/veeso/smalto)<br>· [arkandos/tear](https://gitlab.com/arkandos/tear) | 🟥<br>⬜ | 🟩<br>🟩 | 🟩<br>🟩 | 🟩🟩<br>🟩 | 🟥<br>🟨 | 🟩🟩<br>🟩 | 🟩<br>🟩 | **5** |

**By target:** ☎️ BEAM **37** (6 repos) · 📜 JS **30** (5 repos). glimra is BEAM-only (NIFs); the rest are dual-target pure Gleam.

[How scores are calculated →](#scoring-dimensions)
