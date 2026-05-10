# Runtime bidirectional JSON

> [!NOTE]
> **Status:** DRAFT · **Authoring:** AI-assisted, human-reviewed.

Runtime JSON libraries — encoders and decoders that ship in your binary and run when your program runs. No build step, no `gleam run -m <tool>`. This article covers three slices:

1. **Per-format JSON packages** — `gleam_json`, `jackson`, `juno`, `simplejson`. The encoder/decoder pair you reach for first.
2. **JSON Schema / Patch / RPC** — `castor`, `jscheam`, `sextant`, `squirtle`, `pollux`. JSON-spec-document tools.
3. **Bidirectional schemas at runtime** — `convert`, `kata`, `json_blueprint`. Define your type once as a runtime schema, get encoder + decoder from a single description.

For build-time codegen of JSON encoders/decoders (`json_typedef`, `gserde`, `sara`, …), see [codegen-json.md](codegen-json.md). For non-JSON formats (CBOR, MsgPack, BSON, Protobuf, …), see [other-formats.md](other-formats.md). For the foundational hand-written pattern these libraries plug into, see the folder [README](README.md).

## Table of contents

1. [Summary](#summary)
2. [Discovery](#discovery)
3. [Per-format JSON packages](#per-format-json-packages)
4. [JSON Schema, JSON Patch, JSON-RPC](#json-schema-json-patch-json-rpc)
5. [Bidirectional schemas at runtime](#bidirectional-schemas-at-runtime)
6. [Leaderboards](#leaderboards)
7. [Type-to-spec emission](#type-to-spec-emission)
8. [Related](#related)

## Summary

**Snapshot 2026-05-07.**

| Slice | Status |
| --- | --- |
| [JSON encoder/decoder libraries](#per-format-json-packages) | ✅ [gleam_json](#gleam_json) is canonical (146★). Pure-Gleam alternatives [jackson](#jackson), [simplejson](#simplejson), [juno](#juno) cover JSON Pointer / JSONPath / ad-hoc shapes. |
| [JSON Schema / Patch / RPC](#json-schema-json-patch-json-rpc) | ✅ [castor](#castor), [jscheam](#jscheam), [sextant](#sextant), [squirtle](#squirtle), [pollux](#pollux). |
| [Bidirectional schemas (single source of truth at runtime)](#bidirectional-schemas-at-runtime) | ✅ [convert](#convert), [kata](#kata), [json_blueprint](#json_blueprint). Define once, derive both directions. |
| Gleam → spec document (OpenAPI / JSON Schema from types) | ❌ **Gap.** No package emits a spec from your types or your routes. → see [openapi.md → Gleam → OpenAPI](../openapi.md#gleam--openapi-code-first-spec-generation). |

> [!NOTE]
> **Bidirectional schemas vs codegen.** Pick *runtime bidirectional* when the schema is a value in your program (config, conditional, dynamic). Pick *build-time codegen* (→ [codegen-json.md](codegen-json.md)) when you want zero-cost generated functions and the schema is stable enough to commit. The two approaches are not mutually exclusive — `convert` for the rare dynamic schema, `json_typedef` for the bulk of static types is a reasonable mix.

## Discovery

Searches run on **2026-05-07** against [packages.gleam.run](https://packages.gleam.run/), plus targeted GitHub queries.

| Query | URL |
| --- | --- |
| `json` | [packages.gleam.run/?search=json](https://packages.gleam.run/?search=json) |
| `encode` | [packages.gleam.run/?search=encode](https://packages.gleam.run/?search=encode) |
| `encoder` | [packages.gleam.run/?search=encoder](https://packages.gleam.run/?search=encoder) |
| `decode` | [packages.gleam.run/?search=decode](https://packages.gleam.run/?search=decode) |
| `decoder` | [packages.gleam.run/?search=decoder](https://packages.gleam.run/?search=decoder) |
| `schema` | [packages.gleam.run/?search=schema](https://packages.gleam.run/?search=schema) |
| `convert` | [packages.gleam.run/?search=convert](https://packages.gleam.run/?search=convert) |
| `kata` | [packages.gleam.run/?search=kata](https://packages.gleam.run/?search=kata) |

## Per-format JSON packages

Most Gleam JSON libraries are **bidirectional in one package** — encoder and decoder ship together, around the same field names. Pick one based on whether you need a NIF, JSON Pointer, JSONPath, or ad-hoc shapes.

| Tool | Approach | Notes |
| --- | --- | --- |
| [gleam_json](#gleam_json) | Official wrapper around BEAM's `jiffy` (☎️) and JS `JSON.parse` (📜) | Canonical choice; dual-target. **146★, v3.1.0**. |
| [jackson](#jackson) | Pure Gleam parser + JSON Pointer (RFC 6901) resolver | When you need pointer queries or no NIF |
| [juno](#juno) | Flexible decoding into ADT or `dynamic.Dynamic` | Convenience layer when you don't want to write a full decoder |
| [simplejson](#simplejson) | Pure Gleam parser/generator with JSONPath queries | When you need JSONPath |

### gleam_json

[repo](https://github.com/gleam-lang/json)

Official package (`gleam-lang` org). `json.parse(input, decoder)` returns `Result(t, DecodeError)`. Dual-target — uses Erlang's `jiffy` NIF on BEAM, native `JSON.parse` on JS. The default for any new project. The encode side: `json.object/array/string/...` builders compose a `Json` value; `json.to_string()` flattens.

### jackson

[repo](https://github.com/VioletBuse/jackson)

"A pure gleam json decoder, encoder, and json pointer resolver." Pure Gleam parser (no NIF dependency) plus RFC 6901 JSON Pointer resolution — useful for picking out values by JSON-path-like keys without writing a decoder for the surrounding shape. Symmetric encoder side. Low activity (7 commits at snapshot).

### juno

[repo](https://github.com/massivefermion/juno)

"Flexible JSON decoding for Gleam." Returns a tagged sum representing the JSON value tree, plus convenience constructors. Useful for ad-hoc inspection / non-strict shapes where writing a strict decoder is overkill. Inverse for emission of dynamic shapes.

### simplejson

[repo](https://github.com/pendletong/simplejson)

"Native gleam json parser/generator with jsonpath querying." Pure Gleam, dual-target, ships with JSONPath. Pick this when you want JSONPath without bolting on a separate library. Encode + decode + JSONPath in one. v1.2.0.

### decode

[repo](https://hex.pm/packages/decode)

"Ergonomic dynamic decoders for Gleam." Pre-stdlib helpers; mostly subsumed by `gleam/dynamic/decode` after stdlib `>=0.41`. Useful for projects pinned to older stdlib.

## JSON Schema, JSON Patch, JSON-RPC

| Tool | Standard | Notes |
| --- | --- | --- |
| [castor](#castor) | JSON Schema | Build, encode, and decode JSON Schema documents |
| [jscheam](#jscheam) | JSON Schema (subset) | Smaller surface; schema construction + validation |
| [sextant](#sextant) | JSON Schema | Type-safe JSON Schema generation + validation |
| [squirtle](#squirtle) | JSON Patch (RFC 6902) | Apply patch documents to JSON |
| [pollux](#pollux) | JSON-RPC 2.0 | Request/response framing |

(`castor`, `sextant`, and `jscheam` also appear under [bidirectional schemas at runtime](#bidirectional-schemas-at-runtime) — they emit JSON Schema documents from typed builders.)

### castor

[repo](https://github.com/crowdhailer/castor)

"Build schemas as well as encoding decoding from json schema file." Same author as [oas](../openapi.md#oas) and [oas_generator](../openapi.md#oas_generator). Bidirectional: parse a JSON Schema document, or build one programmatically.

### jscheam

A smaller JSON Schema library. Surface scoped to common subset rather than the full spec.

### sextant

[repo](https://github.com/Pevensie/sextant)

Type-safe JSON Schema generation and validation in Gleam. Targets two use cases: emitting JSON Schema for OpenAPI specs, and generating schemas to constrain LLM structured outputs. The builders are typed, so you cannot accidentally compose a schema that wouldn't typecheck.

### squirtle

[repo](https://hex.pm/packages/squirtle)

JSON Patch (RFC 6902) implementation — apply patch documents (`add`, `remove`, `replace`, `move`, `copy`, `test`) to JSON.

### pollux

JSON-RPC 2.0 framing — request/response/notification structures and envelopes. Pair with `gleam_json` for transport.

## Bidirectional schemas at runtime

A different escape hatch from "write encoder + decoder by hand": describe your type once as a *runtime schema value*, hand it to the library, get both directions. No build step, no codegen — but the schema is a value in your program, not a definition that the compiler checks against your types.

| Tool | Output | Stars | Notes |
| --- | --- | --- | --- |
| [convert](#convert) | Encoder + decoder for basic and complex types | 5★ | "Encode and decode from and to Gleam types effortlessly" |
| [kata](#kata) | Encoder + decoder | 3★ | "Define once, decode and encode with same definition" |
| [json_blueprint](#json_blueprint) | Encoder + decoder + auto-derived JSON Schema | n/v | Closest to bridging runtime schemas and JSON Schema emission |
| [castor](#castor) | JSON Schema document (encode + decode) | 6★ | Build, encode, and decode JSON Schema documents |
| [sextant](#sextant) | JSON Schema document with type-safe builders | 8★ | Targets OpenAPI + LLM structured-output use cases |

### convert

[repo](https://github.com/Billuc/convert)

"Utilities to create encoders and decoders from basic and complex types." Single definition emits both directions. v1.0.2, Apache-2.0, last commit ~mid-2025. Six dependents on Hex at snapshot — modest but real adoption.

```gleam
import convert

let user_converter =
  convert.object3(User, "name", convert.string, "age", convert.int, ...)

// encode: User → Json
convert.encode(user_converter, user)
// decode: String → Result(User, _)
convert.decode(user_converter, json_string)
```

### kata

[repo](https://github.com/Allianaab2m/kata-gleam)

"Define once, decode and encode with same definition." Pairs with `kata_json` adapter for JSON-specific bindings. Smaller community (3★) but the design is on-pattern with the rest of the bidirectional-schema tier.

### json_blueprint

[hex](https://hex.pm/packages/json_blueprint)

Encode + decode + **auto-derived JSON Schema** from the same blueprint definition. Sits at the bidirectional-schema/JSON-Schema-emission boundary — closer than any other Gleam package to "describe the type once, get encoder, decoder, *and* a schema document". Worth tracking; the closest in-ecosystem path to the [Gleam → spec gap](../openapi.md#gleam--openapi-code-first-spec-generation) for the JSON Schema side specifically.

> [!NOTE]
> **castor and sextant emit JSON Schema, but only from runtime values.** You instantiate the schema explicitly via builders. To go from `pub type User { User(...) }` straight to a JSON Schema document **without** a hand-written builder, you would need build-time type introspection, which Gleam does not have. `glerd_json` is the closest indirect path; `json_blueprint` covers the runtime path tightly.

## Leaderboards

[How scores are calculated →](../databases.md#scoring-dimensions)

### JSON

Star counts on most JSON packages aren't surfaced individually by the search index; `gleam_json` is the dominant choice by usage (it's the official package).

| Position | Award | Repo | Approach | Score notes |
| --- | --- | --- | --- | --- |
| 1 | 🥇 | [gleam-lang/json](https://github.com/gleam-lang/json) | Official, dual-target via NIF + JS native | Default for new projects. **146★, v3.1.0**. |
| 2 | 🥈 | [VioletBuse/jackson](https://github.com/VioletBuse/jackson) | Pure Gleam + JSON Pointer | Pick when no-NIF or pointer queries needed. |
| 3 | 🥉 | [pendletong/simplejson](https://github.com/pendletong/simplejson) | Pure Gleam + JSONPath | Pick when JSONPath needed. |
| 4 | — | [massivefermion/juno](https://github.com/massivefermion/juno) | Flexible / ADT-style | Pick for ad-hoc / non-strict shapes. |

### Bidirectional schemas at runtime

| Position | Award | Repo | Output | ★ | Lic | Compat | Maint | Age | README | Idiom | Score |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 🥇 | [Pevensie/sextant](https://github.com/Pevensie/sextant) | JSON Schema (typed) | 🟥 | 🟩 | 🟩 | 🟩 | 🟨 | 🟩 | 🟩 | **4** |
| 2 | 🥈 | [crowdhailer/castor](https://github.com/crowdhailer/castor) | JSON Schema | 🟥 | 🟩 | 🟩 | 🟩 | 🟨 | 🟩 | 🟩 | **4** |
| 3 | 🥉 | [Billuc/convert](https://github.com/Billuc/convert) | Generic encoder/decoder | 🟥 | 🟩 | 🟩 | 🟩 | 🟨 | 🟩 | 🟩 | **4** |
| 4 | — | json_blueprint | encode + decode + JSON Schema | ⬜ | ⬜ | 🟩 | 🟩 | 🟨 | 🟩 | 🟩 | **3** |
| 5 | — | [Allianaab2m/kata-gleam](https://github.com/Allianaab2m/kata-gleam) | Generic encoder/decoder | 🟥 | 🟩 | 🟩 | 🟨 | 🟨 | 🟨 | 🟩 | **2** |

## Type-to-spec emission

(Code-first OpenAPI / JSON Schema from types.)

| Tool | Status |
| --- | --- |
| Anything that walks Gleam types and emits OpenAPI | ❌ does not exist · see [openapi.md](../openapi.md#gleam--openapi-code-first-spec-generation) |
| Anything that walks Gleam types and emits JSON Schema | ⚠️ [json_blueprint](#json_blueprint) gets close (single blueprint → encode + decode + auto-Schema), but you still author the blueprint by hand |

## Related

- [README](README.md) — folder intro: encoder/decoder convention, hand-written ser/deser, cross-language framing.
- [codegen-json.md](codegen-json.md) — build-time codegen for JSON ser/deser.
- [other-formats.md](other-formats.md) — non-JSON formats (CBOR, MsgPack, BSON, Protobuf, …) and wire-protocol codecs.
- [../openapi.md](../openapi.md) — OpenAPI parser library, spec→Gleam codegen, Gleam → OpenAPI gap.
- [../databases.md](../databases.md) — canonical scoring rubric.
- [../web-and-http/web-apps.md](../web-and-http/web-apps.md) — mist, wisp; relevant context for the code-first OpenAPI gap.
- [../web-and-http/http-clients.md](../web-and-http/http-clients.md) — HTTP transport that consumes the encoders/decoders here.
