# Review Workflows

Agentic workflow for systematic library/tool reviews.

## Files

1. **REVIEW_METHODOLOGY.md** — Principles, scoring dimensions, structure, rules. Read this first to understand the approach.
2. **AGENTIC_REVIEW_AGENT.md** — Full agent instructions. Use to define a Claude agent or prompt for review automation.
3. **REVIEW_CHECKLIST.md** — Quick checklist. Use during a review to stay on track.
4. **`../tools/repo-health-metrics/`** — Gleam CLI that fetches the mechanical dimensions (stars, license, compat, maintenance, age, …) from GitHub / GitLab / Codeberg / sr.ht and emits the per-repo table. Run it first; see its `README.md` and `METHODOLOGY.md`.

## Using These Workflows

### Manual Review (Human)
1. Read REVIEW_METHODOLOGY.md
2. Run `tools/repo-health-metrics` on the repo list
3. Use REVIEW_CHECKLIST.md while visiting repos
3. Follow output format from AGENTIC_REVIEW_AGENT.md

### Automated Review (Agent)
1. Provide the agent with AGENTIC_REVIEW_AGENT.md as system instructions
2. User input: category, repo list, goal statement
3. Agent runs `tools/repo-health-metrics` first, then fills judgement rows from the public web UI

## Template Adaptation

Core workflow is generic. Customize for your domain:

- **Add criteria rows:** Beyond the six standard dimensions, add domain-specific rows (e.g., "TypeScript support", "WASM binding")
- **Adjust legend:** Keep emoji scale; adjust meaning if needed
- **Adjust ranking goal:** Change "best overall fit" to "library choice", "example quality", "ecosystem maturity", etc.
- **Adjust tie-breaks:** E.g., prefer newer over older, higher stars, activity over pure maintenance

## Example

See `../gleam/web-and-http/web-apps.md` for a completed review following this workflow.
