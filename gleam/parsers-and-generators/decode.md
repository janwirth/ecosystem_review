# Decoders in Gleam

> [!NOTE]
> **Status:** DRAFT · **Authoring:** AI-assisted, human-reviewed.

Runtime translation from a wire format (JSON / CBOR / BSON / MsgPack / Protobuf / etc.) into a typed Gleam value. The grammar is fixed and trivial — the work is mapping fields to records and validating shapes.

For text-grammar parsing (where you write the grammar yourself), see [parse.md](parse.md). For build-time codegen that emits decoders for you, see [generate.md](generate.md). For the inverse direction (typed value → wire bytes), see [serialize.md](serialize.md).

## Table of Contents

1. [Summary](#summary)
2. [Discovery](#discovery)
3. [The dynamic-decoder convention](#the-dynamic-decoder-convention)
4. [JSON decoders](#json-decoders)
5. [JSON Schema, JSON Patch, JSON-RPC](#json-schema-json-patch-json-rpc)
6. [Binary formats](#binary-formats)
7. [Bidirectional schema libraries](#bidirectional-schema-libraries)
8. [Wire-protocol codecs](#wire-protocol-codecs)
9. [Cross-language framing](#cross-language-framing)
10. [Leaderboards](#leaderboards)

## Summary

**Snapshot 2026-04-26.** Gleam's runtime decoder ecosystem is **explicit and hand-written by convention**, in deliberate contrast to reflection-based approaches in dynamic languages and macro-based approaches like Rust's serde-derive.

| Domain | Picks |
| --- | --- |
| [Dynamic decoder primitives](#the-dynamic-decoder-convention) | [`gleam/dynamic/decode`](https://hexdocs.pm/gleam_stdlib/gleam/dynamic/decode.html) (stdlib), [decode](#decode) (extras) |
| [JSON](#json-decoders) | [gleam_json](#gleam_json) (official), [jackson](#jackson), [juno](#juno), [simplejson](#simplejson) |
| [JSON Schema / Patch / RPC](#json-schema-json-patch-json-rpc) | [castor](#castor), [jscheam](#jscheam), [sextant](#sextant), [squirtle](#squirtle), [pollux](#pollux) |
| [Binary formats](#binary-formats) | [gleebor](#gleebor) (CBOR), [gmsg](#gmsg) (MsgPack), [bison](#bison) (BSON), [protozoa](#protozoa) (Protobuf), [nbeet](#nbeet) (NBT) |
| [Bidirectional schemas](#bidirectional-schema-libraries) | [convert](#convert), [kata](#kata) |
| [Wire protocols](#wire-protocol-codecs) | [postgresql_protocol](#postgresql_protocol), [h2_frame](#h2_frame) |

> [!IMPORTANT]
> Decoders for **the official `dynamic.decode` style** (chained `decode.field(...)` calls) are the idiomatic shape across Gleam JSON libraries. You will write decoders by hand unless you reach for [serialize.md → codegen](serialize.md#codegen-for-serdeser) to derive them at build time (e.g. [json_typedef](serialize.md#json_typedef), [gserde](serialize.md#gserde)).

## Discovery

Searches run on **2026-04-26** against [packages.gleam.run](https://packages.gleam.run/):

| Query | URL |
| --- | --- |
| `decode` | [packages.gleam.run/?search=decode](https://packages.gleam.run/?search=decode) |
| `decoder` | [packages.gleam.run/?search=decoder](https://packages.gleam.run/?search=decoder) |
| `json` | [packages.gleam.run/?search=json](https://packages.gleam.run/?search=json) |
| `cbor` | [packages.gleam.run/?search=cbor](https://packages.gleam.run/?search=cbor) |
| `msgpack` | [packages.gleam.run/?search=msgpack](https://packages.gleam.run/?search=msgpack) |
| `protobuf` | [packages.gleam.run/?search=protobuf](https://packages.gleam.run/?search=protobuf) |
| `bson` | [packages.gleam.run/?search=bson](https://packages.gleam.run/?search=bson) |
| `binary` | [packages.gleam.run/?search=binary](https://packages.gleam.run/?search=binary) |
| `base64` | [packages.gleam.run/?search=base64](https://packages.gleam.run/?search=base64) |
| `schema` | [packages.gleam.run/?search=schema](https://packages.gleam.run/?search=schema) |
| `convert` | [packages.gleam.run/?search=convert](https://packages.gleam.run/?search=convert) |

Out of scope: the parser-combinator surface used for reading text grammars (→ [parse.md](parse.md)).

## The dynamic-decoder convention

Gleam's stdlib ships [`gleam/dynamic/decode`](https://hexdocs.pm/gleam_stdlib/gleam/dynamic/decode.html) — an applicative-functor-style decoder builder. Almost every JSON library on this page hands its parsed value to `dynamic.Dynamic`, then expects you to compose a `decode.Decoder` to extract the typed shape:

```gleam
import gleam/dynamic/decode
import gleam/json

pub type User {
  User(name: String, age: Int)
}

fn user_decoder() -> decode.Decoder(User) {
  use name <- decode.field("name", decode.string)
  use age <- decode.field("age", decode.int)
  decode.success(User(name:, age:))
}

pub fn parse(input: String) -> Result(User, json.DecodeError) {
  json.parse(input, user_decoder())
}
```

This explicitness is intentional — it is what makes [generate.md](generate.md) tools like `json_typedef` and `gserde` sit cleanly on top: they emit exactly this shape and there is no reflection layer to mis-align with.

### decode
[repo](https://hex.pm/packages/decode)

"Ergonomic dynamic decoders for Gleam." Pre-stdlib helpers; mostly subsumed by `gleam/dynamic/decode` after stdlib `>=0.41`. Useful for projects pinned to older stdlib.

## JSON decoders

| Tool | Approach | Stars | Notes |
| --- | --- | --- | --- |
| [gleam_json](#gleam_json) | Official wrapper around BEAM's `jiffy` (☎️) and JS `JSON.parse` (📜) | — | Canonical choice; dual-target |
| [jackson](#jackson) | Pure Gleam parser + JSON Pointer (RFC 6901) resolver | — | When you need pointer queries or no NIF |
| [juno](#juno) | Flexible decoding into ADT or `dynamic.Dynamic` | — | Convenience layer when you don't want to write a full decoder |
| [simplejson](#simplejson) | Pure Gleam parser/generator with JSONPath queries | — | When you need JSONPath |

### gleam_json
[repo](https://github.com/gleam-lang/json)

Official package (`gleam-lang` org). `json.parse(input, decoder)` returns `Result(t, DecodeError)`. Dual-target — uses Erlang's `jiffy` NIF on BEAM, native `JSON.parse` on JS. The default for any new project.

### jackson
[repo](https://github.com/VioletBuse/jackson)

"A pure gleam json decoder, encoder, and json pointer resolver." Pure Gleam parser (no NIF dependency) plus RFC 6901 JSON Pointer resolution — useful for picking out values by JSON-path-like keys without writing a decoder for the surrounding shape.

### juno
[repo](https://github.com/massivefermion/juno)

"Flexible JSON decoding for Gleam." Returns a tagged sum representing the JSON value tree, plus convenience constructors. Useful for ad-hoc inspection / non-strict shapes where writing a strict decoder is overkill.

### simplejson
[repo](https://github.com/pendletong/simplejson)

"Native gleam json parser/generator with jsonpath querying." Pure Gleam, dual-target, ships with JSONPath. Pick this when you want JSONPath without bolting on a separate library.

## JSON Schema, JSON Patch, JSON-RPC

| Tool | Standard | Notes |
| --- | --- | --- |
| [castor](#castor) | JSON Schema | Build, encode, and decode JSON Schema documents |
| [jscheam](#jscheam) | JSON Schema (subset) | Smaller surface; schema construction + validation |
| [sextant](#sextant) | JSON Schema | Type-safe JSON Schema generation + validation |
| [squirtle](#squirtle) | JSON Patch (RFC 6902) | Apply patch documents to JSON |
| [pollux](#pollux) | JSON-RPC 2.0 | Request/response framing |

### castor
[repo](https://github.com/crowdhailer/castor)

"Build schemas as well as encoding decoding from json schema file." Same author as [oas](parse.md#oas) and [oas_generator](generate.md#oas_generator). Bidirectional: parse a JSON Schema document, or build one programmatically.

### jscheam

A smaller JSON Schema library. Surface scoped to common subset rather than the full spec.

### sextant

Type-safe JSON Schema generation and validation in Gleam.

### squirtle
[repo](https://hex.pm/packages/squirtle)

JSON Patch (RFC 6902) implementation — apply patch documents (`add`, `remove`, `replace`, `move`, `copy`, `test`) to JSON.

### pollux

JSON-RPC 2.0 framing — request/response/notification structures and envelopes. Pair with `gleam_json` for transport.

## Binary formats

Gleam has good coverage here for the formats that show up in real workloads.

| Tool | Format | Repo | Notes |
| --- | --- | --- | --- |
| [gleebor](#gleebor) | CBOR (RFC 8949) | [hex](https://hex.pm/packages/gleebor) | Pure Gleam |
| [gmsg](#gmsg) | MessagePack | [hex](https://hex.pm/packages/gmsg) | Pure Gleam |
| [bison](#bison) | BSON | [hex](https://hex.pm/packages/bison) | MongoDB wire format |
| [protozoa](#protozoa) | Protocol Buffers | [hex](https://hex.pm/packages/protozoa) | Library only — no `.proto` codegen (see [generate.md](generate.md#grpc--protobuf-codegen)) |
| [nbeet](#nbeet) | NBT (Minecraft) | [hex](https://hex.pm/packages/nbeet) | Niche but complete |
| [gleb128](#gleb128) | LEB128 integers | [hex](https://hex.pm/packages/gleb128) | Variable-length integer encoding |
| [thirtytwo](#thirtytwo) | Base32 (RFC 4648 + Crockford + Geohash) | [hex](https://hex.pm/packages/thirtytwo) | Multi-variant |
| [sixtytwo](#sixtytwo) | Base62 | [hex](https://hex.pm/packages/sixtytwo) | URL-safe IDs |

### gleebor

CBOR (RFC 8949) decoder and encoder in pure Gleam. CBOR is the "JSON for binary" format used in IoT, COSE, and CTAP2 (WebAuthn).

### gmsg

MessagePack — efficient binary serialisation analogous to JSON. Encode + decode.

### bison

BSON — MongoDB's wire format. Encode + decode.

### protozoa

Protocol Buffers library for Gleam. Encode + decode at the byte level. **Note:** does **not** generate Gleam types from `.proto` definitions — see [generate.md](generate.md#grpc--protobuf-codegen) for the codegen gap.

### nbeet

NBT (Named Binary Tag) encoder + decoder — Minecraft's serialisation format.

### gleb128

LEB128 (Little Endian Base 128) integer encoding/decoding — used inside protobuf, DWARF, WebAssembly, and many other binary formats.

### thirtytwo

Base32 across RFC 4648, Crockford, and Geohash variants.

### sixtytwo

Base62 encoding/decoding — useful for URL-safe short IDs.

## Bidirectional schema libraries

Define a schema once, get both encoder and decoder.

### convert
[repo](https://hex.pm/packages/convert)

"Utilities to create encoders and decoders from basic and complex types." Single definition emits both directions.

### kata
[repo](https://hex.pm/packages/kata)

Bidirectional schema library — single source-of-truth for both directions of conversion.

> [!NOTE]
> Bidirectional schemas overlap with the [serialize.md → codegen](serialize.md#codegen-for-serdeser) story: `convert` and `kata` keep both directions in sync at **runtime**, while `json_typedef` and `gserde` keep them in sync via **build-time** code emission. Pick runtime-bidirectional when you want a single value to drive both directions; pick build-time codegen when you want zero-cost generated functions and don't mind a separate build step.

## Wire-protocol codecs

Lower-level than user-facing wire formats — these are the framing bytes of established protocols.

### postgresql_protocol
[repo](https://hex.pm/packages/postgresql_protocol)

PostgreSQL wire-protocol encoder + decoder. Used by [pog](../databases.md#pog-) under the hood.

### h2_frame
[repo](https://hex.pm/packages/h2_frame)

HTTP/2 frame encoder/decoder. Used by HTTP/2 server implementations.

## Cross-language framing

How Gleam's runtime-decoder model compares to other languages, since the same job is solved very differently elsewhere.

| Language | Default style | Cost | Drift risk |
| --- | --- | --- | --- |
| **Gleam** | Hand-written `decode.Decoder` chained from primitives ([`gleam/dynamic/decode`](https://hexdocs.pm/gleam_stdlib/gleam/dynamic/decode.html)). Build-time codegen optional via [json_typedef](serialize.md#json_typedef) / [gserde](serialize.md#gserde). | Verbose by line count, but explicit. | Field renames caught at compile time. |
| **Rust** | `#[derive(Deserialize)]` via `serde`. Macro expands to a hand-written-equivalent decoder at compile time. | Zero runtime overhead, terse source. | Caught at compile time (macro expansion is type-checked). |
| **Go** | Reflection on struct tags (`json:"name"`). | Runtime reflection cost. | Field-name typos in tags become silent skips (no compile error). |
| **Elixir** | `Jason.decode!/1` returns a map/list tree, then pattern-match. Optional struct shapes via `Jason.Encoder`/`Jason.decode_into/2`. | Cheap; tree allocation. | Map keys are strings or atoms — easy to mismatch. |
| **TypeScript** | `JSON.parse()` + a runtime validator (`zod`, `io-ts`, `ts-json-validator`) or just trust + cast. | Validator overhead, or runtime type-erasure footgun. | Worst case: cast-and-pray, undetectable until prod. |
| **Python** | `json.loads()` + `pydantic`/`dataclasses` validation. | Pydantic v2 is fast; v1 / hand-validation slower. | Caught at validator construction. |

Gleam sits closest to **Elm** (which it inherits the dynamic-decoder pattern from): explicit, verbose, type-checked. It is the "no-magic" end of the spectrum. The trade-off is more code per record vs guaranteed safety + zero codegen surface.

When the verbosity gets in the way: reach into [serialize.md → codegen for ser/deser](serialize.md#codegen-for-serdeser) (`json_typedef` for schema-first, `gserde` for type-first, [trick](generate.md#trick) for hand-rolled emit).

## Leaderboards

Star counts on most decode packages aren't surfaced individually by the search index; `gleam_json` is the dominant choice by usage (it's the official package).

### JSON

| Position | Award | Repo | Approach | Score notes |
| --- | --- | --- | --- | --- |
| 1 | 🥇 | [gleam-lang/json](https://github.com/gleam-lang/json) | Official, dual-target via NIF + JS native | Default for new projects. |
| 2 | 🥈 | [VioletBuse/jackson](https://github.com/VioletBuse/jackson) | Pure Gleam + JSON Pointer | Pick when no-NIF or pointer queries needed. |
| 3 | 🥉 | [pendletong/simplejson](https://github.com/pendletong/simplejson) | Pure Gleam + JSONPath | Pick when JSONPath needed. |
| 4 | — | [massivefermion/juno](https://github.com/massivefermion/juno) | Flexible / ADT-style | Pick for ad-hoc / non-strict shapes. |

### Binary

| Position | Award | Format | Repo |
| --- | --- | --- | --- |
| 1 | 🥇 | CBOR | [gleebor](https://hex.pm/packages/gleebor) |
| 2 | 🥈 | MessagePack | [gmsg](https://hex.pm/packages/gmsg) |
| 3 | 🥉 | Protobuf (lib only) | [protozoa](https://hex.pm/packages/protozoa) |
| 4 | — | BSON | [bison](https://hex.pm/packages/bison) |
| 5 | — | NBT | [nbeet](https://hex.pm/packages/nbeet) |

> [!NOTE]
> The 7-dimension rubric in [README.md](README.md#scoring-rubric-shared) underweights binary-format libraries that have small communities by design (CBOR / MsgPack / NBT consumers are concentrated in vertical niches). Use the rubric for like-for-like JSON comparisons; for binary, prefer "is the format covered at all".

## Related

- [parse.md](parse.md) — text-grammar parsing where you author the grammar.
- [generate.md](generate.md) — build-time emission of the decoders documented here.
- [serialize.md](serialize.md) — the opposite direction (typed value → wire bytes).
