# Library Review Methodology

Generic workflow for systematic review of any library/tool ecosystem.

## Core Principle

Mechanical dimensions come from the **`tools/repo-health-metrics`** CLI (provider APIs: GitHub, GitLab, Codeberg/Forgejo/Gitea, sr.ht). Run it before anything else:

```sh
cd tools/repo-health-metrics && gleam run -- https://github.com/owner/repo --snapshot 2026-09-13
```

Judgement dimensions (README maturity, idiomaticity, feature matrix) still come from the **rendered public web UI** (no clone). Where the tool returns ⬜, visit the repo page and record what is visible; if the page is gated or errors, keep ⬜ and note why.

## Data Sources

0. **`tools/repo-health-metrics` output** — stars, license, target, deps, gleam compat, open issues, latest release, maintenance, age (scored per `practices/formalization.md`)
1. **Repo homepage** — star count, description
2. **Rendered README** — tagline, docs, examples, design intent
3. **Commits page** — date of newest commit, commit density, history span
4. **Issues tab** — open issue count (first page or total shown)
5. Commit count in repo header (if shown)

## Scoring Dimensions

| Dimension | Legend | Signal |
| --- | --- | --- |
| Maintenance | 🟩🟩 actively · 🟩 steady · 🟥 dormant | Latest commit date + frequency across history |
| README quality | 🟩🟩 guide-style · 🟩 clear · 🟥 minimal/broken | Docs maturity; examples; intent clarity |
| Community | ≥10★ = ⭐️ · ≥100★ = ⭐️⭐️ | Star count; fixed thresholds |
| Work (effort) | 🟩🟩 substantial · 🟩 solid · 🟥 minimal | Commit count, history depth, pagination |
| Issues | counts + emoji | Open issue count; health signal |
| Gleam compat | 🟩🟩 latest · 🟩 older · 🟥 incompatible | `gleam` constraint from gleam.toml vs latest stable |

## Review Structure

1. **Snapshot header** — date + "public web UI only"
2. **Legend line** — define emoji scale
3. **Table** — one column per repo, rows = dimensions above
4. **Notes section** — call out edge cases, ⬜ reasons, error notes
5. **Comparison check** — any "head-to-head" docs? Yes/no + brief note

## Scoring Rules

- Use only what the tool output and public pages show (no inference from prior knowledge)
- ⬜ = unknown, not shown, not applicable, or error occurred
- 🟩🟩 = strong signal, 🟩 = OK, 🟥 = negative signal
- Maintenance: ISO date + emoji vs snapshot (🟩🟩 same day/recent, 🟩 months, 🟥 years). Combines recency and frequency into one dimension.
- Work volume: describe pagination or visible span + emoji (🟩🟩 large, 🟩 solid, 🟥 sparse)
- **README maturity:** Full guide-style + examples + API docs = 🟩🟩 (including "batteries-included" frameworks with comprehensive feature docs). Tagline + basic usage = 🟩. Minimal or scaffolding = 🟥.
- **Issues count:** Zero issues = positive signal (note explicitly). High count = possible problems. Balance against maintenance activity (active projects may have more open issues).
- **License:** Record from repo homepage sidebar. Most Gleam ecosystem uses Apache-2.0 or MIT. Weak copyleft (LGPL/MPL) = 🟥 with caveat note for permissive-only shops.
- **Target platform:** Check gleam.toml for `target` field. If absent, infer from dependencies (gleam_erlang/gleam_otp = BEAM, JS adapters = JavaScript). Note whether explicit or inferred.
- **Frozen-mirror repos:** If a GitHub README announces the project has moved to another forge (e.g., Codeberg), score the GitHub repo on its frozen state but flag the move with a `[!CAUTION]` callout. Add a footnote on the leaderboard row noting that Hex/active development continues elsewhere. Do not penalize Hex usability — only the GitHub-visible activity score.
- **Framework-bundled modules:** Sub-libraries shipped inside a framework (not consumable standalone) get scored on the framework's metadata but flagged with a `[!IMPORTANT]` callout and a leaderboard footnote. Pin the dialect/feature description to the bundle's specific scope, not the parent framework's full surface area.
- Ranking: per-category leaderboard using the sum rule in `practices/formalization.md` (🟥 −1 · 🟨 0 · 🟩 1 · 🟩🟩 2); re-rank all rows on every addition

## Running a Review

1. **List repos** to evaluate (semantic group: e.g., "web servers", "logging", "auth")
2. **Run `tools/repo-health-metrics`** on the whole list; paste one table per repo
3. **Visit each repo** for the judgement rows and any ⬜ cells: README, /commits, Issues tab
4. **Capture findings** in table (date, star count, newest commit date, issue count, pagination/history note, README maturity)
5. **Note exceptions** (Issues UI error, no commit history, stub repo, etc.)
6. **Check README** for ecosystem/comparison content
7. **Rank repos** by fit for stated goal (adjust criteria if needed)
8. **Write snapshot** with all findings

## Reusing This Template

- **Goal statement:** "Ranking goal: [e.g., 'library choice for X', 'example quality', 'ecosystem maturity']"
- **Criteria:** Core dimensions above; add domain-specific rows if needed (e.g., "TypeScript support", "WebAssembly binding")
- **Legend:** Reuse 🟩🟩 / 🟩 / ⬜ / 🟥 unless domain-specific scoring makes sense
- **Ranking:** Per-category leaderboards (tools in one category are substitutable; across categories they are not).
