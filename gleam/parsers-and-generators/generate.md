# Code generators in Gleam

> [!NOTE]
> **Status:** DRAFT · **Authoring:** AI-assisted, human-reviewed.

Build-time tools that take an input artifact (Gleam source, SQL, OpenAPI, JSON Schema, etc.) and **emit Gleam source code**. Two shapes:

1. **Gleam → Gleam** — a Gleam DSL describes the code you want and the tool prints it. ([gleamgen](#gleamgen), [glue](#glue), [derived](#derived), [trick](#trick).)
2. **X → Gleam** — an external schema or query (SQL, OpenAPI, GraphQL) drives the codegen. ([squirrel](../databases.md#squirrel-), [parrot](#parrot), [marmot](#marmot), [sqlode](../databases.md#sqlode-), [oaspec](#oaspec), [gilly](#gilly), [oas_generator](#oas_generator), [embeds](#embeds), [squall](#squall).)

> [!NOTE]
> **Codegen tools whose primary output is encoders/decoders** — `gserde`, `json_typedef`, `glerd_json`, `aide_generator` — live in [serialize.md → Codegen for ser/deser](serialize.md#codegen-for-serdeser). They share infrastructure with the tools below (often using `gleamgen` or `glance` under the hood) but are decision-shaped around the ser/deser problem.

For runtime parsing of grammars, see [parse.md](parse.md). For the missing **Gleam → spec** direction (code-first OpenAPI), see [serialize.md](serialize.md#gleam--openapi-code-first-spec-generation).

## Table of Contents

1. [Summary](#summary)
2. [Discovery](#discovery)
3. [Gleam → Gleam generators](#gleam--gleam-generators)
4. [SQL → Gleam](#sql--gleam)
5. [OpenAPI → Gleam](#openapi--gleam)
6. [Other → Gleam](#other--gleam)
7. [Cross-language framing](#cross-language-framing)
8. [Leaderboards](#leaderboards)

## Summary

**Snapshot 2026-04-26.** Code generation is one of the more active corners of the Gleam ecosystem. The biggest, most-actively-developed slice is X→Gleam (SQL and OpenAPI codegen).

| Slice | Tools |
| --- | --- |
| [Gleam → Gleam](#gleam--gleam-generators) | [gleamgen](#gleamgen), [glue](#glue), [derived](#derived), **[trick](#trick)** |
| [SQL → Gleam](#sql--gleam) | [squirrel](../databases.md#squirrel-) 🐘, [parrot](#parrot) 🐘🪶🐬, [marmot](#marmot) 🪶, [sqlode](../databases.md#sqlode-) 🐘🪶🐬 |
| [OpenAPI → Gleam](#openapi--gleam) | [oaspec](#oaspec), [gilly](#gilly), [oas_generator](#oas_generator) |
| [Other → Gleam](#other--gleam) | [squall](#squall) (GraphQL), [embeds](#embeds) (static assets) |
| Codegen for ser/deser | → [serialize.md](serialize.md#codegen-for-serdeser) ([json_typedef](serialize.md#json_typedef), [gserde](serialize.md#gserde), [glerd_json](serialize.md#glerd_json), [aide_generator](serialize.md#aide_generator)) |

> [!IMPORTANT]
> The reverse direction — **Gleam → spec** (e.g. mist/wisp routes → OpenAPI document) is **not covered by any package** as of snapshot. See [serialize.md](serialize.md#gleam--openapi-code-first-spec-generation) for the structural reason and workarounds.

## Discovery

Searches run on **2026-04-26** against [packages.gleam.run](https://packages.gleam.run/), plus targeted GitHub queries:

| Query | URL |
| --- | --- |
| `codegen` | [packages.gleam.run/?search=codegen](https://packages.gleam.run/?search=codegen) |
| `generator` | [packages.gleam.run/?search=generator](https://packages.gleam.run/?search=generator) |
| `generate` | [packages.gleam.run/?search=generate](https://packages.gleam.run/?search=generate) |
| `derive` | [packages.gleam.run/?search=derive](https://packages.gleam.run/?search=derive) |
| `openapi` | [packages.gleam.run/?search=openapi](https://packages.gleam.run/?search=openapi) |
| `swagger` | [packages.gleam.run/?search=swagger](https://packages.gleam.run/?search=swagger) |
| `sql` | [packages.gleam.run/?search=sql](https://packages.gleam.run/?search=sql) |
| `schema` | [packages.gleam.run/?search=schema](https://packages.gleam.run/?search=schema) |
| `graphql` | [packages.gleam.run/?search=graphql](https://packages.gleam.run/?search=graphql) |
| `protobuf` | [packages.gleam.run/?search=protobuf](https://packages.gleam.run/?search=protobuf) (lib only — no codegen) |
| `grpc` | [packages.gleam.run/?search=grpc](https://packages.gleam.run/?search=grpc) (no hits) |
| `mcp` | [packages.gleam.run/?search=mcp](https://packages.gleam.run/?search=mcp) |
| `embed` | [packages.gleam.run/?search=embed](https://packages.gleam.run/?search=embed) |
| GitHub: `language:gleam codegen` | targeted scan for unpublished tools (e.g. [trick](#trick)) |

Out of scope: HTML/CSS/PDF/Typst document generators (nakai, htmz, paddlefish, glypst, sketch_css) — they generate output documents, not Gleam source code; UUID/NanoID/identicon generators — value generators.

## Gleam → Gleam generators

Libraries that **emit Gleam code** from Gleam — typically called by build scripts or other codegen tools.

| Tool | Input | Output | Stars | Latest commit | Notes |
| --- | --- | --- | --- | --- | --- |
| [gleamgen](#gleamgen) | Gleam DSL (phantom-typed) | Formatted .gleam files | 27★ · 🟨 | — | Type-safe Gleam-emitting Gleam |
| [trick](#trick) | Gleam DSL (elm-codegen-style) | Formatted .gleam files | 12★ · 🟨 | — | Inspired by elm-codegen; not on Hex yet |
| [glue](#glue) | Gleam source (via [glance](parse.md#glance)) | Gleam functions in same module | 9★ · 🟥 | 2024-12-08 | `compare`, `list_variants` derivers |
| [derived](#derived) | Gleam source w/ `!derived()` markers | Gleam functions inserted in-place | 2★ · 🟥 | 2025-08-03 | "Code generator's code generator"; framework for custom derivers |

Pick: **gleamgen** for the most-mature DSL with phantom-type guarantees. **trick** if you want elm-codegen ergonomics and don't mind a git dependency. **glue** if you only need the canned `compare`/`list_variants` derivers. **derived** if you want a marker-based round-tripper. For **JSON encode/decode codegen** (the most common downstream use of these primitives), see [serialize.md → Codegen for ser/deser](serialize.md#codegen-for-serdeser).

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

"A package for generating functions from your Gleam code!" Built-in derivers: `compare` (orderings for custom types) and `list_variants` (list-of-all-variants for sum types). Reads existing Gleam source via [glance](parse.md#glance), inserts generated functions. By Louis Pilfold. Last commit 2024-12-08 — usable but not actively-developed.

### derived
[repo](https://github.com/dusty-phillips/derived)

"The gleam code generator's code generator." Marker-based: write `!derived(...)` directives in your Gleam source, run `derived`, and the tool inserts generated code at protected markers (round-trip safe). The framework for building custom derivers — `derived` itself is not a JSON encoder generator, but a tool you compose with [trick](#trick) or [gleamgen](#gleamgen) to build one. Common use cases: serialisation derivers (cross-link → [serialize.md](serialize.md#codegen-for-serdeser)), validation derivers, documentation derivers. Last commit 2025-08-03.

## SQL → Gleam

Cross-link: [../databases.md → SQL Code Generators](../databases.md#sql-code-generators) covers these in depth, with a comparison table for **squirrel vs sqlode**. Quick map:

| Tool | Dialects | Style | Stars | Notes |
| --- | --- | --- | --- | --- |
| [squirrel](../databases.md#squirrel-) 🐘 | PostgreSQL 16+ | `.sql` files → typed Gleam decoders | 633★ | Established, FOSDEM-talked, tight pog integration |
| [parrot](#parrot) 🐘🪶🐬 | PostgreSQL · SQLite · MySQL | sqlc plugin → typed Gleam | 206★ | sqlc-backed (renamed from `sqlc-gen-gleam`) |
| [sqlode](../databases.md#sqlode-) 🐘🪶🐬 | PostgreSQL · SQLite · MySQL 8 | sqlc-style schema + queries → typed Gleam | 3★ | Brand new (Apr 2026), driver-agnostic at codegen |
| [marmot](#marmot) 🪶 | SQLite | `.sql` files → typed functions | 2★ | Inspired by squirrel, SQLite-only |

### parrot
[repo](https://github.com/daniellionel01/parrot) (renamed from `sqlc-gen-gleam`)

"🦜 type-safe SQL in gleam." A sqlc plugin: leverages sqlc's mature SQL parser/codegen pipeline and emits Gleam. Supports SQLite, PostgreSQL, and MySQL. Auto-downloads the sqlc binary; processes `src/sql/` files; outputs a unified `sql.gleam` module. README explicitly credits sqlc: *"Most of the heavy lifting features are provided by / built into sqlc, I do not aim to take credit for them."* Different from squirrel (which has its own PostgreSQL parser) and from [sqlode](../databases.md#sqlode-) (which writes its own multi-dialect codegen).

| Criterion | [parrot](https://github.com/daniellionel01/parrot) |
| --- | --- |
| Stars | 206★ · 🟩🟩 |
| License | Apache-2.0 · 🟩 |
| Target | ☎️ BEAM (codegen + generated code) |
| Gleam compat | `gleam_stdlib >= 0.34.0 and < 2.0.0` · 🟩 |
| Maintenance | 🟩 (last commit 2026-02-03) |
| Age | ~1 year · 🟩 |
| README maturity | 🟩🟩 (multi-DB walkthrough, sqlc integration, examples) |
| Idiomaticity | 🟩 (explicit codegen, sqlc-backed) |
| Issues | 3 open |

### marmot
[repo](https://github.com/pairshaped/marmot)

"Type-safe SQL for SQLite in Gleam. Write `.sql` files, generate typed functions." Inspired by squirrel, focused on SQLite. Brand new — small star count, but fills the SQLite-codegen gap left by squirrel (which is PostgreSQL-only). Last commit 2026-04-21.

| Criterion | [marmot](https://github.com/pairshaped/marmot) |
| --- | --- |
| Stars | 2★ · 🟥 |
| License | MIT · 🟩 |
| Target | ☎️ BEAM (SQLite via [sqlight](../databases.md#sqlight-)) |
| Maintenance | 🟩🟩 (last commit 2026-04-21, ~5 days vs snapshot) |
| Age | ~1 month · 🟥 |
| README maturity | 🟩🟩 (squirrel-style guide, examples) |
| Idiomaticity | 🟩 |
| Issues | 0 open |

## OpenAPI → Gleam

Three tools cover this corner. Both [oaspec](#oaspec) and [gilly](#gilly) are very young (Apr 2026) but ship usable code today; [oas_generator](#oas_generator) is older, built on [oas](parse.md#oas).

### Comparison

| Criterion | [oaspec](https://github.com/nao1215/oaspec) | [gilly](https://github.com/cyclimse/gilly) | [oas_generator](https://github.com/crowdhailer/oas_generator) |
| --- | --- | --- | --- |
| Stars | 4★ · 🟥 | 1★ · 🟥 | 25★ · 🟨 |
| License | MIT · 🟩 | Unlicense (public domain) · 🟩 | Apache-2.0 · 🟩 |
| Target | ☎️ BEAM | ☎️ BEAM | ☎️📜 Both (uses gleam/httpc + gleam/fetch) |
| Gleam compat | `>= 0.44 and < 2.0` · 🟩 | `>= 0.44 and < 2.0` · 🟩 | unspecified (no gleam constraint) · 🟨 |
| Maintenance | 🟩🟩 (last commit 2026-04-26, snapshot day) | 🟩🟩 (last commit 2026-04-19, 1 wk) | 🟩🟩 (last commit 2026-04-16, ~10 days) |
| Age | ~3 weeks (Apr 7, 2026) · 🟥 | ~2 weeks (Apr 12, 2026) · 🟥 | ~older · 🟩 |
| README maturity | 🟩🟩 (full guide, CLI ref, library API, capability boundaries) | 🟩 (description, usage, flag table, examples link) | 🟩 (description + usage) |
| Idiomaticity | 🟩 (explicit codegen) | 🟩 (explicit codegen) | 🟩 (explicit codegen) |
| Issues | 5 open | 3 open | ⬜ |
| | | | |
| **Features** | | | |
| Generates client SDK | ✅ | ✅ | ✅ |
| Generates server stubs (handlers + router) | ✅ | — | — |
| Spec format | YAML + JSON | JSON | OpenAPI 3.0+ |
| `$ref` resolution | ✅ (incl. circular detection) | partial | via `oas` |
| `oneOf` / `anyOf` / `allOf` | ✅ | partial | via `oas` |
| Path / query / header / cookie params | ✅ | path, query, header | typical |
| `deepObject` / `pipeDelimited` / `spaceDelimited` | ✅ | — | — |
| Form bodies (`x-www-form-urlencoded`, `multipart`) | ✅ | — | — |
| Security schemes (apiKey, HTTP, OAuth2, OIDC) | ✅ (bearer attach for OAuth2/OIDC) | manual via request middleware | basic |
| Validation guards from schema constraints | ✅ | — | — |
| `validate` subcommand (no codegen) | ✅ | — | — |
| CI drift check (`--check`) | ✅ | — | — |
| Library API (use as Gleam dep, not just CLI) | ✅ | ✅ | ✅ |
| Snapshot tests on generated output | — | ✅ ([birdie](https://github.com/giacomocavalieri/birdie)) | — |

> [!IMPORTANT]
> Both **oaspec** and **gilly** are days-to-weeks old at snapshot. They move fast — every PR in both repos was merged within hours of opening. Neither has a community track record yet. Pin a version.

> [!NOTE]
> Generated code is plain Gleam built on `gleam/http` types, so it composes with the rest of the ecosystem (e.g. [server frameworks](../web-and-http/web-apps.md#server-frameworks), [HTTP clients](../web-and-http/http-clients.md)). The generators themselves run on BEAM (oaspec/gilly) or are dual-target (oas_generator).

### oaspec
[repo](https://github.com/nao1215/oaspec)

"Generate strongly typed Gleam server stubs and client SDK from OpenAPI 3.x specifications." Wide coverage of the OpenAPI features that show up in real specs: `$ref`, `allOf`/`oneOf`/`anyOf`, `deepObject` query params, form and multipart bodies, all four major security scheme families. Capability boundaries are listed in the README and enforced at validation time — unsupported keywords (`prefixItems`, `not`, `unevaluatedProperties`, etc.) fail fast instead of producing broken code. Backed by 624 unit tests, 40 integration compile tests, 182 fixtures (94 OSS-derived). Distributed as an Erlang escript binary; also usable as a Gleam library with a pure pipeline (`parse → normalize → resolve → capability check → hoist → dedup → validate → codegen`).

CLI:
```sh
oaspec init
# edit oaspec.yaml: input, package, mode (server | client | both)
oaspec generate --config=oaspec.yaml
```

Output layout:
```text
gen/my_api/        types, decode, encode, request_types, response_types,
                   middleware, guards, handlers, router
gen_client/my_api/ types, decode, encode, request_types, response_types,
                   middleware, guards, client
```

Generated client signature:
```gleam
pub type Pet {
  Pet(id: Int, name: String, status: PetStatus, tag: Option(String))
}

pub type PetStatus {
  PetStatusAvailable
  PetStatusPending
  PetStatusSold
}

pub fn create_pet(config: ClientConfig, body: types.CreatePetRequest)
  -> Result(response_types.CreatePetResponse, ClientError)
```

CI drift check:
```sh
oaspec generate --config=oaspec.yaml --check --fail-on-warnings
```

### gilly
[repo](https://github.com/cyclimse/gilly)

"Generate Gleam SDKs from OpenAPI specifications." Client-only scope, inspired by [squirrel](https://github.com/giacomocavalieri/squirrel) (Postgres codegen) and [oapi-codegen](https://github.com/oapi-codegen/oapi-codegen) (Go). Builder-pattern request constructors, snapshot-tested with [birdie](https://github.com/giacomocavalieri/birdie). README is upfront about scope: "many features from the OpenAPI specification are not yet supported"; generated code may break between releases. Ships a real-world Scaleway Containers example (~80 lines) that creates a serverless namespace, polls it to ready, and deploys an nginx container — useful as a reference for how the generated builder API composes with `gleam/httpc`.

CLI:
```sh
gleam add gilly --dev
gleam run -m gilly -- openapi.json --output src/my_api.gleam
```

Flags worth knowing:
- `--optionality {RequiredOnly | NullableOnly | RequiredAndNullable}` — how to decide which fields are `Option(_)` (default `RequiredOnly`)
- `--optional-query-params` — force all query params optional regardless of spec
- `--indent N` — spaces per indent level (default 2)

Generated client usage (Scaleway example, abridged):
```gleam
let api_client =
  client.new(send_fn, region: region, project_id: project_id)

let assert Ok(namespace) =
  client.new_create_namespace_request(
    name: "gilly-example",
    activate_vpc_integration: True,
    secret_environment_variables: [],
    tags: ["example", "gilly"],
  )
  |> client.create_namespace(api_client)
```

The `send_fn` is yours — gilly stays out of HTTP transport. Plug in `gleam/httpc`, `gleam/hackney`, or anything that round-trips `gleam/http` types.

### oas_generator
[repo](https://github.com/crowdhailer/oas_generator)

"Generate HTTP clients from Open API specs." Older entrant in the OpenAPI corner, built on top of the [oas](parse.md#oas) parser library. Supports both backend (`gleam/httpc`) and frontend (`gleam/fetch`) — making it the dual-target choice when oaspec/gilly's BEAM-only output won't fit. 25★, last commit 2026-04-16. Same author as `oas`.

## Other → Gleam

### squall
[repo](https://github.com/bigmoves/squall)

"Type-safe GraphQL client generator." Generates Gleam client code from GraphQL schemas + queries. Out of scope for in-depth review at this snapshot; warrants a dedicated GraphQL article when the corner grows.

### embeds
[repo](https://github.com/arkandos/gleam-embeds)

"Generate Gleam modules based on static assets." Bake files (HTML, CSS, images, anything) into compiled Gleam modules at build time. Adjacent to codegen — emits Gleam constants holding asset bytes rather than functional code.

### MCP encoders/decoders

[aide_generator](serialize.md#aide_generator) emits encoders + decoders for MCP tool schemas. Covered under [serialize.md → Codegen for ser/deser](serialize.md#codegen-for-serdeser) because its primary output is ser/deser code.

### JSON Schema / RFC 8927

[json_typedef](serialize.md#json_typedef) consumes RFC 8927 JSON Type Definition documents and emits Gleam types + encoders + decoders. Same reasoning as above — its primary output is ser/deser code, so it lives in [serialize.md](serialize.md#codegen-for-serdeser).

For runtime JSON-Schema *validation* (without codegen), see [decode.md → JSON Schema](decode.md#json-schema-json-patch-json-rpc) — [castor](decode.md#castor), [jscheam](decode.md#jscheam), [sextant](decode.md#sextant).

### gRPC / Protobuf codegen

**Gap.** No published Gleam package emits Gleam code from `.proto` definitions, and no Gleam gRPC server framework exists. **Workaround:** generate Erlang stubs with `protoc` + `grpcbox` and call them from Gleam. Runtime-only Protobuf coverage exists via [protozoa](decode.md#protozoa).

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
| **Elm** | [elm-codegen](https://github.com/mdgriffith/elm-codegen) is the reference for typed-builder Gleam-codegen — explicitly inspires [trick](#trick) (and indirectly the gleamgen design space). | Explicit, typed, library-driven; Elm has no macros either. |

The Gleam codegen story sits closest to **TypeScript** and **Go**: emit-and-commit, build-step driven, no compiler magic. This is a deliberate consequence of Gleam having [no macros](https://github.com/gleam-lang/gleam/issues/1767) and no runtime reflection — the only way to do "derive" is to **literally write the Gleam source**.

The same constraint is what makes the **Gleam → spec** direction (e.g. handler types → OpenAPI) hard: there is no inspection mechanism short of parsing the source via [glance](parse.md#glance). See [serialize.md](serialize.md#gleam--openapi-code-first-spec-generation) for the full discussion.

## Leaderboards

### Gleam → Gleam generators

| Position | Award | Repo | Output | ★ | Lic | Compat | Maint | Age | README | Idiom | Score |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 🥇 | [Brewingweasel/gleamgen](https://github.com/Brewingweasel/gleamgen) | Gleam (DSL) | 🟨 | 🟨 | 🟩 | 🟩 | 🟩 | 🟩🟩 | 🟩 | **6** |
| 2 | 🥈 | [GearsDatapacks/trick](https://github.com/GearsDatapacks/trick) | Gleam (elm-codegen-style) | 🟨 | 🟥 | 🟩 | 🟩 | 🟨 | 🟩🟩 | 🟩 | **5** |
| 3 | 🥉 | [dusty-phillips/derived](https://github.com/dusty-phillips/derived) | Custom (markers) | 🟥 | 🟩 | 🟩 | 🟩 | 🟩 | 🟩 | 🟩 | **5** |
| 4 | — | [lpil/glue](https://github.com/lpil/glue) | Gleam (`compare`, etc.) | 🟥 | 🟨 | 🟩 | 🟨 | 🟩 | 🟩 | 🟩 | **3** |

> [!NOTE]
> Codegen tools whose **primary output is encoders/decoders** ([json_typedef](serialize.md#json_typedef), [gserde](serialize.md#gserde), [glerd_json](serialize.md#glerd_json)) have their own leaderboard at [serialize.md → Codegen for ser/deser](serialize.md#codegen-for-serdeser).

### X → Gleam generators (combined)

Includes SQL, OpenAPI, GraphQL. Cross-reference: [../databases.md leaderboard](../databases.md#leaderboard) covers SQL codegen alongside drivers and migrations. Codegen tools whose output is encoders/decoders (json_typedef RFC 8927, aide_generator MCP) have their own leaderboard in [serialize.md](serialize.md#codegen-for-serdeser).

| Position | Award | Repo | Input | ★ | Lic | Compat | Maint | Age | README | Idiom | Score |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 🥇 | [giacomocavalieri/squirrel](https://github.com/giacomocavalieri/squirrel) | SQL (PostgreSQL) | 🟩🟩 | 🟩 | 🟩 | 🟩 | 🟩 | 🟩🟩 | 🟩 | **9** |
| 2 | 🥈 | [daniellionel01/parrot](https://github.com/daniellionel01/parrot) | SQL (sqlc; multi-DB) | 🟩🟩 | 🟩 | 🟩 | 🟩 | 🟩 | 🟩🟩 | 🟩 | **9** |
| 3 | 🥉 | [nao1215/oaspec](https://github.com/nao1215/oaspec) | OpenAPI 3.x | 🟥 | 🟩 | 🟩 | 🟩🟩 | 🟥 | 🟩🟩 | 🟩 | **6** |
| 4 | — | [crowdhailer/oas_generator](https://github.com/crowdhailer/oas_generator) | OpenAPI 3.x | 🟨 | 🟩 | 🟨 | 🟩🟩 | 🟩 | 🟩 | 🟩 | **6** |
| 5 | — | [pairshaped/marmot](https://github.com/pairshaped/marmot) | SQL (SQLite) | 🟥 | 🟩 | 🟩 | 🟩🟩 | 🟥 | 🟩🟩 | 🟩 | **5** |
| 6 | — | [nao1215/sqlode](https://github.com/nao1215/sqlode) | SQL (multi-DB) | 🟥 | 🟩 | 🟩 | 🟩🟩 | 🟥 | 🟩🟩 | 🟩 | **5** |
| 7 | — | [cyclimse/gilly](https://github.com/cyclimse/gilly) | OpenAPI 3.x | 🟥 | 🟩 | 🟩 | 🟩🟩 | 🟥 | 🟩 | 🟩 | **4** |

### Honorable mentions

- **[squirrel](https://github.com/giacomocavalieri/squirrel)** — the established SQL→Gleam codegen, FOSDEM-talked, 633★. The reference implementation other tools cite.
- **[parrot](https://github.com/daniellionel01/parrot)** — sqlc-backed, multi-DB, 206★. Renamed from `sqlc-gen-gleam`.
- **[oaspec](https://github.com/nao1215/oaspec)** — wide OpenAPI coverage out of the gate, capability boundaries documented, server *and* client.
- **[gilly](https://github.com/cyclimse/gilly)** — tight scope, builder-pattern API, snapshot-tested, real-world Scaleway example.
- **[gleamgen](https://github.com/Brewingweasel/gleamgen)** — phantom-typed builder API, foundational dependency for downstream codegen tools.
- **[trick](https://github.com/GearsDatapacks/trick)** — elm-codegen-shaped builder; pre-Hex but the developer-experience peer of gleamgen.
- **[json_typedef](serialize.md#json_typedef)**, **[gserde](serialize.md#gserde)**, **[aide_generator](serialize.md#aide_generator)** — covered in [serialize.md](serialize.md#codegen-for-serdeser) as ser/deser-specific codegen.

[How scores are calculated →](README.md#scoring-rubric-shared)

## Related

- [parse.md](parse.md) — runtime parsing (the input side of codegen pipelines like `oas → oas_generator`).
- [decode.md](decode.md) — runtime JSON Schema validation tooling that overlaps the same conceptual space.
- [serialize.md](serialize.md) — runtime ser/deser, codegen for encoders/decoders (json_typedef, gserde, glerd_json, aide_generator), bidirectional schemas, and the Gleam→spec gap.
- [../databases.md](../databases.md#sql-code-generators) — squirrel vs sqlode comparison in depth.
