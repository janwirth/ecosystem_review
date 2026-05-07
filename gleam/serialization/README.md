# Serialization in Gleam

> [!NOTE]
> **Status:** DRAFT · **Authoring:** AI-assisted, human-reviewed.

If you want to write a Gleam value to a file, send it over the network, or hand it to another process, you have to turn it into bytes first — files, sockets, and pipes don't speak Gleam types. **Serialization** is that conversion. **Deserialization** is the reverse: read bytes back, get a typed Gleam value (or an error if the bytes are malformed).

Concretely: **Serialize** = `T → bytes` (or → spec document). **Deserialize** = `bytes → Result(T, Error)`. The bytes might be UTF-8 JSON in `config.json`, a binary CBOR payload in a WebAuthn signature, a Protobuf message on a gRPC wire, or a row of BSON in MongoDB — the destination dictates the format, but the question is the same: how do you cross the gap between your typed Gleam record and the bytes the outside world wants?

The two directions are written together because most Gleam packages bundle both — the encoder and decoder ship in the same module, around the same field names — and because the design pressure on each side is symmetric.

## Why hand-write?

Gleam's stance is **explicit, hand-written by convention**, with optional escape hatches via runtime schemas or build-time codegen. The pattern is very close to Elm's `Json.Encode` / `Json.Decode` pair — and very far from Rust's `#[derive(Serialize, Deserialize)]` or Python's pydantic-style runtime reflection. There are no macros, no reflection, no struct-tag reading.

The hand-written stance is deliberate, not an accident of immaturity. Gleam has:

- **No macros.** No `#[derive]`, no PPX, no compiler plugins. The compiler does not run user code at build time.
- **No reflection.** Types are erased on BEAM and absent on JS at runtime. There is no `typeof(T)` value to inspect.
- **No struct tags.** Field annotations like Go's `json:"name"` do not exist.

The closest in-language analogue is **Elm**, which Gleam inherits the dynamic-decoder pattern from: explicit, verbose, type-checked, and "no-magic". The trade-off is more code per record vs guaranteed safety + zero codegen surface.

## Articles in this folder

- **[serialize-and-deserialize.md](serialize-and-deserialize.md)** — the canonical article. Covers:
  - The encoder/decoder convention (`gleam/dynamic/decode` and `gleam/json`).
  - Hand-written ser/deser — the explicit, verbose, type-checked default.
  - Per-format packages — JSON (gleam_json, jackson, juno, simplejson), binary (gleebor, gmsg, bison, protozoa, nbeet, gleb128, thirtytwo, sixtytwo, toon_codec).
  - JSON Schema / Patch / RPC tools — castor, jscheam, sextant, squirtle, pollux.
  - Bidirectional schemas at runtime — convert, kata, json_blueprint.
  - Wire-protocol codecs — postgresql_protocol, h2_frame.
  - Codegen for ser/deser — gserde, json_typedef, sara, derived, glerd_json, aide_generator. **Plus [deriv](serialize-and-deserialize.md#deriv) — currently broken on new projects (gleam_json 3.x conflict).**
  - Cross-language framing against serde / pydantic / Jason / encoding/json / utoipa.

## Adjacent corners

- **[../openapi.md](../openapi.md)** — the OpenAPI corner: the [oas](../openapi.md#oas) parser, [oaspec](../openapi.md#oaspec) / [gilly](../openapi.md#gilly) / [oas_generator](../openapi.md#oas_generator) codegen tools, and the **Gleam → OpenAPI gap** (no package emits a spec from your routes).
- **[../parse-and-generate-gleam.md](../parse-and-generate-gleam.md)** — Gleam source parsers (glance) and Gleam-emitting DSLs (gleamgen, trick). The build-time machinery that codegen tools sit on.
- **[../parse-and-generate-other-languages.md](../parse-and-generate-other-languages.md)** — parser combinators, format parsers (TOML/Djot/CSV/XML), HTML parsers, SQL→Gleam codegen, GraphQL, static-asset embeds, and the gRPC/Protobuf codegen gap.
- **[../databases.md](../databases.md)** — SQL→Gleam codegen produces *types and query functions*, not encoders/decoders, but uses the same code-emit infrastructure. Canonical scoring rubric lives there.
- **[../../postman-to-openapi-converters.md](../../postman-to-openapi-converters.md)** — adjacent spec-conversion workflow.
