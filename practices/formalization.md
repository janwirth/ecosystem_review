# Formalization

Criteria, discovery methods, and tooling plan extracted from existing articles in `gleam/` and `openapi/`. Target: automate package search + GitHub metrics + scoring.

## Scoring dimensions (per-repo)

| Dim | Source | Rule |
|---|---|---|
| **Stars** | GitHub API `stargazers_count` | 🟩🟩 ≥200, 🟩 ≥100, 🟨 ≥10, 🟥 <10 |
| **License** | GitHub API `license.spdx_id` | 🟩 MIT/Apache/BSD/Unlicense, 🟥 GPL/AGPL/none |
| **Gleam compat** | `gleam.toml` `[dependencies].gleam_stdlib` | 🟩 `>= X and < Y`, 🟥 `~>` pin or non-range |
| **Maintenance** | `pushed_at` + issue/PR timeline | `max(recency, responsiveness)`. Recency: <1mo 🟩🟩 / <6mo 🟩 / <1yr 🟨 / else 🟥. Responsiveness: owner reply <2d 🟩🟩 / <1wk 🟩 / <1mo 🟨 / else 🟥. 0 open = 🟩🟩 |
| **Age** | `created_at` → first commit | ≥3yr 🟩🟩 / ≥1yr 🟩 / ≥3mo 🟨 / <3mo 🟥 |
| **README maturity** | `README.md` length + section heuristics | 🟩🟩 guide+examples+feature docs, 🟩 tagline+usage, 🟥 minimal/broken. Batteries-included → 🟩🟩; adapter/example → 🟩 |
| **Idiomaticity** | AST scan for magic directives (`///@rpc`, `l-*`), template DSLs | 🟩 explicit codegen / typed, 🟥 implicit wiring / template extraction |
| **Feature completeness** | Category-specific matrix | % of N features supported. Partial = ½. Thresholds 90/60/30 |
| **Ease of use** (tool articles) | Install cmd count + runtime deps | 🟩🟩 one-liner, 🟩 build-step, 🟨 quirks/pins, 🟥 clone+configure |
| **Output quality** (converter articles) | Validator (e.g. `redocly lint`) errors + warnings | lower = better; track both |

**Leaderboard sum:** 🟥 = −1, 🟨 = 0, 🟩 = 1, 🟩🟩 = 2. Max = #dims × 2.

## Metadata to collect (metrics layer)

- **From GitHub API**: stars, license SPDX, `created_at`, `pushed_at`, default branch, `open_issues_count`, open PR count, contributors + commit counts, latest release tag.
- **From issue/PR timeline** (list + event traversal): owner reply latency per thread (ignore bots); ignored-threshold flag if none.
- **From `gleam.toml`**: `gleam_stdlib` constraint string, dep count, target (`erlang`/`javascript`/both), package name (canonical identity — detect aliases like `rawhat/dew` == `mist`).
- **From Hex/packages.gleam.run**: package existence, latest version, description tagline.
- **From README**: word count, heading list, presence of code blocks, link checker (rsvp has broken recipes), feature-list tokens.
- **From source**: test file counts, snapshot-test marker (`birdie`), use of magic annotations.

## Discovery pipeline

1. **Seed keywords** per topic → query `packages.gleam.run/?search=<kw>`.
   - Web apps: `server|backend|frontend|react|web`.
   - Clients: `http|fetch|rest|rpc|client`.
   - Codegen: `openapi`.
   - External-tool articles: web search + GitHub `topic:`/language filter.
2. **Enumerate** package rows → GitHub repo URL (or GitLab/off-GH flag).
3. **Dedupe aliases** (same repo ID, old package name).
4. **Triage filter — disregard reasons** (durable categories):
   - Unmaintained (last commit >1yr, no owner replies)
   - No license (exclude unless noted as caveat)
   - Low traction (<5★ AND <3mo AND no README substance)
   - Superseded (strict subset of another)
   - Out of scope: domain-specific wrappers, wrong direction, aliases, stubs/echo-servers, 3D engines, etc.
5. **Include surviving** set → score each dim.
6. **Build feature matrix** per category (defined up front; rows = capabilities).
7. **Rank** = leaderboard sum; re-rank all on add.
8. **Dependency graph**: parse `gleam.toml` deps of included set to draw "uses" arrows (detect foundations: `http`, `glisten`, `mist`).

## Per-article invariants

- Snapshot date = run date, ISO.
- Activity emoji = diff(snapshot, last-commit): same-day/recent 🟩🟩, weeks–months 🟩, years 🟥.
- Zero-issues = positive signal (note in table).
- ⬜ when access fails.
- Disregarded bucket kept with reason (auditable).

## What differs across articles

- **Gleam-package articles** (`gleam/*.md`): 7–8 core dims, per-category feature matrix, leaderboard.
- **Converter/tool articles** (`openapi/*.md`): add *Ease of use*, *Runtime required*, *Output quality* (validator-run). Leaderboard replaced by "by use case" recommendation table. TL;DR upfront.
- **Both**: Discovery section, Disregarded list with reasons, Dependency graph, Test-setup reproducer (converters only).

## Tooling components to build

1. **Search fetcher** — `packages.gleam.run` scraper + GitHub search by topic/language.
2. **Metadata collector** — GitHub API (stars, dates, license, `open_issues`), repo file fetch (`gleam.toml`, `README.md`).
3. **Responsiveness analyzer** — walk N recent issues/PRs, compute owner-reply latency from timeline events.
4. **`gleam.toml` parser** — extract `gleam_stdlib` constraint, classify range vs `~>`, dep count, target.
5. **Idiom linter** — grep for magic-directive patterns (`/// @rpc`, `l-*`, custom template langs).
6. **Feature-matrix harness** — per-category checklist; hand-coded checks (e.g. converter runner + `redocly lint` parser).
7. **Scorer** — apply thresholds per dim, emit emoji + numeric.
8. **Dedup/alias map** — canonical repo id.
9. **Triage classifier** — apply disregard rules, explain each exclusion.
10. **Renderer** — emit markdown table + leaderboard + disregarded `<details>` block, matching existing article layout.
11. **Dep-graph builder** — union-find over `gleam.toml` deps to produce the `<details>` graph block.
12. **Snapshot diff** — re-run over time; surface changes (new star tier, maintenance decay, new repos to include).

## Suggested build order

1. `gleam.toml` parser + metadata collector (pure data).
2. Scorer (thresholds applied to data).
3. Renderer (markdown matching existing layout).
4. Discovery + triage (expand corpus).
5. Responsiveness analyzer + idiom linter (advanced dims).
6. Snapshot diff (longitudinal).
