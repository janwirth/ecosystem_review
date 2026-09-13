# Agentic Review Agent

Instructions for automated systematic library/tool review.

## Task

Evaluate a list of libraries/repos in a semantic category (e.g., "web servers", "logging", "auth") and produce a structured review following REVIEW_METHODOLOGY.md.

## Input

User provides:
- **Category/goal** (e.g., "Gleam web servers", "HTTP clients", "test frameworks")
- **List of repos** (GitHub owner/repo format)
- **Goal statement** (what you're ranking for: library choice, example quality, ecosystem maturity, etc.)
- **Optional:** Extra criteria rows beyond the standard six dimensions

## Process

### 0. Fetch mechanical metrics
- Run `cd tools/repo-health-metrics && gleam run -- <url1> <url2> ... --snapshot <DATE>` (add `--json` for machine use). Accepts GitHub, GitLab, Codeberg/Forgejo/Gitea and sr.ht URLs.
- Keep the emitted `| Criterion | repo |` tables verbatim; only the ⬜ cells and the README maturity / Idiomaticity rows are yours to fill.

### 1. Setup
- Print category, goal, snapshot date
- Note: "Data source: `repo-health-metrics` (provider APIs) + public web UI for judgement rows (no clone)"
- Define legend (🟩🟩 strong · 🟩 OK · ⬜ unknown · 🟥 negative)

### 2. For Each Repo

For rows the tool left ⬜ and for the judgement rows, visit in this order (web browser, logged out or public view):

1. **Repo homepage**
   - Read tagline/description
   - Note star count from header or star button area
   - Check for repo image/icon

2. **README** (rendered view on default branch)
   - Read full or summarize from rendered view
   - Note: guide-style vs tagline-only vs minimal
   - Check for examples, API docs, design intent, feature completeness
   - Batteries-included frameworks with comprehensive guides + feature lists = 🟩🟩 (not just 🟩)
   - Look for ecosystem comparison tables (call out separately)

3. **/commits page** (default branch)
   - Find newest commit date (ISO format)
   - Check if paginated or single page
   - Note date span of visible history (e.g., "Jan 2024 to Mar 2026")
   - Describe pagination (e.g., "34 commits per page, 5+ pages" = 🟩🟩, "single page" = 🟥)
   - Estimate total commit count if UI shows it (avoid guessing)

4. **Issues tab**
   - Count open issues visible on first load
   - Note if Issues UI failed (= ⬜)
   - Zero issues = positive signal (note explicitly in Notes section)
   - High count = possible problems (balance against maintenance activity; active projects may have more open issues)

5. **Repo header / other**
   - Commit count badge if present
   - Description/language tags

### 3. Capture in Table

| Dimension | Repo1 | Repo2 | ... |
| --- | --- | --- | --- |
| Open issues | [count] | [count] | ... |
| Stars | [count] | [count] | ... |
| Recently maintained | [ISO date] · [emoji] | [ISO date] · [emoji] | ... |
| Total work | [description] · [emoji] | [description] · [emoji] | ... |
| Activity (recency) | [emoji] | [emoji] | ... |
| README maturity | [emoji] [note] | [emoji] [note] | ... |
| Community (stars) | [emoji] | [emoji] | ... |

### 4. Notes Section

For each repo with ⬜, error, or edge case:
- Call out reason
- Example: "**repo-name**: /commits is empty — project is stub" or "**repo-name**: Issues UI returned 404"

Also call out positive signals:
- Example: "**repo-name**: Zero open issues; robust, current framework with strong maintenance."

### 5. Comparison Check

**One line:** Do any READMEs include a "head-to-head comparison" section or table? (Usually no.)
- If yes, which repo and what does it compare?
- If it's ecosystem context (not tool comparison), note that.

### 6. Ranking

Title: "Ranking (readme + scoring)"

For each repo (1–N, best fit first):

```
N. **[Repo Name](https://github.com/owner/repo)**
   - **README (lead):** [1–2 sentences from README/tagline]
   - **Scores:** activity [emoji] · README [emoji] · stars [emoji] · issues **[count]** · maintenance **[date or unknown]** · work **[short phrase]**
```

**Order:** Best fit for stated goal first. Tie-break: maintenance date + evidence quality.

### 7. Output Format

```
# [Category] Review

**Snapshot [DATE]** — metrics from **`tools/repo-health-metrics`** (provider APIs) + public web pages for judgement rows (no clone).

**Legend:** [emoji definitions]

| Criterion | repo1 | repo2 | ... |
[table]

[Notes section]

[Comparison check]

### Ranking ([goal])

1. [repo + scores]
2. [repo + scores]
...
```

## Constraints

- Use ONLY what `repo-health-metrics` output and public pages show (no git clone, no private data)
- If a page fails to load or is private, mark cell as ⬜ and note the reason
- Do not infer from prior knowledge or memory
- ISO date format (YYYY-MM-DD)
- Emoji must come from legend (no custom symbols)
- README lead: direct quote or close paraphrase, max 2 sentences

## Edge Cases

- **Repo with no commits**: Mark "Total work" 🟥, maintenance date ⬜, README maturity 🟥 (likely scaffold)
- **Issues UI error**: Cell = ⬜, note in section below table
- **Very old last commit**: Compare gap to snapshot date; if >1 year, likely 🟥 maintenance
- **README is just tagline**: Mark 🟩 for clarity, 🟥 for lack of substance (context matters)
- **Multi-language repo**: No penalty if off-topic; describe actual content

## Success Criteria

- ✅ Snapshot date and data source clearly stated
- ✅ Table complete with all repos and dimensions
- ✅ All ⬜ cells explained in notes
- ✅ Ranking is justified (tie-break logic shown)
- ✅ Mechanical rows come from `repo-health-metrics`; no git clones, no non-public data used
- ✅ Emoji consistent with legend
