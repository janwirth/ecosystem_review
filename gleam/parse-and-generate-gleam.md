# Parsing and Generating Gleam (the language)

> [!NOTE]
> **Status:** DRAFT · **Authoring:** AI-assisted, human-reviewed.

Gleam-on-Gleam tooling. Two operations on the same language:

1. **Parsing Gleam** — read Gleam source code into a typed AST inside a Gleam program ([glance](#glance), [glance_printer](#glance_printer)).
2. **Generating Gleam** — emit Gleam source from a Gleam DSL ([gleamgen](#gleamgen), [trick](#trick), [glue](#glue), [derived](#derived)).

These primitives are the building blocks for almost every codegen tool in the ecosystem: SQL→Gleam, OpenAPI→Gleam, ser/deser derivers, and so on. Tools whose **input** is a non-Gleam language live in the sibling article [parse-and-generate-other-languages.md](parse-and-generate-other-languages.md); tools whose **output** is encoders/decoders live in [serialization/serialize-and-deserialize.md](serialization/serialize-and-deserialize.md).

## Table of Contents

1. [Summary](#summary)
2. [Discovery](#discovery)
3. [Parsing Gleam](#parsing-gleam)
   - [glance](#glance)
   - [glance_printer](#glance_printer)
4. [Generating Gleam](#generating-gleam)
   - [gleamgen](#gleamgen)
   - [trick](#trick)
   - [glue](#glue)
   - [derived](#derived)
5. [Cross-cutting tools using these primitives](#cross-cutting-tools-using-these-primitives)
6. [Cross-language framing](#cross-language-framing)
7. [Leaderboard](#leaderboard)
8. [Related](#related)

## Summary

**Snapshot 2026-05-07.** Gleam has no macros and no runtime reflection: the only way to do "derive" is to **literally write the Gleam source**. That makes parse-Gleam and emit-Gleam the foundational layer of the codegen ecosystem. The parser side is one mature library plus its pretty-printer companion; the emitter side has four contenders covering different ergonomics.

| Slice | Tools |
| --- | --- |
| [Parsing Gleam](#parsing-gleam) | [glance](#glance), [glance_printer](#glance_printer) |
| [Generating Gleam](#generating-gleam) | [gleamgen](#gleamgen), [trick](#trick), [glue](#glue), [derived](#derived) |

> [!NOTE]
> If you're reading Gleam to highlight it (token stream → coloured output), you want a syntax-highlighter lexer instead — see [syntax-highlighting.md](syntax-highlighting.md). The role-difference is "extract token stream for colourisation" vs "extract AST for analysis/codegen". Use [contour](syntax-highlighting.md) to highlight Gleam; use [glance](#glance) to analyse Gleam.

## Discovery

Searches run on **2026-05-07** against [packages.gleam.run](https://packages.gleam.run/), plus targeted GitHub queries for unpublished tools:

| Query | URL |
| --- | --- |
| `glance` | [packages.gleam.run/?search=glance](https://packages.gleam.run/?search=glance) |
| `parser` | [packages.gleam.run/?search=parser](https://packages.gleam.run/?search=parser) |
| `ast` | [packages.gleam.run/?search=ast](https://packages.gleam.run/?search=ast) |
| `codegen` | [packages.gleam.run/?search=codegen](https://packages.gleam.run/?search=codegen) |
| `generator` | [packages.gleam.run/?search=generator](https://packages.gleam.run/?search=generator) |
| `generate` | [packages.gleam.run/?search=generate](https://packages.gleam.run/?search=generate) |
| `derive` | [packages.gleam.run/?search=derive](https://packages.gleam.run/?search=derive) |
| `printer` | [packages.gleam.run/?search=printer](https://packages.gleam.run/?search=printer) |
| GitHub: `language:gleam codegen` | targeted scan for unpublished tools (e.g. [trick](#trick)) |

Out of scope for this file: per-language syntax-highlighter lexers (→ [syntax-highlighting.md](syntax-highlighting.md)); CLI argument parsers (glint, clip, hoist, glap, sheen); HTML/CSS/PDF document generators (nakai, htmz, paddlefish, glypst) — they emit *output documents*, not Gleam source.

## Parsing Gleam

Gleam libraries that parse Gleam source code into a typed AST you can inspect, transform, and (optionally) re-emit.

| Tool | Role | Stars | Latest commit | Notes |
| --- | --- | --- | --- | --- |
| [glance](#glance) | Gleam source → AST | 80★ · 🟥 | 2025-10-21 | Permissive parser, accepts code the compiler rejects |
| [glance_printer](#glance_printer) | AST → Gleam source | ⬜ | — | Pretty printer; closes the source → AST → source loop |

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

Used as a dependency by [oas_generator](openapi.md#oas_generator), [dusty-phillips/derived](#derived), and others doing source-level codegen.

### glance_printer
[repo](https://github.com/bcpeinhardt/glance_printer)

"A pretty printer for the glance AST." Companion to [glance](#glance) — pairs the parser with a re-emitter, closing the source → AST → source loop required for refactor tools and source-level rewrites.

## Generating Gleam

Libraries that **emit Gleam code** from a Gleam DSL — typically called by build scripts or other codegen tools. These are the primitives downstream tools build on; if you're consuming SQL/OpenAPI/GraphQL and want it as Gleam, see [parse-and-generate-other-languages.md](parse-and-generate-other-languages.md), which uses these libraries under the hood.

| Tool | Input | Output | Stars | Latest commit | Notes |
| --- | --- | --- | --- | --- | --- |
| [gleamgen](#gleamgen) | Gleam DSL (phantom-typed) | Formatted .gleam files | 27★ · 🟨 | — | Type-safe Gleam-emitting Gleam |
| [trick](#trick) | Gleam DSL (elm-codegen-style) | Formatted .gleam files | 12★ · 🟨 | — | Inspired by elm-codegen; not on Hex yet |
| [glue](#glue) | Gleam source (via [glance](#glance)) | Gleam functions in same module | 9★ · 🟥 | 2024-12-08 | `compare`, `list_variants` derivers |
| [derived](#derived) | Gleam source w/ `!derived()` markers | Gleam functions inserted in-place | 2★ · 🟥 | 2025-08-03 | "Code generator's code generator"; framework for custom derivers |

Pick: **gleamgen** for the most-mature DSL with phantom-type guarantees. **trick** if you want elm-codegen ergonomics and don't mind a git dependency. **glue** if you only need the canned `compare`/`list_variants` derivers. **derived** if you want a marker-based round-tripper that's safe to re-run. For **JSON encode/decode codegen** (the most common downstream use of these primitives), see [serialization/serialize-and-deserialize.md → Codegen for ser/deser](serialization/serialize-and-deserialize.md#codegen-for-serdeser).

### gleamgen
[repo](https://github.com/Brewingweasel/gleamgen)

"A package for generating clean, type-checked, and formatted Gleam code!" Phantom-typed builder API — the type system enforces that the generated code typechecks. Removes unused imports, inlines functions, simplifies blocks. Foundational dependency for several other generators in the ecosystem.

### trick
[repo](https://github.com/GearsDatapacks/trick) · [docs](https://gearsco.de/trick/)

"A code generation library for Gleam, based on [elm-codegen](https://github.com/mdgriffith/elm-codegen)." By GearsDatapacks (Surya Rose). Builder API: declare constants, functions, parameters, variables, expressions, and the library prints valid Gleam to a string. Type-checked at the API level.

```gleam
import trick

pub fn main() {
  let pi = trick.constant("pi", trick.float(3.14))

  let radius = trick.parameter("radius", trick.float_type())
  let area = trick.function("circle_area", [radius], fn(radius) {
    trick.expression(
      trick.multiply_float(
        trick.variable(pi),
        trick.multiply_float(trick.variable(radius), trick.variable(radius)),
      ),
    )
  })

  trick.module([pi, area]) |> trick.to_string |> echo
}
```

| Criterion | [trick](https://github.com/GearsDatapacks/trick) |
| --- | --- |
| Stars | 12★ · 🟨 |
| License | not declared in `gleam.toml` (commented `Apache-2.0` placeholder) · 🟥 |
| Target | ☎️📜 Both (pure Gleam codegen) |
| Gleam compat | `gleam_stdlib >= 0.44.0 and < 2.0.0` · 🟩 |
| Maintenance | 🟩 (active development; not yet 1.0-on-Hex) |
| Age | recent · 🟨 |
| README maturity | 🟩🟩 (full guide on gearsco.de/trick with examples) |
| Idiomaticity | 🟩 (typed builder, no magic) |
| Issues | 0 open |
| Distribution | git-only (`{ git = "https://github.com/GearsDatapacks/trick.git", ref = "main" }`) — not on Hex |

> [!NOTE]
> **trick vs gleamgen** — both are typed Gleam-emitting Gleam. `gleamgen` is published, established, and the foundational dependency for several downstream tools; `trick` is newer, elm-codegen-shaped, and currently git-only. Pick `gleamgen` for production today; pick `trick` if its API resonates with your team or if you want elm-codegen ergonomics. Watch trick for a Hex release.

### glue
[repo](https://github.com/lpil/glue)

"A package for generating functions from your Gleam code!" Built-in derivers: `compare` (orderings for custom types) and `list_variants` (list-of-all-variants for sum types). Reads existing Gleam source via [glance](#glance), inserts generated functions. By Louis Pilfold. Last commit 2024-12-08 — usable but not actively-developed.

### derived
[repo](https://github.com/dusty-phillips/derived)

"The gleam code generator's code generator." Marker-based: write `!derived(...)` directives in your Gleam source, run `derived`, and the tool inserts generated code at protected markers (round-trip safe). The framework for building custom derivers — `derived` itself is not a JSON encoder generator, but a tool you compose with [trick](#trick) or [gleamgen](#gleamgen) to build one. Common use cases: serialisation derivers (cross-link → [serialization/serialize-and-deserialize.md](serialization/serialize-and-deserialize.md#codegen-for-serdeser)), validation derivers, documentation derivers. Last commit 2025-08-03.

> [!NOTE]
> **derived appears in two articles.** Here it's covered as a Gleam-emitting framework — the structural piece. In [serialization/serialize-and-deserialize.md](serialization/serialize-and-deserialize.md#codegen-for-serdeser) it's covered as a ser/deser deriver framework — the use-case piece. Both are accurate; pick the article that matches your lens.

## Cross-cutting tools using these primitives

The Gleam-emitting libraries above are the foundation for almost every codegen tool that targets Gleam output. If you're shopping for a tool that consumes some external schema and produces Gleam, you probably want one of these instead:

- **SQL / GraphQL → Gleam.** See [parse-and-generate-other-languages.md → X → Gleam code generation](parse-and-generate-other-languages.md#x--gleam-code-generation) for [squirrel](databases.md#squirrel-), [parrot](parse-and-generate-other-languages.md#parrot), [marmot](parse-and-generate-other-languages.md#marmot), [sqlode](databases.md#sqlode-), [squall](parse-and-generate-other-languages.md#squall) (GraphQL), [embeds](parse-and-generate-other-languages.md#embeds) (static assets). Many of these emit Gleam via [gleamgen](#gleamgen) or [trick](#trick) under the hood.
- **OpenAPI → Gleam.** See [openapi.md](openapi.md) for [oas](openapi.md#oas), [oaspec](openapi.md#oaspec), [gilly](openapi.md#gilly), [oas_generator](openapi.md#oas_generator).
- **Codegen for ser/deser.** See [serialization/serialize-and-deserialize.md → Codegen for ser/deser](serialization/serialize-and-deserialize.md#codegen-for-serdeser) for [json_typedef](serialization/serialize-and-deserialize.md), [gserde](serialization/serialize-and-deserialize.md), [glerd_json](serialization/serialize-and-deserialize.md), [aide_generator](serialization/serialize-and-deserialize.md). These tools emit encoders/decoders rather than general Gleam, but they share the same emit-and-commit pipeline.
- **SQL → Gleam in depth.** [databases.md → SQL Code Generators](databases.md#sql-code-generators) has the deepest comparison for the SQL slice (squirrel vs parrot vs sqlode vs marmot).

## Cross-language framing

How Gleam's build-time codegen story compares to other ecosystems.

| Language | Build-time codegen story | Trade-off |
| --- | --- | --- |
| **Gleam** | Explicit codegen tools that emit `.gleam` files; no macros, no compiler plugins. Build-script driven (`gleam run -m <tool>`), output committed to repo. | Outputs are auditable and grep-able. Requires running the tool whenever the input changes — CI drift check needed (e.g. [oaspec --check](openapi.md#oaspec)). |
| **Rust** | Procedural macros (`#[derive(...)]`) and `build.rs`. Macros expand at compile time, output not visible by default. | Zero runtime overhead, terse source. Generated code invisible without `cargo expand`. |
| **OCaml** | PPX rewriters (preprocessor extensions) — `[@@deriving show, eq]`. | Similar to Rust macros; output via `dune describe`. |
| **TypeScript** | Code generators that emit `.ts` files (graphql-codegen, openapi-typescript, prisma generate). Pattern is **identical** to Gleam's — committed, build-step driven, drift-checkable in CI. | TypeScript is the closest analogue ergonomically. The Gleam ecosystem is converging on the same conventions. |
| **Go** | `go:generate` directives + `go generate` — emits committed `.go` files. Same pattern as Gleam. | Excellent for codegen; less common than struct tags for de/serialization. |
| **Java** | Annotation processors (`@Generated`); Lombok-style transformations. | Generated code merged into compile units, often not committed. |
| **Elm** | [elm-codegen](https://github.com/mdgriffith/elm-codegen) is the reference for typed-builder Gleam-codegen — explicitly inspires [trick](#trick) (and indirectly the gleamgen design space). | Explicit, typed, library-driven; Elm has no macros either. |

The Gleam codegen story sits closest to **TypeScript** and **Go**: emit-and-commit, build-step driven, no compiler magic. This is a deliberate consequence of Gleam having [no macros](https://github.com/gleam-lang/gleam/issues/1767) and no runtime reflection — the only way to do "derive" is to **literally write the Gleam source**.

The same constraint is what makes the **Gleam → spec** direction (e.g. handler types → OpenAPI) hard: there is no inspection mechanism short of parsing the source via [glance](#glance). See [openapi.md](openapi.md#gleam--openapi-code-first-spec-generation) for the full discussion.

## Leaderboard

### Gleam → Gleam generators

| Position | Award | Repo | Output | ★ | Lic | Compat | Maint | Age | README | Idiom | Score |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 🥇 | [Brewingweasel/gleamgen](https://github.com/Brewingweasel/gleamgen) | Gleam (DSL) | 🟨 | 🟨 | 🟩 | 🟩 | 🟩 | 🟩🟩 | 🟩 | **6** |
| 2 | 🥈 | [GearsDatapacks/trick](https://github.com/GearsDatapacks/trick) | Gleam (elm-codegen-style) | 🟨 | 🟥 | 🟩 | 🟩 | 🟨 | 🟩🟩 | 🟩 | **5** |
| 3 | 🥉 | [dusty-phillips/derived](https://github.com/dusty-phillips/derived) | Custom (markers) | 🟥 | 🟩 | 🟩 | 🟩 | 🟩 | 🟩 | 🟩 | **5** |
| 4 | — | [lpil/glue](https://github.com/lpil/glue) | Gleam (`compare`, etc.) | 🟥 | 🟨 | 🟩 | 🟨 | 🟩 | 🟩 | 🟩 | **3** |

> [!NOTE]
> Codegen tools whose **primary output is encoders/decoders** ([json_typedef](serialization/serialize-and-deserialize.md#codegen-for-serdeser), [gserde](serialization/serialize-and-deserialize.md#codegen-for-serdeser), [glerd_json](serialization/serialize-and-deserialize.md#codegen-for-serdeser)) have their own leaderboard at [serialization/serialize-and-deserialize.md → Codegen for ser/deser](serialization/serialize-and-deserialize.md#codegen-for-serdeser). Codegen tools whose **input is a non-Gleam language** ([squirrel](databases.md#squirrel-), [parrot](parse-and-generate-other-languages.md#parrot), [oaspec](openapi.md#oaspec), etc.) have their own leaderboard at [parse-and-generate-other-languages.md → X → Gleam code generation](parse-and-generate-other-languages.md#x--gleam-code-generation) and [openapi.md → Leaderboard](openapi.md#leaderboard).

[How scores are calculated →](databases.md#scoring-dimensions)

## Related

- [parse-and-generate-other-languages.md](parse-and-generate-other-languages.md) — parsers for non-Gleam input (SQL, JSON Schema, etc.) and codegen tools that emit Gleam from those inputs (squirrel, parrot, marmot, sqlode, squall, embeds).
- [openapi.md](openapi.md) — OpenAPI-specific corner: `oas` parser, OpenAPI → Gleam codegen (oaspec, gilly, oas_generator), and the **Gleam → OpenAPI gap**.
- [serialization/serialize-and-deserialize.md](serialization/serialize-and-deserialize.md) — runtime ser/deser, codegen for encoders/decoders (json_typedef, gserde, glerd_json, aide_generator).
- [databases.md](databases.md#sql-code-generators) — squirrel vs sqlode vs parrot vs marmot in depth.
- [syntax-highlighting.md](syntax-highlighting.md) — sibling lexers for tokenising Gleam source for colourisation (different role than glance: token stream vs AST).
