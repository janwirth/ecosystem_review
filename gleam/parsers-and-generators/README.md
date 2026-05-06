# Parsers and code generators in Gleam

You have text or data and you want a typed Gleam value.
Or you have a typed Gleam value and you want bytes on a wire.
Or you have a schema and you want typed Gleam code.
This folder maps each direction independently — runtime parsing, runtime decoding, build-time code generation, and runtime serialization — plus the cross-language cases.

## Sub-articles

The article is split by **what the tool does**, not what input it consumes:

| File | Question it answers | Snapshot |
| --- | --- | --- |
| [parse.md](parse.md) | Text → AST / typed value at **runtime**, via combinators or grammars (parser combinators, format parsers, HTML, source-language parsers like `glance`). | 2026-04-26 |
| [decode.md](decode.md) | Wire bytes → typed value at **runtime** (JSON / CBOR / MsgPack / etc. decoders — the format is already well-defined; the work is mapping fields to records). | 2026-04-26 |
| [generate.md](generate.md) | Input artifact → emit Gleam (or other) **source code at build time** (gleamgen-style DSLs, X→Gleam codegen for SQL / OpenAPI / JSON Schema). | 2026-04-26 |
| [serialize.md](serialize.md) | Typed value → wire bytes / spec document at **runtime** (encoders + the Gleam→OpenAPI gap). | 2026-04-26 |

The parse/decode and generate/serialize axes split along the **runtime vs. build-time** line and the **structure-extraction vs. structure-emission** line:

|  | Runtime | Build-time |
| --- | --- | --- |
| **Input → typed value** | [parse](parse.md) (text grammar) · [decode](decode.md) (defined wire format) | — (compile-time decoders are not a thing in Gleam) |
| **Typed value → output** | [serialize](serialize.md) (encoders) | [generate](generate.md) (codegen) |

## Cross-cutting themes

- **Gleam (parse & gen)** — Gleam-native libraries cluster in [parse.md](parse.md) (combinators, format parsers) and [generate.md](generate.md) (gleamgen, glue, derived, gserde, trick).
- **OpenAPI** — threads through [parse.md](parse.md) (`oas` reads specs), [generate.md](generate.md) (`oaspec`, `gilly`, `oas_generator` emit Gleam from specs), and [serialize.md](serialize.md) (the Gleam→OpenAPI gap — no code-first spec generator exists).
- **Other languages** — comparative framing in [decode.md](decode.md) (Rust serde, Go encoding/json, Elixir Jason as analogues for Gleam's runtime decoders) and [serialize.md](serialize.md) (serde-derive, protoc, asn1c, utoipa as analogues for Gleam's missing build-time serializers).

## Out of scope (across all four files)

Same exclusions for the whole folder:

- **Per-language syntax-highlighter lexers** (contour, just, pearl, tear, smalto, glimra) → [../syntax-highlighting.md](../syntax-highlighting.md). They tokenise but for colourisation, not AST analysis.
- **CLI argument parsers** (glint, clip, hoist, glap, sheen) — domain-specific, covered when relevant in CLI tooling.
- **UUID / NanoID / identicon generators** — value generators, not code or data generators.
- **HTML/CSS/PDF/Typst document generators** (nakai, htmz, paddlefish, glypst, sketch_css) — output documents, not Gleam source code.

## Scoring rubric (shared)

Every leaderboard in this folder uses the same 7-dimension rubric inherited from [../databases.md](../databases.md#scoring-dimensions) and [../web-and-http/web-apps.md](../web-and-http/web-apps.md#scoring-dimensions):

- **Stars:** 🟩🟩 ≥200★, 🟩 ≥100★, 🟨 ≥10★, 🟥 <10★. ⬜ = not shown by host.
- **License:** 🟩 permissive (MIT, Apache-2.0, BSD, Unlicense). 🟥 viral or missing.
- **Gleam compat:** `gleam_stdlib` constraint format. 🟩 range (`>= X and < Y`), 🟥 non-range or missing.
- **Maintenance:** `max(recency, responsiveness)`. 🟩🟩 <1 month / clean tracker, 🟩 <6 months, 🟨 <1 year, 🟥 >1 year or ignored.
- **Age:** First commit to snapshot. 🟩🟩 ≥3 years, 🟩 ≥1 year, 🟨 ≥3 months, 🟥 <3 months.
- **README maturity:** 🟩🟩 guide-style with examples + feature docs, 🟩 clear tagline + usage, 🟥 minimal.
- **Idiomaticity:** 🟩 typed, explicit, no magic. 🟥 magic directives or template extraction.

**Leaderboard scoring:** 🟥 = −1, 🟨/⬜ = 0, 🟩 = 1, 🟩🟩 = 2. Sum of all 7 dimensions. Max = 13.

Each sub-article runs **its own discovery** (search queries + snapshot date + result counts) — the package landscape for `parse` is not the same as for `generate`, and the search terms differ.

## Related reviews

- **[../databases.md](../databases.md)** — SQL→Gleam codegen in depth ([squirrel](../databases.md#squirrel-) vs [sqlode](../databases.md#sqlode-)) plus drivers, query builders, migrations. Cross-linked from [generate.md](generate.md).
- **[../syntax-highlighting.md](../syntax-highlighting.md)** — per-language lexers (contour, just, pearl, tear, smalto) and tree-sitter NIFs (glimra). Overlaps with parsing role-difference: tokenisation for colourisation vs AST for analysis.
- **[../web-and-http/web-apps.md](../web-and-http/web-apps.md)** — mist, wisp, server frameworks; relevant context for the [Gleam → OpenAPI](serialize.md#gleam--openapi-code-first-spec-generation) gap.
- **[../web-and-http/http-clients.md](../web-and-http/http-clients.md)** — HTTP transports the OpenAPI-generated SDKs plug into.
- **[../../postman-to-openapi-converters.md](../../postman-to-openapi-converters.md)** — converting Postman collections into OpenAPI specs that feed [generate.md](generate.md) tools.
