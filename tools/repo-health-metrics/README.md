# repo-health-metrics

Fetches the mechanically-fetchable repo-health dimensions from a git forge and
prints them either as the `| Criterion | repo |` table the articles in this
repository use, or as JSON.

Its whole job is the fetching. It does not discover packages, does not rank
anything, and does not grade the two dimensions that need a human to read the
project — see [What it does not do](#what-it-does-not-do).

The scoring thresholds come from
[`practices/formalization.md`](../../practices/formalization.md). Where those
thresholds came from, and which parts of the rubric are left to a human, is in
[METHODOLOGY.md](METHODOLOGY.md).

## Usage

```sh
gleam run -- <repo>... [--json] [--snapshot YYYY-MM-DD] [--forgejo HOST]
```

`<repo>` is either a full URL, from which the provider is detected by host, or a
bare `owner/repo`, which is assumed to be on GitHub. Pass several to get one
column per repository in a single table.

```sh
gleam run -- lpil/pog
gleam run -- https://codeberg.org/ninanonemon/shork --snapshot 2026-04-27
gleam run -- lpil/pog lpil/sqlight giacomocavalieri/squirrel --json
gleam run -- https://git.example.org/owner/repo --forgejo git.example.org
```

| Flag | Effect |
|---|---|
| `--json` | Emit JSON instead of the markdown table. Includes a per-dimension emoji and its leaderboard points. |
| `--snapshot YYYY-MM-DD` | Measure recency against this date instead of today. Use the article's snapshot date when re-deriving a published table. |
| `--forgejo HOST` | Treat `HOST` as a Forgejo/Gitea instance without probing it first. Repeatable. |
| `--help` | Print usage. |

### Example

```
$ gleam run -- https://github.com/lpil/pog --snapshot 2026-09-13

| Criterion | [lpil/pog](https://github.com/lpil/pog) |
| --- | --- |
| Stars | 264★ · 🟩🟩 |
| License | Apache-2.0 · 🟩 |
| Target | ⬜ (no `target` in gleam.toml) |
| Deps | 6 |
| Gleam compat | `>= 0.51.0 and < 2.0.0` · 🟩 |
| Open issues | 19 |
| Latest release | v4.1.0 |
| Maintenance | 🟨 (last activity 2026-03-09, ~6mo before 2026-09-13) |
| Age | 🟩🟩 (~6y, created 2019-11-17) |
| README maturity | ⬜ (human judgement — README is 7594 bytes) |
| Idiomaticity | ⬜ (human judgement) |
```

Any cell the tool could not determine is `⬜`, and every `⬜` that is not
inherent to the provider gets a bullet under the table saying which call
failed. A repository that cannot be reached at all produces an all-`⬜` column
and a note; it does not abort the run.

## Environment variables

All optional, except on SourceHut where the API is closed to anonymous callers.

| Variable | Provider | Effect if unset |
|---|---|---|
| `GITHUB_TOKEN` | GitHub | Works; rate limit is 60 requests/hour instead of 5000. Each repository costs 3–4 requests. |
| `GITLAB_TOKEN` | GitLab | Works, except that `open_issues_count` is withheld from anonymous callers and renders `⬜`. |
| `CODEBERG_TOKEN` | Codeberg and other Forgejo/Gitea hosts | Works. |
| `SRHT_TOKEN` | SourceHut | Falls back to the public RSS commit log for the maintenance date; the creation date becomes `⬜`. |

## Providers

| Host | Provider | API | Notes |
|---|---|---|---|
| `github.com` | GitHub | REST v3 | Every dimension available. |
| `gitlab.com`, any `gitlab.*` host | GitLab | REST v4 | Maintenance uses `last_activity_at`, which also moves on issue and merge-request activity. Open issues need a token. Subgroup paths are supported. |
| `codeberg.org` | Forgejo | API v1 | No licence field on the repository object, so the licence is read from `gleam.toml`. A disabled Issues tab is reported as such, distinct from "0 open". |
| `git.sr.ht` | SourceHut | GraphQL, else RSS + `/blob/` | Stars and open issues are always `⬜` — SourceHut has neither. See METHODOLOGY.md. |
| anything else | probed | Forgejo API v1 | The host is probed once at `/api/v1/version`. If it answers with JSON it is treated as Forgejo/Gitea; otherwise the run reports the probe failure and returns `⬜`. `--forgejo HOST` skips the probe. |

Two hosts referenced in the articles cannot be read: `gitea.attum.co` no longer
resolves, and `git.ahlcode.fi` puts Anubis in front of `/api/v1/` as well as
the web UI. Both produce an all-`⬜` column with the reason in the notes.
`git.liten.app` *looks* gated in a browser but its API is open — see the
correction in METHODOLOGY.md.

## What it does not do

- **No README maturity grade.** It reports the README's byte count and leaves
  the emoji to you. Length is not maturity.
- **No idiomaticity grade.** That needs someone to read the source.
- **No responsiveness.** `formalization.md` defines Maintenance as
  `max(recency, responsiveness)`; only recency is implemented, so a slow-pushing
  but fast-replying maintainer scores lower here than a human would score them.
- **No install reproduction.** A `< 1.0.0` `gleam_stdlib` cap scores 🟥 (per `practices/formalization.md`), but the tool does not run `gleam add` to prove the breakage — that step stays manual. See METHODOLOGY.md.
- **No leaderboard.** Two of seven dimensions are missing by design, so any sum
  this tool printed would be a partial one presented as a total. `--json` gives
  you the per-dimension points if you want to add them up yourself.
- **No discovery.** It takes repositories you already have; it does not search
  Hex or packages.gleam.run.
- **No web-UI reading.** It uses forge APIs, which is a deliberate divergence
  from `workflows/AGENTIC_REVIEW_AGENT.md`'s "no API" rule. That contradiction
  is documented, not resolved, in METHODOLOGY.md.
- **No writing.** It prints to stdout. Pasting into an article is your job, and
  so is re-ranking the leaderboard afterwards.

## Development

```sh
gleam build
gleam test    # threshold, gleam.toml and URL-parsing tests; no network
gleam format
```

The tests cover the threshold boundaries from `formalization.md` exactly (199
vs 200 stars, 29 vs 30 days, and so on), so a change to the rubric should start
by changing them.

Layout: one module per provider (`src/rhm/github.gleam`, `gitlab.gleam`,
`forgejo.gleam`, `sourcehut.gleam`), each mapping onto the shared
`rhm/metrics.Metrics` record; `rhm/score.gleam` holds every threshold;
`rhm/render.gleam` holds both output formats.
