# Workflow & Quality Standards

## Article Update Standards

When manually editing articles (e.g., adding repos, refreshing data), update workflow files to reflect discovered nuances:

### Data Quality

- **Snapshot dates**: Update article snapshot date when repos are re-evaluated. Use ISO format (YYYY-MM-DD).
- **Exact metrics**: Stars, issue counts, commit dates must come from live GitHub web UI, not inference.
- **Date precision**: Maintenance date uses ISO format + emoji showing recency vs snapshot date (🟩🟩 same day/recent, 🟩 weeks to months, 🟥 years).
- **Activity emoji**: Compare latest commit date to snapshot date. Recent = 🟩🟩, months old = 🟩, years old = 🟥.

### README Assessment

- **Batteries-included frameworks**: Full guide + clear feature list = 🟩🟩 (not just 🟩).
- **Tagline-only**: Just description = 🟩 for clarity, 🟥 if no substance.
- **Adapter patterns**: Lightweight READMEs for single-purpose repos (e.g., "HTTP server for Cowboy") = 🟩 if clear.
- **Example repos**: GitHub-generated templates = 🟩 (shows intent, not execution).

### Issue Tracking

- **Zero issues**: Positive signal. Note explicitly in table and notes section.
- **Unknown issues** (⬜): Page load error or access denied. Document in notes.

### Table Updates

