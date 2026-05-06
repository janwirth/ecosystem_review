# UX Resources & Tools — A Curated Review

> [!NOTE]
> **Status:** DRAFT · **Authoring:** AI-assisted, human-reviewed.

> **Explicitly not design but UX.** This article is about *user experience* — research, behavioural patterns, usability heuristics, flow specifications, and the instrumentation that tells you whether a flow actually works. It is **not** about visual design — typography, colour systems, brand identity, illustration, motion. The two disciplines overlap (an aesthetically polished UI can mask a broken flow; the [Aesthetic-Usability Effect](#laws-of-ux) is itself a UX law about that overlap), but the resources reviewed here exist because those overlaps are exactly what gets confused most often.

**Snapshot 2026-04-29** — metadata captured from live sites only (no API). Star counts, edition info, course catalogues, and pricing reflect what a logged-out visitor sees today.

## Table of Contents

1. [The UX vs visual-design line](#the-ux-vs-visual-design-line)
2. [Laws of UX](#laws-of-ux)
3. [Nielsen Norman Group (NN/g)](#nielsen-norman-group-nng)
4. [Dogfooding](#dogfooding)
5. [PostHog — instrumentation that complements dogfooding](#posthog--instrumentation-that-complements-dogfooding)
6. [Connection to Gherkin / BDD](#connection-to-gherkin--bdd)
7. [How these fit together](#how-these-fit-together)
8. [Leaderboard — UX resources at a glance](#leaderboard--ux-resources-at-a-glance)

## The UX vs visual-design line

When a stakeholder says "we need a UX review", they usually mean one of three things:

1. **The flow is wrong.** Users can't find the action; the steps are out of order; the empty state has no call to action; the recovery path from an error doesn't exist. *This is UX.*
2. **The interface looks unprofessional.** Spacing is uneven, the type hierarchy is muddled, the colour contrast is wrong, the icons are inconsistent. *This is visual design.*
3. **The product solves the wrong problem.** Nobody asked for this; the use case doesn't survive a five-minute conversation with a real user. *This is product strategy / discovery — upstream of both.*

This article only covers **(1)**. The line is fuzzier in practice than in theory — Don Norman, who [coined the job title "User Experience" at Apple in 1993](https://en.wikipedia.org/wiki/Don_Norman), was insistent that UX is "every aspect of the user's interaction" with a product, which is broad enough to swallow visual design whole. But the operational distinction holds: **a usability problem is reproducible by watching one user fail to complete a task**, regardless of how the screen looks. A visual-design problem is reproducible by *the user not failing but feeling that the product is unpolished*. They are different bugs.

The resources below are picked for the first kind of bug.

## Laws of UX

> **[lawsofux.com](https://lawsofux.com)** — *"A collection of best practices that designers can consider when building user interfaces."*
>
> **Author:** [Jon Yablonski](https://jonyablonski.com) · **Free** (the site) · **Paid** (the book + index poster)

Yablonski's site catalogues **31 laws** — psychology principles distilled into one-line, application-ready rules. The site presents each law with: a concise definition, the underlying psychological research, posters and reference cards, and (for many) practical UI examples. It is the most heavily referenced single-page UX resource on the web today.

There is also a companion book — **"Laws of UX: Using Psychology to Design Better Products & Services"** by Jon Yablonski, published by **O'Reilly Media** (ISBN 9781098146964 for the Second Edition). The Second Edition adds material on LLMs, AI-powered tools, spatial computing, and three new laws (Paradox of Choice, Complexity Bias, Flow). Translated into 10+ languages including Portuguese, Korean, German, Thai, Chinese, Spanish, Japanese, and Russian.

### The 31 laws

Numbering follows the alphabetical order on lawsofux.com (the site itself does not number them). One-sentence summaries paraphrased to fit a single line; for the source citation and research, follow the per-law page.

| # | Law | One-line summary |
|---:|---|---|
| 1 | Aesthetic-Usability Effect | Users perceive aesthetically pleasing designs as easier to use. |
| 2 | Choice Overload | Many equally-weighted options creates decision paralysis. |
| 3 | Chunking | Group related content into discrete units to aid working-memory recall. |
| 4 | Cognitive Bias | Systematic deviations from rational judgment shape interface perception. |
| 5 | Cognitive Load | Total mental effort required exceeds capacity if not managed. |
| 6 | Doherty Threshold | Productivity peaks when system response is faster than ~400ms. |
| 7 | Fitts's Law | Time to target = function of distance and target size. |
| 8 | Flow | A balanced challenge-skill state produces engaged use. |
| 9 | Goal-Gradient Effect | Motivation increases as the user nears the goal. |
| 10 | Hick's Law | Decision time grows logarithmically with the number of choices. |
| 11 | Jakob's Law | Users expect your site to work like all the other sites they already know. |
| 12 | Law of Common Region | Items within a clear boundary are perceived as a group. |
| 13 | Law of Proximity | Items near each other are grouped together perceptually. |
| 14 | Law of Prägnanz | The eye reduces complex shapes to the simplest possible form. |
| 15 | Law of Similarity | Visually similar items are perceived as related. |
| 16 | Law of Uniform Connectedness | Connected elements are perceived as more related than disconnected ones. |
| 17 | Mental Model | Users act on their internal model of how a system works, not the actual model. |
| 18 | Miller's Law | The average person can hold ~7 (±2) items in working memory. |
| 19 | Occam's Razor | Of competing options, the simplest is usually best. |
| 20 | Paradox of the Active User | Users start using a product before reading instructions, even when reading would be faster. |
| 21 | Pareto Principle | ~80% of effects come from ~20% of causes; focus on the heavy users / paths. |
| 22 | Parkinson's Law | Tasks expand to fill the time allotted; tight defaults beat open-ended prompts. |
| 23 | Peak-End Rule | Users judge an experience by its peak and its end, not its average. |
| 24 | Postel's Law | Be liberal in what you accept, conservative in what you produce. |
| 25 | Selective Attention | Users filter for what they expect; unexpected items go unseen ("banner blindness"). |
| 26 | Serial Position Effect | First and last items in a list are remembered best. |
| 27 | Tesler's Law | Every system has irreducible complexity; decide who absorbs it (the user or the developer). |
| 28 | Von Restorff Effect | A distinctive item among similar ones is remembered. |
| 29 | Working Memory | Short-term retention is limited; persist state externally where you can. |
| 30 | Zeigarnik Effect | Incomplete tasks are remembered better than completed ones. |
| 31 | Law of Pragnanz / Cognitive… (book-only additions: Paradox of Choice, Complexity Bias, Flow) | The Second Edition adds these; the website may not yet list all separately. |

> [!NOTE]
> The user request mentioned "the 21+ laws". The site has grown — at snapshot date there are **31** distinct laws listed. Numbers fluctuate as Yablonski adds material; treat any specific count as a snapshot.

**Verdict.** The site is the single most accessible introduction to applied UX psychology. Free, single-author, opinionated but well-cited, and the index-poster format means each law fits a slack-message-sized explanation. **Pick when:** you want a vocabulary to argue for or against a UI change with research backing, not vibes. **Pass when:** you need empirical study reports rather than principles — that's NN/g territory.

## Nielsen Norman Group (NN/g)

> **[nngroup.com](https://www.nngroup.com)** — *"Research-based, results-driven UX guidance and training."*
>
> **Founded:** 1998, by **Jakob Nielsen** and **Don Norman**. **Don Norman retired in 2018** but remains on the board; **Jakob Nielsen retired in April 2023**. Kara Pernice is now President & CEO; Sarah Gibbons and Kate Moran are vice presidents. Operating for ~28 years at snapshot.

The "consultancy that wrote the textbook" of usability. NN/g published the canonical research-based UX papers of the late 1990s through 2010s and turned that body of work into a training-and-consulting business. Clients on the homepage include Visa, P&G, Citi, Amazon, Vimeo, Samsung.

### What NN/g actually offers

| Surface | What it is | Cost |
|---|---|---|
| **Articles** | ~2,000+ research-based articles (the canonical archive of empirical UX research from 1995-present). Free, indexed, searchable. | Free |
| **Videos** | Short explainer videos on individual UX topics; many feature Jakob Nielsen pre-2023. | Free |
| **NN/g UX Podcast** | Interview / topic podcast on Spotify. | Free |
| **Reports** | Long-form research reports on specific verticals (mobile UX, intranet design, etc.). | Paid |
| **Live online courses** | 60+ live courses across AI, research, leadership, web/UI design, strategy. All eligible for UX Certification credit. | Paid |
| **Self-paced courses** | Asynchronous courses, ~$199–$289 USD typical pricing. | Paid |
| **UX Certification** | Three specialty tracks: **AI**, **Interaction Management**, **Research**. Earned via course completion + exams. | Paid (per course) |
| **UX Conference** | Multi-day intensive in major cities globally; the canonical place to take a stack of NN/g courses contiguously. | Paid |
| **Consulting** | Custom user research, expert review, intensive workshops, keynote speaking, user testing, UX maturity assessment. | Custom quote |

### The 10 Usability Heuristics

Nielsen's heuristics, originally published **1994-04-24**, last updated **2024-01-30** ([source](https://www.nngroup.com/articles/ten-usability-heuristics/)). The most-cited UX framework in the field; underpins most heuristic-evaluation methodology.

| # | Heuristic | Sentence-summary |
|---:|---|---|
| 1 | **Visibility of system status** | The design should keep users informed about what is going on, through appropriate feedback within reasonable time. |
| 2 | **Match between system and the real world** | Use words, phrases, and concepts familiar to the user, not internal jargon; follow real-world conventions. |
| 3 | **User control and freedom** | Provide a clearly marked "emergency exit" — undo and redo — for users who took an action by mistake. |
| 4 | **Consistency and standards** | Don't make users wonder whether different words or actions mean the same thing; follow platform and industry conventions. |
| 5 | **Error prevention** | Eliminate error-prone conditions, or check for them and present a confirmation before the user commits to the action. |
| 6 | **Recognition rather than recall** | Make elements, actions, and options visible — minimize what the user has to remember. |
| 7 | **Flexibility and efficiency of use** | Accelerators (shortcuts, hidden from novices) speed up expert interaction; cater to both novice and expert. |
| 8 | **Aesthetic and minimalist design** | Interfaces should not contain irrelevant or rarely-needed information; every extra unit competes with what matters. |
| 9 | **Help users recognize, diagnose, and recover from errors** | Error messages in plain language, precisely indicate the problem, constructively suggest a solution. |
| 10 | **Help and documentation** | The system should ideally not need explanation; when it does, the help is task-focused, easy to search, concrete. |

These heuristics are the **default first pass** for any UX review. A team can evaluate a screen against these ten in 15 minutes and find more issues than most user-test sessions surface.

**Verdict.** NN/g is the institution. Free archive of articles is the deepest single source of empirical UX research available; paid training is expensive but defensibly priced for what it gives a team (a shared vocabulary + a credentialed proficiency floor). **Pick when:** you need primary research, certificated training, or industry-standard heuristic vocabulary. **Pass when:** you want one-line application rules over research narrative — go to [Laws of UX](#laws-of-ux) instead.

## Dogfooding

> **"Eating your own dog food."** Internal use of your own product, by your own team, in their normal day-to-day work — *before* it ships to anyone else.

The phrase is folklore-old but its industry usage traces to a documented 1988 Microsoft email. Earlier antecedents:

- **1970s** — Alpo dog-food TV commercials starring Lorne Greene, in which Greene said he fed Alpo to his own dogs. The president of Kal Kan Pet Food was reportedly photographed eating his product at shareholder meetings. ([source](https://en.wikipedia.org/wiki/Eating_your_own_dog_food))
- **1988** — **Paul Maritz** at Microsoft sent an internal email titled *"Eating our own Dogfood"* to **Brian Valentine** (test manager for Microsoft LAN Manager), challenging him to drive internal use of the product. Maritz later called this his *"only contribution to the IT world"*.
- **Pre-1988 at Apple** — the practice (without the dog-food name) was already in use; engineers at Apple, Lockheed, and other West Coast hardware shops had been using their own products in development for decades. The name from Microsoft is what stuck.

### Why it matters for UX

Dogfooding produces the highest-bandwidth UX feedback channel a team can have:

1. **Real workflows**, not contrived test scripts. The team uses the product to do their actual job — write code, run meetings, ship features — so the friction points are the ones real users will hit.
2. **Repeated exposure**. A user-test session is one hour; dogfooding is 8 hours a day, 5 days a week. Latent issues (a state that only triggers after 30 days of use; a permission edge case that only matters when the team grows past 50; a settings menu that's fine for week-1 but humiliating by month-6) surface naturally.
3. **Ownership pressure**. The engineer who broke checkout is the one who has to live with broken checkout tomorrow morning. Bug priority is calibrated automatically.

### Anti-patterns

Dogfooding is *not* a substitute for external user research. The well-documented failure modes:

- **Engineer-only sample bias.** Your team is technical, well-paid, on fast hardware, on a fast network, with a deep mental model of the product. Real users are none of those things. Dogfooding catches workflow bugs but **misses onboarding bugs** by definition — the team has been onboarded for years.
- **The "we already know" trap.** Internal users learn workarounds. "Oh you have to click Settings → Advanced first, everyone does that." That workaround is invisible internally and a wall externally.
- **Selection bias on staff.** Companies hire people who fit the product's mental model. Notion is full of people who like Notion's metaphor. The 80% of the market that finds Notion confusing is not represented on the team.
- **Production substitution.** Some teams claim to dogfood but actually use the polished, paid, fully-configured tier — not the trial that 90% of new signups see.

The mitigation is **always** to pair dogfooding with structured external user research and **with quantitative instrumentation** (next section) so that the gap between "what the team thinks the product feels like" and "what new users actually do" is visible.

### Public dogfooding examples

- **Slack-on-Slack.** Slack's company-wide communication runs on Slack; their public "channels we use" posts are an ongoing case study in how the team's own use shaped features (huddles, threads, custom emoji culture).
- **Linear-on-Linear.** Linear builds Linear in Linear; the public roadmap and issue tracker are the dogfood.
- **Notion-on-Notion.** The Notion company wiki, HR docs, and engineering tracker are all in Notion. The "every internal page is also a feature demo" loop is explicit.
- **GitHub-on-GitHub.** The GitHub product team uses GitHub Issues, Projects, Actions, and Codespaces to build GitHub itself.
- **PostHog-on-PostHog.** PostHog tracks its own product usage in PostHog and publishes the dashboards. (See [PostHog](#posthog--instrumentation-that-complements-dogfooding) below.)

What these have in common: the company's *own daily operating tooling* is the product. That's the strong form. Weaker forms — "the engineering team is on the beta channel" — still help but capture less.

## PostHog — instrumentation that complements dogfooding

> **[posthog.com](https://posthog.com)** · **[GitHub: PostHog/posthog](https://github.com/PostHog/posthog)** — *"The new way to build products"* / *"All-in-one developer platform for building successful products."*
>
> **Founders:** James Hawkins & Tim Glaser (both Co-CEOs). **Y Combinator W20.** Founded **2020**.
> **Stars:** 34.2k★. **Primary license:** **MIT** (the `ee` enterprise directory has its own non-MIT license; see [licensing](#a-note-on-posthog-licensing) below).

If dogfooding tells you what *the team* hits, instrumentation tells you what *real users* hit. PostHog is the open-source option in this space.

### Feature matrix

| Capability | PostHog | Notes |
|---|:---:|---|
| **Product analytics** (events, funnels, retention, cohorts) | ✅ | Core product. Free tier 1M events/month; $0.00005/event after. |
| **Session replay** | ✅ | Records user sessions for replay. 5K recordings/month free; $0.005/recording after. |
| **Feature flags** | ✅ | Server- and client-side flag evaluation. 1M requests/month free. |
| **Experiments (A/B testing)** | ✅ | Built on top of feature flags. |
| **Surveys** | ✅ | In-product surveys. 1.5K responses/month free; $0.10/response after. |
| **Error tracking** | ✅ | Exception monitoring. 100K exceptions/month free. |
| **LLM observability** | ✅ | Traces, generations, evals for AI features. 100K events/month free. |
| **Data warehouse** | ✅ | Managed warehouse + SQL editor. 1M rows free. |
| **Heatmaps** | ✅ | Click and scroll heatmaps. |
| **Web analytics** | ✅ | Bundled with product analytics. |
| **Workflows / automation** | ✅ | Newer; messaging + action orchestration. |
| **Self-hostable** | ✅ | Docker / k8s; full feature set on the OSS path. |
| **Cloud (managed)** | ✅ | US (Virginia) and EU (Frankfurt) regions. |

The breadth is the point: PostHog's argument is that for a product team, having analytics + replay + flags + experiments + surveys in **one tool with a shared event identity** removes a class of integration plumbing that fragmented stacks impose. Whether the consolidation argument wins depends on the team — the trade-off is depth-per-product vs. integration cost-savings.

### A note on PostHog licensing

PostHog's open-source claim is real but not uniform. Per the [GitHub repo](https://github.com/PostHog/posthog) at snapshot:

- **Main repo** is licensed under the **MIT (expat) license**, *except* the `ee/` directory, which has its **own license** (proprietary; gating enterprise-only features).
- A separate repository, **[posthog-foss](https://github.com/PostHog/posthog-foss)**, is "purged of all proprietary code and features" and is fully MIT — for users who need a guarantee of no proprietary code in their tree.

> [!NOTE]
> Earlier reviews of PostHog described the project as "Apache 2 + MIT mix". That description does not match the current GitHub repo, which lists **MIT** as the primary license with a per-directory enterprise license override. License terms can change between releases — re-check the [LICENSE](https://github.com/PostHog/posthog/blob/master/LICENSE) file at install time.

### Pricing model

PostHog Cloud uses **usage-based pricing** with a free tier per product (see matrix above). Their public claim is *"more than 90% of companies use PostHog for free"* — i.e., the free tiers are sized to absorb most early-stage products' volume. Self-host has no per-event metering.

### Competitors (briefly)

PostHog occupies the **"open-source, all-in-one, developer-marketed"** corner. The neighbouring corners:

| Tool | Position | Notes |
|---|---|---|
| **[Mixpanel](https://mixpanel.com)** | Closed-source product analytics, mature | Stronger BI / cohort UX; no session replay or flags natively. Closed-source. |
| **[Amplitude](https://amplitude.com)** | Closed-source product analytics, enterprise-flavoured | Strongest analyst tooling; heaviest sales motion. Closed-source. |
| **[Heap](https://heap.io)** | Closed-source, "autocapture" pioneer | Auto-tracks all events; lighter setup, more data noise. Closed-source. |
| **[FullStory](https://fullstory.com)** | Closed-source, session-replay first | Replay + heatmaps + frustration signals. Adjacent to analytics rather than full replacement. Closed-source. |
| **[Plausible](https://plausible.io)** / **[Umami](https://umami.is)** | Open-source, lightweight web-analytics-only | Privacy-focused, no flags / replay / surveys; much narrower scope than PostHog. |
| **[Sentry](https://sentry.io)** | Open-core error tracking | Deeper on errors / performance than PostHog; narrower elsewhere. Often paired with PostHog rather than replacing it. |

**Verdict.** PostHog is the strongest single open-source option for "I want one stack covering analytics + replay + flags + experiments + surveys" without sales calls. Self-hosting is real and supported. Closed-source competitors win on per-product depth (Amplitude's analyst tooling, FullStory's replay UX). **Pick when:** you want to own the data, you're on a developer-led team, you want one tool for many adjacent jobs. **Pass when:** you need the deepest analyst surface (go Amplitude) or the deepest replay-frustration analytics (go FullStory).

## Connection to Gherkin / BDD

> **Cross-link:** [BDD with Gherkin across ecosystems](bdd-with-gherkin.md) — full review of Cucumber-family tooling per language.

There is a real, often-missed link between Behaviour-Driven Development and UX flow specification. A Gherkin scenario:

```gherkin
Feature: Password reset

  Scenario: User reset email arrives within a minute
    Given a user with email "alice@example.com" exists
    When the user submits the password-reset form with their email
    Then they receive a reset email within 60 seconds
    And the email contains a single-use reset link
    And the link expires after 30 minutes
```

…is **structurally a UX flow specification**. The `Given/When/Then` triad maps cleanly onto:

| Gherkin clause | UX equivalent |
|---|---|
| `Given` | Initial user state / preconditions / mental model entry point |
| `When` | The user action or trigger event |
| `Then` | Expected system response from the user's point of view |
| `And` (after `Then`) | Implicit usability promises (timing, clarity, single-use semantics, expiry) |

This matters for UX work for three reasons:

1. **A Gherkin spec captures the flow at the same granularity user testing observes it.** A test session would log "she clicked submit, then she got an email, then she clicked the link." The scenario captures exactly that level. They can be written by the same person.
2. **Specs are executable.** A user-research finding becomes a regression: if the next refactor breaks "reset email arrives in 60s", the test fails. UX defects don't usually get this protection because they're not phrased as testable assertions.
3. **Stakeholder readability is the same goal.** Gherkin's design intent — "non-programmers can read it" — is the same as the design intent of a UX flow diagram. The two artefacts can be consolidated.

The trade-off: Gherkin scenarios under-specify *visual and interaction* details (cursor behaviour, animation, focus order). They are not a substitute for a Figma flow diagram or for a heuristic walkthrough — they are a complement that locks in **the bits of UX behaviour the test suite can actually verify**.

In a mature workflow:

- **Designers** specify flows + user stories.
- **Researchers** validate the flows with real users (NN/g methodology).
- **Engineers + designers** translate validated flows into Gherkin scenarios.
- **CI** runs the scenarios; regressions fail the build.
- **PostHog** measures whether real production users actually complete the flow at the rate the test asserts they should.

This is the loop that closes "we designed it and shipped it" → "we know whether it works."

## How these fit together

A complete UX practice uses these pieces in sequence:

1. **Discovery & spec** — talk to users (NN/g methodology), build a flow, write [Gherkin scenarios](bdd-with-gherkin.md) for the load-bearing behaviours.
2. **Design pass** — apply [Laws of UX](#laws-of-ux) (Hick, Fitts, Jakob, Aesthetic-Usability) to the proposed UI; argue with the vocabulary, not with vibes.
3. **Heuristic review pre-ship** — walk the [10 NN/g heuristics](#the-10-usability-heuristics) against the build. 15 minutes; finds more issues than most demos.
4. **Ship + dogfood** — the team uses the feature in normal work for at least one full cycle. Note the friction; do not yet act on it.
5. **Instrument + measure** — [PostHog](#posthog--instrumentation-that-complements-dogfooding) (or equivalent) tracks the funnel, replay, and explicit surveys for real users. Compare what the team felt versus what real users do.
6. **External user testing** — for high-stakes flows, run scheduled tests with non-team users to catch what dogfooding hid (selection bias, learned workarounds, onboarding gaps).
7. **Iterate** — when a Gherkin scenario fails, fix it. When PostHog shows a funnel-drop the team didn't predict, investigate. When a heuristic review flags a recurring issue, fold it into a design-system rule.

None of these steps replaces the others. **The team that only does (4) ships beautifully-engineered products that real users find confusing.** The team that only does (5) measures the wrong thing because nobody asked what to measure. The team that only does (3) writes 10 issues on launch day and never sees them again.

## Leaderboard — UX resources at a glance

Five-dimension scoring across the resources reviewed in this article. The dimensions:

- **Authority** — depth of underlying research / institutional credibility. 🟩🟩 = primary-source institution / cited everywhere; 🟩 = strong secondary; 🟨 = useful curation; 🟥 = thin.
- **Accessibility** — how easy is it to actually use the resource as a non-expert? 🟩🟩 = free, scannable, fits in 30min; 🟩 = readable but takes time; 🟨 = paywall or steep curve; 🟥 = institutional-only.
- **Depth** — how far down does the rabbit hole go? 🟩🟩 = years of material; 🟩 = solid coverage; 🟨 = single-pass treatment; 🟥 = surface only.
- **Currency** — is it actively maintained? 🟩🟩 = updated within last year; 🟩 = updated within 3 years; 🟥 = stale.
- **Cost** — 🟩🟩 = entirely free; 🟩 = free tier covers most use; 🟨 = free for individuals, paid for teams; 🟥 = paid only.

| Resource | Authority | Accessibility | Depth | Currency | Cost | Verdict |
|---|:---:|:---:|:---:|:---:|:---:|---|
| **[Laws of UX](#laws-of-ux)** (site) | 🟩 | 🟩🟩 | 🟩 | 🟩🟩 | 🟩🟩 | The best entry point. One-line rules with research backing, free, scannable. |
| **Laws of UX** (book, 2nd ed.) | 🟩🟩 | 🟩 | 🟩🟩 | 🟩🟩 | 🟥 | Worth buying if the site clicks for you. |
| **[NN/g](#nielsen-norman-group-nng)** (free articles) | 🟩🟩 | 🟩 | 🟩🟩 | 🟩🟩 | 🟩🟩 | The deepest free archive of empirical UX research. |
| **NN/g** (training / UXC) | 🟩🟩 | 🟨 | 🟩🟩 | 🟩🟩 | 🟥 | Industry-standard credential; expensive but justifiable for teams. |
| **[Dogfooding](#dogfooding)** (practice) | 🟩 | 🟩🟩 | 🟩 | 🟩🟩 | 🟩🟩 | Free, immediate, but anti-patterns are real — pair with research. |
| **[PostHog](#posthog--instrumentation-that-complements-dogfooding)** (cloud) | 🟩 | 🟩🟩 | 🟩🟩 | 🟩🟩 | 🟩 | Free tier covers most early-stage products; pay-as-you-grow. |
| **PostHog** (self-host) | 🟩 | 🟨 | 🟩🟩 | 🟩🟩 | 🟩🟩 | Full feature set, no metering — at the cost of running it. |
| **[Gherkin / BDD](#connection-to-gherkin--bdd)** (link to article) | 🟩 | 🟩 | 🟩 | 🟩🟩 | 🟩🟩 | Complement to the rest of this list, not a substitute. |

**Recommendation by situation:**

- **Solo founder, just starting:** Read Laws of UX (site, free), apply NN/g's 10 heuristics to your build, ship, instrument with PostHog Cloud free tier. Total cost: $0.
- **Small team, pre-product-market-fit:** Add dogfooding as a daily practice; write Gherkin specs for the top 3 flows; the rest as above.
- **Series-A and beyond, dedicated design / research function:** Send the design lead to a NN/g UX Conference; pursue UX Certification for the research-tracked role; self-host PostHog if data-residency is a constraint; institutionalise the dogfood-then-instrument loop.

---

**Snapshot 2026-04-29.** Submit issues for missing tools, repo updates, or corrections.
