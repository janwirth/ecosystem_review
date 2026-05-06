# Hot reloading tools for Gleam

> [!NOTE]
> **Status:** DRAFT · **Authoring:** AI-assisted, human-reviewed.

Saved a file, want the running app to pick it up without a full restart or a manual refresh?
This article maps what's available across both targets.

## Table of Contents

1. [Summary](#summary)
2. [Research Method](#research-method)
   - [Scoring Dimensions](#scoring-dimensions)
   - [Discovery](#discovery)
3. [Categories](#categories)
   - [BEAM Module Reloaders](#beam-module-reloaders) — [radiate](#radiate)
   - [Server + Browser Live Reload (BEAM)](#server--browser-live-reload-beam) — [mist_reload](#mist_reload) · [olive](#olive)
   - [JS Dev Servers & Bundler Plugins](#js-dev-servers--bundler-plugins) — [lustre_dev_tools](#lustre_dev_tools) · [vite-gleam](#vite-gleam) · [vite-plugin-gleam](#vite-plugin-gleam)
   - [File Watcher Primitives](#file-watcher-primitives) — [filespy](#filespy) · [watchexec](#watchexec) · [polly](#polly)
4. [Leaderboard](#leaderboard)

## Summary

Snapshot: **2026-04-20**.

"Hot reload" means different things on each target. On BEAM it's real [hot code swapping](https://www.erlang.org/doc/system/code_loading.html) — the running VM swaps a module's bytecode under long-lived processes without dropping state. On JavaScript it's [Vite](https://vite.dev/)/[Bun](https://bun.sh/)-style HMR: the bundler replaces modules in the browser and the framework re-renders.

Gleam has separate tools for each and no single cross-target answer — the mechanisms are too different to unify.

| Category | ☎️ BEAM | 📜 JS |
| --- | --- | --- |
| **[BEAM Module Reloaders](#beam-module-reloaders)** | · [🥉](#leaderboard) [radiate](#radiate) ([repo](https://github.com/pta2002/gleam-radiate), 67★) — *watch sources, recompile, swap BEAM modules in the running VM* | — |
| **[Server + Browser Live Reload (BEAM)](#server--browser-live-reload-beam)** | · [🥉](#leaderboard) [mist_reload](#mist_reload) ([repo](https://github.com/CrowdHailer/mist_reload), 5★) — *radiate + WebSocket script injected into HTML to refresh browsers*<br>· [olive](#olive) ([repo](https://github.com/fravan/olive), 10★) — *dev proxy, dormant (README: "no longer in active development")* | — |
| **[JS Dev Servers & Bundler Plugins](#js-dev-servers--bundler-plugins)** | · [🥇](#leaderboard) [lustre_dev_tools](#lustre_dev_tools) ([repo](https://github.com/lustre-labs/dev-tools), 112★) — *Lustre CLI, Bun bundler, browser live-reload* | · [🥇](#leaderboard) [lustre_dev_tools](#lustre_dev_tools) — *serves the JS bundle; frontend target*<br>· [🥈](#leaderboard) [vite-gleam](#vite-gleam) ([repo](https://github.com/Enderchief/gleam-tools), 81★) — *Vite plugin, inherits Vite HMR*<br>· [vite-plugin-gleam](#vite-plugin-gleam) ([repo](https://github.com/gleam-br/vite-plugin-gleam), 0★) — *alternative Vite plugin, early* |
| **[File Watcher Primitives](#file-watcher-primitives)** | · [🥉](#leaderboard) [filespy](#filespy) ([repo](https://github.com/pta2002/gleam-filespy), 18★) — *`fs` NIF wrapper, inotify/FSEvents*<br>· [watchexec](#watchexec) ([repo](https://github.com/lpil/watchexec), 5★) — *`watchexec` CLI wrapped as Erlang port*<br>· [polly](#polly) ([repo](https://gitlab.com/arkandos/polly)) — *polling watcher, used by lustre_dev_tools* | — |

> [!IMPORTANT]
> **No single tool covers both targets.** BEAM reloaders swap compiled `.beam` modules in the running VM; JS tools rebuild the bundle and push HMR patches to the browser. Pick per target; compose if your app has both.

> [!NOTE]
> Only `radiate` does actual BEAM hot code swap. `mist_reload` and `olive` add a browser refresh on top. `lustre_dev_tools` is the blessed path for Lustre SPAs. Vite plugins give you stock Vite HMR if you prefer that stack.

> [!WARNING]
> **Lustre server components are a blind spot.** Server components run on BEAM and stream DOM patches to a 10 kB browser runtime over WebSocket — a different reload path from either SPA HMR or server-HTML refresh. **No reviewed tool documents a server-component dev loop.** The BEAM reloaders (`radiate`, `mist_reload`) fit in principle: swap the component module, reconnect the WebSocket on browser refresh. JS bundler tools (`vite-gleam`, `vite-plugin-gleam`) don't fit — server component code never ships to JS. See the `Lustre server components` row in each table for per-tool inference.

> <details>
> <summary><strong>Dependency Graph</strong></summary>
>
> Arrows read "uses."
>
> **Reloaders:**
> - [mist_reload](#mist_reload) → [radiate](#radiate) + WebSocket injection
> - [radiate](#radiate) → [filespy](#filespy) (file events)
> - [olive](#olive) → `fs` + `simplifile` + `mist` + `wisp` (self-contained)
>
> **JS stack:**
> - [lustre_dev_tools](#lustre_dev_tools) → [polly](#polly) (file watcher) + [mist](./web-apps.md#mist) (dev HTTP) + [lustre](./web-apps.md#lustre) + Bun (bundler, runtime dep)
> - [vite-gleam](#vite-gleam), [vite-plugin-gleam](#vite-plugin-gleam) → Vite (external, npm)
>
> **Watchers:**
> - [filespy](#filespy) → Erlang `fs` (inotify/FSEvents/ReadDirectoryChangesW)
> - [watchexec](#watchexec) → `watchexec` CLI (external binary) via Erlang port
> - [polly](#polly) → pure polling (no native deps)
>
> </details>

## Research Method

### Scoring Dimensions

Same rubric as [web-apps.md](./web-apps.md#scoring-dimensions). Recap:

- **Stars:** 🟩🟩 ≥200★, 🟩 ≥100★, 🟨 ≥10★, 🟥 <10★.
- **License:** 🟩 permissive (MIT/Apache/BSD), 🟥 viral or missing.
- **Gleam compat:** `gleam_stdlib` constraint format. 🟩 range (`>= X and < Y`), 🟥 `~>` pin. N/A for npm-only packages (no `gleam.toml`) — scored 🟩 (no resolver conflict possible).
- **Maintenance:** max(recency, responsiveness). 🟩🟩 <1 mo / <2 days / clean tracker, 🟩 <6 mo / <1 wk, 🟨 <1 yr / <1 mo, 🟥 older / ignored.
- **Age:** 🟩🟩 ≥3 yr, 🟩 ≥1 yr, 🟨 ≥3 mo, 🟥 <3 mo.
- **README maturity:** 🟩🟩 full guide + examples, 🟩 clear tagline + usage, 🟥 minimal.
- **Idiomaticity:** 🟩 typed/explicit, 🟥 magic directives or template extraction.

**Leaderboard:** 🟥 = −1, 🟨 = 0, 🟩 = 1, 🟩🟩 = 2. Sum of 7 dimensions, max 13.

**Non-scored criterion — Lustre server components support:** Whether the tool fits the [Lustre server components](https://hexdocs.pm/lustre/lustre/server_component.html) dev loop — components run on BEAM and stream DOM patches to a ~10 kB browser runtime over WebSocket. **None of the reviewed tools document this explicitly**, so the value is inferred from the reload mechanism: 🟩 = mechanism fits (BEAM module reload picks up changed component code; a page refresh cleanly reconnects the server-component WebSocket), 🟥 = mechanism incompatible (tool bundles Gleam to JS; server components never ship to JS), ⬜ = no evidence either way. Confirm for your own project before relying on it.

### Discovery

Searches run on [Gleam packages registry](https://packages.gleam.run/) plus npm for Vite plugins. Terms: `reload`, `hot`, `live`, `watch`, `watcher`, `dev`, `hmr`, `vite`. Cross-checked via web search for "gleam hot reload" / "gleam HMR" / "gleam live reload".

**9 included** (below). **5 disregarded** — stale or out of scope:

> <details>
> <summary>5 disregarded</summary>
>
> - **[PROMETHIA-27/halo](https://github.com/PROMETHIA-27/halo)** — Hot-reloading REPL. 5★, last commit 2024-02, ~2 years dormant. Maintenance 🟥.
> - **[WhoAteDaCake/file-watcher](https://github.com/WhoAteDaCake/file-watcher)** — 1★, last commit 2021-06. Abandoned. Maintenance 🟥.
> - **[esgleam](https://hexdocs.pm/esgleam/)** — Bundler with `serve` command, but file watching and HMR are explicitly unimplemented roadmap items. Not hot-reload today.
> - **[gleam_compile](https://hexdocs.pm/gleam_compile/)** — Embeds Gleam in Elixir/Phoenix; delegates reload to Phoenix LiveReload. Adjacent, not standalone.
> - **[vleam/vleam](https://github.com/vleam/vleam)** — Vue SFC + Gleam LSP proxy. 139★, archived 2026-02. Editor integration, not dev-time reload.
>
> </details>

## Categories

### BEAM Module Reloaders

Watch sources, recompile changed modules, load the new bytecode into the running VM. Long-lived processes keep their state; code paths take effect immediately.

| Criterion | [radiate](https://github.com/pta2002/gleam-radiate) [🥉](#leaderboard) |
| --- | --- |
| Stars | 67★ · 🟨 |
| License | Apache-2.0 · 🟩 |
| Target | ☎️ BEAM |
| Deps | 5 |
| Gleam compat | `>= 0.44 and < 2.0` · 🟩 |
| Maintenance | 🟨 (last commit 2025-09-18, ~7 mo before snapshot; 3 open issues) |
| Age | ~2.5 years (Oct 2023) · 🟩 |
| README maturity | 🟩 (tagline + working example) |
| Idiomaticity | 🟩 |
| Lustre server components | 🟩 *(inferred — reloads any BEAM module, including server component code)* |

#### radiate
[repo](https://github.com/pta2002/gleam-radiate) · [🥉](#leaderboard)

"Hot reloading while in development for Gleam!" The only tool in the ecosystem that does real BEAM hot code swap: watches a directory via [filespy](#filespy), reruns `gleam build`, and reloads changed `.beam` modules into the running VM. Callback hook lets you run your own logic on reload (e.g. re-render UI). Gen-purpose — works for any BEAM-target app, not tied to a framework.

```gleam
import radiate

pub fn main() {
  let _ =
    radiate.new()
    |> radiate.add_dir("src")
    |> radiate.on_reload(fn(_) { io.println("reloaded") })
    |> radiate.start()

  // your normal app code here; it keeps running while code swaps underneath
}
```

### Server + Browser Live Reload (BEAM)

BEAM module reload + a WebSocket telling the browser to refresh. For full-stack apps where you want both sides updated on save.

| Criterion | [mist_reload](https://github.com/CrowdHailer/mist_reload) [🥉](#leaderboard) | [olive](https://github.com/fravan/olive) |
| --- | --- | --- |
| Stars | 5★ · 🟥 | 10★ · 🟨 |
| License | Apache-2.0 · 🟩 | Apache-2.0 · 🟩 |
| Target | ☎️ BEAM | ☎️ BEAM |
| Deps | 5 | 14 |
| Gleam compat | `>= 0.44 and < 2.0` · 🟩 | `>= 0.50 and < 2.0` · 🟩 |
| Maintenance | 🟩🟩 (last 2026-03-28, ~3 wk; 1 issue) | 🟥 (last 2025-07-18, ~9 mo; README: "no longer in active development") |
| Age | ~7 months (first commit 2025-09-16) · 🟨 | ~14 months (first commit 2025-02-21) · 🟩 |
| README maturity | 🟩 (tagline + `gleam add --dev` usage) | 🟩 (features + usage + explicit deprecation note) |
| Idiomaticity | 🟩 | 🟩 |
| Lustre server components | 🟩 *(inferred — BEAM reload via radiate; page refresh reconnects server-component WebSocket)* | ⬜ *(mechanism fits but dormant; not recommended)* |

#### mist_reload
[repo](https://github.com/CrowdHailer/mist_reload) · [🥉](#leaderboard)

"Reload your mist web application in development, supports wisp etc." Wraps radiate and injects a tiny WebSocket client into served HTML so the browser refreshes the moment the BEAM module reloads. Install as dev dep. Low stars but actively maintained as of 2026-03 and fills a real gap (radiate reloads server code; this extends the loop to the browser).

```gleam
// Wrap your normal mist handler in mist_reload.handler during dev
import mist
import mist_reload

pub fn main() {
  let assert Ok(_) =
    fn(req) { your_handler(req) }
    |> mist_reload.handler
    |> mist.new
    |> mist.port(4000)
    |> mist.start
}
```

#### olive
[repo](https://github.com/fravan/olive)

"A gleam dev proxy to enable live reload and smoother DX." Dev proxy that sits in front of mist/wisp, watches files via `fs` + `simplifile`, recompiles, and pushes a reload to the browser. **The author's README states the project is no longer in active development** and warns of rough edges. Listed for completeness — prefer `mist_reload` for new projects.

### JS Dev Servers & Bundler Plugins

JS-target apps need browser HMR, not BEAM code swap. Two paths: Lustre's official tooling (opinionated, Bun-based, zero-config) or plug Gleam into your existing Vite pipeline.

| Criterion | [lustre_dev_tools](https://github.com/lustre-labs/dev-tools) [🥇](#leaderboard) | [vite-gleam](https://github.com/Enderchief/gleam-tools) [🥈](#leaderboard) | [vite-plugin-gleam](https://github.com/gleam-br/vite-plugin-gleam) |
| --- | --- | --- | --- |
| Stars | 112★ · 🟩 | 81★ · 🟨 *(monorepo, vite-gleam subpackage)* | 0★ · 🟥 |
| License | MIT · 🟩 | MIT · 🟩 | Apache-2.0 · 🟩 |
| Target | ☎️ BEAM tool → 📜 JS output | 📜 JS (npm) | 📜 JS (npm) |
| Gleam compat | `>= 0.60 and < 2.0` · 🟩 | N/A · 🟩 (npm package) | N/A · 🟩 (npm package) |
| Maintenance | 🟩🟩 (active, ~2 wk before snapshot) | 🟩 (last 2025-11-22, ~5 mo) | 🟩 (last 2025-12-18, ~4 mo) |
| Age | ~2 years (Mar 2024) · 🟩 | ~2.7 years (first commit 2023-08-19) · 🟩 | ~5 months (first commit 2025-11-16) · 🟨 |
| README maturity | 🟩 (features list, install guide, no code samples) | 🟩 (plugin usage + examples) | 🟩 (usage + config) |
| Idiomaticity | 🟩 | 🟩 | 🟩 |
| Lustre server components | ⬜ *(docs only describe SPA dev loop; server-component reload path is undocumented — verify before relying on it)* | 🟥 *(bundles Gleam → JS; server components run on BEAM and never ship to JS)* | 🟥 *(same: JS-only)* |

#### lustre_dev_tools
[repo](https://github.com/lustre-labs/dev-tools) · [🥇](#leaderboard)

Lustre's official CLI. Zero-config dev server, Bun-based bundling, TailwindCSS v4 auto-detection, browser live reload. Watches via [polly](#polly). CLI-driven — no Gleam API to integrate. Also covered in the main [web-apps](./web-apps.md#lustre_dev_tools) article; included here because live reload is its core dev-UX feature.

```sh
gleam add lustre_dev_tools --dev
gleam run -m lustre/dev start   # dev server + HMR-like reload
```

#### vite-gleam
[repo](https://github.com/Enderchief/gleam-tools) ([npm](https://www.npmjs.com/package/vite-gleam))

Vite plugin that lets you `import` `.gleam` files directly from JS/TS, compiled via Gleam's `--target javascript`. HMR is whatever Vite gives you — module replacement with state preservation, full browser reload on unreplaceable changes. Part of the `gleam-tools` monorepo (which also ships a TS LSP plugin). For teams already on Vite/React/Svelte who want to mix in Gleam modules.

```ts
// vite.config.ts
import { defineConfig } from "vite"
import gleam from "vite-gleam"

export default defineConfig({
  plugins: [gleam()],
})
```

#### vite-plugin-gleam
[repo](https://github.com/gleam-br/vite-plugin-gleam)

Newer, independently authored Vite plugin with different configuration surface. Zero traction yet (0★) but recent (last commit 2025-12-18). Listed so readers know both exist; prefer `vite-gleam` until this one accrues users.

### File Watcher Primitives

Not reload tools themselves — the OS-level file-event libraries that the reloaders build on. Included because if you're rolling your own dev tooling, these are the three picks.

| Criterion | [filespy](https://github.com/pta2002/gleam-filespy) | [watchexec](https://github.com/lpil/watchexec) | [polly](https://gitlab.com/arkandos/polly) |
| --- | --- | --- | --- |
| Stars | 18★ · 🟨 | 5★ · 🟥 | ⬜ (GitLab) · 🟥 |
| License | Apache-2.0 · 🟩 | Apache-2.0 · 🟩 | ⬜ · 🟩 *(assumed permissive; verify before use)* |
| Target | ☎️ BEAM | ☎️ BEAM | ☎️ BEAM |
| Gleam compat | `>= 0.44 and < 2.0` · 🟩 | `>= 0.44 and < 2.0` · 🟩 | ⬜ · 🟩 |
| Maintenance | 🟨 (last 2025-08-13, ~8 mo) | 🟩🟩 (last 2026-02-02, v1.0.0, clean tracker) | 🟩 (used by lustre_dev_tools, kept current) |
| Age | ~2.5 years (first commit 2023-10-21) · 🟩 | ~2.7 months (first commit 2026-01-29) · 🟥 | ~2+ years · 🟩 |
| README maturity | 🟩 | 🟩 | 🟨 *(tagline, minimal)* |
| Idiomaticity | 🟩 | 🟩 | 🟩 |
| Lustre server components | 🟩 *(primitive; compose with radiate or your own reloader)* | 🟩 *(primitive; same)* | 🟩 *(primitive; same)* |

Mechanics:
- **filespy** — Erlang `fs` NIF (inotify/FSEvents/ReadDirectoryChangesW). Native events, zero polling cost. Powers radiate.
- **watchexec** — spawns the [`watchexec`](https://github.com/watchexec/watchexec) CLI as an Erlang port. Cross-platform, needs the binary installed. lpil's, v1.0.0 just shipped.
- **polly** — pure-Gleam polling. No NIFs, no external binaries — costlier CPU, but works anywhere. Powers lustre_dev_tools' bundler hot reload.

#### filespy
Tagline: "Get notified of filesystem events in Gleam." Returns a stream of typed events.

```gleam
import filespy

pub fn main() {
  filespy.new()
  |> filespy.add_dir("src")
  |> filespy.set_handler(fn(path, event) {
    io.println("changed: " <> path)
  })
  |> filespy.start()
}
```

#### watchexec
Tagline: "Use watchexec as a cross-platform file event watcher on the BEAM!" Sidesteps NIF compilation by shelling out to the `watchexec` binary through an Erlang port.

#### polly
Polling-based watcher used by [lustre_dev_tools](#lustre_dev_tools). Lives on GitLab. Preferred when you can't rely on NIFs or external binaries (sandboxed CI, WASM-adjacent envs).

## Leaderboard
Every contribution is invaluable and appreciated.

Medals assigned strictly by score (ties share a medal). polly is listed but excluded from scoring (no reliable GitLab metrics).

**🥇 Gold**
- **lustre_dev_tools** ([hayleigh-dot-dev](https://github.com/hayleigh-dot-dev), [yoshi-monster](https://github.com/yoshi-monster)) — The blessed dev loop for Lustre SPAs: bundling, serving, and browser reload in one CLI.

**🥈 Silver**
- **vite-gleam** ([Enderchief](https://github.com/Enderchief)) — The bridge for teams already on Vite. Lets you drop `.gleam` files into a JS/TS Vite project and get stock Vite HMR.

**🥉 Bronze** (three-way tie)
- **radiate** ([pta2002](https://github.com/pta2002)) — The only real BEAM hot code swap in the Gleam ecosystem. Everything else that reloads server code stands on this.
- **filespy** ([pta2002](https://github.com/pta2002)) — The native file-event primitive radiate (and anything else on BEAM) builds on.
- **mist_reload** ([CrowdHailer](https://github.com/CrowdHailer)) — Small surface, real gap: extends radiate's server reload to the browser for mist/wisp apps. Low stars but actively maintained.

| Position | Award | Repo | ★ | Lic | Compat | Maint | Age | README | Idiom | Score |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 🥇 | [lustre-labs/dev-tools](https://github.com/lustre-labs/dev-tools) | 🟩 | 🟩 | 🟩 | 🟩🟩 | 🟩 | 🟩 | 🟩 | **8** |
| 2 | 🥈 | [Enderchief/gleam-tools](https://github.com/Enderchief/gleam-tools) (vite-gleam) | 🟨 | 🟩 | 🟩 | 🟩 | 🟩 | 🟩 | 🟩 | **6** |
| 3 | 🥉 | · [pta2002/gleam-radiate](https://github.com/pta2002/gleam-radiate)<br>· [pta2002/gleam-filespy](https://github.com/pta2002/gleam-filespy)<br>· [CrowdHailer/mist_reload](https://github.com/CrowdHailer/mist_reload) | 🟨<br>🟨<br>🟥 | 🟩<br>🟩<br>🟩 | 🟩<br>🟩<br>🟩 | 🟨<br>🟨<br>🟩🟩 | 🟩<br>🟩<br>🟨 | 🟩<br>🟩<br>🟩 | 🟩<br>🟩<br>🟩 | **5** |
| 4 | | · [lpil/watchexec](https://github.com/lpil/watchexec)<br>· [gleam-br/vite-plugin-gleam](https://github.com/gleam-br/vite-plugin-gleam)<br>· [fravan/olive](https://github.com/fravan/olive) | 🟥<br>🟥<br>🟨 | 🟩<br>🟩<br>🟩 | 🟩<br>🟩<br>🟩 | 🟩🟩<br>🟩<br>🟥 | 🟥<br>🟨<br>🟩 | 🟩<br>🟩<br>🟩 | 🟩<br>🟩<br>🟩 | **4** |

**By target:** ☎️ BEAM **31** (6 scored repos) · 📜 JS **18** (3 scored repos). `lustre_dev_tools` counts toward both (BEAM-target tool that produces a JS dev server).

[How scores are calculated →](#scoring-dimensions)
