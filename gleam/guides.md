# Learning Gleam — guides, books, courses, and other resources

> [!NOTE]
> **Status:** DRAFT · **Authoring:** AI-assisted, human-reviewed.

So you want to learn Gleam.
The honest answer in 2026: **there is no Gleam book** (no Manning, no O'Reilly, no Pragmatic) and no university course. What exists instead is a single very-good interactive language tour, an excellent Exercism track, a paid CodeCrafters track, framework-shipped guides for the main libraries, and a thin smear of YouTube talks from the maintainer + a few community creators. The official position from the maintainers — recorded in [a 2024 GitHub discussion](https://github.com/gleam-lang/gleam/discussions/2622) — is "no one has made a book yet, the language tour is the substitute."

This article reviews the *learning resources* (interactive tour, Exercism, CodeCrafters, framework guides, YouTube videos, community blog series, awesome-list, newsletter, conference talks) — not the libraries themselves. For library-by-library coverage of the ecosystem, see the rest of this folder ([web-apps.md](web-and-http/web-apps.md), [databases.md](databases.md), [authentication.md](authentication.md), …).

> [!IMPORTANT]
> **No Gleam book exists as of snapshot.** If you're asking "what should I read on a long flight to learn Gleam?", the answer is: print [tour.gleam.run/everything/](https://tour.gleam.run/everything/) to PDF and bring that. Everything else is online-only or video.

**Snapshot: 2026-04-29.**

## Table of Contents

1. [TL;DR](#tldr)
2. [Framing — why the list looks like this](#framing--why-the-list-looks-like-this)
3. [Research method](#research-method)
   - [Scoring dimensions](#scoring-dimensions)
   - [Discovery](#discovery)
4. [The guides](#the-guides)
   - [Official — Gleam Language Tour](#official--gleam-language-tour)
   - [Official — Writing Gleam guide](#official--writing-gleam-guide)
   - [Official — Cheatsheets (per-language migration)](#official--cheatsheets-per-language-migration)
   - [Official — News blog (release notes as learning material)](#official--news-blog-release-notes-as-learning-material)
   - [Exercism — Gleam track](#exercism--gleam-track)
   - [CodeCrafters — Gleam track](#codecrafters--gleam-track)
   - [awesome-gleam — community index](#awesome-gleam--community-index)
   - [Gleam Weekly — newsletter](#gleam-weekly--newsletter)
   - [Discord — chat & community](#discord--chat--community)
   - [Lustre — framework-shipped guide](#lustre--framework-shipped-guide)
   - [Wisp — framework-shipped guide (examples-only)](#wisp--framework-shipped-guide-examples-only)
   - [YouTube — talks and tutorials](#youtube--talks-and-tutorials)
   - [Community blog series & one-off articles](#community-blog-series--one-off-articles)
   - [gleam-book (community book attempt)](#gleam-book-community-book-attempt)
   - [gleamprogramming.com (community link directory)](#gleamprogrammingcom-community-link-directory)
5. [Gaps — what doesn't exist yet](#gaps--what-doesnt-exist-yet)
6. [Per-guide leaderboard](#per-guide-leaderboard)
7. [Related reviews](#related-reviews)

## TL;DR

| Guide | Format | Audience | Cost | Verdict |
| --- | --- | --- | --- | --- |
| **[Gleam Language Tour](#official--gleam-language-tour)** | Interactive (in-browser, runs Gleam) | Beginners → intermediate | Free | 🥇 The de-facto Gleam textbook. Maintained by the language team. |
| **[Writing Gleam guide](#official--writing-gleam-guide)** | HTML walkthrough | Has-the-language-down → first-project | Free | 🥈 The "how do I actually ship something" half. Pairs with the tour. |
| **[Exercism Gleam track](#exercism--gleam-track)** | 122 exercises, 33 concepts, mentored | Beginners → intermediate | Free | 🥈 Best deliberate-practice resource. Funded by ErlEF. |
| **[Cheatsheets](#official--cheatsheets-per-language-migration)** | Side-by-side syntax tables | Devs from Elixir/Erlang/Elm/PHP/Python/Rust | Free | Translation aid for polyglots; not a learning path. |
| **[News blog](#official--news-blog-release-notes-as-learning-material)** | Release notes (monthly-ish) | Anyone keeping current | Free | Announcement-shaped; teaches features as they ship. |
| **[CodeCrafters Gleam](#codecrafters--gleam-track)** | "Build your own Redis/Shell/Grep/SQLite/HTTP/Kafka/Interpreter/Chess Bot" | Intermediate, project-driven | Paid (Redis free until 2026-05-01) | Project-based, deep, paywalled. |
| **[awesome-gleam](#awesome-gleam--community-index)** | Curated list (GitHub repo) | Anyone scoping the ecosystem | Free | Index, not a guide. Where you go to find guides. |
| **[Gleam Weekly](#gleam-weekly--newsletter)** | Email newsletter | Active practitioners | Free | Curated; community-run. |
| **[Discord](#discord--chat--community)** | Live chat | Anyone with a question | Free | The fastest path from "stuck" to "unstuck." |
| **[Lustre guide](#lustre--framework-shipped-guide)** | HexDocs guide + 20+ examples | Web frontends in Gleam | Free | Best framework-shipped guide in the ecosystem. |
| **[Wisp guide](#wisp--framework-shipped-guide-examples-only)** | Examples + API docs (no narrative tutorial) | HTTP backends | Free | Examples-only; functional but no first-class walkthrough. |
| **[YouTube talks](#youtube--talks-and-tutorials)** | 30-60 min recorded talks | Mixed | Free | Sparse; mostly conference talks, a few intros. |
| **[Community blog series](#community-blog-series--one-off-articles)** | Per-author HTML posts | Mixed | Free | Scattered, no canonical "go-read-this" post. |
| **[gleam-book](#gleam-book-community-book-attempt)** | Community book attempt | Beginners | Free | Stalled since 2022. Don't rely on it. |
| **[gleamprogramming.com](#gleamprogrammingcom-community-link-directory)** | Link directory | Curious newcomers | Free | Thin; redundant with awesome-gleam. |

**One sentence:** Start with the [Language Tour](#official--gleam-language-tour), do [Exercism](#exercism--gleam-track) in parallel, read the [Writing Gleam guide](#official--writing-gleam-guide) when you want to ship a project, and join the [Discord](#discord--chat--community) the moment you get stuck.

## Framing — why the list looks like this

Gleam reached v1.0 on [2024-03-04](https://gleam.run/news/gleam-version-1) — barely two years before snapshot. The learning-resource market has had two years to react, and that shows:

- **No book.** The maintainer (Louis Pilfold) confirmed in [discussion #2622](https://github.com/gleam-lang/gleam/discussions/2622): "No one has made one that I'm aware of." The community decision was to invest in the interactive [Language Tour](#official--gleam-language-tour) instead — printable to PDF via `/everything/`, which is the closest thing to a book.
- **No university course.** Gleam isn't on any computer-science syllabus the author could find.
- **No paid video course.** Not on Udemy, Egghead, Pluralsight, Frontend Masters, Coursera, edX. (Searched 2026-04-29.) Compared to Elixir (which has multiple paid courses including Pragmatic Studio, ElixirCasts, Grox.io), Gleam is empty here.
- **One sponsored interactive course.** The [Erlang Ecosystem Foundation funded the Exercism Gleam track in 2023](https://erlef.org/) — that's the canonical "do exercises and get mentored" path.
- **Framework guides do most of the heavy lifting.** Once you're past syntax, the meatiest learning material lives in [Lustre's guide](#lustre--framework-shipped-guide) and the [Wisp examples](#wisp--framework-shipped-guide-examples-only). The Gleam team owns the language tour; the framework authors own the "how do I build a web app" tour.
- **YouTube is sparse.** A handful of talks (mostly Code BEAM and FOSDEM), one or two creator series (notably [Isaac Harris-Holt](#youtube--talks-and-tutorials)). No multi-hour series the way you'd find for Rust or Elixir.

The shape of this list is therefore: **one strong interactive tour + one strong exercise platform + one paid project track + framework-shipped guides + a thin community periphery**. That's not a criticism — it's an accurate snapshot of a 2-year-old v1 language whose docs are deliberately curated by a small core team.

## Research method

### Scoring dimensions

Same 7-dim rubric used across this folder (inherited from [REVIEW_METHODOLOGY.md](../workflows/REVIEW_METHODOLOGY.md)) — but adapted from "library" to "learning resource" as the unit. The dimensions track what a learner cares about:

- **Coverage:** how much of Gleam the resource teaches. 🟩🟩 = language + stdlib + ecosystem; 🟩 = language + stdlib; 🟨 = language only; 🟥 = single topic / sliver.
- **Currency:** when it was last updated, ISO date + emoji vs. snapshot. 🟩🟩 weeks-fresh, 🟩 months-fresh, 🟨 ~1 year, 🟥 multi-year stale.
- **Format quality:** interactive / project-driven > video > prose > stub. 🟩🟩 interactive or built-in mentorship; 🟩 polished prose / video; 🟨 thin or single-topic; 🟥 broken / placeholder.
- **Approachability:** how welcoming the resource is to a beginner *with prior programming experience* (the Gleam team's stated audience). 🟩🟩 beginner-friendly; 🟩 intermediate; 🟨 mixed; 🟥 expert-only / context-heavy.
- **Accessibility (license / cost):** 🟩🟩 free + openly licensed (CC / MIT / public source); 🟩 free; 🟨 mostly free with paid-tier; 🟥 paid-only.
- **Authority:** 🟩🟩 official Gleam team or first-party (e.g. Lustre maintainer); 🟩 well-known maintainer / ErlEF-funded / Hex-published; 🟨 community individual; 🟥 abandoned / unknown.
- **Depth:** 🟩🟩 takes you to building real apps with idiomatic patterns; 🟩 covers full language idiomatically; 🟨 stops at syntax / hello-world; 🟥 sliver / drive-by.

**Leaderboard scoring:** 🟥 = −1, 🟨 / ⬜ = 0, 🟩 = 1, 🟩🟩 = 2. Sum across 7 dims. Max = 14.

### Discovery

Resources surfaced via:

| Source | URL | What surfaced |
| --- | --- | --- |
| Official Gleam site nav | [gleam.run/documentation](https://gleam.run/documentation/) | Tour, Writing Gleam, Cheatsheets, Install, Deployment, Community, Exercism, CodeCrafters |
| Awesome-Gleam Resources section | [github.com/gleam-lang/awesome-gleam](https://github.com/gleam-lang/awesome-gleam) | Websites, Courses, Talks, Social Media |
| Hex.pm tutorial-shaped docs | [hexdocs.pm/lustre](https://hexdocs.pm/lustre/), [hexdocs.pm/wisp](https://hexdocs.pm/wisp/) | Lustre guide, Wisp examples |
| YouTube search | "Gleam programming language tutorial" | Talk recordings, intro videos |
| Google search | "Gleam book", "Gleam course", "Learn Gleam" | gleam-book (stalled), gleamprogramming.com (link dir), Michael Uloth blog (notes) |
| Manning / O'Reilly catalogs | direct catalog search | **No book exists.** |
| Udemy / Egghead / Pluralsight / Frontend Masters | direct catalog search | **No paid video course exists.** |
| ErlEF events page | [erlef.org/events](https://erlef.org/events) | Code BEAM (Europe / America / Stockholm), Erlang Workshop (ICFP) — all include Gleam content |
| Hacker News / Reddit / Discord pinned messages | various | Newsletter, conference talks, occasional blog series |

**Total resources reviewed: 15.** No paid book / video course matched search; the gap is real, not just under-discovered.

## The guides

### Official — Gleam Language Tour

**Thesis:** the Gleam team's official, interactive, in-browser language reference. Edit-and-run code blocks, real-time compilation to JS, error messages displayed inline. Maintained alongside the compiler. The community-decided substitute for "no book exists."

- URL: [tour.gleam.run](https://tour.gleam.run/)
- Single-page printable view: [tour.gleam.run/everything/](https://tour.gleam.run/everything/) (intended for "print to PDF" use)
- Source: [github.com/gleam-lang/language-tour](https://github.com/gleam-lang/language-tour) (linked from awesome-gleam)
- Authority: official Gleam team (`gleam-lang` org)

#### Score

| Criterion | Score | Reason |
| --- | --- | --- |
| Coverage | 🟩🟩 | Covers the entire language: types, pattern matching, custom types, generics, modules, JS interop, Erlang interop. Doesn't go into stdlib breadth (that's hexdocs) but does the language proper. |
| Currency | 🟩🟩 | Maintained alongside the compiler. New features land in the tour as they ship in releases. |
| Format quality | 🟩🟩 | Interactive in-browser editor with live compilation. The single best Gleam learning UX. |
| Approachability | 🟩🟩 | Designed for "you have programming experience but are new to Gleam." Builds gradually from `hello world` to advanced features. |
| Accessibility | 🟩🟩 | Free, MIT-licensed source, runs entirely in browser (no signup). |
| Authority | 🟩🟩 | Official Gleam team. The maintainer-recommended starting point. |
| Depth | 🟩 | Takes you through the full language, but stops at "you understand the language." For "build a real web app," you graduate to the [Lustre guide](#lustre--framework-shipped-guide) or the [Writing Gleam guide](#official--writing-gleam-guide). |

**Score: 13** — see [leaderboard](#per-guide-leaderboard).

#### What's in it

The tour walks through chapters: hello world; basics (variables, ints, floats, strings); functions; flow control; data structures (tuples, lists, custom types); modules; advanced features (generics, use expressions, panic / let assert / todo); concurrency primitives; JavaScript & Erlang FFI. Every page has a runnable code editor with live compilation.

#### Gotchas

- **Stdlib coverage is intentionally thin.** The tour is the *language* tour, not the *standard library* tour. For stdlib, use [hexdocs.pm/gleam_stdlib/](https://hexdocs.pm/gleam_stdlib/).
- **No "build a real project" content.** That's the [Writing Gleam guide](#official--writing-gleam-guide)'s job.
- **Print-to-PDF works, but the result isn't a polished book.** It's a printout of a website; expect long pages and some interactive widgets that don't render in print.

### Official — Writing Gleam guide

**Thesis:** the "you know the syntax, now ship a project" companion to the Language Tour. Walks through `gleam new`, dependency management, testing with `gleeunit`, building escripts. Lives at [gleam.run/writing-gleam/](https://gleam.run/writing-gleam/).

- URL: [gleam.run/writing-gleam/](https://gleam.run/writing-gleam/)
- Authority: official Gleam team

#### Score

| Criterion | Score | Reason |
| --- | --- | --- |
| Coverage | 🟩 | Covers the project-shaped concerns: build tool, dependencies, testing, escript distribution. Doesn't cover web frameworks, JS bundling, deployment. |
| Currency | 🟩🟩 | Maintained on `gleam.run`. Aligned with the current build tool. |
| Format quality | 🟩 | Clear prose tutorial; not interactive but focused and short. |
| Approachability | 🟩 | Assumes you've already done the language tour; not a true beginner doc. |
| Accessibility | 🟩🟩 | Free, source under [gleam-lang/website](https://github.com/gleam-lang/website). |
| Authority | 🟩🟩 | Official. |
| Depth | 🟩 | Single project (CLI escript). Doesn't go into multi-package workspaces, OTP, web apps. |

**Score: 11** — see [leaderboard](#per-guide-leaderboard).

#### What's in it

`gleam new` → adding `argv` and `envoy` deps → using them in `main` → writing tests with `gleeunit` → bundling as an escript. Linear, ~30 minutes end-to-end.

#### Gotchas

- **Single-project scope.** If you want OTP supervision trees, multi-package layouts, web frameworks, or JS deployment, this guide stops short — graduate to the framework-specific guides.
- **The example is a CLI tool.** Web devs may want to skim it for the build-tool material and then jump to the [Lustre guide](#lustre--framework-shipped-guide).

### Official — Cheatsheets (per-language migration)

**Thesis:** side-by-side syntax tables for developers coming from another language. Six languages covered: Elixir, Erlang, Elm, PHP, Python, Rust. Lives under [gleam.run/documentation/](https://gleam.run/documentation/).

- URLs: e.g. `gleam.run/cheatsheets/gleam-for-elixir-users/` (each language has its own page; URL slug per language)
- Authority: official Gleam team

#### Score

| Criterion | Score | Reason |
| --- | --- | --- |
| Coverage | 🟨 | Covers syntax mapping (variables, functions, modules, pattern matching, custom types) — not stdlib, not project setup. By design. |
| Currency | 🟩 | Maintained on `gleam.run`. Last refresh tracking the live site. |
| Format quality | 🟩 | Side-by-side code blocks; idiomatic, terse. |
| Approachability | 🟩🟩 | Most approachable resource if you already know one of the source languages — you learn by translation. |
| Accessibility | 🟩🟩 | Free, on official site. |
| Authority | 🟩🟩 | Official. |
| Depth | 🟨 | Translation aid, not a learning path. You finish a cheatsheet and you can read Gleam; you can't yet write idiomatic Gleam. |

**Score: 9** — see [leaderboard](#per-guide-leaderboard).

#### What's in it (Elixir cheatsheet, representative)

Comments → variables → match operator → variable type annotations → functions → function heads & overloading → labelled arguments → modules → operators → constants → blocks → data types (strings, tuples, lists, atoms, dicts) → patterns → custom types (records & unions). Per-topic side-by-side code blocks.

#### Gotchas

- **Six source languages, no Java / Go / Swift / Kotlin / Haskell / OCaml / TypeScript.** If your background isn't covered, you fall back to the language tour.
- **Cheatsheets show *what* maps, not *why* it maps that way.** They assume you'll figure out the why from idiomaticity once you write some Gleam. Pair with [Exercism](#exercism--gleam-track) for the "writing it yourself" half.

### Official — News blog (release notes as learning material)

**Thesis:** Louis Pilfold's release-note posts on `gleam.run/news` introduce new features as they ship. Not tutorials by intent, but they explain *why* a feature exists with code examples — which means they double as learning material for new features.

- URL: [gleam.run/news/](https://gleam.run/news/)
- Frequency: roughly monthly (v1.13 → v1.16 over Oct 2025 → Apr 2026)
- Author: Louis Pilfold (compiler maintainer)

#### Score

| Criterion | Score | Reason |
| --- | --- | --- |
| Coverage | 🟨 | Covers whatever's in the current release. Cumulatively, covers a lot of language evolution; in any single post, narrow. |
| Currency | 🟩🟩 | Last post 2026-04-24 (5 days before snapshot — v1.16 release). |
| Format quality | 🟩 | Long-form prose with code examples. Polished. |
| Approachability | 🟨 | Assumes Gleam fluency. Reading "Formalising external APIs" cold won't onboard a beginner. |
| Accessibility | 🟩🟩 | Free, on official site. |
| Authority | 🟩🟩 | Compiler author. |
| Depth | 🟩 | Per-feature deep-dives. Cumulative depth across the archive is substantial (back to 2019). |

**Score: 9** — see [leaderboard](#per-guide-leaderboard).

#### Recent posts (representative)

- **2026-04-24** — *JavaScript source maps* (v1.16.0)
- **2026-03-xx** — *Upgrading Hex security* (v1.15.0)
- **2026-02-xx** — *Join us at Gleam Gathering* — first all-Gleam conference announcement
- **2025-12-xx** — *The happy holidays release 2025* (v1.14.0)
- **2025-10-xx** — *Formalising external APIs* (v1.13.0)
- **2024-03-04** — *Gleam version 1* — the v1.0 release post

#### Gotchas

- **Release-note shaped, not tutorial-shaped.** Use these to *update* your knowledge, not build it from scratch.
- **No table of contents across posts.** You're scrolling the archive; the most-recent posts are the most-relevant for "what's new since I last looked."

### Exercism — Gleam track

**Thesis:** 122 coding exercises across 33 concepts, with optional volunteer mentorship. The track was [funded by the Erlang Ecosystem Foundation in 2023](https://erlef.org/) — making it the only "sponsored" Gleam learning resource. As of snapshot: **7,571 enrolled students, 110 contributors, 104 mentors, MIT-licensed, repo last commit 2026-04-02.**

- Site: [exercism.org/tracks/gleam](https://exercism.org/tracks/gleam)
- Source: [github.com/exercism/gleam](https://github.com/exercism/gleam) — 115★, MIT, last commit 2026-04-02

#### Score

| Criterion | Score | Reason |
| --- | --- | --- |
| Coverage | 🟩 | 33 concepts → covers most of the language. Ecosystem (HTTP, JSON, OTP) less so — the track is language-and-stdlib focused. |
| Currency | 🟩🟩 | Last commit 2026-04-02 (~4 weeks before snapshot). Active maintenance + bot-bumps. |
| Format quality | 🟩🟩 | Exercise-driven with optional mentor review. The strongest *deliberate practice* resource for Gleam. |
| Approachability | 🟩🟩 | Designed for beginners; concepts unlock progressively. Mentor reviews give beginner-grade idiomatic feedback. |
| Accessibility | 🟩🟩 | Free, MIT-licensed. Exercism platform is donation-funded, no paywall. |
| Authority | 🟩 | Run by Exercism (well-known multi-language platform), funded by ErlEF, 110 contributors. Not the Gleam core team but blessed-adjacent. |
| Depth | 🟩 | Solid coverage of language idioms; doesn't take you to "ship a real app" depth (that's the [Writing Gleam guide](#official--writing-gleam-guide) + framework guides). |

**Score: 12** — see [leaderboard](#per-guide-leaderboard).

#### What's in it

Concepts (33 unlocked progressively): basics, ints, floats, strings, lists, custom types, pattern matching, generics, anonymous functions, labelled args, results, options, modules, recursion, dicts, sets, type variables, etc. Exercises (122) range from "hello world" to multi-step problems (Word Count, Grade School, Allergies, Forth interpreter).

#### Gotchas

- **Mentorship is volunteer-staffed; queue times vary.** 104 mentors → typically days, sometimes longer for less-popular exercises.
- **No web / OTP / framework content.** The track is language-only by Exercism's design (see also: Exercism Elixir track follows the same pattern).
- **Exercises don't sequence into a single project.** It's deliberate-practice in isolation, not "build the same thing across 30 lessons."

### CodeCrafters — Gleam track

**Thesis:** project-driven challenges where you implement substantial software (Redis, Shell, Grep, SQLite, HTTP server, Kafka, an interpreter, a chess bot) from scratch in Gleam. Test-graded, stage-by-stage. **Paid** — most challenges require subscription; the Redis challenge is free until 2026-05-01 (1 day after snapshot). Track was launched [in collaboration with Louis Pilfold](https://forum.codecrafters.io/t/gleam-track-is-live-watch-gleams-creator-do-the-redis-challenge/280) (he recorded a screencast solving Redis in Gleam).

- Track: [app.codecrafters.io/tracks/gleam](https://app.codecrafters.io/tracks/gleam)
- Source: [github.com/codecrafters-io](https://github.com/codecrafters-io) (testers per challenge, e.g. [gleam-chess-bot-tester](https://github.com/codecrafters-io/gleam-chess-bot-tester))

#### Score

| Criterion | Score | Reason |
| --- | --- | --- |
| Coverage | 🟩🟩 | Spans systems programming territory: TCP, concurrency, parsing, file formats, B-trees. Touches more of the stdlib + ecosystem than any other resource here. |
| Currency | 🟩 | Tracks are kept up to date with new Gleam releases ("Gleam 1.13/1.14 is now available" forum posts indicate active version-bumping). |
| Format quality | 🟩🟩 | Stage-graded automated tests + reference implementation diff = the most-rigorous practice format in the list. |
| Approachability | 🟨 | Intermediate. The challenges assume you know Gleam syntax — Redis stage 1 is a TCP listener, not "what is a list." Pair with the language tour. |
| Accessibility | 🟥 | **Paid** — most content gated behind subscription. Redis free through 2026-05-01 (effectively expiring); other challenges paid. |
| Authority | 🟩🟩 | Codecrafters is a known platform (multi-language, well-regarded); the Gleam track was co-developed with the language creator. |
| Depth | 🟩🟩 | Builds real systems. The strongest "go deep" resource here. |

**Score: 9** — see [leaderboard](#per-guide-leaderboard). The score is dragged down by the paywall; on developer-side merit (depth, format quality, ecosystem coverage), this is the second-strongest resource on the list.

#### Challenges available

1. **Build your own Redis** — TCP, concurrent programming, Redis wire protocol. *Free until 2026-05-01.*
2. **Build your own Shell** — REPL, command parsing, process spawning, builtins.
3. **Build your own Grep** — Regex, pattern matching.
4. **Build your own SQLite** — B-trees, file formats, query parsing.
5. **Build your own HTTP server** — TCP, HTTP wire protocol, concurrent connections.
6. **Build your own Kafka** — Kafka wire protocol, TCP servers.
7. **Build your own Interpreter** — Following *Crafting Interpreters*, build the Lox language.
8. **Build your own Chess Bot** — Chess engine, competitive ranking against other users' bots.

#### Gotchas

- **Paywall is real.** Most challenges require an active subscription. Budget accordingly.
- **Not for absolute beginners.** Stage 1 of any challenge assumes Gleam fluency.
- **Free Redis stage is the on-ramp.** It's also the screencast Louis Pilfold recorded — watching that + doing the stages yourself is a strong free intro to "real Gleam."

### awesome-gleam — community index

**Thesis:** the canonical curated index of Gleam libraries, projects, and resources. Run by the `gleam-lang` GitHub org (semi-official). **2k★, 109 forks, 312 commits, MIT, last commit 2026-04-19** (10 days before snapshot).

- URL: [github.com/gleam-lang/awesome-gleam](https://github.com/gleam-lang/awesome-gleam)
- Authority: `gleam-lang` org (community curated, repo lives in the official org)

#### Score

| Criterion | Score | Reason |
| --- | --- | --- |
| Coverage | 🟩🟩 | Indexes everything: libraries (broken down by category), projects, resources (websites, courses, talks, social). |
| Currency | 🟩🟩 | Last commit 2026-04-19. |
| Format quality | 🟩 | Standard awesome-list format. Useful but not interactive. |
| Approachability | 🟩 | An index, not a tutorial. A beginner won't learn Gleam from it but will learn *what to learn next*. |
| Accessibility | 🟩🟩 | Free, MIT, on GitHub. |
| Authority | 🟩🟩 | `gleam-lang` org → semi-official. |
| Depth | 🟨 | Pointers, not depth. |

**Score: 11** — see [leaderboard](#per-guide-leaderboard).

#### What's in the Resources section

Sub-sections: Websites (gleam.run, tour.gleam.run, gleamweekly.com, gloogle.run), Courses (Exercism, gladvent for Advent of Code), Talks (FOSDEM 2023 × 2, Theo Harris's "I learned Gleam in a week" YouTube talk), Social Media (Twitter / X, Reddit, Bluesky).

#### Gotchas

- **No Books / Videos / Cheatsheets sub-section.** Reflects the gap — there are no books to link to, the cheatsheets live on `gleam.run` directly, and YouTube content is sparse enough to merge into Talks.
- **Not exhaustive on tutorials / blog posts.** Individual creator series (Michael Uloth, Isaac Harris-Holt's videos beyond the FOSDEM talk) aren't all linked.

### Gleam Weekly — newsletter

**Thesis:** community-curated weekly email of Gleam articles, releases, and project highlights. Free.

- URL: [gleamweekly.com](https://gleamweekly.com/)
- Authority: community-run (separate from `gleam-lang`)

#### Score

| Criterion | Score | Reason |
| --- | --- | --- |
| Coverage | 🟨 | Whatever was published that week — broad on aggregate, narrow per issue. |
| Currency | 🟩🟩 | Weekly cadence (assumed active per the homepage tagline; not verified to a specific date because the site doesn't expose an issue list timestamp on the landing page). |
| Format quality | 🟩 | Standard developer newsletter — link list with editorial summaries. |
| Approachability | 🟨 | Assumes you already follow Gleam; not a learning resource for beginners. |
| Accessibility | 🟩🟩 | Free, email opt-in. |
| Authority | 🟩 | Community-run, listed in the [Gleam community page](https://gleam.run/community/). |
| Depth | 🟨 | Aggregator. Depth lives in the linked articles, not the issue. |

**Score: 7** — see [leaderboard](#per-guide-leaderboard).

#### Gotchas

- **Issue archive isn't trivially browseable from the landing page** — past issues exist but the public-facing site emphasizes signup over archive navigation. Treat as "subscribe and read going forward."
- **Newsletter ≠ tutorial.** Don't list this as a primary learning resource; list it as a "stay current" channel.

### Discord — chat & community

**Thesis:** the live community channel. Linked from [gleam.run/community/](https://gleam.run/community/) ("Lively and friendly, just like Gleam!"). Where you go when you're stuck, want to bounce ideas, or want to see what real Gleam developers are working on. Maintainers and library authors are present.

- Invite: [discord.gg/Fm8Pwmy](https://discord.gg/Fm8Pwmy) (linked from [gleam.run](https://gleam.run/))
- Authority: official (linked from `gleam.run`)

#### Score

| Criterion | Score | Reason |
| --- | --- | --- |
| Coverage | 🟩🟩 | Anything anyone is working on, asks about, or shipping. |
| Currency | 🟩🟩 | Real-time chat. |
| Format quality | 🟨 | Chat ≠ structured learning material; it's Q&A by nature. |
| Approachability | 🟩🟩 | Friendliness is one of the Gleam community's stated values; beginners are welcomed. |
| Accessibility | 🟩🟩 | Free, requires Discord account. |
| Authority | 🟩🟩 | Maintainers + library authors active. |
| Depth | 🟨 | Per-thread depth varies wildly. Chat doesn't substitute for a tutorial; it accelerates *unblocking* more than *learning*. |

**Score: 10** — see [leaderboard](#per-guide-leaderboard).

#### Gotchas

- **Chat is ephemeral.** Searchable within Discord, but not indexed by Google. Knowledge gets re-discussed because it's hard to find old answers. (GitHub Discussions, also linked from `gleam.run/community/`, is the more permanent alternative.)
- **Time zones.** EU / NA dominate; APAC / SA contributors are less concentrated.

### Lustre — framework-shipped guide

**Thesis:** the most polished framework-shipped guide in the Gleam ecosystem. Written by Hayleigh Thompson (Lustre maintainer). Walks through SPAs, state, side effects, server-side rendering, full-stack apps, and deployments. Plus 20+ runnable examples and three migration cheatsheets (from Elm / React / LiveView).

- URL: [hexdocs.pm/lustre/](https://hexdocs.pm/lustre/) (current docs version 5.6.0 as of snapshot)
- Quickstart: [hexdocs.pm/lustre/guide/01-quickstart.html](https://hexdocs.pm/lustre/guide/01-quickstart.html)
- Source: [github.com/lustre-labs/lustre](https://github.com/lustre-labs/lustre) — 2.3k★, MIT, 933 commits

#### Score

| Criterion | Score | Reason |
| --- | --- | --- |
| Coverage | 🟩 | Covers Lustre fully (SPA + SSR + server-components + deployments + framework cheatsheets). Does not cover Gleam-the-language (you're expected to bring that). |
| Currency | 🟩🟩 | Lustre v5.6.0; framework actively maintained, last announcement 2026-02-16. |
| Format quality | 🟩🟩 | Multi-page narrative guide + 20+ examples + 3 migration cheatsheets + full API reference. The benchmark for ecosystem-shipped docs. |
| Approachability | 🟩 | Beginner-friendly *for someone who has finished the Gleam tour*. Not a Gleam-from-zero doc — a Lustre-from-zero doc. |
| Accessibility | 🟩🟩 | Free, MIT, hosted on HexDocs. |
| Authority | 🟩🟩 | Hayleigh Thompson — Lustre maintainer, multi-time conference speaker, well-known in the BEAM community. |
| Depth | 🟩🟩 | Takes you to "I shipped a full-stack Lustre app." |

**Score: 12** — see [leaderboard](#per-guide-leaderboard).

#### Sections

- Quickstart (counter app, side effects, intro to Model-Message-View)
- Managing state
- Side effects (managed effects, HTTP, etc.)
- Server-side rendering (static HTML)
- Full-stack applications (server + client)
- SPA deployments
- Full-stack deployments
- Cheatsheets: Lustre for Elm devs / for React devs / for LiveView devs

#### Gotchas

- **Lustre is the *only* Gleam framework with a guide of this caliber.** Don't expect comparable polish from other frameworks (Wisp's guide is examples-only; Mist relies on README only).
- **Doesn't teach Gleam.** Pair with the [Language Tour](#official--gleam-language-tour) before tackling.

> [!NOTE]
> Lustre itself is reviewed in the web-apps article — see [`web-and-http/web-apps.md#lustre`](web-and-http/web-apps.md). This entry scores the *guide*, not the library.

### Wisp — framework-shipped guide (examples-only)

**Thesis:** the dominant Gleam HTTP server framework. Documentation strategy is "examples + API docs, no narrative tutorial." Pragmatic, but rougher onboarding than Lustre.

- URL: [hexdocs.pm/wisp/](https://hexdocs.pm/wisp/)
- Examples: [github.com/gleam-wisp/wisp/tree/main/examples](https://github.com/gleam-wisp/wisp/tree/main/examples)
- Source: [github.com/gleam-wisp/wisp](https://github.com/gleam-wisp/wisp)

#### Score

| Criterion | Score | Reason |
| --- | --- | --- |
| Coverage | 🟩 | Covers Wisp's two concepts (handlers, middleware) thoroughly via examples. |
| Currency | 🟩🟩 | Examples kept current with the library. |
| Format quality | 🟨 | **Examples-only — no narrative quickstart guide.** You read commented example code. Functional, but rougher than Lustre's. |
| Approachability | 🟨 | Intermediate. A beginner expecting a "Lustre-quickstart"-shaped tutorial will be surprised by example-driven docs. |
| Accessibility | 🟩🟩 | Free, on HexDocs + GitHub. |
| Authority | 🟩🟩 | Louis Pilfold (the Gleam compiler maintainer) is the primary author. |
| Depth | 🟩 | Goes as deep as the examples (which include real-world topics: routing, middleware, file uploads, JSON, sessions). |

**Score: 9** — see [leaderboard](#per-guide-leaderboard).

#### Gotchas

- **No quickstart in the same shape as Lustre's.** New-user expectation mismatch is real — multiple Discord / forum threads are "where do I start with Wisp?"
- **Examples are well-commented.** Treat the examples directory as the tutorial.

> [!NOTE]
> Wisp itself is reviewed in [`web-and-http/web-apps.md#wisp`](web-and-http/web-apps.md). This entry scores the *guide*.

### YouTube — talks and tutorials

**Thesis:** sparse but real. A handful of conference talks (FOSDEM 2023, GOTO Copenhagen 2024, YOW! Australia 2024, Code BEAM Stockholm 2025, Code BEAM America 2025) and a couple of creator videos (mainly from [Isaac Harris-Holt](https://www.youtube.com/IsaacHarrisHolt)). No multi-hour tutorial series.

#### Score

| Criterion | Score | Reason |
| --- | --- | --- |
| Coverage | 🟨 | Each talk is a slice. Aggregate covers a lot, but no single video is comprehensive. |
| Currency | 🟩 | Newest talks are 2025–early 2026. Older ones (2023) are pre-v1.0 — code may not match current syntax. |
| Format quality | 🟩 | Recorded conference talks are high-production but lecture-shaped, not exercise-shaped. |
| Approachability | 🟨 | Mixed. Some intros ("A Brief Introduction to Gleam," "Gleam for Impatient Devs") are beginner-friendly; conference talks assume background. |
| Accessibility | 🟩🟩 | Free on YouTube. |
| Authority | 🟩 | Mix — conference recordings are well-vetted; creator content is one-person depth. Includes the language creator (Louis Pilfold) and prominent maintainers (Hayleigh Thompson, Giacomo Cavalieri). |
| Depth | 🟨 | Talk-shaped, not tutorial-shaped. Watching a talk doesn't teach you to write Gleam — it sells you on Gleam. |

**Score: 7** — see [leaderboard](#per-guide-leaderboard).

#### Notable videos (sampled — not exhaustive)

- **[Gleam v1 — Programming Language Overview & Tutorial](https://www.youtube.com/watch?v=QMSApGFd3Qo)** (March 2024) — coincides with v1.0 release.
- **[Gleam for Impatient Devs](https://www.youtube.com/watch?v=NyKIvWvr9kw)** by Isaac Harris-Holt (2024-03-17) — fast intro for experienced devs.
- **[A Code Centric Journey Into the Gleam Language](https://www.youtube.com/watch?v=PfPIiHCId0s)** by Giacomo Cavalieri, YOW! Australia 2024.
- **[How I ended up writing Gleam for a living](https://www.youtube.com/watch?v=BfPRcanTWXA)** by Isaac Harris-Holt, Code BEAM Stockholm 2025.
- **[Microcontrollers with Gleam](https://www.youtube.com/watch?v=-jd1lRQ4LZg)** by Ray De Los Santos, Code BEAM America 2025.
- **[Distributed music programming with Gleam](https://fosdem.org/2023/schedule/event/beam_distributed_music_programming_gleam/)** by Hayleigh Thompson, FOSDEM 2023.
- **[Introduction to Gleam](https://fosdem.org/2023/schedule/event/beam_gleam_intro/)** by Harry Bairstow, FOSDEM 2023.
- **[Gleam: First Impressions](https://www.youtube.com/watch?v=4RlS6NnitYs)** (January 2026).
- **[I learned Gleam in a week. Here's how it went](https://www.youtube.com/watch?v=-8OIK4RIUsg)** by Theo Harris.

#### Gotchas

- **Pre-v1.0 talks (2023) may have stale syntax.** The language was mostly stable but some surface details shifted around the v1 release.
- **No paid course, no multi-hour playlist.** If you like long-form video tutorials, Gleam's offering is meager compared to Rust or Elixir.

### Community blog series & one-off articles

**Thesis:** scattered, individual. Notable individuals: Michael Uloth (notes at [michaeluloth.com/gleam/](https://michaeluloth.com/gleam/) — author describes them as "unfinished notes"), Isaac Harris-Holt's blog ([ihh.dev](https://www.ihh.dev/) — blog section exists, content not exhaustively surveyed for this snapshot), occasional pieces on Lindbakk / Serokell / DEV.to / The New Stack. **No canonical "go-read-this" post**; content is one-off.

#### Score

| Criterion | Score | Reason |
| --- | --- | --- |
| Coverage | 🟨 | Per-post narrow; aggregate uneven. |
| Currency | 🟨 | Mixed. Some posts are 2025-26 fresh; many are 2022-23 and refer to pre-v1.0 syntax. |
| Format quality | 🟩 | Standard blog prose, code snippets. Quality varies by author. |
| Approachability | 🟨 | Author-dependent. |
| Accessibility | 🟩🟩 | Free. |
| Authority | 🟨 | Individual creators; no single voice with authoritative weight. |
| Depth | 🟨 | One-shot posts; no series structure equivalent to (e.g.) "Phoenix LiveView Crash Course." |

**Score: 5** — see [leaderboard](#per-guide-leaderboard).

#### Gotchas

- **Half-life of "introduction to a new language" blog posts is short** and Gleam has had multiple "this is what's changing in v1" posts that are now historical.
- **Cherry-pick by date.** Anything pre-v1.0 (March 2024) may have stale syntax (e.g. older `try` syntax replaced by `use`).

### gleam-book (community book attempt)

> [!CAUTION]
> **Stalled since 2022.** Last commit on the `human154/gleam-book` repo is 2022-04-06 — about four years before snapshot. The maintainer has not signalled a return. Do **not** rely on this as a current learning resource. Listed for completeness because it surfaces in Google searches for "Gleam book."

- URL: [github.com/human154/gleam-book](https://github.com/human154/gleam-book)
- 29★, 1 fork, 67 commits, last commit 2022-04-06, license unstated (🟨)

#### Score

| Criterion | Score | Reason |
| --- | --- | --- |
| Coverage | 🟥 | Two chapters — language characteristics + early data examples. Never finished. |
| Currency | 🟥 | Last commit 2022-04-06; ~4 years stale. Predates Gleam v1.0 syntax. |
| Format quality | 🟨 | Markdown chapters; never published to a hosted site. |
| Approachability | 🟨 | Targets beginners; doesn't reach them in any current state. |
| Accessibility | 🟨 | Free on GitHub but no LICENSE file (🟨 unknown). |
| Authority | 🟥 | Single contributor, abandoned. |
| Depth | 🟥 | Stub. |

**Score: −3** — see [leaderboard](#per-guide-leaderboard). Anti-recommended; tracked for transparency.

### gleamprogramming.com (community link directory)

**Thesis:** a small standalone site that links to other Gleam resources. Footer reads "Crafted to be a useful resource • 2025–present." Functions as a thin link directory; mostly redundant with [awesome-gleam](#awesome-gleam--community-index).

- URL: [gleamprogramming.com](https://gleamprogramming.com/)
- Authority: community individual (no author named on the page)

#### Score

| Criterion | Score | Reason |
| --- | --- | --- |
| Coverage | 🟨 | Half a dozen links — gleam.run, docs, tour, GitHub, awesome-gleam, one YouTube tutorial. Nothing awesome-gleam doesn't already cover. |
| Currency | 🟩 | "2025–present" suggests recent maintenance; no per-link last-updated visible. |
| Format quality | 🟨 | Plain link directory. |
| Approachability | 🟩 | Frictionless landing page; no register-to-read. |
| Accessibility | 🟩🟩 | Free. |
| Authority | 🟨 | Unattributed individual. |
| Depth | 🟥 | Pointers, no original content. |

**Score: 3** — see [leaderboard](#per-guide-leaderboard). Redundant with [awesome-gleam](#awesome-gleam--community-index); use awesome-gleam instead.

## Gaps — what doesn't exist yet

What is **not** available for learning Gleam, as of 2026-04-29:

- **No published book.** Not from Manning ("In Action" series), not from O'Reilly, not from Pragmatic Bookshelf, not from No Starch. Verified via direct catalog search. The maintainer's [stated position](https://github.com/gleam-lang/gleam/discussions/2622) is that the [Language Tour](#official--gleam-language-tour) is the substitute.
- **No paid video course.** Not on Udemy, Egghead, Pluralsight, Frontend Masters, Coursera, edX, LinkedIn Learning. Searched 2026-04-29.
- **No university course.** No CS programme the author could find lists Gleam.
- **No "Gleam Cookbook" / recipe site.** The Elixir / Rust / Go ecosystems have these; Gleam doesn't yet. Workaround: read the [Lustre examples directory](https://github.com/lustre-labs/lustre/tree/main/examples) and the [Wisp examples directory](https://github.com/gleam-wisp/wisp/tree/main/examples).
- **No multi-hour YouTube tutorial series.** Closest things are the conference talk archives (Code BEAM, FOSDEM, YOW!) and Isaac Harris-Holt's individual videos.
- **No OTP-on-Gleam dedicated guide.** OTP material is scattered across [hexdocs.pm/gleam_otp](https://hexdocs.pm/gleam_otp/) (API docs, not a tutorial), the language tour's concurrency chapter, and Discord threads.
- **No "advanced patterns" book.** No Gleam equivalent of *Designing Elixir Systems with OTP* or *Programming Phoenix LiveView*.
- **No book-shaped Wisp tutorial.** Wisp's docs are examples-only by design.
- **No Spanish / Mandarin / Portuguese translations of the language tour** (English-only as of snapshot).
- **No Gleam track on freeCodeCamp.**
- **No Gleam content on the Erlang / Elixir podcast circuits with any regularity** (one-off episodes only).

If you want a learning shape that doesn't exist here, **the best chance of finding it is on [Discord](#discord--chat--community)** — someone's likely working on it.

## Per-guide leaderboard

Scored against the [7-dim rubric](#scoring-dimensions). Max score = 14.

| Position | Award | Guide | Cov | Cur | Fmt | App | Acc | Auth | Dep | Score |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 🥇 | [Gleam Language Tour](#official--gleam-language-tour) | 🟩🟩 | 🟩🟩 | 🟩🟩 | 🟩🟩 | 🟩🟩 | 🟩🟩 | 🟩 | **13** |
| 2 | 🥈 | [Exercism Gleam track](#exercism--gleam-track) | 🟩 | 🟩🟩 | 🟩🟩 | 🟩🟩 | 🟩🟩 | 🟩 | 🟩 | **12** |
| 2 | 🥈 | [Lustre guide](#lustre--framework-shipped-guide) | 🟩 | 🟩🟩 | 🟩🟩 | 🟩 | 🟩🟩 | 🟩🟩 | 🟩🟩 | **12** |
| 4 | 🥉 | [Writing Gleam guide](#official--writing-gleam-guide) | 🟩 | 🟩🟩 | 🟩 | 🟩 | 🟩🟩 | 🟩🟩 | 🟩 | **11** |
| 4 | 🥉 | [awesome-gleam](#awesome-gleam--community-index) | 🟩🟩 | 🟩🟩 | 🟩 | 🟩 | 🟩🟩 | 🟩🟩 | 🟨 | **11** |
| 6 | | [Discord](#discord--chat--community) | 🟩🟩 | 🟩🟩 | 🟨 | 🟩🟩 | 🟩🟩 | 🟩🟩 | 🟨 | **10** |
| 7 | | [Cheatsheets](#official--cheatsheets-per-language-migration) | 🟨 | 🟩 | 🟩 | 🟩🟩 | 🟩🟩 | 🟩🟩 | 🟨 | **9** |
| 7 | | [News blog](#official--news-blog-release-notes-as-learning-material) | 🟨 | 🟩🟩 | 🟩 | 🟨 | 🟩🟩 | 🟩🟩 | 🟩 | **9** |
| 7 | | [CodeCrafters Gleam track](#codecrafters--gleam-track) | 🟩🟩 | 🟩 | 🟩🟩 | 🟨 | 🟥 | 🟩🟩 | 🟩🟩 | **9** |
| 7 | | [Wisp guide](#wisp--framework-shipped-guide-examples-only) | 🟩 | 🟩🟩 | 🟨 | 🟨 | 🟩🟩 | 🟩🟩 | 🟩 | **9** |
| 11 | | [Gleam Weekly newsletter](#gleam-weekly--newsletter) | 🟨 | 🟩🟩 | 🟩 | 🟨 | 🟩🟩 | 🟩 | 🟨 | **7** |
| 11 | | [YouTube talks](#youtube--talks-and-tutorials) | 🟨 | 🟩 | 🟩 | 🟨 | 🟩🟩 | 🟩 | 🟨 | **7** |
| 13 | | [Community blog series](#community-blog-series--one-off-articles) | 🟨 | 🟨 | 🟩 | 🟨 | 🟩🟩 | 🟨 | 🟨 | **5** |
| 14 | | [gleamprogramming.com](#gleamprogrammingcom-community-link-directory) | 🟨 | 🟩 | 🟨 | 🟩 | 🟩🟩 | 🟨 | 🟥 | **3** |
| 15 | | [gleam-book](#gleam-book-community-book-attempt) | 🟥 | 🟥 | 🟨 | 🟨 | 🟨 | 🟥 | 🟥 | **−3** |

**One-sentence justifications:**

1. 🥇 **Language Tour** — the de-facto Gleam textbook. Interactive, comprehensive on the language, and maintained by the compiler team in lockstep with releases. Loses one point on Depth because it stops at "you understand the language" rather than "you've shipped a real app" — but that's by design; the [Writing Gleam guide](#official--writing-gleam-guide) and [Lustre guide](#lustre--framework-shipped-guide) cover the next step.
2. 🥈 **Exercism Gleam track** — strongest deliberate-practice resource. Loses on Authority (well-known but not core team) and Depth (language idiom, not full apps). 122 exercises × 33 concepts = the path of most Gleam learners.
2. 🥈 **Lustre guide** — best framework-shipped guide. 20+ examples + narrative + cheatsheets for Elm / React / LiveView refugees. The benchmark for ecosystem documentation in the Gleam world.
4. 🥉 **Writing Gleam guide** — short, focused, official. The natural follow-on to the Language Tour for "now ship something."
4. 🥉 **awesome-gleam** — the canonical index. Not a guide itself, but the discovery layer over every other guide.
6. **Discord** — where you go when stuck. Beats most other resources on Approachability and Authority; loses on Format and Depth because chat isn't pedagogy.
7. **Cheatsheets / News blog / CodeCrafters / Wisp guide** — four very different resources tied at 9. Cheatsheets and News blog: official but narrow-purpose. CodeCrafters: deep and rigorous but paywalled. Wisp guide: well-authored but examples-only (no narrative tutorial).
11. **Gleam Weekly / YouTube talks** — both are stay-current channels rather than learning paths. Useful supplementary, not primary.
13. **Community blog series** — a smear of one-off posts. Useful when you find one that matches your moment, not reliable as a curriculum.
14. **gleamprogramming.com** — thin link directory; redundant with awesome-gleam. Listed for transparency.
15. **gleam-book** — stalled since 2022. Anti-recommended; included so readers searching for "Gleam book" find the warning instead of the dead repo.

> [!IMPORTANT]
> **Recommended path for a new Gleam learner in 2026:**
>
> 1. Read the [Language Tour](#official--gleam-language-tour) end to end (~1 day).
> 2. Start [Exercism's Gleam track](#exercism--gleam-track) (proceed at your pace).
> 3. Read the [Writing Gleam guide](#official--writing-gleam-guide) when you want to ship something (~30 min).
> 4. Pick a framework guide based on what you're building: [Lustre](#lustre--framework-shipped-guide) for frontend / SPA / SSR; [Wisp examples](#wisp--framework-shipped-guide-examples-only) for HTTP backend.
> 5. Join the [Discord](#discord--chat--community) for live questions.
> 6. Skim [Gleam Weekly](#gleam-weekly--newsletter) and [News blog](#official--news-blog-release-notes-as-learning-material) to stay current.
> 7. (Optional, paid) Take on a [CodeCrafters](#codecrafters--gleam-track) challenge for project-driven depth.

## Related reviews

- **[web-and-http/web-apps.md](web-and-http/web-apps.md)** — Lustre, Wisp, Mist, full-stack Gleam web stack. The [Lustre guide](#lustre--framework-shipped-guide) and [Wisp guide](#wisp--framework-shipped-guide-examples-only) entries here score the *guides*; the libraries themselves are reviewed there.
- **[databases.md](databases.md)** — pog, sqlight, cake, squirrel, etc. Database tooling has no dedicated guide of its own; readers learn from Hex docs + each library's README.
- **[authentication.md](authentication.md)** — auth libraries. No tutorial-shaped meta-doc; same per-library README pattern.
- **[parse-and-generate-gleam.md](parse-and-generate-gleam.md)** · **[parse-and-generate-other-languages.md](parse-and-generate-other-languages.md)** · **[openapi.md](openapi.md)** · **[serialization/](serialization/)** — parser combinators, codecs, codegen, ser/deser. Each tool's docs serve as its own guide.
- **[mobile-apps.md](mobile-apps.md)** — building mobile apps with Gleam. No first-party "Gleam mobile" guide exists; that article is the closest reference.
- **[../README.md](../README.md)** — top-level ecosystem reviews index.

> [!NOTE]
> If you're looking for "how do I learn library X in Gleam?", the answer is almost always: **read its HexDocs page**. Most Gleam libraries ship API docs but not narrative tutorials; [Lustre](#lustre--framework-shipped-guide) is the prominent exception. This article scores the rare narrative guides; for per-library API documentation, follow the cross-links into the topic-specific articles above.
