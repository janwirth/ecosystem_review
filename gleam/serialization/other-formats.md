# Other formats: encode / decode (non-JSON)

> [!NOTE]
> **Status:** DRAFT · **Authoring:** AI-assisted, human-reviewed.

JSON is the default wire format on the web, but plenty of Gleam workloads cross other byte boundaries — CBOR for WebAuthn, MessagePack for inter-service binary RPC, BSON for MongoDB, Protobuf on gRPC, NBT for Minecraft, LEB128 inside DWARF/Wasm, Base32/62 for IDs, TOON for LLM prompts, the PostgreSQL wire protocol for `pog`. Each format has its own Gleam package; the encoder + decoder ship together because they are symmetric.

This article covers all the **non-JSON** ser/deser packages: per-format binary libraries plus low-level wire-protocol codecs. For JSON specifically (gleam_json, jackson, juno, simplejson, plus JSON Schema/Patch/RPC, plus runtime bidirectional schemas), see [runtime-bidirectional-json.md](runtime-bidirectional-json.md). For build-time JSON codegen, see [codegen-json.md](codegen-json.md). For the foundational hand-written pattern, see the folder [README](README.md).

## Table of contents

1. [Summary](#summary)
2. [Discovery](#discovery)
3. [Binary formats](#binary-formats)
4. [Wire-protocol codecs](#wire-protocol-codecs)
5. [Records → binary formats (hand-written)](#records--binary-formats-hand-written)
6. [Leaderboard](#leaderboard)
7. [Related](#related)

## Summary

**Snapshot 2026-05-07.** Coverage is good for the formats that show up in real workloads.

| Format | Package | Notes |
| --- | --- | --- |
| CBOR (RFC 8949) | [gleebor](#gleebor) | Pure Gleam. **⚠ Hex shows ~2 years stale at snapshot.** WebAuthn / COSE / CTAP2 use case. |
| MessagePack | [gmsg](#gmsg) | Pure Gleam |
| BSON | [bison](#bison) | MongoDB wire format |
| Protocol Buffers | [protozoa](#protozoa) | Library only — no `.proto` codegen. v2.0.3 with companion `protozoa_dev` CLI. |
| NBT (Minecraft) | [nbeet](#nbeet) | Niche but complete |
| LEB128 integers | [gleb128](#gleb128) | Variable-length integer encoding |
| Base32 (RFC 4648 / Crockford / Geohash) | [thirtytwo](#thirtytwo) | Multi-variant |
| Base62 | [sixtytwo](#sixtytwo) | URL-safe IDs |
| TOON | [toon_codec](#toon_codec) | LLM-friendly JSON-replacement format |
| PostgreSQL wire protocol | [postgresql_protocol](#postgresql_protocol) | Used by [pog](../databases.md#pog-) |
| HTTP/2 frames | [h2_frame](#h2_frame) | Used by HTTP/2 server implementations |

## Discovery

Searches run on **2026-05-07** against [packages.gleam.run](https://packages.gleam.run/), plus targeted GitHub queries.

| Query | URL |
| --- | --- |
| `cbor` | [packages.gleam.run/?search=cbor](https://packages.gleam.run/?search=cbor) |
| `msgpack` | [packages.gleam.run/?search=msgpack](https://packages.gleam.run/?search=msgpack) |
| `protobuf` | [packages.gleam.run/?search=protobuf](https://packages.gleam.run/?search=protobuf) |
| `bson` | [packages.gleam.run/?search=bson](https://packages.gleam.run/?search=bson) |
| `binary` | [packages.gleam.run/?search=binary](https://packages.gleam.run/?search=binary) |
| `base64` | [packages.gleam.run/?search=base64](https://packages.gleam.run/?search=base64) |
| `codec` | [packages.gleam.run/?search=codec](https://packages.gleam.run/?search=codec) |
| `encode` | [packages.gleam.run/?search=encode](https://packages.gleam.run/?search=encode) |
| `decode` | [packages.gleam.run/?search=decode](https://packages.gleam.run/?search=decode) |

## Binary formats

> [!NOTE]
> **The package boundary is per-format, not per-direction.** Every package in this section ships encoder + decoder together. A Gleam project that needs both directions of CBOR imports `gleebor` once and uses both halves of its API.

| Tool | Format | Repo | Notes |
| --- | --- | --- | --- |
| [gleebor](#gleebor) | CBOR (RFC 8949) | [hex](https://hex.pm/packages/gleebor) | Pure Gleam. **⚠ Hex shows ~2 years stale at snapshot; sticky if active CBOR work is needed.** |
| [gmsg](#gmsg) | MessagePack | [hex](https://hex.pm/packages/gmsg) | Pure Gleam |
| [bison](#bison) | BSON | [hex](https://hex.pm/packages/bison) | MongoDB wire format |
| [protozoa](#protozoa) | Protocol Buffers | [hex](https://hex.pm/packages/protozoa) | Library only — no `.proto` codegen (see [parse-and-generate-other-languages.md](../parse-and-generate-other-languages.md#grpc--protobuf-codegen)). v2.0.3 with companion `protozoa_dev` CLI. |
| [nbeet](#nbeet) | NBT (Minecraft) | [hex](https://hex.pm/packages/nbeet) | Niche but complete |
| [gleb128](#gleb128) | LEB128 integers | [hex](https://hex.pm/packages/gleb128) | Variable-length integer encoding |
| [thirtytwo](#thirtytwo) | Base32 (RFC 4648 + Crockford + Geohash) | [hex](https://hex.pm/packages/thirtytwo) | Multi-variant |
| [sixtytwo](#sixtytwo) | Base62 | [hex](https://hex.pm/packages/sixtytwo) | URL-safe IDs |
| [toon_codec](#toon_codec) | TOON | [hex](https://hex.pm/packages/toon_codec) | LLM-friendly JSON-replacement format. Format-specific, narrow audience. |

### gleebor

CBOR (RFC 8949) decoder and encoder in pure Gleam. CBOR is the "JSON for binary" format used in IoT, COSE, and CTAP2 (WebAuthn). Used for COSE / CTAP2 / WebAuthn signing payloads.

### gmsg

MessagePack — efficient binary serialisation analogous to JSON. Encode + decode. Compact JSON-equivalent for inter-service binary RPC.

### bison

BSON — MongoDB's wire format. Encode + decode.

### protozoa

Protocol Buffers library for Gleam. Encode + decode at the byte level. **Note:** does **not** generate Gleam types from `.proto` definitions — see [parse-and-generate-other-languages.md → gRPC / Protobuf codegen](../parse-and-generate-other-languages.md#grpc--protobuf-codegen) for the codegen gap.

### nbeet

NBT (Named Binary Tag) encoder + decoder — Minecraft's serialisation format.

### gleb128

LEB128 (Little Endian Base 128) integer encoding/decoding — used inside protobuf, DWARF, WebAssembly, and many other binary formats.

### thirtytwo

Base32 across RFC 4648, Crockford, and Geohash variants.

### sixtytwo

Base62 encoding/decoding — useful for URL-safe short IDs.

### toon_codec

TOON — an LLM-friendly JSON-replacement format. Format-specific; narrow audience, but the encode/decode shape mirrors `gleam_json`.

## Wire-protocol codecs

Lower-level than user-facing wire formats — these are the framing bytes of established protocols.

### postgresql_protocol

[repo](https://hex.pm/packages/postgresql_protocol)

PostgreSQL wire-protocol encoder + decoder. Used by [pog](../databases.md#pog-) under the hood.

### h2_frame

[repo](https://hex.pm/packages/h2_frame)

HTTP/2 frame encoder/decoder. Used by HTTP/2 server implementations.

## Records → binary formats (hand-written)

Each binary package (`gleebor`, `gmsg`, `bison`, `protozoa`) exposes the same value-builder/decoder pattern as `gleam/json`, with format-specific primitives (e.g. `gleebor.uint`, `protozoa.varint`). Hand-writing CBOR or MessagePack encoders is the same shape as JSON; the cost is paying attention to format-specific edges (CBOR's tagged values, Protobuf's field-number assignment, BSON's ordering rules).

For the underlying convention and the JSON example, see the folder [README → encoder/decoder convention](README.md#the-encoderdecoder-convention).

## Leaderboard

| Position | Award | Format | Repo |
| --- | --- | --- | --- |
| 1 | 🥇 | CBOR | [gleebor](https://hex.pm/packages/gleebor) (⚠ stale at snapshot) |
| 2 | 🥈 | MessagePack | [gmsg](https://hex.pm/packages/gmsg) |
| 3 | 🥉 | Protobuf (lib only) | [protozoa](https://hex.pm/packages/protozoa) |
| 4 | — | BSON | [bison](https://hex.pm/packages/bison) |
| 5 | — | NBT | [nbeet](https://hex.pm/packages/nbeet) |

> [!NOTE]
> The 7-dimension rubric underweights binary-format libraries that have small communities by design (CBOR / MsgPack / NBT consumers are concentrated in vertical niches). Use the rubric for like-for-like JSON comparisons; for binary, prefer "is the format covered at all".

[How scores are calculated →](../databases.md#scoring-dimensions)

## Related

- [README](README.md) — folder intro: encoder/decoder convention, hand-written ser/deser, cross-language framing.
- [codegen-json.md](codegen-json.md) — build-time codegen for JSON ser/deser.
- [runtime-bidirectional-json.md](runtime-bidirectional-json.md) — runtime JSON libraries + JSON Schema / Patch / RPC + bidirectional schemas at runtime.
- [../parse-and-generate-other-languages.md → gRPC / Protobuf codegen](../parse-and-generate-other-languages.md#grpc--protobuf-codegen) — Protobuf `.proto` codegen gap.
- [../databases.md](../databases.md) — `postgresql_protocol` consumer ([pog](../databases.md#pog-)). Canonical scoring rubric lives here.
- [../ai.md](../ai.md) — TOON / LLM input optimisation context for `toon_codec`.
