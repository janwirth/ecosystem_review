# Serializers in Gleam

> [!NOTE]
> **Status:** DRAFT · **Authoring:** AI-assisted, human-reviewed.

Runtime translation from a typed Gleam value into a wire format (JSON / CBOR / MsgPack / etc.) or a spec document (OpenAPI, JSON Schema). The structural inverse of [decode.md](decode.md).

This article also covers the **biggest current gap** in the Gleam ecosystem: **Gleam → OpenAPI (code-first)**. No package introspects mist/wisp routes and emits a spec.

For build-time emission of *code* (rather than runtime emission of *bytes*), see [generate.md](generate.md). For text-grammar parsing, see [parse.md](parse.md).

## Table of Contents

1. [Summary](#summary)
2. [Discovery](#discovery)
3. [JSON encoders](#json-encoders)
4. [Binary encoders](#binary-encoders)
5. [Bidirectional schema serializers](#bidirectional-schema-serializers)
6. [Gleam → OpenAPI (code-first spec generation)](#gleam--openapi-code-first-spec-generation)
7. [Cross-language framing](#cross-language-framing)
8. [Leaderboards](#leaderboards)

## Summary

**Snapshot 2026-04-26.** Gleam's runtime serialization story is **the inverse of [decode.md](decode.md)**: most of the same packages (`gleam_json`, `jackson`, `gleebor`, `gmsg`, `bison`, `protozoa`) provide both encode and decode in a single library. The interesting unique-to-serialize content lives in **spec generation** — what the Gleam ecosystem can produce as an output document (OpenAPI, JSON Schema), and what it cannot.

| Slice | Status |
| --- | --- |
| [JSON encoding](#json-encoders) | ✅ Fully covered (gleam_json, jackson, juno, simplejson — all bidirectional with [decode.md](decode.md#json-decoders)) |
| [Binary encoding](#binary-encoders) | ✅ Covered (CBOR, MsgPack, BSON, Protobuf — bidirectional) |
| [JSON Schema generation](#bidirectional-schema-serializers) | ✅ Covered ([castor](decode.md#castor), [sextant](decode.md#sextant)) |
| [Gleam → OpenAPI](#gleam--openapi-code-first-spec-generation) | ❌ **Gap.** No code-first spec generator exists. |
| Gleam → GraphQL Schema | ❌ Gap. |
| Gleam → JSON Schema (from types, not values) | ❌ Gap (sextant generates from values, not from `type` definitions). |

> [!IMPORTANT]
> The pattern: **runtime encoding is solved**; **build-time emission of *spec documents* derived from your types is not**. The structural reason is the same one that limits [generate.md](generate.md): Gleam has no macros and no runtime reflection.

## Discovery

Searches run on **2026-04-26** against [packages.gleam.run](https://packages.gleam.run/):

| Query | URL |
| --- | --- |
| `serialize` | [packages.gleam.run/?search=serialize](https://packages.gleam.run/?search=serialize) |
| `serializer` | [packages.gleam.run/?search=serializer](https://packages.gleam.run/?search=serializer) |
| `encode` | [packages.gleam.run/?search=encode](https://packages.gleam.run/?search=encode) |
| `encoder` | [packages.gleam.run/?search=encoder](https://packages.gleam.run/?search=encoder) |
| `marshal` | [packages.gleam.run/?search=marshal](https://packages.gleam.run/?search=marshal) (no hits) |
| `json` | [packages.gleam.run/?search=json](https://packages.gleam.run/?search=json) |
| `openapi` | [packages.gleam.run/?search=openapi](https://packages.gleam.run/?search=openapi) |
| `swagger` | [packages.gleam.run/?search=swagger](https://packages.gleam.run/?search=swagger) |
| GitHub: `language:gleam openapi route` | targeted scan for un-published code-first OpenAPI tools (no results at snapshot) |

## JSON encoders

The same packages from [decode.md](decode.md#json-decoders) — they encode and decode out of the same module. Gleam's split-by-direction conceptual model does not match the package boundary; the package boundary is per-format.

| Tool | Repo | Encode-side notes |
| --- | --- | --- |
| [gleam_json](decode.md#gleam_json) | [github.com/gleam-lang/json](https://github.com/gleam-lang/json) | `json.object/array/string/...` builders compose a `Json` value, then `json.to_string()`. Canonical, dual-target. |
| [jackson](decode.md#jackson) | [github.com/VioletBuse/jackson](https://github.com/VioletBuse/jackson) | Pure-Gleam encoder side; symmetric with the decoder/pointer story. |
| [juno](decode.md#juno) | [github.com/massivefermion/juno](https://github.com/massivefermion/juno) | Inverse of the flexible decoder — convenient for ad-hoc emission. |
| [simplejson](decode.md#simplejson) | [github.com/pendletong/simplejson](https://github.com/pendletong/simplejson) | Encode + decode + JSONPath in one. |

Hand-written `gleam_json` encoder for the [decode.md example](decode.md#the-dynamic-decoder-convention):

```gleam
import gleam/json

pub type User {
  User(name: String, age: Int)
}

pub fn user_to_json(user: User) -> json.Json {
  json.object([
    #("name", json.string(user.name)),
    #("age", json.int(user.age)),
  ])
}

pub fn encode(user: User) -> String {
  user_to_json(user) |> json.to_string
}
```

When the verbosity gets in the way, see [generate.md](generate.md):
- **[json_typedef](generate.md#json_typedef)** — schema-first: define a TypeDef, get encoders + decoders.
- **[gserde](generate.md#gserde)** — type-first: define a Gleam type, get encoders + decoders.
- **[trick](generate.md#trick)** / **[gleamgen](generate.md#gleamgen)** — emit your own custom encoders.

## Binary encoders

Same per-format-package shape as JSON. All bidirectional; cross-link to [decode.md](decode.md#binary-formats) for the table.

| Format | Tool | Encode-side notes |
| --- | --- | --- |
| CBOR (RFC 8949) | [gleebor](decode.md#gleebor) | Used for COSE / CTAP2 / WebAuthn signing payloads. |
| MessagePack | [gmsg](decode.md#gmsg) | Compact JSON-equivalent for inter-service binary RPC. |
| BSON | [bison](decode.md#bison) | MongoDB wire format. |
| Protobuf | [protozoa](decode.md#protozoa) | Library-only; no `.proto` codegen (see [generate.md](generate.md#grpc--protobuf-codegen)). |
| NBT | [nbeet](decode.md#nbeet) | Minecraft. |
| LEB128 | [gleb128](decode.md#gleb128) | Used inside protobuf, DWARF, WebAssembly. |
| Base32 | [thirtytwo](decode.md#thirtytwo) | RFC 4648 + Crockford + Geohash. |
| Base62 | [sixtytwo](decode.md#sixtytwo) | URL-safe IDs. |

## Bidirectional schema serializers

Schemas where you define the shape once and the library produces both encoder + decoder.

- **[convert](decode.md#convert)** — runtime; single-definition encoders/decoders for basic and complex types.
- **[kata](decode.md#kata)** — runtime; bidirectional schema library.
- **[castor](decode.md#castor)** — JSON Schema documents: build, encode, decode.
- **[sextant](decode.md#sextant)** — type-safe JSON Schema generation + validation.

> [!NOTE]
> `castor` and `sextant` can **emit JSON Schema**, but only from runtime values (you instantiate the schema explicitly) — not from Gleam *type definitions*. To go from `pub type User { User(...) }` straight to a JSON Schema document without a hand-written builder, you need build-time codegen (`json_typedef` is the closest: it derives types-and-codecs from a TypeDef document, but the inverse `Gleam type → TypeDef` doesn't exist).

## Gleam → OpenAPI (code-first spec generation)

If you have a [mist](../web-and-http/web-apps.md#mist) or [wisp](../web-and-http/web-apps.md#wisp) app and want an OpenAPI spec emitted from your routes and handler types — **no such tool exists in Gleam yet**.

| Direction | Status | Tools |
| --- | --- | --- |
| Spec → Gleam (server stubs + client SDK) | ✅ covered | [oaspec](generate.md#oaspec), [gilly](generate.md#gilly), [oas_generator](generate.md#oas_generator) |
| **Gleam → Spec (code-first)** | ❌ **none** | — |
| Spec parsing (as a library) | ✅ covered | [oas](parse.md#oas) |

> [!IMPORTANT]
> If you want code-first OpenAPI in the style of [FastAPI](https://fastapi.tiangolo.com/), [Ktor](https://ktor.io/docs/openapi-spec-generation.html), [tsoa](https://tsoa-community.github.io/docs/), or [utoipa](https://github.com/juhaku/utoipa), **the Gleam ecosystem cannot give it to you today**. You will either hand-write the spec, generate it outside Gleam, or adopt the spec-first workflow with [oaspec](generate.md#oaspec)/[gilly](generate.md#gilly)/[oas_generator](generate.md#oas_generator).

### Why the gap exists

The structural reason: **Gleam has no runtime type reflection and no macros.** A code-first generator would have to walk the compiler AST or require developers to write a parallel description of each route (defeating the point). Neither approach exists as a published package.

What a hypothetical `mist_openapi` or `wisp_openapi` would need to do:

1. **Enumerate routes.** Both mist and wisp dispatch via ordinary Gleam pattern-match on the request — there is no declarative route registry to walk. An annotation layer or a routing DSL would need to exist first.
2. **Extract parameter and body types.** Gleam functions carry static types, but those types are erased on BEAM and absent from JS. Without macros or reflection, the generator would have to parse Gleam source (the compiler AST) at build time.
3. **Emit JSON Schema.** A type → schema mapper for Gleam records, custom types (sum types → `oneOf`), `Option` (nullable), `List` (array), `Dict` (`additionalProperties`), and generics.
4. **Assemble the document.** Compose into a full OpenAPI 3.x document (security schemes, servers, tags, responses) and serialise.

### What exists that could be reused

- [crowdhailer/oas](parse.md#oas) — data model for the output document (could be the encode side if builders + a JSON encoder were added).
- [gleam_json](#json-encoders) — JSON serialisation.
- [glance](parse.md#glance) — Gleam source parser, the most plausible bridge to "extract types from handler functions."
- [gleamgen](generate.md#gleamgen) / [trick](generate.md#trick) / [derived](generate.md#derived) — code-emit infrastructure (would emit the *registration* layer, not the spec itself).
- Gleam compiler's published package metadata — type information exists in `.cache_meta` / HexDocs JSON, in principle reachable.

### What is missing

- Any published Gleam-level route registry abstraction (the mist/wisp idiom is an opaque pattern match).
- Any type-introspection mechanism. Gleam has [no macros](https://github.com/gleam-lang/gleam/issues/1767) and no runtime reflection by design, so the path is source-level codegen against the compiler AST — a non-trivial dependency on unstable compiler internals.

### Workarounds

- **Hand-written spec** — keep `openapi.yaml` in the repo, feed it to [oaspec](generate.md#oaspec) with `--check` in CI to detect drift between spec and generated server stubs. This inverts the code-first model: the **spec** is authoritative, your Gleam server is derived.
- **Spec-first as default** — if your reason for wanting code-first is "I don't want to maintain a YAML file by hand," spec-first tooling now covers enough of the OpenAPI surface that the YAML can be short and mostly auto-scaffoldable from an initial sketch.
- **Annotation DSL** — wrap routes in a small Gleam DSL that holds both the handler and a description of its inputs/outputs; a separate function walks the DSL value to emit the spec. This is the only path that avoids parsing source. Nobody has built it yet.

## Cross-language framing

Gleam's runtime encoders are unremarkable — symmetric with decoders, format-per-package. The interesting framing is for **build-time spec emission from types**, which is where Gleam diverges sharply.

| Language | Type → Spec (e.g. → OpenAPI / JSON Schema) | Mechanism |
| --- | --- | --- |
| **Gleam** | ❌ none | No reflection, no macros |
| **Rust** | ✅ [utoipa](https://github.com/juhaku/utoipa), [aide](https://github.com/tamasfe/aide) | `#[derive(ToSchema)]` macros |
| **Python** | ✅ [FastAPI](https://fastapi.tiangolo.com/), [pydantic](https://docs.pydantic.dev/latest/concepts/json_schema/) | Runtime reflection on type hints |
| **TypeScript** | ✅ [tsoa](https://tsoa-community.github.io/docs/), [zod-to-openapi](https://github.com/asteasolutions/zod-to-openapi) | TS compiler API + decorators / runtime schema introspection |
| **Kotlin** | ✅ [Ktor OpenAPI](https://ktor.io/docs/openapi-spec-generation.html), [springdoc-openapi](https://springdoc.org/) | KSP / annotation processing |
| **Go** | ✅ [swaggo/swag](https://github.com/swaggo/swag) (comments), [huma](https://github.com/danielgtaylor/huma) (struct tags) | Source comments or struct tags |
| **Elixir** | ⚠️ [open_api_spex](https://github.com/open-api-spex/open_api_spex) — explicit DSL, not auto-derived from handler signatures | Schema modules built by hand |
| **Elm** | ❌ none (Elm has no major web-server framework, so the question is moot) | — |

The closest analogue to Gleam's situation is **Elixir's open_api_spex**: an explicit schema DSL, hand-maintained, generates the spec via runtime introspection of *the schema modules* (not the handler types). A Gleam equivalent — `wisp_openapi`-style with hand-written schema modules — could be built on top of [oas](parse.md#oas) + [gleam_json](#json-encoders) without needing macros. **It just hasn't been.**

## Leaderboards

The encode side of the JSON / binary leaderboards is identical to [decode.md → leaderboards](decode.md#leaderboards) — the packages are the same. Pick by decoder fit; the encoder follows.

### Schema-emission tools

| Tool | Emits | Notes |
| --- | --- | --- |
| [castor](decode.md#castor) | JSON Schema | Build-and-encode at runtime |
| [sextant](decode.md#sextant) | JSON Schema | Type-safe builders |
| [json_typedef](generate.md#json_typedef) | (consumes) RFC 8927 TypeDef | Reverse direction not supported |

### Type-to-spec emission

Empty. This is the gap. See [Gleam → OpenAPI](#gleam--openapi-code-first-spec-generation).

## Related

- [decode.md](decode.md) — the inverse direction, with the same per-format packages.
- [generate.md](generate.md) — build-time code emission (fills the "I don't want to hand-write encoders for every record" use case).
- [parse.md](parse.md) — `oas` (OpenAPI parser) is the data model that any future Gleam→OpenAPI tool would build on.
- [../web-and-http/web-apps.md](../web-and-http/web-apps.md) — mist, wisp; relevant context for the gap.
