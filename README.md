# Ecosystem Reviews

Systematic evaluations of software ecosystems — sampled by the author's project needs, with the goal of becoming a reliable reference for CTOs and coding agents making tooling decisions.

## Vision

Picking a library shouldn't mean a weekend of GitHub archaeology. Every review here asks the same questions — *is it maintained? is it idiomatic? does it actually cover the feature you need?* — and answers them with reproducible, snapshot-dated evidence.

The target audience:

- **CTOs & tech leads** — need to justify tooling choices with more than a star count.
- **Coding agents** — need machine-readable, consistently-scored signal to recommend the right library on behalf of a human.

Coverage starts where the author's own projects demand answers, then widens outward. Topic requests and contributions welcome.

## How this almanac is organised

```
.
├── gleam/                  per-language ecosystem (20+ articles)
├── application-types/      what kind of thing are you building? (website builders, desktop, mobile, terminals)
├── design/                 UX + diagramming
├── practices/              methodologies: BDD, DDD, formalization rubric
├── industry-watch/         ecosystem-meta: discovery, language popularity, incidents
├── authentication.md       cross-cutting auth primer (loner)
├── marketing/              SEO + analytics
├── postman-to-openapi-converters.md  format-converter review (loner)
└── workflows/              the review process itself (for contributors / agents)
```

Each topic folder has a `README.md` that orients the reader and links to sibling articles. Loners that don't have siblings yet stay at the root.

## Articles

### Gleam — per-language ecosystem

Full index in [`gleam/README.md`](gleam/README.md). Highlights:

**Web & HTTP**

- [Web apps](gleam/web-and-http/web-apps.md) — full-stack, server frameworks, HTTP servers, frontend, dev tools, RPC. 15 repos reviewed.
- [HTTP clients](gleam/web-and-http/http-clients.md) — making outbound HTTP requests.
- [Hot reloading](gleam/web-and-http/hot-reloading.md) — BEAM module swap, browser live reload, JS dev servers, file watcher primitives.

**Testing**

- [Testing libraries](gleam/testing/general-testing.md) — gleeunit, dream_test, property testing, snapshot, assertions. 17 repos reviewed.
- [Browser automation](gleam/testing/browser-automation.md) — CDP clients, E2E frameworks, integration test infra.

**Languages & codegen**

