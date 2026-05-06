# Diagramming Tools — Cross-Ecosystem Survey

> [!NOTE]
> **Status:** DRAFT · **Authoring:** AI-assisted, human-reviewed.

> Pen and paper is ideal but hard to digitalise. You want something machine-parseable. This is the map.

**Snapshot 2026-04-27** — metrics from live GitHub / GitLab web UI only (no API for stars, no clones). Star counts, last-commit dates, and open-issue counts reflect what a logged-out visitor sees today.

## Table of Contents

1. [Why diagrams-as-code](#why-diagrams-as-code)
2. [The diagramming pipeline](#the-diagramming-pipeline)
3. [Aspects we score on](#aspects-we-score-on)
4. [Mainstream text-to-diagram tools](#mainstream-text-to-diagram-tools)
   - [Mermaid](#mermaid)
   - [PlantUML](#plantuml)
   - [D2](#d2)
   - [Graphviz / DOT](#graphviz--dot)
   - [LaTeX / TikZ](#latex--tikz)
   - [Pikchr](#pikchr)
5. [Meta-aggregator: Kroki](#meta-aggregator-kroki)
6. [Domain-specific tools](#domain-specific-tools)
   - [Cloud architecture — mingrammer/diagrams](#cloud-architecture--mingrammerdiagrams)
   - [Cloud architecture (AWS) — awslabs/diagram-as-code](#cloud-architecture-aws--awslabsdiagram-as-code)
   - [C4 model — Structurizr](#c4-model--structurizr)
   - [C4 model — LikeC4](#c4-model--likec4)
   - [C4 model — goa.design/model](#c4-model--goadesignmodel)
   - [Mathematical notation — Penrose](#mathematical-notation--penrose)
   - [Database schema — DBML](#database-schema--dbml)
   - [Database exploration — Azimutt](#database-exploration--azimutt)
   - [Timelines — Markwhen](#timelines--markwhen)
   - [Hardware timing — WaveDrom](#hardware-timing--wavedrom)
   - [Wiring harnesses — WireViz](#wiring-harnesses--wireviz)
   - [Byte fields / protocols — bytefield-svg](#byte-fields--protocols--bytefield-svg)
   - [Message sequence charts — mscgen_js](#message-sequence-charts--mscgen_js)
   - [BPMN — bpmn-js](#bpmn--bpmn-js)
   - [Tiny UML — Nomnoml](#tiny-uml--nomnoml)
   - [Hand-drawn aesthetic — Excalidraw](#hand-drawn-aesthetic--excalidraw)
   - [Documentation builder — C4-Builder](#documentation-builder--c4-builder)
7. [ASCII renderers](#ascii-renderers)
   - [DSL → ASCII](#dsl--ascii)
   - [ASCII sketch → vector](#ascii-sketch--vector)
   - [Pure-ASCII editors](#pure-ascii-editors)
   - [Terminal charts](#terminal-charts)
8. [Decision tree](#decision-tree)
9. [Leaderboard](#leaderboard)
10. [Appendix: skipped or stale](#appendix-skipped-or-stale)
11. [Discovery — search queries](#discovery--search-queries)

## Why diagrams-as-code

Hand-drawn whiteboard sketches don't survive into the repo. Visio / draw.io binaries diff badly and lock you to a GUI. **Text-source diagrams** are version-controllable, AI-generatable, and round-trip cleanly through PR review. The trade-off is layout: a text source needs an engine to position the boxes.

Two design intents dominate the space:

- **Auto-layout** (mermaid, plantuml, d2, graphviz) — you describe nodes and edges; the tool decides positions. Wins for "I just want a diagram from the code in my head". Loses on aesthetic control.
- **Manual positioning** (TikZ, asymptote, drawio XML) — you specify coordinates. Wins on print-quality precision. Loses on iteration speed.

This article focuses on auto-layout DSLs first, then domain-specific and ASCII renderers. Manual-positioning typesetting (TikZ) appears for completeness.

## The diagramming pipeline

```
┌──────────────────────────┐
│  Source text (DSL)       │  ← .mmd, .puml, .d2, .dot, .tex
└────────────┬─────────────┘
             │ parsed by …
             ▼
┌──────────────────────────┐
│  AST + semantic model    │  ← nodes, edges, clusters, attributes
└────────────┬─────────────┘
             │ laid out by …
             ▼
┌──────────────────────────┐
│  Layout engine           │  ← dagre / ELK / graphviz / TALA
└────────────┬─────────────┘
             │ rendered to …
             ▼
┌──────────────────────────┐
│  Output                  │  ← SVG / PNG / PDF / ASCII / HTML
└──────────────────────────┘
```

When you pick a diagramming tool you are really picking three things:

1. A **DSL surface** (how concise is the source?)
2. A **layout engine** (does the rendered diagram look any good?)
3. A **rendering target** (where does the output need to live — browser, print, terminal, GitHub?)

Most tools couple all three. Kroki, uniquely, decouples DSL choice from rendering target.

## Aspects we score on

- **Stars** — community-size signal. ≥10k = 🟩🟩, ≥1k = 🟩, <100 = 🟥. (Cross-host caveat: GitLab star culture is much weaker than GitHub's; Graphviz's 1.4k GitLab stars carries roughly the weight of GitHub 10k+.)
- **License** — 🟩 permissive (MIT/Apache-2.0/BSD/MPL/EPL), 🟨 weak copyleft (LGPL/MPL with file-level reach), 🟥 viral (GPL/AGPL). Multi-licensed tools with a permissive option get 🟩.
- **Maintenance** — latest commit date vs snapshot. 🟩🟩 within last month, 🟩 within last year, 🟥 > 1 year stale.
- **README maturity** — 🟩🟩 guide-style with feature list + diagram gallery, 🟩 clear tagline + install + basic usage, 🟥 minimal/scaffold.
- **Language support** — *what host languages can render this without shelling out to a foreign runtime?* Browser-native JS = wide reach; Java JAR = niche outside JVM shops; pure C with bindings everywhere = universal.
- **Rendering targets** — SVG, PNG, PDF, ASCII, HTML, animated — what does the tool actually emit?
- **Design intent** — readability, interactivity, aesthetic, scope (general vs domain-specific). Qualitative.
- **Diagram type breadth** — count of distinct semantic diagram kinds (sequence, ER, gantt, etc.).

The first six are tabular; the last two are prose per tool.

## Mainstream text-to-diagram tools

The big five. All five have first-tier maintenance and active distribution as of snapshot date.

| Dimension | [Mermaid](#mermaid) | [PlantUML](#plantuml) | [D2](#d2) | [Graphviz / DOT](#graphviz--dot) | [LaTeX / TikZ](#latex--tikz) |
| --- | --- | --- | --- | --- | --- |
| Stars | 87.7k · 🟩🟩 | ~13k · 🟩🟩 | 23.6k · 🟩🟩 | 1.4k *(GitLab)* · 🟩 † | 1.3k · 🟩 |
| License | MIT · 🟩 | Multi (MIT/Apache/EPL/LGPL/GPL) · 🟩 | MPL-2.0 · 🟩 | EPL-2.0 · 🟨 | LPPL/GPL/GFDL · 🟨 |
| Latest commit | 2026-04-27 · 🟩🟩 | 2026-04-17 · 🟩🟩 | 2026-04-24 · 🟩🟩 | 2026-04-20 · 🟩🟩 | 2026-04-13 · 🟩🟩 |
| Open issues | ~1.4k | ~600 | 470 | ⬜ ‡ | 288 |
| README maturity | 🟩🟩 | 🟩🟩 | 🟩 | 🟩🟩 *(via graphviz.org)* | 🟩 *(via 1300pp pgfmanual.pdf)* |
| Implementation | TypeScript / browser | Java JAR | Go | C | TeX macros |
| Auto-layout | yes (dagre) | yes (delegates to dot) | yes (dagre / ELK / TALA) | yes (canonical) | manual positioning |
| ASCII output | no | sequence diagrams only | yes (≥0.7.1) | yes (`-Tascii`) | no |
| Animated output | limited | no | **yes (SVG SMIL)** | no | yes (via dvisvgm) |
| Diagram-type count | 25+ | ~25 | ~10 | graph primitives only |  ∞ via libraries |

> † Graphviz lives on GitLab; star culture floor is much lower than GitHub. The GitHub mirror (`ellson/MOTHBALLED-graphviz`) is obsolete — name itself signals the abandonment.
>
> ‡ GitLab issue list is JS-rendered; the count couldn't be retrieved via static fetch. Historically several hundred open.

### Mermaid

**[mermaid-js/mermaid](https://github.com/mermaid-js/mermaid)** — *"Generation of diagrams like flowcharts or sequence diagrams from text in a similar manner as markdown."*

The dominant text-to-diagram tool by a wide margin (87.7k★). Browser-native JavaScript; **GitHub renders ` ```mermaid ` blocks inline** (since Feb 2022) and so do GitLab, Notion, Obsidian, Forgejo, HackMD, Quarto, Slidev, Joplin and many others. The ubiquity of zero-config rendering is its single strongest moat.

- **Implementation:** TypeScript + JavaScript. Runs in any JS environment.
- **Server-side:** [`mermaid-cli`](https://github.com/mermaid-js/mermaid-cli) (4.5k★) — wraps Puppeteer, emits SVG/PNG/PDF. Cross-language consumption is always Puppeteer-mediated; no native non-JS implementation.
- **Diagram types (25+):** flowchart, sequence, class, state, ER, user journey, gantt, pie, quadrant, requirement, gitgraph, C4, mindmap, timeline, ZenUML, sankey, XY chart, block, packet, kanban, architecture, radar, treemap, venn, ishikawa, treeview.
- **Interactivity:** clickable nodes (`click NodeId href "URL"`), JS handler callbacks, hover. Sandboxed iframe security mode for UGC.
- **Theming:** built-in (default, dark, forest, neutral, base) + `themeVariables` for full custom palettes. Dark mode first-class.
- **Playground:** [mermaid.live](https://mermaid.live) (free), [mermaidchart.com](https://mermaidchart.com) (commercial SaaS by core team).

**Pick when:** you want diagrams that *just render* anywhere a markdown viewer exists; you're already in a JS toolchain; you need broad diagram-type coverage with one tool.

**Pass when:** print-quality output is non-negotiable, you need fine layout control, or you can't tolerate a Puppeteer dep server-side.

### PlantUML

**[plantuml/plantuml](https://github.com/plantuml/plantuml)** — *"Generate UML diagrams from textual descriptions."*

The senior tool of the space (project ~2009). Strongest UML coverage, deepest diagram catalogue (~25 types including some nobody else has — Salt for wireframes, Archimate for enterprise architecture, Ditaa for ASCII art, EBNF, regex, JSON/YAML pretty-printing).

- **Implementation:** Java JAR. Distribution as `plantuml.jar`. **Multi-licensed** — pick from MIT / Apache-2.0 / EPL-2.0 / LGPL-3.0 / GPL-3.0 — so commercial integrators can avoid GPL viral copyleft. This is unusual and worth flagging.
- **Layout:** delegates to **Graphviz/dot by default**. Pure-Java fallback engine **Smetana** for shops that can't ship Graphviz.
- **Wrappers:** Python (`python-plantuml`, IPython), Node, Ruby (Jekyll plugin), PHP, Perl, Swift, Groovy. Every wrapper builds the source string + invokes the JAR.
- **Online:** [plantuml.com](https://plantuml.com) renders text → image (URL-encoded source). Self-host via [`plantuml/plantuml-server`](https://hub.docker.com/r/plantuml/plantuml-server) Docker image.
- **Output:** PNG, SVG, LaTeX, EPS. ASCII art for **sequence diagrams only** (`-ttxt` / `-tutxt`).
- **Theming:** verbose `skinparam` system + community [`puml-themes-gallery`](https://github.com/bschwarz/puml-themes).

**Pick when:** UML breadth matters (sequence + class + activity + state + component all from one tool); print-style PDF/EPS output is needed; archimate or salt diagrams are in scope.

**Pass when:** you want zero-Java deployment, or your readers expect inline rendering on GitHub (PlantUML works there only via image URL trick, not native).

### D2

**[terrastruct/d2](https://github.com/terrastruct/d2)** — *"A modern diagram scripting language that turns text to diagrams."*

The newest entrant of the big three (first commit ~2022) and the one positioned explicitly against the older tools' aesthetics. Go implementation with **three swappable layout engines** (dagre, ELK, TALA), built-in **animated SVG export**, and **sketch mode** (hand-drawn aesthetic, similar to Excalidraw's look but auto-laid-out).

- **Implementation:** Go. `go install oss.terrastruct.com/d2@latest`. Bindings (community wrappers, not native rewrites) in JavaScript, Python, C#/.NET, Clojure. No Rust or WASM port.
- **Layout engines:**
  - `dagre` — default, hierarchical, bundled
  - `ELK` — alternative hierarchical, bundled
  - `TALA` — proprietary binary, optimised for software architecture; commercial offering from Terrastruct
- **Output:** SVG, PNG, PDF, **animated SVG** (the marquee feature — *"the only language that can produce animated diagrams from text"* per the docs), **ASCII** (≥0.7.1, two charsets — Unicode-box + standard-ASCII).
- **Watch mode:** `d2 --watch` for live-reload local dev.
- **Diagram types:** sequence (`shape: sequence_diagram`), UML class, ER, flowchart, infrastructure, network, general directed graphs.
- **Interactivity:** clickable links, tooltips, multilingual labels, syntax-highlighted code blocks **inside** diagram nodes.
- **Privacy:** README explicitly states *"no telemetry post-installation"*.

**Pick when:** aesthetic matters and you want auto-layout; you need animated diagrams from text; you're in Go-tooling-friendly territory.

**Pass when:** GitHub-native inline rendering is required (mermaid wins); you need 20+ diagram types (mermaid/plantuml win); the proprietary TALA layout is a non-starter for your shop.

### Graphviz / DOT

**[gitlab.com/graphviz/graphviz](https://gitlab.com/graphviz/graphviz)** — *the layout substrate for half the diagramming ecosystem.*

Born at AT&T Bell Labs ~1991. Pure **graph-drawing tool** — not a UML/sequence DSL. The DOT language describes nodes and edges; six layout engines position them:

- **dot** — hierarchical/Sugiyama for DAGs
- **neato** — spring-model force-directed (small undirected graphs)
- **fdp** — alternative force-directed
- **sfdp** — multilevel force-directed, **scales to thousands of nodes**
- **circo** — circular layout (cyclic structures)
- **twopi** — radial (tree from root)

Plus **osage**, **patchwork**, **nop** for clustered / treemap / pass-through.

- **Implementation:** C. Install via `apt`/`brew`/`choco` or official tarball.
- **Bindings:** [pygraphviz](https://github.com/pygraphviz/pygraphviz), [python-graphviz](https://github.com/xflr6/graphviz) (lightweight wrapper), [ts-graphviz](https://github.com/ts-graphviz/ts-graphviz), [graphviz-rust](https://github.com/besok/graphviz-rust), [graphviz4j](https://github.com/nidi3/graphviz-java), [Rgraphviz](https://www.bioconductor.org/packages/release/bioc/html/Rgraphviz.html). Almost every general-purpose language has at least a thin wrapper.
- **WASM:** [**viz-js**](https://github.com/mdaines/viz-js) (~4.3k★, MIT) — Graphviz compiled to WebAssembly + JS wrapper. Enables fully client-side DOT rendering. Powers many in-browser graph viewers.
- **Output formats** (`dot -T?`): canon, dot, gv, xdot, json, **svg**, svgz, pdf, ps, eps, vrml, **png**, jpg, gif, bmp, tiff, webp, **plain**, **ascii**, **kitty** (Kitty terminal protocol), cmapx (HTML imagemap for click targets), and ~30 others.
- **Diagram types:** directed/undirected/multi-edge graphs, hierarchical, force-directed, radial, circular layouts, clusters/subgraphs, HTML-like labels (mini-tables in nodes). **No** UML/sequence/ER semantics.

**Why it's foundational:** Graphviz is the **plumbing layer** for higher-level tools. PlantUML uses dot for layout (default for class/component/state). The blockdiag family delegates to it. Doxygen uses dot for class/call graphs. NetworkX, pydot, gprof2dot, pyreverse all emit DOT and shell out. *Effective market share is dramatically larger than direct user count.*

**Pick when:** you need the best automatic layout for large graphs (sfdp scales further than anything else); you're emitting graphs from another tool that wants a target format; you want browser rendering with no server (viz-js).

**Pass when:** you want UML / sequence semantics out of the box (use plantuml/mermaid layered on top instead).

### LaTeX / TikZ

**[pgf-tikz/pgf](https://github.com/pgf-tikz/pgf)** — the TeX-world drawing standard.

Different category from the rest. **TikZ runs only inside TeX** (pdfTeX, XeTeX, LuaTeX). Pure TeX macros — no port to any other language exists or is feasible. Compilation pipeline: `.tex` → DVI/PDF; with the `standalone` document class, single-page crop-to-content PDF; SVG via `dvisvgm`.

- **Design intent:** maximum **typographic and mathematical precision**. Every node can hold full TeX math; fonts match document body exactly. Programmer-hostile syntax (semicolon-terminated paths, brace-nested options) but academia-loved.
- **Library ecosystem (huge):** pgfplots (technical plots), tikz-cd (commutative diagrams), tikz-uml, circuitikz, chemfig (chemistry), tikzducks, tikz-network, forest (linguistic trees), pgfgantt, tikz-3dplot.
- **Wrappers:** [tikzplotlib](https://github.com/nschloe/tikzplotlib) (matplotlib → TikZ source).
- **Server-side rendering:** requires a full TeX install — `latexmlhttp`, Overleaf compile API, or self-hosted Docker (`texlive/texlive`). **No native browser/JS renderer** — the biggest contrast with Mermaid/D2/Graphviz-WASM.
- **Online services:** [overleaf.com](https://overleaf.com), [tikzcd.yichuanshen.de](https://tikzcd.yichuanshen.de) (commutative-diagram GUI → TikZ), [q.uiver.app](https://q.uiver.app).
- **Output:** PDF (primary), SVG (via dvisvgm — supports SMIL animations), PNG (post-conversion). **Static**, print-quality. No interactivity.

**Sister tools:**

- **[Asymptote](https://github.com/vectorgraphics/asymptote)** — 666★, GPL-3.0, last commit 2026-04-26 · 🟩🟩. Standalone vector-graphics language inspired by MetaPost. Same TeX-graphics tradition; not LaTeX-bundled.
- **MetaPost** — TikZ's predecessor; bundled with TeX Live, Pascal-like syntax. Knuth uses it.
- **[TikZiT](https://tikzit.github.io)** — minimal GUI editor for TikZ, exports editable source.

**Pick when:** the diagram lives inside a LaTeX document; you need print-quality typesetting where fonts match body text; you're producing academic figures; you want maximum control over node placement.

**Pass when:** you don't already have a TeX install in the pipeline; you need browser rendering or interactivity; iteration speed matters.

> **Note:** "LaTeX" alone is a typesetting system — it does not draw diagrams. The diagramming layer is **TikZ/PGF** (or sister packages MetaPost / Asymptote). This article treats them as one row.

### Pikchr

**[pikchr.org](https://pikchr.org)** — primary host (Fossil) · **[github.com/drhsqlite/pikchr](https://github.com/drhsqlite/pikchr)** mirror — 148★ · **0BSD** · last commit 2026-01-02 · 🟩🟩

PIC-revival by **D. Richard Hipp** (the SQLite author). The original `pic` was Brian Kernighan's diagram language at Bell Labs (~1982); Pikchr is a modern, security-hardened reimplementation in C, designed to be embedded into Markdown fenced code blocks. **The official SQLite documentation, Fossil SCM, and TCL/TK docs are all rendered with pikchr** — that's the production proof.

- **Implementation:** single C file, no deps. Embeds trivially in any C/C++/Rust binary; ports exist for Rust ([`kinnison/pikchr`](https://github.com/kinnison/pikchr)), TypeScript ([`Hocdoc/pikchr-typescript`](https://github.com/Hocdoc/pikchr-typescript)), Haskell, Node.
- **Output:** SVG only. (Other formats via SVG post-processing.)
- **License:** **0BSD** — zero-clause BSD, the most permissive license that still requires distribution. *More permissive than MIT.*
- **Design intent:** maximum embeddability + zero attack surface. The `sh` command of legacy PIC was deliberately removed for security.

**Pick when:** you're shipping a doc site in C/C++/Rust and want a single-file, license-free embedded diagram engine; you like the PIC syntax tradition.

**Pass when:** you need broad diagram-type coverage (it's a graph-drawing primitive, not a UML toolkit); you're not in a doc-tooling context.

> Note: GitHub stars on the mirror radically understate adoption — Pikchr's effective install base is "every project that uses Fossil or SQLite docs". The primary repo lives at [pikchr.org](https://pikchr.org) on Fossil; GitHub is mirror-only.

## Meta-aggregator: Kroki

**[yuzutech/kroki](https://github.com/yuzutech/kroki)** — 4.1k★ · MIT · v0.30.1 (2026-03-02) · 🟩🟩

Self-hostable HTTP gateway that renders **~25 DSLs** through one unified API. Clients `POST /<engine>/<format>` and get SVG/PNG back. Supported engines: BlockDiag family, BPMN, Bytefield, C4-PlantUML, **D2**, DBML, Diagrams.net, Ditaa, Erd, Excalidraw, GoAT, Graphviz, **Mermaid**, Nomnoml, Pikchr, **PlantUML**, SvgBob, Symbolator, UMLet, **Vega/Vega-Lite**, **WaveDrom**, WireViz.

Distinctive: it's a **meta-tool, not a DSL**. You can defer the DSL choice and let each author pick. Trade-off: heavyweight Java + Node deployment.

**Pick when:** you maintain a documentation platform / wiki where contributors want to use whatever DSL they prefer; you need server-side rendering of multiple DSLs from one ops surface.

## Domain-specific tools

When the general-purpose tools don't fit your domain, these are the standards.

### Cloud architecture — mingrammer/diagrams

**[mingrammer/diagrams](https://github.com/mingrammer/diagrams)** — 42.2k★ · MIT · v0.25.1 (2025-11-22)

Python DSL where you `import` AWS / Azure / GCP / Kubernetes / Alibaba / Oracle node icons and compose with `>>` / `<<` operators. Renders via Graphviz to PNG/SVG.

```python
from diagrams import Diagram
from diagrams.aws.compute import EC2
from diagrams.aws.database import RDS

with Diagram("Web Service"):
    EC2("web") >> RDS("db")
```

The killer feature is the **massive icon catalogue** (every major cloud provider's stencil set). Used by Apache Airflow et al. for docs. **Visualisation-only** — does not interact with cloud APIs.

### Cloud architecture (AWS) — awslabs/diagram-as-code

**[awslabs/diagram-as-code](https://github.com/awslabs/diagram-as-code)** — 1.5k★ · Apache-2.0 · v0.23 (2026-04-08) · 🟩🟩

AWS-official **YAML-based** CLI for AWS architecture diagrams. Optionally consumes a CloudFormation template directly and emits a PNG that mirrors AWS's official architecture-icon style. Younger than mingrammer/diagrams (first release 2024) and **AWS-only** in scope, but the CFN-template ingestion is unique — you can generate diagrams from your live infra-as-code.

**Pick over mingrammer/diagrams when:** you're AWS-only and want CloudFormation-template→diagram round-trip; you prefer YAML over Python.

### C4 model — Structurizr

**[structurizr/dsl](https://github.com/structurizr/dsl)** — 1.4k★ · Apache-2.0 · *archived 2024-01-10*, code moved to [`structurizr/java/tree/master/structurizr-dsl`](https://github.com/structurizr/java/tree/master/structurizr-dsl).

DSL for **C4-model** architecture (Context / Container / Component / Code) with first-class abstractions: `softwareSystem`, `container`, `relationship`, multiple views derived from one model. Single source of truth → multiple diagram views. Only mainstream tool where C4 is **the data model**, not a stencil set.

For inline C4-on-mermaid/plantuml, see [`C4-PlantUML`](https://github.com/plantuml-stdlib/C4-PlantUML) (community macros) and Mermaid's native `C4Context` diagram type.

### C4 model — LikeC4

**[likec4/likec4](https://github.com/likec4/likec4)** — 3.1k★ · MIT · v1.55.1 (2026-04-15), latest commit 2026-04-25 · 🟩🟩

Modern alternative to Structurizr DSL: declares a **single architecture model** in a custom DSL and compiles it into multiple zoomable interactive web diagrams. Inspired by C4 + Structurizr but with **flexible notation** (custom element types, unlimited nesting), full **VS Code extension**, and — critically — an **MCP server** that lets agentic AI tools (Claude Code, Copilot) query the architecture model directly.

- **Implementation:** TypeScript (97%). Browser-native viewer; CLI compiles to static HTML.
- **DSL surface:** `model { ... }`, `views { ... }`, with `specification` for custom shapes/colours.
- **Output:** interactive web app (zoom-between-levels), static SVG/PNG export, MCP server for AI agents.
- **Adoption signal:** 3.1k★ in <3 years, 133 open issues, very active (fortnightly releases).

**Pick when:** you want C4 as data model (like Structurizr) **plus** interactive zoom-from-context-to-component **plus** AI-native architecture queries; your team is in a TypeScript / Node toolchain.

**Pass when:** you need server-side rendering only (LikeC4 is web-first); you want pure DSL with zero build step (Structurizr DSL ships as a single JAR).

### C4 model — goa.design/model

**[goadesign/model](https://github.com/goadesign/model)** — 459★ · MIT · v1.14.1 (2025-12-15) · 🟩🟩

**Go DSL** for C4-model architecture, by the goa.design team. Architecture is declared as ordinary Go packages; the `mdl` and `stz` tools emit either a local SVG/HTML viewer or upload to Structurizr.com. Pick when your shop is Go-native and you want the architecture model to live next to the code that implements it.

### Mathematical notation — Penrose

**[penrose/penrose](https://github.com/penrose/penrose)** — 7.9k★ · MIT · v3.3.0 (2025-09-28), latest commit 2026-03-02 · 🟩🟩

Carnegie Mellon research project (SIGGRAPH 2020) that takes a fundamentally different approach: you write **abstract mathematical statements** in a `Substance` file, **type definitions** in a `Domain` file, and **visual styling rules** in a `Style` file. Penrose then runs **constrained numerical optimization** to lay out the diagram — there's no fixed library of node shapes.

- **Three-DSL surface:** Domain (types/predicates) + Substance (instances) + Style (visual rules). Total separation of *what's being shown* from *how it looks*.
- **Output:** SVG via constrained optimisation. Diagrams are auto-laid-out by solving — different runs produce different valid layouts.
- **Use cases:** mathematical notation (set theory, group theory, linear algebra, graph theory, geometry), but the same engine handles general constraint-laid-out diagrams.
- **Distinct from everything else in this article** — it's the only constraint-optimised diagrammer.

**Pick when:** you're producing mathematical figures for papers / courseware; you want to separate diagram *content* from *style* completely (one Substance file, swap Style for different aesthetics).

**Pass when:** you want a single-file DSL (Penrose's three-file split has a learning curve); you need interactive output (SVG-only, static).

### Database schema — DBML

**[holistics/dbml](https://github.com/holistics/dbml)** — 3.6k★ · Apache-2.0 · v7.1.1 (2026-04-17) · 🟩🟩

**Database Markup Language** by Holistics. The de-facto standard for database-schema-as-code. Powers [dbdiagram.io](https://dbdiagram.io) (visual editor) and [dbdocs.io](https://dbdocs.io) (auto-generated database documentation). 2.5M+ DBML docs created on dbdiagram.io as of early 2026.

```dbml
Table users {
  id integer [pk]
  email varchar [unique]
  created_at timestamp [default: `now()`]
}

Table posts {
  id integer [pk]
  user_id integer [ref: > users.id]
  title varchar
}
```

- **Implementation:** TypeScript core, JS/CLI bindings.
- **DB-agnostic** — the DSL describes structure, generators emit DDL for PostgreSQL, MySQL, SQL Server, Oracle, Snowflake, BigQuery, and SQLite.
- **Bidirectional:** SQL DDL → DBML import, DBML → DDL export. Round-trippable.
- **Tooling:** VS Code extension ([`bocovo.dbml-erd-visualizer`](https://marketplace.visualstudio.com/items?itemName=bocovo.dbml-erd-visualizer)) for inline ERD preview; CLI for CI use.
- **Renders via:** [Kroki](https://kroki.io/) supports DBML server-side. dbdiagram.io is the canonical web renderer.

**Pick when:** you want a single source of truth for database schema with auto-rendered ERD; you're in a multi-DB shop and want vendor-neutral schema docs; you want to round-trip schemas to/from DDL.

**Pass when:** your data model is denormalised / NoSQL-shaped (DBML assumes relational); you want a graphical editor (dbdiagram.io is closed-source SaaS for that).

### Database exploration — Azimutt

**[azimuttapp/azimutt](https://github.com/azimuttapp/azimutt)** — 2.1k★ · MIT · latest commit 2026-04-27 · 🟩🟩

Self-hostable database **explorer** + ERD viewer + custom DSL ([**AML** — Azimutt Markup Language](https://azimutt.app/aml)) for schema design. Differentiator vs DBML: Azimutt **introspects live databases** (PostgreSQL, MySQL, MariaDB, Oracle, SQL Server, SQLite, MongoDB, Couchbase, Snowflake, BigQuery, Apache Hive) and lets you navigate hundreds of tables — designed for *real-world messy* schemas, not greenfield design.

- **Implementation:** Elixir/Phoenix backend + Elm/elm-spa frontend.
- **AML DSL** is shorter than DBML and supports rich documentation (notes, tags, layouts, memos).
- **Self-host:** Docker + Kubernetes deployment supported.

**Pick when:** you have a legacy DB with hundreds of tables and need exploration + documentation, not just static schema; you want self-hostable with sensitive data.

**Pass when:** you only need static ERD output (DBML is simpler).

### Timelines — Markwhen

**[mark-when/markwhen](https://github.com/mark-when/markwhen)** — 4.8k★ · MIT · main repo last commit 2023-12-11 (UI active in [`mark-when/c2`](https://github.com/mark-when/c2) — last update 2026-02-05) · 🟩

Markdown-like timeline DSL. Cascading timeline, calendar, resume, and gantt views from one source. The main monorepo's commits trail the org's other repos because development moved into modular packages (parser, view-client, vue-view-template, vscode extension) — the org as a whole had updates February 2026.

```markwhen
2024-01-01 / 2024-03-01: Build MVP #engineering
2024-03-01 / 2024-06-01: Beta launch #marketing
```

- **Output:** timeline view, calendar view, resume view, gantt-style view, custom views via the [view-client](https://github.com/mark-when/view-client) library.
- **Distinct from Mermaid gantt:** Markwhen handles arbitrary timeline events with hierarchies, locations, links, and tags — it's a *narrative timeline* tool, not just a project-plan gantt.
- **VS Code extension** for live preview.

**Pick when:** you want a personal timeline / project history / CV / event log as code; Mermaid's gantt is too project-plan-shaped for your data.

### Hardware timing — WaveDrom

**[wavedrom/wavedrom](https://github.com/wavedrom/wavedrom)** — 3.4k★ · MIT

WaveJSON input → SVG digital timing diagrams (clock signals, bit fields, register layouts). Editor, CLI, embeddable JS, server-side rendering at [svg.wavedrom.com](https://svg.wavedrom.com).

The standard for hardware/IC engineers. Nothing else in this list does waveforms. Niche but uncontested.

### Wiring harnesses — WireViz

**[wireviz/WireViz](https://github.com/wireviz/WireViz)** — 5.1k★ · GPL-3.0 · v0.4.1 (2024-07-13) · 🟩

YAML → SVG/PNG **cable and wiring-harness diagrams**, plus auto-generated bills of materials (BOM as TSV / embedded HTML). Used by hardware/maker shops to document loom assemblies. Renders via Graphviz under the hood.

- **Input:** YAML (connectors, cables, connections, ferrules, ratings).
- **Output:** SVG, PNG, TSV BOM, HTML page combining diagram + BOM.
- **Web wrapper:** [`wireviz/wireviz-web`](https://github.com/wireviz/wireviz-web) — REST API.
- **Caveat:** GPL-3.0 — viral copyleft. Use the REST wrapper if your downstream consumer can't be GPL.

Niche but uncontested in its corner. Nothing else here does wire-harness BOM-aware diagrams.

### Byte fields / protocols — bytefield-svg

**[Deep-Symmetry/bytefield-svg](https://github.com/Deep-Symmetry/bytefield-svg)** — 193★ · EPL-2.0 · v1.8.0 (2023-02-27) · 🟥

Node module that produces byte-field/protocol-frame diagrams (the kind of "labelled boxes-of-bits" diagram you see in IETF RFCs and protocol specs). Inspired by the LaTeX `bytefield` package; powered by a **Clojure DSL** running on top of SCI (Small Clojure Interpreter).

- **Input:** EDN (Extensible Data Notation, Clojure's data syntax).
- **Output:** SVG.
- **Use case:** binary protocol documentation, packet layouts, register maps for documentation/standards work.
- **Maintenance:** stale (3yr+) but the format is mature; zero open issues is a positive signal of "done".

Worth flagging because no other tool in this article does protocol byte-field diagrams; LaTeX `bytefield` is the only alternative.

### Message sequence charts — mscgen_js

**[sverweij/mscgen_js](https://github.com/sverweij/mscgen_js)** — 211★ · GPL-3.0 (with embedding exception) · v4.0.3 (2024-03-07) · 🟩

JavaScript port of the original `mscgen` (a C tool for **Message Sequence Charts** — the formal-engineering cousin of UML sequence diagrams, used heavily in telecom and SDL contexts). Adds two simplified syntax variants (**Xù**, **MsGenny**) for less verbose authoring, plus animation support.

- **Input:** MscGen / Xù / MsGenny text.
- **Output:** SVG (real-time rendering, syntax highlighting, animation, PNG/SVG export).
- **CLI:** [`mscgenjs/mscgenjs-cli`](https://github.com/mscgenjs/mscgenjs-cli) for headless rendering.

**Pick over mermaid sequence diagrams when:** you specifically need MSC/Xù semantics (telecom protocol modelling, formal sequence specs); the original C `mscgen` is fine but `mscgen_js` is browser-deployable.

### BPMN — bpmn-js

**[bpmn-io/bpmn-js](https://github.com/bpmn-io/bpmn-js)** — 9.5k★ · custom (MIT-like with attribution) · v18.15.0 (2026-04-22) · 🟩🟩

BPMN 2.0 toolkit: render and edit BPMN XML in-browser. Programmatic in the sense that BPMN XML is text — round-trippable. Only mature open BPMN renderer; serious adoption in BPM/workflow tooling (Camunda).

### Tiny UML — Nomnoml

**[skanaar/nomnoml](https://github.com/skanaar/nomnoml)** — 2.8k★ · MIT · last commit 2024-12-14 · 🟩

Minimalist UML class-diagram DSL designed so the source resembles the rendered output. Browser-native, CLI, Node SVG. Pure UML focus, zero deps, no Graphviz. Good when you just need a class diagram in a markdown file and don't want to install anything.

### Hand-drawn aesthetic — Excalidraw

**[excalidraw/excalidraw](https://github.com/excalidraw/excalidraw)** — **122k★** · MIT · v0.18.1 (2026-04-21) · 🟩🟩

Hand-drawn-aesthetic infinite whiteboard. Exports `.excalidraw` JSON, fully scriptable via the `@excalidraw/excalidraw` npm package (React component). Adopted by Notion, Obsidian, Replit, Meta.

**Design intent is "looks human-drawn"**, opposite of Mermaid's geometric crispness. Programmatic API + JSON format means you can generate diagrams from code while keeping the sketchy aesthetic. D2's sketch mode is a similar aesthetic but with auto-layout; Excalidraw is GUI-positioned with a JSON wire format.

### Documentation builder — C4-Builder

**[adrianvlupu/C4-Builder](https://github.com/adrianvlupu/C4-Builder)** — 620★ · MIT · 121 commits, last activity 2022 · 🟥

Node CLI that consumes a folder of `.md` + `.puml` files and emits a navigable docs site (Markdown collection, single Markdown, multi-PDF, single PDF, or [Docsify](https://docsify.js.org) site). Slim wrapper around PlantUML; the value-add is the documentation-builder layer.

**Pick when:** you've got an existing PlantUML-heavy architecture-docs corpus and want a one-shot publish step.

**Pass when:** you're starting fresh — LikeC4 has surpassed it for the "C4 + interactive site" use case.

## ASCII renderers

The user specifically wanted "raw ascii renderers — there must be multiple". There are. They split into four categories.

### DSL → ASCII

Structured input language → terminal-displayable text-art.

| Tool | URL | Stars | License | Latest | Notes |
|---|---|---:|---|---|---|
| **D2** (≥0.7.1) | [terrastruct/d2](https://github.com/terrastruct/d2) | 23.6k · 🟩🟩 | MPL-2.0 · 🟩 | 2026-04-24 · 🟩🟩 | Tier-1 ASCII export, two charsets (Unicode-box + standard-ASCII). Cross-ref [D2 above](#d2). |
| **PlantUML** (`-ttxt`) | [plantuml/plantuml](https://github.com/plantuml/plantuml) | ~13k · 🟩🟩 | Multi · 🟩 | 2026-04-17 · 🟩🟩 | **Sequence diagrams only** in ASCII mode. Excellent for those. Cross-ref [PlantUML above](#plantuml). |
| **Graphviz** (`-Tascii`) | [gitlab.com/graphviz/graphviz](https://gitlab.com/graphviz/graphviz) | 1.4k · 🟩 | EPL-2.0 · 🟨 | 2026-04-20 · 🟩🟩 | Native ASCII output for graph layouts. Cross-ref [Graphviz above](#graphviz--dot). |
| **Graph::Easy** | [metacpan.org/pod/Graph::Easy](https://metacpan.org/pod/Graph::Easy) | 684 (mirror) · 🟩 | GPL/Artistic · 🟨 | CPAN 0.76 (2016) · 🟥 | Perl. Graphviz-style DSL → ASCII art / Unicode boxart. Dormant but historically the canonical "graph DSL → text-art" tool. |
| **dot-to-ascii** | [ggerganov/dot-to-ascii](https://github.com/ggerganov/dot-to-ascii) | 501 · 🟩 | check | 2026-04-12 · 🟩🟩 | Wraps Graph::Easy to convert `.dot` → ASCII. Practical wrapper. |
| **adia** | [pylover/adia](https://github.com/pylover/adia) | 66 · 🟥 | check | 2026-01-25 · 🟩 | Python. ASCII DSL for UML sequence diagrams; emits ASCII. Niche. |

> [!IMPORTANT]
> There is **no notable native ASCII renderer for Mermaid**. Workaround in the wild is render → SVG → svg-to-ascii post-processing. Worth flagging as a gap.

### ASCII sketch → vector

Hand-drawn ASCII art as the *input*, polished SVG/PNG as the *output*. The "scribble on a napkin then render it" pattern.

| Tool | URL | Stars | License | Latest | Notes |
|---|---|---:|---|---|---|
| **svgbob** | [ivanceras/svgbob](https://github.com/ivanceras/svgbob) | 4.2k · 🟩 | Apache-2.0 · 🟩 | 2026-04-22 · 🟩🟩 | **Winner.** Rust. Most active, broadest embedding (mdbook, Hugo plugins). |
| **ditaa** | [stathissideris/ditaa](https://github.com/stathissideris/ditaa) | 1.0k · 🟩 | LGPL-3.0 · 🟨 | 2022-03-14 · 🟥 | Java classic. PNG/SVG. Stale but stable; PlantUML embeds it. |
| **goat** | [blampe/goat](https://github.com/blampe/goat) | 773 · 🟥 | MIT · 🟩 | active · 🟩 | Go reimplementation of ditaa-style. Hugo + static-site embedded. |
| **asciitosvg** | [asciitosvg/asciitosvg](https://github.com/asciitosvg/asciitosvg) | 220 · 🟥 | MIT · 🟩 | 2022-11-26 · 🟥 | Go reimplementation of `a2s`. |
| **ascii-d** | [huytd/ascii-d](https://github.com/huytd/ascii-d) | 290 · 🟥 | BSD-3-Clause · 🟩 | 2023-04-06 · 🟥 | Cross-platform ASCII diagram drawing app. |
| **shaape** | [christiangoltz/shaape](https://github.com/christiangoltz/shaape) | 108 · 🟥 | unclear · 🟨 | 2014-09-23 · 🟥 | Python. Asciidoc-friendly; abandoned (12yr stale). |
| **aafigure** | [aafigure/aafigure](https://github.com/aafigure/aafigure) | 21 · 🟥 | unclear · 🟨 | 2017-07-05 · 🟥 | Python, Sphinx ecosystem. Abandoned. |
| **Markdeep** | [casual-effects.com/markdeep](https://casual-effects.com/markdeep/) | n/a | BSD-2-Clause · 🟩 | active · 🟩 | Morgan McGuire. Markdown + ASCII diagrams → HTML/SVG client-side. |

### Pure-ASCII editors

ASCII in, ASCII out. For when the output medium itself is the terminal or a markdown code block.

| Tool | URL | Stars | License | Latest | Notes |
|---|---|---:|---|---|---|
| **Asciiflow** | [lewish/asciiflow](https://github.com/lewish/asciiflow) | 5.6k · 🟩 | MIT · 🟩 | 2026-04-23 · 🟩🟩 | TS web canvas. Most-starred in the space. Active. |
| **Diagon** | [ArthurSonzogni/Diagon](https://github.com/ArthurSonzogni/Diagon) | 2.2k · 🟩 | MIT · 🟩 | 2025-05-16 · 🟩 | C++. Interactive web + CLI. Math, sequence, table, grammar, graph, tree, frame. |
| **venn.nvim** | [jbyuki/venn.nvim](https://github.com/jbyuki/venn.nvim) | 1.2k · 🟩 | MIT · 🟩 | 2024-08-16 · 🟩 | Lua/Neovim plugin for drawing in-buffer. |
| **boxes** | [ascii-boxes/boxes](https://github.com/ascii-boxes/boxes) | 676 · 🟩 | GPL-3.0 · 🟥 | 2025-05-15 · 🟩 | C. Wraps text in ASCII box frames; canonical "decorate-with-ASCII" tool. |
| **askii** | [nytopop/askii](https://github.com/nytopop/askii) | 84 · 🟥 | Apache-2.0 · 🟩 | 2022-01-12 · 🟥 | Rust TUI editor. Stale ~4yr. |
| **asciio** | [nkh/P5-App-Asciio](https://github.com/nkh/P5-App-Asciio) | 80 · 🟥 | unclear · 🟨 | 2026-03-30 · 🟩🟩 | Perl/Gtk interactive editor. Active despite low stars. |

### Terminal charts

Numeric data → ASCII plot. Tangentially diagrammatic but in the same "text-as-canvas" tradition.

| Tool | URL | Stars | License | Latest | Notes |
|---|---|---:|---|---|---|
| **YouPlot** | [red-data-tools/YouPlot](https://github.com/red-data-tools/YouPlot) | 4.7k · 🟩 | MIT · 🟩 | 2026-04-27 · 🟩🟩 | Ruby CLI. Bar, hist, scatter, box, line. Most active. |
| **termgraph** | [mkaz/termgraph](https://github.com/mkaz/termgraph) | 3.3k · 🟩 | MIT · 🟩 | 2026-03-25 · 🟩🟩 | Python. Bar charts only; CLI-friendly. |
| **plotext** | [piccolomo/plotext](https://github.com/piccolomo/plotext) | 2.1k · 🟩 | MIT · 🟩 | 2026-04-24 · 🟩🟩 | Python. Most chart types: line, scatter, bar, hist, candlestick, image. |
| **asciichart** | [kroitor/asciichart](https://github.com/kroitor/asciichart) | 2.1k · 🟩 | MIT · 🟩 | 2026-04-02 · 🟩🟩 | JS/Node + ports. Single-purpose: line charts. |
| **gnuplot** (`set term dumb`) | [gnuplot.info](http://gnuplot.info) | n/a | gnuplot license · 🟨 | active | The reference. ASCII output via `dumb` terminal driver. |

## Decision tree

1. **Output must render inline on GitHub / GitLab / Notion / Obsidian without a render step?** → **Mermaid**. No further shopping needed.
2. **You need every UML diagram type, archimate, salt, gantt, ditaa, JSON pretty-print — all from one tool?** → **PlantUML**. Accept the Java JAR.
3. **You're a Go shop and want auto-layout + animated SVG + a sketch aesthetic from text?** → **D2**.
4. **You're laying out a graph with thousands of nodes and need automatic positioning?** → **Graphviz** (specifically `sfdp`). Wrap with viz-js if you need browser rendering.
5. **The diagram lives inside a LaTeX document or you need print-quality typesetting?** → **TikZ**. Static, no shortcuts.
6. **You want a single-file, license-free embedded C diagram engine in your doc tooling?** → **Pikchr**.
7. **Cloud architecture diagram with vendor icons (any cloud)?** → **mingrammer/diagrams**.
8. **AWS-only architecture diagram from a CloudFormation template?** → **awslabs/diagram-as-code**.
9. **C4 model with multiple views from one source?** → **Structurizr DSL** (canonical) · **LikeC4** (interactive web + AI/MCP integration) · **goa.design/model** (Go-native).
10. **Mathematical figures with constraint-based auto-layout?** → **Penrose**. Uncontested.
11. **Database schema as code with auto-rendered ERD?** → **DBML**. **Azimutt** for legacy DB introspection on top.
12. **Cascading project / personal timeline?** → **Markwhen**. (Mermaid gantt for plain project plans.)
13. **Digital timing diagram (signals, bit fields)?** → **WaveDrom**. Uncontested.
14. **Wiring harness with BOM?** → **WireViz**. Uncontested.
15. **Byte field / protocol-frame diagram (IETF-RFC style)?** → **bytefield-svg** or LaTeX `bytefield`.
16. **Telecom-style Message Sequence Charts (MSC / Xù / MsGenny)?** → **mscgen_js**.
17. **BPMN business process?** → **bpmn-js**.
18. **Hand-drawn aesthetic, sketch-like?** → **Excalidraw** (GUI-positioned with JSON wire) or **D2 sketch mode** (auto-layout).
19. **You want to defer the DSL choice and render server-side?** → **Kroki**.
20. **Output medium is the terminal / a markdown code block?** → **D2** (≥0.7.1) for general DSL→ASCII, **PlantUML -ttxt** for sequence ASCII, **Graphviz -Tascii** for graph ASCII, **svgbob** for ASCII-sketch→SVG.

## Leaderboard

Ranking by *fitness for general diagrams-as-code use* (broad applicability, maintenance, ecosystem reach). Domain-specific tools are not directly comparable on this axis — they're best-in-class for their niches. ASCII renderers are scored separately.

### Mainstream, general-purpose

1. **🥇 [Mermaid](#mermaid)** — 87.7k★, MIT, 25+ diagram types, native rendering on every major doc platform. The default choice for new projects unless a specific reason rules it out.
2. **🥈 [D2](#d2)** — 23.6k★, MPL-2.0, modern aesthetic, three layout engines, animated SVG, ASCII export. Strong second when aesthetic matters.
3. **🥉 [PlantUML](#plantuml)** — ~13k★, multi-licensed, deepest UML breadth (~25 types), the only tool with archimate / salt / EBNF support. Senior of the space; pick for UML-heavy work.
4. **[Graphviz / DOT](#graphviz--dot)** — 1.4k GitLab★, EPL-2.0, the layout substrate underneath much of the rest. Pick directly only when you need raw graph layout (large graphs, custom higher-level tools).
5. **[LaTeX / TikZ](#latex--tikz)** — 1.3k★, LPPL/GPL/GFDL, precision typesetting. Pick when print-quality and TeX-math integration are non-negotiable.
6. **[Pikchr](#pikchr)** — 148★ (mirror), 0BSD, single-file C, zero attack surface. Effective install base massively understated by GitHub stars (powers SQLite + Fossil docs).

### Domain-specific

- **Cloud architecture (general):** 🥇 [mingrammer/diagrams](#cloud-architecture--mingrammerdiagrams) (42.2k★, no peer for cross-cloud)
- **Cloud architecture (AWS, CFN-aware):** 🥇 [awslabs/diagram-as-code](#cloud-architecture-aws--awslabsdiagram-as-code) (1.5k★, AWS-official)
- **C4 model:** 🥇 [Structurizr](#c4-model--structurizr) (1.4k★, canonical/JAR-based) · 🥈 [LikeC4](#c4-model--likec4) (3.1k★, interactive + MCP for AI agents) · 🥉 [goa.design/model](#c4-model--goadesignmodel) (459★, Go-native)
- **Mathematical notation (constraint-laid-out):** 🥇 [Penrose](#mathematical-notation--penrose) (7.9k★, uncontested)
- **Database schema:** 🥇 [DBML](#database-schema--dbml) (3.6k★, the de-facto DB-as-code standard) · 🥈 [Azimutt](#database-exploration--azimutt) (2.1k★, legacy-DB-friendly + AML)
- **Timelines:** 🥇 [Markwhen](#timelines--markwhen) (4.8k★, narrative timelines) · Mermaid gantt for plain project plans
- **Hardware timing:** 🥇 [WaveDrom](#hardware-timing--wavedrom) (3.4k★, uncontested)
- **Wiring harnesses:** 🥇 [WireViz](#wiring-harnesses--wireviz) (5.1k★, uncontested)
- **Byte fields / protocols:** 🥇 [bytefield-svg](#byte-fields--protocols--bytefield-svg) (193★) · LaTeX bytefield (in TikZ ecosystem)
- **Message sequence charts (MSC):** 🥇 [mscgen_js](#message-sequence-charts--mscgen_js) (211★, telecom-flavoured)
- **BPMN:** 🥇 [bpmn-js](#bpmn--bpmn-js) (9.5k★, only mature open option)
- **Tiny UML class:** 🥇 [Nomnoml](#tiny-uml--nomnoml) (2.8k★)
- **Sketch aesthetic:** 🥇 [Excalidraw](#hand-drawn-aesthetic--excalidraw) (122k★, GUI+JSON) · 🥈 D2 sketch mode (auto-layout)
- **Documentation builder:** 🥇 [C4-Builder](#documentation-builder--c4-builder) (620★, stale; LikeC4 is the active successor)
- **Meta-aggregator:** 🥇 [Kroki](#meta-aggregator-kroki) (4.1k★)

### ASCII

- **DSL → ASCII:** 🥇 D2 (modern, broad) · 🥈 Graph::Easy + dot-to-ascii (deepest but Perl/dormant) · 🥉 PlantUML `-ttxt` (sequence-only)
- **ASCII sketch → vector:** 🥇 svgbob · 🥈 ditaa · 🥉 goat
- **Pure-ASCII editors:** 🥇 Asciiflow · 🥈 Diagon · 🥉 venn.nvim
- **Terminal charts:** 🥇 YouPlot · 🥈 plotext · 🥉 asciichart

## Appendix: skipped or stale

- **drawio / [diagrams.net](https://github.com/jgraph/drawio)** — 5.1k★, GUI-first; XML format is text and round-trippable but the project does not accept PRs. Not really a diagrams-as-code tool — adjacent, mention only.
- **[tldraw/tldraw](https://github.com/tldraw/tldraw)** — 46.6k★, **proprietary tldraw license** (production needs a license key), GUI-first infinite-canvas SDK. Like Excalidraw, JSON wire format exists but workflow is mouse-driven. Skipped as the input is GUI, not text.
- **[Eraser.io](https://www.eraser.io)** — closed-source SaaS with a markdown-flavoured DSL for sequence + flow + cloud arch + ER. Commercial; mention only.
- **[Ilograph](https://www.ilograph.com)** — closed-source / commercial. YAML diagrams-as-code with auto-layout and interactive zoom-between-levels. Competes with LikeC4/Structurizr on the "interactive architecture" axis.
- **[diagram.codes](https://www.diagram.codes)**, **[Gleek](https://www.gleek.io)**, **[dbdiagram.io](https://dbdiagram.io)** (DBML's online renderer) — closed-source SaaS frontends; their underlying DSLs are open (DBML) or proprietary. Listed for awareness; not separately scored.
- **[swimlanes.io](https://swimlanes.io)** — free closed-source web sequence-diagram tool with simple DSL. Not OSS itself; community wrapper [`verkstedt/swimlanes`](https://github.com/verkstedt/swimlanes) handles round-trip with text files.
- **blockdiag family** — [blockdiag/blockdiag](https://github.com/blockdiag/blockdiag) + seqdiag/actdiag/nwdiag, 240★, Python single-purpose DSLs. Active mostly pre-2020; superseded by mermaid/d2 for new projects.
- **vega / vega-lite** — [vega/vega](https://github.com/vega/vega), 11.9k★, JSON visualisation grammar. Charts more than diagrams; included in Kroki for dashboard cross-over.
- **mscgen** (the original C tool) — long-stale, last release ~2019; superseded by [mscgen_js](#message-sequence-charts--mscgen_js).
- **[BurntSushi/erd](https://github.com/BurntSushi/erd)** — 1.9k★, Unlicense, Haskell. Stale (last release 2023-05-31). Plain-text ER schema → graphviz render. DBML covers the same use case with ongoing maintenance.
- **[blushft/go-diagrams](https://github.com/blushft/go-diagrams)** — 5.2k★, MIT, last commit 2025-03-22. Go port of mingrammer/diagrams. Active enough to mention but mingrammer remains the canonical Python original; Go port is nice if your toolchain is Go-native.
- **[dmytrostriletskyi/diagrams-as-code](https://github.com/dmytrostriletskyi/diagrams-as-code)** — 392★, MIT, last release 2023-09-12. YAML wrapper around mingrammer/diagrams. Stale; mingrammer/diagrams is the active path.
- **Railroad diagrams** — [bottlecaps.de/rr/ui](https://www.bottlecaps.de/rr/ui/) — niche syntax-diagram generator. One-shot use only.
- **mxgraph** — drawio's predecessor library; superseded.
- **Terrastruct Lite** — folded into D2.
- **figlet / toilet** — banner text, not diagrams. Mention only for completeness.

## Discovery — search queries

The following queries (Google, GitHub topic walks, awesome-list mining) were used to surface the **2026-04-27** additions on top of the existing mainstream coverage:

- `"diagrams as code" awesome list github text-to-diagram tools 2026`
- `text-based diagramming tool DSL alternative to mermaid d2 plantuml 2026`
- `likec4 pikchr penrose diagrams as code architecture`
- `pikchr text diagram language PIC alternative github`
- `penrose diagrams github mathematical text-to-diagram`
- `tldraw computer text-based diagramming "open source" eraser.io alternative`
- `"diagrams as code" obscure niche text-based tools 2026 nwdiag erd dbml`
- `"erd" entity relationship diagram DSL github BurntSushi`
- `dbml dbdiagram github holistics text database diagram`
- `"c4-builder" "ilograph" "diagrams.mingrammer" architecture diagrams github comparison`
- `"go.drawing" OR "GoAT" OR "goat" ascii diagram github svg`
- `"awesome-diagramming" github shubhamgrg04 list of all tools`
- `"awesome-diagrams" robbie-cao github tools list`
- `"markwhen" timeline text-based github gantt mermaid`
- `"azimutt" database diagrams open source github`
- `"diagrams" python golang "diagram-as-code" alternative github obscure 2025`
- `"awesome-diagram-as-code" OR "awesome diagrams-as-code" github topic list`
- `"diagrams.net" OR "drawio" text format JSON YAML diagram-as-code`
- `github "ilograph" OR "tikz-uml" OR "mscgen" newer alternatives 2025 diagram`
- `"mscgen.js" "msc" message sequence chart text diagram github stars`
- `"wireviz" wire harness diagram github text yaml DSL`
- `"bytefield-svg" OR "symbolator" verilog hdl text diagram github`
- `"clikt" OR "kotlin" "DSL" OR "go-structurizr" "structurizr-python" architecture diagrams github`
- `github "diagram language" OR "diagram dsl" 2025 newcomer "open source"`

Awesome-lists walked: [shubhamgrg04/awesome-diagramming](https://github.com/shubhamgrg04/awesome-diagramming), [robbie-cao/awesome-diagrams](https://github.com/robbie-cao/awesome-diagrams), [HariSekhon/Diagrams-as-Code](https://github.com/HariSekhon/Diagrams-as-Code), GitHub topic pages [`diagrams-as-code`](https://github.com/topics/diagrams-as-code) and [`diagram-as-code`](https://github.com/topics/diagram-as-code).

New repos added in this pass: **Pikchr**, **awslabs/diagram-as-code**, **LikeC4**, **goa.design/model**, **Penrose**, **DBML**, **Azimutt**, **Markwhen**, **WireViz**, **bytefield-svg**, **mscgen_js**, **C4-Builder**. Newly noted in the appendix: **tldraw**, **Eraser.io**, **diagram.codes**, **Gleek**, **dbdiagram.io**, **swimlanes.io**, **BurntSushi/erd**, **blushft/go-diagrams**, **dmytrostriletskyi/diagrams-as-code**.

---

**Snapshot 2026-04-27.** Submit issues for missing tools, repo updates, or corrections.
