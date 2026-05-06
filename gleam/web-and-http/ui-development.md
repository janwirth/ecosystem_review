# UI Development in Gleam

> [!NOTE]
> **Status:** DRAFT · **Authoring:** AI-assisted, human-reviewed.

You picked Gleam and [Lustre](./web-apps.md#lustre) (or [redraw](./web-apps.md#redraw)).
Now you actually have to *build a UI*. What component libraries, layout primitives,
icon sets, drag-and-drop kits, animations, and form helpers does the ecosystem
ship today?

This article is the layer above [web-apps.md](./web-apps.md). That one picks your
*frontend framework*; this one picks the things you reach for after that decision
is made.

## Table of Contents

1. [Summary](#summary)
2. [Research Method](#research-method)
   - [Scoring Dimensions](#scoring-dimensions)
   - [Discovery](#discovery)
3. [Categories](#categories)
   - [Foundation](#foundation) — [lustre](#lustre)
   - [Layout / Style Primitives](#layout--style-primitives) — [legos](#legos) · [lustre_stylish](#lustre_stylish)
   - [CSS-in-Gleam](#css-in-gleam) — [sketch](#sketch) · [monks_of_style](#monks_of_style)
   - [Design Tokens](#design-tokens) — [open_props](#open_props)
   - [Component Libraries](#component-libraries) — [lustre_ui](#lustre_ui) · [gleez](#gleez) · [glaze_basecoat](#glaze_basecoat) · [glaze_oat](#glaze_oat) · [m3e](#m3e) · [lustre_prefab](#lustre_prefab) · [glizzy](#glizzy) · [blask](#blask)
   - [Icon Sets](#icon-sets) — [lucide_lustre](#lucide_lustre) · [phosphor_lustre](#phosphor_lustre) · [gleroglero](#gleroglero)
   - [Layout / Behaviour Primitives](#layout--behaviour-primitives) — [lustre_portal](#lustre_portal) · [lustre_virtual_list](#lustre_virtual_list)
   - [Forms](#forms) — [formz_lustre](#formz_lustre)
   - [Drag and Drop](#drag-and-drop) — [dnd](#dnd) · [ensaimada](#ensaimada)
   - [Overlays / Notifications](#overlays--notifications) — [popcicle](#popcicle) · [grille_pain](#grille_pain)
   - [Motion](#motion) — [lustre_animation](#lustre_animation) · [lustre_transition](#lustre_transition)
   - [State Helpers](#state-helpers) — [optimist](#optimist)
   - [Authoring Style](#authoring-style) — [lustre_pipes](#lustre_pipes)
4. [Component libraries compared](#component-libraries-compared)
5. [Leaderboard](#leaderboard)

## Summary

Snapshot: **2026-04-26**.

The Gleam UI scene is small but unusually well-shaped. Two patterns dominate:

1. **Lustre + utility CSS** (Tailwind via [lustre_dev_tools](./tailwind.md#lustre_dev_tools), components from [gleez](#gleez), [glaze_basecoat](#glaze_basecoat) / [glaze_oat](#glaze_oat), or [gbr_ui](#disregarded)).
2. **Lustre + typed layout primitives** (Elm-UI–style: [legos](#legos) or [lustre_stylish](#lustre_stylish); or CSS-in-Gleam via [sketch](#sketch)).

Pick a track, then layer in icons, drag-and-drop, popovers, toasts, transitions
as needed.

| Category | Tools |
| --- | --- |
| **[Foundation](#foundation)** | [🥇](#leaderboard) [lustre](#lustre) ([repo](https://github.com/lustre-labs/lustre), 2.3k★) — declarative MVU, BEAM + JS |
| **[Layout / Style Primitives](#layout--style-primitives)** (Elm-UI) | [legos](#legos) ([repo](https://github.com/NduatiK/legos), 11★) · [lustre_stylish](#lustre_stylish) ([repo](https://github.com/mc706/lustre_stylish), 4★) |
| **[CSS-in-Gleam](#css-in-gleam)** | [🥈](#leaderboard) [sketch](#sketch) ([repo](https://github.com/ghivert/sketch), 81★) · [monks_of_style](#monks_of_style) ([repo](https://github.com/dusty-phillips/monks_of_style), 4★) |
| **[Design Tokens](#design-tokens)** | [open_props](#open_props) ([repo](https://github.com/dusty-phillips/open_props_gleam), 0★) |
| **[Component Libraries](#component-libraries)** | [lustre_ui](#lustre_ui) ([repo](https://github.com/lustre-labs/lustre_ui), 155★) · [gleez](#gleez) ([repo](https://github.com/MAHcodes/gleez), 61★) · [glaze_basecoat](#glaze_basecoat) ([repo](https://github.com/daniellionel01/glaze), 23★) · [glaze_oat](#glaze_oat) (same repo) · [m3e](#m3e) ([repo](https://github.com/bruceesmith/m3e), 4★) · [lustre_prefab](#lustre_prefab) ([repo](https://github.com/mc706/lustre_prefab), 0★) · [glizzy](#glizzy) ([repo](https://github.com/tantalumv/Glizzy), 0★) · [blask](#blask) ([repo](https://github.com/loipesmas/blask), 7★) |
| **[Icon Sets](#icon-sets)** | [lucide_lustre](#lucide_lustre) ([repo](https://github.com/dinkelspiel/lucide_lustre), 14★) · [phosphor_lustre](#phosphor_lustre) ([repo](https://github.com/brettkolodny/phosphor-lustre), 7★) · [gleroglero](#gleroglero) ([repo](https://github.com/skinkade/gleroglero), 5★) |
| **[Layout / Behaviour Primitives](#layout--behaviour-primitives)** | [lustre_portal](#lustre_portal) ([repo](https://github.com/lustre-labs/portal), 8★) · [lustre_virtual_list](#lustre_virtual_list) ([repo](https://github.com/schurhammer/lustre_virtual_list), 13★) |
| **[Forms](#forms)** | [formz_lustre](#formz_lustre) ([repo](https://github.com/bentomas/formz), 7★) |
| **[Drag and Drop](#drag-and-drop)** | [🥉](#leaderboard) [dnd](#dnd) ([sourcehut](https://git.sr.ht/~tpjg/dnd)) · [ensaimada](#ensaimada) ([repo](https://github.com/renatillas/ensaimada), 5★) |
| **[Overlays / Notifications](#overlays--notifications)** | [grille_pain](#grille_pain) ([repo](https://github.com/ghivert/grille-pain), 25★) · [popcicle](#popcicle) ([repo](https://github.com/dinkelspiel/popcicle), 17★) |
| **[Motion](#motion)** | [lustre_animation](#lustre_animation) ([repo](https://codeberg.org/kero/lustre_animation), 0★) · [lustre_transition](#lustre_transition) ([hex](https://hex.pm/packages/lustre_transition)) |
| **[State Helpers](#state-helpers)** | [optimist](#optimist) ([repo](https://github.com/hayleigh-dot-dev/optimist), 22★) |
| **[Authoring Style](#authoring-style)** | [lustre_pipes](#lustre_pipes) ([repo](https://github.com/weedonandscott/lustre_pipes), 8★) |

> [!IMPORTANT]
> **Two adjacent articles cover what's deliberately not duplicated here.**
> [tailwind.md](./tailwind.md) covers the Tailwind side ([lustre_dev_tools](./tailwind.md#lustre_dev_tools),
> [glailglind](./tailwind.md#glailglind), Tailwind class merging). [web-apps.md](./web-apps.md)
> covers frontend frameworks themselves ([lustre](./web-apps.md#lustre),
> [redraw](./web-apps.md#redraw)). This article focuses on what you build *with* the
> framework: layouts, components, icons, interactions.

> [!NOTE]
> **The "shadcn pattern" has three independent attempts in Gleam alone:** [gleez](#gleez)
> (Tailwind, copy/paste, ~1.7k LOC, 61★, alpha-grade), [glizzy](#glizzy) (headless,
> Base UI–inspired, 0★, just started), and [glaze_basecoat](#glaze_basecoat) (Lustre
> bindings to [Basecoat](https://basecoatui.com/), 23★, actively maintained). None
> is at production parity with React's shadcn/ui — the closest in *traction* is
> gleez, the closest in *active development* is glaze_basecoat.

> [!NOTE]
> **The "Elm-UI pattern" also has two independent ports:** [legos](#legos) (11★,
> by NduatiK) and [lustre_stylish](#lustre_stylish) (4★, by mc706, paired with the
> [lustre_prefab](#lustre_prefab) component kit). They overlap heavily —
> declarative layout primitives that generate CSS for you, no class strings.
> Different APIs; pick by feel.

> <details>
> <summary><strong>Dependency Graph</strong></summary>
>
> Arrows read "uses."
>
> **Foundation:**
> - [lustre](#lustre) — root of everything below
>
> **Style track A — utility classes (Tailwind):**
> - [gleez](#gleez), [glaze_basecoat](#glaze_basecoat), [glaze_oat](#glaze_oat), [m3e](#m3e), [gbr_ui](#disregarded) → [lustre](#lustre) + Tailwind (BYO via [lustre_dev_tools](./tailwind.md#lustre_dev_tools) or [glailglind](./tailwind.md#glailglind))
> - [lustre_transition](#lustre_transition) → [lustre](#lustre) + Tailwind classes
>
> **Style track B — typed layout primitives (Elm-UI):**
> - [legos](#legos) → [lustre](#lustre)
> - [lustre_stylish](#lustre_stylish) → [lustre](#lustre)
> - [lustre_prefab](#lustre_prefab) → [lustre_stylish](#lustre_stylish)
>
> **Style track C — CSS-in-Gleam:**
> - [sketch](#sketch) → has its own runtime (`sketch_lustre`, `sketch_redraw`, `sketch_css`)
> - [monks_of_style](#monks_of_style) → generates from CSS grammar; framework-agnostic
> - [open_props](#open_props) → constants only, layer onto any styling system
>
> **Components / primitives:**
> - [lustre_ui](#lustre_ui), [glizzy](#glizzy), [blask](#blask) → [lustre](#lustre)
> - [lustre_portal](#lustre_portal), [lustre_virtual_list](#lustre_virtual_list) → [lustre](#lustre)
>
> **Icons:**
> - [lucide_lustre](#lucide_lustre), [phosphor_lustre](#phosphor_lustre), [gleroglero](#gleroglero) → [lustre](#lustre)
>
> **Behavior / interaction:**
> - [dnd](#dnd), [ensaimada](#ensaimada), [grille_pain](#grille_pain), [popcicle](#popcicle), [lustre_animation](#lustre_animation), [optimist](#optimist), [lustre_pipes](#lustre_pipes), [formz_lustre](#formz_lustre) → [lustre](#lustre)
>
> </details>

## Research Method

### Scoring Dimensions

Same rubric as [web-apps.md](./web-apps.md#scoring-dimensions). Recap:

- **Stars:** Community adoption signal based on star count. 🟩🟩 = ≥200★, 🟩 = ≥100★, 🟨 = ≥10★, 🟥 = <10★. *Example: 165★ → 🟩; 3★ → 🟥.*
- **License:** Whether the license allows unrestricted commercial use. 🟩 = permissive OSS (MIT, Apache-2.0, BSD). 🟥 = viral (GPL, AGPL) or no license. Only one tier — permissive or not.
- **Gleam compat:** Checks `gleam_stdlib` version constraint format in `gleam.toml` `[dependencies]`. 🟩 = range constraint (`>= X and < Y`), 🟥 = non-range constraint (`~>` style) which can cause resolver conflicts during install. *Example: `"~> 0.34 or ~> 1.0"` → 🟥; `">= 0.44.0 and < 2.0.0"` → 🟩.*
- **Maintenance:** Two-level scoring that prioritizes proactive development. Final score = **max(recency, responsiveness)**. **Level 1 — Recency:** last commit relative to snapshot. 🟩🟩 = <1 month, 🟩 = <6 months, 🟨 = <1 year, 🟥 = >1 year. **Level 2 — Responsiveness:** time for repo owner to reply to issues or update PRs (owner comment = ball in opener's court, counts as handled). 🟩🟩 = <2 days, 🟩 = <1 week, 🟨 = <1 month, 🟥 = >1 month or ignored. Clean tracker (0 open PRs/issues) = 🟩🟩. The better of the two wins.
- **Age:** Time from first visible commit to snapshot date. Older projects have more time to stabilize. 🟩🟩 = ≥3 years, 🟩 = ≥1 year, 🟨 = ≥3 months, 🟥 = <3 months.
- **README maturity:** Quality of documentation in the repo README. 🟩🟩 = guide-style with examples, full feature docs, and getting-started instructions. 🟩 = clear description and basic usage. 🟥 = minimal, broken, or missing.
- **Idiomaticity:** Whether the project follows Gleam's principles: typed, sound, explicit, no magic. 🟩 = idiomatic (explicit APIs, explicit codegen steps, builder patterns). 🟥 = magic directives, implicit behavior, or template languages that extract code from non-Gleam sources.

**Leaderboard scoring:** 🟥 = −1, 🟨 = 0, 🟩 = 1, 🟩🟩 = 2. Sum of all 7 dimensions. Max possible = 13.

### Discovery

Searches run on the [Gleam packages registry](https://packages.gleam.run/) for
`ui`, `component`, `lustre`, `tailwind`, `css`, `style`, `design`, `icon`, `form`,
`animation`, `headless`, `lego`, `legos`, plus the [awesome-gleam](https://github.com/gleam-lang/awesome-gleam)
list. Repos verified one-by-one against live GitHub / Codeberg / sourcehut /
Hex pages.

**~30 packages surveyed — 25 included** (below), **6 disregarded** (collapsible
section after the leaderboard).

> [!NOTE]
> **About "glailglind":** the package exists (`okkdev/glailglind`, 49★, a
> Tailwind CLI wrapper), but it's a *build-pipeline* tool, not a UI dev library.
> It's covered in [tailwind.md](./tailwind.md#glailglind) and cross-linked from
> the dependency graph above. Not duplicated here.

## Categories

### Foundation

The framework everything else here is built on.

| Criterion | [lustre](https://github.com/lustre-labs/lustre) [🥇](#leaderboard) |
| --- | --- |
| Stars | 2.3k★ · 🟩🟩 |
| License | MIT · 🟩 |
| Target | ☎️📜 Both (BEAM + JS) |
| Deps | 5 |
| Gleam compat | `>= 0.60 and < 2.0` · 🟩 |
| Maintenance | 🟩🟩 (last commit 2026-04-18) |
| Age | ~4.2 years (Feb 2022) · 🟩🟩 |
| README maturity | 🟩🟩 (guide + examples + ecosystem) |
| Idiomaticity | 🟩 |

#### lustre
[repo](https://github.com/lustre-labs/lustre) · [hexdocs](https://hexdocs.pm/lustre/) · [🥇](#leaderboard)

The Elm-style MVU framework that anchors the Gleam UI ecosystem. Declarative
HTML, `init`/`update`/`view` triple, universal components (same Gleam runs on
BEAM and JS), SSR, server components. Already covered in detail in
[web-apps.md](./web-apps.md#lustre); listed here because every package below
either depends on it or targets it.

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

### Layout / Style Primitives

The Elm-UI school: declarative layout functions (`row`, `column`, `el`) that
generate CSS for you. No class strings, no Tailwind, no stylesheets.

| Criterion | [legos](https://github.com/NduatiK/legos) | [lustre_stylish](https://github.com/mc706/lustre_stylish) |
| --- | --- | --- |
| Stars | 11★ · 🟨 | 4★ · 🟥 |
| License | BSD-3-Clause (`gleam.toml` / hex) · 🟩 | MIT · 🟩 |
| Target | 📜 JS (Lustre) | 📜 JS (Lustre) |
| Deps | 4 | minimal (zero-dep design) |
| Gleam compat | `>= 0.44 and < 2.0` · 🟩 | (range; published 2026-01) · 🟩 |
| Maintenance | 🟩 (last commit 2025-10-01) | 🟩🟩 (last commit 2026-01-17, 0 issues) |
| Age | ~8 months (Aug 2025) · 🟨 | ~3 months (Jan 2026) · 🟨 |
| README maturity | 🟩 (tagline + working example) | 🟩 (philosophy + module map) |
| Idiomaticity | 🟩 | 🟩 |

#### legos
[repo](https://github.com/NduatiK/legos) · [hexdocs](https://hexdocs.pm/legos/)

"Layout and style that's easy to refactor, all without thinking about CSS." A
direct Lustre adaptation of Elm-UI: build views by composing typed layout +
style attributes, the library generates the CSS. Modules: `ui` (layout),
`background`, `border`, `color`, `font`, `input`, `events`, `keyed`, `region`.

```gleam
import legos/ui
import legos/background
import legos/border
import legos/color
import legos/font

ui.el(
  [
    background.color(color.blue_500()),
    font.color(color.white()),
    border.rounded(3),
    ui.padding(30),
  ],
  ui.text("stylish!")
)
```

#### lustre_stylish
[repo](https://github.com/mc706/lustre_stylish) · [hexdocs](https://hexdocs.pm/lustre_stylish/)

The other Elm-UI port. The README explicitly frames it as "elm-ui's proven
philosophy" applied to Lustre, with 130+ functions across 8 modules (layout,
typography, borders, backgrounds, events, accessibility, form inputs). Zero
runtime dependencies; styles compile to inline CSS via Lustre attributes. Pairs
with [lustre_prefab](#lustre_prefab) for pre-built components.

Two parallel ports of the same idea (`legos` and `lustre_stylish`) is a small
duplication tax. They diverge on API surface (legos models the Elm-UI primitive
set closely; lustre_stylish layers more typography + a11y helpers).

### CSS-in-Gleam

The "write CSS as Gleam expressions" school. Type-safe styles, but you still
think in CSS — just typed.

| Criterion | [sketch](https://github.com/ghivert/sketch) [🥈](#leaderboard) | [monks_of_style](https://github.com/dusty-phillips/monks_of_style) |
| --- | --- | --- |
| Stars | 81★ · 🟨 | 4★ · 🟥 |
| License | MIT · 🟩 | (license commit present, file unverified) · 🟩 |
| Target | ☎️📜 Both (separate runtime per target) | 📜 JS (codegen) |
| Deps | 5 (`murmur3a`, `gleam_erlang`, `gleam_otp`, `gleam_stdlib`, `gleeunit`) | 0 (codegen-only) |
| Gleam compat | `>= 0.60 and < 2.0` · 🟩 | 🟩 (codegen package) |
| Maintenance | 🟩🟩 (last commit 2026-04-22) | 🟩🟩 (last commit 2025-11-30, fresh) |
| Age | ~1 year+ (history visible from May 2025; older releases on hex) · 🟩 | ~5 months (Nov 2025) · 🟨 |
| README maturity | 🟩 (concept + monorepo map) | 🟩 (tagline + concept) |
| Idiomaticity | 🟩 | 🟩 (explicit codegen) |

#### sketch
[repo](https://github.com/ghivert/sketch) · [hexdocs](https://hexdocs.pm/sketch/) · [🥈](#leaderboard)

"A CSS-in-Gleam package, made to work with frontend, backend, with your favorite
framework!" The most-adopted typed-styles approach in the ecosystem. The core
package defines the CSS DSL; runtime adapters live in companion packages
(`sketch_lustre`, `sketch_redraw`, `sketch_css` — that last one extracts CSS at
build time, no runtime). 263 commits, ~80k lifetime downloads, single-author
shop (ghivert) but very active.

```gleam
import sketch
import sketch/lustre as sl
import sketch/lustre/element/html

fn button() {
  sl.element(html.button, [
    sketch.background("hotpink"),
    sketch.color("white"),
    sketch.padding_("16px 32px"),
    sketch.border_radius_("8px"),
  ], [], [html.text([], "click")])
}
```

#### monks_of_style
[repo](https://github.com/dusty-phillips/monks_of_style) · [hexdocs](https://hexdocs.pm/monks_of_style/)

"Type safe CSS-in-gleam using generated code." Distinct approach from sketch:
parses the actual `css-tree` CSS grammar and emits typed Gleam constructors for
properties and values. The pitch is that the type system reflects real CSS,
not a curated subset. Very young (4 months, 11 commits) but the codegen-from-
grammar approach is unique.

### Design Tokens

Constants for the design-system numbers (colors, sizes, shadows, easings) so
you stop hardcoding magic strings.

| Criterion | [open_props](https://github.com/dusty-phillips/open_props_gleam) |
| --- | --- |
| Stars | 0★ · 🟥 |
| License | (LICENSE in repo) · 🟩 |
| Target | ☎️📜 Either (constants only) |
| Deps | 0 |
| Gleam compat | range · 🟩 |
| Maintenance | 🟩🟩 (last commit 2026-02-04) |
| Age | ~5 months (Nov 2025) · 🟨 |
| README maturity | 🟩 (tagline + monorepo map) |
| Idiomaticity | 🟩 (explicit codegen from open-props sources) |

#### open_props
[repo](https://github.com/dusty-phillips/open_props_gleam) · [hexdocs](https://hexdocs.pm/open_props/)

"Open-props design token system in Gleam." Generates Gleam constants for the
[open-props](https://open-props.style/) CSS variable set — colors, sizes,
shadows, gradients, animations — so you reference `colors.blue_5` instead of
writing `"var(--blue-5)"`. Layers cleanly on top of any styling approach
(Tailwind, sketch, raw class strings). Very fresh, very low traction, but the
underlying open-props itself has 5.4k stars and is well-known.

### Component Libraries

Pre-built UI components: buttons, dialogs, dropdowns, inputs. Different
philosophies (utility-class kits, headless behaviour-only kits, full design
systems).

| Criterion | [lustre_ui](https://github.com/lustre-labs/lustre_ui) | [gleez](https://github.com/MAHcodes/gleez) | [glaze_basecoat](https://github.com/daniellionel01/glaze) | [m3e](https://github.com/bruceesmith/m3e) | [glizzy](https://github.com/tantalumv/Glizzy) | [blask](https://github.com/loipesmas/blask) | [lustre_prefab](https://github.com/mc706/lustre_prefab) |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Stars | 155★ · 🟩 | 61★ · 🟨 | 23★ · 🟨 | 4★ · 🟥 | 0★ · 🟥 | 7★ · 🟥 | 0★ · 🟥 |
| License | MIT · 🟩 | MIT · 🟩 | Apache-2.0 · 🟩 | MIT · 🟩 | MIT · 🟩 | MIT · 🟩 | MIT · 🟩 |
| Target | 📜 JS | ☎️📜 (CLI BEAM, components Lustre) | 📜 JS | 📜 JS | 📜 JS | 📜 JS | 📜 JS |
| Gleam compat | `>= 0.40 and < 2.0` · 🟩 | `>= 0.34 and < 2.0` · 🟩 | range · 🟩 | range · 🟩 | range · 🟩 | range · 🟩 | range · 🟩 |
| Maintenance | 🟥 (last commit 2024-12-08, ~16 mo before snapshot; 4 issues) | 🟨 (last commit 2025-06-04, ~10.5 mo) | 🟩🟩 (last commit 2026-03-25, ~1 mo; 2 issues) | 🟩🟩 (last commit 2026-04-26, snapshot day; 0 issues) | 🟥 (last commit 2026-03-01, ~2 mo; 5 commits total) | 🟥 (last commit 2024-11-24, ~17 mo) | 🟥 (single commit, 1 total; 0 issues) |
| Age | ~1.6 years (Oct 2024) · 🟩 | ~2 years (May 2024) · 🟩 | ~2 months (Feb 2026) · 🟥 | ~20 days (Apr 2026) · 🟥 | ~2 months (Feb 2026) · 🟥 | ~9 months (Jul 2024) · 🟨 | <1 month · 🟥 |
| README maturity | 🟩 (philosophy + install) | 🟩 (concept + colors + theme setup) | 🟩 (binding + roadmap) | 🟩🟩 (component list, builder + config patterns, screenshots, roadmap) | 🟩 (concept + theming + a11y notes; alpha) | 🟩 (showcase link, component list) | 🟩 (philosophy, module list) |
| Idiomaticity | 🟩 (typed components, design tokens) | 🟩 (typed `Color` enum) | 🟩 (typed bindings) | 🟩 (builder + config-record dual API) | 🟩 (typed components) | 🟩 (typed components) | 🟩 (typed components) |
| | | | | | | | |
| **Approach** | | | | | | | |
| Style of components | "Opinionated" design system | shadcn-style copy/paste | Bindings to [Basecoat](https://basecoatui.com/) | Bindings to [M3E](https://m3e.duckdns.org/) (Material 3 Expressive web components) | shadcn / Base UI inspired headless | Pre-styled built-in | Inspired by Clarity Design |
| Styling system | Custom CSS + design tokens | Tailwind + 7 named CSS vars | Basecoat (Tailwind-based) | Material 3 web components (CSS lives in M3E) | Headless (you style) | Custom CSS | Built on [lustre_stylish](#lustre_stylish) (no CSS) |
| External CSS dep? | No | Yes (Tailwind) | Yes (Basecoat CSS) | Yes (M3E `<m3e-*>` web components) | No (headless) | No | No |
| Distribution | Hex package | Hex + CLI copy/paste | Hex package | Hex package | Hex package | Hex package | Hex package |

See [Component libraries compared](#component-libraries-compared) below for a
fuller side-by-side.

#### lustre_ui
[repo](https://github.com/lustre-labs/lustre_ui) · [hexdocs](https://hexdocs.pm/lustre_ui/)

"A collection of components and design tokens for building Lustre apps." The
*official* Lustre component library by hayleigh-dot-dev (Lustre's author).
Opinionated design philosophy (their words): a curated set of components with
cohesive design tokens, no Tailwind, no class strings. The catch: last commit
December 2024 — ~16 months stale at snapshot. Still on `1.0.0-rc.1` on hex. The
README is honest about the situation ("solo development alongside other work").
Use it if the design fits and you're willing to ride out the lull, or vendor
the source.

#### gleez
[repo](https://github.com/MAHcodes/gleez) · [hexdocs](https://hexdocs.pm/gleez/) · [demo](https://gleez.netlify.app/)

shadcn for Lustre. Distributed via a CLI (`gleez`) that copies component source
into your project — the README explicitly says *"This is NOT a component
library. It's a collection of re-usable components that you can copy and paste
into your apps."* Requires Tailwind + 7 named CSS variables (`--neutral`,
`--primary`, `--secondary`, `--success`, `--info`, `--warning`, `--danger`)
defined as HSL triples. Components take a typed `Color` enum so call sites stay
typed. Same package was already covered (briefly) in
[tailwind.md → Component Kits](./tailwind.md#component-kits) — that lens is
"Tailwind tooling"; this lens is "you've picked Lustre, now pick a kit."

#### glaze_basecoat
[repo](https://github.com/daniellionel01/glaze) · [hexdocs](https://hexdocs.pm/glaze_basecoat/)

Lustre bindings to [Basecoat UI](https://basecoatui.com/) — a framework-agnostic
Tailwind-based UI library. The Gleam side is just a thin typed wrapper around
Basecoat's component classes; styling lives in Basecoat's CSS. This means you
get someone else's design-system maintenance for free, and the Gleam side stays
small. Same monorepo also publishes [`glaze_oat`](#glaze_oat).

#### glaze_oat
[repo](https://github.com/daniellionel01/glaze) · [hexdocs](https://hexdocs.pm/glaze_oat/)

Same pattern as glaze_basecoat but bound to [Oat UI](https://oat-ui.dev/)
instead. Both ship from the same `daniellionel01/glaze` monorepo, both updated
in 2026-03 (~1 month stale at snapshot), both Apache-2.0. Pick by which
underlying CSS library you prefer.

#### m3e
[repo](https://github.com/bruceesmith/m3e) · [hexdocs](https://hexdocs.pm/m3e/)

"Gleam/Lustre wrappers for [M3E](https://m3e.duckdns.org/) — Material 3
Expressive components." M3E is a set of web components implementing Google's
Material 3 design system; m3e wraps them as typed Lustre attributes/elements.
Very young (~3 weeks at snapshot, 453 commits, last commit on the same day as
snapshot — so the volume is in active churn rather than maturity). Two API
styles offered: builder pattern and config record. Watch this one — the
underlying M3E project is well-resourced.

#### glizzy
[repo](https://github.com/tantalumv/Glizzy) · [hexdocs](https://hexdocs.pm/glizzy/)

"A headless UI component library for Gleam and Lustre, inspired by Base UI and
Shadcn." Alpha (5 commits, 0 stars, ~2 months old, JS-only). Headless = you
get behaviour + accessibility, you bring the styles. The Base UI inspiration is
notable — Base UI is the library Material UI extracted its accessible
primitives into. Worth tracking.

#### blask
[repo](https://github.com/loipesmas/blask) · [hexdocs](https://hexdocs.pm/blask/)

"A UI component library for Lustre." Provides selects, accordions, tabs, inputs,
buttons — both styled and unstyled. 7★, 54 commits. Last commit November 2024,
so ~17 months stale at snapshot. Live showcase exists, but the maintenance
gap puts it in "vendor at your own risk" territory.

#### lustre_prefab
[repo](https://github.com/mc706/lustre_prefab) · [hexdocs](https://hexdocs.pm/lustre_prefab/)

Pre-fabricated components built on [lustre_stylish](#lustre_stylish), inspired
by VMware's [Clarity Design System](https://clarity.design/). Single commit at
snapshot, 0★, 0 issues — it's a sketch of an idea more than a shipped library.
Listed because the *combination* (Elm-UI primitives + Clarity-style components)
is unique in this ecosystem.

### Icon Sets

Drop-in SVG icon packages. All three follow the same pattern: one Gleam
function per icon, attribute-based sizing/colour.

| Criterion | [lucide_lustre](https://github.com/dinkelspiel/lucide_lustre) | [phosphor_lustre](https://github.com/brettkolodny/phosphor-lustre) | [gleroglero](https://github.com/skinkade/gleroglero) |
| --- | --- | --- | --- |
| Stars | 14★ · 🟨 | 7★ · 🟥 | 5★ · 🟥 |
| License | MIT · 🟩 | Apache-2.0 (hex) · 🟩 | Apache-2.0 · 🟩 |
| Target | 📜 JS | 📜 JS | 📜 JS |
| Deps | 2 (lustre + stdlib) | 2 (lustre + stdlib) | 2 (lustre + stdlib) |
| Gleam compat | `>= 0.34 and < 2.0` · 🟩 | range · 🟩 | `>= 0.34 and < 2.0` · 🟩 |
| Maintenance | 🟩🟩 (last commit 2025-12-28, ~4 mo; 0 issues) | 🟩 (last commit 2025-12-16, ~4 mo; 0 issues) | 🟨 (last commit 2025-05-21, ~11 mo; 1 issue) |
| Age | ~1.5 years (Oct 2024) · 🟩 | ~1.7 years (Aug 2024) · 🟩 | ~1.8 years (Jul 2024) · 🟩 |
| README maturity | 🟩 (selective install via CLI; output module config) | 🟩 (builder pattern, advice on copying subset) | 🟩 (variants list, install) |
| Idiomaticity | 🟩 | 🟩 | 🟩 |
| | | | |
| **Coverage** | | | |
| Underlying icon set | [lucide.dev](https://lucide.dev/) (~1500 icons) | [Phosphor Icons](https://phosphor.icons.com/) (~1200 icons × 6 weights) | [Heroicons](https://heroicons.com/) (~300 icons × 4 styles) |
| Variants | One module per icon set | weight modifiers per icon (`heart`, `heart_bold`, etc.) | `micro` / `mini` / `outline` / `solid` |
| Selective install | ✅ CLI to copy only icons you use | "copy paste just the ones you need" recommended in README | Whole package |

#### lucide_lustre
[repo](https://github.com/dinkelspiel/lucide_lustre) · [hexdocs](https://hexdocs.pm/lucide_lustre/)

Lucide icons (the lucide.dev fork of the original Feather icon set). Most
recent of the three icon packs (last commit 2025-12), ships a CLI for selective
install — important because Lucide has ~1500 icons and you don't want all of
them in your bundle.

#### phosphor_lustre
[repo](https://github.com/brettkolodny/phosphor-lustre) · [hexdocs](https://hexdocs.pm/phosphor_lustre/)

Phosphor icons. Builder-pattern API per icon (size + weight + color modifiers
on a single function). README explicitly suggests copy-pasting just the icons
you need — Phosphor is one of the largest icon sets (~1200 × 6 weights = ~7200
distinct SVGs).

```gleam
import phosphor

html.div([], [phosphor.heart_bold([])])
```

#### gleroglero
[repo](https://github.com/skinkade/gleroglero) · [hexdocs](https://hexdocs.pm/gleroglero/)

Heroicons (Tailwind's icon set) ported to Lustre. Four variant modules:
`micro`, `mini`, `outline`, `solid`. Smallest icon set of the three; oldest
last-commit (May 2025); last update was for Lustre 5.x compatibility.

### Layout / Behaviour Primitives

Single-purpose UI primitives that don't fit a "component library" but are
essential when you need them.

| Criterion | [lustre_portal](https://github.com/lustre-labs/portal) | [lustre_virtual_list](https://github.com/schurhammer/lustre_virtual_list) |
| --- | --- | --- |
| Stars | 8★ · 🟥 | 13★ · 🟨 |
| License | MIT · 🟩 | Apache-2.0 · 🟩 |
| Target | 📜 JS | 📜 JS |
| Deps | 2 (lustre + plinth) | 2 (lustre + stdlib) |
| Gleam compat | `>= 0.44 and < 2.0` · 🟩 | range · 🟩 |
| Maintenance | 🟩 (last commit 2025-11-10, ~5.5 mo; 0 issues) | 🟥 (last commit 2024-10-28, ~18 mo; 0 issues) |
| Age | ~10 months (Jun 2025) · 🟩 | ~1.5 years (Oct 2023) · 🟩 |
| README maturity | 🟩 (CSS selector targeting, shadow DOM, iframes, standalone bundle) | 🟩 (registration + height/count config, tagline + usage) |
| Idiomaticity | 🟩 | 🟩 |

#### lustre_portal
[repo](https://github.com/lustre-labs/portal) · [hexdocs](https://hexdocs.pm/lustre_portal/)

Web component that "teleports" Lustre-rendered content into DOM nodes outside
the framework's controlled tree. CSS selectors as targets; supports shadow DOM
and iframes. Ships a standalone bundle for non-Lustre HTML pages. Maintained
by hayleigh-dot-dev + yoshi-monster (Lustre core) — official-adjacent.

#### lustre_virtual_list
[repo](https://github.com/schurhammer/lustre_virtual_list) · [hexdocs](https://hexdocs.pm/lustre_virtual_list/)

"Virtual list component for rendering very large lists without performance
problems." Renders only the on-screen subset; you specify item height + render
count. 18 commits, no activity in 18 months, but the API is small enough that
"unmaintained" doesn't necessarily mean "broken" — works against current Lustre
per the latest README update.

### Forms

| Criterion | [formz_lustre](https://hexdocs.pm/formz_lustre/) |
| --- | --- |
| Stars | 7★ (parent `bentomas/formz` repo) · 🟥 |
| License | (parent repo licensed; hex metadata required) · 🟩 |
| Target | ☎️📜 Both (paired with `formz` core) |
| Deps | builds on `formz` |
| Gleam compat | range · 🟩 |
| Maintenance | 🟨 (parent repo 59 commits, project relocated to `tangled.org/@bthom.tngl.sh/formz`) |
| Age | ~1 year+ · 🟩 |
| README maturity | 🟩 (modules: definition, generator, widget) |
| Idiomaticity | 🟩 |

#### formz_lustre
[repo](https://github.com/bentomas/formz) · [hexdocs](https://hexdocs.pm/formz_lustre/)

Lustre widgets and field definitions for the [formz](https://hexdocs.pm/formz/)
form library. formz itself ("accessible, type-safe form parsing and generating
for Gleam") is the parent project — formz_lustre adds typed render widgets so
your form fields stay in sync with your Lustre view. Project is migrating from
GitHub to tangled.sh (a sourcehut-style git host) — README on GitHub points to
the new home.

### Drag and Drop

Two independent attempts; different APIs, different scope.

| Criterion | [dnd](https://git.sr.ht/~tpjg/dnd) [🥉](#leaderboard) | [ensaimada](https://github.com/renatillas/ensaimada) |
| --- | --- | --- |
| Stars | (sourcehut, no stars displayed) · 🟥 | 5★ · 🟥 |
| License | BSD-3-Clause · 🟩 | MIT · 🟩 |
| Target | 📜 JS | 📜 JS |
| Deps | 3 | minimal |
| Gleam compat | range · 🟩 | range · 🟩 |
| Maintenance | 🟩🟩 (last hex release 2025-12-10, ~4.5 mo) | 🟩 (11 commits, 0 issues; published as v2.0.0) |
| Age | range · 🟩 | range · 🟩 |
| README maturity | 🟩🟩 (port of [`elm/dnd-list`](https://github.com/annaghi/dnd-list); operations, listen modes, constraints, ghost elements, group transfers) | 🟩 (HTML5 drag-and-drop + touch, multi-container) |
| Idiomaticity | 🟩 | 🟩 |
| | | |
| **Scope** | | |
| Sortable lists | ✅ | ✅ |
| Cross-list transfer | ✅ (groups) | ✅ |
| Mobile / touch | ✅ (hold-to-select) | ✅ (touch events) |
| Free / horizontal / vertical movement | ✅ | (HTML5 default) |
| Custom ghost element | ✅ | (HTML5 default) |

#### dnd
[sourcehut](https://git.sr.ht/~tpjg/dnd) · [hex](https://hex.pm/packages/dnd) · [hexdocs](https://hexdocs.pm/dnd/) · [🥉](#leaderboard)

Direct Gleam port of [Anna Ghi's `dnd-list`](https://github.com/annaghi/dnd-list)
from Elm. Two modules: `dnd` (basic) and `dnd/groups` (transfer between
containers). Configurable operations (insert/rotate/swap), movement constraints,
custom ghost elements. The most thorough drag-and-drop library in the Gleam
ecosystem.

> [!NOTE]
> Hosted on sourcehut. Star count not directly comparable to GitHub repos —
> scored 🟥 by the rubric, but consider this an artifact of the host rather
> than a quality signal.

#### ensaimada
[repo](https://github.com/renatillas/ensaimada) · [hexdocs](https://hexdocs.pm/ensaimada/)

Sortable list with HTML5 drag-and-drop + touch events. Smaller scope than dnd
(no insert/rotate/swap operation modes, no custom ghost) but simpler API.
Same author as `arctic` and several other Gleam packages — well-shipped track
record across the ecosystem.

### Overlays / Notifications

| Criterion | [grille_pain](https://github.com/ghivert/grille-pain) | [popcicle](https://github.com/dinkelspiel/popcicle) |
| --- | --- | --- |
| Stars | 25★ · 🟨 | 17★ · 🟨 |
| License | MIT · 🟩 | Apache-2.0 · 🟩 |
| Target | 📜 JS | 📜 JS |
| Deps | 2 (lustre + stdlib) | 3 (lustre + plinth + stdlib) |
| Gleam compat | `>= 0.60 and < 2.0` · 🟩 | `>= 0.34 and < 2.0` · 🟩 |
| Maintenance | 🟩🟩 (last commit 2025-12-24, ~4 mo; hex release 2026-04-22, ~4 days; 0 issues) | 🟩 (last commit 2025-01-11, ~15 mo; 1 issue) |
| Age | ~1+ year (57 commits) · 🟩 | ~1.3 years (Jan 2025) · 🟩 |
| README maturity | 🟩🟩 (severity levels, sticky toasts, CSS variables, Shadow DOM isolation) | 🟩🟩 (positioning, click/hover triggers, shadcn-inspired styles, demo site) |
| Idiomaticity | 🟩 | 🟩 |

#### grille_pain
[repo](https://github.com/ghivert/grille-pain) · [hexdocs](https://hexdocs.pm/grille_pain/)

"Toaster, made in lustre, for gleam." Inspired by react-toastify. Severity
levels (info / warning / error / success / standard), sticky toasts with manual
dismiss, CSS variables for styling, Shadow DOM isolation so app styles don't
bleed into toasts. Same author as [sketch](#sketch) — ghivert ships a lot of
the underrated quality in this ecosystem.

#### popcicle
[repo](https://github.com/dinkelspiel/popcicle) · [hexdocs](https://hexdocs.pm/popcicle/) · [demo](https://popcicle.keii.dev/)

"Simple to use, styleable popovers for Lustre." Configurable positioning
(e.g. `UnderCenter`), click or hover triggers, unstyled by default with optional
shadcn-inspired style examples. Same author as [lucide_lustre](#lucide_lustre).

### Motion

| Criterion | [lustre_animation](https://codeberg.org/kero/lustre_animation) | [lustre_transition](https://hex.pm/packages/lustre_transition) |
| --- | --- | --- |
| Stars | 0★ (Codeberg) · 🟥 | ⬜ (GitHub repo `codemonkey76/lustre_transition` returns 404) · 🟥 |
| License | MIT · 🟩 | MIT · 🟩 |
| Target | 📜 JS | 📜 JS |
| Deps | 3 | 2 |
| Gleam compat | range · 🟩 | `>= 0.34 and < 2.0` · 🟩 |
| Maintenance | 🟩 (last commit 2025-06-04, ~10.5 mo; hex 2025-04-26, ~12 mo) | 🟥 (last hex release 2024-06-24, ~22 mo; GH repo missing) |
| Age | ~1+ year · 🟩 | ~1.8 years · 🟩 |
| README maturity | 🟩 (workflow, examples folder) | 🟩 (tagline + Tailwind use note) |
| Idiomaticity | 🟩 | 🟩 |

#### lustre_animation
[codeberg](https://codeberg.org/kero/lustre_animation) · [hexdocs](https://hexdocs.pm/lustre_animation/)

"Animations for lustre, utilizing JS requestAnimationFrame and setTimeout."
Maintain an `Animations` value, add animations via triggers, dispatch
`animation.effect()` on each frame until completion. Hosted on Codeberg —
star count is not directly comparable to GitHub.

#### lustre_transition
[hex](https://hex.pm/packages/lustre_transition) · [hexdocs](https://hexdocs.pm/lustre_transition/)

Enter/leave transition state machine for Lustre views. Toggles Tailwind
transition classes (`enter`, `enter-from`, `enter-to`, `leave`, `leave-from`,
`leave-to`) in sequence. Already covered in
[tailwind.md → Class Utilities](./tailwind.md#class-utilities); included in this
table for completeness when comparing animation options. Same caveat: GitHub
repo 404s, only hex + hexdocs remain.

### State Helpers

Patterns layered on top of Lustre's MVU loop.

| Criterion | [optimist](https://github.com/hayleigh-dot-dev/optimist) |
| --- | --- |
| Stars | 22★ · 🟨 |
| License | MIT · 🟩 |
| Target | ☎️📜 Either |
| Deps | 1 (`gleam_stdlib`) |
| Gleam compat | `>= 0.34 and < 2.0` · 🟩 |
| Maintenance | 🟩 (last commit 2025-08-16, ~8 mo; 0 issues) |
| Age | ~1.4 years (Nov 2024) · 🟩 |
| README maturity | 🟩 (`Optimistic` type + `push`/`update`/`resolve`/`revert` API) |
| Idiomaticity | 🟩 |

#### optimist
[repo](https://github.com/hayleigh-dot-dev/optimist) · [hexdocs](https://hexdocs.pm/optimist/)

"A simple package for modelling optimistic ui updates." Provides an
`Optimistic` type and `push` / `update` / `resolve` / `revert` operations so
you can render expected values immediately and reconcile against the server
later. Single-author shop (hayleigh) but the surface is small enough that the
~8-month gap to last commit isn't worrying.

### Authoring Style

Optional sugar over Lustre's view-function syntax.

| Criterion | [lustre_pipes](https://github.com/weedonandscott/lustre_pipes) |
| --- | --- |
| Stars | 8★ · 🟥 |
| License | MIT · 🟩 |
| Target | ☎️📜 Either |
| Deps | (lustre, stdlib) |
| Gleam compat | range · 🟩 |
| Maintenance | 🟩 (last hex release 2025-05-09, ~12 mo; 11 commits; 0 issues) |
| Age | ~1+ year · 🟩 |
| README maturity | 🟩 (pipe-syntax example, perf caveat) |
| Idiomaticity | 🟩 |

#### lustre_pipes
[repo](https://github.com/weedonandscott/lustre_pipes) · [hexdocs](https://hexdocs.pm/lustre_pipes/)

"Lets you write views with pipes." Reshapes Lustre's `html.div([attrs], [children])`
into a `|>`-chain so views read top-down. The README is honest about the
tradeoff: *"It's definitely less performant but I have not benchmarked if
significant or not."* Niche — included because it's the only alternative
authoring style in the ecosystem.

```gleam
// Standard Lustre
html.div([attribute.class("card")], [
  html.h2([], [html.text("Title")]),
  html.p([], [html.text("Body")]),
])

// With lustre_pipes
pipes.div() |> pipes.class("card") |> pipes.children([
  pipes.h2() |> pipes.text("Title"),
  pipes.p() |> pipes.text("Body"),
])
```

## Component libraries compared

The "I want pre-built components" question has more answers than any other in
the Gleam UI space. They split along two axes: *who owns the styles* and *how
opinionated the design system is*.

| | [lustre_ui](#lustre_ui) | [gleez](#gleez) | [glaze_basecoat](#glaze_basecoat) | [m3e](#m3e) | [glizzy](#glizzy) | [blask](#blask) |
| --- | --- | --- | --- | --- | --- | --- |
| **Approach** | Curated design system | shadcn copy/paste | Bindings to external CSS lib | Bindings to web components | Headless | Pre-styled |
| **Style ownership** | The library | You (with required vars) | [Basecoat](https://basecoatui.com/) | [M3E](https://m3e.duckdns.org/) | You | The library |
| **Tailwind required?** | No | Yes | Yes (Basecoat is Tailwind-based) | No | No | No |
| **Design system** | Custom | shadcn-derived | Basecoat | Material 3 Expressive | None (you bring) | Custom |
| **Distribution** | Hex package | CLI copies source | Hex package | Hex package | Hex package | Hex package |
| **Stars** | 155★ | 61★ | 23★ | 4★ | 0★ | 7★ |
| **Last commit (mo before snapshot)** | ~16 | ~10.5 | ~1 | <1 | ~2 | ~17 |
| **Production-ready?** | Frozen at rc.1 | Alpha-grade, gleez calls itself "NOT a component library" | Active, very young | Active, very young | Alpha (5 commits) | Stale (~17 mo) |
| **Best when** | You want hayleigh's design choices and can wait for v1 | You want shadcn's API + Tailwind, willing to vendor source | You want a maintained design system without owning it | You're shipping Material 3 specifically | You want behaviour + a11y, you do all styling | (Hard to recommend at snapshot) |

### How to pick

- **You want it to look like Material 3?** → [m3e](#m3e). Watch the maturity though — it's <1 month old.
- **You want shadcn's "copy the source into your repo" workflow?** → [gleez](#gleez). Accept that you're vendoring an alpha-grade library.
- **You want a maintained design system without owning the styles?** → [glaze_basecoat](#glaze_basecoat) or [glaze_oat](#glaze_oat) — the upstream CSS lib carries the maintenance.
- **You want headless behaviour primitives and you do all styling?** → [glizzy](#glizzy) (alpha) or roll your own with [lustre_portal](#lustre_portal) + [popcicle](#popcicle) + [grille_pain](#grille_pain).
- **You want lustre's official answer and you can ride out the lull?** → [lustre_ui](#lustre_ui). It's frozen at rc.1 but the design philosophy is clear.
- **You want zero CSS files, period?** → [legos](#legos) or [lustre_stylish](#lustre_stylish) (Elm-UI primitives) + [lustre_prefab](#lustre_prefab) (the prefab kit on top).

These are not mutually exclusive — the icon and primitive libraries
([lucide_lustre](#lucide_lustre), [lustre_portal](#lustre_portal),
[grille_pain](#grille_pain), etc.) layer on top of any of these choices.

## Leaderboard
Every contribution is invaluable and appreciated.

This ranking
- helps authors check if the metrics are sane at a glance
- uncovers gems unique to the Gleam ecosystem
- cherishes key contributors

**🥇 Gold**
- **lustre** ([hayleigh-dot-dev](https://github.com/hayleigh-dot-dev), [yoshi-monster](https://github.com/yoshi-monster)) — The framework that makes the entire UI conversation possible. Already gold in [web-apps.md](./web-apps.md#leaderboard); gold here too because every package below either depends on it or targets it.

**🥈 Silver**
- **sketch** ([ghivert](https://github.com/ghivert)) — The CSS-in-Gleam answer. 263 commits, three runtime adapters (Lustre, Redraw, build-time CSS), ~80k lifetime downloads. The closest the ecosystem has to a typed-styles standard.

**🥉 Bronze**
- **dnd** ([tpjg](https://git.sr.ht/~tpjg)) — Direct port of `elm/dnd-list`, the most thorough drag-and-drop library in Gleam. Sourcehut-hosted, so star count understates it.

| Position | Award | Repo | ★ | Lic | Compat | Maint | Age | README | Idiom | Score |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 🥇 | [lustre-labs/lustre](https://github.com/lustre-labs/lustre) | 🟩🟩 | 🟩 | 🟩 | 🟩🟩 | 🟩🟩 | 🟩🟩 | 🟩 | **12** |
| 2 | 🥈 | [ghivert/sketch](https://github.com/ghivert/sketch) | 🟨 | 🟩 | 🟩 | 🟩🟩 | 🟩 | 🟩 | 🟩 | **7** |
| 3 | 🥉 | · [tpjg/dnd](https://git.sr.ht/~tpjg/dnd)<br>· [ghivert/grille-pain](https://github.com/ghivert/grille-pain)<br>· [bruceesmith/m3e](https://github.com/bruceesmith/m3e) | 🟥<br>🟨<br>🟥 | 🟩<br>🟩<br>🟩 | 🟩<br>🟩<br>🟩 | 🟩🟩<br>🟩🟩<br>🟩🟩 | 🟩<br>🟩<br>🟥 | 🟩🟩<br>🟩🟩<br>🟩🟩 | 🟩<br>🟩<br>🟩 | **7** |
| 4 | | · [dinkelspiel/popcicle](https://github.com/dinkelspiel/popcicle)<br>· [dinkelspiel/lucide_lustre](https://github.com/dinkelspiel/lucide_lustre)<br>· [hayleigh-dot-dev/optimist](https://github.com/hayleigh-dot-dev/optimist) | 🟨<br>🟨<br>🟨 | 🟩<br>🟩<br>🟩 | 🟩<br>🟩<br>🟩 | 🟩<br>🟩🟩<br>🟩 | 🟩<br>🟩<br>🟩 | 🟩🟩<br>🟩<br>🟩 | 🟩<br>🟩<br>🟩 | **7** |
| 5 | | · [MAHcodes/gleez](https://github.com/MAHcodes/gleez)<br>· [NduatiK/legos](https://github.com/NduatiK/legos)<br>· [daniellionel01/glaze_basecoat](https://github.com/daniellionel01/glaze) (basecoat)<br>· [brettkolodny/phosphor-lustre](https://github.com/brettkolodny/phosphor-lustre) | 🟨<br>🟨<br>🟨<br>🟥 | 🟩<br>🟩<br>🟩<br>🟩 | 🟩<br>🟩<br>🟩<br>🟩 | 🟨<br>🟩<br>🟩🟩<br>🟩 | 🟩<br>🟨<br>🟥<br>🟩 | 🟩<br>🟩<br>🟩<br>🟩 | 🟩<br>🟩<br>🟩<br>🟩 | **5** |
| 6 | | · [lustre-labs/lustre_ui](https://github.com/lustre-labs/lustre_ui)<br>· [lustre-labs/portal](https://github.com/lustre-labs/portal)<br>· [skinkade/gleroglero](https://github.com/skinkade/gleroglero)<br>· [renatillas/ensaimada](https://github.com/renatillas/ensaimada)<br>· [weedonandscott/lustre_pipes](https://github.com/weedonandscott/lustre_pipes)<br>· [mc706/lustre_stylish](https://github.com/mc706/lustre_stylish) | 🟩<br>🟥<br>🟥<br>🟥<br>🟥<br>🟥 | 🟩<br>🟩<br>🟩<br>🟩<br>🟩<br>🟩 | 🟩<br>🟩<br>🟩<br>🟩<br>🟩<br>🟩 | 🟥<br>🟩<br>🟨<br>🟩<br>🟩<br>🟩🟩 | 🟩<br>🟩<br>🟩<br>🟩<br>🟩<br>🟨 | 🟩<br>🟩<br>🟩<br>🟩<br>🟩<br>🟩 | 🟩<br>🟩<br>🟩<br>🟩<br>🟩<br>🟩 | **5** |
| 7 | | · [schurhammer/lustre_virtual_list](https://github.com/schurhammer/lustre_virtual_list)<br>· [dusty-phillips/monks_of_style](https://github.com/dusty-phillips/monks_of_style)<br>· [dusty-phillips/open_props_gleam](https://github.com/dusty-phillips/open_props_gleam)<br>· [bentomas/formz](https://github.com/bentomas/formz) | 🟨<br>🟥<br>🟥<br>🟥 | 🟩<br>🟩<br>🟩<br>🟩 | 🟩<br>🟩<br>🟩<br>🟩 | 🟥<br>🟩🟩<br>🟩🟩<br>🟨 | 🟩<br>🟨<br>🟨<br>🟩 | 🟩<br>🟩<br>🟩<br>🟩 | 🟩<br>🟩<br>🟩<br>🟩 | **4** |
| 8 | | · [tantalumv/Glizzy](https://github.com/tantalumv/Glizzy)<br>· [loipesmas/blask](https://github.com/loipesmas/blask)<br>· [mc706/lustre_prefab](https://github.com/mc706/lustre_prefab)<br>· [kero/lustre_animation](https://codeberg.org/kero/lustre_animation)<br>· [codemonkey76/lustre_transition](https://hex.pm/packages/lustre_transition) | 🟥<br>🟥<br>🟥<br>🟥<br>🟥 | 🟩<br>🟩<br>🟩<br>🟩<br>🟩 | 🟩<br>🟩<br>🟩<br>🟩<br>🟩 | 🟥<br>🟥<br>🟥<br>🟩<br>🟥 | 🟥<br>🟨<br>🟥<br>🟩<br>🟩 | 🟩<br>🟩<br>🟩<br>🟩<br>🟩 | 🟩<br>🟩<br>🟩<br>🟩<br>🟩 | **2** |

> [!NOTE]
> [glaze_oat](https://github.com/daniellionel01/glaze) ships from the same monorepo as glaze_basecoat (same maintenance, license, age) and scores identically; folded into a single row above to avoid double-counting.

[How scores are calculated →](#scoring-dimensions)

> <details>
> <summary>Disregarded — out of scope, abandoned, or duplicate of an existing article</summary>
>
> **Out of Scope (covered elsewhere or off-topic):**
> - **[okkdev/glailglind](https://github.com/okkdev/glailglind)** — Tailwind CLI wrapper. Build-pipeline tool, not a UI dev library. Already covered in [tailwind.md → glailglind](./tailwind.md#glailglind).
> - **[lustre-labs/dev-tools](https://github.com/lustre-labs/dev-tools)** — Lustre CLI / dev server. Build tooling. Covered in [web-apps.md → lustre_dev_tools](./web-apps.md#lustre_dev_tools) and [tailwind.md → lustre_dev_tools](./tailwind.md#lustre_dev_tools).
> - **[andre-dasilva/html_components](https://github.com/andre-dasilva/html_components)** — Generates HTML/XML from Gleam functions. Not Lustre-specific; overlaps with `lustre/element/html` itself. Niche.
> - **[Massolari/pink](https://github.com/Massolari/pink)** — Bindings to [Ink](https://github.com/vadimdemedes/ink) for terminal UIs. Out of scope (this article is web UI).
> - **[gleam-br/gbr_ui](https://github.com/gleam-br/gbr_ui)** — Stateless Lustre components inspired by TailAdmin. 4★, 139 commits, last commit 2025-11-26 (~5 mo before snapshot), Apache-2.0. Real candidate that overlaps with [gleez](#gleez) / [glaze_basecoat](#glaze_basecoat); excluded for traction (4★ vs gleez's 61★) and to avoid further bloat in the component-library section. Worth tracking.
>
> **Abandoned / Stub:**
> - **[TobiasBinnewies/cosmos](https://gitlab.com/TobiasBinnewies/cosmos)** — UI library for the abandoned `novdom` framework. Already noted as abandoned in [web-apps.md disregarded](./web-apps.md#discovery). 3 commits, v0.0.0.
> - **[arnarg/gliew](https://github.com/arnarg/gliew)** — SSR framework with "live updating UI." Already disregarded in [web-apps.md](./web-apps.md#discovery) (~3 years dormant); reappears in `?search=ui` results because of the description.
>
> </details>
