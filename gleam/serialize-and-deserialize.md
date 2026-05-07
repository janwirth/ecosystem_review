# Serialization and deserialization in Gleam

> [!NOTE]
> **Status:** DRAFT · **Authoring:** AI-assisted, human-reviewed.

If you want to write a Gleam value to a file, send it over the network, or hand it to another process, you have to turn it into bytes first — files, sockets, and pipes don't speak Gleam types. **Serialization** is that conversion. **Deserialization** is the reverse: read bytes back, get a typed Gleam value (or an error if the bytes are malformed).

Concretely: **Serialize** = `T → bytes` (or → spec document). **Deserialize** = `bytes → Result(T, Error)`. The bytes might be UTF-8 JSON in `config.json`, a binary CBOR payload in a WebAuthn signature, a Protobuf message on a gRPC wire, or a row of BSON in MongoDB — the destination dictates the format, but the question is the same: how do you cross the gap between your typed Gleam record and the bytes the outside world wants?

The two directions are written together because most Gleam packages bundle both — the encoder and decoder ship in the same module, around the same field names — and because the design pressure on each side is symmetric.

This article covers:

- The convention Gleam uses for both directions (and why it looks the way it does).
- **How to write encoders and decoders by hand** — the explicit, verbose, type-checked default.
- **Per-format packages** — JSON (gleam_json, jackson, juno, simplejson), binary (gleebor, gmsg, bison, protozoa, nbeet, gleb128, thirtytwo, sixtytwo, toon_codec).
- **JSON Schema / Patch / RPC tools** — castor, jscheam, sextant, squirtle, pollux.
- **Bidirectional schemas at runtime** — convert, kata, json_blueprint.
- **Wire-protocol codecs** — postgresql_protocol, h2_frame.
- **Codegen for ser/deser** — gserde, json_typedef, derived, glerd_json, aide_generator.
- **The biggest gap in the ecosystem** — Gleam → spec document (code-first OpenAPI / JSON Schema from type definitions). No library covers it.
- Cross-language framing against serde / pydantic / Jason / encoding/json / utoipa.

For text-grammar parsing where you author the grammar and for build-time emission of *non-ser/deser* Gleam code (Gleam DSLs, SQL→Gleam, OpenAPI→server stubs), see [parse-and-generate-gleam.md](parse-and-generate-gleam.md) and [parse-and-generate-other-languages.md](parse-and-generate-other-languages.md).

## Table of contents

