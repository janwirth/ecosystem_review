# Gleam Ecosystem Reviews

Snapshot-dated evaluations of the [Gleam](https://gleam.run/) library landscape — what's maintained, what's idiomatic, and what actually covers the feature you need. Each article scores repos against the same scaffold (stars, license, language-compat, maintenance, age, README maturity, idiomaticity) plus category-specific dimensions, with disregarded repos listed for auditability.

For the full scoring formalization see [../formalization.md](../formalization.md); the review process is documented in [../workflows/REVIEW_METHODOLOGY.md](../workflows/REVIEW_METHODOLOGY.md). Back to the top-level index: [../README.md](../README.md).

## Articles

### Web & HTTP

- [Web apps](web-and-http/web-apps.md) — full-stack, server frameworks, HTTP servers, frontend, dev tools, RPC. 15 repos reviewed.
- [HTTP clients](web-and-http/http-clients.md) — making outbound HTTP requests.
- [Hot reloading](web-and-http/hot-reloading.md) — BEAM module swap, browser live reload, JS dev servers, file watcher primitives.
- [UI development](web-and-http/ui-development.md) — component libraries, layout primitives, icon sets, drag-and-drop kits, animations, and form helpers above the Lustre / redraw frontend choice.
- [Lustre server components](web-and-http/lustre-server-components.md) — guided tour through the official Lustre server-component examples (init / update / view running on the BEAM, DOM patches over WebSocket).
- [Tailwind](web-and-http/tailwind.md) — Gleam-specific Tailwind integrations, standalone CLI wrappers, class utilities, and component kits.

### Testing

- [Testing libraries](testing/general-testing.md) — gleeunit, dream_test, property testing, snapshot, assertions. 17 repos reviewed.
- [Browser automation](testing/browser-automation.md) — CDP clients, E2E frameworks, integration test infra.

### Other

- [Parse & generate Gleam](parse-and-generate-gleam.md) — Gleam source parsers (glance, glance_printer) + Gleam-emitting Gleam DSLs (gleamgen, trick, glue, derived).
- [Parse & generate other languages](parse-and-generate-other-languages.md) — parser combinators, format parsers (TOML / Djot / CSV / XML / Markdown / CEL), HTML, SQL→Gleam codegen, GraphQL (squall), static-asset embeds.
- [OpenAPI in Gleam](openapi.md) — `oas` parser, OpenAPI → Gleam codegen (oaspec / gilly / oas_generator), and the **Gleam → OpenAPI (code-first) gap** — no package emits a spec from your routes.
- [Serialize & deserialize](serialization/README.md) — folder. Encoder/decoder convention, why decoding by hand, cross-language framing in [README](serialization/README.md). Three sibling articles: [codegen-json.md](serialization/codegen-json.md) (json_typedef, gserde, sara, glerd_json, derived, aide_generator); [runtime-bidirectional-json.md](serialization/runtime-bidirectional-json.md) (gleam_json, jackson, juno, simplejson, JSON Schema/Patch/RPC, convert/kata/json_blueprint); [other-formats.md](serialization/other-formats.md) (CBOR, MsgPack, BSON, Protobuf, NBT, base32-62, TOON, wire-protocol codecs). **Note:** [`deriv`](serialization/codegen-json.md#deriv) cannot resolve in projects using `gleam_json 3.x`.
- [Subprocesses](subprocesses.md) — shelling out, streaming stdio, process control.
- [Syntax highlighting](syntax-highlighting.md) — per-language lexers, multi-language grammars, tree-sitter NIFs. 6 repos reviewed.
- [Databases](databases.md) — PostgreSQL / SQLite / MySQL drivers, query builders, codegen, migrations, framework-bundled DB. 9 repos reviewed (+ 4 disregarded).
- [Logging](logging.md) — OTP `logger` adapters, structured dual-target loggers, specialist sinks. 11 repos reviewed.
- [Authentication](authentication.md) — password hashing, JOSE/JWT, OAuth2 clients, TOTP, WebAuthn, sessions, IDaaS. 20+ repos reviewed.
- [Hashing](hashing.md) — `gleam_crypto` (canonical, MD5/SHA-1/SHA-2 + HMAC, dual-target), SHA-3/Keccak (4 fragmented impls), BLAKE2/BLAKE3, Murmur3 (×2: pure-Gleam `murmur3a` + NIF `mumu`), SipHash, IPFS CIDs (`multiformats`). Includes a "when to use what" decision table and explicit FFI paths for missing algorithms (xxHash, CRC32, FNV, etc.). 18 packages reviewed.
- [Email](email.md) — SMTP clients, transactional email vendor wrappers, HTML email composition, and the inbound / IMAP gap.
- [AI / LLM clients](ai.md) — multi-provider abstractions (starlet, glean), per-vendor SDKs (Anthropic, OpenAI, Mistral, Ollama), AssemblyAI transcription, TOON token-efficient encoding, and the Model Context Protocol cluster (aide, mcp_toolkit, mcp_client). 16 repos reviewed (+ 4 disregarded).
- [Mobile apps](mobile-apps.md) — Gleam has no native mobile target; the realistic 2026 paths all compile to JS then plug into a shell (Capacitor, Tauri Mobile, RN-as-logic-only, PWA, bare WebView). 5 paths scored. Cross-links to [../building-mobile-apps.md](../building-mobile-apps.md) for shell internals.
- [Guides & learning resources](guides.md) — Language Tour, Writing Gleam guide, Cheatsheets, Exercism, CodeCrafters, awesome-gleam, framework-shipped guides (Lustre, Wisp), YouTube talks, community blog series, newsletter, Discord. 15 resources scored. Honest about the no-book / no-paid-course gap.
