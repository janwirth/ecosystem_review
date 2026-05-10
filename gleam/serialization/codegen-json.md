# Codegen for JSON ser/deser

> [!NOTE]
> **Status:** DRAFT · **Authoring:** AI-assisted, human-reviewed.

Build-time tools whose **primary output is JSON encoder / decoder code**. These are the "I don't want to write 200 lines of `decode.field` per record" escape hatch. Every one of them runs as a build step (`gleam run -m <tool>`) and emits `.gleam` files you commit to the repo.

For the foundational pattern these tools emit *into* (the encoder/decoder convention and hand-written defaults), see the folder [README](README.md). For runtime JSON libraries and bidirectional schemas (no codegen step), see [runtime-bidirectional-json.md](runtime-bidirectional-json.md). For non-JSON formats, see [other-formats.md](other-formats.md).

## Table of contents

1. [Summary](#summary)
2. [Discovery](#discovery)
3. [Decision flow](#decision-flow)
4. [json_typedef](#json_typedef)
5. [gserde](#gserde)
6. [sara](#sara)
7. [glerd_json](#glerd_json)
8. [derived](#derived)
9. [aide_generator](#aide_generator)
10. [deriv](#deriv)
11. [What does not exist (yet)](#what-does-not-exist-yet)
12. [Leaderboard](#leaderboard)
13. [Related](#related)

## Summary

**Snapshot 2026-05-07.** Several entrants, none dominant. The corner is healthy enough that you can pick a tool today; none are universal.

| Tool | Source of truth | Emits | Stars | Notes |
| --- | --- | --- | --- | --- |
| [json_typedef](#json_typedef) | RFC 8927 JSON Type Definition | Gleam types + JSON encoders/decoders | 51★ | Schema-first; well-trusted (lpil) |
| [gserde](#gserde) | Gleam types | JSON encoders/decoders | 32★ · alpha | Type-first |
| [sara](#sara) | Gleam types w/ `//@json_encode()` / `//@json_decode()` annotations | JSON encoders/decoders in `_json.gleam` modules | 10★ | Annotation-driven; squirrel-inspired |
| [glerd_json](#glerd_json) | Gleam types via `glerd` runtime info | JSON encoders/decoders | n/v | Runtime-info-driven |
| [derived](#derived) | Gleam source w/ `!derived(...)` markers | Anything (incl. ser/deser) | 2★ | Marker-based; bring-your-own deriver |
| [aide_generator](#aide_generator) | MCP tool schemas | MCP encoders/decoders | n/v | Narrow-scope (MCP only) |
| [deriv](#deriv) | Gleam types w/ `//$ derive json …` markers | JSON encoders/decoders + type unification | 5★ · ⚠️ broken on new projects | Pinned to `gleam_json < 3.0`; conflicts with current `gleam_json 3.x` |

## Discovery

Searches run on **2026-05-07** against [packages.gleam.run](https://packages.gleam.run/), plus targeted GitHub queries.

| Query | URL |
| --- | --- |
| `serialize` | [packages.gleam.run/?search=serialize](https://packages.gleam.run/?search=serialize) |
| `serializer` | [packages.gleam.run/?search=serializer](https://packages.gleam.run/?search=serializer) |
| `serde` | [packages.gleam.run/?search=serde](https://packages.gleam.run/?search=serde) (only `nimiq_serde` — blockchain-specific, not a generic library) |
| `derive` | [packages.gleam.run/?search=derive](https://packages.gleam.run/?search=derive) |
| `codec` | [packages.gleam.run/?search=codec](https://packages.gleam.run/?search=codec) |
| `glerd` | [packages.gleam.run/?search=glerd](https://packages.gleam.run/?search=glerd) |
| `sara` | [packages.gleam.run/?search=sara](https://packages.gleam.run/?search=sara) |

## Decision flow

- **You have a schema document** (TypeDef, OpenAPI, MCP) → use the tool that consumes that document directly. `json_typedef` for TypeDef, [oaspec](../openapi.md#oaspec) / [gilly](../openapi.md#gilly) for OpenAPI, `aide_generator` for MCP.
- **You want to start from your Gleam types** → `gserde` (full source-walking) or `sara` (per-type annotations) are the most direct matches. `glerd_json` if you already use the `glerd` runtime-info ecosystem. `derived` if you want a marker-based approach where you control the emitted shape. **Avoid `deriv` until its `gleam_json` constraint is bumped** — it cannot resolve in any project that depends on `gleam_json 3.x`.
- **Round-trip correctness is critical and you have many records** → schema-first (`json_typedef`) beats type-first because the schema is a single artefact you can validate the wire against.

## json_typedef

[repo](https://github.com/lpil/json-typedef)

"Work with JSON using a schema! RFC8927." JSON Type Definition (RFC 8927) is a JSON schema standard simpler than JSON Schema itself — fewer keywords, smaller surface, designed explicitly for codegen. The package decodes a TypeDef document into Gleam, then generates encoders/decoders. By Louis Pilfold (lpil — author of the language).

| Criterion | [json_typedef](https://github.com/lpil/json-typedef) |
| --- | --- |
| Stars | 51★ · 🟨 |
| License | not specified · 🟨 |
| Target | ☎️📜 Both |
| Maintenance | 🟩 (latest tag v1.1.x; ~16 months old at snapshot) |
| Age | ~2 years · 🟩 |
| README maturity | 🟩 (clear; explicit schema-first stance) |
| Idiomaticity | 🟩 (typed, explicit) |
| Issues | 2 open |

```gleam
// Given a TypeDef schema document, generate types + codecs:
import json_typedef

pub fn main() {
  let assert Ok(schema) = json_typedef.from_string(schema_string)
  let gleam_source = json_typedef.codegen(schema, module_name: "user")
  // → write to src/user.gleam
}
```

The schema-first stance means changes to the wire format are **document edits**, not code edits, and the regenerated codecs cannot drift from the schema. Pair with `--check` in CI to catch unregenerated code.

## gserde

[repo](https://github.com/cdaringe/gserde)

"Gleam codegen for serialization and deserialization." Type-first: point it at your Gleam types, get JSON encoders/decoders out. README declares **alpha** quality. The most direct response to "I don't want to write decoders" — but the alpha caveat means you should pin a version and accept some breakage between releases.

| Criterion | [gserde](https://github.com/cdaringe/gserde) |
| --- | --- |
| Stars | 32★ · 🟨 |
| License | not specified · 🟨 |
| Maintenance | 🟩 (commits ~Dec 2025) |
| Age | ~1 year · 🟩 |
| README maturity | 🟩 (alpha disclaimer; usage example) |
| Idiomaticity | 🟩 |
| Issues | 1 open |

For production today, prefer hand-written `gleam_json` decoders or schema-first `json_typedef`. For prototyping, gserde turns hours of decoder typing into seconds.

## sara

[repo](https://github.com/gungun974/Sara) · [hexdocs](https://hexdocs.pm/sara/1.0.0/index.html)

"A Gleam serialization code generator." Annotation-driven type-first codegen: mark a custom type with `//@json_encode()` and/or `//@json_decode()`, run `gleam run -m sara`, and `sara` emits a sibling `_json.gleam` module with the encoder/decoder functions. Inspired by [squirrel](../databases.md#squirrel-) (which uses the same "annotate + run codegen" loop for SQL). Pure Gleam, dev-dependency, dual-target.

```gleam
//@json_encode()
//@json_decode()
pub type Comment {
  Comment(id: Int, message: String)
}
```

Then `gleam run -m sara` produces `comment_json.gleam` next to the source. Supports built-in types (Bool/Int/Float/String/List/Tuple), custom types, recursive types, nested structures. Unannotated types can be handled by passing custom encoder/decoder functions as parameters (escape hatch for opaque types or third-party types you can't annotate).

| Criterion | [sara](https://github.com/gungun974/Sara) |
| --- | --- |
| Stars | 10★ · 🟨 |
| License | Apache-2.0 · 🟩 |
| Target | ☎️📜 Both (pure Gleam) |
| Maintenance | 🟩 (last commit 2026-03-21, ~7 weeks before snapshot) |
| Age | ~7 weeks (created 2026-03-21) · 🟥 |
| README maturity | 🟩 (annotation example, run command, limitations) |
| Idiomaticity | 🟩 (typed, explicit annotations) |
| Issues | 3 open |

**Limitation:** annotated types must be `pub` and non-opaque, since the generated `_json.gleam` module needs to access the constructors. Same constraint applies to most source-walking codegen tools in Gleam.

**vs gserde / json_typedef:** sara sits between the two — gserde walks all types in your project (no annotation needed, but less control), json_typedef requires a separate schema document (most explicit, but two artefacts). sara's per-type annotation gives finer control than gserde without the schema-document overhead of json_typedef.

## glerd_json

[hex](https://hex.pm/packages/glerd_json)

"JSON encoders/decoders codegen using Glerd." Built on top of [glerd](https://hex.pm/packages/glerd), a runtime type-information library that exposes Gleam record metadata to other tools. `glerd_json` consumes that metadata and emits encoders/decoders. Different mechanism from `gserde` (which parses Gleam source via [glance](../parse-and-generate-gleam.md#glance)) — `glerd` instruments your build to expose type info at build time, then plugins like `glerd_json` consume it.

The pattern is interesting because it factors out the "extract type info" step into a shared library, so other tools (validation, GraphQL schema, etc.) can reuse it. Adoption is still small at snapshot.

## derived

[repo](https://github.com/dusty-phillips/derived)

"The gleam code generator's code generator." Marker-based: write `!derived(...)` directives in docstrings of your Gleam source, run `derived`, and the tool inserts generated code at protected markers (round-trip safe; reruns won't double-insert). For building **custom** ser/deser derivers — useful when neither `json_typedef` nor `gserde` produces the shape you want and you'd rather write a small deriver than every encoder by hand.

derived itself is **not** a JSON encoder generator out of the box; it is the framework on which one could be built. Pair with [trick](../parse-and-generate-gleam.md#trick) or [gleamgen](../parse-and-generate-gleam.md#gleamgen) for the code-emission half and you have a custom deriver in <100 lines.

## aide_generator

[repo](https://github.com/crowdhailer/aide_generator)

"Generate encoders and decoders for MCP tools." Narrow scope: emit ser/deser for the parameter and result types of an MCP (Model Context Protocol) tool definition. Same author as [oas](../openapi.md#oas) and [oas_generator](../openapi.md#oas_generator). Not a general-purpose codegen — but the right pick if you are building an MCP server in Gleam where tool schemas are the source of truth. See [ai.md](../ai.md) for the MCP context.

## deriv

[repo](https://github.com/bchase/deriv) · [hex](https://hex.pm/packages/deriv)

"Derive functions for your Gleam types." Marker-based codegen: write `//$ derive json decode encode` (or `//$ derive unify`) above a type definition, run `gleam run -m deriv`, and the tool emits JSON encoders/decoders alongside type-unification helpers. Supports custom field naming (e.g. mapping a Gleam field `draft` to JSON key `content`) and nested-key paths (e.g. `meta_nested_key` → `meta.nested.key`). Last release: v2.0.0 (2025-04-08).

> [!CAUTION]
> **deriv 2.0.0 cannot resolve dependencies in new projects as of snapshot (2026-05-07).** Its manifest pins `gleam_json >= 2.2.0 and < 3.0.0`, but the current `gleam_json` is **v3.1.0**. Adding `deriv` to a project that already depends on `gleam_json 3.x` fails immediately:
>
> ```
> error: Dependency resolution failed
> There's no compatible version of `gleam_json`:
>   - You require deriv >= 0.0.0
>     - deriv requires gleam_json >= 2.2.0 and < 3.0.0
>   - You require gleam_json 3.1.0
> ```
>
> Adding `deriv` to a fresh project pins the project to `gleam_json 2.x`, which is missing the API surface added in 3.0. Until upstream bumps the constraint, prefer [gserde](#gserde) or [sara](#sara) for type-first JSON codegen.

| Criterion | [deriv](https://github.com/bchase/deriv) |
| --- | --- |
| Stars | 5★ · 🟥 |
| License | MIT · 🟩 |
| Target | ☎️ BEAM |
| Gleam compat | `gleam_stdlib >= 0.34.0 and < 2.0.0` · 🟩, but `gleam_json < 3.0.0` · 🟥 |
| Maintenance | 🟥 (latest release 2025-04-08; no commits since) |
| Age | ~13 months at snapshot · 🟩 |
| README maturity | 🟩 (annotation examples, custom-naming, nested keys) |
| Idiomaticity | 🟩 (typed, explicit annotations) |
| Issues | not surfaced |

The annotation/run-codegen loop is the same shape as [sara](#sara), so if upstream catches up on `gleam_json` and `decode 1.x`, deriv is a reasonable peer in the codegen-from-types corner. As of snapshot, treat it as **stale**.

## What does not exist (yet)

- **No `#[derive(Decode)]`-equivalent** — Gleam has no macros. The closest analogue is `gserde` (parse source, emit code) or `glerd_json` (runtime type info, emit code), neither of which is a one-liner annotation.
- **No serde-style format-pluggable codegen** — Rust's `serde` separates the "describe my type" trait from the "this format encodes booleans like X" trait, letting one derive serve JSON, CBOR, MsgPack, etc. Gleam codegen tools are **per-format** (gserde is JSON-only, json_typedef is JSON-only). A future serde-shaped Gleam tool would be a useful addition.
- **No Protobuf `.proto` codegen** — `protozoa` is library-only. Cross-link: [parse-and-generate-other-languages.md → gRPC / Protobuf codegen](../parse-and-generate-other-languages.md#grpc--protobuf-codegen).
- **No Gleam → spec document emission** — no package emits OpenAPI / JSON Schema from your types or your routes. See [openapi.md → Gleam → OpenAPI](../openapi.md#gleam--openapi-code-first-spec-generation).

## Leaderboard

[How scores are calculated →](../databases.md#scoring-dimensions)

| Position | Award | Repo | Source of truth | ★ | Lic | Compat | Maint | Age | README | Idiom | Score |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 🥇 | [lpil/json-typedef](https://github.com/lpil/json-typedef) | RFC 8927 TypeDef | 🟨 | 🟨 | 🟩 | 🟩 | 🟩 | 🟩 | 🟩 | **5** |
| 2 | 🥈 | [cdaringe/gserde](https://github.com/cdaringe/gserde) | Gleam types | 🟨 | 🟨 | 🟩 | 🟩 | 🟩 | 🟩 | 🟩 | **5** |
| 2 | 🥈 | [crowdhailer/aide_generator](https://github.com/crowdhailer/aide_generator) | MCP tool schemas | ⬜ | 🟩 | 🟩 | 🟩 | 🟨 | 🟩 | 🟩 | **5** |
| 2 | 🥈 | [dusty-phillips/derived](https://github.com/dusty-phillips/derived) | `!derived()` markers | 🟥 | 🟩 | 🟩 | 🟩 | 🟩 | 🟩 | 🟩 | **5** |
| 5 | — | [gungun974/Sara](https://github.com/gungun974/Sara) | Gleam types w/ annotations | 🟨 | 🟩 | 🟩 | 🟩 | 🟥 | 🟩 | 🟩 | **4** |
| 6 | — | [darky/glerd-json](https://hex.pm/packages/glerd_json) | Gleam types via `glerd` | ⬜ | ⬜ | 🟩 | 🟨 | 🟩 | 🟨 | 🟩 | **3** |
| 7 | — | [bchase/deriv](https://github.com/bchase/deriv) ⚠️ | Gleam types w/ `//$ derive` markers | 🟥 | 🟩 | 🟥 | 🟥 | 🟩 | 🟩 | 🟩 | **1** |

**json_typedef** wins on authority + schema-first stance + "lpil-built" trust. **gserde** is the most direct type-first answer but the alpha caveat keeps it tied. **sara** is the youngest entrant but ships a clean per-type annotation API; the squirrel-inspired loop will feel familiar to anyone using SQL codegen. **derived** is the right pick when none of the above emit the shape you want — it is the framework, not the deriver. **deriv** drops to the bottom because of its `gleam_json < 3.0.0` cap — see the [`Caution` callout](#deriv).

## Related

- [README](README.md) — folder intro: encoder/decoder convention, hand-written ser/deser, cross-language framing.
- [runtime-bidirectional-json.md](runtime-bidirectional-json.md) — runtime JSON libraries (no codegen step).
- [other-formats.md](other-formats.md) — non-JSON formats (CBOR, MsgPack, BSON, Protobuf, …).
- [../openapi.md](../openapi.md) — OpenAPI parser, spec→Gleam codegen (oaspec/gilly/oas_generator), and the Gleam → OpenAPI gap.
- [../parse-and-generate-gleam.md](../parse-and-generate-gleam.md) — Gleam-emitting DSLs (gleamgen, trick) — the build-time machinery codegen tools sit on.
- [../parse-and-generate-other-languages.md](../parse-and-generate-other-languages.md) — X→Gleam codegen for non-ser/deser (SQL, GraphQL, …).
- [../databases.md](../databases.md) — canonical scoring rubric.
- [../ai.md](../ai.md) — MCP context for `aide_generator`.
