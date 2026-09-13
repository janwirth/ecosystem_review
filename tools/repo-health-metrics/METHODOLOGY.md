# Methodology notes

What this tool is for, which parts of the review rubric it covers, and what it
deliberately leaves to a human. Written 2026-09-13 from a read of
`practices/formalization.md`, `workflows/REVIEW_METHODOLOGY.md`,
`workflows/AGENTIC_REVIEW_AGENT.md`, `meta-review.md`, and the per-repo tables
in `gleam/databases.md`.

## The rubric this tool implements

`practices/formalization.md` is the rubric the articles actually use. Its
per-repo dimensions, and where each value comes from:

| Dimension | Source | Rule |
|---|---|---|
| Stars | forge API star count | 🟩🟩 ≥200 · 🟩 ≥100 · 🟨 ≥10 · 🟥 <10 |
| License | forge API SPDX id, or `gleam.toml` `licences` | 🟩 MIT/Apache/BSD/Unlicense · 🟥 anything else, including none declared |
| Gleam compat | `gleam.toml` `[dependencies].gleam_stdlib` | 🟩 a `>= X and < Y` range · 🟥 a `~>` pin, other shape, or any `< 1.0.0` cap |
| Maintenance | last-push/last-activity date vs the snapshot date | 🟩🟩 <1mo · 🟩 <6mo · 🟨 <1yr · 🟥 older |
| Age | repository creation date vs the snapshot date | 🟩🟩 ≥3yr · 🟩 ≥1yr · 🟨 ≥3mo · 🟥 younger |
| README maturity | README length + section heuristics | **human** |
| Idiomaticity | AST/source reading for magic directives | **human** |

Leaderboard weighting, also from `formalization.md`: 🟥 = −1, 🟨 = 0, 🟩 = 1,
🟩🟩 = 2. The tool reports those points per dimension in `--json`; it does not
produce a leaderboard, because two of the seven dimensions are missing by
design and a partial sum would be misread as a total.

The markdown output reproduces the `| Criterion | repo |` shape used in the
articles (see `gleam/databases.md`, the `pog` entry), including the `Target`
and `Deps` rows those tables carry alongside the seven scored dimensions.

## Covered mechanically

- Stars, license, creation date, last-activity date, open issue count, default
  branch, archived flag, latest release or tag.
- `gleam.toml`: the `gleam_stdlib` constraint, the declared `target`, the
  dependency count, and the declared `licences` (used where the forge API has
  no licence field).
- README byte size, reported as a number in the README cell so a human has the
  input in front of them when they grade it.

## Left to a human, on purpose

- **README maturity.** The tool prints the byte count and an ⬜. Length is not
  maturity: `formalization.md` and `REVIEW_METHODOLOGY.md` both grade a
  batteries-included framework's guide 🟩🟩 and a tagline-only adapter README
  🟩, and no byte threshold separates those.
- **Idiomaticity.** Needs source reading for magic directives and template
  DSLs.
- **Maintenance responsiveness.** `formalization.md` defines Maintenance as
  `max(recency, responsiveness)`, where responsiveness is owner reply latency
  across recent issue threads. Only the recency half is implemented. A repo
  whose owner answers every issue in a day but has not pushed in eight months
  will be scored 🟨 here and 🟩🟩 by a human following the rubric.
- **Zero open issues as a positive signal.** `formalization.md` says `0 open =
  🟩🟩` on the Maintenance dimension. The tool reports the count but does not
  apply that promotion, because "0 open" and "the Issues tab is disabled" are
  different facts and only the second is reliably distinguishable per forge
  (Forgejo exposes `has_issues`; GitHub does not expose it in the same shape).
  Where the tool can tell, it says so in the notes.
- **Feature completeness, ease of use, output quality.** Category-specific
  dimensions from `formalization.md`; out of scope for a per-repo fetcher.

## The known contradiction between the two methodology documents

There are two live methodology documents in this repository and they disagree:

