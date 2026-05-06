# Adding Tailwind to a Gleam App

> [!NOTE]
> **Status:** DRAFT · **Authoring:** AI-assisted, human-reviewed.

You picked Gleam and Lustre (or Wisp). Now you want utility classes. What does
the ecosystem actually offer for [Tailwind CSS](https://tailwindcss.com/) — and
what's just "download the standalone CLI yourself"?

This article maps the (small) Gleam-specific surface around Tailwind and the
language-agnostic fallbacks worth knowing.

## Table of Contents

1. [Summary](#summary)
2. [Research Method](#research-method)
   - [Scoring Dimensions](#scoring-dimensions)
   - [Discovery](#discovery)
3. [Categories](#categories)
   - [Zero-Config Integrations](#zero-config-integrations) — [lustre_dev_tools](#lustre_dev_tools)
   - [Standalone CLI Wrappers](#standalone-cli-wrappers) — [glailglind](#glailglind)
   - [Class Utilities](#class-utilities) — [glailwind_merge](#glailwind_merge) · [lustre_transition](#lustre_transition)
   - [Component Kits](#component-kits) — [gleez](#gleez)
   - [No-Package Baseline](#no-package-baseline-the-standalone-binary) — *standalone binary*
   - [Alternatives to Tailwind in Gleam](#alternatives-to-tailwind-in-gleam) — *sketch · lustre_ui*
4. [Leaderboard](#leaderboard)
5. [Related Work](#related-work)

## Summary

Snapshot: **2026-04-24**.

Tailwind in Gleam is a thin slice. The headline finding: **if you're on Lustre,
[lustre_dev_tools](#lustre_dev_tools) auto-detects an `@import "tailwindcss"` in
your CSS and downloads + runs the official Tailwind v4 standalone binary for
you — zero extra packages.** If you're not on Lustre (Wisp, mist, SSG), the
honest answer is: **download the [standalone Tailwind binary](https://github.com/tailwindlabs/tailwindcss/releases)
and shell out to it from a build script**. [glailglind](#glailglind) packages
that subprocess pattern as a Gleam library; everything else is conveniences on
top.

| Category | Tool | What it does |
| --- | --- | --- |
| **[Zero-Config Integrations](#zero-config-integrations)** | [🥇](#leaderboard) [lustre_dev_tools](#lustre_dev_tools) ([repo](https://github.com/lustre-labs/dev-tools), 111★) | Auto-detects `@import "tailwindcss"`, downloads the v4 standalone binary, runs it on dev/build |
| **[Standalone CLI Wrappers](#standalone-cli-wrappers)** | [🥇](#leaderboard) [glailglind](#glailglind) ([repo](https://github.com/okkdev/glailglind), 49★) | Same pattern, framework-agnostic: `tailwind/install` + `tailwind/run` modules you call from your build |
| **[Class Utilities](#class-utilities)** | [glailwind_merge](#glailwind_merge) ([repo](https://github.com/dinkelspiel/glailwind_merge), 1★) | `tw_merge` — resolve conflicting utility classes (JS target only, wraps `tailwind-merge`) |
| | [lustre_transition](#lustre_transition) ([hex](https://hex.pm/packages/lustre_transition)) | Enter/leave transition state machine that toggles Tailwind classes for Lustre views |
| **[Component Kits](#component-kits)** | [gleez](#gleez) ([repo](https://github.com/MAHcodes/gleez), 61★) | shadcn-style copy/paste Lustre components built on Tailwind + 7 named CSS variables |
| **[No-Package Baseline](#no-package-baseline-the-standalone-binary)** | *Tailwind standalone binary* | Download → `./tailwindcss -i in.css -o out.css --watch`. No Gleam package needed |
| **[Alternatives](#alternatives-to-tailwind-in-gleam)** | sketch · lustre_ui | Skip Tailwind entirely: typed CSS-in-Gleam or pre-built design tokens |

> [!IMPORTANT]
> **Lustre users:** start with [lustre_dev_tools](#lustre_dev_tools). It already
> does the right thing — adding any other Tailwind package is duplicate machinery.
>
> **Everyone else (Wisp, mist, SSG, custom builds):** [glailglind](#glailglind)
> is the only Gleam package that wraps the Tailwind CLI in a framework-agnostic
> way. The "no-package" baseline (running the standalone binary directly) is also
> a perfectly fine answer and is what every Gleam Tailwind tool ultimately does
> under the hood.

> [!NOTE]
> **There is no "compile classes from Gleam types" library** (a la `cva` /
> `tailwind-variants` / `panda-css`). The closest thing is [glailwind_merge](#glailwind_merge)
> for conflict resolution and [lustre_transition](#lustre_transition) for animation
> sequencing — both narrow utilities, not full type-safe class systems. If you want
> typed styles, use [sketch](https://hexdocs.pm/sketch/) and skip Tailwind.

> <details>
> <summary><strong>Dependency Graph</strong></summary>
>
> Arrows read "uses."
>
> - [lustre_dev_tools](#lustre_dev_tools) → downloads the Tailwind v4 standalone binary from `tailwindlabs/tailwindcss` GitHub releases, verifies SHA-256, runs it as a subprocess
> - [glailglind](#glailglind) → same: downloads + invokes the standalone binary (`shellout` + `gleam_httpc`)
> - [gleez](#gleez) → expects you to already have Tailwind set up (BYO build pipeline) + 7 named CSS variables
> - [glailwind_merge](#glailwind_merge) → [tails](https://hex.pm/packages/tails) (Elixir port; JS target)
> - [lustre_transition](#lustre_transition) → [lustre](./web-apps.md#lustre)
>
> </details>

## Research Method

### Scoring Dimensions

Same rubric as [web-apps.md](./web-apps.md#scoring-dimensions). Recap:

- **Stars:** 🟩🟩 ≥200★, 🟩 ≥100★, 🟨 ≥10★, 🟥 <10★.
- **License:** 🟩 permissive (MIT/Apache/BSD), 🟥 viral or missing.
- **Gleam compat:** `gleam_stdlib` constraint format. 🟩 range (`>= X and < Y`), 🟥 `~>` pin. N/A for packages with no Gleam deps → scored 🟩 (no resolver conflict).
- **Maintenance:** max(recency, responsiveness). 🟩🟩 <1 mo / <2 days / clean tracker, 🟩 <6 mo / <1 wk, 🟨 <1 yr / <1 mo, 🟥 older / ignored.
- **Age:** 🟩🟩 ≥3 yr, 🟩 ≥1 yr, 🟨 ≥3 mo, 🟥 <3 mo.
- **README maturity:** 🟩🟩 full guide + examples, 🟩 clear tagline + usage, 🟥 minimal.
- **Idiomaticity:** 🟩 typed/explicit, 🟥 magic directives or template extraction.

**Leaderboard:** 🟥 = −1, 🟨 = 0, 🟩 = 1, 🟩🟩 = 2. Sum of 7 dimensions, max 13.

> [!NOTE]
> **License caveat for [lustre_dev_tools](#lustre_dev_tools) and [glailglind](#glailglind):**
> both declare a permissive license in `gleam.toml` / `hex.pm` metadata (MIT and
> Apache-2.0 respectively) but neither ships a `LICENSE` file at the repo root,
> so GitHub's API reports `license: null`. Hex requires a license declaration to
> publish, so the metadata is authoritative. Scored 🟩.

### Discovery

Searches run on the [Gleam packages registry](https://packages.gleam.run/) for
`tailwind`, `css`, `style`, plus the [awesome-gleam](https://github.com/gleam-lang/awesome-gleam)
README, plus web search for "gleam tailwind" / "lustre tailwind" / "wisp tailwind".

**5 included** (below). Two adjacent things — [sketch](https://hexdocs.pm/sketch/)
(CSS-in-Gleam) and [lustre_ui](https://hexdocs.pm/lustre_ui/) (design tokens) —
get a one-paragraph mention in [Alternatives](#alternatives-to-tailwind-in-gleam)
because they're what you'd reach for *instead of* Tailwind, not as a Tailwind
integration.

> [!NOTE]
> **No native Gleam Tailwind compiler exists** — and there's no reason to want
> one. Tailwind's whole compute model is "scan source files for class names,
> emit CSS." The official standalone binary already does this without needing a
> Node/Elixir/Gleam runtime, so every ecosystem (Phoenix, Rails, Django, Gleam)
> arrives at the same answer: shell out to the binary. The packages below are
> conveniences over that subprocess.

## Categories

### Zero-Config Integrations

A single tool wired into your dev loop that handles install, watch, and build of
Tailwind without you writing a build script.

| Criterion | [lustre_dev_tools](https://github.com/lustre-labs/dev-tools) [🥇](#leaderboard) |
| --- | --- |
| Stars | 111★ · 🟩 |
| License | MIT (`gleam.toml`; no `LICENSE` file) · 🟩 |
| Target | ☎️ BEAM tool → 📜 JS output |
| Deps | 20 |
| Gleam compat | `>= 0.60 and < 2.0` · 🟩 |
| Maintenance | 🟩🟩 (last commit 2026-04-21, ~3 days before snapshot; 16 open issues) |
| Age | ~2.1 years (first commit 2024-03-20) · 🟩 |
| README maturity | 🟩 (features list + install; deeper docs in hexdocs `assets.html` and `toml-reference.html`) |
| Idiomaticity | 🟩 |

#### lustre_dev_tools
[repo](https://github.com/lustre-labs/dev-tools) · [hexdocs](https://hexdocs.pm/lustre_dev_tools/) · [🥇](#leaderboard)

Lustre's official CLI. The README's three-line feature list literally calls out
"**Automatic detection and support for TailwindCSS v4**" alongside dev server +
bundling. The mechanism (visible in [`src/lustre_dev_tools/bin/tailwind.gleam`](https://github.com/lustre-labs/dev-tools/blob/main/src/lustre_dev_tools/bin/tailwind.gleam)):
on every dev / build run it scans your CSS entry for `@import "tailwindcss"` (or
a legacy `tailwind.config.js`), and if found, downloads the platform-appropriate
[Tailwind standalone binary](https://github.com/tailwindlabs/tailwindcss/releases)
into `.lustre/`, verifies its SHA-256, and runs it. No `package.json`, no `npm
install`, no Node.

```sh
gleam add lustre_dev_tools --dev
mkdir -p assets
echo '@import "tailwindcss";' > assets/style.css
gleam run -m lustre/dev start   # auto-downloads tailwind, watches, live-reloads
```

To disable the auto-detection (e.g. if you want to manage Tailwind yourself or
use a system install) — from the [TOML reference](https://hexdocs.pm/lustre_dev_tools/toml-reference.html):

```toml
[tools.lustre.build]
no_tailwind = true

[tools.lustre.bin]
tailwindcss = "system"   # or an absolute path
```

Also covered in [hot-reloading.md](./hot-reloading.md#lustre_dev_tools) for the
dev-server side and [web-apps.md](./web-apps.md#lustre_dev_tools) for the
broader CLI surface.

### Standalone CLI Wrappers

Same idea as the Lustre integration — download and run the Tailwind binary —
but framework-agnostic. Use these from a Wisp build, an [arctic](./web-apps.md#arctic)
SSG pipeline, or anywhere you don't have lustre_dev_tools.

| Criterion | [glailglind](https://github.com/okkdev/glailglind) [🥇](#leaderboard) |
| --- | --- |
| Stars | 49★ · 🟨 |
| License | Apache-2.0 (hex.pm; no `LICENSE` file) · 🟩 |
| Target | ☎️📜 Both (BEAM + JS; JS target needs `curl` on host) |
| Deps | 7 |
| Gleam compat | `>= 1.0.0 and < 2.0.0` · 🟩 |
| Maintenance | 🟩🟩 (last commit 2026-04-20, ~4 days before snapshot; **0 open issues**) |
| Age | ~2.5 years (first commit 2023-10-11) · 🟩 |
| README maturity | 🟩🟩 (full guide: install, CSS, run, plus a worked LustreSSG build script) |
| Idiomaticity | 🟩 |

#### glailglind
[repo](https://github.com/okkdev/glailglind) · [hexdocs](https://hexdocs.pm/glailglind/) · [🥇](#leaderboard)

"Installs and invokes TailwindCSS CLI." Heavily inspired by Phoenix's
[`phoenixframework/tailwind`](https://github.com/phoenixframework/tailwind/) — same
pattern, ported to Gleam. Two operations, both runnable via `gleam run`:

```toml
# gleam.toml — args go straight to the tailwindcss binary
[tools.tailwind]
version = "4.2.2"   # optional — pins which standalone release to download
args = [
  "--input=./src/css/app.css",
  "--output=./priv/css/app.css",
]
path = "/path/to/tailwindcss"   # optional — skip the download, use a system binary
```

```sh
gleam add glailglind --dev
gleam run -m tailwind/install   # downloads CLI to ./build/bin/tailwindcss
gleam run -m tailwind/run       # runs `tailwindcss <args>` (one-shot or --watch)
```

You can also call `tailwind.run([...])` from any Gleam build script (the README
has a worked LustreSSG example chaining `ssg.build` → `tailwind.run`). The
README explicitly cross-links to lustre_dev_tools and tells Lustre users to use
that instead — a notably honest stance.

**Why 🟩🟩 maintenance:** 0 open issues, last commit 4 days before snapshot.
The "zero issues" signal here is a positive maintenance signal beyond just the
recent commit date.

### Class Utilities

Helpers that operate on the class strings you generate, not on the build pipeline.

| Criterion | [glailwind_merge](https://github.com/dinkelspiel/glailwind_merge) | [lustre_transition](https://hex.pm/packages/lustre_transition) |
| --- | --- | --- |
| Stars | 1★ · 🟥 | ⬜ (GH repo `codemonkey76/lustre_transition` returns 404) · 🟥 |
| License | MIT (hex.pm; no `LICENSE` file) · 🟩 | MIT (`gleam.toml`) · 🟩 |
| Target | 📜 JS only | 📜 JS only |
| Deps | 1 (`tails`, an Elixir-port library) | 2 (`gleam_stdlib`, `lustre`) |
| Gleam compat | N/A (no `gleam_stdlib` dep declared) · 🟩 | `>= 0.34.0 and < 2.0.0` · 🟩 |
| Maintenance | 🟥 (last commit 2024-10-19, ~18 mo; 0 issues but no activity) | 🟥 (last hex release 2024-06-24, ~22 mo; GH repo missing) |
| Age | ~1.5 years (first commit 2024-10-19) · 🟩 | ~1.8 years (first hex release 2024-06) · 🟩 |
| README maturity | 🟩 (tagline + minimal example; TODO note about replacing Elixir dep) | 🟩 (tagline + Tailwind use note via hexdocs) |
| Idiomaticity | 🟩 | 🟩 |

#### glailwind_merge
[repo](https://github.com/dinkelspiel/glailwind_merge) · [hexdocs](https://hexdocs.pm/glailwind_merge/)

A Gleam wrapper around the `tailwind-merge` algorithm: takes a list of class
strings that may contain conflicting utilities (e.g. two `justify-*` values) and
returns a single string with later classes winning per Tailwind's specificity
rules. Useful when you compose classes from props/variants and need to dedupe
deterministically.

```gleam
import glailwind_merge
import gleam/io

pub fn main() {
  glailwind_merge.tw_merge(["justify-center bg-red-500", "justify-start"])
  |> io.println
  // → bg-red-500 justify-start
}
```

JS target only. The README is honest that it currently depends on an Elixir
library (`tails`) and notes "Move from elixir dependency to erlang or gleam
implementation" as a TODO. Low traction (1★, 18 months stale) — included
because conflict resolution is a real Tailwind problem with no other Gleam
answer.

#### lustre_transition
[hex](https://hex.pm/packages/lustre_transition) · [hexdocs](https://hexdocs.pm/lustre_transition/)

Enter/leave transition state machine for Lustre views. You declare classes for
each transition phase (`enter`, `enter-from`, `enter-to`, `leave`, `leave-from`,
`leave-to`) — the library toggles them in the right sequence so Tailwind's
transition utilities (`transition`, `duration-300`, `opacity-0`, etc.) actually
fire. The hexdocs note that you must declare a `hidden` class explicitly "so
that tailwind doesn't strip out this class" — important for Tailwind v4's JIT
which only emits classes it sees in source files.

> [!WARNING]
> The GitHub repository `codemonkey76/lustre_transition` returns 404 at snapshot
> — only the [hex package](https://hex.pm/packages/lustre_transition) and
> [hexdocs](https://hexdocs.pm/lustre_transition/) remain. Last release was
> 2024-06-24 (v0.2.0). Use only if you're prepared to vendor the source from
> hex.

### Component Kits

Pre-built UI components that *use* Tailwind. Not a Tailwind integration per se
— they assume you've already wired up Tailwind via one of the tools above.

| Criterion | [gleez](https://github.com/MAHcodes/gleez) |
| --- | --- |
| Stars | 61★ · 🟨 |
| License | MIT · 🟩 |
| Target | ☎️📜 Both (Lustre components compile to either) |
| Deps | 5 |
| Gleam compat | `>= 0.34.0 and < 2.0.0` · 🟩 |
| Maintenance | 🟨 (last commit 2025-06-04, ~10.5 mo before snapshot; 1 open issue) |
| Age | ~2.0 years (first commit 2024-04) · 🟩 |
| README maturity | 🟩 (concept + colors + theme setup; not a step-by-step "first component" guide) |
| Idiomaticity | 🟩 |

#### gleez
[repo](https://github.com/MAHcodes/gleez) · [hexdocs](https://hexdocs.pm/gleez/) · [demo](https://gleez.netlify.app/)

shadcn for Lustre — explicitly: *"This is NOT a component library. It's a
collection of re-usable components that you can copy and paste into your apps."*
Distributed via a `gleez` CLI that copies component source into your project.
Components require seven named CSS variables (`--neutral`, `--primary`,
`--secondary`, `--success`, `--info`, `--warning`, `--danger`) defined as HSL
triples for light + dark mode, plus a `tailwind.config.js` that maps them to
Tailwind color names.

```js
// tailwind.config.js — required mapping
module.exports = {
  theme: {
    extend: {
      colors: {
        primary: {
          DEFAULT: "hsl(var(--primary) / <alpha-value>)",
          foreground: "hsl(var(--primary-foreground) / <alpha-value>)",
        },
        // ... neutral, secondary, success, info, warning, danger
      },
    },
  },
}
```

```css
/* assets/style.css */
@layer base {
  :root, .light {
    --primary: 331 82% 64%;
    --primary-foreground: 220 23% 95%;
    /* ... */
  }
  .dark {
    --primary: 331 82% 64%;
    --primary-foreground: 240 21% 15%;
    /* ... */
  }
}
```

Components themselves take a typed `Color` value (`Neutral | Primary | Secondary | Success | Info | Warning | Danger`) so call sites stay typed even though the styling is utility-class-based.

### No-Package Baseline: the standalone binary

You don't need any Gleam package to use Tailwind in a Gleam app. Tailwind ships
[platform-native standalone binaries](https://github.com/tailwindlabs/tailwindcss/releases)
(`tailwindcss-linux-x64`, `tailwindcss-macos-arm64`, etc.) with zero runtime
dependencies. This is exactly what `lustre_dev_tools` and `glailglind` download
under the hood — you can do it yourself.

For a Wisp app or any non-Lustre setup:

```sh
# Download the binary once (per-machine or vendored in repo)
curl -sLO https://github.com/tailwindlabs/tailwindcss/releases/latest/download/tailwindcss-linux-x64
chmod +x tailwindcss-linux-x64

# Create your CSS entry
mkdir -p priv/static src/css
echo '@import "tailwindcss";' > src/css/app.css

# Watch (dev) — Tailwind v4 scans src/ for class names automatically
./tailwindcss-linux-x64 -i src/css/app.css -o priv/static/app.css --watch
```

Then have Wisp serve `priv/static/app.css` via [`wisp.serve_static`](https://hexdocs.pm/wisp/wisp.html#serve_static):

```gleam
import wisp.{type Request, type Response}

pub fn handle_request(req: Request) -> Response {
  use <- wisp.serve_static(req, under: "/static", from: "priv/static")
  // ... your routes
  wisp.ok()
}
```

Reach for [glailglind](#glailglind) when you want this loop expressed as Gleam
code (so `gleam run` is your one entry point); reach for the raw binary when
you'd rather keep the build script in `make` / `just` / `npm scripts` /
whatever your team already uses.

### Alternatives to Tailwind in Gleam

If utility classes aren't a religious requirement, two Gleam-native options
sidestep the build pipeline entirely:

- **[sketch](https://hexdocs.pm/sketch/)** ([repo](https://github.com/ghivert/sketch))
  — typed CSS-in-Gleam. You write CSS as Gleam expressions; sketch resolves them
  to real stylesheets at build or runtime. Targets BEAM and JS. Pairs with Lustre
  via `sketch_lustre`. The "if you want typed styles" answer.
- **[lustre_ui](https://hexdocs.pm/lustre_ui/)** ([repo](https://github.com/lustre-labs/ui))
  — Lustre's official component + design-token library. Headless components with
  a small CSS file you include directly; no Tailwind, no class strings, no build
  step beyond what Lustre already does.

Use these *instead of* Tailwind, not alongside. Mixing utility classes with a
typed-styles library produces two sources of truth for visual design.

## Leaderboard
Every contribution is invaluable and appreciated.

Medals assigned strictly by score (ties share a medal).

**🥇 Gold** (two-way tie at **8**)
- **lustre_dev_tools** ([hayleigh-dot-dev](https://github.com/hayleigh-dot-dev)) — The blessed path for Lustre. Auto-detects Tailwind v4, downloads the binary, runs it. Zero config; you literally just write `@import "tailwindcss";`.
- **glailglind** ([okkdev](https://github.com/okkdev)) — The framework-agnostic answer. Same standalone-binary pattern, but exposed as plain Gleam modules you can call from Wisp / SSG / any build script. Honest README that points Lustre users at lustre_dev_tools instead.

**(no Silver / Bronze)** — the gap to the next tier is large; nothing in the 5–7 range deserves a medal.

| Position | Award | Repo | ★ | Lic | Compat | Maint | Age | README | Idiom | Score |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 🥇 | · [lustre-labs/dev-tools](https://github.com/lustre-labs/dev-tools)<br>· [okkdev/glailglind](https://github.com/okkdev/glailglind) | 🟩<br>🟨 | 🟩<br>🟩 | 🟩<br>🟩 | 🟩🟩<br>🟩🟩 | 🟩<br>🟩 | 🟩<br>🟩🟩 | 🟩<br>🟩 | **8** |
| 2 | | [MAHcodes/gleez](https://github.com/MAHcodes/gleez) | 🟨 | 🟩 | 🟩 | 🟨 | 🟩 | 🟩 | 🟩 | **5** |
| 3 | | · [dinkelspiel/glailwind_merge](https://github.com/dinkelspiel/glailwind_merge)<br>· [codemonkey76/lustre_transition](https://hex.pm/packages/lustre_transition) | 🟥<br>🟥 | 🟩<br>🟩 | 🟩<br>🟩 | 🟥<br>🟥 | 🟩<br>🟩 | 🟩<br>🟩 | 🟩<br>🟩 | **3** |

**Headline:** the two top tools both shell out to the same underlying binary
(`tailwindlabs/tailwindcss` standalone release). Pick by where you live —
inside Lustre's CLI (lustre_dev_tools) or outside it (glailglind / raw binary).

[How scores are calculated →](#scoring-dimensions)

## Related Work

- [Tools for building web applications with Gleam](./web-apps.md) — Lustre, Wisp, mist, the broader stack these Tailwind tools plug into.
- [Hot reloading tools for Gleam](./hot-reloading.md) — `lustre_dev_tools` reload mechanism, plus alternatives if you're rolling your own dev loop around `glailglind`.
- [HTTP clients in Gleam](./http-clients.md) — relevant if you're shipping a Wisp app that also calls APIs.
