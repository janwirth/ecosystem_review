# Tools for building web applications with Gleam

> [!NOTE]
> **Status:** DRAFT · **Authoring:** AI-assisted, human-reviewed.

So you want to ~~become a pokemon trainer~~ build a web app in gleam?
Don't know where to start?
Start here.

## Table of Contents

1. [Summary](#summary)
2. [Research Method](#research-method)
   - [Scoring Dimensions](#scoring-dimensions)
   - [Discovery](#discovery)
3. [Categories](#categories)
   - [Full-Stack Frameworks](#full-stack-frameworks) — [glimr](#glimr)
   - [Server Frameworks](#server-frameworks) — [wisp](#wisp) · [dream](#dream) · [glen](#glen)
   - [Static Site Generators](#static-site-generators) — [arctic](#arctic)
   - [Dev Tools](#dev-tools) — [lustre_dev_tools](#lustre_dev_tools) · [gleam-radiate](#gleam-radiate)
   - [RPC Layer](#rpc-layer) — [libero](#libero)
   - [Frontend Frameworks](#frontend-frameworks) — [lustre](#lustre) · [redraw](#redraw)
   - [Core HTTP Types](#core-http-types) — [http](#http)
   - [HTTP Servers](#http-servers) — [mist](#mist) · [ewe](#ewe) · [cowboy](#cowboy)
   - [Network Infrastructure](#network-infrastructure) — [glisten](#glisten)
4. [Full-stack approaches compared](#full-stack-approaches-compared-libero-vs-lustre-server-components-vs-glimr) — libero vs lustre server components vs glimr
5. [Leaderboard](#leaderboard)

## Summary



Gleam's ecosystem is growing fast, and keeping track of what's available isn't easy.

I put this together so you don't have to spend hours on research, or worse, build something that already exists.

The essentials to build something great are there.


| Category | ☎️ BEAM | 📜 JS |
| --- | --- | --- |
| **[Full-Stack Frameworks](#full-stack-frameworks)** | · [glimr](#glimr) ([repo](https://github.com/glimr-org/glimr), 165★) — *young; routing, templates, DB schema + migrations, auth, hot reload* | — |
| **[Server Frameworks](#server-frameworks)** | · [🥈](#leaderboard) [wisp](#wisp) ([repo](https://github.com/gleam-wisp/wisp), 1.4k★) — *handler+middleware, production-ready*<br>· [dream](#dream) ([repo](https://github.com/TrustBound/dream), 39★) — *composable, no magic, batteries-included* | · [glen](#glen) ([repo](https://github.com/MystPi/glen), 111★) — *lightweight, promise-based, Deno/Node/Workers* |
| **[Static Site Generators](#static-site-generators)** | · [arctic](#arctic) ([repo](https://github.com/RyanBrewer317/arctic), 26★) — *content collections, parsers, SSG via lustre_ssg* | — |
| **[Frontend Frameworks](#frontend-frameworks)** (Elm-style) | · [🥇](#leaderboard) [lustre](#lustre) ([repo](https://github.com/lustre-labs/lustre), 2.2k★) — *declarative UI, SSR, universal* | · [🥇](#leaderboard) [lustre](#lustre) ([repo](https://github.com/lustre-labs/lustre), 2.2k★) — *also runs on JS target* |
| **[Frontend Frameworks](#frontend-frameworks)** (React) | — | · [redraw](#redraw) ([repo](https://github.com/ghivert/redraw), 62★) — *full React 19 bindings, type-checked* |
| **[RPC Layer](#rpc-layer)** | · [libero](#libero) ([repo](https://github.com/pairshaped/libero), 18★) — *young; full-stack framework with typed RPC over WebSocket, project scaffold, ETF wire* | · [libero](#libero) — *also generates JS client stubs* |
| **[Dev Tools](#dev-tools)** | · [lustre_dev_tools](#lustre_dev_tools) ([repo](https://github.com/lustre-labs/dev-tools), 112★) — *dev server, bundling, Tailwind*<br>· [gleam-radiate](#gleam-radiate) ([repo](https://github.com/pta2002/gleam-radiate), 66★) — *BEAM module reload* | — |
| **[HTTP Servers](#http-servers)** | · [🥇](#leaderboard) [mist](#mist) ([repo](https://github.com/rawhat/mist), 489★) — *HTTP server, WebSocket, SSE, streaming*<br>· [ewe](#ewe) ([repo](https://github.com/vshakitskiy/ewe), 106★) — *HTTP server, TLS, WebSocket, SSE, file serving*<br>· [cowboy](#cowboy) ([repo](https://github.com/gleam-lang/cowboy), 75★) — *adapter for existing Erlang/Elixir Cowboy setups* | — |
| **[Network Infrastructure](#network-infrastructure)** | · [glisten](#glisten) ([repo](https://github.com/rawhat/glisten), 197★) — *TCP/TLS layer, powers mist and ewe* | — |
| **[Core HTTP Types](#core-http-types)** | · [🥉](#leaderboard) [http](#http) ([repo](https://github.com/gleam-lang/http), 276★) — *request/response types, used by nearly everything* | · [🥉](#leaderboard) [http](#http) ([repo](https://github.com/gleam-lang/http), 276★) — *also targets JS* |

> [!IMPORTANT]  
> The side of the ecosystem targeting BEAM is more mature.


> <details>
> <summary><strong>Dependency Graph</strong></summary>
>
> Arrows read "uses."
>
> **[Full-Stack Frameworks](#full-stack-frameworks):**
> - [glimr](#glimr) → [mist](#mist) (HTTP server)
>
> **[Server Frameworks](#server-frameworks):**
> - [wisp](#wisp) → [mist](#mist) (HTTP server)
> - [dream](#dream) → [mist](#mist) (HTTP server)
> - [glen](#glen) → [http](#http) (core types) — *JS target, independent stack*
>
> **[Static Site Generators](#static-site-generators):**
> - [arctic](#arctic) → [lustre](#lustre) + lustre_ssg (rendering)
>
> **[RPC Layer](#rpc-layer):**
> - [libero](#libero) → [lustre](#lustre) (client stubs) — works with any server
>
> **[Frontend Frameworks](#frontend-frameworks):**
> - [lustre](#lustre), [redraw](#redraw) — standalone, integrate with any backend
>
> **[Dev Tools](#dev-tools):**
> - [lustre_dev_tools](#lustre_dev_tools) — pairs with [lustre](#lustre)
> - [gleam-radiate](#gleam-radiate) — framework-agnostic
>
> **[HTTP Servers](#http-servers):**
> - [mist](#mist) → [glisten](#glisten) (TCP/TLS) → [http](#http) (core types)
> - [ewe](#ewe) → [glisten](#glisten) (TCP/TLS) → [http](#http) (core types)
> - [cowboy](#cowboy) → [http](#http) (core types) — *adapter for Erlang's Cowboy*
>
> **[Network Infrastructure](#network-infrastructure):**
> - [glisten](#glisten) → [http](#http) (core types) — *TCP/TLS layer, powers mist and ewe*
>
> **[Core HTTP Types](#core-http-types):**
> - [http](#http) — no upstream deps; depended on by nearly everything above
>
> </details>


## Research Method

### Scoring Dimensions

- **Stars:** Community adoption signal based on star count. 🟩🟩 = ≥200★, 🟩 = ≥100★, 🟨 = ≥10★, 🟥 = <10★. *Example: 165★ → 🟩; 3★ → 🟥.*
- **License:** Whether the license allows unrestricted commercial use. 🟩 = permissive OSS (MIT, Apache-2.0, BSD). 🟥 = viral (GPL, AGPL) or no license. Only one tier — permissive or not.
- **Gleam compat:** Checks `gleam_stdlib` version constraint format in `gleam.toml` `[dependencies]`. 🟩 = range constraint (`>= X and < Y`), 🟥 = non-range constraint (`~>` style) which can cause resolver conflicts during install. *Example: `"~> 0.34 or ~> 1.0"` → 🟥; `">= 0.44.0 and < 2.0.0"` → 🟩.*
- **Maintenance:** Two-level scoring that prioritizes proactive development. Final score = **max(recency, responsiveness)**. **Level 1 — Recency:** last commit relative to snapshot. 🟩🟩 = <1 month, 🟩 = <6 months, 🟨 = <1 year, 🟥 = >1 year. **Level 2 — Responsiveness:** time for repo owner to reply to issues or update PRs (owner comment = ball in opener's court, counts as handled). 🟩🟩 = <2 days, 🟩 = <1 week, 🟨 = <1 month, 🟥 = >1 month or ignored. Clean tracker (0 open PRs/issues) = 🟩🟩. The better of the two wins. *Example: last commit 12 days ago but PRs ignored 18 months → max(🟩🟩, 🟥) = 🟩🟩; last commit 6 months ago but PR reviewed in 6 days → max(🟨, 🟩) = 🟩; last commit 10 months ago + issues ignored 8 months → max(🟨, 🟥) = 🟨.*
- **Age:** Time from first visible commit to snapshot date. Older projects have more time to stabilize. 🟩🟩 = ≥3 years, 🟩 = ≥1 year, 🟨 = ≥3 months, 🟥 = <3 months. *Example: history starts Mar 2026, snapshot Apr 2026 → ~1 month → 🟥.*
- **README maturity:** Quality of documentation in the repo README. 🟩🟩 = guide-style with examples, full feature docs, and getting-started instructions. 🟩 = clear description and basic usage. 🟥 = minimal, broken, or missing. *Example: batteries-included framework with full guide → 🟩🟩; tagline-only → 🟩.*
- **Idiomaticity:** Whether the project follows Gleam's principles: typed, sound, explicit, no magic. 🟩 = idiomatic (explicit APIs, explicit codegen steps, builder patterns). 🟥 = magic directives, implicit behavior, or template languages that extract code from non-Gleam sources. Explicit codegen (e.g. a build step that generates typed Gleam modules) is fine — the key question is whether the developer can see and understand what code runs. *Example: `/// @get "/path"` annotation routing with implicit wiring → 🟥; explicit codegen step producing readable Gleam → 🟩.* Note: projects that use non-idiomatic patterns are included and graded rather than excluded — significant bodies of work deserve coverage regardless of style.

**Leaderboard scoring:** 🟥 = −1, 🟨 = 0, 🟩 = 1, 🟩🟩 = 2. Sum of all 7 dimensions. Max possible = 13.

### Discovery

34 repos found via [Gleam packages registry](https://packages.gleam.run/) searches — **15 included** (see [Categories](#categories)), **19 disregarded** (below).

- [server](https://packages.gleam.run/?search=server)
- [backend](https://packages.gleam.run/?search=backend)
- [frontend](https://packages.gleam.run/?search=frontend)
- [react](https://packages.gleam.run/?search=react)
- [web](https://packages.gleam.run/?search=web)

> <details>
> <summary>19 disregarded — maintenance, scope, or traction issues</summary>
>
> **Unmaintained:**
> - **[gleam-lang/plug](https://github.com/gleam-lang/plug)** — HTTP adapter for Elixir Plug compatibility. Last commit 2020-08-27 (6+ years dormant). Activity 🟥.
> - **[mikeyjones/howdy](https://github.com/mikeyjones/howdy)** — API wrapper on Mist. 12★, last commit 2022-06-19 (4+ years dormant). Activity 🟥.
> - **[sporto/bliss](https://github.com/sporto/bliss)** — Micro web framework. 7★, last commit 2022-05-12 (4+ years dormant). Activity 🟥.
> - **[arnarg/gliew](https://github.com/arnarg/gliew)** — SSR framework. 9★, last commit 2023-06-12 (3+ years dormant). Activity 🟥.
> - **[Endercheif/glare](https://github.com/Endercheif/glare)** — SolidJS-based framework. 35★, last commit 2024-05-18 (~2 years dormant). Activity 🟥.
> - **[JoelVerm/meadow](https://github.com/JoelVerm/meadow)** — Server side for glare. 8★, last commit 2024-05-12. Depends on dormant glare. Activity 🟥.
>
> **No Longer Maintained:**
> - **[fravan/olive](https://github.com/fravan/olive)** — Hot-reload dev tool. 8★, short history (Feb–Jul 2025). README states "no longer in active development" and warns of rough edges. Maintenance 🟥.
>
> **Superseded / Low Activity:**
> - **[brettkolodny/react-gleam](https://github.com/brettkolodny/react-gleam)** — React bindings for Gleam. 69★, 27 commits (Nov 2022–Sep 2025). Superseded by redraw which has fuller React 19 coverage. Maintenance 🟥.
> - **[samifouad/gild_frontend](https://github.com/samifouad/gild_frontend)** — React client-side framework for Gleam. 0★, 18 commits, "extremely alpha." Abandoned experiment. Work 🟥.
> - **[TobiasBinnewies/novdom](https://gitlab.com/TobiasBinnewies/novdom)** — Frontend framework for Gleam. GitLab-hosted. 93 commits, last Sep 2024 (7+ months stale). v0.5.0. MIT. Maintenance 🟥.
> - **[TobiasBinnewies/cosmos](https://gitlab.com/TobiasBinnewies/cosmos)** — UI library for novdom. 3 commits, v0.0.0. Early experiment, depends on inactive novdom. Work 🟥.
>
> **Experiments & Stubs:**
> - **[myzykyn/gleam_webserver](https://github.com/myzykyn/gleam_webserver)** — Stub/scaffold. Single commit, default TODO template. Not usable; abandoned experiment. Work 🟥.
> - **[gleam-lang/example-echo-server](https://github.com/gleam-lang/example-echo-server)** — Reference implementation. Learning example only; not for production use.
> - **[raskell-io/refrakt](https://github.com/raskell-io/refrakt)** — Phoenix-inspired framework. 1★, too early, no traction yet.
> - **[haleywhazel/lily](https://github.com/haleywhazel/lily)** — Reactive framework. 0★, just started, no traction.
> - **[crowdhailer/mysig](https://github.com/crowdhailer/mysig)** — Web toolkit. 4★, low traction.
> - **[crowdhailer/mist_reload](https://github.com/crowdhailer/mist_reload)** — Dev tool overlapping with gleam-radiate. 5★, too niche.
>
> **Out of Scope / Aliases:**
> - **[rawhat/dew](https://github.com/rawhat/dew)** — Old package name for mist (identical GitHub repo ID). Alias, not a separate project.
> - **[renatillas/tiramisu](https://github.com/renatillas/tiramisu)** — 3D game engine. 101★, not web app tooling.
>
> </details>


## Categories

### Full-Stack Frameworks

All-in-one solutions: routing, templates, middleware, auth, database, development tools.

| Criterion | [glimr](https://github.com/glimr-org/glimr) |
| --- | --- |
| Stars | 165★ · 🟩 |
| License | MIT · 🟩 |
| Target | ☎️ BEAM (server) + 📜 JS (Vite frontend) |
| Deps | 16 |
| Gleam compat | `>= 0.44 and < 2.0` · 🟩 |
| Maintenance | 🟩🟩 |
| Age | ~4.5 months (Nov 2025) · 🟨 |
| README maturity | 🟩🟩 (batteries-included; full guide) |
| Idiomaticity | 🟥 (loom templates, magic directives — [see reasoning](#glimr-idiomaticity)) |

#### glimr
[repo](https://github.com/glimr-org/glimr)

Young, batteries-included full-stack framework (~5 weeks of history). Routing with annotations, compiled Loom templates, middleware, DB schema + migrations, Vite integration, hot reload. Built on Mist HTTP server. Zero open issues — but also no community track record yet. Ambitious scope for its age; worth watching, not yet battle-tested.

```gleam
import compiled/loom/welcome
import glimr/http/http.{type Response}
import glimr/response/response

/// @get "/welcome"
pub fn show() -> Response {
  welcome.render() |> response.string_tree(200)
}
```

<a id="glimr-idiomaticity"></a>
**Why 🟥 Idiomaticity:** Glimr uses Loom, a custom template language with magic `l-*` directives that extract Gleam code from HTML templates. This was [discussed in the Gleam Discord](https://discord.com/channels/768594524158427167/768594524158427170/1488146844138733719) (2026-03-30) where community members raised concerns: extracting partial Gleam snippets from templates leads to bad error experiences when things go wrong (rebecca\~); the `l-*` directives implicitly wire server-driven interactivity as the default, which goes against Gleam's design philosophy of making the right thing easy and explicit (hayleigh, Lustre creator); and the template approach is "completely different" from idiomatic Gleam patterns, creating a rough editing experience (paaradiso). The core issue: Gleam values typed, sound, explicit code — Loom templates introduce a layer of magic where the developer can't easily see what Gleam code actually runs. Explicit codegen (like libero's) is fine; implicit template extraction is not.


### Server Frameworks

Routing, handlers, middleware. All are independent (not full-stack).

| Criterion | [wisp](https://github.com/gleam-wisp/wisp) [🥈](#leaderboard) | [dream](https://github.com/TrustBound/dream) | [glen](https://github.com/MystPi/glen) |
| --- | --- | --- | --- |
| Stars | 1.4k★ · 🟩🟩 | 39★ · 🟨 | 111★ · 🟩 |
| License | Apache-2.0 · 🟩 | MIT · 🟩 | MIT · 🟩 |
| Target | ☎️ BEAM | ☎️ BEAM | 📜 JavaScript |
| Deps | 12 | 10 | 7 |
| Gleam compat | `>= 0.50 and < 2.0` · 🟩 | `>= 0.44 and < 2.0` · 🟩 | `~> 0.34 or ~> 1.0` · 🟥 |
| Maintenance | 🟩🟩 | 🟩🟩 | 🟨 |
| Age | ~2.7 years (Aug 2023) · 🟩 | ~5 months (Nov 2025) · 🟨 | ~2.2 years (Jan 2024) · 🟩 |
| README maturity | 🟩🟩 (practical, handler+middleware) | 🟩🟩 (guide-style, quickstart, examples) | 🟩 (tagline + repo) |
| Idiomaticity | 🟩 | 🟩 | 🟩 |
| | | | |
| **Features** | | | |
| Routing DSL | — (`case` on path segments) | ✅ (route/method/path) | — (`case` on path segments) |
| Middleware | ✅ | ✅ | ✅ |
| JSON | ✅ | ✅ | ✅ |
| Static files | ✅ | ✅ | ✅ |
| Logging | ✅ | — | — |
| WebSocket | — | ✅ | ✅ |
| Sessions / cookies | ✅ | ✅ (cookies) | — |
| Form parsing | ✅ | ✅ | ✅ |
| Testing helpers | ✅ (`wisp/simulate`) | — | — |

#### wisp
[repo](https://github.com/gleam-wisp/wisp) · [🥈](#leaderboard)

"A practical web framework for Gleam" (backend). Mature (1.4k stars), handler + context pattern. Built-in logging, static files. Production-ready.

```gleam
import wisp.{type Request, type Response}

pub type Context {
  Context(secret: String)
}

pub fn handle_request(request: Request, context: Context) -> Response {
  wisp.ok()
}
```

#### dream
[repo](https://github.com/TrustBound/dream)

"Clean, composable web development for Gleam. No magic." Young (~5 months), batteries-included server framework built on mist. Router, middleware, JSON support, structured logging. 39 stars, 3 open issues. Positions itself as an alternative to wisp with more built-in conveniences.

```gleam
import dream/server
import dream/router.{Get, route}

pub fn main() {
  router()
  |> route(method: Get, path: "/", controller: index, middleware: [])
  |> server.new()
  |> server.bind("localhost")
  |> server.listen(3000)
}
```

#### glen
[repo](https://github.com/MystPi/glen)

"A peaceful web framework for Gleam that targets JS." Lightweight, promise-based, runs on Deno/Node/Cloudflare Workers.

```gleam
import gleam/javascript/promise.{type Promise}
import glen
import glen/status

pub fn main() {
  glen.serve(8000, handle_req)
}

fn handle_req(req: glen.Request) -> Promise(glen.Response) {
  "<h1>Welcome to my webpage!</h1>"
  |> glen.html(status.ok)
  |> promise.resolve
}
```


### Static Site Generators

Build-time content pipelines that output static HTML. No runtime server needed.

| Criterion | [arctic](https://github.com/RyanBrewer317/arctic) |
| --- | --- |
| Stars | 26★ · 🟨 |
| License | Apache-2.0 · 🟩 |
| Target | ☎️ BEAM (build-time) |
| Deps | 10 |
| Gleam compat | `>= 0.40 and < 2.0` · 🟩 |
| Maintenance | 🟩🟩 |
| Age | ~1.7 years (Aug 2024) · 🟩 |
| README maturity | 🟩 (conceptual guide, external quickstart link) |
| Idiomaticity | 🟩 |

#### arctic
[repo](https://github.com/RyanBrewer317/arctic)

Content-driven static site generator built on lustre and lustre_ssg. Define collections (e.g. blog posts) with custom parsers, renderers, and index pages. Outputs static HTML — designed for fast response times and serverless/lightweight backends. 26 stars, 1 open issue, 9 months since last commit.

```gleam
let posts = collection.new("posts")
  |> collection.with_parser(post_parser)
  |> collection.with_index(app.post_index)
  |> collection.with_renderer(app.post_renderer)

let config = config.new()
  |> config.home_renderer(app.render_homepage)
  |> config.add_collection(posts)

build.build(config)
```


### Dev Tools

Hot-reload, dev servers, bundling. Used during development, not shipped to production.

| Criterion | [lustre_dev_tools](https://github.com/lustre-labs/dev-tools) | [gleam-radiate](https://github.com/pta2002/gleam-radiate) |
| --- | --- | --- |
| Stars | 112★ · 🟩 | 66★ · 🟨 |
| License | MIT · 🟩 | Apache-2.0 · 🟩 |
| Target | ☎️ BEAM | ☎️ BEAM |
| Deps | 20 | 5 |
| Gleam compat | `>= 0.60 and < 2.0` · 🟩 | `>= 0.44 and < 2.0` · 🟩 |
| Maintenance | 🟩🟩 | 🟨 |
| Age | ~2 years (Mar 2024) · 🟩 | ~2.5 years (Oct 2023) · 🟩 |
| README maturity | 🟩 (features list, install guide, no code samples) | 🟩 (tagline) |
| Idiomaticity | 🟩 | 🟩 |

#### lustre_dev_tools
[repo](https://github.com/lustre-labs/dev-tools)

Lustre's CLI and development tooling. Zero-config dev server, bundling, TailwindCSS v4 auto-detection. Uses bun for bundling/file watching. CLI-driven (no Gleam API). Pairs with lustre frontend framework.

```sh
# Install as dev dependency
gleam add lustre_dev_tools --dev

# Start dev server with live reload
gleam run -m lustre/dev start
```

#### gleam-radiate
[repo](https://github.com/pta2002/gleam-radiate)

Watches source files and reloads BEAM modules. Lightweight hot-reload. 5 deps, small footprint.

```gleam
let _ =
  radiate.new()
  |> radiate.add_dir("src")
  |> radiate.start()
```


### RPC Layer

Typed remote procedure calls between server and client. Replaces REST boilerplate with codegen.

| Criterion | [libero](https://github.com/pairshaped/libero) |
| --- | --- |
| Stars | 18★ · 🟨 |
| License | MIT · 🟩 |
| Target | ☎️📜 Both (BEAM server + JS client) |
| Deps | 7 |
| Gleam compat | `>= 0.69.0 and < 2.0.0` · 🟩 |
| Maintenance | 🟩🟩 (last commit 2026-04-21, zero open issues) |
| Age | ~12 days (Apr 2026) · 🟥 |
| README maturity | 🟩🟩 (full guide, scaffold, CLI, wire format, push, HTTP fallback) |
| Idiomaticity | 🟩 (explicit codegen step, explicit message types) |

#### libero
[repo](https://github.com/pairshaped/libero) · [hexdocs](https://hexdocs.pm/libero/)

Self-described as "a full-stack Gleam framework with typed RPC." Young (~12 days old at snapshot, 9 hex releases 1.0.0 → 4.1.1 in that window — API still churning). `libero new` scaffolds a multi-package project: server entry point on mist, shared message types, one or more Lustre SPA clients, SSR + hydration, handler tests. The wire is **ETF (Erlang Term Format) over binary WebSocket** — Gleam types serialize without JSON codecs; a JS-side ETF codec ships with the framework. Server-to-client push uses BEAM `pg` groups (no external broker). No HTTP routing, no DB, no auth, no templates — the "framework" part is the scaffold + server/client boundary + wire; the "full-stack" claim refers to coordinated project structure, not feature breadth.

```gleam
// shared/src/shared/messages.gleam — types shared by server + client
pub type MsgFromClient {
  Create(params: TodoParams)
  Toggle(id: Int)
  LoadAll
}

pub type MsgFromServer {
  TodoCreated(Result(Todo, TodoError))
  TodosLoaded(Result(List(Todo), TodoError))
}

// src/server/handler.gleam — single dispatch, no routes
pub fn update_from_client(
  msg msg: MsgFromClient,
  state state: SharedState,
) -> Result(#(MsgFromServer, SharedState), AppError) {
  case msg {
    messages.LoadAll -> Ok(#(TodosLoaded(Ok(all())), state))
    messages.Create(params:) ->
      Ok(#(TodoCreated(Ok(insert(params.title))), state))
  }
}

// clients/web — Lustre update, generated typed stub
ToggleTodo(id) ->
  #(model, rpc.send_to_server(msg: Toggle(id:), on_response: GotResponse))
```


### Frontend Frameworks

Client-side / UI layer. Can be integrated with any backend (including glimr).

| Criterion | [lustre](https://github.com/lustre-labs/lustre) [🥇](#leaderboard) | [redraw](https://github.com/ghivert/redraw) |
| --- | --- | --- |
| Stars | 2.2k★ · 🟩🟩 | 62★ · 🟨 |
| License | MIT · 🟩 | MIT · 🟩 |
| Target | ☎️📜 Both (BEAM + JS) | 📜 JavaScript |
| Deps | 5 | 2 |
| Gleam compat | `>= 0.60 and < 2.0` · 🟩 | `>= 0.60 and < 2.0` · 🟩 |
| Maintenance | 🟩🟩 | 🟩🟩 |
| Age | ~4.2 years (Feb 2022) · 🟩🟩 | ~1.7 years (Jul 2024) · 🟩 |
| README maturity | 🟩🟩 (full guide) | 🟩🟩 (guide-style, examples, hooks, contexts) |
| Idiomaticity | 🟩 | 🟩 |

#### lustre
[repo](https://github.com/lustre-labs/lustre) · [🥇](#leaderboard)

Declarative HTML, Elm-style state (`init`/`update`/`view`), universal components, SSR support, CLI tooling. Most popular Gleam frontend framework (2.2k stars).

```gleam
import lustre
import lustre/element/html
import lustre/event

pub fn main() {
  let app = lustre.simple(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)
}

fn view(model) {
  html.div([], [
    html.button([event.on_click(Decr)], [html.text("-")]),
    html.p([], [html.text(int.to_string(model))]),
    html.button([event.on_click(Incr)], [html.text("+")]),
  ])
}
```

#### redraw
[repo](https://github.com/ghivert/redraw)

React 19 bindings for Gleam. Components, props, hooks, contexts, with full Gleam type-checking. JS target only.

```gleam
import redraw
import redraw/dom/attribute
import redraw/dom/html

pub fn gleam_is_awesome() {
  use Nil <- redraw.component_("GleamIsAwesome")
  html.div([attribute.class("oh-yeah")], [
    html.text("Yeah, for sure")
  ])
}
```


### Core HTTP Types

Shared type definitions used by all server and client adapters in the ecosystem.

| Criterion | [http](https://github.com/gleam-lang/http) [🥉](#leaderboard) |
| --- | --- |
| Stars | 276★ · 🟩🟩 |
| License | Apache-2.0 · 🟩 |
| Target | ☎️📜 Both (BEAM + JS) |
| Deps | 1 |
| Gleam compat | `>= 0.45 and < 2.0` · 🟩 |
| Maintenance | 🟩 |
| Age | ~6.8 years (Jun 2019) · 🟩🟩 |
| README maturity | 🟩 (adapter tables + ecosystem) |
| Idiomaticity | 🟩 |

#### http
[repo](https://github.com/gleam-lang/http) · [🥉](#leaderboard)

Types and functions for HTTP clients and servers. Links server adapters (Mist, Cowboy) and client adapters (Plug, fetch, etc.). Central to ecosystem — almost every web library depends on this.

```gleam
// Core types provided by this package:
pub type Request(body)    // HTTP request with typed body
pub type Response(body)   // HTTP response with typed body
pub type Header           // Header key-value pair
pub type Method           // Get, Post, Put, Delete, etc.
pub type Scheme           // Http, Https
```


### HTTP Servers

Full HTTP server implementations and adapters. Use with frameworks or custom routing.

| Criterion | [mist](https://github.com/rawhat/mist) [🥇](#leaderboard) | [ewe](https://github.com/vshakitskiy/ewe) | [cowboy](https://github.com/gleam-lang/cowboy) |
| --- | --- | --- | --- |
| Stars | 489★ · 🟩🟩 | 106★ · 🟩 | 75★ · 🟨 |
| License | Apache-2.0 · 🟩 | Apache-2.0 · 🟩 | Apache-2.0 · 🟩 |
| Target | ☎️ BEAM | ☎️ BEAM | ☎️ BEAM |
| Deps | 9 | 9 | 5 |
| Gleam compat | `>= 0.50 and < 1.0` · 🟩 | `>= 0.44 and < 2.0` · 🟩 | `>= 0.45 and < 2.0` · 🟩 |
| Maintenance | 🟩🟩 | 🟩🟩 | 🟩 |
| Age | ~4 years (Apr 2022) · 🟩🟩 | ~8 months (Aug 2025) · 🟨 | ~5.7 years (Aug 2020) · 🟩🟩 |
| README maturity | 🟩🟩 (builder, WebSocket, streaming) | 🟩🟩 (guide, TLS, routing examples) | 🟩 (adapter pattern) |
| Idiomaticity | 🟩 | 🟩 | 🟩 |
| | | | |
| **Features** | | | |
| HTTP/1.1 | ✅ | ✅ | ✅ (via Cowboy) |
| WebSocket | ✅ | ✅ | — |
| TLS / HTTPS | ✅ (via glisten) | ✅ | — |
| Streaming responses | ✅ (chunked) | ✅ (chunked) | — |
| Server-Sent Events | ✅ | ✅ | — |
| File serving | ✅ (`send_file`) | ✅ (`ewe.file`) | — |
| Compression | — | — | — |
| HTTP/2 | — | — | — |

#### mist
[repo](https://github.com/rawhat/mist) · [🥇](#leaderboard)

"A glistening Gleam web server." Builder pattern, WebSocket support, streaming. Powers glimr and wisp. Active development (latest Apr 2026). Note: commit history on `master` branch, not `main`.

```gleam
import gleam/http/response
import gleam/bytes_tree
import mist

pub fn main() {
  fn(req) {
    response.new(200)
    |> response.set_body(mist.Bytes(bytes_tree.from_string("Hello, Mist!")))
  }
  |> mist.new
  |> mist.port(4000)
  |> mist.start
}
```

#### ewe
[repo](https://github.com/vshakitskiy/ewe)

"A fluffy Gleam web server." Independent HTTP server built on glisten (same foundation as mist). TLS support, WebSocket, compression, routing by path segments. 106 stars, single-author project, actively maintained. Younger and smaller community than mist but growing.

```gleam
import ewe

fn handler(req) {
  ewe.response(200, "Hello from ewe!")
}

pub fn main() {
  ewe.new(handler)
  |> ewe.bind("0.0.0.0")
  |> ewe.listening(port: 8080)
  |> ewe.start
}
```

#### cowboy
[repo](https://github.com/gleam-lang/cowboy)

Thin adapter for [Cowboy](https://github.com/ninenines/cowboy), the battle-tested Erlang HTTP server (~12+ years old, powers Phoenix/Plug). Translates between Gleam's `gleam/http` types and Cowboy's Erlang interface. Most new Gleam projects use mist instead — this adapter is for integrating Gleam handlers into an existing Erlang/Elixir codebase already running Cowboy.

```gleam
import gleam/bytes_tree
import gleam/http/response
import gleam/erlang/process

pub fn my_service(request) {
  let body = bytes_tree.from_string("Hello, world!")
  response.new(200)
  |> response.prepend_header("made-with", "Gleam")
  |> response.set_body(body)
}

pub fn main() {
  cowboy.start(my_service, on_port: 3000)
  process.sleep_forever()
}
```


### Network Infrastructure

TCP/TLS layer. Not an HTTP server — the foundational networking that mist and ewe are built on.

| Criterion | [glisten](https://github.com/rawhat/glisten) |
| --- | --- |
| Stars | 197★ · 🟩 |
| License | Apache-2.0 · 🟩 |
| Target | ☎️ BEAM |
| Deps | 5 |
| Gleam compat | `>= 0.59 and < 1.0` · 🟩 |
| Maintenance | 🟩 |
| Age | ~4 years (Apr 2022) · 🟩🟩 |
| README maturity | 🟩 (TCP/TLS server) |
| Idiomaticity | 🟩 |

#### glisten
[repo](https://github.com/rawhat/glisten)

Pure Gleam TCP/TLS server with supervised socket acceptors. Not a web framework — this is the networking infrastructure that mist is built on. Included here because it's a key dependency in the stack, not because you'd use it directly for web apps.

```gleam
import glisten/socket/options.{ActiveMode, Passive}
import glisten/tcp

pub fn main() {
  let assert Ok(listener) = tcp.listen(8000, [ActiveMode(Passive)])
  let assert Ok(socket) = tcp.accept(listener)
  let assert Ok(msg) = tcp.receive(socket, 0)
  echo #("got a msg", msg)
}
```


## Full-stack approaches compared: libero vs lustre server components vs glimr

Three tools call themselves "full-stack" or aim at the same job — shipping a real Gleam app with an interactive UI — but they solve very different problems.

| | [libero](https://github.com/pairshaped/libero) | [lustre server components](https://hexdocs.pm/lustre/lustre/server_component.html) | [glimr](https://github.com/glimr-org/glimr) |
| --- | --- | --- | --- |
| **Shape** | Typed RPC + project scaffold | Server-rendered MVU component streaming DOM patches | Batteries-included MVC framework |
| **Where state lives** | Both sides (shared types); client is a real SPA | Server process (BEAM); client is a thin runtime (~10 KB) | Server; browser gets rendered HTML (+ optional Vite SPA) |
| **Wire** | ETF over WebSocket (no JSON codecs) | Diff patches over WebSocket / SSE / polling | HTTP requests + rendered templates |
| **Routing** | — (message dispatch) | — (per-component; you plug into any HTTP server) | ✅ annotation-based (`/// @get "/path"`) compiled to pattern match |
| **Templates** | — (Lustre view functions) | — (Lustre view functions) | ✅ Loom (custom template lang, `l-*` directives) |
| **DB + migrations** | — | — | ✅ schema DSL + migration runner |
| **Auth / sessions** | — | — | ✅ scaffolded (Postgres / SQLite / Redis stores) |
| **Offline-capable client** | ✅ (client is an SPA with local state) | — (needs server socket) | Depends — SSR by default |
| **Built on** | mist + lustre + BEAM `pg` + glance | lustre runtime + your HTTP server | mist + Vite |
| **Best when** | You want a Lustre SPA and typed server calls without REST boilerplate | You want rich interactivity but most state + logic belongs on the server | You want Rails/Laravel ergonomics for a new Gleam project |

### libero — what you write

A single `update_from_client` handler dispatches typed messages. No HTTP routes, no JSON.

```gleam
// src/server/handler.gleam
pub fn update_from_client(
  msg msg: MsgFromClient,
  state state: SharedState,
) -> Result(#(MsgFromServer, SharedState), AppError) {
  case msg {
    messages.LoadAll -> Ok(#(TodosLoaded(Ok(all())), state))
    messages.Toggle(id:) -> Ok(#(TodoToggled(toggle(id)), state))
  }
}

// clients/web — generated stub, called from a Lustre update
import generated/messages as rpc
ToggleTodo(id) ->
  #(model, rpc.send_to_server(msg: Toggle(id:), on_response: GotResponse))
```

### lustre server components — what you write

A normal Lustre `init` / `update` / `view` component. The runtime ships the diffs; the `<lustre-server-component>` custom element applies patches in the browser.

```gleam
// src/counter.gleam — universal: runs on the server, renders in the browser
pub fn component() -> App(_, Model, Message) {
  lustre.simple(init, update, view)
}

pub opaque type Message {
  UserClickedIncrement
  UserClickedDecrement
}

fn update(model: Int, message: Message) -> Int {
  case message {
    UserClickedIncrement -> model + 1
    UserClickedDecrement -> model - 1
  }
}

fn view(model: Int) -> Element(Message) {
  html.div([], [
    html.button([event.on_click(UserClickedDecrement)], [html.text("-")]),
    html.p([], [html.text(int.to_string(model))]),
    html.button([event.on_click(UserClickedIncrement)], [html.text("+")]),
  ])
}
```

Boot it on the server; render the custom element in your HTML and serve `/lustre/runtime.mjs`:

```gleam
let counter = counter.component()
let assert Ok(component) = lustre.start_server_component(counter, Nil)
server_component.register_subject(process.new_subject())
|> lustre.send(to: component)

// In your page HTML:
html.body([], [
  server_component.element([server_component.route("/ws")], []),
])
```

### glimr — what you write

Annotated controllers compile to a typed router. Loom templates render views.

```gleam
// src/app/http/controllers/user_controller.gleam
import app/app.{type App}
import compiled/loom/user_show
import glimr/http/context.{type Context}
import glimr/http/middleware
import glimr/http/response.{type Response}
import app/http/middleware/auth
import app/models/user

/// @get "/users/:id"
pub fn show(ctx: Context(App), id: Int) -> Response {
  use ctx <- middleware.apply([auth.run], ctx)
  use person <- user.find_or_fail(ctx.app.db, id)
  user_show.render(user: person)
  |> response.string_tree(200)
}

/// @post "/users"
pub fn store(ctx: Context(App)) -> Response {
  use validated <- user_store.validate(ctx)
  // validated.name, validated.email already typed; 422 on fail
  // ...
}
```

### How to pick

- **Want REST replaced, SPA kept, types end-to-end?** → libero. You trade an emerging API and zero track record for zero JSON boilerplate.
- **Server owns the state; UI is reactive but thin?** → lustre server components. You keep MVU everywhere and pay a WebSocket + one BEAM process per connected session.
- **New app, want everything — router, DB, auth, assets — decided for you?** → glimr. You accept non-idiomatic templating + magic directives in exchange for scaffolding breadth.

These are not mutually exclusive. libero works with any Gleam server (wisp, mist, glimr); lustre server components plug into any HTTP server; glimr ships its own runtime but its Lustre integration can host either approach on top.


## Leaderboard
Every contribution is invaluable and appreciated.

This ranking
- helps authors check if the metrics are sane at a glance
- uncovers gems unique to the Gleam ecosystem
- cherishes key contributors

**🥇 Gold**
Special thanks for their unwavering dedication to bringing joy to development goes to _drumroll_ 🥁
- **lustre** ([hayleigh-dot-dev](https://github.com/hayleigh-dot-dev) 703 commits, [yoshi-monster](https://github.com/yoshi-monster) 79) — A supercharged take on the Elm architecture — high-performance, standards-compliant, modular, scalable, and unique to Gleam. A true gem.
- **mist** ([rawhat](https://github.com/rawhat) 363 commits) — Many frameworks here stand on the shoulder of this giant.

**🥈 Silver**
- **wisp** ([lpil](https://github.com/lpil) 278 commits, [renatillas](https://github.com/renatillas) 16) — Feature-rich and mature. A solid foundation for your application.

**🥉 Bronze**
- **http** ([lpil](https://github.com/lpil) 158 commits, [CrowdHailer](https://github.com/CrowdHailer) 29, [giacomocavalieri](https://github.com/giacomocavalieri) 28) — Shared request/response types that glue the entire ecosystem together.

| Position | Award | Repo | ★ | Lic | Compat | Maint | Age | README | Idiom | Score |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 🥇 | · [lustre-labs/lustre](https://github.com/lustre-labs/lustre)<br>· [rawhat/mist](https://github.com/rawhat/mist) | 🟩🟩<br>🟩🟩 | 🟩<br>🟩 | 🟩<br>🟩 | 🟩🟩<br>🟩🟩 | 🟩🟩<br>🟩🟩 | 🟩🟩<br>🟩🟩 | 🟩<br>🟩 | **11** |
| 2 | 🥈 | [gleam-wisp/wisp](https://github.com/gleam-wisp/wisp) | 🟩🟩 | 🟩 | 🟩 | 🟩🟩 | 🟩 | 🟩🟩 | 🟩 | **10** |
| 3 | 🥉 | [gleam-lang/http](https://github.com/gleam-lang/http) | 🟩🟩 | 🟩 | 🟩 | 🟩 | 🟩🟩 | 🟩 | 🟩 | **9** |
| 4 | | · [rawhat/glisten](https://github.com/rawhat/glisten)<br>· [vshakitskiy/ewe](https://github.com/vshakitskiy/ewe)<br>· [lustre-labs/dev-tools](https://github.com/lustre-labs/dev-tools)<br>· [ghivert/redraw](https://github.com/ghivert/redraw) | 🟩<br>🟩<br>🟩<br>🟨 | 🟩<br>🟩<br>🟩<br>🟩 | 🟩<br>🟩<br>🟩<br>🟩 | 🟩<br>🟩🟩<br>🟩🟩<br>🟩🟩 | 🟩🟩<br>🟨<br>🟩<br>🟩 | 🟩<br>🟩🟩<br>🟩<br>🟩🟩 | 🟩<br>🟩<br>🟩<br>🟩 | **8** |
| 5 | | · [TrustBound/dream](https://github.com/TrustBound/dream)<br>· [gleam-lang/cowboy](https://github.com/gleam-lang/cowboy)<br>· [RyanBrewer317/arctic](https://github.com/RyanBrewer317/arctic) | 🟨<br>🟨<br>🟨 | 🟩<br>🟩<br>🟩 | 🟩<br>🟩<br>🟩 | 🟩🟩<br>🟩<br>🟩🟩 | 🟨<br>🟩🟩<br>🟩 | 🟩🟩<br>🟩<br>🟩 | 🟩<br>🟩<br>🟩 | **7** |
| 6 | | · [glimr-org/glimr](https://github.com/glimr-org/glimr)<br>· [pairshaped/libero](https://github.com/pairshaped/libero) | 🟩<br>🟨 | 🟩<br>🟩 | 🟩<br>🟩 | 🟩🟩<br>🟩🟩 | 🟨<br>🟥 | 🟩🟩<br>🟩🟩 | 🟥<br>🟩 | **6** |
| 7 | | [pta2002/gleam-radiate](https://github.com/pta2002/gleam-radiate) | 🟨 | 🟩 | 🟩 | 🟨 | 🟩 | 🟩 | 🟩 | **5** |
| 8 | | [MystPi/glen](https://github.com/MystPi/glen) | 🟩 | 🟩 | 🟥 | 🟨 | 🟩 | 🟩 | 🟩 | **4** |

**By target:** ☎️ BEAM **103** (13 repos) · 📜 JS **38** (5 repos). Dual-target repos (lustre, http, libero) count toward both.

[How scores are calculated →](#scoring-dimensions)
