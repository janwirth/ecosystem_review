# Review Checklist

Quick reference for running a systematic review.

## Pre-Review

- [ ] Define category/goal
- [ ] List all repos to review
- [ ] Note snapshot date (today's date)
- [ ] Run `tools/repo-health-metrics` on the full repo list with `--snapshot <date>`; paste one table per repo
- [ ] Confirm: judgement rows from public web UI only (no clone)

## Per-Repo Steps

For each repo in list (fill ⬜ cells and judgement rows; do not re-type what the tool already emitted):

### Homepage
- [ ] Record star count from header
- [ ] Read tagline/description

### README (rendered)
- [ ] Read full or key sections
- [ ] Note maturity: guide-style / clear / minimal
- [ ] Check if batteries-included (full features documented = 🟩🟩, not just 🟩)
- [ ] Scan for examples, docs, API clarity
- [ ] Check for ecosystem/comparison tables

### /commits
- [ ] Find newest commit date (ISO: YYYY-MM-DD)
- [ ] Note pagination (paginated vs single page)
- [ ] Describe history span visible (e.g., "Jan 2024 to Mar 2026")
- [ ] Estimate commit volume from pagination

### Issues Tab
- [ ] Count open issues on first load
- [ ] Note if tab failed to load (= ⬜)
- [ ] Call out zero issues in Notes section (positive signal)

### Scoring
- [ ] Record open issue count
- [ ] Record star count
- [ ] Record license from repo sidebar
- [ ] Record target platform (check gleam.toml `target` field; infer from deps if absent)
- [ ] Record `gleam` version constraint from gleam.toml (🟩🟩 if compatible with latest stable)
- [ ] Calculate maintenance emoji (🟩🟩 = today/recent, 🟩 = months, 🟥 = years)
- [ ] Assign README maturity emoji
- [ ] Assign community emoji (≥10★ = ⭐️, ≥100★ = ⭐️⭐️, below = —)
- [ ] Assign work emoji based on pagination/history span

## Table Construction

- [ ] Create table: repos as columns, dimensions as rows
- [ ] Fill all cells from captured data
- [ ] Mark ⬜ for unknown/error/not applicable
- [ ] Double-check emoji consistency with legend

## Notes & Exceptions

- [ ] List any ⬜ cells with reason
- [ ] Call out stub repos (README = TODO, no commits, etc.)
- [ ] Note any API/page load errors
- [ ] Flag edge cases (very old commits, very new, no history, etc.)

## Comparison Check

- [ ] Search READMEs for "comparison", "vs", "alternatives" sections
- [ ] Note if found (which repo, what it compares)
- [ ] Distinguish: ecosystem context vs tool head-to-head

## Output Validation

- [ ] Snapshot date present and correct
- [ ] Legend clearly defined
- [ ] Table complete (no blank cells unless ⬜)
- [ ] All ⬜ explained in notes
- [ ] Emoji usage matches legend throughout
- [ ] Mechanical rows match `repo-health-metrics` output; no private data
- [ ] No inference from prior knowledge or memory
