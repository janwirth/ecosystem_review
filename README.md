# Ecosystem Reviews

Systematic evaluations of software ecosystems — sampled by the author's project needs, with the goal of becoming a reliable reference for CTOs and coding agents making tooling decisions.

## Vision

Picking a library shouldn't mean a weekend of GitHub archaeology. Every review here asks the same questions — *is it maintained? is it idiomatic? does it actually cover the feature you need?* — and answers them with reproducible, snapshot-dated evidence.

The target audience:

- **CTOs & tech leads** — need to justify tooling choices with more than a star count.
- **Coding agents** — need machine-readable, consistently-scored signal to recommend the right library on behalf of a human.

Coverage starts where the author's own projects demand answers, then widens outward. Topic requests and contributions welcome.

## Articles

### Gleam

**Web & HTTP**

- [Web apps](gleam/web-and-http/web-apps.md) — full-stack, server frameworks, HTTP servers, frontend, dev tools, RPC. 15 repos reviewed.
- [HTTP clients](gleam/web-and-http/http-clients.md) — making outbound HTTP requests.
- [Hot reloading](gleam/web-and-http/hot-reloading.md) — BEAM module swap, browser live reload, JS dev servers, file watcher primitives.

**Testing**

- [Testing libraries](gleam/testing/general-testing.md) — gleeunit, dream_test, property testing, snapshot, assertions. 17 repos reviewed.
- [Browser automation](gleam/testing/browser-automation.md) — CDP clients, E2E frameworks, integration test infra.

**Other**