1. [Summary](#summary)
2. [Discovery](#discovery)
3. [The encoder/decoder convention](#the-encoderdecoder-convention)
4. [Hand-written ser/deser](#hand-written-serdeser)
5. [Per-format packages](#per-format-packages)
6. [JSON Schema, JSON Patch, JSON-RPC](#json-schema-json-patch-json-rpc)
7. [Bidirectional schemas at runtime](#bidirectional-schemas-at-runtime)
8. [Wire-protocol codecs](#wire-protocol-codecs)
9. [Codegen for ser/deser](#codegen-for-serdeser)
10. [Gleam → OpenAPI (code-first spec generation)](#gleam--openapi-code-first-spec-generation)
11. [Cross-language framing](#cross-language-framing)
12. [Leaderboards](#leaderboards)
13. [Related](#related)

## Summary

**Snapshot 2026-05-07.** Gleam's ser/deser model is **explicit, hand-written by convention**, with optional escape hatches via runtime schemas or build-time codegen. The pattern is very close to Elm's `Json.Encode` / `Json.Decode` pair — and very far from Rust's `#[derive(Serialize, Deserialize)]` or Python's pydantic-style runtime reflection. There are no macros, no reflection, no struct-tag reading.

| Slice | Status |
| --- | --- |
| [Hand-written encoders + decoders](#hand-written-serdeser) | ✅ The default. `gleam/dynamic/decode` (stdlib) for the decode side, `gleam/json` builders for encode. |
| [Per-format JSON / binary packages (bidirectional)](#per-format-packages) | ✅ Coverage: JSON, CBOR, MsgPack, BSON, Protobuf, NBT, LEB128, Base32, Base62, TOON. All bundle encode + decode. |
| [JSON Schema / Patch / RPC](#json-schema-json-patch-json-rpc) | ✅ [castor](#castor), [jscheam](#jscheam), [sextant](#sextant), [squirtle](#squirtle), [pollux](#pollux). |
| [Bidirectional schemas (single source of truth at runtime)](#bidirectional-schemas-at-runtime) | ✅ [convert](#convert), [kata](#kata), [json_blueprint](#json_blueprint). Define once, derive both directions. |
| [Wire-protocol codecs](#wire-protocol-codecs) | ✅ [postgresql_protocol](#postgresql_protocol), [h2_frame](#h2_frame). |
| [Codegen for ser/deser (at build time)](#codegen-for-serdeser) | ⚠️ Several entrants, none dominant. [json_typedef](#json_typedef), [gserde](#gserde), [sara](#sara), [glerd_json](#glerd_json), [derived](#derived), [aide_generator](#aide_generator). |
| [Gleam → spec document (OpenAPI / JSON Schema from types)](#gleam--openapi-code-first-spec-generation) | ❌ **Gap.** No package emits a spec from your types or your routes. |
| [`#[derive]`-style attribute macros](#cross-language-framing) | ❌ Not possible — Gleam has no macros and no compiler plugins. |

> [!IMPORTANT]
> **The ergonomic default in Gleam is to write decoders by hand**, even when that means twenty lines of `decode.field` per record. The escape hatches exist (codegen, runtime schemas) but every one of them adds either a build step, a runtime indirection, or a dependency on an unstable third-party tool. For most projects the verbose-but-explicit baseline is the right choice; for codebases with hundreds of records the codegen route pays for itself.

> [!IMPORTANT]
> Decoders for **the official `dynamic.decode` style** (chained `decode.field(...)` calls) are the idiomatic shape across Gleam JSON libraries. You will write decoders by hand unless you reach for [codegen](#codegen-for-serdeser) to derive them at build time (e.g. [json_typedef](#json_typedef), [gserde](#gserde)).

## Discovery

Searches run on **2026-05-07** against [packages.gleam.run](https://packages.gleam.run/), plus targeted GitHub queries.

| Query | URL |
| --- | --- |
| `serialize` | [packages.gleam.run/?search=serialize](https://packages.gleam.run/?search=serialize) |
| `serializer` | [packages.gleam.run/?search=serializer](https://packages.gleam.run/?search=serializer) |
| `serde` | [packages.gleam.run/?search=serde](https://packages.gleam.run/?search=serde) (only `nimiq_serde` — blockchain-specific, not a generic library) |
| `encode` | [packages.gleam.run/?search=encode](https://packages.gleam.run/?search=encode) |
| `encoder` | [packages.gleam.run/?search=encoder](https://packages.gleam.run/?search=encoder) |
| `decode` | [packages.gleam.run/?search=decode](https://packages.gleam.run/?search=decode) |
| `decoder` | [packages.gleam.run/?search=decoder](https://packages.gleam.run/?search=decoder) |
| `derive` | [packages.gleam.run/?search=derive](https://packages.gleam.run/?search=derive) |
| `codec` | [packages.gleam.run/?search=codec](https://packages.gleam.run/?search=codec) |
| `marshal` | [packages.gleam.run/?search=marshal](https://packages.gleam.run/?search=marshal) (no hits) |
| `schema` | [packages.gleam.run/?search=schema](https://packages.gleam.run/?search=schema) |
| `json` | [packages.gleam.run/?search=json](https://packages.gleam.run/?search=json) |
| `cbor` | [packages.gleam.run/?search=cbor](https://packages.gleam.run/?search=cbor) |
| `msgpack` | [packages.gleam.run/?search=msgpack](https://packages.gleam.run/?search=msgpack) |
| `protobuf` | [packages.gleam.run/?search=protobuf](https://packages.gleam.run/?search=protobuf) |
| `bson` | [packages.gleam.run/?search=bson](https://packages.gleam.run/?search=bson) |
| `binary` | [packages.gleam.run/?search=binary](https://packages.gleam.run/?search=binary) |
| `base64` | [packages.gleam.run/?search=base64](https://packages.gleam.run/?search=base64) |
| `convert` | [packages.gleam.run/?search=convert](https://packages.gleam.run/?search=convert) |
| `kata` | [packages.gleam.run/?search=kata](https://packages.gleam.run/?search=kata) |
| `glerd` | [packages.gleam.run/?search=glerd](https://packages.gleam.run/?search=glerd) |
| `sara` | [packages.gleam.run/?search=sara](https://packages.gleam.run/?search=sara) |
| GitHub: `language:gleam openapi route` | targeted scan for un-published code-first OpenAPI tools (no results at snapshot) |

Out of scope: text-grammar parsing where you author the grammar (→ [parse-and-generate-other-languages.md](parse-and-generate-other-languages.md)); build-time emission of arbitrary Gleam source not specifically targeting ser/deser, e.g. SQL→Gleam codegen, gleamgen, trick (→ [parse-and-generate-gleam.md](parse-and-generate-gleam.md), [parse-and-generate-other-languages.md](parse-and-generate-other-languages.md)).

## The encoder/decoder convention

Gleam's stdlib ships [`gleam/dynamic/decode`](https://hexdocs.pm/gleam_stdlib/gleam/dynamic/decode.html) — an applicative-functor-style decoder builder. The companion encoder side is [`gleam/json`](https://hexdocs.pm/gleam_json/) (and the equivalent constructors in each binary-format package). The shape is symmetric.

```gleam
import gleam/dynamic/decode
import gleam/json

pub type User {
  User(name: String, age: Int)
}

// Decode side — from String/Dynamic → typed Result
fn user_decoder() -> decode.Decoder(User) {
  use name <- decode.field("name", decode.string)
  use age <- decode.field("age", decode.int)
  decode.success(User(name:, age:))
}

pub fn parse(input: String) -> Result(User, json.DecodeError) {
  json.parse(input, user_decoder())
}

// Encode side — from typed value → Json (then String)
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

Three properties to notice:

1. **The two functions name fields twice.** Field names appear in `decode.field("name", ...)` and again in `json.object([#("name", ...)])`. The compiler will not catch a typo across the two functions — only a runtime test will. This is the cost paid for not having macros. Most codebases write a round-trip property test per record (`encode |> decode == Ok(value)`) to mechanically catch drift.
2. **The decode side is partial; the encode side is total.** Decoding fails (input may be malformed); encoding does not (a typed Gleam value is always serialisable in some shape). This asymmetry is reflected in the return types — `Result(T, Error)` versus `Json`/`BitArray`.
3. **Every JSON / binary library on this page funnels through `dynamic.Dynamic` for decode and an opaque format value (`json.Json`, `cbor.Value`, etc.) for encode.** Once you know the convention, switching libraries (or formats) is mostly mechanical: the decoder *combinators* are the same shape; only the parse step at the top differs.

This explicitness is what lets every codegen / schema library on this page sit cleanly on top — they emit (or compose) exactly this shape, with no reflection layer to mis-align with.

### Why Gleam decodes by hand

The hand-written stance is deliberate, not an accident of immaturity. Gleam has:

- **No macros.** No `#[derive]`, no PPX, no compiler plugins. The compiler does not run user code at build time.
- **No reflection.** Types are erased on BEAM and absent on JS at runtime. There is no `typeof(T)` value to inspect.
- **No struct tags.** Field annotations like Go's `json:"name"` do not exist.

The closest in-language analogue is **Elm**, which Gleam inherits the dynamic-decoder pattern from: explicit, verbose, type-checked, and "no-magic". The trade-off is more code per record vs guaranteed safety + zero codegen surface.

### decode

[repo](https://hex.pm/packages/decode)

"Ergonomic dynamic decoders for Gleam." Pre-stdlib helpers; mostly subsumed by `gleam/dynamic/decode` after stdlib `>=0.41`. Useful for projects pinned to older stdlib.

## Hand-written ser/deser

The default. For most records under ~30 fields, hand-writing is shorter than any codegen setup. Patterns and pitfalls:

### Records → JSON

The pair-of-functions example above is the canonical shape. Three extensions show up routinely:

**Optional fields.** `Option(T)` for nullable, `decode.optional_field` for fields that may be absent (vs present-but-null):

```gleam
import gleam/option.{type Option, None, Some}

pub type Profile {
  Profile(name: String, bio: Option(String))
}

fn profile_decoder() -> decode.Decoder(Profile) {
  use name <- decode.field("name", decode.string)
  use bio <- decode.optional_field("bio", None, decode.optional(decode.string))
  decode.success(Profile(name:, bio:))
}

fn profile_to_json(profile: Profile) -> json.Json {
  json.object([
    #("name", json.string(profile.name)),
    #("bio", json.nullable(profile.bio, of: json.string)),
  ])
}
```

**Sum types (custom types) → tagged objects.** The idiomatic encoding is `{"type": "tag", "fields": ...}` or a discriminator field:

```gleam
pub type Event {
  ClickEvent(target: String)
  KeyEvent(key: String)
}

fn event_to_json(event: Event) -> json.Json {
  case event {
    ClickEvent(target) -> json.object([
      #("type", json.string("click")),
      #("target", json.string(target)),
    ])
    KeyEvent(key) -> json.object([
      #("type", json.string("key")),
      #("key", json.string(key)),
    ])
  }
}

fn event_decoder() -> decode.Decoder(Event) {
  use tag <- decode.field("type", decode.string)
  case tag {
    "click" -> {
      use target <- decode.field("target", decode.string)
      decode.success(ClickEvent(target:))
    }
    "key" -> {
      use key <- decode.field("key", decode.string)
      decode.success(KeyEvent(key:))
    }
    other -> decode.failure(ClickEvent(""), "unknown event type: " <> other)
  }
}
```

**Lists, dicts, nested records.** `decode.list`, `decode.dict`, and ordinary composition. Every decoder is a value, so a decoder for `List(User)` is `decode.list(user_decoder())`.

### Records → binary formats

Each binary package (`gleebor`, `gmsg`, `bison`, `protozoa`) exposes the same value-builder/decoder pattern as `gleam/json`, with format-specific primitives (e.g. `gleebor.uint`, `protozoa.varint`). Hand-writing CBOR or MessagePack encoders is the same shape as JSON; the cost is paying attention to format-specific edges (CBOR's tagged values, Protobuf's field-number assignment, BSON's ordering rules).

### When hand-writing pays off

- **Few records (<~20).** Setup cost of any codegen tool exceeds the manual line count.
- **The encoded shape diverges from the Gleam type.** Snake-case keys, flattened nested records, polymorphic discriminator schemes, version-specific output. Any divergence beats codegen by a wide margin because hand-written code can do anything; codegen tools have a fixed mapping.
- **The wire format is short-lived or under negotiation.** Don't pay codegen-setup time when the schema is not stable.

### When hand-writing hurts

- **Many similar records.** A 60-record API surface with conventional shape is 1,200+ lines of decoder/encoder boilerplate.
- **The schema is the source of truth.** When you have a `.json-typedef.json` or an OpenAPI spec, hand-writing diverges from the document on every change and creates drift bugs.
- **Round-trip correctness must be guaranteed.** Hand-written encoder/decoder pairs can disagree (typo in one field name); codegen pairs cannot.

For both of those, jump to [codegen for ser/deser](#codegen-for-serdeser) or [bidirectional schemas](#bidirectional-schemas-at-runtime).

## Per-format packages

Most Gleam ser/deser libraries are **bidirectional per format** — one library per wire format, with both encoder and decoder exposed. The package boundary is per-format, not per-direction.

> [!NOTE]
> **The package boundary is per-format, not per-direction.** Gleam's split-by-direction conceptual model (encoder vs decoder) does **not** match the package shape. A Gleam project that needs both directions of JSON imports `gleam/json` once and uses both halves of its API.

### JSON

| Tool | Approach | Notes |
| --- | --- | --- |
| [gleam_json](#gleam_json) | Official wrapper around BEAM's `jiffy` (☎️) and JS `JSON.parse` (📜) | Canonical choice; dual-target. **146★, v3.1.0**. |
| [jackson](#jackson) | Pure Gleam parser + JSON Pointer (RFC 6901) resolver | When you need pointer queries or no NIF |
| [juno](#juno) | Flexible decoding into ADT or `dynamic.Dynamic` | Convenience layer when you don't want to write a full decoder |
| [simplejson](#simplejson) | Pure Gleam parser/generator with JSONPath queries | When you need JSONPath |

#### gleam_json

[repo](https://github.com/gleam-lang/json)

Official package (`gleam-lang` org). `json.parse(input, decoder)` returns `Result(t, DecodeError)`. Dual-target — uses Erlang's `jiffy` NIF on BEAM, native `JSON.parse` on JS. The default for any new project. The encode side: `json.object/array/string/...` builders compose a `Json` value; `json.to_string()` flattens.

#### jackson

[repo](https://github.com/VioletBuse/jackson)

"A pure gleam json decoder, encoder, and json pointer resolver." Pure Gleam parser (no NIF dependency) plus RFC 6901 JSON Pointer resolution — useful for picking out values by JSON-path-like keys without writing a decoder for the surrounding shape. Symmetric encoder side. Low activity (7 commits at snapshot).

#### juno

[repo](https://github.com/massivefermion/juno)

"Flexible JSON decoding for Gleam." Returns a tagged sum representing the JSON value tree, plus convenience constructors. Useful for ad-hoc inspection / non-strict shapes where writing a strict decoder is overkill. Inverse for emission of dynamic shapes.

#### simplejson

[repo](https://github.com/pendletong/simplejson)

"Native gleam json parser/generator with jsonpath querying." Pure Gleam, dual-target, ships with JSONPath. Pick this when you want JSONPath without bolting on a separate library. Encode + decode + JSONPath in one. v1.2.0.

### Binary

Gleam has good coverage here for the formats that show up in real workloads.

| Tool | Format | Repo | Notes |
| --- | --- | --- | --- |
| [gleebor](#gleebor) | CBOR (RFC 8949) | [hex](https://hex.pm/packages/gleebor) | Pure Gleam. **⚠ Hex shows ~2 years stale at snapshot; sticky if active CBOR work is needed.** |
| [gmsg](#gmsg) | MessagePack | [hex](https://hex.pm/packages/gmsg) | Pure Gleam |
| [bison](#bison) | BSON | [hex](https://hex.pm/packages/bison) | MongoDB wire format |
| [protozoa](#protozoa) | Protocol Buffers | [hex](https://hex.pm/packages/protozoa) | Library only — no `.proto` codegen (see [parse-and-generate-other-languages.md](parse-and-generate-other-languages.md#grpc--protobuf-codegen)). v2.0.3 with companion `protozoa_dev` CLI. |
| [nbeet](#nbeet) | NBT (Minecraft) | [hex](https://hex.pm/packages/nbeet) | Niche but complete |
| [gleb128](#gleb128) | LEB128 integers | [hex](https://hex.pm/packages/gleb128) | Variable-length integer encoding |
| [thirtytwo](#thirtytwo) | Base32 (RFC 4648 + Crockford + Geohash) | [hex](https://hex.pm/packages/thirtytwo) | Multi-variant |
| [sixtytwo](#sixtytwo) | Base62 | [hex](https://hex.pm/packages/sixtytwo) | URL-safe IDs |
| [toon_codec](#toon_codec) | TOON | [hex](https://hex.pm/packages/toon_codec) | LLM-friendly JSON-replacement format. Format-specific, narrow audience. |

#### gleebor

CBOR (RFC 8949) decoder and encoder in pure Gleam. CBOR is the "JSON for binary" format used in IoT, COSE, and CTAP2 (WebAuthn). Used for COSE / CTAP2 / WebAuthn signing payloads.

#### gmsg

MessagePack — efficient binary serialisation analogous to JSON. Encode + decode. Compact JSON-equivalent for inter-service binary RPC.

#### bison

BSON — MongoDB's wire format. Encode + decode.

#### protozoa

Protocol Buffers library for Gleam. Encode + decode at the byte level. **Note:** does **not** generate Gleam types from `.proto` definitions — see [parse-and-generate-other-languages.md → gRPC / Protobuf codegen](parse-and-generate-other-languages.md#grpc--protobuf-codegen) for the codegen gap.

#### nbeet

NBT (Named Binary Tag) encoder + decoder — Minecraft's serialisation format.

#### gleb128

LEB128 (Little Endian Base 128) integer encoding/decoding — used inside protobuf, DWARF, WebAssembly, and many other binary formats.

#### thirtytwo

Base32 across RFC 4648, Crockford, and Geohash variants.

#### sixtytwo

Base62 encoding/decoding — useful for URL-safe short IDs.

#### toon_codec

TOON — an LLM-friendly JSON-replacement format. Format-specific; narrow audience, but the encode/decode shape mirrors `gleam_json`.

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

"Build schemas as well as encoding decoding from json schema file." Same author as [oas](parse-and-generate-other-languages.md#oas) and [oas_generator](parse-and-generate-other-languages.md#oas_generator). Bidirectional: parse a JSON Schema document, or build one programmatically.

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

Encode + decode + **auto-derived JSON Schema** from the same blueprint definition. Sits at the bidirectional-schema/JSON-Schema-emission boundary — closer than any other Gleam package to "describe the type once, get encoder, decoder, *and* a schema document". Worth tracking; the closest in-ecosystem path to the [Gleam → spec gap](#gleam--openapi-code-first-spec-generation) for the JSON Schema side specifically.

> [!NOTE]
> **castor and sextant emit JSON Schema, but only from runtime values.** You instantiate the schema explicitly via builders. To go from `pub type User { User(...) }` straight to a JSON Schema document **without** a hand-written builder, you would need build-time type introspection, which Gleam does not have. `glerd_json` is the closest indirect path; `json_blueprint` covers the runtime path tightly.

> [!NOTE]
> **Bidirectional schemas vs codegen.** Pick *runtime bidirectional* when the schema is a value in your program (config, conditional, dynamic). Pick *build-time codegen* when you want zero-cost generated functions and the schema is stable enough to commit. The two approaches are not mutually exclusive — `convert` for the rare dynamic schema, `json_typedef` for the bulk of static types is a reasonable mix.

## Wire-protocol codecs

Lower-level than user-facing wire formats — these are the framing bytes of established protocols.

### postgresql_protocol

[repo](https://hex.pm/packages/postgresql_protocol)

PostgreSQL wire-protocol encoder + decoder. Used by [pog](databases.md#pog-) under the hood.

### h2_frame

[repo](https://hex.pm/packages/h2_frame)

HTTP/2 frame encoder/decoder. Used by HTTP/2 server implementations.

## Codegen for ser/deser

Build-time tools whose **primary output is encoder / decoder code**. These are the "I don't want to write 200 lines of `decode.field` per record" escape hatch. Every one of them runs as a build step (`gleam run -m <tool>`) and emits `.gleam` files you commit to the repo.

| Tool | Source of truth | Emits | Stars | Notes |
| --- | --- | --- | --- | --- |
| [json_typedef](#json_typedef) | RFC 8927 JSON Type Definition | Gleam types + JSON encoders/decoders | 51★ | Schema-first; well-trusted (lpil) |
| [gserde](#gserde) | Gleam types | JSON encoders/decoders | 32★ · alpha | Type-first |
| [sara](#sara) | Gleam types w/ `//@json_encode()` / `//@json_decode()` annotations | JSON encoders/decoders in `_json.gleam` modules | 10★ | Annotation-driven; squirrel-inspired |
| [glerd_json](#glerd_json) | Gleam types via `glerd` runtime info | JSON encoders/decoders | n/v | Runtime-info-driven |
| [derived](#derived) | Gleam source w/ `!derived(...)` markers | Anything (incl. ser/deser) | 2★ | Marker-based; bring-your-own deriver |
| [aide_generator](#aide_generator) | MCP tool schemas | MCP encoders/decoders | n/v | Narrow-scope (MCP only) |

Decision flow:
- **You have a schema document** (TypeDef, OpenAPI, MCP) → use the tool that consumes that document directly. `json_typedef` for TypeDef, [oaspec](parse-and-generate-other-languages.md#oaspec) / [gilly](parse-and-generate-other-languages.md#gilly) for OpenAPI, `aide_generator` for MCP.
- **You want to start from your Gleam types** → `gserde` (full source-walking) or `sara` (per-type annotations) are the most direct matches. `glerd_json` if you already use the `glerd` runtime-info ecosystem. `derived` if you want a marker-based approach where you control the emitted shape.
- **Round-trip correctness is critical and you have many records** → schema-first (`json_typedef`) beats type-first because the schema is a single artefact you can validate the wire against.

### json_typedef

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

### gserde

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

### sara

[repo](https://github.com/gungun974/Sara) · [hexdocs](https://hexdocs.pm/sara/1.0.0/index.html)

"A Gleam serialization code generator." Annotation-driven type-first codegen: mark a custom type with `//@json_encode()` and/or `//@json_decode()`, run `gleam run -m sara`, and `sara` emits a sibling `_json.gleam` module with the encoder/decoder functions. Inspired by [squirrel](parse-and-generate-other-languages.md#squirrel-) (which uses the same "annotate + run codegen" loop for SQL). Pure Gleam, dev-dependency, dual-target.

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

### glerd_json

[hex](https://hex.pm/packages/glerd_json)

"JSON encoders/decoders codegen using Glerd." Built on top of [glerd](https://hex.pm/packages/glerd), a runtime type-information library that exposes Gleam record metadata to other tools. `glerd_json` consumes that metadata and emits encoders/decoders. Different mechanism from `gserde` (which parses Gleam source via [glance](parse-and-generate-gleam.md#glance)) — `glerd` instruments your build to expose type info at build time, then plugins like `glerd_json` consume it.

The pattern is interesting because it factors out the "extract type info" step into a shared library, so other tools (validation, GraphQL schema, etc.) can reuse it. Adoption is still small at snapshot.

### derived

[repo](https://github.com/dusty-phillips/derived)

"The gleam code generator's code generator." Marker-based: write `!derived(...)` directives in docstrings of your Gleam source, run `derived`, and the tool inserts generated code at protected markers (round-trip safe; reruns won't double-insert). For building **custom** ser/deser derivers — useful when neither `json_typedef` nor `gserde` produces the shape you want and you'd rather write a small deriver than every encoder by hand.

derived itself is **not** a JSON encoder generator out of the box; it is the framework on which one could be built. Pair with [trick](parse-and-generate-gleam.md#trick) or [gleamgen](parse-and-generate-gleam.md#gleamgen) for the code-emission half and you have a custom deriver in <100 lines.

### aide_generator

[repo](https://github.com/crowdhailer/aide_generator)

"Generate encoders and decoders for MCP tools." Narrow scope: emit ser/deser for the parameter and result types of an MCP (Model Context Protocol) tool definition. Same author as [oas](parse-and-generate-other-languages.md#oas) and [oas_generator](parse-and-generate-other-languages.md#oas_generator). Not a general-purpose codegen — but the right pick if you are building an MCP server in Gleam where tool schemas are the source of truth. See [ai.md](ai.md) for the MCP context.

### What does *not* exist (yet)

- **No `#[derive(Decode)]`-equivalent** — Gleam has no macros. The closest analogue is `gserde` (parse source, emit code) or `glerd_json` (runtime type info, emit code), neither of which is a one-liner annotation.
- **No serde-style format-pluggable codegen** — Rust's `serde` separates the "describe my type" trait from the "this format encodes booleans like X" trait, letting one derive serve JSON, CBOR, MsgPack, etc. Gleam codegen tools are **per-format** (gserde is JSON-only, json_typedef is JSON-only). A future serde-shaped Gleam tool would be a useful addition.
- **No Protobuf `.proto` codegen** — `protozoa` is library-only. Cross-link: [parse-and-generate-other-languages.md → gRPC / Protobuf codegen](parse-and-generate-other-languages.md#grpc--protobuf-codegen).

## Gleam → OpenAPI (code-first spec generation)

If you have a [mist](web-and-http/web-apps.md#mist) or [wisp](web-and-http/web-apps.md#wisp) app and want an OpenAPI spec emitted from your routes and handler types — **no such tool exists in Gleam yet**.

| Direction | Status | Tools |
| --- | --- | --- |
| Spec → Gleam (server stubs + client SDK) | ✅ covered | [oaspec](parse-and-generate-other-languages.md#oaspec), [gilly](parse-and-generate-other-languages.md#gilly), [oas_generator](parse-and-generate-other-languages.md#oas_generator) |
| **Gleam → Spec (code-first)** | ❌ **none** | — |
| Spec parsing (as a library) | ✅ covered | [oas](parse-and-generate-other-languages.md#oas) |

> [!IMPORTANT]
> If you want code-first OpenAPI in the style of [FastAPI](https://fastapi.tiangolo.com/), [Ktor](https://ktor.io/docs/openapi-spec-generation.html), [tsoa](https://tsoa-community.github.io/docs/), or [utoipa](https://github.com/juhaku/utoipa), **the Gleam ecosystem cannot give it to you today**. You will either hand-write the spec, generate it outside Gleam, or adopt the spec-first workflow with [oaspec](parse-and-generate-other-languages.md#oaspec)/[gilly](parse-and-generate-other-languages.md#gilly)/[oas_generator](parse-and-generate-other-languages.md#oas_generator).

### Why the gap exists

The structural reason: **Gleam has no runtime type reflection and no macros.** A code-first generator would have to walk the compiler AST or require developers to write a parallel description of each route (defeating the point). Neither approach has been published as a package.

What a hypothetical `mist_openapi` or `wisp_openapi` would need to do:

1. **Enumerate routes.** Both mist and wisp dispatch via ordinary Gleam pattern-match on the request — there is no declarative route registry to walk. An annotation layer or a routing DSL would need to exist first.
2. **Extract parameter and body types.** Gleam functions carry static types, but those types are erased on BEAM and absent from JS. Without macros or reflection, the generator would have to parse Gleam source (the compiler AST) at build time — or rely on `glerd`-style runtime metadata.
3. **Emit JSON Schema.** A type → schema mapper for Gleam records, custom types (sum types → `oneOf`), `Option` (nullable), `List` (array), `Dict` (`additionalProperties`), and generics.
4. **Assemble the document.** Compose into a full OpenAPI 3.x document (security schemes, servers, tags, responses) and serialise.

### What exists that could be reused

- [crowdhailer/oas](parse-and-generate-other-languages.md#oas) — data model for the output document (could be the encode side if builders + a JSON encoder were added).
- [gleam_json](#gleam_json) — JSON serialisation.
- [glance](parse-and-generate-gleam.md#glance) — Gleam source parser, the most plausible bridge to "extract types from handler functions."
- [glerd](https://hex.pm/packages/glerd) — runtime type metadata; could expose handler signatures to a generator without source-walking.
- [gleamgen](parse-and-generate-gleam.md#gleamgen) / [trick](parse-and-generate-gleam.md#trick) / [derived](#derived) — code-emit infrastructure (would emit the *registration* layer, not the spec itself).
- [json_blueprint](#json_blueprint) — already produces JSON Schema from a runtime definition; with route-walking on top, this is the shortest path to a working tool.

### What is missing

- Any published Gleam-level route registry abstraction (the mist/wisp idiom is an opaque pattern match).
- Any type-introspection mechanism that doesn't depend on parsing source. `glerd` is the only published shoe-in; it is small but well-shaped.
- An opinionated DSL that holds both handler and signature description at the same value level.

### Workarounds

- **Hand-written spec** — keep `openapi.yaml` in the repo, feed it to [oaspec](parse-and-generate-other-languages.md#oaspec) with `--check` in CI to detect drift between spec and generated server stubs. This inverts the code-first model: the **spec** is authoritative, your Gleam server is derived.
- **Spec-first as default** — if your reason for wanting code-first is "I don't want to maintain a YAML file by hand," spec-first tooling now covers enough of the OpenAPI surface that the YAML can be short and mostly auto-scaffoldable from an initial sketch.
- **Annotation DSL** — wrap routes in a small Gleam DSL that holds both the handler and a description of its inputs/outputs; a separate function walks the DSL value to emit the spec. This is the only path that avoids parsing source. Nobody has published it yet.
- **`json_blueprint` for the schema half** — if your need is just JSON Schema for request/response bodies (not the full OpenAPI document), `json_blueprint` already gives you a single-source-of-truth path. Ship the request/response schemas with your handlers and assemble them into a hand-written OpenAPI shell.

For Postman ↔ OpenAPI conversion (the inverse direction, often a workaround input), see [../postman-to-openapi-converters.md](../postman-to-openapi-converters.md).

## Cross-language framing

Gleam's runtime encoders are unremarkable — symmetric with decoders, format-per-package. The interesting framing is for **code-first ser/deser** (build-time emission of encoders/decoders from types) and for **type → spec** (build-time emission of *spec documents* from types), which are where Gleam diverges sharply.

| Language | Default ser/deser style | Cost | Drift risk | Code-first spec from types? | Mechanism |
| --- | --- | --- | --- | --- | --- |
| **Gleam** | Hand-written `decode.Decoder` / `json.object`. Codegen optional via `gserde`, `json_typedef`, `glerd_json`. | Verbose by line count, but explicit. | Field renames caught at compile time. Encoder/decoder field-name typos only caught by round-trip tests. | ❌ none | No reflection, no macros |
| **Rust** | `#[derive(Serialize, Deserialize)]` via `serde`. Macro expands at compile time. | Zero runtime overhead, terse source. | Caught at compile time (macro expansion is type-checked). | ✅ [utoipa](https://github.com/juhaku/utoipa), [aide](https://github.com/tamasfe/aide) | Procedural macros |
| **Python** | `pydantic` BaseModel with type hints; `dataclasses` + custom validation; raw `json.loads` for ad-hoc. | Pydantic v2 is fast; v1 / hand-validation slower. | Caught at validator construction. | ✅ [FastAPI](https://fastapi.tiangolo.com/), [pydantic.json_schema()](https://docs.pydantic.dev/latest/concepts/json_schema/) | Runtime reflection on type hints |
| **TypeScript** | `JSON.parse` + runtime validator (zod, io-ts). Or trust + cast. | Validator overhead, or runtime type-erasure footgun. | Worst case: cast-and-pray, undetectable until prod. | ✅ [tsoa](https://tsoa-community.github.io/docs/), [zod-to-openapi](https://github.com/asteasolutions/zod-to-openapi) | TS compiler API or runtime schema introspection |
| **Go** | Reflection on struct tags (`json:"name"`). | Runtime reflection cost. | Field-name typos in tags become silent skips (no compile error). | ✅ [swaggo/swag](https://github.com/swaggo/swag) (comments), [huma](https://github.com/danielgtaylor/huma) (struct tags) | Source comments or struct tags |
| **Kotlin** | `kotlinx.serialization` with compiler plugin. | Compile-time generation; cheap. | Caught at compile time. | ✅ [Ktor OpenAPI](https://ktor.io/docs/openapi-spec-generation.html), [springdoc-openapi](https://springdoc.org/) | KSP / annotation processing |
| **Elixir** | `Jason.decode!/1` returns a map/list tree, then pattern-match. `Jason.Encoder` protocol for typed encoding. | Cheap; tree allocation. | Map keys are strings or atoms — easy to mismatch. | ⚠️ [open_api_spex](https://github.com/open-api-spex/open_api_spex) — explicit DSL, not auto-derived from handler signatures | Schema modules built by hand |
| **Elm** | Hand-written `Json.Decode` / `Json.Encode`. Same pattern Gleam inherits. | Verbose, explicit. | Caught at compile time on the type side; round-trip tests for field-name drift. | ❌ none (no major Elm web-server framework, so the question is moot) | — |
| **OCaml** | PPX rewriters: `[@@deriving yojson, json]`. | Zero runtime cost; PPX expands at compile time. | Caught at compile time. | ⚠️ partial — schema generation possible via custom PPXes | PPX (preprocessor extension) |

The closest analogue to Gleam's code-first OpenAPI situation is **Elixir's `open_api_spex`**: an explicit schema DSL, hand-maintained, generates the spec via runtime introspection of *the schema modules* (not the handler types). A Gleam equivalent — `wisp_openapi`-style with hand-written schema modules built on `oas` + `json_blueprint` — could be built without needing macros. **It just hasn't been.**

The closest analogue to Gleam's hand-written ser/deser baseline is **Elm**: deliberately verbose, deliberately type-checked, deliberately no-magic. The Gleam ecosystem inherits that aesthetic and the ergonomic cost.

When the verbosity gets in the way: reach into [codegen for ser/deser](#codegen-for-serdeser) (`json_typedef` for schema-first, `gserde` for type-first, [trick](parse-and-generate-gleam.md#trick) for hand-rolled emit).

## Leaderboards

[How scores are calculated →](databases.md#scoring-dimensions)

### Codegen for ser/deser

| Position | Award | Repo | Source of truth | ★ | Lic | Compat | Maint | Age | README | Idiom | Score |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 🥇 | [lpil/json-typedef](https://github.com/lpil/json-typedef) | RFC 8927 TypeDef | 🟨 | 🟨 | 🟩 | 🟩 | 🟩 | 🟩 | 🟩 | **5** |
| 2 | 🥈 | [cdaringe/gserde](https://github.com/cdaringe/gserde) | Gleam types | 🟨 | 🟨 | 🟩 | 🟩 | 🟩 | 🟩 | 🟩 | **5** |
| 2 | 🥈 | [crowdhailer/aide_generator](https://github.com/crowdhailer/aide_generator) | MCP tool schemas | ⬜ | 🟩 | 🟩 | 🟩 | 🟨 | 🟩 | 🟩 | **5** |
| 2 | 🥈 | [dusty-phillips/derived](https://github.com/dusty-phillips/derived) | `!derived()` markers | 🟥 | 🟩 | 🟩 | 🟩 | 🟩 | 🟩 | 🟩 | **5** |
| 5 | — | [gungun974/Sara](https://github.com/gungun974/Sara) | Gleam types w/ annotations | 🟨 | 🟩 | 🟩 | 🟩 | 🟥 | 🟩 | 🟩 | **4** |
| 6 | — | [darky/glerd-json](https://hex.pm/packages/glerd_json) | Gleam types via `glerd` | ⬜ | ⬜ | 🟩 | 🟨 | 🟩 | 🟨 | 🟩 | **3** |

**json_typedef** wins on authority + schema-first stance + "lpil-built" trust. **gserde** is the most direct type-first answer but the alpha caveat keeps it tied. **sara** is the youngest entrant but ships a clean per-type annotation API; the squirrel-inspired loop will feel familiar to anyone using SQL codegen. **derived** is the right pick when none of the above emit the shape you want — it is the framework, not the deriver.

### Bidirectional schemas at runtime

| Position | Award | Repo | Output | ★ | Lic | Compat | Maint | Age | README | Idiom | Score |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 🥇 | [Pevensie/sextant](https://github.com/Pevensie/sextant) | JSON Schema (typed) | 🟥 | 🟩 | 🟩 | 🟩 | 🟨 | 🟩 | 🟩 | **4** |
| 2 | 🥈 | [crowdhailer/castor](https://github.com/crowdhailer/castor) | JSON Schema | 🟥 | 🟩 | 🟩 | 🟩 | 🟨 | 🟩 | 🟩 | **4** |
| 3 | 🥉 | [Billuc/convert](https://github.com/Billuc/convert) | Generic encoder/decoder | 🟥 | 🟩 | 🟩 | 🟩 | 🟨 | 🟩 | 🟩 | **4** |
| 4 | — | json_blueprint | encode + decode + JSON Schema | ⬜ | ⬜ | 🟩 | 🟩 | 🟨 | 🟩 | 🟩 | **3** |
| 5 | — | [Allianaab2m/kata-gleam](https://github.com/Allianaab2m/kata-gleam) | Generic encoder/decoder | 🟥 | 🟩 | 🟩 | 🟨 | 🟨 | 🟨 | 🟩 | **2** |

### JSON

Star counts on most JSON packages aren't surfaced individually by the search index; `gleam_json` is the dominant choice by usage (it's the official package).

| Position | Award | Repo | Approach | Score notes |
| --- | --- | --- | --- | --- |
| 1 | 🥇 | [gleam-lang/json](https://github.com/gleam-lang/json) | Official, dual-target via NIF + JS native | Default for new projects. **146★, v3.1.0**. |
| 2 | 🥈 | [VioletBuse/jackson](https://github.com/VioletBuse/jackson) | Pure Gleam + JSON Pointer | Pick when no-NIF or pointer queries needed. |
| 3 | 🥉 | [pendletong/simplejson](https://github.com/pendletong/simplejson) | Pure Gleam + JSONPath | Pick when JSONPath needed. |
| 4 | — | [massivefermion/juno](https://github.com/massivefermion/juno) | Flexible / ADT-style | Pick for ad-hoc / non-strict shapes. |

### Binary

| Position | Award | Format | Repo |
| --- | --- | --- | --- |
| 1 | 🥇 | CBOR | [gleebor](https://hex.pm/packages/gleebor) (⚠ stale at snapshot) |
| 2 | 🥈 | MessagePack | [gmsg](https://hex.pm/packages/gmsg) |
| 3 | 🥉 | Protobuf (lib only) | [protozoa](https://hex.pm/packages/protozoa) |
| 4 | — | BSON | [bison](https://hex.pm/packages/bison) |
| 5 | — | NBT | [nbeet](https://hex.pm/packages/nbeet) |

> [!NOTE]
> The 7-dimension rubric underweights binary-format libraries that have small communities by design (CBOR / MsgPack / NBT consumers are concentrated in vertical niches). Use the rubric for like-for-like JSON comparisons; for binary, prefer "is the format covered at all".

### Type-to-spec emission (code-first OpenAPI / JSON Schema from types)

| Tool | Status |
| --- | --- |
| Anything that walks Gleam types and emits OpenAPI | ❌ does not exist |
| Anything that walks Gleam types and emits JSON Schema | ⚠️ [json_blueprint](#json_blueprint) gets close (single blueprint → encode + decode + auto-Schema), but you still author the blueprint by hand |

The gap. See [Gleam → OpenAPI](#gleam--openapi-code-first-spec-generation) for the structural reasons and the workarounds.

## Related

- [parse-and-generate-gleam.md](parse-and-generate-gleam.md) — Gleam source parsers (glance) and Gleam-emitting DSLs (gleamgen, trick). The build-time machinery on which `gserde` and `derived` sit.
- [parse-and-generate-other-languages.md](parse-and-generate-other-languages.md) — parser combinators, format parsers, OpenAPI parser (`oas`), spec→Gleam codegen (`oaspec`, `gilly`), and the Protobuf `.proto` codegen gap.
- [databases.md](databases.md) — SQL→Gleam codegen produces *types and query functions*, not encoders/decoders, but uses the same code-emit infrastructure. Canonical scoring rubric lives here.
- [web-and-http/web-apps.md](web-and-http/web-apps.md) — mist, wisp; relevant context for the [code-first OpenAPI gap](#gleam--openapi-code-first-spec-generation).
- [web-and-http/http-clients.md](web-and-http/http-clients.md) — HTTP transport that consumes the encoders/decoders here.
- [ai.md](ai.md) — MCP context for `aide_generator`.
- [../postman-to-openapi-converters.md](../postman-to-openapi-converters.md) — adjacent spec-conversion workflow.
- [../formalization.md](../formalization.md) — scoring formalization.