When adding repos:
1. Add to "Repos Reviewed" list (maintain original order or sort by category).
2. Add column to table (right-aligned new repos for easy review).
3. Recalculate all rows (don't assume old emoji rankings still hold relative to new entrant).
4. Update Notes section with new repo's edge cases or highlights.

## Workflow File Updates Trigger

Update `/workflows/` files when articles reveal:

- **New scoring dimension**: E.g., if "zero issues" becomes a strong signal across multiple reviews, add explicit callout in AGENTIC_REVIEW_AGENT.md.
- **New edge case**: E.g., "batteries-included framework README" wasn't differentiated before glimr. Document in REVIEW_METHODOLOGY.md under README assessment.
- **New checklist item**: If manual review surfaced a missed step, add to REVIEW_CHECKLIST.md.

### Example: Glimr Addition (2026-04-13)

Added `glimr-org/glimr` to Gleam Web Frameworks article. Insights:

- **README 🟩🟩 signal**: "Batteries-included framework" with comprehensive guide → refined README maturity assessment in workflows.
- **Zero issues signal**: Noted explicitly; considered positive maintenance/quality signal beyond just activity date.
- **Snapshot date bump**: Moved from 2026-03-22 to 2026-04-13. Workflow reminder: snapshot date is not "creation date" but "evaluation date".

### Example: shork + glimr db Addition (2026-04-26)

Added `ninanomenon/shork` (MySQL driver) and `glimr-org/framework/src/glimr/db` (framework-bundled DB layer) to Gleam Databases article. Insights:

- **Frozen-mirror edge case**: shork's README announces the project moved to Codeberg; the GitHub repo is now a stale mirror. Decision: score the GitHub repo on its frozen state, add a `[!CAUTION]` callout, and footnote the leaderboard row. Codified in REVIEW_METHODOLOGY.md.
- **Framework-bundled modules**: glimr's `db` module is the closest thing to an ORM in Gleam, but only consumable inside a glimr application. Decision: include in leaderboard with a `†` footnote flagging it as framework-bundled (not standalone), retain framework metadata for scoring. Codified in REVIEW_METHODOLOGY.md.
- **New dialect icon**: Adding a MySQL driver triggered extending the dialect legend (🐘 / 🪶 / 🐬). Updated cake (now 🐘🪶🐬) and sqlode (now 🐘🪶🐬) inline tables to reflect the third dialect they already support.
- **Disabled Issues tab**: shork's GitHub Issues UI is disabled (issue tracking happens on Codeberg). Marked as ⬜ in the issues row with explanatory note — distinct from "0 open" (positive signal).
- **Capped gleam_stdlib**: shork's `< 1.0.0` cap mirrors the migrant disregard reason. Did not disregard shork because (a) user asked to add it, (b) cake/sqlode wire to it as the canonical MySQL backend; instead flagged the cap as 🟥 in compat row and called it out in the leaderboard summary.

### Example: Parsers & Generators Article (2026-04-26)

Created `gleam/parsers-and-generators.md` covering issue #3, merging two prior OpenAPI articles into it. Insights:

- **Article merge pattern**: When sub-todos explicitly authorise it, merge narrowly-scoped articles into a broader one rather than keeping separate stubs. Preserve **all** substantive content (feature tables, code examples, gap analyses) — fold them into appropriately-scoped sub-sections of the new article. Delete the old files and update every cross-link in the codebase.
- **Multi-category leaderboard**: When an article spans heterogeneous tool classes (e.g., parser combinators vs SQL→Gleam codegen), produce **per-category leaderboards** rather than one ranking. The 7-dim score is comparable within a class, not across (a SQL codegen with 600★ shouldn't dominate the parser-combinator winner with 80★ purely on community size).
- **Cross-reference instead of duplicate**: For repos already deeply covered elsewhere (e.g., squirrel/sqlode in `databases.md#sql-code-generators`), link to the existing entry rather than re-listing the full table. Use the cross-link pattern `[squirrel](databases.md#squirrel-)` (note the trailing `-` because the source heading is `#### squirrel 🐘`).
- **Cross-link role disambiguation**: When the same repo class fits two articles (e.g., per-language lexers fit both `syntax-highlighting.md` and a parsers article), pick the **role-defining** article and have the other cross-link with a one-sentence note explaining the role-difference ("parsing for AST/analysis" vs "tokenising for colourisation"). Don't duplicate.
- **Renamed/redirected repos**: `daniellionel01/sqlc-gen-gleam` redirects to `daniellionel01/parrot` (renamed). Use the **current** repo URL in the article, mention the prior name in prose (`"renamed from sqlc-gen-gleam"`), so readers find it from either name.
- **Self-hosted Git hosts gated by Anubis** (e.g., liten.app/krig/mork): WebFetch returns the access-denied page. Mark stars/license/dates as ⬜ with a note. Don't disregard — the package still exists on Hex.
- **Unknown licenses**: When repo sidebar/LICENSE doesn't render via WebFetch but the project is real, score as 🟨 unknown (not 🟥) and add a footnote inviting the reader to check directly. Don't pretend to know.

### Example: Parsers & Generators folder split (2026-04-26)

Split `gleam/parsers-and-generators.md` into a folder `gleam/parsers-and-generators/` with sub-articles `parse.md`, `decode.md`, `generate.md`, `serialize.md`, plus a `README.md` index. Insights:

- **Operation-axis split**: When a single article spans heterogeneous operation classes (parse vs decode vs emit-code vs encode), splitting by **operation** (what the tool *does*) rather than by **input type** (what it *consumes*) keeps each sub-article internally consistent. The runtime-vs-build-time and structure-extraction-vs-emission axes naturally produce four files.
- **Per-article discovery**: Each sub-article gets its own Discovery section listing the packages.gleam.run search queries used for *that operation*. Different operations have different keyword surface (e.g. `decode` is mostly silent on `parser`, `generate` needs `codegen` + `swagger` + `protobuf`). Snapshot date repeated per file.
- **Cross-cutting themes via shared README**: When sub-articles share a rubric (the 7-dim score), document the rubric in the folder `README.md` once and link from each sub-article via `[How scores are calculated →](README.md#scoring-rubric-shared)`. Avoids duplicating the legend across 4 files.
- **OpenAPI spans three files**: `parse.md` (oas reads specs), `generate.md` (oaspec/gilly emit Gleam), `serialize.md` (Gleam→OpenAPI gap). Cross-link aggressively rather than duplicating; use anchor links like `[oaspec](generate.md#oaspec)` from neighbouring files in the same folder.
- **Cross-language framing for context, not for review**: When users explicitly ask for "other languages" framing, add a *Cross-language framing* section comparing approaches (serde / Jason / encoding-json / pydantic / utoipa) but do **not** score those tools. The article remains Gleam-scoped; the framing is for contextual orientation.
- **Per-format packages, per-direction sub-articles**: JSON / CBOR / Protobuf packages tend to bundle encode + decode in one library. The split-by-direction sub-articles cross-link to each other for the inverse side rather than re-listing packages. `decode.md` lists `gleam_json`; `serialize.md` cross-links with a note that the encoder is the same package.
- **Gap framing**: The Gleam→OpenAPI gap moves to `serialize.md` because it's about emitting a *spec document*, which is structurally a serialization (typed value → output document) rather than a code generation (input → emitted source). Surface it loudly with `[!IMPORTANT]` callouts in both `serialize.md` and the folder `README.md`.

### Example: Parsers & Generators folder unsplit + reaxis (2026-05-07)

Refactored `gleam/parsers-and-generators/` (4 files: `parse.md`, `decode.md`, `generate.md`, `serialize.md`, plus `README.md` index) into 3 articles directly in `gleam/`:

- `gleam/parse-and-generate-gleam.md` — Gleam source parsers (glance, glance_printer) + Gleam-emitting Gleam DSLs (gleamgen, trick, glue, derived).
- `gleam/parse-and-generate-other-languages.md` — parser combinators, format parsers, HTML, OpenAPI parser (oas), X→Gleam codegen (squirrel/parrot/marmot/sqlode/oaspec/gilly/oas_generator/squall/embeds), gRPC/Protobuf gap.
- `gleam/serialize-and-deserialize.md` — encoder/decoder convention, hand-written ser/deser, per-format packages, JSON Schema/Patch/RPC, bidirectional schemas, codegen for ser/deser (json_typedef, gserde, glerd_json, derived, aide_generator), Gleam→OpenAPI gap.

Insights worth codifying:

- **Folder split-by-operation can over-fragment**: The previous 4-file split (parse / decode / generate / serialize) cut along orthogonal axes (runtime vs build-time, structure-extraction vs structure-emission) that didn't cleanly partition the package landscape. Tools showed up in 2-3 sub-articles via cross-links because the axes overlapped. Re-axising by **whose language is being parsed/generated** (Gleam vs other) plus a separate ser/deser article produced cleaner per-article scope and fewer cross-cuts.
- **Articles directly in topic folder beats sub-folder index**: When a topic produces 3-4 sibling articles, putting them directly in the topic folder (`gleam/foo.md`, `gleam/bar.md`) is more discoverable than a sub-folder with a README index (`gleam/baz/README.md` + `gleam/baz/foo.md`). The folder/index pattern adds a navigation step without earning it.
- **Shared scoring rubric belongs in the canonical article, not a folder README**: When you delete a folder index, the shared scoring rubric it held has to move. Inline-and-duplicate is wrong; better is to point all sibling articles at the **first article that introduced the rubric** (`databases.md#scoring-dimensions` here) as the canonical source — the rubric is stable across articles, so one citation is enough.
- **Cross-link rewrite during refactor**: Every external article that linked into the old folder needs updating. Search pattern: `parsers-and-generators` (the folder name) catches almost all of them. Don't forget the top-level `README.md`, the `gleam/README.md` index, and CLAUDE.md (workflow rules referencing old paths).
- **Snapshot date discipline during refactor**: Re-use the most recent existing snapshot date for content that didn't change, and set the **refactor date** as the snapshot for the merged articles. Mixing 2026-04-26 (old parse.md) and 2026-05-07 (refactor day) in the merged file is a smell — use one date for the article as a whole.

## Future Article Updates

When adding to existing articles or creating new ones:
1. Use current date as snapshot (not article creation date).
2. Follow AGENTIC_REVIEW_AGENT.md process exactly.
3. Capture exact metrics from live GitHub UI.
4. If new repo type or pattern emerges, note in workflows immediately.
5. Re-rank all repos when adding new ones (don't append to old ranking).
6. Update Notes section with summary of any new repos or edge cases.

### Example: Databases article — marmot + parrot + Disregarded hoisted (2026-04-27)

Three changes to `gleam/databases.md`:

- **Add `marmot` (SQLite SQL→Gleam codegen)** — squirrel-inspired, brand new (Apr 2026), 2★, MIT, last commit 4 days before snapshot. Placed under SQL Code Generators (not migrations, not driver).
- **Re-evaluate `parrot` in proper category (SQL Code Generators)** — previously only mentioned in a footnote-style NOTE under MySQL Drivers ("not a driver, worth follow-up"). Now fully scored: 207★, Apache-2.0, sqlc plugin, multi-dialect (PG/SQLite/MySQL). Score **9** (ties with squirrel + sqlight).
- **Hoist `Disregarded` from a sub-subsection at the bottom to a top-level `## Disregarded` section after Research Method.** Rationale: when an article accumulates disregarded packages across multiple categories (was just SQLite migrations, now also `gmysql` from MySQL drivers), keeping them in a leading top-level section makes the negative-signal corner discoverable in one place — readers can immediately see "this corner has been considered, here's what was skipped and why" before drilling into per-category leaderboards.

Insights worth codifying:

- **Repo moving out of disregarded/footnote**: When a repo previously dismissed in a NOTE turns out to be in scope for a different category, **do a full 7-dim review in the right category** — don't half-measure with another note. Update the original location's NOTE to point to the new full review (so search-by-text still finds the breadcrumb).
- **Section reordering rationale (Disregarded at top vs bottom)**: Bottom = "appendix" feel (reader has to know to look). Top = "we considered the corner, this is what's not worth pursuing" (informs the reader before they read recommendations). Top placement is preferred when the disregarded list spans multiple categories. Keep the per-category leaderboards/comparisons clean of dead-end clutter.
- **Cross-article codegen entry consistency**: parrot/marmot are reviewed in **both** `gleam/databases.md#sql-code-generators` (database lens) and `gleam/parse-and-generate-other-languages.md#sql--gleam` (codegen lens). The 7-dim score should match between the two if the underlying metrics haven't drifted; add a `[!NOTE]` callout in the database article cross-linking to the codegen article (and vice-versa) so readers find the matching review either way. Do not duplicate the full code example — let one canonical entry hold the example and have the other cross-link.
- **Tied leaderboard ranks**: When new entrants tie at a score that already has multiple holders (e.g. parrot ties with squirrel + sqlight at 9), use the same award emoji for all (here: 🥈 × 3) and bump the next-ranked entry's position number to match the count above (3 entries at rank 2 → next is rank 5). Don't fudge the math by giving "2nd place" only to the first one read.