- [Parse & generate Gleam](gleam/parse-and-generate-gleam.md) — Gleam source parsers (glance, glance_printer) and Gleam-emitting Gleam DSLs (gleamgen, trick, glue, derived).
- [Parse & generate other languages](gleam/parse-and-generate-other-languages.md) — parser combinators, format parsers (TOML/Markdown/CSV/XML), HTML, SQL→Gleam codegen, GraphQL, static-asset embeds.
- [OpenAPI in Gleam](gleam/openapi.md) — `oas` parser, OpenAPI → Gleam codegen (oaspec / gilly / oas_generator), and the Gleam → OpenAPI (code-first) gap.
- [Serialize & deserialize](gleam/serialization/README.md) — folder. Encoder/decoder convention + hand-written ser/deser in [README](gleam/serialization/README.md). Three sibling articles: [codegen-json.md](gleam/serialization/codegen-json.md) (build-time codegen for JSON: json_typedef, gserde, sara, derived); [runtime-bidirectional-json.md](gleam/serialization/runtime-bidirectional-json.md) (runtime JSON + JSON Schema/Patch/RPC + bidirectional schemas); [other-formats.md](gleam/serialization/other-formats.md) (non-JSON: CBOR, MsgPack, BSON, Protobuf, …). **Note:** [`deriv`](gleam/serialization/codegen-json.md#deriv) is currently broken on new projects (gleam_json 3.x conflict).
- [Subprocesses](gleam/subprocesses.md) — shelling out, streaming stdio, process control.
- [Syntax highlighting](gleam/syntax-highlighting.md) — per-language lexers, multi-language grammars, tree-sitter NIFs. 6 repos reviewed.
- [Databases](gleam/databases.md) — PostgreSQL / SQLite / MySQL drivers, query builders, codegen, migrations, framework-bundled DB. 9 repos reviewed (+ 4 disregarded).
- [Logging](gleam/logging.md) — OTP `logger` adapters, structured dual-target loggers, specialist sinks. 11 repos reviewed.
- [Authentication](gleam/authentication.md) — password hashing, JOSE/JWT, OAuth2 clients, TOTP, WebAuthn, sessions, IDaaS. 20+ repos reviewed.
- [Hashing](gleam/hashing.md) — `gleam_crypto` (canonical), SHA-3/Keccak (4 fragmented impls), BLAKE2/BLAKE3, Murmur3 (×2), SipHash, IPFS CIDs. Decision table for "when to use what" + FFI paths for missing algorithms. 18 packages reviewed.
- [Caching](gleam/caching.md) — memoisation (`memo_gleam`, `rememo_*`, `gemo`, `worm`), state cells (`booklet`, `cell`, `capuchin_crypt`), LRU (`immutable_lru`), ETS foundations (`bravo`, `rasa`, `dream_ets`, `mala`, `shelf`, `lamb`), persistent (`hardcache`, `trove`, `amnesiac`), out-of-process (`glimr_redis`, `glemcached`), HTTP (Wisp built-in), domain-shaped (`gquery` SWR, `squall_cache` GraphQL, Lustre `element.memo`). Background on ETS / `persistent_term` / Mnesia / DETS vs JS-side primitives. Decision table + FFI paths to Cachex/Nebulex. **Note:** [`carpenter`](gleam/caching.md#carpenter-broken) and [`glemo`](gleam/caching.md#glemo-broken) are broken on new projects (reproduced build failure). 24 packages reviewed (+ 12 disregarded).
- [CLI](gleam/cli.md) — argument parsers (glint, clip, clad, hoist, argv) and interactive UI / CLI renderers (gleam_community/ansi, spinner, glitzer, input/survey, tobble, term_size, full-screen TUI: shore/etch/pink). Decision table for "when to use what" + FFI paths for missing capabilities (multi-select, password, fuzzy-find). 39 packages reviewed (+ 17 disregarded).
- [Environment variables](gleam/env-vars.md) — `envoy` (canonical, dual-target, zero-dep) plus typed wrappers (envoker, envie, glenv), `.env` file loaders (glenvy, dot_env, dotenv_gleam, dotenv_conf), framework-bundled modules (kata_env, fiction_env, dream_config), `${VAR}`-interpolated config files (yodel). Decision table for "when to use what" + FFI paths for missing capabilities (AWS/GCP/Vault secret managers, dotenv-vault, OTP application env). **Note:** [`dot_env`](gleam/env-vars.md#dot_env) silently downgrades on `gleam_stdlib 1.x` projects. 13 packages reviewed.
- [YAML](gleam/yaml.md) — pure-Gleam dual-target parsers (`taffy`, `yamleam`), `yamerl`-FFI parsers (`yay`, `glaml`), the only emitter (`cymbal`), domain-shaped (`mb_rep_gleam` for Metabase), cross-link to [`yodel`](gleam/env-vars.md#yodel) for config-loading. Background on YAML 1.1 vs 1.2, alias bombs, anchor/tag/merge-key support. Decision table for "when to use what" + FFI escape hatches (`yamerl` / `fast_yaml`). 6 packages reviewed (+ 4 disregarded).
- [Parallelization](gleam/parallelization.md) — single-node parallelism: actors + supervisors (`gleam_otp`), resource pools (`bath`, `lifeguard`, `crew`), parallel-map (`parallel_map`, `taskle`), background jobs (`m25`, `bg_jobs`), rate limiting (`glimit`, `speedbump`), scheduling, debounce/throttle (Lustre core; non-Lustre DIY recipe), observability (`spectator`, `glychee`, `gleamy_bench`), PubSub / registries. Leads with bottleneck-identification workflow + recursive-directory anti-pattern. **Non-goals: distributed BEAM clustering.** 30+ packages reviewed.
- [Mobile apps](gleam/mobile-apps.md) — JS-compile-then-shell paths (Lustre + Capacitor / Tauri Mobile / RN-as-logic-only / PWA / bare WebView). Honest about the gaps.
- [Guides & learning resources](gleam/guides.md) — interactive tour, Exercism, CodeCrafters, awesome-gleam, framework-shipped guides (Lustre, Wisp), YouTube, newsletter, Discord. 15 resources scored. Honest about the no-book / no-paid-course gap.

### Application types

- [Application types — what kind of thing are you building?](application-types.md) — the orientation step *before* picking a framework: website vs web app vs PWA vs desktop vs mobile. Distribution, install friction, offline expectations, native-API access, and a decision matrix. Parent of the [mobile-app survey](building-mobile-apps.md) below.

### Mobile

- [Building mobile apps — cross-ecosystem survey](building-mobile-apps.md) — native (Kotlin/Swift), Flutter, React Native / Expo, Capacitor, Tauri Mobile, Compose Multiplatform / KMP, .NET MAUI, NativeScript, Lynx, Quasar, Solito, PWA. 14 frameworks reviewed + 7 disregarded/EOL. Sub-article of [Application types](application-types.md).

### Testing

- [BDD with Gherkin](bdd-with-gherkin.md) — cross-ecosystem Cucumber-family survey across Ruby, JS, JVM, Python, .NET, Go, Rust, PHP, Elixir, Gleam, Haskell.

### UX

- [UX resources & tools](ux-resources-and-tools.md) — curated review of UX (not visual design) resources: Laws of UX, NN/g heuristics + training, dogfooding practice, PostHog instrumentation, and the BDD/Gherkin connection.

### Diagramming

- [Diagramming tools — cross-ecosystem survey](diagramming.md) — Mermaid, PlantUML, D2, Graphviz/DOT, LaTeX/TikZ, Kroki, mingrammer/diagrams, Structurizr, WaveDrom, Excalidraw, plus 20+ ASCII renderers and terminal-chart tools. ~40 tools reviewed.

### OpenAPI

- [Postman → OpenAPI converters](postman-to-openapi-converters.md) — converting Postman collections to OpenAPI specs.

### Shell

- [Browser-based SSH terminals](browser-ssh-terminals.md) — embeddable web SSH clients for iframe / Notion use.

### Security

- [Recent incidents in major technologies](recent-incidents-in-major-technologies.md) — 2024-2026 CVE and supply-chain highlights across Next.js, WordPress, Python, npm, and others.

### Authentication

- [Authentication — a high-level primer](authentication.md) — what authentication is, how it works on the web, the practical security floor, common pitfalls, and a glossary. Cross-cutting / language-agnostic; pairs with [Gleam authentication](gleam/authentication.md) for ecosystem-specific picks.

### Software Design

- [Domain-Driven Design](domain-driven-design.md) — opinionated orientation: why DDD is hard, where it earns its keep (Ubiquitous Language + Bounded Contexts), how it maps onto Ash (Elixir), and the author's evolving "adjusted approach."

### Languages

- [Programming language popularity & desire](programming-languages-popularity-and-desire.md) — Stack Overflow 2025 rankings: what's used vs what's loved.

### Meta

- [Navigating software ecosystems](navigating-ecosystems.md) — meta-review of the discovery toolkit itself: awesome lists, friends & experts, bundlephobia and friends, ossinsight, comparison pages, and how to combine them with this repo's structured-review approach.

### Upcoming

- Linters

## Method

Every review uses the same scoring scaffold: **stars, license, language-compat, maintenance, age, README maturity, idiomaticity**, plus category-specific dimensions (feature completeness, ease of use, output quality) where they apply.

- Data comes from public sources — GitHub / GitLab / Hex / package registries — captured on a named snapshot date.
- Disregarded repos are listed with reasons, so the triage is auditable.
- Scores combine into a leaderboard so authors can sanity-check their own metrics at a glance.

The full scoring formalization lives in [formalization.md](formalization.md). The first worked example is in the [Gleam web apps review](gleam/web-and-http/web-apps.md#research-method).

## Contributing

Requests for new ecosystems, categories, or re-snapshots are welcome. Open an issue.

## License

[MIT](LICENSE)