- [Parse & generate Gleam](gleam/parse-and-generate-gleam.md) — Gleam source parsers (glance, glance_printer) and Gleam-emitting Gleam DSLs (gleamgen, trick, glue, derived).
- [Parse & generate other languages](gleam/parse-and-generate-other-languages.md) — parser combinators, format parsers (TOML/Markdown/CSV/XML), HTML, SQL→Gleam codegen, GraphQL, static-asset embeds.
- [OpenAPI in Gleam](gleam/openapi.md) — `oas` parser, OpenAPI → Gleam codegen (oaspec / gilly / oas_generator), and the Gleam → OpenAPI (code-first) gap.
- [Serialize & deserialize](gleam/serialization/README.md) — folder. Encoder/decoder convention + hand-written ser/deser in the [folder README](gleam/serialization/README.md). Three sibling articles: [codegen-json.md](gleam/serialization/codegen-json.md) (build-time codegen for JSON), [runtime-bidirectional-json.md](gleam/serialization/runtime-bidirectional-json.md) (runtime JSON + JSON Schema/Patch/RPC + bidirectional schemas), [other-formats.md](gleam/serialization/other-formats.md) (non-JSON: CBOR, MsgPack, BSON, Protobuf, …). **Note:** [`deriv`](gleam/serialization/codegen-json.md#deriv) is currently broken on new projects (gleam_json 3.x conflict).

**Infrastructure**

- [Subprocesses](gleam/subprocesses.md) — shelling out, streaming stdio, process control.
- [Syntax highlighting](gleam/syntax-highlighting.md) — per-language lexers, multi-language grammars, tree-sitter NIFs. 6 repos reviewed.
- [Databases](gleam/databases.md) — PostgreSQL / SQLite / MySQL drivers, query builders, codegen, migrations. 9 repos reviewed (+ 4 disregarded).
- [Logging](gleam/logging.md) — OTP `logger` adapters, structured dual-target loggers, specialist sinks. 11 repos reviewed.
- [Authentication](gleam/authentication.md) — password hashing, JOSE/JWT, OAuth2 clients, TOTP, WebAuthn, sessions, IDaaS. 20+ repos reviewed.
- [Hashing](gleam/hashing.md) — `gleam_crypto`, SHA-3/Keccak (×4), BLAKE2/3, Murmur3 (×2), SipHash, IPFS CIDs. Decision table + FFI paths. 18 packages reviewed.
- [Caching](gleam/caching.md) — memoisation, state cells, LRU, ETS, persistent, out-of-process, HTTP, domain-shaped. **Note:** [`carpenter`](gleam/caching.md#carpenter-broken) and [`glemo`](gleam/caching.md#glemo-broken) are broken on new projects. 24 packages reviewed (+ 12 disregarded).
- [CLI](gleam/cli.md) — argument parsers (glint, clip, clad, hoist, argv) and interactive UI / CLI renderers (39 packages, + 17 disregarded).
- [Environment variables](gleam/env-vars.md) — `envoy` (canonical), typed wrappers, `.env` loaders, framework modules, `${VAR}`-interpolated config files. 13 packages reviewed.
- [YAML](gleam/yaml.md) — pure-Gleam parsers, FFI parsers, the only emitter (`cymbal`), domain-shaped libraries. 6 packages (+ 4 disregarded).
- [Parallelization](gleam/parallelization.md) — actors, pools, parallel-map, background jobs, rate limiting, scheduling, observability. 30+ packages. **Non-goals: distributed BEAM clustering.**

**Application surfaces**

- [Mobile apps](gleam/mobile-apps.md) — JS-compile-then-shell paths (Lustre + Capacitor / Tauri Mobile / RN-as-logic-only / PWA / bare WebView). Honest about the gaps.
- [AI](gleam/ai.md) — LLM clients, MCP packages, agent frameworks.

**Meta**

- [Guides & learning resources](gleam/guides.md) — interactive tour, Exercism, CodeCrafters, awesome-gleam, framework guides, YouTube, newsletter. 15 resources scored.

### Application types — *what kind of thing are you building?*

Folder [`application-types/`](application-types/README.md). The orientation step *before* picking a framework.

- [Application types overview](application-types/README.md) — website vs web app vs PWA vs desktop vs mobile. Distribution, install friction, offline, native-API access, decision matrix.
- [Choosing a web-presence stack](application-types/choosing-a-web-presence-stack.md) — the tier decision, from Wix to a custom app: five tiers (off-the-shelf builder · visual development platform · SSG + git CMS · framework + headless CMS · custom application), a pick-by-organizational-capacity grid, the "no technical staff doesn't mean Wix" case, and the break-even where plugin/add-on costs on off-the-shelf platforms stop being cheaper than building (editorial workflow and custom roles turn out to be the Enterprise-gated pair almost everywhere).
- [Website builders](application-types/website-builders.md) — ~60 hosted and self-hostable platforms across six families: mainstream all-in-one (Wix, Squarespace, Duda, GoDaddy, Hostinger, IONOS…), designer-first (Webflow, Framer, Webstudio), portfolio (Readymag, Cargo, Semplice, Pixpa…), WordPress + Elementor/Divi/Bricks/Beaver and the open-source corner, AI-first (Lovable, Bolt, v0, 10Web…), and Notion-as-CMS. Pricing-gotcha taxonomy, caps, lock-in/export table, SEO-by-construction, EAA accessibility, GDPR residency, Core Web Vitals. Plus ecommerce platforms and no-code app builders, reviewed to draw the boundary.
- [Building desktop apps](application-types/desktop.md) — Electron, Tauri 2, Electrobun, Wails, Flutter Desktop, Compose MP, Avalonia, Slint, iced, egui, .NET MAUI, Qt 6, GTK 4, native. 22 frameworks reviewed + 7 disregarded. Dedicated pitfalls section.
- [Building mobile apps](application-types/mobile.md) — native (Kotlin/Swift), Flutter, RN/Expo, Capacitor, Tauri Mobile, KMP, .NET MAUI, NativeScript, Lynx, Quasar, Solito, PWA. 14 frameworks reviewed + 7 disregarded/EOL.
- [Browser-based SSH terminals](application-types/browser-ssh-terminals.md) — embeddable web SSH clients for iframe / Notion use.

### Design — UX, UI, diagrams

Folder [`design/`](design/README.md).

- [UX resources & tools](design/ux.md) — Laws of UX, NN/g heuristics + training, dogfooding practice, PostHog instrumentation, BDD/Gherkin connection.
- [Diagramming tools](design/diagramming.md) — Mermaid, PlantUML, D2, Graphviz/DOT, LaTeX/TikZ, Kroki, mingrammer/diagrams, Structurizr, WaveDrom, Excalidraw, + 20 ASCII renderers and terminal-chart tools. ~40 tools reviewed.

### Practices — methodologies and how-to-think

Folder [`practices/`](practices/README.md).

- [BDD with Gherkin](practices/bdd-with-gherkin.md) — cross-ecosystem Cucumber-family survey across Ruby, JS, JVM, Python, .NET, Go, Rust, PHP, Elixir, Gleam, Haskell.
- [Domain-Driven Design](practices/domain-driven-design.md) — opinionated orientation: why DDD is hard, where it earns its keep (Ubiquitous Language + Bounded Contexts), how it maps onto Ash (Elixir).
- [Formalization](practices/formalization.md) — the scoring rubric (stars, license, lang-compat, maintenance, age, README, idiomaticity, feature completeness, ease, output quality) and discovery pipeline used across all reviews.

### Industry watch — observing the broader ecosystem

Folder [`industry-watch/`](industry-watch/README.md).

- [Navigating software ecosystems](industry-watch/navigating-ecosystems.md) — meta-review of the discovery toolkit itself: awesome lists, friends & experts, bundlephobia, ossinsight, comparison pages, deps.dev.
- [Programming language popularity & desire](industry-watch/language-popularity.md) — Stack Overflow 2025 rankings: what's used vs what's loved.
- [Recent incidents in major technologies](industry-watch/recent-incidents.md) — 2024-2026 CVE and supply-chain highlights across Next.js, WordPress, Python, npm, and others.

### Other cross-ecosystem articles

Loners — don't have siblings yet, kept at the root.

- [Authentication — high-level primer](authentication.md) — what authentication is, how it works on the web, the practical security floor, common pitfalls, glossary. Cross-cutting / language-agnostic; pairs with [Gleam authentication](gleam/authentication.md) for ecosystem-specific picks.
- **Marketing** ([folder](marketing/README.md)) — SEO + analytics as two sibling articles:
  - [SEO](marketing/seo.md) — keyword research, technical / on-page / off-page SEO, Generative Engine Optimization (GEO), tools by price tier, per-capability feature matrix, marketer playbook. Includes a [Quick Start](marketing/seo.md#quick-start--8020-seo-for-non-marketers) — an 80/20 routine for technical founders who want to replace an SEO agency.
  - [Analytics](marketing/analytics.md) — GA4 vs privacy-first (Plausible / Fathom / Umami / Matomo), product analytics (PostHog / Mixpanel / Amplitude), session replay + heatmaps (Clarity / Hotjar / FullStory), privacy / cookie shifts, tool feature matrix.
- [Postman → OpenAPI converters](postman-to-openapi-converters.md) — converting Postman collections to OpenAPI specs.
- [Audio genre & BPM detection](audio-genre-and-bpm-detection.md) — cross-ecosystem (JS / npm / browser, Python, standalone CLIs, hosted APIs, the BEAM gap) survey of BPM (tempo) and genre classification tools. ~30 tools reviewed; explicit callouts for the deprecated Spotify `/audio-features` endpoint and shut-down AcousticBrainz. Includes per-capability leaderboards and a "When to use what" decision table keyed by licence + runtime.

### Upcoming

- Linters

## Method

Every review uses the same scoring scaffold: **stars, license, language-compat, maintenance, age, README maturity, idiomaticity**, plus category-specific dimensions (feature completeness, ease of use, output quality) where they apply.

- Data comes from public sources — GitHub / GitLab / Hex / package registries — captured on a named snapshot date.
- Disregarded repos are listed with reasons, so the triage is auditable.
- Scores combine into a leaderboard so authors can sanity-check their own metrics at a glance.

The full scoring formalization lives in [`practices/formalization.md`](practices/formalization.md). The first worked example is in the [Gleam web apps review](gleam/web-and-http/web-apps.md#research-method). The agent-facing review process lives in [`workflows/`](workflows/README.md).

## Contributing

Requests for new ecosystems, categories, or re-snapshots are welcome. Open an issue.

## License

[MIT](LICENSE)
