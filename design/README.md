# Design

Reviews of the tools and resources used to design what your software looks like, communicates, and is communicated *about*. Not "visual design" in the brand sense — closer to **how users experience the product**, **how its text is set**, and **how engineers communicate its shape to each other**.

## Articles

- [**AI mascot tools**](ai-mascot-tools.md) — tools, what people make with them, attributed public previews, and shared-budget platforms; no grading.
- [**AI mascot website workflow**](ai-mascot-workflows.md) — brief full flow from design exploration to website images, SVG, or 3D, including the ship-selection process.
- [**UX resources & tools**](ux.md) — curated review of UX (not visual design) resources: Laws of UX, NN/g heuristics + training, dogfooding practice, PostHog instrumentation for behavioural signal, and the BDD/Gherkin connection. For when you have users and need to know whether they're succeeding.
- [**Diagramming tools — cross-ecosystem survey**](diagramming.md) — Mermaid, PlantUML, D2, Graphviz/DOT, LaTeX/TikZ, Kroki, mingrammer/diagrams, Structurizr, WaveDrom, Excalidraw, plus 20+ ASCII renderers and terminal-chart tools. ~40 tools reviewed on the [shared scoring rubric](../practices/formalization.md#scoring-dimensions-per-repo).
- [**Typography — vertical rhythm, type scales, fluid type, leading trim**](typography.md) — the typesetting-mechanics half that `ux.md` excludes: how browsers build a line box (half-leading, font metrics), vertical rhythm with `lh`/`rlh` + `.flow`, what 18 design systems actually ship for type scales, fluid `clamp()` type (Utopia, fluid-tailwind, RFS) and the WCAG 1.4.4 check, Capsize vs `text-box-trim`, metric-matched fallback fonts (fontaine, `next/font`), and what "vertical rhythm reset" means. ~45 tools/repos, reproduced outputs, per-category leaderboards.
- [**Charts — cross-ecosystem survey**](charts.md) — sibling to the diagramming article: charts encode *data*, diagrams encode *structure*. D3 (the foundation), Vega/Vega-Lite/Observable Plot (declarative grammar), Chart.js/ApexCharts/ECharts/Highcharts/Plotly.js/uPlot/Chartist/Frappe Charts/Billboard.js (JS/web), visx/Recharts/Nivo/Victory/react-chartjs-2 (the React-specific layer), and matplotlib/Seaborn/Plotly/Bokeh/Altair/HoloViews/Pygal/Plotnine (Python, including the ggplot2 → Vega-Lite → Altair grammar lineage). ~29 tools reviewed, plus a "Decision guide by use case."

## Related

- [SEO](../marketing/seo.md) & [Analytics](../marketing/analytics.md) — the acquisition + measurement sides; UX converts the traffic that SEO drives.
- [BDD with Gherkin](../practices/bdd-with-gherkin.md) — encoding the expected user flow as executable specifications; downstream of UX research.
