# Parse & generate: other languages

> [!NOTE]
> **Status:** DRAFT · **Authoring:** AI-assisted, human-reviewed.

**Snapshot 2026-05-07.** Tools whose **input is a non-Gleam language**: parser combinators for hand-rolled grammars, format-specific parsers (TOML, Markdown, CSV, XML, CEL), HTML parsers, SQL/GraphQL parsers, and codegen tools that consume those inputs to **emit Gleam source code**.

This article has two halves:

1. **Runtime parsing of other-language text** — combinators, format parsers, HTML parsers. Output is a typed Gleam value at runtime.
2. **Build-time codegen consuming external schemas** — SQL → Gleam, GraphQL → Gleam, static-asset embedding. Output is committed `.gleam` source.

For tools that parse Gleam itself or emit Gleam from a Gleam-shaped DSL, see [parse-and-generate-gleam.md](parse-and-generate-gleam.md). For codegen tools whose primary output is encoders/decoders (`json_typedef`, `gserde`, `glerd_json`, `aide_generator`) and the runtime ser/deser story (`gleam_json`, `protozoa`, `gleam_erlang_cbor`), see [serialization/serialize-and-deserialize.md](serialization/serialize-and-deserialize.md). For OpenAPI specifically (parser library, spec→Gleam codegen, Gleam→spec gap), see [openapi.md](openapi.md).

## Table of Contents

