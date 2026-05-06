# Testing libraries in Gleam

> [!NOTE]
> **Status:** DRAFT · **Authoring:** AI-assisted, human-reviewed.

You want to test a Gleam project — unit tests, property tests, snapshots, doc tests, maybe a mock HTTP server or a mocked Erlang module.
This article maps out what's available on [packages.gleam.run](https://packages.gleam.run/) and hex at snapshot.

BDD/Gherkin (`dream_test`) has its own cross-ecosystem write-up: see [BDD with Gherkin](../../bdd-with-gherkin.md).
Browser drivers and end-to-end frameworks live in [Browser automation & testing tools](./browser-automation.md).

## Table of Contents

1. [Summary](#summary)
2. [Research Method](#research-method)
   - [Scoring Dimensions](#scoring-dimensions)
   - [Discovery](#discovery)
3. [Categories](#categories)
   - [Unit Test Runners](#unit-test-runners) — [gleeunit](#gleeunit) · [unitest](#unitest) · [startest](#startest) · [showtime](#showtime) · [glacier](#glacier) · [glacier_gleeunit](#glacier_gleeunit)
   - [Property Testing](#property-testing) — [qcheck](#qcheck) · [qcheck_gleeunit_utils](#qcheck_gleeunit_utils)
   - [Snapshot Testing](#snapshot-testing) — [birdie](#birdie) · [drift_record](#drift_record)
   - [Doc Tests](#doc-tests) — [testament](#testament)
   - [Mocking](#mocking) — [mockth](#mockth) · [dream_mock_server](#dream_mock_server)
   - [Programmatic Test Building](#programmatic-test-building) — [testbldr](#testbldr)
   - [Timing & Synchronisation](#timing--synchronisation) — [tickle](#tickle)
   - [Specialised Runners](#specialised-runners) — [exercism_test_runner](#exercism_test_runner)
   - [Adjacent (linked out)](#adjacent-linked-out) — [dream_test](#dream_test) · browser automation
4. [Leaderboard](#leaderboard)

## Summary

**Snapshot 2026-04-24.** The Gleam testing story has one clear default and a handful of well-scoped specialists around it.

- **[gleeunit](#gleeunit)** (lpil) is the canonical unit test runner — what `gleam new` wires up, what every library's test suite uses, actively maintained by the language creator. Most testing in Gleam is gleeunit + `assert`.
- **[birdie](#birdie)** (giacomocavalieri) is the unchallenged snapshot testing library — 192★, best maintained, batteries-included CLI for reviewing new snapshots.
- **[qcheck](#qcheck)** (mooreryan) is the property-testing anchor — QuickCheck-style generators with integrated shrinking, dual-licensed, active.
- **[mockth](#mockth)** (bondiano) wraps Erlang's `meck` for module-level mocking on BEAM.
- **[dream_mock_server](#dream_mock_server)** (TrustBound) gives you a live HTTP mock server for exercising HTTP clients end-to-end.

Alternative unit runners exist — **[unitest](#unitest)** (random order + tags + CLI filtering), **[startest](#startest)** (describe/it API, Vitest-inspired), **[showtime](#showtime)** (gleeunit-compatible surface) — all with smaller followings than gleeunit and varying maintenance. **[glacier](#glacier)** (incremental interactive testing) was archived at snapshot and no longer a live option.

Specialised tools round it out: **[testament](#testament)** for doc tests, **[tickle](#tickle)** for simulating `send_after` delays, **[drift_record](#drift_record)** as a snapshot companion for the `drift` pure-core library, **[testbldr](#testbldr)** for generating test cases from data.

| Category | Lead | Also |
| --- | --- | --- |
| **[Unit runners](#unit-test-runners)** | [🥇](#leaderboard) [gleeunit](#gleeunit) ([repo](https://github.com/lpil/gleeunit), 40★) — *the default; EUnit on BEAM + custom JS runner* | [unitest](#unitest) ([repo](https://github.com/jtdowney/unitest), 4★) · [startest](#startest) ([repo](https://github.com/maxdeviant/startest), 38★) · [showtime](#showtime) ([repo](https://github.com/JohnBjrk/showtime), 26★, dormant) · [glacier](#glacier) ([repo](https://github.com/inoas/glacier), 37★, archived) |
| **[Property testing](#property-testing)** | [🥇](#leaderboard) [qcheck](#qcheck) ([repo](https://github.com/mooreryan/gleam_qcheck), 41★) — *QuickCheck-inspired, integrated shrinking* | [qcheck_gleeunit_utils](#qcheck_gleeunit_utils) |
| **[Snapshot testing](#snapshot-testing)** | [🥇](#leaderboard) [birdie](#birdie) ([repo](https://github.com/giacomocavalieri/birdie), 192★) — *review CLI, diff output, Gleam-native* | [drift_record](#drift_record) *(niche; logs for drift steppers)* |
| **[Doc tests](#doc-tests)** | [testament](#testament) ([repo](https://github.com/bwireman/testament), 8★) — *extract and execute code blocks from docs* | — |
| **[Mocking](#mocking)** | [mockth](#mockth) ([repo](https://github.com/bondiano/mockth), 14★) — *Erlang `meck` wrapper for module mocks* | [dream_mock_server](#dream_mock_server) *(HTTP mock server)* |
| **[Programmatic tests](#programmatic-test-building)** | [testbldr](#testbldr) ([repo](https://github.com/bcpeinhardt/testbldr), 4★) — *build test cases from data/files* | — |
| **[Timing helpers](#timing--synchronisation)** | [tickle](#tickle) ([repo](https://github.com/sbergen/tickle), 0★) — *simulate `process.send_after` in tests* | — |
| **[Specialised runners](#specialised-runners)** | [exercism_test_runner](#exercism_test_runner) ([repo](https://github.com/exercism/gleam-test-runner), 5★) — *Docker runner for Exercism submissions* | — |

> [!NOTE]
> **What `gleam new` gives you.** A new Gleam project ships with a `test/` directory, `gleeunit` as a dev dependency, and `gleam test` wired to EUnit on BEAM. Most Gleam projects never reach outside that default. This article exists for the cases that do — property tests for a parser, snapshot tests for a pretty-printer, a mocked HTTP backend for integration tests, etc.

> [!IMPORTANT]
> **`assert` is a language keyword, not a library.** Modern Gleam (≥1.11) provides `assert` as a built-in statement. There is no standalone assertion library on packages.gleam.run at snapshot because the language covers that surface. Runners that advertise "pretty assertions" (startest, showtime) add matcher sugar on top.

## Research Method

### Scoring Dimensions

Same rubric as [logging.md](../logging.md#scoring-dimensions) and [web-apps.md](../web-and-http/web-apps.md#scoring-dimensions). Recap:

- **Stars:** 🟩🟩 ≥200★, 🟩 ≥100★, 🟨 ≥10★, 🟥 <10★.
- **License:** 🟩 permissive (MIT/Apache/BSD). 🟥 viral or missing.
- **Gleam compat:** `gleam_stdlib` constraint format. 🟩 range (`>= X and < Y`), 🟥 `~>` pin.
- **Maintenance:** max(recency, responsiveness). 🟩🟩 <1 mo / <2 d / clean tracker, 🟩 <6 mo / <1 wk, 🟨 <1 yr / <1 mo, 🟥 older / ignored.
- **Age:** 🟩🟩 ≥3 yrs, 🟩 ≥1 yr, 🟨 ≥3 mo, 🟥 <3 mo.
- **README maturity:** 🟩🟩 full guide + examples, 🟩 clear tagline + usage, 🟥 minimal.
- **Idiomaticity:** 🟩 typed/explicit, 🟥 magic directives or implicit behaviour.

**Leaderboard scoring:** 🟥 = −1, 🟨 = 0, 🟩 = 1, 🟩🟩 = 2. Sum of 7 dimensions. Max = 13.

### Discovery

Discovery query (user-specified): **`test`**. Searched [packages.gleam.run](https://packages.gleam.run/?search=test) and cross-checked [hex.pm](https://hex.pm). Related probe queries used to widen: `mock`, `property`, `snapshot`, `spec`, `coverage`, `assert`.

**17 repos included below.** **7 disregarded** — scope overlaps with sibling articles, niche unrelated purpose, or topic mismatch.

> <details>
> <summary>7 disregarded — scope or topic</summary>
>
> **Covered in [browser automation](./browser-automation.md):**
> - **[steerlab/luciole](https://github.com/steerlab/luciole)** — "API for writing Cypress tests in Gleam." Compiles Gleam specs to Cypress — browser/E2E territory, not Gleam-side unit testing. Reviewed in the sibling article.
>
> **Infrastructure / adjacent to testing:**
> - **[patrik-kuehl/melon](https://hex.pm/packages/melon)** — "A Gleam library for running test containers via Docker." Docker container orchestration for integration tests. The browser-automation article covers [testcontainers_gleam](./browser-automation.md#testcontainers_gleam) for the same shape of need; melon is an alternative wrapper, last published 2024-10-17. Infra, not a test library.
> - **[presentable_soup](https://hex.pm/packages/presentable_soup)** — "HTML parsing … good for snapshot testing too!" Primary purpose is HTML querying; snapshot-testing utility is secondary. Belongs in an HTML-parsing review.
>
> **Covered in [BDD with Gherkin](../../bdd-with-gherkin.md):**
> - **[TrustBound/dream_test](https://github.com/TrustBound/dream_test)** — BDD/Gherkin runner for Gleam. Full review in the sibling article; mentioned briefly [below](#dream_test).
>
> **Topic mismatch:**
> - **[adglent](https://hex.pm/packages/adglent)** — "Advent of Code helper." Scaffolds AoC solution templates; not a general test tool.
> - **[butterbidi](https://hex.pm/packages/butterbidi)** — "Spec-compliant WebDriver BiDi types, decoders and encoders." WebDriver types, not a test runner. Relevant to a future browser-driver binding; not this article.
> - **[klubok_gleam](https://hex.pm/packages/klubok_gleam)** — "Do-notation pipes for functions which easy to mock." A composition primitive that happens to help with mocking; not itself a mocking library.
>
> </details>

## Categories

### Unit Test Runners

Replacements or supplements to `gleam test`'s default. All target gleeunit-shaped test signatures (`*_test` functions returning assertions) except startest which exposes a different describe/it API.

| Criterion | [gleeunit](https://github.com/lpil/gleeunit) [🥇](#leaderboard) | [unitest](https://github.com/jtdowney/unitest) | [startest](https://github.com/maxdeviant/startest) | [showtime](https://github.com/JohnBjrk/showtime) | [glacier](https://github.com/inoas/glacier) |
| --- | --- | --- | --- | --- | --- |
| Stars | 40★ · 🟨 | 4★ · 🟥 | 38★ · 🟨 | 26★ · 🟨 | 37★ · 🟨 |
| License | Apache-2.0 · 🟩 | Apache-2.0 · 🟩 | MIT · 🟩 | Apache-2.0 · 🟩 | Apache-2.0 · 🟩 |
| Target | ☎️📜 Both (EUnit on BEAM + custom JS runner) | ☎️📜 Both | ☎️📜 Both | ☎️ BEAM | ☎️📜 Both |
| Open issues | 8 · 🟩 | 0 · 🟩🟩 | 8 · 🟩 | 0 · 🟩🟩 ([dormant — see note](#showtime)) | 1 · 🟩🟩 ([archived — see note](#glacier)) |
| Maintenance | 🟩🟩 (last commit 2026-04-18, ~6 days) | 🟩🟩 (last commit 2026-04-20, ~4 days) | 🟩 (last commit 2026-01-19, ~3 mo) | 🟥 (last commit 2024-03-18, ~2 yrs) | 🟩🟩 (last commit 2026-04-18 — archive event) |
| Age | ~4 yrs (since Exercism fork era) · 🟩🟩 | ~3 mo (late 2025) · 🟨 | ~2 yrs · 🟩 | ~3 yrs · 🟩🟩 | ~2 yrs · 🟩 |
| README maturity | 🟩 (tagline + install + quick example) | 🟩🟩 (install, CLI flags, tagging, assertion note) | 🟩🟩 (describe/it, matchers, skip/only, reporters) | 🟩 (gleeunit-compat story, usage) | 🟩🟩 (incremental mode, watcher, drop-in) |
| Idiomaticity | 🟩 (`should` matchers, EUnit integration) | 🟩 (explicit tagging, language `assert` friendly) | 🟩 (typed matchers, reporter config) | 🟩 (gleeunit-compat API) | 🟩 (wraps gleeunit, file-watching) |

#### gleeunit
[repo](https://github.com/lpil/gleeunit) · [🥇](#leaderboard)

"A simple test runner for Gleam, using EUnit on Erlang and a custom runner on JS." Authored by Louis Pilfold. The default `gleam new` project ships with gleeunit as a dev dependency and `gleam test` invokes it out of the box — which makes it effectively the reference runner for the whole language. Exposes a lightweight `should` module for common matchers and an optional pattern for test discovery.

869k+ all-time hex downloads. Active: last commit 2026-04-18 (v1.10.0 release, ~6 days before snapshot). 8 open issues, typical shape for a widely-used runner (feature requests, discovery edge cases).

```gleam
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

pub fn addition_test() {
  1 + 1 |> should.equal(2)
}
```

#### unitest
[repo](https://github.com/jtdowney/unitest)

"A Gleam test runner with random ordering, tagging, and CLI filtering. It is a drop-in replacement for gleeunit if you're already using asserts." Introduces three features gleeunit doesn't ship: deterministic random ordering via a seed (catches test-order dependencies), tags on test functions, and CLI filters over path or name. README explicitly positions itself as gleeunit-compatible provided you've migrated off `should` onto the language `assert` statement — minimising migration effort.

Young (hex publish 2026-02, ~3 months at snapshot) but active — last commit 2026-04-20, zero open issues, clean tracker. Single-author.

```gleam
import unitest

pub fn main() {
  unitest.main()
}

@unitest.tag("slow")
pub fn big_computation_test() {
  assert compute_pi(1_000_000) == expected
}
```

#### startest
[repo](https://github.com/maxdeviant/startest)

"A testing framework to help you shoot for the stars." Describe/it API in the Vitest/Jest mould — `describe("the thing", [ it("does X", fn() { ... }) ])` — plus pretty matcher-style assertions (`expect.to_equal`), test filtering by file path or name, and `skip`/`only` markers. A different flavour from gleeunit's flat-function model.

Active cadence but uneven: last commit 2026-01-19, previous burst July 2025, earlier mid-2024. Single-author project. 8 open issues across features and bugs. Good fit if you prefer describe/it organisation; gleeunit remains the broader ecosystem default.

```gleam
import startest.{describe, it}
import startest/expect

pub fn main() {
  startest.run(startest.default_config(), [
    describe("add/2", [
      it("sums two ints", fn() {
        add(1, 2) |> expect.to_equal(3)
      }),
    ]),
  ])
}
```

<a id="showtime-note"></a>
#### showtime
[repo](https://github.com/JohnBjrk/showtime)

"Test framework for Gleam. It can be used in the same way as Gleeunit and intends to support the same API so that migration can be done by simply changing some imports." BEAM-only. Historically served as a gleeunit alternative with improved reporter output and parallelism.

**Dormant:** last commit 2024-03-18 (~2 years before snapshot). Zero open issues in the tracker, but that's survivorship bias on an unmaintained project rather than a positive signal. Author is also behind `glimt` (logging) which is in the same frozen state. Historical reference; not a live choice for new work.

<a id="glacier-note"></a>
#### glacier
[repo](https://github.com/inoas/glacier)

"Glacier brings incremental interactive unit testing to Gleam. It is meant as a drop-in replacement for gleeunit and depends on a fork of it." File-watcher-driven test runner that re-runs only the tests whose source files (or dependencies of those files) changed. Ambitious and useful concept.

**Archived 2026-04-18** (visible banner on repo page). README and hex package remain live, but the repo is read-only. The companion fork [glacier_gleeunit](#glacier_gleeunit) is in the same state. Do not pick for new projects; leaving in the review because it's historically significant and may inspire the next attempt.

#### glacier_gleeunit
[repo](https://github.com/inoas/gleeunit)

"A fork of gleeunit that allows it to be called as a library/function with a list of test modules instead of just via CLI." Infrastructure for [glacier](#glacier) — exposes gleeunit as a library API so glacier's watcher can drive it. Last commit 2025-12-25 (archive-adjacent; final state of the fork). Not independently useful unless you need library-style gleeunit invocation for your own tool.

### Property Testing

Generate random values that satisfy a spec, check invariants, shrink counterexamples on failure.

| Criterion | [qcheck](https://github.com/mooreryan/gleam_qcheck) [🥇](#leaderboard) | [qcheck_gleeunit_utils](https://github.com/mooreryan/qcheck_gleeunit_utils) |
| --- | --- | --- |
| Stars | 41★ · 🟨 | 1★ · 🟥 |
| License | Apache-2.0 + MIT · 🟩 | Apache-2.0 + MIT · 🟩 |
| Target | ☎️📜 Both | ☎️📜 Both |
| Open issues | 5 · 🟩 | 0 · 🟩🟩 |
| Maintenance | 🟩🟩 (last commit 2026-04-10, ~2 weeks) | 🟨 (last commit 2025-09-30, ~7 mo) |
| Age | ~2 yrs · 🟩 | ~2 yrs · 🟩 |
| README maturity | 🟩🟩 (concept intro, generators, shrinking, worked examples) | 🟩 (tagline + parallel/timeout helpers) |
| Idiomaticity | 🟩 (typed generators, explicit combinators) | 🟩 (helper functions, no magic) |

#### qcheck
[repo](https://github.com/mooreryan/gleam_qcheck) · [🥇](#leaderboard)

"Rather than specifying test cases manually, you describe the invariants that values of a given type must satisfy … generators generate lots of values on which the properties are checked. Finally, if a value is found for which a given property does not hold, that value is 'shrunk' in order to find an informative counter-example." Clean README framing. Combinator library for building generators (ints, strings, lists, records, variants) with integrated shrinking.

Active: last commit 2026-04-10, v1.0.4 released Feb 2026. Dual-licensed Apache-2.0/MIT — useful if you need to redistribute under either. 5 open issues, all feature-request/discussion shape. The standard property-testing choice for Gleam at snapshot.

```gleam
import gleeunit
import qcheck

pub fn main() {
  gleeunit.main()
}

pub fn reverse_reverse_is_identity_test() {
  use xs <- qcheck.given(qcheck.list_generic(qcheck.int_uniform(), 0, 100))
  list.reverse(list.reverse(xs)) == xs
}
```

#### qcheck_gleeunit_utils
[repo](https://github.com/mooreryan/qcheck_gleeunit_utils)

"Utility functions for working with Gleam's gleeunit test framework. Originally developed for internal use in the qcheck library." Parallel test execution, timeouts, helpers for running a test repeatedly. Originally extracted from qcheck; small, focused. Not a standalone choice — useful if you already use qcheck and hit one of the gaps it plugs.

### Snapshot Testing

Capture a value's rendered form on first run, assert equality on subsequent runs, review changes with a diff tool.

| Criterion | [birdie](https://github.com/giacomocavalieri/birdie) [🥇](#leaderboard) | [drift_record](https://github.com/sbergen/drift) |
| --- | --- | --- |
| Stars | 192★ · 🟩 | 4★ (repo total) · 🟥 |
| License | Apache-2.0 · 🟩 | Apache-2.0 · 🟩 |
| Target | ☎️📜 Both | ☎️📜 Both |
| Open issues | 1 · 🟩🟩 | 0 · 🟩🟩 |
| Maintenance | 🟩🟩 (last commit 2026-04-18, ~6 days) | 🟩 (last commit 2025-08-03, ~9 mo) |
| Age | ~3 yrs · 🟩🟩 | ~1 yr · 🟩 |
| README maturity | 🟩🟩 (concept, CLI review flow, screenshots, integration guide) | 🟩 (sibling of drift library; snapshot helper for stepper logs) |
| Idiomaticity | 🟩 (opt-in review step, file-on-disk snapshots) | 🟩 (explicit logs, explicit diffs) |

#### birdie
[repo](https://github.com/giacomocavalieri/birdie) · [🥇](#leaderboard)

"🐦‍⬛ Snapshot testing in Gleam. Snapshot testing allows you to perform assertions without having to write the expectation yourself. Birdie will store a snapshot of the expected value and compare future runs of the same test against it." Ships a CLI (`gleam run -m birdie`) for reviewing new snapshots interactively — accept, reject, diff. Files land in `birdie_snapshots/` which you check in.

192★, the largest community signal in this article by a wide margin. Last commit 2026-04-18 (v1.5.5 release). Clean tracker (1 issue). Authored by Giacomo Cavalieri, also behind [squirrel](https://github.com/giacomocavalieri/squirrel) and other core ecosystem tools. The uncontested snapshot choice.

```gleam
import birdie

pub fn renders_hello_test() {
  "Hello, Joe!"
  |> birdie.snap(title: "greets Joe")
}
```

```
$ gleam run -m birdie
  (press `a` to accept, `r` to reject, `q` to quit)
```

#### drift_record
[repo](https://github.com/sbergen/drift)

"Record logs for drift steppers, and use them in snapshot tests." One of four packages inside the `drift` monorepo (alongside `drift`, `drift_actor`, `drift_js`). Lets you capture the event/log stream produced by a [drift](https://github.com/sbergen/drift) pure-functional core and snapshot it for regression testing.

Specialist tool — only relevant if you're already using `drift` to structure a stepper-based pure core. Last commit on the parent repo 2025-08-03; drift_record v1.0.1 published around the same time. Active in context, narrow in scope.

### Doc Tests

Extract code examples from module documentation and run them as tests.

| Criterion | [testament](https://github.com/bwireman/testament) |
| --- | --- |
| Stars | 8★ · 🟥 |
| License | MIT · 🟩 |
| Target | ☎️📜 Both |
| Open issues | 0 · 🟩🟩 |
| Maintenance | 🟨 (last commit 2025-09-07, ~7 mo) |
| Age | ~1 yr · 🟩 |
| README maturity | 🟩 (install, quick example, hexdocs link) |
| Idiomaticity | 🟩 (explicit extraction from `///` comments) |

#### testament
[repo](https://github.com/bwireman/testament)

"Doc tests for Gleam! ✨" Parses `///` doc comments, extracts fenced code blocks, and evaluates them as test cases — the same workflow Rust and Elixir developers expect. Zero open issues, single author, clean code. Quiet recently (last commit Sep 2025, ~7 months before snapshot) but looks complete rather than abandoned — doc tests are a well-scoped feature and the project reached it.

Useful if your docs contain non-trivial examples you want to keep working. Skip if your examples are just `add(1, 2) == 3`-level — the overhead isn't worth it.

### Mocking

Replace real collaborators with controllable stand-ins during tests.

| Criterion | [mockth](https://github.com/bondiano/mockth) | [dream_mock_server](https://github.com/TrustBound/dream) |
| --- | --- | --- |
| Stars | 14★ · 🟨 | 41★ (repo total, monorepo) · 🟨 |
| License | Apache-2.0 · 🟩 | MIT · 🟩 |
| Target | ☎️ BEAM (Erlang `meck`) | ☎️ BEAM |
| Open issues | 0 · 🟩🟩 | 1 (repo-level) · 🟩 |
| Maintenance | 🟨 (last commit ≈2025-09-14, hex publish; repo last commit not verifiable via /commits) | 🟩🟩 (repo last commit 2026-03-17, ~5 wks; package published 2026-03-03) |
| Age | ~1.5 yrs · 🟩 | ~6 mo as a package (hex pub Oct 2025) · 🟨 |
| README maturity | 🟩 (meck-wrapper tagline + usage) | 🟩 (quick-start; lives inside dream monorepo) |
| Idiomaticity | 🟩 (typed module mocks) | 🟩 (explicit config, streaming/non-streaming endpoints) |

#### mockth
[repo](https://github.com/bondiano/mockth)

"A Gleam wrapper around the Meck library to do mocking in the easiest way." Lets you replace a module's functions with mocks for the duration of a test, then restore them. BEAM-only because it wraps [Erlang's `meck`](https://github.com/eproxus/meck) — the de facto module-mocking library in the BEAM world. Typical use is stubbing side-effecting dependencies (HTTP clients, database drivers) in pure-ish tests.

No live GitHub `/commits` browse at snapshot (the UI didn't surface the default branch view clearly), so activity is inferred from hex publish date (2025-09-14, v2.0.0). Zero open issues. The only Gleam-native module-mocking library at snapshot.

```gleam
import mockth

pub fn uses_mocked_client_test() {
  mockth.with_mock(http_client, "get", fn(_url) { Ok("stubbed body") }, fn() {
    let assert Ok("stubbed body") = my_module.fetch_user(42)
  })
}
```

#### dream_mock_server
[repo](https://github.com/TrustBound/dream) · *module: `modules/mock_server`*

"General-purpose HTTP mock server developed by Dream — provides both streaming and non-streaming endpoints for testing HTTP clients." Lives inside the TrustBound/dream web toolkit monorepo (`modules/mock_server`) and is published to hex as its own package. Complementary to mockth: mockth replaces a Gleam/Erlang module; `dream_mock_server` spins up an actual HTTP listener so you can exercise your HTTP client over a real socket.

The dream repo is actively maintained (last commit 2026-03-17, v2.4.0 release 2026-03-11). `dream_mock_server` v1.1.1 was published 2026-03-03.

### Programmatic Test Building

Generate test suites from data rather than writing them one-by-one.

| Criterion | [testbldr](https://github.com/bcpeinhardt/testbldr) |
| --- | --- |
| Stars | 4★ · 🟥 |
| License | Apache-2.0 · 🟩 |
| Target | ☎️📜 Both (inferred) |
| Open issues | 0 · 🟩 |
| Maintenance | ⬜ (hex last pub 2024-02-01; `/commits/main` returns "no commit history to show" at snapshot — [see note](#testbldr-note)) |
| Age | ~2 yrs · 🟩 |
| README maturity | 🟩 (clear premise + example) |
| Idiomaticity | 🟩 (library API, no macros) |

<a id="testbldr-note"></a>
#### testbldr
[repo](https://github.com/bcpeinhardt/testbldr)

"Programatically build test suites in Gleam. Most of the time it makes sense to have one test signature per test … Other times you may want to read test cases in from files, json responses, etc. This library is for the second case." Useful for data-driven testing — read a JSON corpus, generate one test per entry with a clear name and assertion.

**Access anomaly:** `/commits/main` showed "There isn't any commit history to show here" at snapshot despite the tree view listing 12 commits on main and the repo being public. Couldn't verify last-commit date via the UI. Hex last publish 2024-02-01, ~2 years before snapshot — practically dormant even if commit history surfaces. Marked ⬜ on maintenance.

### Timing & Synchronisation

Test code that depends on wall-clock delays without actually waiting.

| Criterion | [tickle](https://github.com/sbergen/tickle) |
| --- | --- |
| Stars | 0★ · 🟥 |
| License | Apache-2.0 · 🟩 |
| Target | ☎️ BEAM (wraps `process.send_after`) |
| Open issues | 0 · 🟩 |
| Maintenance | 🟨 (last commit 2025-04-05, ~1 yr) |
| Age | ~1 yr · 🟩 |
| README maturity | 🟩 (tagline + concept) |
| Idiomaticity | 🟩 (drop-in replacement for `send_after`) |

#### tickle
[repo](https://github.com/sbergen/tickle)

"Gleam Testing utility for simulating `send_after` delays and defining synchronization points ⏱️." Replace `process.send_after(...)` with `tickle.send_after(...)` in code under test, then in tests advance a virtual clock manually instead of sleeping. Also provides synchronisation points that tests can safely wait on — useful for actor-heavy code where you want to observe a state transition without racing.

Zero stars, zero issues, one-day burst of 21 commits in April 2025 then quiet. Single-author. Scope-complete for what it does; reach for it when your actor tests need deterministic timing.

### Specialised Runners

Test runners scoped to a single downstream use case.

| Criterion | [exercism_test_runner](https://github.com/exercism/gleam-test-runner) |
| --- | --- |
| Stars | 5★ · 🟥 |
| License | AGPL-3.0 · 🟥 |
| Target | ☎️ BEAM (Docker image) |
| Open issues | 6 · 🟩 |
| Maintenance | 🟨 (last commit 2025-09-01, ~7 mo) |
| Age | ~4 yrs · 🟩🟩 |
| README maturity | 🟩 (Exercism-specific deployment docs) |
| Idiomaticity | 🟩 (explicit JSON test output contract) |

#### exercism_test_runner
[repo](https://github.com/exercism/gleam-test-runner)

"The Docker image to automatically run tests on Gleam solutions submitted to Exercism." Packages a test harness plus JSON output contract suitable for Exercism's solution grading pipeline. Only relevant if you're running or extending an Exercism Gleam exercise track — otherwise out of scope for general project testing.

**License note:** AGPL-3.0. Unusual in the Gleam ecosystem, which is overwhelmingly Apache-2.0 or MIT. Marked 🟥 for license on the permissive/viral split — but this is Exercism infrastructure, not a library you'd vendor into your own project, so the practical impact is nil.

### Adjacent (linked out)

#### dream_test
[repo](https://github.com/TrustBound/dream_test) · also see [BDD with Gherkin](../../bdd-with-gherkin.md)

"A testing framework for Gleam that gets out of your way." Covers unit testing (describe/group/it), Gherkin-style BDD scenarios (either `.feature` files or inline DSL), parallel execution, multiple reporters (BDD, progress, JSON), and snapshot testing. If you want a one-stop "bigger than gleeunit" framework that also gives you Gherkin specs, dream_test is the Gleam-native option. 5★ at the last snapshot; most of the BDD discussion lives in the sibling article.

#### Browser & end-to-end testing

Out of scope for this article — see [Browser automation & testing tools in Gleam](./browser-automation.md) for [chrobot](./browser-automation.md#chrobot) (Chrome DevTools Protocol), [luciole](./browser-automation.md#luciole) (Cypress-from-Gleam), and [testcontainers_gleam](./browser-automation.md#testcontainers_gleam) (Docker services for integration tests).

## Leaderboard

Thanks to everyone writing Gleam testing libraries. The ecosystem defaults well — `gleeunit` + `assert` + `birdie` + `qcheck` covers 95% of what most Gleam codebases need — but the specialist tools below fill genuine gaps, and the alternative runners keep the design space honest.

Ranked by raw score (tie-break: maintenance recency, then README maturity). Context caveats (archived, dormant, license edge case) flagged inline rather than used to drop a repo from the table.

**🥇 Gold**
- **birdie** ([giacomocavalieri](https://github.com/giacomocavalieri)) — The snapshot testing library. 192★, active, comprehensive review CLI. No close second in its category.
- **gleeunit** ([lpil](https://github.com/lpil)) — The default unit test runner. Ubiquitous, actively maintained by Gleam's creator, the reference that all other runners pitch themselves against.
- **qcheck** ([mooreryan](https://github.com/mooreryan)) — The property-testing anchor. QuickCheck-style generators with integrated shrinking, active, dual-licensed.

**🥈 Silver**
- **unitest** ([jtdowney](https://github.com/jtdowney)) — Random-order + tag + CLI filter runner, gleeunit-compatible migration path, zero open issues, active.
- **startest** ([maxdeviant](https://github.com/maxdeviant)) — Describe/it API for teams that prefer that organisation over flat test functions.
- **mockth** ([bondiano](https://github.com/bondiano)) — The only Gleam-native module-mocking library; thin wrapper over `meck`.
- **dream_mock_server** ([TrustBound](https://github.com/TrustBound)) — Active HTTP mock server, pairs with any HTTP client for end-to-end tests.

**🥉 Bronze**
- **testament** ([bwireman](https://github.com/bwireman)) — Doc tests. Quiet but scope-complete.
- **drift_record** ([sbergen](https://github.com/sbergen)) — Niche but necessary companion for `drift`-based pure cores.
- **tickle** ([sbergen](https://github.com/sbergen)) — Simulated `send_after` + sync points for deterministic actor tests.
- **qcheck_gleeunit_utils** ([mooreryan](https://github.com/mooreryan)) — Parallel/timeout helpers for qcheck.

**No award (dormant, archived, or narrow)**
- **showtime** ([JohnBjrk](https://github.com/JohnBjrk)) — Gleeunit-compatible runner, 2 years dormant.
- **glacier** / **glacier_gleeunit** ([inoas](https://github.com/inoas)) — Incremental interactive runner, **archived 2026-04-18**.
- **testbldr** ([bcpeinhardt](https://github.com/bcpeinhardt)) — Programmatic test building. Hex dormant since early 2024; `/commits` page returned no history at snapshot.
- **exercism_test_runner** ([exercism](https://github.com/exercism)) — Exercism infra, AGPL-3.0, not a library choice.

| Position | Award | Repo | ★ | Lic | Compat | Maint | Age | README | Idiom | Score |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 🥇 | [giacomocavalieri/birdie](https://github.com/giacomocavalieri/birdie) | 🟩 | 🟩 | 🟩 | 🟩🟩 | 🟩🟩 | 🟩🟩 | 🟩 | **10** |
| 2 | 🥇 | [lpil/gleeunit](https://github.com/lpil/gleeunit) | 🟨 | 🟩 | 🟩 | 🟩🟩 | 🟩🟩 | 🟩 | 🟩 | **8** |
| 2 | 🥇 | [mooreryan/gleam_qcheck](https://github.com/mooreryan/gleam_qcheck) | 🟨 | 🟩 | 🟩 | 🟩🟩 | 🟩 | 🟩🟩 | 🟩 | **8** |
| 3 | 🥈 | [jtdowney/unitest](https://github.com/jtdowney/unitest) | 🟥 | 🟩 | 🟩 | 🟩🟩 | 🟨 | 🟩🟩 | 🟩 | **6** |
| 3 | 🥈 | [maxdeviant/startest](https://github.com/maxdeviant/startest) | 🟨 | 🟩 | 🟩 | 🟩 | 🟩 | 🟩🟩 | 🟩 | **7** |
| 3 | 🥈 | [bondiano/mockth](https://github.com/bondiano/mockth) | 🟨 | 🟩 | 🟩 | 🟨 | 🟩 | 🟩 | 🟩 | **5** |
| 3 | 🥈 | [TrustBound/dream](https://github.com/TrustBound/dream) (`dream_mock_server`) | 🟨 | 🟩 | 🟩 | 🟩🟩 | 🟨 | 🟩 | 🟩 | **6** |
| 4 | 🥉 | [bwireman/testament](https://github.com/bwireman/testament) | 🟥 | 🟩 | 🟩 | 🟨 | 🟩 | 🟩 | 🟩 | **4** |
| 4 | 🥉 | [sbergen/drift](https://github.com/sbergen/drift) (`drift_record`) | 🟥 | 🟩 | 🟩 | 🟩 | 🟩 | 🟩 | 🟩 | **5** |
| 4 | 🥉 | [sbergen/tickle](https://github.com/sbergen/tickle) | 🟥 | 🟩 | 🟩 | 🟨 | 🟩 | 🟩 | 🟩 | **4** |
| 4 | 🥉 | [mooreryan/qcheck_gleeunit_utils](https://github.com/mooreryan/qcheck_gleeunit_utils) | 🟥 | 🟩 | 🟩 | 🟨 | 🟩 | 🟩 | 🟩 | **4** |
| 5 | | [JohnBjrk/showtime](https://github.com/JohnBjrk/showtime) | 🟨 | 🟩 | 🟩 | 🟥 | 🟩🟩 | 🟩 | 🟩 | **5** |
| 5 | | [inoas/glacier](https://github.com/inoas/glacier) | 🟨 | 🟩 | 🟩 | 🟥 | 🟩 | 🟩🟩 | 🟩 | **5**\* (archived) |
| 5 | | [inoas/gleeunit](https://github.com/inoas/gleeunit) (`glacier_gleeunit`) | 🟥 | 🟩 | 🟩 | 🟥 | 🟩 | 🟩 | 🟩 | **2**\* (archive-adjacent) |
| 5 | | [bcpeinhardt/testbldr](https://github.com/bcpeinhardt/testbldr) | 🟥 | 🟩 | 🟩 | ⬜ | 🟩 | 🟩 | 🟩 | **3** |
| 5 | | [exercism/gleam-test-runner](https://github.com/exercism/gleam-test-runner) | 🟥 | 🟥 | 🟩 | 🟨 | 🟩🟩 | 🟩 | 🟩 | **3** |

**By target:** ☎️ BEAM **17** · 📜 JS **11** (gleeunit, unitest, startest, glacier, birdie, drift_record, qcheck, qcheck_gleeunit_utils, testament, testbldr (inferred), plus specialist runners). BEAM-only entries are showtime, mockth, tickle, dream_mock_server, exercism_test_runner.

[How scores are calculated →](#scoring-dimensions)

---

*Snapshot: 2026-04-24. Data sources: [packages.gleam.run](https://packages.gleam.run/) search for `test` (and probe queries `mock`, `property`, `snapshot`, `spec`, `coverage`, `assert`), hex.pm package pages, live GitHub web UI for stars/commits/issues. No API or git-clone access used.*
