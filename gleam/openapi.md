# OpenAPI in Gleam

> [!NOTE]
> **Status:** DRAFT · **Authoring:** AI-assisted, human-reviewed.

**Snapshot 2026-05-07.** Three sub-stories live here:

1. **Spec parsing** — read an OpenAPI 3.x document into typed Gleam values ([oas](#oas)).
2. **Spec → Gleam codegen** — emit Gleam server stubs and/or client SDKs from a spec ([oaspec](#oaspec), [gilly](#gilly), [oas_generator](#oas_generator)).
3. **Gleam → spec (code-first)** — emit an OpenAPI document from your routes / handler types. **No package covers this** as of snapshot.

For the runtime ser/deser story (`gleam_json`, `protozoa`, `gleam_erlang_cbor`) and codegen tools whose primary output is encoders/decoders (`json_typedef`, `gserde`, `sara`, `glerd_json`, `aide_generator`), see [serialization/serialize-and-deserialize.md](serialization/serialize-and-deserialize.md). For non-OpenAPI parsers and X→Gleam codegen (parser combinators, format parsers, SQL→Gleam, GraphQL→Gleam), see [parse-and-generate-other-languages.md](parse-and-generate-other-languages.md).

## Table of contents

1. [Summary](#summary)
2. [Discovery](#discovery)
3. [Spec parsing](#spec-parsing)
   - [oas](#oas)
4. [OpenAPI → Gleam codegen](#openapi--gleam-codegen)
   - [Comparison](#comparison)
   - [oaspec](#oaspec)
   - [gilly](#gilly)
   - [oas_generator](#oas_generator)
5. [Gleam → OpenAPI (code-first spec generation)](#gleam--openapi-code-first-spec-generation)
6. [Cross-language framing](#cross-language-framing)
7. [Leaderboard](#leaderboard)
8. [Related](#related)

[How scores are calculated →](databases.md#scoring-dimensions)

## Summary

| Direction | Status | Tools |
| --- | --- | --- |
| Spec parsing (as a library) | ✅ covered | [oas](#oas) |
| Spec → Gleam (server stubs + client SDK) | ✅ covered | [oaspec](#oaspec), [gilly](#gilly), [oas_generator](#oas_generator) |
| **Gleam → Spec (code-first)** | ❌ **none** | — |
| Postman ↔ OpenAPI conversion (adjacent) | ✅ external | [../postman-to-openapi-converters.md](../postman-to-openapi-converters.md) |

> [!IMPORTANT]
> Both **oaspec** and **gilly** are days-to-weeks old at snapshot. They move fast — every PR in both repos was merged within hours of opening. Neither has a community track record yet. Pin a version.

> [!IMPORTANT]
> If you want code-first OpenAPI in the style of [FastAPI](https://fastapi.tiangolo.com/), [Ktor](https://ktor.io/docs/openapi-spec-generation.html), [tsoa](https://tsoa-community.github.io/docs/), or [utoipa](https://github.com/juhaku/utoipa), **the Gleam ecosystem cannot give it to you today**. You will either hand-write the spec, generate it outside Gleam, or adopt the spec-first workflow with [oaspec](#oaspec)/[gilly](#gilly)/[oas_generator](#oas_generator).

## Discovery

Searches run on **2026-05-07** against [packages.gleam.run](https://packages.gleam.run/), plus targeted GitHub queries.

| Query | URL | Result |
| --- | --- | --- |
| `openapi` | [packages.gleam.run/?search=openapi](https://packages.gleam.run/?search=openapi) | oas, oaspec, gilly, oas_generator |
| `swagger` | [packages.gleam.run/?search=swagger](https://packages.gleam.run/?search=swagger) | 0 hits |
| `mist` | [packages.gleam.run/?search=mist](https://packages.gleam.run/?search=mist) | mist + adapters — none emit specs |
| `wisp` | [packages.gleam.run/?search=wisp](https://packages.gleam.run/?search=wisp) | wisp + adapters — none emit specs |
| GitHub: `language:gleam openapi route` | targeted scan | no results — no published code-first OpenAPI tools |
| GitHub: `gleam openapi mist` | repository search | 0 hits |

## Spec parsing

### oas
[repo](https://github.com/crowdhailer/oas)

"Work with Open API Specs (previously swagger) and JSON Schema." Decodes OpenAPI 3.x documents into Gleam types (paths, components, operations). Used as input by [oas_generator](#oas_generator). Apache-2.0. 0 open issues at snapshot. Note: `gleam.toml` has `target = "javascript"` — JS-first, but parsing is platform-agnostic.

| Criterion | [oas](https://github.com/crowdhailer/oas) |
| --- | --- |
| Stars | 15★ · 🟨 |
| License | Apache-2.0 · 🟩 |
| Target | ☎️📜 Both (JS-first per gleam.toml, parsing is platform-agnostic) |
| Maintenance | 🟩🟩 (last commit 2026-04-16) |
| Age | older · 🟩 |
| README maturity | 🟩 |
| Idiomaticity | 🟩 |
| Issues | 0 open |

## OpenAPI → Gleam codegen

Build-time tools that read an OpenAPI 3.x spec and emit typed Gleam modules. Run from the CLI; commit the generated code; no runtime spec parsing. The output uses standard `gleam/http` types, so it composes with the rest of the ecosystem (e.g. [server frameworks](web-and-http/web-apps.md#server-frameworks), [HTTP clients](web-and-http/http-clients.md)).

### Comparison

| Criterion | [oaspec](https://github.com/nao1215/oaspec) | [gilly](https://github.com/cyclimse/gilly) | [oas_generator](https://github.com/crowdhailer/oas_generator) |
| --- | --- | --- | --- |
| Stars | 4★ · 🟥 | 1★ · 🟥 | 25★ · 🟨 |
| License | MIT · 🟩 | Unlicense (public domain) · 🟩 | Apache-2.0 · 🟩 |
| Target | ☎️ BEAM | ☎️ BEAM | ☎️📜 Both (uses gleam/httpc + gleam/fetch) |
| Gleam compat | `>= 0.44 and < 2.0` · 🟩 | `>= 0.44 and < 2.0` · 🟩 | unspecified (no gleam constraint) · 🟨 |
| Maintenance | 🟩🟩 (last commit 2026-04-26) | 🟩🟩 (last commit 2026-04-19) | 🟩🟩 (last commit 2026-04-16) |
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

"Generate HTTP clients from Open API specs." Older entrant in the OpenAPI corner, built on top of the [oas](#oas) parser library. Supports both backend (`gleam/httpc`) and frontend (`gleam/fetch`) — making it the dual-target choice when oaspec/gilly's BEAM-only output won't fit. 25★, last commit 2026-04-16. Same author as `oas`.

## Gleam → OpenAPI (code-first spec generation)

If you have a [mist](web-and-http/web-apps.md#mist) or [wisp](web-and-http/web-apps.md#wisp) app and want an OpenAPI spec emitted from your routes and handler types — **no such tool exists in Gleam yet**.

### Why the gap exists

The structural reason: **Gleam has no runtime type reflection and no macros.** A code-first generator would have to walk the compiler AST or require developers to write a parallel description of each route (defeating the point). Neither approach has been published as a package.

What a hypothetical `mist_openapi` or `wisp_openapi` would need to do:

1. **Enumerate routes.** Both mist and wisp dispatch via ordinary Gleam pattern-match on the request — there is no declarative route registry to walk. An annotation layer or a routing DSL would need to exist first.
2. **Extract parameter and body types.** Gleam functions carry static types, but those types are erased on BEAM and absent from JS. Without macros or reflection, the generator would have to parse Gleam source (the compiler AST) at build time — or rely on `glerd`-style runtime metadata.
3. **Emit JSON Schema.** A type → schema mapper for Gleam records, custom types (sum types → `oneOf`), `Option` (nullable), `List` (array), `Dict` (`additionalProperties`), and generics.
4. **Assemble the document.** Compose into a full OpenAPI 3.x document (security schemes, servers, tags, responses) and serialise.

### What exists that could be reused

- [crowdhailer/oas](#oas) — data model for the output document (could be the encode side if builders + a JSON encoder were added).
- [gleam_json](serialization/serialize-and-deserialize.md#gleam_json) — JSON serialisation.
- [glance](parse-and-generate-gleam.md#glance) — Gleam source parser, the most plausible bridge to "extract types from handler functions."
- [glerd](https://hex.pm/packages/glerd) — runtime type metadata; could expose handler signatures to a generator without source-walking.
- [gleamgen](parse-and-generate-gleam.md#gleamgen) / [trick](parse-and-generate-gleam.md#trick) / [derived](serialization/serialize-and-deserialize.md#derived) — code-emit infrastructure (would emit the *registration* layer, not the spec itself).
- [json_blueprint](serialization/serialize-and-deserialize.md#json_blueprint) — already produces JSON Schema from a runtime definition; with route-walking on top, this is the shortest path to a working tool.

### What is missing

- Any published Gleam-level route registry abstraction (the mist/wisp idiom is an opaque pattern match).
- Any type-introspection mechanism that doesn't depend on parsing source. `glerd` is the only published shoe-in; it is small but well-shaped.
- An opinionated DSL that holds both handler and signature description at the same value level.

### Workarounds

- **Hand-written spec** — keep `openapi.yaml` in the repo, feed it to [oaspec](#oaspec) with `--check` in CI to detect drift between spec and generated server stubs. This inverts the code-first model: the **spec** is authoritative, your Gleam server is derived.
- **Spec-first as default** — if your reason for wanting code-first is "I don't want to maintain a YAML file by hand," spec-first tooling now covers enough of the OpenAPI surface that the YAML can be short and mostly auto-scaffoldable from an initial sketch.
- **Annotation DSL** — wrap routes in a small Gleam DSL that holds both the handler and a description of its inputs/outputs; a separate function walks the DSL value to emit the spec. This is the only path that avoids parsing source. Nobody has published it yet.
- **`json_blueprint` for the schema half** — if your need is just JSON Schema for request/response bodies (not the full OpenAPI document), [json_blueprint](serialization/serialize-and-deserialize.md#json_blueprint) already gives you a single-source-of-truth path. Ship the request/response schemas with your handlers and assemble them into a hand-written OpenAPI shell.

For Postman ↔ OpenAPI conversion (the inverse direction, often a workaround input), see [../postman-to-openapi-converters.md](../postman-to-openapi-converters.md).

## Cross-language framing

Code-first OpenAPI emission is the place where Gleam diverges sharply from sibling ecosystems.

| Language | Code-first spec from types? | Mechanism |
| --- | --- | --- |
| **Gleam** | ❌ none | No reflection, no macros |
| **Rust** | ✅ [utoipa](https://github.com/juhaku/utoipa), [aide](https://github.com/tamasfe/aide) | Procedural macros |
| **Python** | ✅ [FastAPI](https://fastapi.tiangolo.com/), [pydantic.json_schema()](https://docs.pydantic.dev/latest/concepts/json_schema/) | Runtime reflection on type hints |
| **TypeScript** | ✅ [tsoa](https://tsoa-community.github.io/docs/), [zod-to-openapi](https://github.com/asteasolutions/zod-to-openapi) | TS compiler API or runtime schema introspection |
| **Go** | ✅ [swaggo/swag](https://github.com/swaggo/swag) (comments), [huma](https://github.com/danielgtaylor/huma) (struct tags) | Source comments or struct tags |
| **Kotlin** | ✅ [Ktor OpenAPI](https://ktor.io/docs/openapi-spec-generation.html), [springdoc-openapi](https://springdoc.org/) | KSP / annotation processing |
| **Elixir** | ⚠️ [open_api_spex](https://github.com/open-api-spex/open_api_spex) — explicit DSL, not auto-derived from handler signatures | Schema modules built by hand |
| **OCaml** | ⚠️ partial — schema generation possible via custom PPXes | PPX (preprocessor extension) |
| **Elm** | ❌ none (no major Elm web-server framework, so the question is moot) | — |

The closest analogue to Gleam's situation is **Elixir's `open_api_spex`**: an explicit schema DSL, hand-maintained, generates the spec via runtime introspection of *the schema modules* (not the handler types). A Gleam equivalent — `wisp_openapi`-style with hand-written schema modules built on `oas` + `json_blueprint` — could be built without needing macros. **It just hasn't been.**

## Leaderboard

[How scores are calculated →](databases.md#scoring-dimensions)

Combines the [oas](#oas) parser with the three OpenAPI codegen tools, since they're typically picked together.

| Position | Award | Repo | Role | ★ | Lic | Compat | Maint | Age | README | Idiom | Score |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 🥇 | [crowdhailer/oas](https://github.com/crowdhailer/oas) | Parser library | 🟨 | 🟩 | 🟨 | 🟩🟩 | 🟩 | 🟩 | 🟩 | **7** |
| 2 | 🥈 | [nao1215/oaspec](https://github.com/nao1215/oaspec) | Codegen (server + client) | 🟥 | 🟩 | 🟩 | 🟩🟩 | 🟥 | 🟩🟩 | 🟩 | **6** |
| 2 | 🥈 | [crowdhailer/oas_generator](https://github.com/crowdhailer/oas_generator) | Codegen (client, dual-target) | 🟨 | 🟩 | 🟨 | 🟩🟩 | 🟩 | 🟩 | 🟩 | **6** |
| 4 | 🥉 | [cyclimse/gilly](https://github.com/cyclimse/gilly) | Codegen (client) | 🟥 | 🟩 | 🟩 | 🟩🟩 | 🟥 | 🟩 | 🟩 | **4** |

### Type-to-spec emission (code-first OpenAPI from types)

| Tool | Status |
| --- | --- |
| Anything that walks Gleam types and emits OpenAPI | ❌ does not exist |
| Anything that walks Gleam types and emits JSON Schema | ⚠️ [json_blueprint](serialization/serialize-and-deserialize.md#json_blueprint) gets close (single blueprint → encode + decode + auto-Schema), but you still author the blueprint by hand |

The gap. See [Why the gap exists](#why-the-gap-exists) for the structural reasons and the workarounds.

## Related

- [serialization/serialize-and-deserialize.md](serialization/serialize-and-deserialize.md) — runtime ser/deser (gleam_json, protozoa, gleam_erlang_cbor), codegen for encoders/decoders (json_typedef, gserde, sara, glerd_json, derived, aide_generator), JSON Schema tools (castor, jscheam, sextant), bidirectional schemas (convert, kata, json_blueprint).
- [parse-and-generate-other-languages.md](parse-and-generate-other-languages.md) — parser combinators, format parsers (TOML/Djot/CSV/XML/Markdown/CEL), HTML parsers, SQL→Gleam codegen (squirrel/parrot/marmot/sqlode), GraphQL (squall), static-asset embeds, gRPC/Protobuf gap.
- [parse-and-generate-gleam.md](parse-and-generate-gleam.md) — Gleam source parsers (glance, glance_printer) and Gleam-emitting DSLs (gleamgen, trick, glue, derived).
- [web-and-http/web-apps.md](web-and-http/web-apps.md) — mist, wisp; relevant context for the [code-first OpenAPI gap](#gleam--openapi-code-first-spec-generation).
- [web-and-http/http-clients.md](web-and-http/http-clients.md) — HTTP transport that consumes the generated client SDKs.
- [../postman-to-openapi-converters.md](../postman-to-openapi-converters.md) — adjacent: converting Postman collections to OpenAPI specs (precedes the OpenAPI → Gleam pipeline).