- `workflows/REVIEW_METHODOLOGY.md` states, as its Core Principle, *"Use
  **public web UI only** (no API, no clone)"*, defines six dimensions, and ends
  with *"No ranking: present data, let reader decide."*
  `workflows/AGENTIC_REVIEW_AGENT.md` repeats the constraint (*"Use ONLY what
  public pages show (no API, no git clone …)"*) — and then contradicts itself
  by including a numbered `### Ranking` section in its own output template.
- `practices/formalization.md` defines API-shaped dimensions (*"GitHub API
  `stargazers_count`"*, *"GitHub API `license.spdx_id`"*, *"`pushed_at`"*,
  *"`created_at`"*) and a numeric leaderboard sum.

Every substantive article follows `formalization.md`: `gleam/databases.md`
closes with a medal-emoji leaderboard scoring pog at 10, and its per-repo
tables carry exactly the API-shaped fields. `meta-review.md` already records
this as an open defect ("Two competing, unreconciled methodology docs") and
notes that an API fetcher *"requires updating `workflows/AGENTIC_REVIEW_AGENT.md`'s
'no API' rule first — building it silently would create a second undocumented
methodology divergence."*

**This tool is that API fetcher, so the divergence is now concrete.** It reads
forge REST APIs and raw files; it does not read rendered web pages. Two
consequences a `workflows/` update would need to address:

1. The "no API" rule is what currently protects against fabrication — a browser
   fetch can see "Issues tab returned 404" or an Anubis interstitial, which an
   API client cannot. This tool's substitute is that every unknowable cell is
   ⬜ with a note explaining which call failed; nothing is inferred.
2. The API and the web UI do not always report the same thing. GitLab's
   `last_activity_at` moves on issue and merge-request activity, not only
   pushes, so it can read fresher than the code is. Forgejo's `updated_at` has
   the same caveat. The tool annotates both rather than silently presenting
   them as "last commit".

Resolving the contradiction is a documentation decision for the repo owner, not
something this tool should do unilaterally. Flagged in the final report.

## Providers

Host counts are link counts across all `*.md` in the repository, from
`grep -rhoE 'https?://[a-zA-Z0-9._-]+' --include='*.md' .` on 2026-09-13.

| Host | Links | API | Auth needed? | Dimensions fetchable |
|---|---|---|---|---|
| github.com | 1535 | REST v3 (`api.github.com`) | No — 60 req/h anonymous, 5000 with `GITHUB_TOKEN` | All: stars, SPDX licence, `created_at`, `pushed_at`, open issues, default branch, archived, latest release/tag, raw files |
| gitlab.com | 32 | REST v4 (`/api/v4/projects/:enc_path`) | No for public projects, but **`open_issues_count` is null anonymously** | Stars, licence (with `?license=true`), `created_at`, `last_activity_at`, default branch, archived, tags, raw files. Open issues needs `GITLAB_TOKEN` |
| codeberg.org | 21 | Forgejo/Gitea API v1 (`/api/v1/repos/:owner/:repo`) | No | Stars, `created_at`, `updated_at`, open issues, `has_issues`, default branch, archived, tags, raw files. **No licence field** — read from `gleam.toml` |
| git.sr.ht | 5 | GraphQL at `/query` | **Yes** — anonymous calls get `ERR_UNAUTHORIZED`; there is no legacy REST (`/api/~user/repos/x` → 404) | With `SRHT_TOKEN`: `created`, `updated`, `visibility`. Without: last commit date from the public RSS log, plus raw files from `/blob/`. Stars and issues never — see below |
| git.liten.app | 1 | Gitea 1.22 (`/api/v1/…`) | No | Same as Codeberg. **The API is not gated** — see correction below |
| gitea.attum.co | 1 | would be Gitea | — | **Host is gone**: DNS resolution fails (`nxdomain`). All ⬜ |
| git.ahlcode.fi | 1 | unknown | — | **Anubis-gated, including `/api/v1/version`**, which returns an HTML "Checking access…" page. All ⬜ |
| gitlab.gnome.org | 1 | GitLab REST v4 | No | Same as gitlab.com; handled by the `gitlab.*` host rule |
| code.qt.io | mentioned in prose | Gerrit | — | Not implemented; no link in the corpus to resolve |

### Correction: liten.app is not API-gated

`CLAUDE.md` records liten.app under *"Self-hosted Git hosts gated by Anubis …
Mark stars/license/dates as ⬜"*, and
`gleam/parse-and-generate-other-languages.md` marks `mork` as
"⬜ (self-hosted)". That is true of the **web UI**, which is what WebFetch sees.
It is not true of the **API**: `https://git.liten.app/api/v1/version` returns
`{"version":"16.0.4+gitea-1.22.0"}` to an anonymous caller, and the repository,
tag and raw-file endpoints all answer normally. Running this tool against
`https://git.liten.app/krig/mork` fills every cell that is ⬜ in the article
today. Anubis gates browsers, not API clients — worth checking the API before
marking any self-hosted forge unknowable.

`git.ahlcode.fi` is the counter-example: there, Anubis fronts `/api/v1/` too,
so ⬜ is correct and the tool reports the probe failure as a note.

### SourceHut is structurally different

Two dimensions are ⬜ on sr.ht **by construction**, not by access failure:

- **Stars.** SourceHut has no starring feature. A ⬜ here is not a low score.
  `gleam/web-and-http/ui-development.md` already makes this point in prose
  ("Sourcehut-hosted, so star count understates it").
- **Open issues.** Tickets live on todo.sr.ht as a separate service keyed by
  tracker name, not by repository. There is nothing to count on git.sr.ht.

Also: the GraphQL `Query` type has no lookup by owner and name. The only route
to another user's repository is `user(username:)` → `repository(name:)`; the
top-level `repositories` field returns only the authenticated user's own repos,
and `repository(rid:)` needs an internal numeric id. The tool uses the
`user → repository` path when `SRHT_TOKEN` is set.

## Snapshot dates

`--snapshot` defaults to today and is read as midnight UTC, so recency is
measured in whole days. Per `formalization.md`, the snapshot date is the
*evaluation* date, not the article's creation date; pass the article's date
explicitly when re-deriving an existing table so the emoji match what was
published.

## The `< 1.0.0` stdlib cap — rule reconciled (2026-09-13)

`formalization.md`'s Gleam-compat rule used to be purely structural (🟩 for any
`>= X and < Y` range), while `CLAUDE.md` records four separate times
(carpenter/glemo, bravo, deriv, shork/migrant) that a `< 1.0.0` cap on
`gleam_stdlib` must score 🟥 and be reproduced. `practices/formalization.md`
now carries that carve-out explicitly, and the tool implements it: any
`gleam_stdlib` constraint whose upper bound is `< 1.0…` scores 🟥 regardless of
range shape. The reproduction step (fresh `gleam new` + `gleam add`) is still
manual — the tool flags, it does not prove.
