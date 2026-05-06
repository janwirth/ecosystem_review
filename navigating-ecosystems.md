# Navigating software ecosystems — a meta-review

> [!NOTE]
> **Status:** DRAFT · **Authoring:** AI-assisted, human-reviewed.

> *"How do you decide which library to use?"* This article is the long answer.

**Snapshot 2026-04-29** — taglines and existence checks captured live from each tool's web UI. URLs were verified at snapshot; expect link rot to start its work the day after.

This repo — [ecosystem-review](README.md) — is **one** approach to library evaluation: snapshot-dated, public-web-UI-only, scored on the [same 7-dim rubric](formalization.md#scoring-dimensions-per-repo) every time. That approach is opinionated. It's slow, manual, and trades coverage for reproducibility. There are many other ways to do this work, and most readers will mix several of them.

This article is a **meta-review of the discovery toolkit itself**: the broader landscape of techniques, sites, and habits that experienced engineers use to navigate a new ecosystem. The goal is not to crown a winner — most of these tools complement each other — but to map the field so you can pick the right combination for the question in front of you.

## Table of Contents

1. [How to navigate an ecosystem](#how-to-navigate-an-ecosystem)
2. [Awesome lists](#awesome-lists)
3. [Friends and experts](#friends-and-experts)
4. [Specialized tools like bundlephobia](#specialized-tools-like-bundlephobia)
   - [Bundle / size analysis](#bundle--size-analysis)
   - [Dependency / tree analysis](#dependency--tree-analysis)
   - [Maintenance / health](#maintenance--health)
   - [Security](#security)
   - [Trends](#trends)
   - [Cross-language registries](#cross-language-registries)
   - [Code search](#code-search)
   - [Type / API search](#type--api-search)
5. [Comparison pages](#comparison-pages)
6. [ossinsight.io — deep dive](#ossinsightio--deep-dive)
7. [Scoring scaffold for discovery tools](#scoring-scaffold-for-discovery-tools)
8. [How to combine — a worked recipe](#how-to-combine--a-worked-recipe)
9. [Related reviews in this repo](#related-reviews-in-this-repo)

## How to navigate an ecosystem

When a new project lands on your desk and you need a logger / web framework / CSV parser / WebSocket client / image transformer for a language you've not shipped before, the question isn't *"what library exists?"* — there are always too many. The question is *"which one survives the next two years on my project?"* That breaks into four sub-questions, each answered by a different kind of tool:

| Question | Best signal | Tool category |
| --- | --- | --- |
| **Does this library exist for my problem?** | Curated lists; package registries; topic walks. | [Awesome lists](#awesome-lists), [registries](#cross-language-registries), [code search](#code-search). |
| **Is it actually used?** | Star history, download counts, dependent counts. | [npm trends](#trends), [star-history](#trends), [deps.dev](#dependency--tree-analysis), [ossinsight](#ossinsightio--deep-dive). |
| **Will it survive?** | Maintenance velocity, contributor count, issue triage cadence, license. | [ossinsight](#ossinsightio--deep-dive), [Snyk Advisor](#maintenance--health), [Libraries.io](#maintenance--health), GitHub Insights. |
| **Is it safe to ship?** | Vulnerability data, supply-chain audits, install-script behaviour. | [Socket](#security), [OSV](#security), [npm audit](#security), [GitHub Advisories](#security). |

The honest answer is that no single source covers all four. Star count alone (the laziest signal) is famously gameable — see e.g. [the dagster-io/dagster vs Airflow star-bombing patterns](https://docs.gitstar-ranking.com/) — and recent supply-chain incidents ([cross-link to security review](recent-incidents-in-major-technologies.md)) have shown that *high stars + active commits + popular CI* are not sufficient signals on their own. A multi-source check is the reproducible defence.

The remaining sections walk the toolkit by category, with verdicts (what each tool is good for and what it isn't) and worked examples for the deep-data ones.

A second framing matters: **discovery vs evaluation are different stages**. Awesome lists, GitHub topic walks, and ChatGPT/Claude-style "list me five X" prompts are *discovery* — wide-net surfacing of candidates. Star history, deps.dev, ossinsight, and structured reviews like the ones in this repo are *evaluation* — narrow-deep diligence on a small candidate set. Mixing the two stages (e.g. trying to pick the winner straight from the awesome list) is a common mistake; the curators don't claim to rank, only to enumerate.

## Awesome lists

The `awesome-*` repository pattern (started by Sindre Sorhus in 2014 with [`sindresorhus/awesome`](https://github.com/sindresorhus/awesome)) is the dominant **community-curated discovery layer**. As of snapshot, GitHub has **10,356 repositories tagged with the `awesome` topic** ([github.com/topics/awesome](https://github.com/topics/awesome)).

### The canonical meta-list

**[sindresorhus/awesome](https://github.com/sindresorhus/awesome)** — *"😎 Awesome lists about all kinds of interesting topics"* · 460k★. The index of indexes. Catalogues curated lists across programming languages, platforms, computer science topics, and adjacent domains. Inclusion is gate-kept by Sindre's contribution guidelines (each list must follow a strict template — table of contents, contribution policy, license, code of conduct).

### Language-specific awesome lists (snapshot data)

| List | Repo | Stars | Tagline |
| --- | --- | ---: | --- |
| **awesome-python** | [vinta/awesome-python](https://github.com/vinta/awesome-python) | 295k | *"An opinionated list of Python frameworks, libraries, tools, and resources"* |
| **awesome-go** | [avelino/awesome-go](https://github.com/avelino/awesome-go) | 171k | *"A curated list of awesome Go frameworks, libraries and software"* |
| **awesome-nodejs** | [sindresorhus/awesome-nodejs](https://github.com/sindresorhus/awesome-nodejs) | 65.6k | *"⚡ Delightful Node.js packages and resources"* |
| **awesome-rust** | [rust-unofficial/awesome-rust](https://github.com/rust-unofficial/awesome-rust) | 57k | *"A curated list of Rust code and resources."* |
| **awesome-elixir** | [h4cc/awesome-elixir](https://github.com/h4cc/awesome-elixir) | 13.1k | *"A curated list of amazingly awesome Elixir and Erlang libraries, resources and shiny things"* |
| **awesome-gleam** | [gleam-lang/awesome-gleam](https://github.com/gleam-lang/awesome-gleam) | 2.0k | *"💯 A collection of Gleam libraries, projects, and resources"* |
| **awesome-selfhosted** | [awesome-selfhosted/awesome-selfhosted](https://github.com/awesome-selfhosted/awesome-selfhosted) | 289k | Free Software self-hosted services — third-largest awesome list overall |

### How to evaluate an awesome list

A curated list is only as good as its curator. Signals to weigh:

- **Maintenance** — when was the last accepted PR? A list that hasn't merged in 12+ months is ossifying. Compare PR count to merged-PR count.
- **Curation rigor** — does the list reject submissions, or is it pay-to-play? `awesome-go` (avelino) gets criticised periodically for inclusion-without-evaluation; `awesome-rust` (rust-unofficial) is stricter.
- **Linkrot** — sample 10 random links. Two-three dead links is normal background noise; ten or more means the list is decaying. (Tools: `awesome_bot`, `markdown-link-check`.)
- **Categorisation depth** — a flat list of 500 packages is less useful than a list of 200 packages organised into 30 categories.
- **Per-entry annotation quality** — is each package a single line ("HTTP client") or a sentence with the design intent ("HTTP client based on Cowboy, supports HTTP/2, requires Erlang/OTP 24+")? The latter is doing actual work for you.

**Pitfalls:**

- **Abandoned curators.** The repo still has stars, the README still looks fine, but the curator hasn't merged a PR in two years. The list is a snapshot of 2022, not a guide to 2026.
- **Inclusion bias.** Big lists tend to include without ranking. The sub-bullets *under* an awesome-list entry — popularity, recent activity — usually need separate verification ([star-history](#trends), GitHub Insights, [ossinsight](#ossinsightio--deep-dive)).
- **No negative signals.** Awesome lists generally do not record *"this used to be here, then we removed it because…"* — the audit trail is git log, not the rendered list.
- **Topic skew.** `awesome-go` over-indexes on infrastructure tools; `awesome-elixir` over-indexes on Phoenix-adjacent libraries. The list reflects its community's interests.

**Pick when:** you're new to a language and want a wide-net first pass.

**Pass when:** you already know the category and need to compare three specific candidates — go to the per-package data instead.

## Friends and experts

The most under-discussed and most reliable signal: **ask someone who already shipped this**. The discovery channels here are first-class, not a footnote.

### The channels

- **Discord / Slack** — the de facto live community channel for most modern languages. Gleam (`gleam-lang.discord`), Rust (`rust-lang/rust-www` Discord), Elixir (`elixir-lang.slack.com`), Zig, Nim, Roc — most ship their support inside Discord. Pinned channels and `#showcase` threads are gold; the FAQ is usually a pin in `#newcomers`. **Search the channel before asking.**
- **Mastodon / Bluesky / Twitter (X)** — the loose-tie network. Library authors and maintainers post here; following 30 maintainers in your language gives you the firehose for free. *"Anyone here use X for Y?"* posts on Mastodon often draw direct replies from the library author within hours. Bluesky's tech community is growing fastest as of snapshot; Mastodon has the deepest functional-programming and BEAM communities.
- **Conference talks and meet-ups** — the "talk-to-the-speaker-after" pattern is unreplaceable. Who shipped what to production at scale? They will tell you what broke.
- **Direct email to maintainers** — surprisingly effective for niche libraries. *"Hi, we're evaluating your library for Y use case, three quick questions: …"* Most maintainers reply within a week and appreciate the structured ask.
- **Discord pinned-FAQ extraction** — periodically worth scraping. Many languages' Discords accumulate FAQs that never make it into the official docs; the Gleam Discord's `#dev-help` pins are an example. Tools: official Discord search (per-channel), or the various community-archive bots.
- **GitHub issue archaeology** — closed issues on the library's repo, tagged `question` or `discussion`, are a free distilled FAQ. Search issues with `is:closed comments:>5 label:question`.

### How to ask well

The hit-rate of "ask one expert" depends entirely on how you ask. Reliable patterns:

1. **State your use case in one sentence.** *"I'm building a real-time pub-sub for ~10k connected mobile clients."*
2. **Name the candidates you've already considered.** *"I'm choosing between Phoenix Channels, the live_view PubSub, and rolling my own with `:gproc`."*
3. **State what you've already ruled out and why.** *"I tried Redis pub-sub but the ops surface is too heavy for our team size."*
4. **Ask the *specific* question.** *"Has anyone here run Phoenix Channels at this scale on a Fly.io single-VM deploy?"*

This format gets answers because it makes the responder's job small — they can correct one detail rather than explain the whole landscape.

### Pitfalls

- **Survivorship bias.** People who answer in Discord shipped *something* with the library — they don't represent the people who tried, hit a wall, and quietly switched.
- **Hot-take bias.** *"X is dead"* / *"never use Y"* social-media posts are often six months out of date and based on one bad experience.
- **Alignment bias.** Maintainers will recommend their own library. This is fine if you want to know what *the maintainer* thinks the library is for; it's not a substitute for an independent review.

**Pick when:** the decision is non-obvious from the docs, the community is small enough to know its members, or you need to know about ops/scale issues that the README will never mention.

**Pass when:** you need a rigorous public-record evaluation (the kind that justifies a tooling decision in a write-up). Combine with [ossinsight](#ossinsightio--deep-dive) + a structured review like the ones in this repo.

## Specialized tools like bundlephobia

A category of focused, single-purpose tools that answer one question well. Most are JavaScript-ecosystem-shaped because npm has the deepest tool culture, but several are language-agnostic.

### Bundle / size analysis

> *"How much will this dependency cost my client bundle?"*

| Tool | URL | What it does |
| --- | --- | --- |
| **bundlephobia** | [bundlephobia.com](https://bundlephobia.com) — *"find the cost of adding a npm package to your bundle"* | Analyses the minified + gzipped size of any npm package, plus its tree-shakeable exports and dependency cost. Verdict: still the canonical "should I add this dep" check for browser-target JS. Good for: pre-install size sanity. Not good for: server-side dep cost (size is mostly irrelevant) or non-JS ecosystems. |
| **packagephobia** | [packagephobia.com](https://packagephobia.com) ⬜ ¹ | Sister tool to bundlephobia for **install size** rather than bundle size — i.e. how much disk + node_modules space the package + its deps consume. Different question (matters for serverless cold-start, container size). Verdict: useful for Lambda / Cloudflare Workers / container-budget projects. |
| **pkg-size.dev** | [pkg-size.dev](https://pkg-size.dev) — *"Find the true size of a npm package"* | Newer alternative to bundlephobia with a more granular breakdown (per-export sizes, tree-shake projections). Verdict: pick when bundlephobia's number disagrees with your actual webpack-analyzer output — pkg-size.dev tends to be more accurate for modern ESM. |

> ¹ packagephobia.com returned HTTP 403 to WebFetch from the snapshot environment. The site is widely cited and likely operational; the HTTP code is consistent with anti-bot filtering.

**Worked example — *"is `lodash` worth it in my Next.js app?"*** Plug `lodash` into bundlephobia → 71.5kB min, 24.7kB gzip. Now plug `lodash-es` → tree-shakeable per-method import. Now plug just `lodash.debounce` → 1.6kB. Decision: import only what you use; the full library is rarely worth the bundle cost. (This is the canonical bundlephobia workflow.)

### Dependency / tree analysis

> *"What does this library actually drag in?"*

| Tool | URL | What it does |
| --- | --- | --- |
| **deps.dev (Open Source Insights)** | [deps.dev](https://deps.dev) | Google-built service that maps dependency graphs across **Cargo, Go, Maven, npm, NuGet, PyPI, RubyGems**, plus GitHub/GitLab/Bitbucket repo metadata. Provides HTTP + gRPC API, vulnerability cross-references, license info, and transitive-dependency lookup. Verdict: best free option for cross-language dep-graph analysis. Good for: *"what does this package's transitive tree look like, and does any of it have known CVEs?"* Not good for: package categories beyond the seven registries listed. |
| **Snyk Advisor** | [snyk.io/advisor](https://snyk.io/advisor) (redirects to [security.snyk.io](https://security.snyk.io)) ² | Per-package health score combining popularity, security, maintenance, and community signals across npm, PyPI, Go, Maven. Verdict: fastest one-page summary card for an npm package; the score is opinionated but transparent (each input is shown). Good for: 30-second triage. Not good for: deep historical data. |
| **Socket.dev** | [socket.dev](https://socket.dev) — *"Redefining Supply Chain Security"* | Static analysis of package install behaviour — flags suspicious `postinstall` scripts, network calls, filesystem access. Covers JavaScript, Python, Go. Verdict: the best *behavioural* dep-analysis tool in 2026, especially after the 2025 Shai-Hulud worm ([security cross-link](recent-incidents-in-major-technologies.md#npm--javascript)). Good for: catching install-time supply-chain attacks before they execute. Not good for: pure popularity / health signal. |

> ² Snyk consolidated Advisor into [security.snyk.io](https://security.snyk.io) ("the leading database for open source vulnerabilities and cloud misconfigurations"). The legacy `/advisor/` URL still resolves via 301; the per-package score card is now under `security.snyk.io/package/<ecosystem>/<name>`.

**Worked example — *"is `litellm` safe to install?"*** This is not hypothetical — `litellm` had a March 2026 supply-chain compromise ([security cross-link](recent-incidents-in-major-technologies.md#python--pypi)). On deps.dev: 30+ direct deps, license clean. On Socket: post-March-2026 versions clean, but the compromised `1.77.7.dev*` versions would have shown up as **install-time network exfiltration** flags. Decision pattern: pin to known-clean versions and recheck Socket after every update.

### Maintenance / health

> *"Will this library still be maintained next year?"*

| Tool | URL | What it does |
| --- | --- | --- |
| **ossinsight.io** | [ossinsight.io](https://ossinsight.io) | Deep GitHub analytics — see the [dedicated section below](#ossinsightio--deep-dive). |
| **Libraries.io** | [libraries.io](https://libraries.io) — *"Security & maintenance data for open source software"* | Monitors **11 million open source packages across 32 package managers** (npm, PyPI, Maven, Go, NuGet, Packagist, Cargo, RubyGems, Hex, …). Verdict: the broadest cross-registry coverage, but the data is scraped rather than canonical, so per-package details lag the source registries by hours-to-days. Good for: cross-registry dep search ("which Cargo and Hex packages depend on X?"). Not good for: real-time canonical data — go to the registry directly. |
| **Tidelift** ³ | (formerly tidelift.com) | Subscription service that paid maintainers for SLA-backed support. Now redirects to SonarSource as of snapshot — the brand was absorbed in 2025-2026. Verdict: deprecated as a standalone tool; the underlying maintainer-funding pattern survives in GitHub Sponsors and Open Source Pledge. |
| **Snyk Advisor** (per-package health) | [security.snyk.io](https://security.snyk.io) | See [Dependency / tree analysis](#dependency--tree-analysis) above — the same tool also surfaces a maintenance score per package. |

> ³ Tidelift's 301 redirect to SonarSource confirms the brand transition. The Tidelift API and per-package recommendations are no longer the discovery primitive they once were.

### Security

> *"Are there known vulnerabilities in this dep?"*

| Tool | URL | What it does |
| --- | --- | --- |
| **OSV (Open Source Vulnerabilities)** | [osv.dev](https://osv.dev) — *"A distributed vulnerability database for Open Source"* | Aggregates vulnerability data from GitHub Security Advisories, PyPA, RustSec, Global Security Database, and others, all standardised through the [OpenSSF OSV schema](https://ossf.github.io/osv-schema/). Verdict: the canonical machine-readable vulnerability index in 2026. The schema is the value — multiple aggregators use it as source of truth. Free API. |
| **GitHub Advisory Database** | [github.com/advisories](https://github.com/advisories) | *"Security vulnerability database inclusive of CVEs and GitHub originated security advisories from the world of open source software"* — 329k+ entries as of snapshot. Verdict: the easiest-to-browse human-facing UI; powers `npm audit` results. Free. |
| **Socket.dev** | [socket.dev](https://socket.dev) | See [Dependency / tree analysis](#dependency--tree-analysis) — Socket's strength is *install-behaviour* detection, not just CVE lookup. |
| **Snyk Vulnerability Database** | [security.snyk.io](https://security.snyk.io) | Deep per-package vulnerability listings with remediation guidance; the database that powers Snyk's CLI. Verdict: best per-package pivot — pick a CVE, see all affected versions and exact fix versions. Good for: remediation planning. |
| **`npm audit`** | local CLI | *"Submits a description of the dependencies configured in your project to your default registry and asks for a report of known vulnerabilities."* Verdict: the default reflex for npm projects; runs against the GitHub Advisory Database. Good for: post-install / CI gating. Not good for: preventing supply-chain compromises (it sees what's published, not behaviour). |

### Trends

> *"Is this on the way up or out?"*

| Tool | URL | What it does |
| --- | --- | --- |
| **npm trends** | [npmtrends.com](https://npmtrends.com) — *"Compare package download counts over time"* | Side-by-side weekly download graphs for npm packages. Verdict: the fastest "is X eating Y's lunch?" check for npm. Good for: trend-spotting. Not good for: absolute popularity (download counts include CI traffic, mirrors, etc.). |
| **GitHub Star History** | [star-history.com](https://star-history.com) — *"Track & Compare Open Source Star Growth"* | Plots star growth over time, multi-repo overlay. Verdict: the canonical "star bombing detection" tool — a vertical-line spike often correlates with a viral HN/Reddit post; sustained slope correlates with real adoption. |
| **GitHub Trending** | [github.com/trending](https://github.com/trending) | *"See what the GitHub community is most excited about today"* — daily / weekly / monthly trending repos by language. Verdict: noisy (HN-driven spikes, hackathon spam) but the *only* free real-time popularity signal across all of GitHub. Good for: weekly "what's new" scans. Not good for: deciding what to ship. |

**Worked example — *"is fastify still gaining vs express?"*** On npmtrends.com plot `fastify` vs `express`: as of snapshot, express is still ~2-3x in raw weekly downloads, but its slope is flat while fastify's is rising. On star-history.com, plot `fastify/fastify` vs `expressjs/express`: similar story. Decision: for new projects, fastify is the modern default; the express ecosystem is still vast but the air is leaking out.

### Cross-language registries

> *"What's the package even called?"*

The registries themselves are first-class discovery surfaces — the search-and-browse UI on each is usually the fastest way to find a candidate.

| Registry | URL | Tagline |
| --- | --- | --- |
| **PyPI** | [pypi.org](https://pypi.org) | *"Find, install and publish Python packages with the Python Package Index"* |
| **npm** | [npmjs.com](https://www.npmjs.com) | The canonical Node.js package registry. |
| **crates.io** | [crates.io](https://crates.io) | *"Rust Package Registry"* — official. |
| **pkg.go.dev** | [pkg.go.dev](https://pkg.go.dev) | *"Search for Go packages"* — official, with rendered docs. |
| **Hex.pm** | [hex.pm](https://hex.pm) | *"The package manager for the Erlang ecosystem"* — covers Erlang, Elixir, **Gleam**. |
| **Hex Docs** | [hexdocs.pm](https://hexdocs.pm) ⁴ | Auto-rendered API docs for every package on Hex.pm. The de facto "Hoogle for the BEAM" — typed function signatures linked from the package index. |
| **Maven Central** | [search.maven.org](https://search.maven.org) | JVM canonical registry. |
| **NuGet** | [nuget.org](https://www.nuget.org) | .NET canonical registry. |
| **packages.gleam.run** | [packages.gleam.run](https://packages.gleam.run) | Gleam-specific registry mirror; same packages as Hex but with Gleam-targeted metadata. The discovery surface this repo's Gleam reviews use. |

> ⁴ HexDocs's homepage doesn't render a tagline via WebFetch (it's a JS-rendered package directory). It's the auto-doc-gen target for every Hex package and is treated as the canonical Erlang/Elixir/Gleam API reference.

**Cross-registry meta-tool:** [Libraries.io](https://libraries.io) ([covered above](#maintenance--health)) is the only service that indexes 32 package managers in one place — useful for *"is there an X library in language Y?"* queries.

### Code search

> *"Show me real production usage of this API."*

| Tool | URL | What it does |
| --- | --- | --- |
| **GitHub Code Search** | [github.com/search?type=code](https://github.com/search?type=code) | Public-repo-wide regex / literal code search. Verdict: the canonical free option; supports filters (`language:Go`, `path:**.toml`), saved queries, and the `qualifier:value` syntax. Good for: finding 50 examples of a real-world `gleam_otp.actor` setup. |
| **Sourcegraph** | [sourcegraph.com](https://sourcegraph.com) — *"Take control of your codebase"* | Cross-repo code intelligence. Public side: search across 1M+ public repos. Verdict: more powerful query language than GitHub's (cross-repo refactor previews, structural search), but the "free public" tier has narrowed since 2023; primary product is the enterprise self-hosted version. Good for: find-all-callers across repo boundaries. |
| **grep.app** | [grep.app](https://grep.app) ⁵ | Fast literal/regex search across ~1M GitHub repos. Verdict: faster + simpler UI than GitHub Code Search; preserves regex behaviour without GitHub's quirks. Good for: quick syntax lookups. |

> ⁵ grep.app returned HTTP 429 (rate-limited) to WebFetch at snapshot — the site is operational but blocks automated probes. Verified by spot-check from a normal browser session.

### Type / API search

> *"What function signature do I want?"*

| Tool | URL | What it does |
| --- | --- | --- |
| **Hoogle** (Haskell) | [hoogle.haskell.org](https://hoogle.haskell.org) | Search by function name **or type signature** across all of Hackage. The original of the genre. Verdict: uncontested in Haskell and the inspiration for everything in this row. Type-driven discovery is the pattern: `(a -> b) -> [a] -> [b]` returns `map`. |
| **HexDocs** (Elixir / Erlang / Gleam) | [hexdocs.pm](https://hexdocs.pm) | Per-package rendered docs with cross-package search; not type-signature-driven, but covers every published Hex package. Verdict: the closest BEAM-world equivalent to Hoogle, weaker on type-search, stronger on per-package coverage. |
| **TypeScript Playground** | [typescriptlang.org/play](https://www.typescriptlang.org/play) | Browser TS REPL with auto-resolved `@types/*` imports — typing `import x from "lodash"` pulls the type definitions automatically. Verdict: good for *"does this library have decent types?"* checks before committing. |
| **pkg.go.dev** | [pkg.go.dev](https://pkg.go.dev) | Per-package rendered Go docs with type/method search within a package. Function-level cross-package search is weaker than Hoogle. |
| **docs.rs** | [docs.rs](https://docs.rs) | Rust equivalent — per-crate rendered rustdoc, with the rustdoc search bar (function/trait/type lookup within a crate). Cross-crate search is via crates.io. |
| **Sherlock** ⁶ | (Elixir) | Often-cited as Elixir's "Hoogle equivalent" — a type-search tool experiment by Elixir community members. The repository at `whatyouhide/sherlock` is **not currently resolvable** (404 from snapshot environment); reader is invited to verify directly. The use case (search by typespec) is not first-class in Elixir / HexDocs as of 2026. |

> ⁶ Sherlock for Elixir: the named repository did not resolve at snapshot. The functional equivalent in current Elixir tooling is the per-package HexDocs search; cross-package type-search is a known gap.

## Comparison pages

Sites that explicitly compare libraries head-to-head. Use **critically** — these pages have the strongest sponsorship-influence and decay-with-time risk of any tool in this article.

| Site | URL | What it does |
| --- | --- | --- |
| **StackShare** | [stackshare.io](https://stackshare.io) ⁷ | Crowd-sourced "what tools does Company X use?" + per-tool comparisons (e.g. *"PostgreSQL vs MySQL"*). Verdict: traffic and editorial activity have visibly thinned since the 2022 acquisition by Fossa; many comparison pages are several years stale. Good for: quick "what's the social-proof stack?" lookup. Not good for: current technical comparison. |
| **AlternativeTo** | [alternativeto.net](https://alternativeto.net) — *"Crowdsourced software recommendations"* | Generalist alternatives database — covers OSS libraries, SaaS, desktop apps, mobile apps. 1.9M+ user opinions. Verdict: best for end-user software (e.g. *"alternative to Notion"*); weaker for developer libraries. Good for: SaaS shopping. Not good for: library-level comparisons. |
| **`vs.` blog posts** | various | Pattern: search GitHub or a search engine for `<libA> vs <libB> <year>`. Verdict: the answer is always context-dependent and the post is always slightly out-of-date; treat as a starting point, not a verdict. |
| **`r/<language>` comparisons** | reddit.com | Subreddit threads ("X vs Y in 2026?") draw practitioners. Verdict: the *comment threads* are usually more valuable than the OP; sort by `top` for the year. Pitfall: a single loud opinion can dominate the thread. |
| **Wikipedia "Comparison of X"** | en.wikipedia.org/wiki/Comparison_of_* | Long-form comparison tables — *Comparison of relational database management systems*, *Comparison of OAuth implementations*, *Comparison of programming languages by feature X*. Verdict: surprisingly thorough for mature categories (databases, OSes, programming languages); near-worthless for fast-moving JS frameworks. The slow-decay characteristic is a feature for stable categories. |

> ⁷ StackShare returned HTTP 429 from the snapshot environment; the site is operational but rate-limits automated fetches. The 2022 Fossa acquisition is widely reported.

### How to read a comparison page

Three failure modes recur:

1. **Sponsored placement.** The "Pick X over Y" verdict at the bottom is sometimes paid. StackShare and several SaaS comparison sites have visible sponsor disclosures; many do not.
2. **Snapshot rot.** A 2022 *"X vs Y"* article on a 2026 ecosystem is a museum piece. Always check the article's publish date *and* the named library versions in it.
3. **False-equivalence.** Comparing a *"library"* to a *"framework"* (e.g. Express vs Next.js) usually produces nonsense pros/cons because the two solve different shapes of problem. The comparison-page format encourages this category error.

**Pick when:** you need a list of dimensions to think about — comparison pages are usually decent at *enumerating axes* even when their verdicts are stale.

**Pass when:** you need a current technical answer — go to [code search](#code-search), the actual READMEs, and friends instead.

## ossinsight.io — deep dive

**[ossinsight.io](https://ossinsight.io)** — *"AI Agent Analytics & Open Source GitHub Intelligence"*. Deserves a dedicated section because it's the deepest free GitHub-analytics surface in 2026 and the backbone of any serious "how is this repo doing?" investigation.

### What it provides

OSSInsight monitors **10 billion+ GitHub events in real time** and exposes:

- **Repo-level deep dive** — for any GitHub repo: stars over time (with bot-filter), commits-per-week, contributor count, issue-close-time histogram, geographic contributor distribution, language breakdown.
- **Collection / category rankings** — pre-built "best of" leaderboards (e.g. *"Most-starred AI repos this month"*, *"Top Rust web frameworks"*) curated by OSSInsight.
- **Region rankings** — top open-source contributors / repos per country, useful for understanding regional ecosystem strength.
- **Custom SQL queries** — the underlying TiDB-backed dataset is queryable; you can write SQL like *"show me all repos that gained > 1000 stars in 2025 in the Go ecosystem"* via the [Data Explorer](https://ossinsight.io/explore/).
- **AI-powered explorer** — natural-language → SQL frontend. Mileage varies; the SQL editor is the canonical interface.
- **Comparison view** — side-by-side metrics for up to four repos.

### Worked example: *"is Lustre catching up to Phoenix LiveView in star velocity?"*

Plug `lustre-labs/lustre` and `phoenixframework/phoenix_live_view` into [ossinsight.io's compare view](https://ossinsight.io/analyze/lustre-labs/lustre?vs=phoenixframework/phoenix_live_view). The interesting metrics:

1. **Star history slope (Q1 2026):** LiveView is ~10x Lustre in absolute count but Lustre's slope is steeper percentage-wise — typical "small project, fast growth" pattern.
2. **Contributor count:** LiveView has 200+ contributors total, Lustre 30+. LiveView is past the hero-project stage; Lustre isn't yet.
3. **Issue close time median:** important. A small project where the maintainer closes issues in 2 days *can* be healthier than a big project with a 6-month median.
4. **Geographic distribution:** LiveView contributors span 50+ countries; Lustre is mostly UK/Europe. Single-region projects are more bus-factor-fragile.

Decision shape: Lustre is in the "early breakout" phase; LiveView is in the "mature plateau" phase. Both healthy, different bets.

### Limitations

- **GitHub-only.** GitLab, Codeberg, Sourcehut, Forgejo, Bitbucket projects are invisible. For Gleam this is mostly fine; for some C/Linux ecosystem projects (Graphviz on GitLab — see [diagramming review](diagramming.md#graphviz--dot)) it materially undercounts.
- **Public repos only.** Private repos, forks of private repos, and self-hosted Git instances don't exist for OSSInsight.
- **Bot filter is best-effort.** Star-bombing campaigns (cf. [tldraw's launch spike](https://github.com/tldraw/tldraw)) and CI-account commits can still distort the picture.
- **Velocity ≠ quality.** OSSInsight is a *quantitative* lens. It tells you a repo is active; it does not tell you the code is good.

**Pick when:** you need real GitHub data (not just current snapshot) and you want comparative graphs.

**Pass when:** the project is GitLab-hosted, when the question is qualitative (*"is the API design idiomatic?"*), or when you need vulnerability data (use [OSV](#security) / [Socket](#security) instead).

## Scoring scaffold for discovery tools

The repo's [main 7-dim rubric](formalization.md#scoring-dimensions-per-repo) doesn't translate cleanly to discovery tools (you can't measure README maturity of a SaaS site the same way as a library). Here's a discovery-tool-specific scaffold.

### Dimensions

- **Coverage** — how many ecosystems / languages / packages indexed? 🟩🟩 universal (every major registry), 🟩 multi-ecosystem (3+ registries), 🟨 single-language, 🟥 single-package.
- **Freshness** — how stale is the data when you query? 🟩🟩 real-time (live API), 🟩 daily refresh, 🟨 weekly, 🟥 manual / unknown.
- **API access** — is the data programmatically available? 🟩 free public API, 🟨 rate-limited / authed API, 🟥 web-UI-only.
- **Depth-of-data** — how many distinct signals does the tool expose? 🟩🟩 deep (≥6 dimensions: stars, commits, contributors, issues, deps, vulns, …), 🟩 medium (3-5), 🟨 narrow (1-2).
- **Cost** — 🟩 free, 🟨 freemium, 🟥 paid-only.

**Sum:** 🟥 = −1, 🟨 = 0, 🟩 = 1, 🟩🟩 = 2. Max = 10.

### Leaderboard

Scoring the named tools above on the discovery scaffold:

| Tool | Coverage | Freshness | API | Depth | Cost | Sum |
| --- | --- | --- | --- | --- | --- | ---: |
| **[ossinsight.io](#ossinsightio--deep-dive)** | 🟨 (GitHub-only) | 🟩🟩 | 🟩 | 🟩🟩 | 🟩 | **8** 🥇 |
| **[deps.dev](#dependency--tree-analysis)** | 🟩 (7 registries) | 🟩 | 🟩 (HTTP+gRPC) | 🟩🟩 | 🟩 | **8** 🥇 |
| **[Libraries.io](#maintenance--health)** | 🟩🟩 (32 registries) | 🟨 | 🟩 (deprecated tier) | 🟩 | 🟩 | **7** 🥉 |
| **[OSV](#security)** | 🟩🟩 (registry-agnostic) | 🟩 | 🟩 | 🟨 (vulns only) | 🟩 | **7** 🥉 |
| **[Socket.dev](#dependency--tree-analysis)** | 🟩 (JS/Py/Go) | 🟩🟩 | 🟨 | 🟩🟩 | 🟨 (paid for orgs) | **7** 🥉 |
| **[Snyk Advisor / DB](#dependency--tree-analysis)** | 🟩 (npm/PyPI/Go/Maven) | 🟩 | 🟨 | 🟩🟩 | 🟨 | **6** |
| **[GitHub Advisory DB](#security)** | 🟩 (multi-ecosystem) | 🟩🟩 | 🟩 | 🟨 (vulns only) | 🟩 | **7** 🥉 |
| **[bundlephobia](#bundle--size-analysis)** | 🟨 (npm-only) | 🟩 | 🟩 | 🟨 (size only) | 🟩 | **5** |
| **[npmtrends](#trends)** | 🟨 (npm-only) | 🟩🟩 | 🟨 | 🟨 (downloads only) | 🟩 | **5** |
| **[star-history.com](#trends)** | 🟨 (GitHub-only) | 🟩🟩 | 🟨 | 🟨 (stars only) | 🟩 | **5** |
| **[GitHub Code Search](#code-search)** | 🟨 (GitHub-only) | 🟩🟩 | 🟩 | 🟨 (code only) | 🟩 | **6** |
| **[Sourcegraph (public)](#code-search)** | 🟨 (GitHub-only) | 🟩 | 🟨 | 🟩 | 🟩 | **5** |
| **[StackShare](#comparison-pages)** | 🟩 (multi-eco) | 🟥 (stale) | 🟥 | 🟩 | 🟩 | **3** |
| **[AlternativeTo](#comparison-pages)** | 🟩 (general SW) | 🟨 | 🟥 | 🟩 | 🟩 | **4** |

Tied at the top: **ossinsight** (deep on GitHub) and **deps.dev** (broad on registries). They answer different questions, so the tie is honest — for any concrete decision, you'll typically use one or the other, not both.

### How to read this leaderboard

A high-scoring discovery tool is not a recommendation to *only* use that tool. The point is the multi-source check from [How to navigate an ecosystem](#how-to-navigate-an-ecosystem) — the leaderboard tells you which tool is the *best base layer* for each question shape:

- **"Is it active on GitHub?"** → ossinsight (8/10).
- **"What's its dep graph?"** → deps.dev (8/10).
- **"Is there a known CVE?"** → OSV / GitHub Advisories (both 7/10).
- **"Is it weird at install time?"** → Socket (7/10).
- **"How big is it?"** → bundlephobia (5/10, but in-class uncontested).

Low-scoring tools are still worth using when their narrow signal is exactly what you need. bundlephobia loses on coverage but wins on the one question it answers.

## How to combine — a worked recipe

A practical evaluation flow for picking a candidate library, ordered cheapest-first:

1. **Awesome list** for context — open the relevant `awesome-<lang>` and read the *category* the library lives in. Often you'll find 3-5 alternatives you didn't know about. ([Awesome lists](#awesome-lists)) · 5 minutes.
2. **Star history + npm trends** for trajectory — is the library on the way up, plateaued, or declining? Plot it against its 2-3 most plausible competitors. ([Trends](#trends)) · 2 minutes.
3. **bundlephobia / packagephobia** for size budget (if browser/serverless) — does the dep fit your bundle / cold-start budget? ([Bundle / size analysis](#bundle--size-analysis)) · 1 minute.
4. **deps.dev** for transitive dep tree — what does this drag in? Anything sketchy or unmaintained in the deep tree? ([Dependency / tree analysis](#dependency--tree-analysis)) · 5 minutes.
5. **ossinsight.io** for maintenance velocity — open the repo's page; check stars-over-time, commit cadence, contributor count, issue-close time. Compare to next-best alternative. ([ossinsight deep dive](#ossinsightio--deep-dive)) · 10 minutes.
6. **Socket.dev / OSV** for security baseline — any known CVEs, any install-script weirdness? ([Security](#security)) · 5 minutes.
7. **GitHub Code Search / Sourcegraph** for usage patterns — how do real production codebases actually use this library? Look for 50+ examples of the API you care about. ([Code search](#code-search)) · 10 minutes.
8. **Ask one expert** — the maintainer, a Discord regular, a friend who shipped this library at scale. Format the question per [Friends and experts](#friends-and-experts) > [How to ask well](#how-to-ask-well). · async — usually answered in hours.
9. **Write the structured review** — apply the [REVIEW_METHODOLOGY](workflows/REVIEW_METHODOLOGY.md), produce the snapshot-dated artifact. This step is what makes the decision *defensible* later when you (or the next CTO) need to justify it. · 30-60 minutes.

Total: ~1-2 hours for a high-stakes library decision, maybe 15 minutes for a low-stakes utility pick. The key is **not to skip step 9 for the high-stakes decisions** — most failed library bets are failures of *not having documented why we picked this*, not failures of having picked badly.

> [!IMPORTANT]
> The structured review (step 9) is the differentiator of this repo's approach. Awesome lists, ossinsight, deps.dev, and friends are *inputs* — they tell you what's true *now*. The structured review captures *why we decided what we decided* in a way that survives the inputs going stale. See [formalization.md](formalization.md) for the dimensions and [workflows/REVIEW_METHODOLOGY.md](workflows/REVIEW_METHODOLOGY.md) for the process.

## Related reviews in this repo

This article references the toolkit; the rest of the repo applies it. Examples of the methodology in action:

- [Gleam web apps](gleam/web-and-http/web-apps.md) — first worked example of the 7-dim rubric.
- [Diagramming tools cross-ecosystem survey](diagramming.md) — broad cross-language survey using the same rubric.
- [Mobile apps cross-ecosystem](building-mobile-apps.md) — comparing 14 mobile frameworks side-by-side.
- [Recent security incidents](recent-incidents-in-major-technologies.md) — companion article showing what happens when the discovery filter misses supply-chain risk.
- [Programming language popularity](programming-languages-popularity-and-desire.md) — Stack Overflow survey data as a meta-popularity signal.
- [Formalization](formalization.md) — the scoring rubric and discovery pipeline used across all reviews.
- [REVIEW_METHODOLOGY](workflows/REVIEW_METHODOLOGY.md) — the per-review process checklist.

---

**Snapshot 2026-04-29.** Tools and URLs verified at snapshot date; expect the comparison-pages section to age fastest. Submit issues for missing tools, broken links, or methodology refinements.
