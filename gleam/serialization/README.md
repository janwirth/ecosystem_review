# Serialization in Gleam

> [!NOTE]
> **Status:** DRAFT · **Authoring:** AI-assisted, human-reviewed.

If you want to write a Gleam value to a file, send it over the network, or hand it to another process, you have to turn it into bytes first — files, sockets, and pipes don't speak Gleam types. **Serialization** is that conversion. **Deserialization** is the reverse: read bytes back, get a typed Gleam value (or an error if the bytes are malformed).

Concretely: **Serialize** = `T → bytes` (or → spec document). **Deserialize** = `bytes → Result(T, Error)`. The bytes might be UTF-8 JSON in `config.json`, a binary CBOR payload in a WebAuthn signature, a Protobuf message on a gRPC wire, or a row of BSON in MongoDB — the destination dictates the format, but the question is the same: how do you cross the gap between your typed Gleam record and the bytes the outside world wants?

The two directions are written together because most Gleam packages bundle both — the encoder and decoder ship in the same module, around the same field names — and because the design pressure on each side is symmetric.

## Articles in this folder

- **[codegen-json.md](codegen-json.md)** — build-time codegen for JSON encoders/decoders: [json_typedef](codegen-json.md#json_typedef), [gserde](codegen-json.md#gserde), [sara](codegen-json.md#sara), [glerd_json](codegen-json.md#glerd_json), [derived](codegen-json.md#derived), [aide_generator](codegen-json.md#aide_generator). Plus [deriv](codegen-json.md#deriv) — currently broken on new projects (`gleam_json 3.x` conflict).
- **[runtime-bidirectional-json.md](runtime-bidirectional-json.md)** — runtime JSON libraries: per-format JSON ([gleam_json](runtime-bidirectional-json.md#gleam_json), [jackson](runtime-bidirectional-json.md#jackson), [juno](runtime-bidirectional-json.md#juno), [simplejson](runtime-bidirectional-json.md#simplejson)); JSON Schema / Patch / RPC ([castor](runtime-bidirectional-json.md#castor), [jscheam](runtime-bidirectional-json.md#jscheam), [sextant](runtime-bidirectional-json.md#sextant), [squirtle](runtime-bidirectional-json.md#squirtle), [pollux](runtime-bidirectional-json.md#pollux)); bidirectional schemas at runtime ([convert](runtime-bidirectional-json.md#convert), [kata](runtime-bidirectional-json.md#kata), [json_blueprint](runtime-bidirectional-json.md#json_blueprint)).
- **[other-formats.md](other-formats.md)** — non-JSON encode/decode: CBOR ([gleebor](other-formats.md#gleebor)), MessagePack ([gmsg](other-formats.md#gmsg)), BSON ([bison](other-formats.md#bison)), Protobuf ([protozoa](other-formats.md#protozoa)), NBT ([nbeet](other-formats.md#nbeet)), LEB128 ([gleb128](other-formats.md#gleb128)), Base32 ([thirtytwo](other-formats.md#thirtytwo)), Base62 ([sixtytwo](other-formats.md#sixtytwo)), TOON ([toon_codec](other-formats.md#toon_codec)). Plus wire-protocol codecs ([postgresql_protocol](other-formats.md#postgresql_protocol), [h2_frame](other-formats.md#h2_frame)).

The rest of this README covers the foundational pattern that all three articles plug into — the encoder/decoder convention, the hand-written default, and how Gleam compares to other languages.

## Why hand-write?

Gleam's stance is **explicit, hand-written by convention**, with optional escape hatches via runtime schemas or build-time codegen. The pattern is very close to Elm's `Json.Encode` / `Json.Decode` pair — and very far from Rust's `#[derive(Serialize, Deserialize)]` or Python's pydantic-style runtime reflection. There are no macros, no reflection, no struct-tag reading.

The hand-written stance is deliberate, not an accident of immaturity. Gleam has:

- **No macros.** No `#[derive]`, no PPX, no compiler plugins. The compiler does not run user code at build time.
- **No reflection.** Types are erased on BEAM and absent on JS at runtime. There is no `typeof(T)` value to inspect.
- **No struct tags.** Field annotations like Go's `json:"name"` do not exist.

The closest in-language analogue is **Elm**, which Gleam inherits the dynamic-decoder pattern from: explicit, verbose, type-checked, and "no-magic". The trade-off is more code per record vs guaranteed safety + zero codegen surface.

> [!IMPORTANT]
> **The ergonomic default in Gleam is to write decoders by hand**, even when that means twenty lines of `decode.field` per record. The escape hatches exist (codegen, runtime schemas) but every one of them adds either a build step, a runtime indirection, or a dependency on an unstable third-party tool. For most projects the verbose-but-explicit baseline is the right choice; for codebases with hundreds of records the codegen route pays for itself.

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

This explicitness is what lets every codegen / schema library in this folder sit cleanly on top — they emit (or compose) exactly this shape, with no reflection layer to mis-align with.

> [!IMPORTANT]
> Decoders for **the official `dynamic.decode` style** (chained `decode.field(...)` calls) are the idiomatic shape across Gleam JSON libraries. You will write decoders by hand unless you reach for [codegen](codegen-json.md) to derive them at build time (e.g. [json_typedef](codegen-json.md#json_typedef), [gserde](codegen-json.md#gserde)).

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

### When hand-writing pays off

- **Few records (<~20).** Setup cost of any codegen tool exceeds the manual line count.
- **The encoded shape diverges from the Gleam type.** Snake-case keys, flattened nested records, polymorphic discriminator schemes, version-specific output. Any divergence beats codegen by a wide margin because hand-written code can do anything; codegen tools have a fixed mapping.
- **The wire format is short-lived or under negotiation.** Don't pay codegen-setup time when the schema is not stable.

### When hand-writing hurts

- **Many similar records.** A 60-record API surface with conventional shape is 1,200+ lines of decoder/encoder boilerplate.
- **The schema is the source of truth.** When you have a `.json-typedef.json` or an OpenAPI spec, hand-writing diverges from the document on every change and creates drift bugs.
- **Round-trip correctness must be guaranteed.** Hand-written encoder/decoder pairs can disagree (typo in one field name); codegen pairs cannot.

For both of those, jump to [codegen-json.md](codegen-json.md) or [runtime-bidirectional-json.md → bidirectional schemas](runtime-bidirectional-json.md#bidirectional-schemas-at-runtime).

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

When the verbosity gets in the way: reach into [codegen-json.md](codegen-json.md) (`json_typedef` for schema-first, `gserde` for type-first, [trick](../parse-and-generate-gleam.md#trick) for hand-rolled emit).

## Adjacent corners

- **[../openapi.md](../openapi.md)** — the OpenAPI corner: the [oas](../openapi.md#oas) parser, [oaspec](../openapi.md#oaspec) / [gilly](../openapi.md#gilly) / [oas_generator](../openapi.md#oas_generator) codegen tools, and the **Gleam → OpenAPI gap** (no package emits a spec from your routes).
- **[../parse-and-generate-gleam.md](../parse-and-generate-gleam.md)** — Gleam source parsers (glance) and Gleam-emitting DSLs (gleamgen, trick). The build-time machinery codegen tools sit on.
- **[../parse-and-generate-other-languages.md](../parse-and-generate-other-languages.md)** — parser combinators, format parsers (TOML/Djot/CSV/XML), HTML parsers, SQL→Gleam codegen, GraphQL, static-asset embeds, and the gRPC/Protobuf codegen gap.
- **[../databases.md](../databases.md)** — SQL→Gleam codegen produces *types and query functions*, not encoders/decoders, but uses the same code-emit infrastructure. Canonical scoring rubric lives there.
- **[../../postman-to-openapi-converters.md](../../postman-to-openapi-converters.md)** — adjacent spec-conversion workflow.