1. [Discovery](#discovery)
2. [Parser combinator toolkits](#parser-combinator-toolkits)
3. [Data-format parsers](#data-format-parsers)
4. [HTML parsers](#html-parsers)
5. [String-slicing primitives](#string-slicing-primitives)
6. [X → Gleam code generation](#x--gleam-code-generation)
   - [SQL → Gleam](#sql--gleam)
   - [Other → Gleam](#other--gleam)
7. [Gaps](#gaps)
   - [gRPC / Protobuf codegen](#grpc--protobuf-codegen)
   - [Codegen for ser/deser (cross-link)](#codegen-for-serdeser-cross-link)
   - [OpenAPI (cross-link)](#openapi-cross-link)
8. [Cross-language framing](#cross-language-framing)
9. [Leaderboards](#leaderboards)
10. [Related](#related)

[How scores are calculated →](databases.md#scoring-dimensions)

## Discovery

Searches run on **2026-05-07** against [packages.gleam.run](https://packages.gleam.run/), plus targeted GitHub queries.

| Query | URL |
| --- | --- |
| `parser` | [packages.gleam.run/?search=parser](https://packages.gleam.run/?search=parser) |
| `combinator` | [packages.gleam.run/?search=combinator](https://packages.gleam.run/?search=combinator) |
| `lexer` | [packages.gleam.run/?search=lexer](https://packages.gleam.run/?search=lexer) |
| `parse` | [packages.gleam.run/?search=parse](https://packages.gleam.run/?search=parse) |
| `html` | [packages.gleam.run/?search=html](https://packages.gleam.run/?search=html) |
| `xml` | [packages.gleam.run/?search=xml](https://packages.gleam.run/?search=xml) |
| `markdown` | [packages.gleam.run/?search=markdown](https://packages.gleam.run/?search=markdown) |
| `toml` | [packages.gleam.run/?search=toml](https://packages.gleam.run/?search=toml) |
| `csv` | [packages.gleam.run/?search=csv](https://packages.gleam.run/?search=csv) |
| `regex` | [packages.gleam.run/?search=regex](https://packages.gleam.run/?search=regex) |
| `tree-sitter` | [packages.gleam.run/?search=tree-sitter](https://packages.gleam.run/?search=tree-sitter) (0 hits) |
| `sql` | [packages.gleam.run/?search=sql](https://packages.gleam.run/?search=sql) |
| `schema` | [packages.gleam.run/?search=schema](https://packages.gleam.run/?search=schema) |
| `graphql` | [packages.gleam.run/?search=graphql](https://packages.gleam.run/?search=graphql) |
| `protobuf` | [packages.gleam.run/?search=protobuf](https://packages.gleam.run/?search=protobuf) (lib only — no codegen) |
| `grpc` | [packages.gleam.run/?search=grpc](https://packages.gleam.run/?search=grpc) (no hits) |
| `embed` | [packages.gleam.run/?search=embed](https://packages.gleam.run/?search=embed) |
| `codegen` | [packages.gleam.run/?search=codegen](https://packages.gleam.run/?search=codegen) |
| `generator` | [packages.gleam.run/?search=generator](https://packages.gleam.run/?search=generator) |
| `generate` | [packages.gleam.run/?search=generate](https://packages.gleam.run/?search=generate) |
| GitHub: `language:gleam codegen` | targeted scan for unpublished tools |

Out of scope for this file: Gleam-source parsers and Gleam-emitting Gleam DSLs (→ [parse-and-generate-gleam.md](parse-and-generate-gleam.md)); per-language syntax-highlighter lexers (→ [syntax-highlighting.md](syntax-highlighting.md)); CLI argument parsers (glint, clip, hoist, glap, sheen); HTML/CSS/PDF/Typst document generators (nakai, htmz, paddlefish, glypst, sketch_css); UUID / NanoID / identicon value generators.

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
| [mork](#mork) | Markdown | ⬜ (self-hosted) | — | Markdown parser; repo on liten.app (gated by Anubis, no public metrics) |
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

### mork
[repo](https://git.liten.app/krig/mork)

Markdown parser hosted on liten.app, a self-hosted Git instance gated by Anubis. WebFetch returns the access-denied page, so star count, license, and commit dates render as ⬜. The Hex package exists; check the repo directly via browser if you need to evaluate.

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

## X → Gleam code generation

Build-time tools that take an external schema or query (SQL, GraphQL, static asset directory) and **emit Gleam source code**. The output is `.gleam` files that you commit to your repo.

| Slice | Tools |
| --- | --- |
| [SQL → Gleam](#sql--gleam) | [squirrel](databases.md#squirrel-) 🐘, [parrot](#parrot) 🐘🪶🐬, [marmot](#marmot) 🪶, [sqlode](databases.md#sqlode-) 🐘🪶🐬 |
| [Other → Gleam](#other--gleam) | [squall](#squall) (GraphQL), [embeds](#embeds) (static assets) |
| OpenAPI → Gleam | → [openapi.md](openapi.md#openapi--gleam-codegen) |
| Codegen for ser/deser | → [serialization/serialize-and-deserialize.md → Codegen for ser/deser](serialization/serialize-and-deserialize.md#codegen-for-serdeser) |

> [!NOTE]
> **Codegen tools whose primary output is encoders/decoders** — `gserde`, `json_typedef`, `glerd_json`, `aide_generator` — live in [serialization/serialize-and-deserialize.md → Codegen for ser/deser](serialization/serialize-and-deserialize.md#codegen-for-serdeser). They share infrastructure with the tools below (often using `gleamgen` or `glance` under the hood) but are decision-shaped around the ser/deser problem.

> [!NOTE]
> **OpenAPI tools** — the [oas](openapi.md#oas) parser, [oaspec](openapi.md#oaspec), [gilly](openapi.md#gilly), and [oas_generator](openapi.md#oas_generator) codegen tools, plus the Gleam → OpenAPI gap — all live in [openapi.md](openapi.md).

### SQL → Gleam

> [!NOTE]
> [databases.md → SQL Code Generators](databases.md#sql-code-generators) covers these in depth, with a comparison table for **squirrel vs sqlode** and the canonical code examples. The squirrel and sqlode reviews live there; **parrot** and **marmot** get full coverage in *both* articles (this one and databases.md), with cross-link callouts in each direction.

Quick map:

| Tool | Dialects | Style | Stars | Notes |
| --- | --- | --- | --- | --- |
| [squirrel](databases.md#squirrel-) 🐘 | PostgreSQL 16+ | `.sql` files → typed Gleam decoders | 633★ | Established, FOSDEM-talked, tight pog integration. Full review in [databases.md](databases.md#squirrel-). |
| [parrot](#parrot) 🐘🪶🐬 | PostgreSQL · SQLite · MySQL | sqlc plugin → typed Gleam | 207★ | sqlc-backed (renamed from `sqlc-gen-gleam`) |
| [sqlode](databases.md#sqlode-) 🐘🪶🐬 | PostgreSQL · SQLite · MySQL 8 | sqlc-style schema + queries → typed Gleam | 3★ | Brand new (Apr 2026), driver-agnostic at codegen. Full review in [databases.md](databases.md#sqlode-). |
| [marmot](#marmot) 🪶 | SQLite | `.sql` files → typed functions | 2★ | Inspired by squirrel, SQLite-only |

#### parrot
[repo](https://github.com/daniellionel01/parrot) (renamed from `sqlc-gen-gleam`)

"🦜 type-safe SQL in gleam." A sqlc plugin: leverages sqlc's mature SQL parser/codegen pipeline and emits Gleam. Supports SQLite, PostgreSQL, and MySQL. Auto-downloads the sqlc binary; processes `src/sql/` files; outputs a unified `sql.gleam` module. README explicitly credits sqlc: *"Most of the heavy lifting features are provided by / built into sqlc, I do not aim to take credit for them."* Different from squirrel (which has its own PostgreSQL parser) and from [sqlode](databases.md#sqlode-) (which writes its own multi-dialect codegen).

| Criterion | [parrot](https://github.com/daniellionel01/parrot) |
| --- | --- |
| Stars | 207★ · 🟩🟩 |
| License | Apache-2.0 · 🟩 |
| Target | ☎️ BEAM (codegen + generated code) |
| Gleam compat | `gleam_stdlib >= 0.34.0 and < 2.0.0` · 🟩 |
| Maintenance | 🟩 (last commit 2026-02-03) |
| Age | ~1 year · 🟩 |
| README maturity | 🟩🟩 (multi-DB walkthrough, sqlc integration, examples) |
| Idiomaticity | 🟩 (explicit codegen, sqlc-backed) |
| Issues | 3 open |

> [!NOTE]
> parrot is also reviewed in [databases.md → SQL Code Generators](databases.md#sql-code-generators) under the database lens. The 7-dim score is the same in both places; cross-link kept in both directions so readers find the matching review either way.

#### marmot
[repo](https://github.com/pairshaped/marmot)

"Type-safe SQL for SQLite in Gleam. Write `.sql` files, generate typed functions." Inspired by squirrel, focused on SQLite. Brand new — small star count, but fills the SQLite-codegen gap left by squirrel (which is PostgreSQL-only). Last commit 2026-04-21.

| Criterion | [marmot](https://github.com/pairshaped/marmot) |
| --- | --- |
| Stars | 2★ · 🟥 |
| License | MIT · 🟩 |
| Target | ☎️ BEAM (SQLite via [sqlight](databases.md#sqlight-)) |
| Maintenance | 🟩🟩 (last commit 2026-04-21) |
| Age | ~1 month · 🟥 |
| README maturity | 🟩🟩 (squirrel-style guide, examples) |
| Idiomaticity | 🟩 |
| Issues | 0 open |

> [!NOTE]
> marmot is also reviewed in [databases.md → SQL Code Generators](databases.md#sql-code-generators) under the database lens. The 7-dim score is the same in both places; cross-link kept in both directions.

### Other → Gleam

#### squall
[repo](https://github.com/bigmoves/squall)

"Type-safe GraphQL client generator." Generates Gleam client code from GraphQL schemas + queries. Out of scope for in-depth review at this snapshot; warrants a dedicated GraphQL article when the corner grows.

#### embeds
[repo](https://github.com/arkandos/gleam-embeds)

"Generate Gleam modules based on static assets." Bake files (HTML, CSS, images, anything) into compiled Gleam modules at build time. Adjacent to codegen — emits Gleam constants holding asset bytes rather than functional code.

## Gaps

### gRPC / Protobuf codegen

**Gap.** No published Gleam package emits Gleam code from `.proto` definitions, and no Gleam gRPC server framework exists. **Workaround:** generate Erlang stubs with `protoc` + `grpcbox` and call them from Gleam. Runtime-only Protobuf coverage exists via [protozoa](serialization/serialize-and-deserialize.md#protozoa) — cross-link to [serialization/serialize-and-deserialize.md](serialization/serialize-and-deserialize.md) for the runtime ser/deser story.

### Codegen for ser/deser (cross-link)

Several X→Gleam codegen tools exist whose primary output is **encoders/decoders** rather than business-logic types or HTTP clients:

- **[json_typedef](serialization/serialize-and-deserialize.md#json_typedef)** — consumes RFC 8927 JSON Type Definition documents and emits Gleam types + encoders + decoders.
- **[gserde](serialization/serialize-and-deserialize.md#gserde)** — derives JSON encoders/decoders from Gleam type definitions.
- **[glerd_json](serialization/serialize-and-deserialize.md#glerd_json)** — JSON ser/deser derivation.
- **[aide_generator](serialization/serialize-and-deserialize.md#aide_generator)** — emits encoders + decoders for MCP tool schemas.

These are "X→Gleam" too, but they're decision-shaped around the ser/deser problem, so they live in [serialization/serialize-and-deserialize.md → Codegen for ser/deser](serialization/serialize-and-deserialize.md#codegen-for-serdeser).

For runtime JSON-Schema *validation* (without codegen), see [serialization/serialize-and-deserialize.md](serialization/serialize-and-deserialize.md) — castor, jscheam, sextant.

### OpenAPI (cross-link)

The [oas](openapi.md#oas) parser, [oaspec](openapi.md#oaspec) / [gilly](openapi.md#gilly) / [oas_generator](openapi.md#oas_generator) codegen tools, and the **Gleam → OpenAPI gap** all live in [openapi.md](openapi.md). The reverse direction — **Gleam → spec** (e.g. mist/wisp routes → OpenAPI document) is **not covered by any package** as of snapshot. See [openapi.md](openapi.md#gleam--openapi-code-first-spec-generation) for the structural reason and workarounds.

## Cross-language framing

How Gleam's build-time codegen story compares.

| Language | Build-time codegen story | Trade-off |
| --- | --- | --- |
| **Gleam** | Explicit codegen tools that emit `.gleam` files; no macros, no compiler plugins. Build-script driven (`gleam run -m <tool>`), output committed to repo. | Outputs are auditable and grep-able. Requires running the tool whenever the input changes — CI drift check needed (e.g. [oaspec --check](#oaspec)). |
| **Rust** | Procedural macros (`#[derive(...)]`) and `build.rs`. Macros expand at compile time, output not visible by default. | Zero runtime overhead, terse source. Generated code invisible without `cargo expand`. |
| **OCaml** | PPX rewriters (preprocessor extensions) — `[@@deriving show, eq]`. | Similar to Rust macros; output via `dune describe`. |
| **TypeScript** | Code generators that emit `.ts` files (graphql-codegen, openapi-typescript, prisma generate). Pattern is **identical** to Gleam's — committed, build-step driven, drift-checkable in CI. | TypeScript is the closest analogue ergonomically. The Gleam ecosystem is converging on the same conventions. |
| **Go** | `go:generate` directives + `go generate` — emits committed `.go` files. Same pattern as Gleam. | Excellent for codegen; less common than struct tags for de/serialization. |
| **Java** | Annotation processors (`@Generated`); Lombok-style transformations. | Generated code merged into compile units, often not committed. |
| **Elm** | [elm-codegen](https://github.com/mdgriffith/elm-codegen) is the reference for typed-builder Gleam-codegen — explicitly inspires [trick](parse-and-generate-gleam.md#trick) (and indirectly the gleamgen design space). | Explicit, typed, library-driven; Elm has no macros either. |

The Gleam codegen story sits closest to **TypeScript** and **Go**: emit-and-commit, build-step driven, no compiler magic. This is a deliberate consequence of Gleam having [no macros](https://github.com/gleam-lang/gleam/issues/1767) and no runtime reflection — the only way to do "derive" is to **literally write the Gleam source**.

The same constraint is what makes the **Gleam → spec** direction (e.g. handler types → OpenAPI) hard: there is no inspection mechanism short of parsing the source via [glance](parse-and-generate-gleam.md#glance). See [openapi.md](openapi.md#gleam--openapi-code-first-spec-generation) for the full discussion.

## Leaderboards

[How scores are calculated →](databases.md#scoring-dimensions)

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

### X → Gleam generators (combined)

Includes SQL, GraphQL, static-asset embedding. Cross-reference: [databases.md leaderboard](databases.md#leaderboard) covers SQL codegen alongside drivers and migrations. OpenAPI codegen has its own leaderboard in [openapi.md](openapi.md#leaderboard). Codegen tools whose output is encoders/decoders (json_typedef RFC 8927, aide_generator MCP) have their own leaderboard in [serialization/serialize-and-deserialize.md → Codegen for ser/deser](serialization/serialize-and-deserialize.md#codegen-for-serdeser).

| Position | Award | Repo | Input | ★ | Lic | Compat | Maint | Age | README | Idiom | Score |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 🥇 | [giacomocavalieri/squirrel](https://github.com/giacomocavalieri/squirrel) | SQL (PostgreSQL) | 🟩🟩 | 🟩 | 🟩 | 🟩 | 🟩 | 🟩🟩 | 🟩 | **9** |
| 2 | 🥈 | [daniellionel01/parrot](https://github.com/daniellionel01/parrot) | SQL (sqlc; multi-DB) | 🟩🟩 | 🟩 | 🟩 | 🟩 | 🟩 | 🟩🟩 | 🟩 | **9** |
| 3 | 🥉 | [pairshaped/marmot](https://github.com/pairshaped/marmot) | SQL (SQLite) | 🟥 | 🟩 | 🟩 | 🟩🟩 | 🟥 | 🟩🟩 | 🟩 | **5** |
| 4 | — | [nao1215/sqlode](https://github.com/nao1215/sqlode) | SQL (multi-DB) | 🟥 | 🟩 | 🟩 | 🟩🟩 | 🟥 | 🟩🟩 | 🟩 | **5** |

### Honorable mentions

- **[squirrel](https://github.com/giacomocavalieri/squirrel)** — the established SQL→Gleam codegen, FOSDEM-talked, 633★. The reference implementation other tools cite. Full review in [databases.md](databases.md#squirrel-).
- **[parrot](https://github.com/daniellionel01/parrot)** — sqlc-backed, multi-DB, 207★. Renamed from `sqlc-gen-gleam`.
- **OpenAPI codegen** — [oaspec](openapi.md#oaspec), [gilly](openapi.md#gilly), [oas_generator](openapi.md#oas_generator). Covered in [openapi.md](openapi.md).
- **[json_typedef](serialization/serialize-and-deserialize.md#json_typedef)**, **[gserde](serialization/serialize-and-deserialize.md#gserde)**, **[aide_generator](serialization/serialize-and-deserialize.md#aide_generator)** — covered in [serialization/serialize-and-deserialize.md](serialization/serialize-and-deserialize.md#codegen-for-serdeser) as ser/deser-specific codegen.

## Related

- [parse-and-generate-gleam.md](parse-and-generate-gleam.md) — sibling article: Gleam-source parsers (glance, glance_printer) and Gleam-emitting Gleam DSLs (gleamgen, trick, glue, derived).
- [openapi.md](openapi.md) — the OpenAPI corner: parser library (oas), spec→Gleam codegen (oaspec, gilly, oas_generator), and the Gleam → OpenAPI gap.
- [serialization/serialize-and-deserialize.md](serialization/serialize-and-deserialize.md) — runtime ser/deser (gleam_json, protozoa, gleam_erlang_cbor), codegen for encoders/decoders (json_typedef, gserde, glerd_json, aide_generator).
- [databases.md](databases.md#sql-code-generators) — squirrel and sqlode in depth (this article cross-links there to avoid duplication); parrot and marmot reviewed in both places.
- [syntax-highlighting.md](syntax-highlighting.md) — sibling lexers for colourisation (per-language lexers used as highlighter input vs parsing for AST/analysis).
- [../postman-to-openapi-converters.md](../postman-to-openapi-converters.md) — adjacent: converting Postman collections to OpenAPI specs (precedes the OpenAPI → Gleam pipeline).
