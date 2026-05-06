# Parsers in Gleam

> [!NOTE]
> **Status:** DRAFT · **Authoring:** AI-assisted, human-reviewed.

Runtime translation from text (or token stream) into a typed Gleam value. Three sub-shapes: parser combinators, format-specific parsers, and parsers for **other languages** consumed inside Gleam (`glance` for Gleam source, `oas` for OpenAPI specs).

For build-time codegen that consumes these parser outputs, see [generate.md](generate.md). For wire-format decoders where the grammar is fixed and trivial (JSON, CBOR), see [decode.md](decode.md).

## Table of Contents

1. [Summary](#summary)
2. [Discovery](#discovery)
3. [Parser combinator toolkits](#parser-combinator-toolkits)
4. [Data-format parsers](#data-format-parsers)
5. [HTML parsers](#html-parsers)
6. [String-slicing primitives](#string-slicing-primitives)
7. [Other-language parsers](#other-language-parsers)
8. [Leaderboards](#leaderboards)

## Summary

**Snapshot 2026-04-26.** Gleam covers a lot of parsing ground in pure Gleam. Combinators: [nibble](#nibble), [chomp](#chomp), [atto](#atto), [party](#party). Format parsers: [tom](#tom), [jot](#jot), [gsv](#gsv), [gleam_xmlm](#gleam_xmlm), [kirala_markdown](#kirala_markdown), [cel-gleam](#cel-gleam). HTML: [presentable_soup](#presentable_soup), [htmgrrrl](#htmgrrrl), [javascript_dom_parser](#javascript_dom_parser). For other-language parsing inside Gleam: [glance](#glance) (Gleam source), [crowdhailer/oas](#oas) (OpenAPI 3.x).

| Sub-category | Picks |
| --- | --- |
| [Parser combinators](#parser-combinator-toolkits) | [nibble](#nibble), [atto](#atto), [chomp](#chomp), [party](#party) |
| [Format parsers](#data-format-parsers) | [tom](#tom), [jot](#jot), [gsv](#gsv), [gleam_xmlm](#gleam_xmlm), [cel-gleam](#cel-gleam), [kirala_markdown](#kirala_markdown) |
| [HTML](#html-parsers) | [presentable_soup](#presentable_soup), [htmgrrrl](#htmgrrrl), [javascript_dom_parser](#javascript_dom_parser) |
| [String primitives](#string-slicing-primitives) | [splitter](#splitter) |
| [Other-language parsers](#other-language-parsers) | [glance](#glance) (Gleam source), [oas](#oas) (OpenAPI 3.x), [glance_printer](#glance_printer) |

> [!NOTE]
> Where parser libraries overlap with [../syntax-highlighting.md](../syntax-highlighting.md) (e.g., per-language lexers used as highlighter input), this article focuses on the parsing/AST role. Read both articles together if you need both signals.

## Discovery

Searches run on **2026-04-26** against [packages.gleam.run](https://packages.gleam.run/):

| Query | URL |
| --- | --- |
| `parser` | [packages.gleam.run/?search=parser](https://packages.gleam.run/?search=parser) |
| `combinator` | [packages.gleam.run/?search=combinator](https://packages.gleam.run/?search=combinator) |
| `lexer` | [packages.gleam.run/?search=lexer](https://packages.gleam.run/?search=lexer) |
| `parse` | [packages.gleam.run/?search=parse](https://packages.gleam.run/?search=parse) |
| `ast` | [packages.gleam.run/?search=ast](https://packages.gleam.run/?search=ast) |
| `html` | [packages.gleam.run/?search=html](https://packages.gleam.run/?search=html) |
| `xml` | [packages.gleam.run/?search=xml](https://packages.gleam.run/?search=xml) |
| `markdown` | [packages.gleam.run/?search=markdown](https://packages.gleam.run/?search=markdown) |
| `toml` | [packages.gleam.run/?search=toml](https://packages.gleam.run/?search=toml) |
| `csv` | [packages.gleam.run/?search=csv](https://packages.gleam.run/?search=csv) |
| `regex` | [packages.gleam.run/?search=regex](https://packages.gleam.run/?search=regex) |
| `tree-sitter` | [packages.gleam.run/?search=tree-sitter](https://packages.gleam.run/?search=tree-sitter) (0 hits) |

Out of scope for this file: per-language syntax-highlighter lexers (→ [../syntax-highlighting.md](../syntax-highlighting.md)); CLI argument parsers (glint, clip, hoist, glap, sheen).

## Parser combinator toolkits

Primitives (`many`, `sep`, `between`, etc.) for hand-rolling a parser. Pick by error-message quality, recent activity, and license preference.

| Criterion | [nibble](#nibble) | [chomp](#chomp) | [atto](#atto) | [party](#party) |
| --- | --- | --- | --- | --- |
| Stars | 82★ · 🟥 | 9★ · 🟥 | 33★ · 🟨 | 18★ · 🟨 |
| License | MIT · 🟩 | Apache-2.0 · 🟩 | MIT · 🟩 | MPL-2.0 · 🟥 |
| Target | ☎️📜 Both | ☎️📜 Both | ☎️📜 Both | ☎️📜 Both |
| Maintenance | 🟩 (last commit 2025-07-29) | 🟨 (last commit 2024-12-31) | 🟩 (last commit 2025-08-17) | 🟩🟩 (last commit 2026-04-21) |
| Age | ~3 years (Mar 2023) · 🟩🟩 | ~1.5 years (late 2024) · 🟩 | ~2.5 years · 🟩 | ~3 years · 🟩🟩 |
| README maturity | 🟩🟩 (guide, examples, lexer + parser) | 🟩 (clear: "fork of nibble that does some things differently") | 🟩🟩 (combinator reference, error-message focus) | 🟩 (tagline + usage) |
| Idiomaticity | 🟩 (typed, explicit) | 🟩 | 🟩 | 🟩 |
| Issues | 1 open | 1 open | 0 open | 1 open |

Pick: **nibble** for the most-used choice (82★, used by [chomp](#chomp) as its base). **chomp** if you want better error messages and don't mind a fork. **atto** for robust combinators with custom-stream support. **party** for a small surface and recent activity.

### nibble
[repo](https://github.com/hayleigh-dot-dev/gleam-nibble)

"A lexer and parser combinator library inspired by `elm/parser`." Two-stage design: a traditional lexer produces tokens, then combinators consume them. Pure Gleam, dual-target. By Hayleigh Thompson (creator of [Lustre](https://github.com/lustre-labs/lustre)).

```gleam
import nibble
import nibble/lexer

pub fn main() {
  let tokens = lexer.run("3 + 4", my_lexer)
  let assert Ok(ast) = nibble.run(tokens, my_parser)
  echo ast
}
```

### chomp
[repo](https://github.com/MystPi/chomp)

"A fork of nibble that does some things differently." Removes "error dead ends" and adds custom error types. Same lexer + combinator shape. Stale-ish (last commit Dec 2024) but stable.

### atto
[repo](https://github.com/ieeemma/atto)

"Robust and extensible parser-combinators for Gleam." Combinator inventory (`many`, `sep`, `between`, choice with backtracking), beautiful error messages, custom-stream support, and contextual grammar capabilities. Active in 2025.

### party
[repo](https://github.com/RyanBrewer317/party)

"A little parser combinator library in Gleam." Small surface, recent stdlib upgrade (Apr 2026). README explicitly recommends [atto](#atto) for more advanced needs. **Note:** MPL-2.0 license is weak copyleft at the file level — flag for shops standardising on MIT/Apache.

## Data-format parsers

Pure-Gleam parsers for specific formats — drop-in replacements for hand-rolling.

| Tool | Format | Stars | Latest commit | Notes |
| --- | --- | --- | --- | --- |
| [tom](#tom) | TOML | 38★ · 🟨 | recent | Pure-Gleam TOML parser by Louis Pilfold |
| [jot](#jot) | Djot (Markdown-like) | 60★ · 🟥 | 2026-04-07 | Parser + AST + HTML rendering |
| [gsv](#gsv) | CSV | 18★ · 🟨 | 2026-04-18 | `to_lists` / `to_dicts`, custom delimiters |
| [gleam_xmlm](#gleam_xmlm) | XML (pull-based) | 11★ · 🟨 | 2026-01-05 | Inspired by OCaml `xmlm` |
| [kirala_markdown](#kirala_markdown) | Markdown | 5★ · 🟥 | 2024-01-09 | Markdown → HTML, BEAM + JS |
| [mork](https://git.liten.app/krig/mork) | Markdown | ⬜ (self-hosted) | — | Markdown parser; repo on liten.app (gated by Anubis, no public metrics) |
| [cel-gleam](#cel-gleam) | Common Expression Language | 5★ · 🟥 | 2026-04-24 | Lex + parse + evaluate; interpreter |

### tom
[repo](https://github.com/lpil/tom)

"A pure Gleam TOML parser!" By Louis Pilfold. Provides `tom.parse()` plus typed getter helpers. 3 open issues at snapshot (notably TOML v1.1.0 support and dynamic decoding) — usable but not actively-developed.

```gleam
import tom

pub fn main() {
  let assert Ok(parsed) = tom.parse("name = \"alice\"\nage = 30\n")
  let assert Ok("alice") = tom.get_string(parsed, ["name"])
}
```

### jot
[repo](https://github.com/lpil/jot)

"A parser for Djot, a markdown-like language." Two outputs: AST (`jot.parse`) and HTML (`jot.to_html`). Covers headings, lists, links, code blocks, math, and text formatting. Active (last commit 2026-04-07, v11.0.0).

### gsv
[repo](https://github.com/giacomocavalieri/gsv)

"A simple csv parser and serialiser for Gleam." `to_lists()` for nested-list output, `to_dicts()` for header-keyed records. Custom delimiter support. Active (last commit 2026-04-18, v5.1.0).

### gleam_xmlm
[repo](https://github.com/mooreryan/gleam_xmlm)

"A pull-based XML parser for the Gleam programming language." Inspired by OCaml's `xmlm`. Includes XML conformance tests, benchmarking, and Erlang profiling tooling. Dual-licensed Apache-2.0 / MIT.

### kirala_markdown
[repo](https://github.com/Yasuo-Higano/kirala_markdown)

Markdown parser + HTML renderer. Both Erlang and JavaScript targets. Stale (last commit 2024-01-09, "for gleam ver 0.33") — usable but unlikely to track recent stdlib changes.

### cel-gleam
[repo](https://github.com/JonasHedEng/cel-gleam)

A Gleam implementation of [Common Expression Language](https://github.com/google/cel-spec) — Google's "non-Turing complete language designed for simplicity, speed, safety, and portability." Provides lexer, parser, AST, and expression evaluator. Useful for embedding rule/policy DSLs in Gleam apps. Active (last commit 2026-04-24).

## HTML parsers

Three approaches, none of them overlapping.

| Tool | Approach | Target | Stars | Notes |
| --- | --- | --- | --- | --- |
| [presentable_soup](#presentable_soup) | High-level: query, scrape, snapshot-test | ☎️ BEAM (htmerl) | 23★ · 🟨 | "Good for snapshot testing" |
| [htmgrrrl](#htmgrrrl) | Low-level SAX events | ☎️ BEAM (htmerl) | 14★ · 🟨 | Stale (last commit 2023-12-08) |
| [javascript_dom_parser](#javascript_dom_parser) | Bindings to browser `DOMParser` | 📜 JS only | 8★ · 🟥 | Stale (last commit 2024-04-07) |

### presentable_soup
[repo](https://github.com/lpil/presentable-soup)

"Efficient querying, scraping, and parsing of HTML. Good for snapshot testing too!" Built on the Erlang `htmerl` parser. Highest-level of the three: query elements, scrape multiple, integrate with [birdie](https://github.com/giacomocavalieri/birdie) snapshots. Active (last commit 2026-02-05, v2.0.0).

### htmgrrrl
[repo](https://github.com/lpil/htmgrrrl)

"Gleam bindings to htmerl, the fast and memory efficient Erlang HTML SAX parser." Event-based — receive `start_element`, `end_element`, `characters`. Lower-level than presentable_soup; useful when you don't want a tree in memory. Last commit 2023-12-08 — unmaintained but stable bindings.

### javascript_dom_parser
[repo](https://github.com/lpil/javascript-dom-parser)

"Bindings to the JavaScript `DOMParser` API." JS target only — for Lustre/SSR or browser-side parsing. Last commit 2024-04-07.

## String-slicing primitives

### splitter
[repo](https://github.com/lpil/splitter)

"Efficiently slice prefixes from strings. Good for parsers!" Below the combinator level — used as a dependency by several syntax-highlighter lexers (just, pearl, tear). 18★, last commit 2025-11-18, 0 open issues.

## Other-language parsers

Gleam libraries that parse the source/structure of **other** languages.

| Tool | Parses | Stars | Latest commit | Notes |
| --- | --- | --- | --- | --- |
| [glance](#glance) | Gleam source code | 80★ · 🟥 | 2025-10-21 | Permissive parser, accepts code the compiler rejects |
| [oas](#oas) | OpenAPI 3.x specs (+ JSON Schema) | 15★ · 🟨 | 2026-04-16 | Used as input for [oas_generator](generate.md#oas_generator) |
| [glance_printer](#glance_printer) | Re-emits glance AST as Gleam | ⬜ | — | Pretty printer for the glance AST |

> [!NOTE]
> **Per-language syntax-highlighting lexers** (Gleam, Erlang, Elixir, JavaScript) live in [../syntax-highlighting.md](../syntax-highlighting.md). They parse other languages too — the role-difference is "extract token stream for colourisation" vs "extract AST for analysis/codegen." If you want to highlight Gleam code, use [contour](../syntax-highlighting.md#contour); if you want to analyse Gleam code, use [glance](#glance).

### glance
[repo](https://github.com/lpil/glance)

"A Gleam source code parser, in Gleam!" Permissive — accepts some code the official compiler rejects, useful for refactoring tools and analysers. By Louis Pilfold. Active (last commit 2025-10-21, v6.0.0).

```gleam
import glance

pub fn main() {
  let code = "
    pub type Cardinal {
      North
      East
      South
      West
    }
  "
  let assert Ok(parsed) = glance.module(code)
  echo parsed.custom_types
}
```

Used as a dependency by [crowdhailer/oas_generator](generate.md#oas_generator), [dusty-phillips/derived](generate.md#derived), and others doing source-level codegen.

### glance_printer
[repo](https://github.com/bcpeinhardt/glance_printer)

"A pretty printer for the glance AST." Companion to [glance](#glance) — pairs the parser with a re-emitter, closing the source → AST → source loop required for refactor tools.

### oas
[repo](https://github.com/crowdhailer/oas)

"Work with Open API Specs (previously swagger) and JSON Schema." Decodes OpenAPI 3.x documents into Gleam types (paths, components, operations). Used as input by [oas_generator](generate.md#oas_generator). Apache-2.0. 0 open issues at snapshot. Note: gleam.toml has `target = "javascript"` — JS-first, but parsing is platform-agnostic.

## Leaderboards

### Parser combinators

| Position | Award | Repo | ★ | Lic | Compat | Maint | Age | README | Idiom | Score |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 🥇 | [hayleigh-dot-dev/gleam-nibble](https://github.com/hayleigh-dot-dev/gleam-nibble) | 🟥 | 🟩 | 🟩 | 🟩 | 🟩🟩 | 🟩🟩 | 🟩 | **7** |
| 2 | 🥈 | [ieeemma/atto](https://github.com/ieeemma/atto) | 🟨 | 🟩 | 🟩 | 🟩 | 🟩 | 🟩🟩 | 🟩 | **7** |
| 3 | 🥉 | [RyanBrewer317/party](https://github.com/RyanBrewer317/party) | 🟨 | 🟥 | 🟩 | 🟩🟩 | 🟩🟩 | 🟩 | 🟩 | **6** |
| 4 | — | [MystPi/chomp](https://github.com/MystPi/chomp) | 🟥 | 🟩 | 🟩 | 🟨 | 🟩 | 🟩 | 🟩 | **3** |

### Format-specific parsers

| Position | Award | Repo | Format | ★ | Lic | Compat | Maint | Age | README | Idiom | Score |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 🥇 | [giacomocavalieri/gsv](https://github.com/giacomocavalieri/gsv) | CSV | 🟨 | 🟨 | 🟩 | 🟩🟩 | 🟩🟩 | 🟩🟩 | 🟩 | **9** |
| 2 | 🥈 | [lpil/jot](https://github.com/lpil/jot) | Djot | 🟥 | 🟨 | 🟩 | 🟩🟩 | 🟩 | 🟩🟩 | 🟩 | **7** |
| 2 | 🥈 | [lpil/tom](https://github.com/lpil/tom) | TOML | 🟨 | 🟨 | 🟩 | 🟩 | 🟩🟩 | 🟩 | 🟩 | **7** |
| 4 | 🥉 | [JonasHedEng/cel-gleam](https://github.com/JonasHedEng/cel-gleam) | CEL | 🟥 | 🟩 | 🟩 | 🟩🟩 | 🟩 | 🟩 | 🟩 | **6** |
| 5 | — | [mooreryan/gleam_xmlm](https://github.com/mooreryan/gleam_xmlm) | XML | 🟨 | 🟩 | 🟩 | 🟩 | 🟩 | 🟩 | 🟩 | **7** |

(Note: gsv, jot, tom licenses not surfaced via README/sidebar inspection — recorded as 🟨 unknown rather than asserting; check repos directly.)

### HTML parsers

| Position | Award | Repo | ★ | Maint | Age | README | Idiom | Score |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 🥇 | [lpil/presentable-soup](https://github.com/lpil/presentable-soup) | 🟨 | 🟩🟩 | 🟩 | 🟩 | 🟩 | **6** |
| 2 | 🥈 | [lpil/htmgrrrl](https://github.com/lpil/htmgrrrl) | 🟨 | 🟥 | 🟩🟩 | 🟩 | 🟩 | **4** |
| 3 | 🥉 | [lpil/javascript-dom-parser](https://github.com/lpil/javascript-dom-parser) | 🟥 | 🟥 | 🟩🟩 | 🟩 | 🟩 | **2** |

### Other-language parsers

| Position | Award | Repo | Parses | ★ | Lic | Compat | Maint | Age | README | Idiom | Score |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 🥇 | [lpil/glance](https://github.com/lpil/glance) | Gleam source | 🟥 | 🟩 | 🟩 | 🟩🟩 | 🟩🟩 | 🟩🟩 | 🟩 | **9** |
| 2 | 🥈 | [crowdhailer/oas](https://github.com/crowdhailer/oas) | OpenAPI 3.x | 🟨 | 🟩 | 🟨 | 🟩🟩 | 🟩 | 🟩 | 🟩 | **7** |

[How scores are calculated →](README.md#scoring-rubric-shared)

## Related

- [decode.md](decode.md) — wire-format runtime decoders (JSON, CBOR) where the grammar is fixed.
- [generate.md](generate.md) — build-time codegen that consumes parser output (e.g. `glance` → custom derivers, `oas` → server stubs).
- [../syntax-highlighting.md](../syntax-highlighting.md) — sibling lexers for colourisation.
