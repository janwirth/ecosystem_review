# Browser automation & testing tools in Gleam

> [!NOTE]
> **Status:** DRAFT · **Authoring:** AI-assisted, human-reviewed.

So you want to drive a real browser from Gleam? Take screenshots, scrape a page, write an end-to-end test, generate a PDF?

The ecosystem is smaller than "web apps" — but there is real tooling here, and one gem worth knowing about.

## Table of Contents

1. [Summary](#summary)
2. [Research Method](#research-method)
   - [Scoring Dimensions](#scoring-dimensions)
   - [Discovery](#discovery)
3. [Categories](#categories)
   - [Chrome DevTools Protocol Clients](#chrome-devtools-protocol-clients) — [chrobot](#chrobot) · [chrobot_extra](#chrobot_extra)
   - [End-to-End Test Frameworks](#end-to-end-test-frameworks) — [luciole](#luciole)
   - [Integration Test Infrastructure](#integration-test-infrastructure) — [testcontainers_gleam](#testcontainers_gleam)
4. [The Puppeteer / Playwright / Selenium Question](#the-puppeteer--playwright--selenium-question)
5. [Leaderboard](#leaderboard)

## Summary

**Snapshot 2026-04-22.** Data sourced from the Gleam package registry, hex.pm, and GitHub web UI — no clone, no API.

The story is simple: **Chrome DevTools Protocol is the only first-class, native Gleam path to a real browser.** Everything else is either (a) a thin bridge that compiles Gleam to JS so an existing JS test runner can consume it, (b) Docker infrastructure for integration tests that happens to be useful alongside browser automation, or (c) something you'd have to build yourself by FFI-calling an Elixir/Erlang library.

| Category | ☎️ BEAM | 📜 JS |
| --- | --- | --- |
| **[Chrome DevTools Protocol Clients](#chrome-devtools-protocol-clients)** | · [🥇](#leaderboard) [chrobot](#chrobot) ([repo](https://github.com/JonasGruenwald/chrobot), 40★) — *typed CDP bindings, Erlang Port, PDF/screenshot/scrape/test*<br>· [chrobot_extra](#chrobot_extra) ([repo](https://github.com/GG-O-BP/chrobot), 1★) — *fork published as a second hex package; adds `gun` WebSocket dep + small CI/logging fixes* | — |
| **[End-to-End Test Frameworks](#end-to-end-test-frameworks)** | — | · [luciole](#luciole) ([repo](https://github.com/steerlab/luciole), 4★) — *write Cypress specs in Gleam; CLI transpiles to JS* |
| **[Integration Test Infrastructure](#integration-test-infrastructure)** | · [testcontainers_gleam](#testcontainers_gleam) ([repo](https://github.com/darky/testcontainers-gleam), 8★) — *Gleam wrapper over Elixir TestContainers; spin up Docker services for tests* | — |

> [!IMPORTANT]
> **No native Puppeteer or Playwright binding exists in Gleam.** No Selenium/WebDriver client either. If you need a browser driven from Gleam today, `chrobot` is the answer. If you need Cypress-style assertions against a deployed app, `luciole` compiles Gleam tests down to JS. Everything else is an FFI project you'd have to write yourself. See [The Puppeteer / Playwright / Selenium Question](#the-puppeteer--playwright--selenium-question) below.

> <details>
> <summary><strong>Dependency Graph</strong></summary>
>
> Arrows read "uses."
>
> **[Chrome DevTools Protocol Clients](#chrome-devtools-protocol-clients):**
> - [chrobot](#chrobot) → Chrome/Chromium (via Erlang Port) → Chrome DevTools Protocol (JSON-over-pipe)
> - [chrobot_extra](#chrobot_extra) → same as chrobot; additionally pulls `gun` (Erlang HTTP/WebSocket client)
>
> **[End-to-End Test Frameworks](#end-to-end-test-frameworks):**
> - [luciole](#luciole) → Gleam (JS target) → custom CLI transpiler → Cypress 14.x spec files → Cypress runtime
>
> **[Integration Test Infrastructure](#integration-test-infrastructure):**
> - [testcontainers_gleam](#testcontainers_gleam) → Elixir TestContainers → Docker
>
> </details>

## Research Method

### Scoring Dimensions

- **Stars:** Community adoption signal based on star count. 🟩🟩 = ≥200★, 🟩 = ≥100★, 🟨 = ≥10★, 🟥 = <10★. *Example: 40★ → 🟨; 1★ → 🟥.*
- **License:** Whether the license allows unrestricted commercial use. 🟩 = permissive OSS (MIT, Apache-2.0, BSD). 🟥 = viral (GPL, AGPL) or no license. Only one tier — permissive or not. *Example: luciole has no LICENSE file in-repo but hex.pm declares MIT → 🟩 with caveat.*
- **Gleam compat:** Checks `gleam_stdlib` version constraint format in `gleam.toml` `[dependencies]`. 🟩 = range constraint (`>= X and < Y`), 🟥 = non-range constraint (`~>` style) which can cause resolver conflicts during install.
- **Maintenance:** Two-level scoring. Final score = **max(recency, responsiveness)**. **Level 1 — Recency:** last commit relative to snapshot. 🟩🟩 = <1 month, 🟩 = <6 months, 🟨 = <1 year, 🟥 = >1 year. **Level 2 — Responsiveness:** time for repo owner to reply to issues or update PRs. Clean tracker (0 open PRs/issues) = 🟩🟩 *only if* project is otherwise active — a stalled repo with an empty tracker is still 🟨/🟥.
- **Age:** Time from first visible commit to snapshot date. 🟩🟩 = ≥3 years, 🟩 = ≥1 year, 🟨 = ≥3 months, 🟥 = <3 months.
- **README maturity:** 🟩🟩 = guide-style with examples, full feature docs, and getting-started instructions. 🟩 = clear description and basic usage. 🟥 = minimal, broken, or missing.
- **Idiomaticity:** Whether the project follows Gleam's principles: typed, sound, explicit, no magic. 🟩 = idiomatic (explicit APIs, explicit codegen steps, builder patterns). 🟥 = magic directives, implicit behavior, or template languages that extract code from non-Gleam sources.

**Leaderboard scoring:** 🟥 = −1, 🟨 = 0, 🟩 = 1, 🟩🟩 = 2. Sum of all 7 dimensions. Max possible = 13.

### Discovery

Searched the [Gleam package registry](https://packages.gleam.run/) across: `browser`, `puppeteer`, `playwright`, `selenium`, `chrome`, `headless`, `cypress`, `webdriver`, `e2e`, `test`, `integration`, `automation`, `scrape`. Cross-checked against [awesome-gleam](https://github.com/gleam-lang/awesome-gleam) (Testing section) and GitHub topic searches.

**4 repos included** (see [Categories](#categories)). A few related-but-out-of-scope names are noted below for completeness.

> <details>
> <summary>Out of scope — different problem</summary>
>
> - **[darky/gleam-puppeteer](https://github.com/) / any "gleam puppeteer" binding** — *does not exist at snapshot.* Registry search for `puppeteer` returns zero packages. GitHub search surfaces only unrelated projects using "gleam" as a product name (the giveaway site `gleam.io`), not the language.
> - **[presentable_soup](https://hex.pm/packages/presentable_soup)** — HTML querying/parsing, billed as "good for snapshot testing too." Useful *downstream* of a scrape (parse the HTML Chrobot dumped) but not a browser driver itself. Belongs in an HTML-parsing review, not this one.
> - **[scrapbook](https://hex.pm/packages/scrapbook)** — Scrapes Facebook specifically. Niche, not a general browser driver.
> - **[gleeunit](https://hexdocs.pm/gleeunit/), [birdie](https://hexdocs.pm/birdie/), [unitest](https://hexdocs.pm/unitest/)** — Unit/snapshot test runners. Don't drive browsers. Out of scope for *browser* testing.
>
> </details>

## Categories

### Chrome DevTools Protocol Clients

A native Gleam interface to Chrome/Chromium. Launch a real (headless or headed) browser, drive it over CDP, take screenshots, scrape DOM, generate PDFs, run integration tests.

| Criterion | [chrobot](https://github.com/JonasGruenwald/chrobot) [🥇](#leaderboard) | [chrobot_extra](https://github.com/GG-O-BP/chrobot) |
| --- | --- | --- |
| Stars | 40★ · 🟨 | 1★ · 🟥 |
| License | MIT · 🟩 | MIT · 🟩 |
| Target | ☎️ BEAM (Erlang Port to Chrome) | ☎️ BEAM (Erlang Port to Chrome) |
| Deps | 11 | 12 (adds `gun`) |
| Gleam compat | `>= 0.49 and < 2.0` · 🟩 | `>= 0.49 and < 2.0` · 🟩 |
| Maintenance | 🟩 (last commit 2026-03-24) | 🟩 (last commit 2026-03-20) |
| Age | ~1.9 years (Jun 2024) · 🟩 | ~1.9 years (Jun 2024, inherited from upstream) · 🟩 |
| README maturity | 🟩🟩 (guide, 4 worked examples, setup, CI notes) | 🟩🟩 (identical to upstream) |
| Idiomaticity | 🟩 (typed codegen from official CDP JSON spec) | 🟩 (inherits upstream design) |
| | | |
| **Features** | | |
| CDP coverage | ✅ (full protocol bindings generated from stable JSON spec) | ✅ (same) |
| Launch managed browser | ✅ (`chrobot.launch`) | ✅ |
| System Chrome fallback | ✅ | ✅ |
| Bundled Chrome installer | ✅ (`gleam run -m chrobot/install`) | ✅ |
| Screenshots | ✅ | ✅ |
| PDF generation | ✅ | ✅ |
| DOM selection / input | ✅ (`await_selector`, typing, clicking) | ✅ |
| WebSocket CDP transport | — (uses Erlang Port / stdio) | ⚠️ (adds `gun` dep; transport details not documented in fork README) |
| CI (GitHub Actions recipe) | ✅ (documented) | ✅ (documented) |

#### chrobot
[repo](https://github.com/JonasGruenwald/chrobot) · [🥇](#leaderboard)

> ⛭ Typed browser automation for the BEAM ⛭

Chrobot is the answer to "how do I drive Chrome from Gleam." It generates typed Gleam bindings from the stable Chrome DevTools Protocol JSON spec (so the full protocol surface is type-checked), then wraps them with higher-level helpers — `launch`, `open`, `await_selector`, `screenshot`, `to_file`. Under the hood it manages a Chrome subprocess via an Erlang Port and pipes CDP JSON messages back and forth.

Use it for: PDF generation from HTML, web scraping, archiving, browser integration tests. Installation is flexible — system Chrome, a bundled `chrome-for-testing` installer (`gleam run -m chrobot/install`), or the `browser-actions/setup-chrome` GitHub Action with `CHROBOT_BROWSER_PATH`.

The author flags the generated CDP bindings as "largely untested" and the package as experimental. Translation: the high-level surface (screenshots, PDFs, simple scraping) works and is the happy path; the deep protocol surface is theoretically covered but you may be the first person to exercise a given call. 5 open issues, all planning/discussion/enhancement — no bug backlog. 3,507 hex downloads, steady commit cadence since June 2024.

```gleam
import chrobot

pub fn main() {
  let assert Ok(browser) = chrobot.launch()
  let assert Ok(page) =
    browser
    |> chrobot.open("https://gleam.run", 30_000)
  let assert Ok(_) = chrobot.await_selector(page, "body")

  let assert Ok(screenshot) = chrobot.screenshot(page)
  let assert Ok(_) = chrobot.to_file(screenshot, "hi_lucy")
  let assert Ok(_) = chrobot.quit(browser)
}
```

#### chrobot_extra
[repo](https://github.com/GG-O-BP/chrobot)

A GitHub fork of `JonasGruenwald/chrobot` that publishes separately to hex.pm as `chrobot_extra` (v5.0.5). Diverges from upstream by ~4 commits at snapshot: string-buffer refactor (fixes upstream issue #20), browser CLI argument pass-through for CI, empty-string env var filtering, and a debug logging env var (`CHROBOT_LOG_LEVEL=info`). Also declares a `gun` dependency (Erlang WebSocket client) that upstream does not — suggesting the maintainer is experimenting with WebSocket CDP transport alongside the existing Port-based path, though the README doesn't document it.

It's effectively "chrobot with a handful of patches the upstream hasn't merged yet." Picks for you: if you hit a specific bug and one of these fixes resolves it, pin to `chrobot_extra`; otherwise use upstream `chrobot` which has the community, the star count, and the canonical name. 1 star, 0 open issues, 201 hex downloads.

```gleam
// API surface is identical to chrobot — same module names, same functions.
// Swap the dependency in gleam.toml:
//   chrobot_extra = ">= 5.0.0 and < 6.0.0"
// and the code above continues to work unchanged.
```

### End-to-End Test Frameworks

Author browser-driven user-flow tests in Gleam source, transpile to a mainstream JS test runner, run under that runner's browser sandbox.

| Criterion | [luciole](https://github.com/steerlab/luciole) |
| --- | --- |
| Stars | 4★ · 🟥 |
| License | MIT (per hex.pm metadata; no LICENSE file in repo) · 🟩 |
| Target | 📜 JavaScript (Cypress-compatible output) |
| Deps | Unknown — no `gleam.toml` at repo root; Gleam API lives under `api/`, CLI under `cli/` |
| Gleam compat | ⬜ (no top-level gleam.toml to read) |
| Maintenance | 🟨 (last commit 2025-08-14, ~8 months before snapshot; 0 issues but no ongoing activity) |
| Age | ~8 months (Aug 2025) · 🟨 |
| README maturity | 🟩🟩 (installation, CLI workflow, naming conventions, valid/invalid syntax examples) |
| Idiomaticity | 🟩 (explicit transpile step — you run a CLI, see the generated Cypress `.cy.js` files) |

#### luciole
[repo](https://github.com/steerlab/luciole)

> Luciole is the french word for firefly, but contrary to other bugs, this one will illuminate the night and help you find bugs in your app.

Write your Cypress specs in Gleam. The `luciole` CLI compiles your Gleam project to JS, rewrites the AST of each compiled test so it matches Cypress's DSL (`cy.visit`, `.should`, `.get`, etc.), and drops the output into a `cypress/` directory that the regular `cypress` runner then picks up.

Requires Node 24+, Gleam 1.9+, Cypress 14+. Tests are identified by the `_cy` suffix on function names. The Gleam API re-exports Cypress primitives (`cypress`, `chain`, `should`, `location`) so your Gleam source reads naturally while the generated JS stays idiomatic Cypress. License is declared MIT on hex.pm but no LICENSE file was committed to the repo at snapshot — safe to assume MIT but worth a PR.

Labelled "Experimentations on Cypress + Gleam" by the author. One maintainer, ~34 commits over 10 days in August 2025, quiet since. Not dead, but not actively evolving either. Good if you're already a Cypress shop and want type safety on your specs; risky if you need a framework with a roadmap.

```gleam
import luciole/cypress as cy
import luciole/should
import luciole/chain

pub fn login_succeeds_cy() {
  cy.visit("/login")
  |> cy.get("input[name=email]")
  |> chain.type_("user@example.com")

  cy.get("input[name=password]")
  |> chain.type_("s3cret")

  cy.get("button[type=submit]")
  |> chain.click()

  cy.location("pathname")
  |> should.equal("/dashboard")
}
```

### Integration Test Infrastructure

Not a browser driver — a Docker container orchestrator for tests that need a real database, cache, or service. Included here because any serious integration test suite (including browser tests against a real backend) needs it, and there's exactly one such library in Gleam.

| Criterion | [testcontainers_gleam](https://github.com/darky/testcontainers-gleam) |
| --- | --- |
| Stars | 8★ · 🟥 |
| License | MIT · 🟩 |
| Target | ☎️ BEAM |
| Deps | 4 (wraps Elixir `testcontainers`) |
| Gleam compat | `>= 0.34 and < 2.0` · 🟩 |
| Maintenance | 🟩🟩 (last commit 2026-02-15, 0 open issues) |
| Age | ~1.9 years (Jun 2024) · 🟩 |
| README maturity | 🟩🟩 (guide with quick-start, builder API, wait strategies, CI troubleshooting) |
| Idiomaticity | 🟩 (builder pattern, explicit `.with_*` configuration) |

#### testcontainers_gleam
[repo](https://github.com/darky/testcontainers-gleam)

Gleam bindings over [Elixir's TestContainers library](https://hex.pm/packages/testcontainers). Start Redis, Postgres, Kafka, or any Docker image as part of a test's setup; stop it at teardown. Exposed via a builder API — `container.new("redis:7.4-alpine") |> container.with_exposed_port(6379) |> container.start()`. Wait strategies include port-ready, log-matches-regex, and exec-command-succeeds.

Not a browser tool, but the natural companion to one: if you're spinning up Chrobot to test an app end-to-end, you probably also want a disposable Postgres for that app to talk to. 8 stars, 0 open issues, active maintenance (last commit 2 months before snapshot).

```gleam
import testcontainers/container

pub fn start_redis() {
  let assert Ok(redis) =
    container.new("redis:7.4-alpine")
    |> container.with_exposed_port(6379)
    |> container.with_wait_strategy(
      container.wait_for_log("Ready to accept connections"),
    )
    |> container.start()

  redis
}
```

## The Puppeteer / Playwright / Selenium Question

This review was commissioned with an explicit sub-task: "ensure we have puppeteer." Here's the honest answer.

### Puppeteer

**No native Gleam binding to Puppeteer exists at snapshot (2026-04-22).**

The Gleam package registry returns zero results for `puppeteer`. GitHub search for `"gleam" "puppeteer"` surfaces only unrelated projects (bots targeting the `gleam.io` giveaway site, which has no connection to the language).

A Gleam-on-Node-target FFI binding is technically feasible — Puppeteer is a Node library, Gleam targets JS, and FFI bindings to Node libraries are well-trodden (see `redraw`, `glen`, `brioche`). But nobody has shipped one. If you need Puppeteer specifically, you have three options:

1. **Write the binding yourself** via Gleam's JS `@external` keyword. Modest project for a narrow surface (launch, new page, goto, screenshot, close).
2. **Call Puppeteer from JS and expose it via a thin Gleam FFI wrapper** — same as option 1, just scoped to what your app actually needs.
3. **Use `chrobot` instead.** Chrobot is effectively "Puppeteer for the BEAM" — it drives Chrome over the same DevTools Protocol, with typed bindings. Same capability envelope, different runtime.

### Playwright

**No binding.** Same story as Puppeteer. Closest adjacent-ecosystem reference is Elixir's [`playwright_ex`](https://elixirforum.com/t/playwright-ex-playwright-client-for-browser-automation/73323), which an adventurous Gleam developer could FFI from a BEAM-target project.

### Selenium / WebDriver

**No binding.** No Gleam WebDriver client, no Selenium client. The BEAM adjacent options are Elixir's [`wallaby`](https://github.com/elixir-wallaby/wallaby), [`hound`](https://github.com/HashNuke/hound), and the lower-level [`web_driver_client`](https://github.com/elixir-wallaby/web_driver_client). Any of these is callable from Gleam via `@external` FFI — but you're writing the binding, the registry won't hand you one.

### Chrome DevTools Protocol

**Yes — `chrobot`.** This is the only native Gleam path to a real browser. Details above under [Chrome DevTools Protocol Clients](#chrome-devtools-protocol-clients).

### Headless browser libraries reachable via BEAM FFI

If you're on the BEAM target and willing to write a small FFI wrapper, the Erlang/Elixir ecosystem offers:

- **[ChromicPDF](https://hex.pm/packages/chromic_pdf)** (Elixir) — HTML-to-PDF via headless Chrome, different approach than Chrobot.
- **[wallaby](https://github.com/elixir-wallaby/wallaby)** (Elixir) — Concurrent browser tests via ChromeDriver.
- **[hound](https://github.com/HashNuke/hound)** (Elixir) — WebDriver-based browser automation.

None have shipped Gleam wrappers. Each would be a small-to-medium FFI project.

### Recommendation

| Your need | Use |
| --- | --- |
| Drive Chrome from Gleam on BEAM (screenshots, PDFs, scraping, integration tests) | **chrobot** |
| Cypress-style E2E specs authored in Gleam | **luciole** |
| Docker services (Postgres, Redis, etc.) for integration tests | **testcontainers_gleam** |
| Firefox/WebKit specifically | None yet — FFI to Elixir `wallaby` or write JS-target Playwright bindings |
| Puppeteer specifically (can't substitute Chrobot) | Write your own FFI on the JS target |
| Classic Selenium/WebDriver grid | FFI to `hound` or `wallaby` |

## Leaderboard

Every contribution here moves the ecosystem forward. This list is sparse on purpose — browser automation in Gleam is a frontier, and showing up at all is the hard part.

**🥇 Gold**

- **chrobot** ([JonasGruenwald](https://github.com/JonasGruenwald)) — Native Gleam browser automation. A genuinely unusual and useful piece of work: typed CDP bindings generated from the official JSON spec, wrapped in ergonomic helpers for screenshots, PDFs, and integration tests. The only "real" browser driver in the Gleam ecosystem at snapshot.

| Position | Award | Repo | ★ | Lic | Compat | Maint | Age | README | Idiom | Score |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 🥇 | [JonasGruenwald/chrobot](https://github.com/JonasGruenwald/chrobot) | 🟨 | 🟩 | 🟩 | 🟩 | 🟩 | 🟩🟩 | 🟩 | **7** |
| 2 | | [darky/testcontainers-gleam](https://github.com/darky/testcontainers-gleam) | 🟥 | 🟩 | 🟩 | 🟩🟩 | 🟩 | 🟩 | 🟩 | **6** |
| 3 | | [GG-O-BP/chrobot](https://github.com/GG-O-BP/chrobot) (`chrobot_extra`) | 🟥 | 🟩 | 🟩 | 🟩 | 🟩 | 🟩🟩 | 🟩 | **6** |
| 4 | | [steerlab/luciole](https://github.com/steerlab/luciole) | 🟥 | 🟩 | ⬜ | 🟨 | 🟨 | 🟩🟩 | 🟩 | **3** |

**Notes:**
- **chrobot** zero bugs in tracker — all 5 open issues are discussion/enhancement. Positive maintenance signal.
- **chrobot_extra** scores equal to upstream on most dimensions but loses on stars and adds no public documentation for its fork-specific changes (the `gun` WebSocket dep in particular is unexplained).
- **luciole** has 0 open issues but quiet since August 2025 — zero-issue signal is ambiguous when the repo is stalled. Scored 🟨 maintenance rather than 🟩🟩. No in-repo LICENSE file (hex.pm declares MIT). No top-level `gleam.toml` so Gleam-compat dimension is ⬜.
- **testcontainers_gleam** included to complete the integration-testing picture; it is not a browser driver and did not compete for 🥇 in that category.

**By target:** ☎️ BEAM **19** (3 repos) · 📜 JS **3** (1 repo). Chrobot and chrobot_extra split the BEAM CDP niche; luciole is the only JS-target entry.

[How scores are calculated →](#scoring-dimensions)
