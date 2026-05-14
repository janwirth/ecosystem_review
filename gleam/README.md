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
- [Caching](caching.md) — memoisation (`memo_gleam`, `rememo_erlang`/`javascript`, `gemo`, `worm`), in-memory caches & state cells (`booklet`, `cell`, `capuchin_crypt`, `immutable_lru`, `keystore`, `gacache`), ETS bindings (`bravo`, `rasa`, `dream_ets`, `mala`, `shelf`, `lamb`), persistent/disk-backed (`hardcache`, `trove`, `shelf`, `amnesiac`), out-of-process (`glimr_redis`, `glemcached`), HTTP/web (`wisp.serve_static`), domain-shaped (`gquery` SWR, `squall_cache` GraphQL, Lustre `element.memo`). Background on ETS / `persistent_term` / Mnesia / DETS vs JS-side primitives. Decision table for "when to use what" + FFI paths to Cachex/Nebulex for the missing general-purpose-cache slot. **Note:** [`carpenter`](caching.md#carpenter-broken) and [`glemo`](caching.md#glemo-broken) are **broken on new projects** (`gleam_erlang ~> 0.24` pin + `gleam_stdlib 1.0` breaking change — reproduced failure). 24 packages reviewed (+ ~12 disregarded).
- [CLI](cli.md) — argument parsers (glint, clip, clad, hoist, argv, glap, outil, sheen, cosmo_cli) and interactive UI / CLI renderers (gleam_community/ansi + colour, spinner, glitzer, input/survey/promptly/question, tobble/gtabler/fabulous, term_size/string_width/terminal_link/gleave, full-screen TUI: shore/etch/pink/glink/shiny/gtui/glerm). Decision table for "when to use what" + FFI paths for missing capabilities (multi-select, password, autocomplete, fzf). 39 packages reviewed (+ 17 disregarded).
- [Environment variables](env-vars.md) — `envoy` (canonical, dual-target, zero-dep primitive) plus typed wrappers (envoker, envie, glenv), `.env` file loaders (glenvy, dot_env, dotenv_gleam, dotenv_conf), framework-bundled modules (kata_env, fiction_env, dream_config), and `${VAR}`-interpolated config files (yodel). Cross-links to secret-masking helpers (cowl, redact, glm_vault). **Note:** [`dot_env`](env-vars.md#dot_env) silently downgrades to v0.5.1 in projects using `gleam_stdlib 1.x`. 13 packages reviewed (+ 13 disregarded).
- [Parallelization](parallelization.md) — single-node, in-process parallelism: actors + supervisors (`gleam_otp`), resource pools (`bath`, `lifeguard`, `crew`), parallel-map (`parallel_map`, `taskle`, `working_actors`), background jobs (`m25`, `bg_jobs`), rate limiting (`glimit`, `speedbump`), scheduling (`clockwork_schedule`), debounce/throttle (Lustre core; non-Lustre gap with DIY recipe), observability (`spectator`, `glychee`, `gleamy_bench`), PubSub / registries (`glyn`, `reki`, `singularity`, `glubsub`, `glixir` for Elixir FFI). Leads with bottleneck-identification workflow + recursive-directory anti-pattern. **Non-goals: distributed BEAM clustering.** 30+ packages reviewed (+ 12 disregarded).
- [Email](email.md) — SMTP clients, transactional email vendor wrappers, HTML email composition, and the inbound / IMAP gap.
- [AI / LLM clients](ai.md) — multi-provider abstractions (starlet, glean), per-vendor SDKs (Anthropic, OpenAI, Mistral, Ollama), AssemblyAI transcription, TOON token-efficient encoding, and the Model Context Protocol cluster (aide, mcp_toolkit, mcp_client). 16 repos reviewed (+ 4 disregarded).
- [Mobile apps](mobile-apps.md) — Gleam has no native mobile target; the realistic 2026 paths all compile to JS then plug into a shell (Capacitor, Tauri Mobile, RN-as-logic-only, PWA, bare WebView). 5 paths scored. Cross-links to [../building-mobile-apps.md](../building-mobile-apps.md) for shell internals.
- [Guides & learning resources](guides.md) — Language Tour, Writing Gleam guide, Cheatsheets, Exercism, CodeCrafters, awesome-gleam, framework-shipped guides (Lustre, Wisp), YouTube talks, community blog series, newsletter, Discord. 15 resources scored. Honest about the no-book / no-paid-course gap.
