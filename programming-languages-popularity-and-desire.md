# Programming language popularity & desire

> [!NOTE]
> **Status:** DRAFT · **Authoring:** AI-assisted, human-reviewed.

**Snapshot 2026-05-06** — data from [Stack Overflow Developer Survey 2025](https://survey.stackoverflow.co/2025/technology).

Two numbers matter when you pick a language: how many people *use* it (how easy will it be to hire for, find libraries for, and get answers on Stack Overflow) and how many people who have used it *want to keep using it* (how likely is it that your team enjoys the tool a year in). The Stack Overflow Developer Survey publishes both once a year.

This article is a companion to the [security incidents review](recent-incidents-in-major-technologies.md) — both inform the question "which tech do we pick and commit to". Nothing here is a recommendation to switch stacks; these are decision inputs.

**Terminology note.** Stack Overflow renamed the old "loved" question to **"admired"** in 2024. An *admired* language is one a respondent has used in the past year *and* wants to use again in the next year — retention, not hype. A *desired* language is one any respondent wants to use in the next year, whether or not they have used it — interest, including from non-users. Both are asked on the same survey screen.

> [!NOTE]
> The Stack Overflow survey page is a single-page app. The most-popular tables below were captured from the rendered chart directly. The admired/desired rankings are partially sourced from secondary writeups (cited per row) because the relevant SPA section is not crawlable as static HTML. Where a number could not be verified, the row is marked and no percentage is given.

---

## Most popular

What developers have done extensive work in over the past year. Source: [survey.stackoverflow.co/2025/technology](https://survey.stackoverflow.co/2025/technology#most-popular-technologies-language-language-prof-ai).

Stack Overflow publishes two splits — all respondents (includes students, hobbyists, learning-to-code) and professional developers (paid, full-time). Professionals skew higher on TypeScript, SQL, and C#; lower on Python (because the learning-to-code cohort leans Python-heavy).

| Rank | Language | All respondents | Professional devs |
| ---: | --- | ---: | ---: |
| 1 | JavaScript | 66.0% | 68.8% |
| 2 | HTML/CSS | 61.9% | 63.0% |
| 3 | SQL | 58.6% | 61.3% |
| 4 | Python | 57.9% | 54.8% |
| 5 | Bash/Shell | 48.7% | 48.8% |
| 6 | TypeScript | 43.6% | 48.8% |
| 7 | Java | 29.4% | 29.6% |
| 8 | C# | 27.8% | 29.9% |
| 9 | C++ | 23.5% | 21.8% |
| 10 | PowerShell | 23.2% | 23.1% |
| 11 | C | 22.0% | 19.1% |
| 12 | PHP | 18.9% | 19.1% |
| 13 | Go | 16.4% | 17.4% |
| 14 | Rust | 14.8% | 14.5% |
| 15 | Kotlin | 10.8% | 11.5% |
| 16 | Lua | 9.2% | 8.6% |
| 17 | Assembly | 7.1% | 5.7% |
| 18 | Ruby | 6.4% | 6.9% |
| 19 | Dart | 5.9% | 6.1% |
| 20 | Swift | 5.4% | 5.7% |
| 21 | R | 4.9% | — |

Source for both columns: [SO 2025 technology → programming languages](https://survey.stackoverflow.co/2025/technology#most-popular-technologies-language-language-prof-ai).

**Year-over-year movement (SO-reported deltas, 2024 → 2025):**

- Python +7 pp — the single biggest jump, attributed by SO to AI/data work ([SO blog recap](https://stackoverflow.blog/2025/12/29/developers-remain-willing-but-reluctant-to-use-ai-the-2025-developer-survey-results-are-here/)).
- Rust +2 pp, Go +2 pp — both growing on the back of infra and AI tooling.
- PHP −3 pp, Ruby −2.5 pp — continued slow decline.

---

## Most admired

Share of developers who have used the language *and* want to keep using it next year. Source: [SO 2025 → Admired and Desired](https://survey.stackoverflow.co/2025/technology#admired-and-desired). Supplementary percentages cross-checked against third-party writeups where noted.

| Rank | Language | Admired % | Source for % |
| ---: | --- | ---: | --- |
| 1 | Rust | 72.4% | [SO primary](https://survey.stackoverflow.co/2025/technology#admired-and-desired), [itequia.com](https://itequia.com/stack-overflow-2025-where-is-technological-development-heading/) |
| 2 | Gleam | 70.8% | [SO primary](https://survey.stackoverflow.co/2025/technology#admired-and-desired), [itequia.com](https://itequia.com/stack-overflow-2025-where-is-technological-development-heading/) |
| 3 | Elixir | 65.9% | [SO primary](https://survey.stackoverflow.co/2025/technology#admired-and-desired), [itequia.com](https://itequia.com/stack-overflow-2025-where-is-technological-development-heading/) |
| 4 | Zig | 64.2% | [SO primary](https://survey.stackoverflow.co/2025/technology#admired-and-desired), [itequia.com](https://itequia.com/stack-overflow-2025-where-is-technological-development-heading/) |
| — | Python | 56.4% | [frameworktraining.co.uk recap](https://www.frameworktraining.co.uk/news-insights/stackoverflow-developer-survey-results-2025-overview) |
| — | Lua | 46.9% | [frameworktraining.co.uk recap](https://www.frameworktraining.co.uk/news-insights/stackoverflow-developer-survey-results-2025-overview) |

Rust has held the #1 admired slot in the Stack Overflow survey every year since 2016 — ten years running as of this snapshot. Gleam appeared in the admired ranking for the first time in 2025 and debuted at #2 — an unusually strong debut for a language whose usage share is below the survey's reporting threshold.

> [!NOTE]
> Beyond the six entries above, percentages for the remaining admired top-20 could not be confirmed from any text-crawlable source at snapshot time. The interactive SPA chart on [survey.stackoverflow.co/2025/technology#admired-and-desired](https://survey.stackoverflow.co/2025/technology#admired-and-desired) does show the full list visually — readers who need positions 7–20 should consult it directly. This article will be refreshed when a scrape-accessible data export becomes available.

---

## Most desired

Share of *all* developers (users and non-users) who want to work with the language in the next year. Source: [SO 2025 → Admired and Desired](https://survey.stackoverflow.co/2025/technology#admired-and-desired).

| Rank | Language | Desired % | Source for % |
| ---: | --- | ---: | --- |
| 1 | Python | 39.3% | [frameworktraining.co.uk recap](https://www.frameworktraining.co.uk/news-insights/stackoverflow-developer-survey-results-2025-overview) |
| 2 | Rust | 29.2% | [frameworktraining.co.uk recap](https://www.frameworktraining.co.uk/news-insights/stackoverflow-developer-survey-results-2025-overview) |
| 3 | Go | 23.4% | [frameworktraining.co.uk recap](https://www.frameworktraining.co.uk/news-insights/stackoverflow-developer-survey-results-2025-overview) |
| — | TypeScript | — | SO primary names it in the top cluster ([SO 2025](https://survey.stackoverflow.co/2025/technology#admired-and-desired)), exact % not in cited recaps |

SO's own summary groups **Python, TypeScript, Rust, and Go** together as the top desired languages ([SO 2025 technology](https://survey.stackoverflow.co/2025/technology#admired-and-desired)). Independent forum discussion of the 2025 results ([Rust users forum](https://users.rust-lang.org/t/stack-overflow-survey-2025/131005), [Elixir forum](https://elixirforum.com/t/stackoverflow-survey-2025-results/71874)) corroborates Gleam and Elixir appearing high in the desired ranking as well — surprising given how small their user bases are.

> [!NOTE]
> As with the admired table, the full desired top-20 percentages are locked behind the SPA chart. The three numbers above were captured from a secondary source quoting them directly; other positions were not reproduced with percentages in any writeup found at snapshot time.

---

## The delta — popular vs desired

The interesting signal is the *gap* between what's used today and what developers want to use next. A language that's high on both is a safe bet. A language that's high on popular but absent from desired is the status-quo tax. A language that's high on desired but not yet popular is an emerging bet — high enthusiasm, small hiring pool.

| Language | Popular rank | Desired rank | Signal |
| --- | :---: | :---: | --- |
| **Python** | 4 | 1 | High-use + high-want. The safest pick in the survey. |
| **TypeScript** | 6 | top-4 cluster | High-use + high-want. Incumbent for typed frontend/backend. |
| **Rust** | 14 | 2 | Small user base, big desire. Classic "people who use it don't want to leave." Greenfield systems bet. |
| **Go** | 13 | 3 | Similar profile to Rust — smaller pool, strong want, especially for infra and cloud-native. |
| **JavaScript** | 1 | not top-3 | Ubiquitous but not a desire leader. Use because the platform requires it, not because devs pick it voluntarily. |
| **HTML/CSS** | 2 | — | Platform language; "desire" isn't really meaningful here. |
| **SQL** | 3 | — | Same — the pragmatic default, not a love story. |
| **Java** | 7 | not top-4 | Enterprise incumbent. Hiring pool is huge; desire among people already using it is modest. |
| **C#** | 8 | not top-4 | Microsoft-stack incumbent. Similar profile to Java. |
| **PHP** | 12 | declining | Usage shrinking −3 pp YoY. Legacy projects only. |
| **Ruby** | 18 | declining | Usage shrinking −2.5 pp YoY. Shopify/Rails keeps it alive. |
| **Gleam** | below threshold | top-tier admired | #2 admired (70.8%) despite being too small to appear in the usage chart. Earliest-stage bet; small but passionate community. |
| **Elixir** | below threshold | top-tier admired | #3 admired (65.9%). Mature runtime (BEAM), niche usage. |
| **Zig** | below threshold | top-tier admired | #4 admired (64.2%). Systems-programming alternative to Rust, pre-1.0. |

---

## Reading the signal

A few caveats before you act on any of this.

**Sample bias.** The 2025 survey had 49,000+ respondents, down from 65,000+ in 2024 and 90,000+ in 2023 ([Elixir forum discussion](https://elixirforum.com/t/stack-overflow-developer-survey-2025/71073)). Smaller samples amplify enthusiasm from tight-knit communities — this is likely how Gleam, a language with a fraction of Rust's users, landed at #2 admired. That doesn't mean the signal is noise (Gleam users genuinely do like it); it means the bar for reaching "top admired" is lower when the denominator shrinks.

**Self-selection.** People who fill out the Stack Overflow survey are people who read the Stack Overflow blog. That skews toward web, enterprise backend, and developer-tooling work. The survey systematically under-represents embedded, scientific computing (Fortran is invisible here despite running most climate and physics code), HPC, and game development.

**"Popular" ≠ "hiring demand."** Usage is self-reported from developers who happen to answer the survey. It's a proxy for hiring demand, not a direct measurement. For actual hiring-market data, pair this with job-posting aggregators.

**"Admired" rewards small communities.** A 100-person Gleam community that all answered "yes, I want to keep using it" gives Gleam 100% admiration. A million-user Java community with 30% dissatisfaction gives Java a mediocre admired score even though Java is paying more salaries than Gleam ever will. Admiration is a retention signal — useful — but it does not translate directly into strategic safety.

**"Desired" includes wishful thinking.** Someone who has never written a line of Rust can still check the "I want to use Rust next year" box. Desired is aspiration; admired is retention; popular is practice. All three are useful for different decisions.

**AI is moving the numbers.** SO itself attributes Python's +7 pp jump and Rust/Go's +2 pp each to AI and infrastructure work ([SO 2025 recap](https://stackoverflow.blog/2025/12/29/developers-remain-willing-but-reluctant-to-use-ai-the-2025-developer-survey-results-are-here/)). If your tech selection doesn't touch AI workloads, discount those YoY movements somewhat.

---

## Takeaways for tech selection

- **Python, JavaScript, TypeScript, and SQL are the safest bets** — they combine high usage (easy to hire) with top-cluster desire (developers don't resent them). If the project scope fits, pick from these four.
- **Rust scores in the top-3 on desire and has held #1 admired for ten years.** If you are starting a systems, infra, or performance-sensitive project and your team has appetite for a newer ecosystem, this is the survey-backed choice.
- **Go is the low-risk Rust alternative** — #3 desired, simpler learning curve, strong cloud-native/CLI-tool ecosystem, mature hiring pool.
- **Legacy popularity is not future-proofing.** PHP and Ruby are still widely used; they are also both shrinking year-over-year. Pick them for maintaining an existing app, not for starting a new one.
- **Admired-but-niche languages (Gleam, Elixir, Zig) are bets, not defaults.** A high admiration score means people who use them stick with them — a real signal — but the hiring pool is small and the library ecosystem is thin. Viable for small teams comfortable with ecosystem-building; risky for organisations that need to onboard a new engineer every few months.
- **JavaScript is a platform, not a preference.** It is #1 popular and not in the top desire cluster. Use it because the browser requires it, then consider TypeScript on top for the typed experience developers actually want.

---

## Spotlight: the case for Elixir (and the BEAM)

The survey numbers above place Elixir at #3 admired (65.9%) but well below the popularity threshold. The headline number understates how strong an argument can be made for Elixir on operational grounds, distilled here from a [longer practitioner write-up](https://www.notion.so/janwirth/The-case-for-Elixir-3345cbd3c0c6806cb001ff78128bf63f) drawing on ~1M LOC of cross-language production experience (TypeScript, Elm, Java, Python, Gleam, Elixir).

**Scalability.** Elixir runs on the BEAM — Erlang's VM, built at Ericsson for telecom switches that needed five-nines uptime, millions of concurrent lightweight processes per node, hot code upgrades, and supervision trees that survive partial failure. That foundation is unusually well suited to chat, presence, soft-realtime collaboration, IoT message brokers, and any system where "graceful degradation under load" matters more than raw single-thread throughput.

**Security.** Phoenix and core Elixir have *no recent zero-days or unpatched critical CVEs* in the public record. By contrast, Next.js has accumulated several notable CVEs over the 2021–2026 window — middleware authorization bypass, RCE, DoS — patched quickly by Vercel but real. The smaller language ecosystem also means a much smaller supply-chain attack surface than npm or PyPI, both of which see ongoing typosquatting and credential-exfiltration campaigns. (See the companion [security incidents review](recent-incidents-in-major-technologies.md) for the broader pattern.)

**Ecosystem coherence.** Where Python and JS stitch together dozens of partial libraries, the Elixir world ships fewer but more complete frameworks: Phoenix (web + LiveView), Ash (declarative resource framework with first-class money types and policies), Oban (background jobs), Broadway (data ingestion). Phoenix LiveView in particular collapses the frontend/backend split — server-rendered diffs over a WebSocket — so a small team can keep one language across the entire stack.

**Cost.** The two costs that dominate a backend project are recruiting and the cloud bill. BEAM's per-node throughput tends to be higher than Node or Ruby for concurrent-IO-bound workloads, which translates to fewer instances. Recruiting is the standard objection — addressed below.

**LLM-assisted leverage.** With proper specs, tests, and harnesses, a small team of strong engineers using LLM tooling can ship more than a large team of average engineers — and Elixir's "hire fewer better people" story compounds that effect. The pattern works less well in stacks with weak typing or fragmented ecosystems where the LLM has to guess across multiple competing libraries.

**Reasonable counterarguments.**

- **"This will disappear."** The BEAM runtime powers WhatsApp and large parts of telecom backends; production users include Discord, Pepsi, and Square Enix. Languages on top of BEAM may shift (Erlang → Elixir → Gleam) but the runtime has a 30-year deployment record and is not going anywhere.
- **"We can never hire for it."** The Elixir talent pool is concentrated in the US, Germany, and Brazil, and remote roles are the norm. The pool is smaller than JS/Python in absolute terms — true — but the candidates who self-select into Elixir tend to be experienced and motivated. In-office hiring outside the major hubs is genuinely harder.
- **"Vendor risk in the surrounding ecosystem."** A real caveat from the source write-up: the author migrated *off* Elixir for one project because a critical database vendor (Vercel-invested) shut down. The lesson is not "don't use Elixir" but "don't pick infrastructure components whose business model depends on a single VC's continued enthusiasm" — orthogonal to language choice but acute when the language ecosystem is small enough that there isn't an easy second option.

**Practitioner case studies (N=3, from the source write-up).** Three Elixir/Phoenix projects shipped end-to-end by a single developer with no prior Elixir experience at the start:

- *wortwildnis.de* — social-features app (login, term creation/update, comments, ratings, real-time updates piped in from automated translations) — ~2 weeks.
- *acomapro.jan-wirth.de* — ingests CVs in multiple document formats, rewrites and embeds them, ranks against job postings.
- An insurance-pricing calculator integrating two third-party APIs with magic-link email auth — a few days.

These aren't a controlled benchmark, but they illustrate the velocity claim: a feature surface that would be a multi-month engagement in a fragmented stack collapses into days-to-weeks when the framework supplies the parts you would otherwise assemble yourself.

---

## Cookbook: which language for which use case

The survey ranks languages on three axes — usage, retention, desire — but it doesn't tell you which language fits which problem. This section maps common use cases to one or two language picks, with a one-line "why" grounded in the survey data above and the dominant ecosystems for that domain.

Picks are biased toward languages that score well on the survey *and* have a mature ecosystem for the use case in question. Where a domain is dominated by a single language for non-survey reasons (e.g. iOS = Swift), that wins regardless of admiration percentage.

| Use case | Primary pick | Backup pick | Why |
| --- | --- | --- | --- |
| **CRUD web apps (server-rendered)** | Python (Django) | Ruby (Rails) | Python is #1 desired and #4 popular; Django is the boring, batteries-included default. Rails is shrinking in usage but still the gold standard for developer ergonomics on small teams. |
| **CRUD web apps (typed full-stack)** | TypeScript (Next.js / Remix) | C# (ASP.NET Core) | TypeScript is in the top desired cluster and #6 popular; the JS/TS ecosystem dominates greenfield typed full-stack. C# is the mature enterprise alternative if you're already on the Microsoft stack. |
| **Real-time / chat / WebSockets / soft-realtime** | Elixir (Phoenix LiveView) | TypeScript (Node + Socket.IO) | Elixir is #3 admired (65.9%) and runs on the BEAM, which was built at Ericsson for telecom-grade concurrency — millions of lightweight processes, supervision trees, hot code reload. Phoenix LiveView pushes server-rendered diffs over WebSockets without a SPA. TypeScript on Node is the mainstream alternative when hiring matters more than per-node concurrency. |
| **APIs at scale (microservices, infra plumbing)** | Go | Rust | Go is #3 desired with simple deployment (single static binary), fast compile times, and a strong stdlib for HTTP. Rust takes the same single-binary story further with stronger correctness guarantees, at the cost of a steeper learning curve. |
| **Systems programming (OS, drivers, embedded firmware)** | Rust | Zig | Rust is #1 admired (10 years running) with no GC and memory safety. Zig is #4 admired, pre-1.0, and trades Rust's borrow checker for explicit allocators and simpler semantics. C still ships most of the world's firmware; pick Rust/Zig for greenfield. |
| **Embedded (microcontrollers, RTOS, hard-realtime)** | C | Rust | C is the lingua franca of embedded toolchains; almost every MCU vendor ships a C SDK. Rust's `embedded-hal` ecosystem is mature enough to be a serious greenfield option for new ARM Cortex-M / RISC-V projects. |
| **Machine learning / data science / AI** | Python | (no real backup) | Python is #1 desired and the entire ML toolchain (PyTorch, JAX, scikit-learn, pandas, HuggingFace) is Python-first. The +7 pp YoY jump in usage is largely AI-driven. R remains relevant for stats research; Julia for HPC numerics. |
| **Data engineering / ETL / batch pipelines** | Python | Scala | Python (PySpark, Airflow, dbt) is the operator default. Scala still has the deepest Spark integration if you need raw JVM performance and type safety. |
| **iOS / macOS native apps** | Swift | (none) | First-party language, only practical choice for native UI. Apple has effectively deprecated Objective-C for new code. |
| **Android native apps** | Kotlin | Java | Google made Kotlin the preferred Android language in 2019; new Android tutorials are Kotlin-first. Java remains everywhere in legacy Android codebases. |
| **Cross-platform mobile (single codebase, two stores)** | Dart (Flutter) | TypeScript (React Native) | Flutter ships its own rendering engine and gives you near-native performance with one codebase. React Native lets you reuse JS/TS skills and bridges to native UI primitives. |
| **CLI tools (single binary, fast startup)** | Go | Rust | Both compile to a single static binary with no runtime dependencies. Go wins on compile speed and ecosystem familiarity (kubectl, gh, terraform). Rust wins when you need maximum performance or a richer type system. |
| **Scripting / glue code / one-off automation** | Python | Bash/Shell | Python is #4 popular for a reason — readable, ubiquitous, batteries included. Bash is #5 popular and unavoidable for OS-level glue, but switch to Python the moment your script grows past ~50 lines or needs structured data. |
| **Game development (AAA, 3D engines)** | C++ | C# | Unreal is C++; Unity is C#. Both engines dominate the commercial market. Pick by engine, not by language preference. |
| **Game development (indie, 2D, prototyping)** | C# (Unity / Godot) | Lua (Love2D, embedded scripting) | Godot 4 supports both C# and its own GDScript. Lua is #16 popular and the standard embedded scripting language for game engines (also: Roblox, World of Warcraft addons). |
| **Smart contracts / on-chain logic** | Solidity (EVM) | Rust (Solana, Near, ink!) | Solidity is the EVM default; the surrounding ecosystem (Hardhat, Foundry) is mature. Rust dominates non-EVM chains and is the safer choice for new chain VMs. |
| **Scientific computing / numerical / HPC** | Python (NumPy + JAX) | Julia | Python wraps the underlying C/Fortran numerics and is the lingua franca of research. Julia is the rising alternative when JIT performance matters and you don't want to write C extensions. Fortran still runs most production climate/physics code — invisible in the survey but very much alive. |
| **Statistics / academic data analysis** | R | Python | R remains the default in biostats, econometrics, and academic stats teaching. Python (pandas + statsmodels) wins outside academia or when you need to ship the model to production. |
| **DevOps / infrastructure as code / cloud-native** | Go | Python | Almost every cloud-native tool you use day-to-day is Go (Kubernetes, Terraform, Prometheus, Docker). Python (Ansible, boto3, pulumi) covers the orchestration and scripting half. |
| **Database internals / query engines / storage** | Rust | C++ | The new generation of database engines (TiKV, Materialize, SurrealDB, Polars, DataFusion) is Rust. Legacy heavyweight engines (Postgres, MySQL, ClickHouse) are C/C++. Greenfield: Rust. |
| **Compilers / interpreters / language tooling** | Rust | OCaml / Haskell | Rust has become the default for new compiler tooling (rustc itself, swc, biome, ruff, uv). OCaml/Haskell remain the academic and ML-family language choice for type-system-heavy frontends. |
| **Functional / typed correctness-first projects** | Gleam | Elixir | Gleam is #2 admired (70.8%) — a small but very passionate community building a typed BEAM language with a friendly tone and an unusually approachable syntax. Elixir is the mature, dynamically-typed BEAM cousin with the bigger production footprint and the Phoenix ecosystem. |
| **Quick prototypes / weekend hacks where you'll throw it away** | Python | TypeScript | Whichever you already know best. Both are #1/top-cluster on desire, both have a REPL or fast iteration loop, both have a library for almost anything. |
| **Legacy maintenance (be honest about it)** | match the existing stack | — | PHP and Ruby are both shrinking in usage YoY but still pay salaries. Java and C# are not shrinking and will outlast most of us. Maintaining is not a language-choice decision; it's a "learn the codebase you inherited" decision. |

A few cross-cutting notes:

- **The BEAM corner (Elixir + Gleam) deserves its own line.** Both punch far above their popularity on the admired axis (#3 and #2 respectively). The runtime they share — Erlang's BEAM VM — was designed for telecom switches that needed five-nines uptime, hot code upgrades, and millions of concurrent lightweight processes per node. That makes the BEAM unusually well-suited to chat, presence, soft-realtime collaboration, IoT message brokers, and any system where "graceful degradation under load" matters more than raw single-thread throughput. The trade-off is a smaller hiring pool and a smaller library ecosystem than the JVM or Node worlds.
- **Rust shows up in five categories above.** That's not a coincidence — the survey's 10-year admiration streak reflects a real broadening: systems work, CLIs, infra, database engines, and language tooling have all consolidated on Rust as the greenfield default. The cost is the steepest learning curve in this table.
- **Python shows up in seven.** Also not a coincidence. Python's range — scripting to ML to data engineering to scientific computing to web — is what makes it #1 desired even though its individual sub-domains each have a stronger specialist (Go for infra, R for stats, JS for browsers). When in doubt and unsure of the domain, Python is the survey-backed safe default.

---

*Data captured 2026-05-06 from the 2025 Stack Overflow Developer Survey. For the underlying question wording and full methodology, see [Stack Overflow's 2025 methodology page](https://survey.stackoverflow.co/2025/methodology/).*
