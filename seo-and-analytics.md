# SEO & Analytics — A Curated Review

> [!NOTE]
> **Status:** DRAFT · **Authoring:** AI-assisted, human-reviewed.

> **Two disciplines, one feedback loop.** This article covers both **SEO** (how you get found by people who don't already know you exist) and **web/product analytics** (how you measure what they do once they arrive). They are different jobs with different tools — but neither works without the other. SEO without analytics is faith. Analytics without acquisition is a clipboard with nothing to count.

**Snapshot 2026-06-14** — pricing, tool feature sets, and database sizes pulled from logged-out marketing pages and public docs at snapshot date. Tool pricing in particular fluctuates monthly; treat exact numbers as a point-in-time reading.

## Table of Contents

1. [The SEO vs analytics line](#the-seo-vs-analytics-line)
2. [SEO fundamentals — the four pillars](#seo-fundamentals--the-four-pillars)
3. [Keyword research — the load-bearing skill](#keyword-research--the-load-bearing-skill)
4. [Competitor analysis — how marketers actually do it](#competitor-analysis--how-marketers-actually-do-it)
5. [Technical SEO — what crawlers care about](#technical-seo--what-crawlers-care-about)
6. [On-page SEO and content optimization](#on-page-seo-and-content-optimization)
7. [Off-page SEO — backlinks, mentions, authority](#off-page-seo--backlinks-mentions-authority)
8. [The AI-era shift — Generative Engine Optimization (GEO)](#the-ai-era-shift--generative-engine-optimization-geo)
9. [SEO tools by tier and price](#seo-tools-by-tier-and-price)
10. [Free SEO tools that punch above their weight](#free-seo-tools-that-punch-above-their-weight)
11. [Web analytics — measuring the traffic](#web-analytics--measuring-the-traffic)
12. [The full marketer playbook](#the-full-marketer-playbook)
13. [Leaderboard — SEO + analytics tools at a glance](#leaderboard--seo--analytics-tools-at-a-glance)
14. [Cross-links](#cross-links)

## The SEO vs analytics line

When someone says "we need to improve our marketing", they usually mean one of three things:

1. **Nobody finds us.** Direct traffic is flat, search impressions are low, the site doesn't rank for terms the team thinks it should. *This is SEO.*
2. **People find us but don't convert.** Traffic is fine, but visitors bounce, the funnel leaks, the activation event never fires. *This is analytics + UX, not SEO.* (See [UX resources & tools](ux-resources-and-tools.md).)
3. **We don't know what's happening.** No instrumentation, no dashboards, no source attribution. *This is the analytics setup phase — prerequisite to both of the above.*

This article covers **(1)** and **(3)**. The (2)-shaped problem is downstream — you need to know who's arriving (analytics) and from where (SEO attribution) before you can ask why they're leaving.

The operational distinction: **SEO is about the impressions and clicks you haven't earned yet**. Analytics is about the sessions you already have. SEO tools forecast — they tell you what searches happen, how hard it is to rank for them, who currently ranks. Analytics tools observe — they tell you what real users did. The two perspectives correct each other: SEO without analytics over-invests in keywords that don't convert; analytics without SEO optimises a leaky funnel without ever growing the top.

## SEO fundamentals — the four pillars

Modern SEO has four practical pillars. A campaign that's missing any one of them stalls.

| Pillar | What it covers | What goes wrong without it |
|---|---|---|
| **Technical SEO** | Crawlability, indexability, site speed, structured data, mobile-friendliness, HTTPS, canonicalisation, sitemap, robots.txt | Google can't index pages; rankings collapse silently |
| **On-page SEO** | Title tags, meta descriptions, H1-H6 structure, internal linking, content quality, keyword targeting, image alt-text, schema markup | Pages don't rank for their target keyword; CTR from SERP is poor |
| **Off-page SEO** | Backlinks, brand mentions, digital PR, citations, social signals (debated), unlinked mentions | Domain authority stays low; competitive keywords feel unreachable |
| **Content / Topical authority** | Long-form, topic clusters, pillar pages, EEAT signals (Experience, Expertise, Authoritativeness, Trustworthiness), content freshness | Site can't compete with established authorities even with perfect technicals |

The **EEAT** acronym (Experience, Expertise, Authoritativeness, Trustworthiness) was upgraded from EAT in **2022-12-15** when Google added the second "E" for Experience. It's not a direct ranking factor in the algorithm sense — it's the framework Google's human Search Quality Raters use to evaluate the algorithm's output. Pages that look credible to a human under the EEAT rubric correlate strongly with what the algorithm rewards. For YMYL ("Your Money or Your Life") topics — health, finance, legal — EEAT is heavily weighted.

## Keyword research — the load-bearing skill

Keyword research is the part of SEO that most distinguishes professional work from amateur work. Done well, it determines what pages you write, what they're titled, what queries they target, and which fights you pick.

### The vocabulary

| Term | Meaning | Why it matters |
|---|---|---|
| **Search volume** | Estimated monthly searches for a query (averaged over 12 months by most tools) | The size of the prize. Zero-volume keywords don't move revenue regardless of rank. |
| **Keyword difficulty (KD)** | Estimated effort to reach page 1 of Google, typically 0-100 scale | The cost of the prize. Different tools score KD differently — never compare KD across tools. |
| **CPC** | Cost-per-click from Google Ads auction data | Commercial intent proxy — high CPC = advertisers will pay, which usually means buyers exist. |
| **Search intent** | What the searcher actually wants: **informational**, **navigational**, **commercial**, **transactional** | Mismatching content type to intent means even rank 1 doesn't convert. |
| **SERP features** | Featured snippet, People Also Ask, knowledge panel, image pack, video carousel, AI Overview | They eat clicks. Knowing what's on the SERP is as important as knowing the rank. |
| **Long-tail keyword** | Low-volume, specific multi-word query (e.g., *"best open source product analytics for healthcare"*) | High intent, low competition. The vast bulk of valuable traffic comes from the long tail collectively. |
| **Topic cluster** | A pillar page + many related supporting pages, internally linked | Modern Google rewards topical depth, not single-page targeting. |
| **Cannibalisation** | Two of your own pages competing for the same keyword | Splits authority, confuses the algorithm — kill it via canonical, consolidation, or differentiation. |

### Intent matrix

The four-intent model is the default mental model. A query usually maps cleanly to one:

| Intent | Example queries | Right content type |
|---|---|---|
| **Informational** | *what is SEO*, *how to migrate to GA4*, *postgres vs mysql* | Long-form guide, definition, comparison, tutorial |
| **Navigational** | *posthog login*, *github docs*, *ahrefs* | Brand homepage, brand-specific landing |
| **Commercial investigation** | *best CRM for small business*, *posthog vs amplitude*, *cheap SEO tools* | Comparison, listicle, "best of" with explicit recommendation |
| **Transactional** | *buy ahrefs*, *posthog pricing*, *signup linear* | Product page, pricing page, signup-funnel page |

The intent test before writing: search the keyword yourself and look at what's ranking. If page 1 is all listicles and you publish a product page, you'll lose. The SERP is the canonical answer for "what does Google think the intent is."

### Process — what a marketer actually does

1. **Seed list** — start from 5-15 broad terms describing what you do. Ask the founder. Read customer support tickets. Look at AdWords reports if any.
2. **Expansion** — run each seed through a keyword tool's "matching terms" or "phrase match" report. Pull thousands of related queries.
3. **Filter by intent** — drop navigational queries for other brands (unless you're writing comparisons), drop irrelevant intents.
4. **Filter by KD vs DR** — keep keywords where the difficulty roughly matches your site's domain authority. A new site doesn't fight for KD-80 keywords; an established site doesn't waste effort on KD-3.
5. **Score by traffic potential, not search volume** — the page that ranks 1 for a given keyword usually ranks for hundreds of related queries. Tools like Ahrefs estimate the *total* traffic potential of a target page.
6. **Cluster by topic** — group keywords into topic clusters where one pillar page + 3-10 supporting pages cover the cluster.
7. **Prioritise** — rank clusters by `(traffic potential × business value) / (KD × content cost)`. Cheap wins first; cornerstone investments queued.

### The trap: zero-volume keywords aren't always zero-value

Tool-reported volume of 0-10 is unreliable for niche B2B and very new categories. Many marketers ship content for keywords the tools say have no volume because:

- Tools sample volume from clickstream + Ads data; both under-represent SaaS-buyer niches.
- A keyword going from "didn't exist" to "tool-reported 100/mo" usually means it was already searched 50+ times before the tool noticed.
- Long-tail with strong intent (*"capacitor vs cordova for healthcare app"*) converts at 5-10× the rate of informational head terms.

The pragmatic move: trust your domain knowledge over the volume number when the volume is reported as `0` or `10`. Trust the tool when volume is 1,000+.

## Competitor analysis — how marketers actually do it

This is the workflow that distinguishes SEO professionals from one-shot consultants. The repeatable loop:

### 1. Identify SEO competitors (not business competitors)

Your SEO competitors are sites Google ranks for *your* target keywords — not the companies sales calls them out as rivals. A new SaaS startup's SEO competitors are typically blog-heavy publishers (HubSpot, Zapier, content sites) more than peer SaaS products.

Tools that surface this: Ahrefs' *Competing Domains* report, Semrush's *Organic Competitors*, Sistrix's *Competitors* view. All work by intersecting the keyword universe each domain ranks for and surfacing the highest-overlap domains.

### 2. Content gap analysis

The defining technique: list every keyword a competitor ranks for that you don't. Sort by traffic potential. The top of that list is your **content roadmap**.

Mechanically: in Ahrefs, *Content Gap* takes 1-10 competitor domains + your domain and produces the diff. Semrush's *Keyword Gap* does the same thing. The output is hundreds-to-thousands of keyword opportunities ranked by metrics.

### 3. Backlink gap analysis

Same concept, applied to links: list every domain linking to a competitor that doesn't link to you. Sort by domain authority. The top is your **outreach roadmap** — these domains have demonstrably linked to similar content; they're warmer prospects than cold pitches.

### 4. SERP-level audit

For every priority keyword: search it in an incognito browser (or use the tool's SERP overview), record:

- Top 10 ranking URLs
- Domain Rating / Authority of each
- Word count of each
- Backlink count to each ranking URL
- What SERP features are present (Featured Snippet, PAA, AI Overview, video)
- Estimated traffic of each ranking page (from the tool)

This produces the brief for the content team: "to rank for X, we need a 3,500-word guide, 30+ referring domains, and we need to target the Featured Snippet currently held by competitor Y." The brief is testable; the bar for "is the content done?" becomes "does it beat the median ranking competitor on each dimension?"

### 5. Track share of voice

**Share of voice** = the percentage of total available organic traffic for your tracked keyword set that lands on your domain. Tracked monthly. Movement is the lagging indicator of SEO progress; absolute number is the strategic position.

## Technical SEO — what crawlers care about

The categorical floor. None of the content matters if Google can't crawl, render, and index it.

| Concern | What "good" looks like | How to check |
|---|---|---|
| **Crawlability** | `robots.txt` permits the right paths; no accidental `Disallow: /` | [Google Search Console](https://search.google.com/search-console) → URL Inspection |
| **Indexability** | Canonical tags consistent; no rogue `noindex` on money pages | GSC Coverage report |
| **Sitemap** | XML sitemap auto-generated, submitted to GSC, under 50k URLs per file | GSC Sitemaps section |
| **Site speed** | Core Web Vitals (LCP < 2.5s, INP < 200ms, CLS < 0.1) in the green | [PageSpeed Insights](https://pagespeed.web.dev), GSC Core Web Vitals report |
| **Mobile-friendliness** | Responsive design; no horizontal scroll; tap targets ≥ 48px | GSC Mobile Usability, Lighthouse |
| **HTTPS** | Full HTTPS, no mixed content, HSTS header | Any browser dev tools |
| **Structured data** | Schema.org JSON-LD on Article, Product, FAQ, HowTo, BreadcrumbList | [Rich Results Test](https://search.google.com/test/rich-results) |
| **Internal linking** | Every important page reachable within 3 clicks from home; clear hierarchy | Crawl the site with Screaming Frog or Sitebulb |
| **Hreflang** (multi-region) | Correct `hreflang` annotations linking translated pages | GSC International Targeting; Screaming Frog hreflang audit |
| **JavaScript rendering** | Critical content visible to Googlebot without JS, OR SSR/ISR/SSG ensures rendered DOM matches | GSC URL Inspection → "View Tested Page" |

**Core Web Vitals** ([web.dev/vitals](https://web.dev/articles/vitals)) are the user-experience signals Google uses as a tie-breaker in rankings. The three metrics changed in **March 2024** — INP (Interaction to Next Paint) replaced FID (First Input Delay) as the responsiveness metric. Field data from Chrome users (CrUX) feeds into rankings; lab data from Lighthouse approximates it.

**JavaScript SEO** is its own discipline. Single-page apps (React, Vue, Lustre, Elm) that render client-side need either: (a) SSR/ISR/SSG via Next.js / Nuxt / Remix / SvelteKit, or (b) dynamic rendering (serve a pre-rendered HTML version to bots — increasingly discouraged), or (c) careful confirmation via GSC URL Inspection that Googlebot's rendered DOM actually contains the content.

### Tools for technical audits

| Tool | Position | Pricing |
|---|---|---|
| **[Screaming Frog SEO Spider](https://www.screamingfrog.co.uk/seo-spider/)** | The industry-standard desktop crawler | Free up to 500 URLs; £199/year unlimited |
| **[Sitebulb](https://sitebulb.com)** | Desktop crawler with prioritised audit reports | $13.50/mo (Lite) to $35/mo (Pro) |
| **[Lighthouse](https://developer.chrome.com/docs/lighthouse)** | Google's open-source page-level audit | Free; built into Chrome DevTools |
| **[PageSpeed Insights](https://pagespeed.web.dev)** | Lighthouse + CrUX field data + recommendations | Free |
| **[Google Search Console](https://search.google.com/search-console)** | First-party crawl errors, performance, indexing data | Free |
| **[Bing Webmaster Tools](https://www.bing.com/webmasters)** | Bing equivalent of GSC; surprisingly useful free keyword research | Free |
| **[Ahrefs Site Audit](https://ahrefs.com/site-audit)** | Cloud-based crawler bundled with Ahrefs subscriptions | Bundled |
| **[Semrush Site Audit](https://www.semrush.com/site-audit/)** | Cloud-based crawler bundled with Semrush | Bundled |
| **[JetOctopus](https://jetoctopus.com)** | Enterprise log-file analysis + crawler | From €99/mo |
| **[Botify](https://www.botify.com)** | Enterprise crawl + log analysis + render-budget data | Custom (typically £25k+/yr) |

For small-to-medium sites, Screaming Frog + GSC + Lighthouse covers the whole job for £199/year. For sites over 1M URLs, log-file analysis (JetOctopus, Botify) becomes load-bearing — you need to know which URLs Googlebot actually fetches, not which ones exist.

## On-page SEO and content optimization

The set of moves applied per-page to improve rank for a specific target query.

| Element | Best practice (2026) |
|---|---|
| **Title tag** | 50-60 chars; target keyword near the start; emotional/curiosity hook if competitive |
| **Meta description** | 150-160 chars; not a ranking factor but determines CTR from SERP |
| **H1** | One per page; matches or paraphrases the title tag; contains primary keyword |
| **H2-H6** | Hierarchical; cover sub-topics from the SERP's People Also Ask box; semantically related keywords (entities) included |
| **URL slug** | Short, hyphenated, keyword-targeted; avoid stop words and dates |
| **First 100 words** | Answer the search intent immediately ("inverted pyramid"); include primary keyword once |
| **Internal links** | 3-10 contextual links to related pages on your site, with descriptive anchor text |
| **External links** | Link out to authoritative sources where it adds value; doesn't "leak" rank in any meaningful sense |
| **Image alt text** | Describe the image semantically; include keyword only if natural |
| **Schema markup** | JSON-LD; Article schema for blog posts, FAQ schema for Q&A sections, Product for ecommerce, HowTo for guides |
| **Content length** | Match or exceed the median word count of page 1 results — not a magic number but a competitive baseline |
| **Freshness** | Update + republish quarterly for "best/cheapest/X 2026"-style queries; less frequently for evergreen explainers |

### Content optimization tools

These tools score a draft against the SERP's ranking pages and suggest missing entities / keywords / headings.

| Tool | Position | Pricing |
|---|---|---|
| **[Clearscope](https://www.clearscope.io)** | Premium content brief + grading | From $189/mo |
| **[Surfer SEO](https://surferseo.com)** | Mid-market content optimizer + AI writer | From $69/mo |
| **[MarketMuse](https://www.marketmuse.com)** | Enterprise topical authority + content briefs | From $149/mo (Standard) |
| **[Frase](https://www.frase.io)** | Affordable brief + AI draft tool | From $14.99/mo (Solo) |
| **[NeuronWriter](https://www.neuronwriter.com)** | Polish-based, generous lifetime deals on AppSumo | From $19/mo |
| **[Page Optimizer Pro (POP)](https://pageoptimizer.pro)** | Score-driven on-page optimizer; deep technical | From $33/mo |
| **[Ahrefs Content Helper](https://ahrefs.com/content-helper)** | Bundled with Ahrefs subscription | Bundled |
| **[Semrush SEO Writing Assistant](https://www.semrush.com/seo-writing-assistant/)** | Bundled with Semrush; integrates with Google Docs / WordPress | Bundled |

The category has commoditised since 2024 — every tool scores against the same SERP signal. Choose by ecosystem (bundled with Ahrefs / Semrush wins on tool consolidation) or by integration (Frase + WordPress is a popular small-budget combo).

## Off-page SEO — backlinks, mentions, authority

Link-building is the slowest, most expensive, and most determinative part of SEO for competitive keywords.

### Concepts

| Term | Meaning |
|---|---|
| **Backlink** | An external link from another domain to yours |
| **Referring domains** | Unique linking domains; more meaningful than raw backlink count |
| **Domain Rating (DR)** | Ahrefs' 0-100 score of backlink profile strength (most-cited proxy for authority) |
| **Domain Authority (DA)** | Moz's equivalent of DR |
| **Authority Score** | Semrush's equivalent of DR |
| **Anchor text** | The clickable text of the link — natural variation good, exact-match spam dangerous |
| **dofollow vs nofollow** | `rel="nofollow"` links pass less authority signal; `dofollow` (the default) passes full signal |
| **Toxic backlinks** | Spam links Google may penalise; can be disavowed via GSC Disavow Tool |
| **Topical relevance** | A link from a relevant site is worth more than a higher-DR but irrelevant link |
| **Link velocity** | Rate of new links — unnatural spikes flag manipulation; steady growth is the goal |

### Link-building tactics (ranked by 2026 viability)

1. **Digital PR / data studies** — original research + outreach to journalists. Most consistent path to high-DR editorial links. Long lead time.
2. **Guest posting** — declining but still works on relevant industry sites. Avoid networks (Google penalises pattern detection).
3. **Broken link building** — find a broken external link on a high-DR page; offer your equivalent resource. Slow but high quality when it lands.
4. **Resource pages / awesome lists** — get included in curated lists in your niche. (See [Navigating ecosystems](navigating-ecosystems.md) on awesome lists.)
5. **HARO / Connectively / Qwoted / Featured.com** — respond to journalist queries; expert quotes become citations.
6. **Unlinked brand mentions** — find articles mentioning your brand without a link; ask politely for a link.
7. **Product Hunt / launch sites** — single-day traffic spikes + a handful of links; great for new SaaS.
8. **Sponsorships / partnerships** — disclosed sponsored links must use `rel="sponsored"`.
9. **Link exchanges** — small-scale reciprocal links remain common in practice despite being against Google's guidelines; scaled link networks get penalised.

### Backlink-analysis tools

All major SEO platforms have backlink databases. The size and freshness of the index is the key differentiator.

| Tool | Index size (claimed) | Notes |
|---|---|---|
| **[Ahrefs](https://ahrefs.com)** | ~35 trillion backlinks | Considered the freshest and largest; the reference standard |
| **[Semrush](https://www.semrush.com)** | ~43 trillion (claimed, snapshot 2025) | Comparable to Ahrefs; different ranking heuristics |
| **[Majestic](https://majestic.com)** | "Fresh" + "Historic" indexes | Pioneer of backlink databases; Trust Flow / Citation Flow metrics; cheaper than Ahrefs |
| **[Moz Link Explorer](https://moz.com/link-explorer)** | ~40+ trillion | Domain Authority (DA) originator; smaller real-time freshness than Ahrefs |
| **[LinkResearchTools](https://www.linkresearchtools.com)** | Aggregates 25+ link indexes | Premium; penalty-recovery / risk-focused use case |

## The AI-era shift — Generative Engine Optimization (GEO)

The largest acquisition-channel shift since mobile search. Since **late 2023** and accelerating through **2024-2026**, generative AI engines — ChatGPT, Perplexity, Google's AI Overviews / AI Mode, Bing Copilot, Claude with browsing, You.com — increasingly intercept queries that previously went to traditional search.

### What changed

| Traditional SEO | Generative Engine Optimization (GEO) |
|---|---|
| Rank in 10 blue links | Get cited by name in an AI-generated answer |
| Click-through rate from SERP | Citation rate inside LLM responses (no click required) |
| Keyword targeting | Entity targeting + semantic completeness |
| Backlinks as primary authority signal | Mentions, brand strength, and structured data as authority signals (LLMs read more sources) |
| Featured Snippet optimisation | "Quote-ready" answer formatting (numbered lists, definitions, distinct paragraphs) |
| Track rank position | Track citation share across LLM responses |

### Google AI Overviews (formerly SGE)

Google's generative-AI search experience rolled out widely in **May 2024** (US first) and globally through 2025-2026. Key implications:

- **Zero-click queries increase.** AI Overviews answer informational queries in the SERP without a click. Multiple studies estimate 30-60% CTR drops on informational queries showing AI Overviews.
- **Citation slots become the new top-of-funnel.** Pages cited in the AI Overview get brand exposure but reduced click volume.
- **Commercial queries less affected.** Transactional queries still drive clicks; informational queries lose most.

### Tracking GEO

A new category of tools tracks how often a brand or URL appears in LLM responses. As of snapshot 2026-06-14:

| Tool | Position | Pricing |
|---|---|---|
| **[Profound](https://www.tryprofound.com)** | Enterprise GEO tracking across ChatGPT, Perplexity, Google AI Mode, Claude | Custom (enterprise) |
| **[Otterly.AI](https://otterly.ai)** | Mid-market LLM visibility + brand monitoring | From $29/mo |
| **[Peec AI](https://peec.ai)** | AI search analytics for ChatGPT, Perplexity, AI Overviews | From €89/mo |
| **[AthenaHQ](https://athenahq.ai)** | Generative search ranking + optimization | From $99/mo |
| **[BrightEdge BrandEdge](https://www.brightedge.com)** | Enterprise SEO platform with AI search tracking added | Custom |
| **[Semrush AI Toolkit](https://www.semrush.com)** | AI Overview tracking bundled into Semrush plans | Bundled |
| **[Ahrefs Brand Radar](https://ahrefs.com)** | LLM brand-mention tracking bundled into Ahrefs | Bundled |

The market is brand-new and consolidating fast. Most independent GEO trackers launched 2024-2025; the major SEO platforms added equivalents within months. Expect significant churn over the next 12-18 months.

### What practically works for GEO (snapshot 2026)

1. **Strong entity definition.** Wikipedia entry, Wikidata entry, consistent NAP (Name/Address/Phone) across the web. LLMs cite what they can reliably identify.
2. **Structured data.** Schema.org, especially Organization, Person, Product, Article, FAQ. LLMs parse structured markup more reliably than prose.
3. **Quote-ready content blocks.** Numbered lists, clear definitions, distinct paragraphs with topic sentences. LLMs extract chunks; chunks that read cleanly out of context get cited.
4. **Statistics and original data.** LLMs cite numbers. Pages with original research, surveys, or proprietary data become reference sources.
5. **Brand mentions, not just links.** LLMs weight brand co-occurrence with topic keywords; unlinked mentions in authoritative content matter more than they did for traditional SEO.
6. **Up-to-date content.** Many LLMs prefer recent sources. Date-stamped, regularly updated pages get cited more.

The discipline is young enough that consensus on best practice is shifting monthly. The above is the snapshot 2026-06-14 view; revisit quarterly.

## SEO tools by tier and price

The category sorts into four price tiers. Within each tier the tools are roughly substitutable; across tiers they're not.

### Enterprise tier ($99-$500+/mo) — full platforms

The full-stack tools senior SEO professionals and agencies use. All cover: keyword research, rank tracking, site audit, backlink analysis, competitor research, content tools.

| Tool | Starting price | Strengths | Weaknesses |
|---|---|---|---|
| **[Ahrefs](https://ahrefs.com)** | $129/mo (Lite) → $1499/mo (Enterprise) | Freshest backlink index, best content gap analysis, fastest UI, generous data limits | No share of voice; expensive at scale |
| **[Semrush](https://www.semrush.com)** | $139.95/mo (Pro) → $499.95/mo (Business) | Broadest feature set (PPC, social, PR, local SEO), strongest US data, share-of-voice tracking | UI dense; per-seat pricing climbs fast |
| **[Moz Pro](https://moz.com/products/pro)** | $49/mo (Starter) → $599/mo (Premium) | Domain Authority originator, friendly UI, strong educational content | Smaller backlink index than Ahrefs/Semrush; trails on feature releases |
| **[Sistrix](https://www.sistrix.com)** | €99/mo (Plus) → €299/mo (Professional) | Strongest European data, "Visibility Index" is the German-market reference | Lower US data depth; smaller feature surface |
| **[seoClarity](https://www.seoclarity.net)** | Custom (typically $3000+/mo) | Enterprise-only; deep integrations; full-managed | Sales-led; not for SMB |
| **[BrightEdge](https://www.brightedge.com)** | Custom (typically $3000+/mo) | Enterprise content marketing + AI search | Sales-led; locked-in contracts |
| **[Conductor](https://www.conductor.com)** | Custom | Enterprise SEO + content intelligence | Sales-led |
| **[Searchmetrics](https://www.searchmetrics.com)** | Custom | Enterprise; strong European data | Sales-led |

For most SaaS / SMB / mid-market use, **Ahrefs or Semrush** is the answer. The two have feature parity within 10%; pick by UI preference and which features you actually use. Moz Pro is the budget choice in this tier if Ahrefs/Semrush feel overkill.

### Mid-tier ($30-$99/mo) — strong all-rounders

Cover the same job as enterprise tools at smaller data limits and depth. Right for solo SEOs, indie founders, small marketing teams.

| Tool | Starting price | Strengths | Notes |
|---|---|---|---|
| **[SE Ranking](https://seranking.com)** | $65/mo (Essential) → $259/mo (Business) | Full platform; strong rank tracking; generous limits for price | The closest "Ahrefs/Semrush at half the price" pick |
| **[Mangools](https://mangools.com)** (KWFinder + SERPChecker + LinkMiner + SiteProfiler + SERPWatcher) | $29/mo (Basic, annual) → $79/mo (Agency) | Beginner-friendly, fast UI, KWFinder is the best entry-level keyword tool | Smaller indexes than enterprise tier; agency seat limits low |
| **[SpyFu](https://www.spyfu.com)** | $39/mo (Basic) → $299/mo (Team) | PPC competitor intel; historical advertiser data; lifetime SERP history | Smaller backlink index; US-skewed |
| **[Serpstat](https://serpstat.com)** | $59/mo (Lite) → $499/mo (Agency) | Eastern-European-grown all-rounder; strong on Russian/CIS markets | Some UI rough edges; smaller English-language depth |
| **[KWFinder](https://kwfinder.com)** (standalone) | $29/mo | Keyword research only; cleanest UI in the category | Mangools' standalone keyword tool |
| **[Sitechecker](https://sitechecker.pro)** | $49/mo → $249/mo | Site audit + rank tracking + backlink; good free trials | Mid-market; smaller feature surface |
| **[Ubersuggest](https://neilpatel.com/ubersuggest)** | $12/mo (Individual, annual) → $40/mo (Business) | Cheapest "branded" all-rounder; Neil Patel marketing engine | Data quality and freshness lag enterprise tools |

### Affordable / lifetime-deal tier (under $30/mo or one-time)

Specialised tools or aggressive-pricing alternatives. Right for hobby projects, one-off audits, students learning.

| Tool | Price | Notes |
|---|---|---|
| **[Mangools Basic](https://mangools.com)** | $29/mo | Repeat of above — the most popular entry-level all-rounder |
| **[SEO PowerSuite](https://www.link-assistant.com)** | Free / $299 (Pro one-time) / $699 (Enterprise one-time) | Desktop apps for rank tracking, audit, backlinks. One-time pricing is unusual in this market |
| **[RankMath](https://rankmath.com)** | Free / $6.99/mo (Pro) | WordPress plugin; on-page SEO + schema + redirects |
| **[Yoast SEO](https://yoast.com/wordpress/plugins/seo/)** | Free / $99/yr (Premium) | WordPress plugin; the WP default; on-page guidance + redirects |
| **[Frase](https://www.frase.io)** | $14.99/mo (Solo) | Content brief + AI draft; competes with Surfer at half the price |
| **[NeuronWriter](https://www.neuronwriter.com)** | $19/mo | AppSumo lifetime deals appear regularly ($69-$149 one-time) |
| **[Lowfruits](https://lowfruits.io)** | Pay-as-you-go from $0.075/check | Niche tool focused on finding low-KD keywords with weak ranking pages |
| **[Keysearch](https://www.keysearch.co)** | $17/mo (Starter) | Budget Ahrefs-lite for keyword research |

### Lifetime / one-time SEO tool deals

A few categories regularly appear on **AppSumo** with lifetime deals (typically $59-$299 one-time): NeuronWriter, Writesonic, Lowfruits, Mangools (historically), various rank trackers. Pattern: the deal site discounts heavily to capture market share early; the tool eventually moves to subscription-only when established. Lifetime deals are real but indicate the tool is early-stage; treat the data freshness with appropriate scepticism.

## Free SEO tools that punch above their weight

The free tier is more useful than most realise. A determined solo founder can run a real SEO programme on zero tooling spend for the first 12 months.

| Tool | What it does | Quality |
|---|---|---|
| **[Google Search Console](https://search.google.com/search-console)** | First-party indexing, performance (impressions / clicks / CTR / position) per query and per page | The most important SEO tool, period. Use it daily. |
| **[Bing Webmaster Tools](https://www.bing.com/webmasters)** | Bing equivalent + the surprisingly-good free **Keyword Research** tool | Bing's free keyword tool is competitive with paid tools for SMB use |
| **[Google Trends](https://trends.google.com)** | Relative search-volume changes over time; geo-breakdown | Indispensable for spotting trend shifts; not absolute volumes |
| **[Google Keyword Planner](https://ads.google.com/intl/en/home/tools/keyword-planner/)** | Keyword volume + competition data (logged in Google Ads account, no spend required) | Required login + account setup; data is bracketed, not exact |
| **[Ahrefs Free Tools](https://ahrefs.com/free-seo-tools)** | Free Backlink Checker (top 100 links), Keyword Generator, Website Authority Checker, Broken Link Checker | The free tools are limited but accurate within those limits; great for teaser/learning |
| **[Ahrefs Webmaster Tools (AWT)](https://ahrefs.com/webmaster-tools)** | Free Ahrefs site audit + backlink data for sites you verify ownership of | Massively undersold — paid-tier site audit + DR for verified domains, free |
| **[Semrush Free](https://www.semrush.com)** | 10 free searches/day; some tools fully free (Position Tracking limited) | Useful for learning; insufficient for daily work |
| **[Moz Free Tools](https://moz.com/free-seo-tools)** | DA Checker, Keyword Explorer (limited queries), Link Explorer | Limited queries per day; good for spot-checks |
| **[AnswerThePublic](https://answerthepublic.com)** | Visualises questions ("what", "how", "why", "is") around a seed keyword | Free 3 searches/day; great for content ideation |
| **[AlsoAsked](https://alsoasked.com)** | Maps the "People Also Ask" tree from Google for a seed query | Free 3 searches/day; useful for topic clusters |
| **[Keyword Surfer](https://surferseo.com/keyword-surfer-extension/)** | Free Chrome extension showing search volumes inline in Google SERP | Free; the Surfer SEO entry point |
| **[Ubersuggest free](https://neilpatel.com/ubersuggest)** | 3 free searches/day; full data with paid plan | Decent at the free tier; quality is competitive at the lower paid tier |
| **[Microsoft Clarity](https://clarity.microsoft.com)** | Session replay + heatmaps + scrollmaps; unlimited free | Free, no quota — a real Hotjar alternative |
| **[Schema.org](https://schema.org)** + **[Rich Results Test](https://search.google.com/test/rich-results)** | Schema vocabulary + Google's validator | Free; canonical |
| **[Wayback Machine](https://web.archive.org)** | Historical snapshots of any page or domain | Free; useful for competitor history and link-recovery investigations |

The realistic free-tier programme: **GSC + Bing WT + Google Trends + Ahrefs Webmaster Tools + Google Search Console Insights + Microsoft Clarity** runs an SMB site for a year before you genuinely need to upgrade. Add a paid keyword tool (KWFinder, Mangools Basic) at the point you outgrow Bing's free keyword search.

## Web analytics — measuring the traffic

The other half of the loop: once you have traffic, what are visitors doing?

### Platform landscape

| Tool | Position | Pricing |
|---|---|---|
| **[Google Analytics 4 (GA4)](https://analytics.google.com)** | The default; event-based model replacing Universal Analytics (sunset 2023-07-01) | Free up to 10M events/month; GA4 360 enterprise from ~$50k/yr |
| **[Plausible](https://plausible.io)** | Privacy-first, cookieless, EU-based, GDPR-compliant by design | From $9/mo; self-hostable (open-source AGPL) |
| **[Fathom Analytics](https://usefathom.com)** | Privacy-first, simple UI, no cookies | From $15/mo |
| **[Umami](https://umami.is)** | Open-source, self-hostable, privacy-focused | Free self-host; $9/mo cloud |
| **[Matomo (Piwik)](https://matomo.org)** | Open-source GA replacement; full-featured | Free self-host; €19/mo (Matomo Cloud) |
| **[PostHog](https://posthog.com)** | Product analytics + session replay + flags + experiments + surveys | Free tier 1M events/mo; usage-based after. Open-source. (See [UX article](ux-resources-and-tools.md#posthog--instrumentation-that-complements-dogfooding) for deep review.) |
| **[Mixpanel](https://mixpanel.com)** | Product analytics; deeper cohorts and funnels than GA4 | Free tier 1M events/mo; paid from $24/mo |
| **[Amplitude](https://amplitude.com)** | Enterprise product analytics; deep analyst tooling | Free tier 1M events/mo (Plus); enterprise from $49k+/yr |
| **[Heap](https://heap.io)** | Autocapture (all events tracked automatically); lighter setup | Free tier; paid from custom |
| **[FullStory](https://fullstory.com)** | Session replay first; heatmaps + frustration signals | Custom pricing |
| **[Hotjar](https://www.hotjar.com)** | Heatmaps + session replay + surveys | Free Basic; $32/mo Plus → $171/mo Scale |
| **[Microsoft Clarity](https://clarity.microsoft.com)** | Free heatmaps + session replay; surprisingly capable | Free, unlimited |
| **[Mouseflow](https://mouseflow.com)** | Heatmaps + replays + form analytics | From $39/mo |
| **[Adobe Analytics](https://business.adobe.com/products/analytics/adobe-analytics.html)** | Enterprise analytics; deepest customisation; CMP integration | Custom (typically $50k+/yr) |
| **[Pirsch](https://pirsch.io)** | EU-based, privacy-friendly, cookieless, lightweight | From $6/mo |
| **[GoatCounter](https://www.goatcounter.com)** | Open-source, free for small sites | Free <100k pageviews/mo |
| **[Simple Analytics](https://www.simpleanalytics.com)** | Privacy-first, beautifully minimal | From $9/mo |

### Web vs product analytics — which to pick

The categories overlap but aren't identical:

| If you want to know… | Use |
|---|---|
| Where my traffic comes from, what's growing/shrinking, which pages perform | Web analytics (GA4, Plausible, Fathom, Matomo) |
| What users do *inside* my product (event funnels, retention, cohorts) | Product analytics (PostHog, Mixpanel, Amplitude) |
| Why users are dropping off (replay, heatmap, frustration signal) | Session replay / heatmap (Clarity, Hotjar, FullStory, PostHog) |
| Which version of a UI converts better | Experimentation (PostHog, GrowthBook, Optimizely, VWO) |
| Are real visitors hitting our Core Web Vitals targets | Real-User Monitoring (Sentry, Datadog, SpeedCurve, Cloudflare Web Analytics) |

For a typical SaaS website + product combo: **Plausible (or GA4) for marketing-site web analytics + PostHog for product analytics + Microsoft Clarity for free replay**. Total cost: ~$9/mo Plausible + free tiers of PostHog/Clarity = ~$108/yr until you exceed the PostHog free tier.

### GA4 — the inescapable default

Google sunset Universal Analytics on **2023-07-01**. GA4 is the replacement. Notable shifts from UA:

| UA → GA4 change | Impact |
|---|---|
| Sessions → Events | Everything is an event; sessions are derived |
| Bounce rate → Engagement rate | "Engagement" = session ≥10s OR conversion OR ≥2 pageviews; replaces the much-maligned UA bounce rate |
| Data retention defaults to 2 months | Must be manually extended to 14 months max (per GDPR concerns) |
| BigQuery export | Free in GA4 (was paid-only in UA); huge improvement for analytics teams |
| Predictive metrics | Purchase probability, churn probability built-in |
| Reporting interface | Less mature than UA; many marketers still find it harder |
| Cross-platform unified | Web + app events in one property |

The complaints about GA4 are real (UI churn, missing reports, data-thresholding hiding low-volume queries). The reasons to use it anyway: it's free, it integrates with Google Ads / Search Console / Looker Studio, and the entire SEO/PPC industry assumes you have it. Most teams run GA4 alongside a privacy-friendly alternative for the cleaner UI.

### Privacy and cookie-consent shifts

The major shift since 2018: privacy regulations (GDPR 2018, CCPA/CPRA 2020-2023, DSA 2024, EU Cookie Consent / ePrivacy) have changed what you can track, how, and after what user action.

| Concern | Practical effect |
|---|---|
| **Cookie consent** | EU users must explicitly opt in to non-essential cookies; default analytics with cookies requires a CMP (Consent Management Platform) |
| **Server-side tracking** | First-party server-side tagging via Google Tag Manager Server-Side or **[Stape](https://stape.io)** moves cookie creation server-side; bypasses many ad-blockers |
| **First-party vs third-party data** | Walled gardens (Apple Mail open-detection, Safari ITP, iOS 14.5 ATT) have neutered cross-site tracking; first-party data is the new strategic asset |
| **Cookieless analytics** | Plausible, Fathom, Umami, Pirsch all skip cookies — no consent banner required in most jurisdictions |
| **EU vs US data residency** | Schrems II + EU-US Data Privacy Framework: GA4 on EU users now requires care; some EU regulators have ruled GA4 non-compliant |
| **AdBlocker prevalence** | ~30-40% of technical-audience traffic blocks analytics scripts; under-counting is systemic — server-side or first-party-domain-served scripts mitigate but don't eliminate |
| **Apple Mail Privacy Protection (2021)** | Pre-loads email images, breaking email open-rate tracking; affects email-marketing analytics, not web |

The pragmatic stack for a privacy-conscious SaaS in 2026: **Plausible/Fathom (cookieless, no banner) for marketing-site + PostHog (event-based, consent-gated for tracked users) for product + server-side tagging for paid-ad attribution**.

## The full marketer playbook

How a senior SEO + analytics practitioner actually drives and measures traffic. This is the loop.

### Weekly rhythm

| Day | Activity |
|---|---|
| **Mon** | Pull GSC weekly performance report; eyeball top-movers (up and down); investigate drops > 20% |
| **Tue** | Run rank tracker on top 100 keywords; compare to last week; investigate ranking drops |
| **Wed** | Content production: brief + draft + edit for that week's content piece(s) |
| **Thu** | Backlink monitoring: any lost links to investigate? Any new linking opportunities surfaced by the link-building campaign? |
| **Fri** | Reporting: weekly traffic summary to stakeholders; planning for next week |

### Quarterly rhythm

- **Content audit** — every page on the site classified as: keep & maintain / refresh / consolidate / delete. Pruning thin content boosts overall site quality signal.
- **Backlink audit** — full backlink profile review; disavow toxic; cluster the new acquisitions.
- **Technical audit** — full Screaming Frog crawl; resolve any new errors; revisit Core Web Vitals against the latest CrUX update.
- **Competitor re-evaluation** — content gap analysis vs current top 5 competitors; refresh the keyword roadmap.
- **Strategy review** — what's working, what isn't, what should we stop?

### Annual rhythm

- **Re-evaluate tooling** — is the SEO platform still earning its subscription? Could a cheaper alternative cover 80% of the use? Do we need to add a GEO tracker?
- **Re-evaluate content strategy** — major Google algorithm updates (typically 3-5 per year named, plus continuous unnamed shifts) sometimes invalidate prior tactics. Reassess.
- **Brand search measurement** — has branded search volume grown? This is the single best proxy for overall brand-building ROI.

### KPIs marketers actually report on

| KPI | What it measures | Where it comes from |
|---|---|---|
| **Organic traffic (sessions / users)** | Volume of search-driven visits | GA4 / Plausible |
| **Organic clicks and impressions** | First-party search performance | GSC |
| **Click-through rate (CTR)** by query and by position | Title/meta effectiveness, SERP feature impact | GSC |
| **Average position** | Where you rank for tracked queries | GSC + rank tracker |
| **Top 3 / Top 10 keyword count** | Distribution of rankings; "1 keyword at #1, 1000 at #50" is different from "100 at #5" | Rank tracker |
| **Share of voice** | Your share of available organic traffic for tracked keywords | SEO platform |
| **Domain Rating / Authority** | Backlink-profile strength | Ahrefs / Moz |
| **Conversion rate from organic** | Did the traffic translate to signups / sales | GA4 + product analytics |
| **Branded vs non-branded split** | Brand awareness component vs SEO acquisition component | GSC |
| **AI Overview / citation share** | Visibility in AI-generated answers | GEO tracker |

The single most important KPI for most growth-stage companies: **organic clicks to high-intent commercial pages**, measured in GSC, filtered to pricing / signup / comparison pages. This number ties acquisition spend forecasts directly to SEO work.

## Leaderboard — SEO + analytics tools at a glance

Five-dimension scoring across the tools reviewed in this article. The dimensions:

- **Authority** — depth of underlying data / institutional credibility / industry adoption. 🟩🟩 = category-defining; 🟩 = strong contender; 🟨 = useful niche; 🟥 = thin.
- **Accessibility** — how easy is it to actually use as a non-expert? 🟩🟩 = signup-to-insight in minutes; 🟩 = readable but takes time; 🟨 = steep curve; 🟥 = enterprise-only.
- **Depth** — how far down does the rabbit hole go? 🟩🟩 = full-platform, weeks-of-learning; 🟩 = solid coverage; 🟨 = single-purpose treatment; 🟥 = surface only.
- **Currency** — is it actively maintained, feature-current? 🟩🟩 = updated monthly; 🟩 = quarterly; 🟥 = stale.
- **Cost** — 🟩🟩 = entirely free; 🟩 = free tier covers most use; 🟨 = affordable paid ($15-$100/mo); 🟥 = expensive ($100+/mo or enterprise).

### SEO platforms

| Tool | Authority | Accessibility | Depth | Currency | Cost | Verdict |
|---|:---:|:---:|:---:|:---:|:---:|---|
| **[Ahrefs](#enterprise-tier-99-500mo--full-platforms)** | 🟩🟩 | 🟩 | 🟩🟩 | 🟩🟩 | 🟥 | The default for serious work. Best content gap analysis + freshest backlinks. |
| **[Semrush](#enterprise-tier-99-500mo--full-platforms)** | 🟩🟩 | 🟨 | 🟩🟩 | 🟩🟩 | 🟥 | Broadest feature surface; share-of-voice; PPC bonus. UI denser than Ahrefs. |
| **[Moz Pro](#enterprise-tier-99-500mo--full-platforms)** | 🟩 | 🟩🟩 | 🟩 | 🟩🟩 | 🟨 | Friendly UI; DA originator; lags Ahrefs/Semrush on features but cheapest of the three. |
| **[Sistrix](#enterprise-tier-99-500mo--full-platforms)** | 🟩 | 🟩 | 🟩 | 🟩🟩 | 🟥 | European-market reference (Visibility Index); weaker outside Europe. |
| **[SE Ranking](#mid-tier-30-99mo--strong-all-rounders)** | 🟩 | 🟩 | 🟩 | 🟩🟩 | 🟨 | Closest "Ahrefs at half-price" pick for SMB. |
| **[Mangools / KWFinder](#mid-tier-30-99mo--strong-all-rounders)** | 🟩 | 🟩🟩 | 🟨 | 🟩🟩 | 🟨 | Best beginner UX; the gateway drug. |
| **[Ubersuggest](#mid-tier-30-99mo--strong-all-rounders)** | 🟨 | 🟩🟩 | 🟨 | 🟩 | 🟩 | Cheapest branded all-rounder; data freshness/depth lags. |
| **[Lowfruits](#affordable--lifetime-deal-tier-under-30mo-or-one-time)** | 🟨 | 🟩🟩 | 🟨 | 🟩 | 🟩 | Pay-as-you-go niche tool for low-KD opportunities. |
| **[GSC](#free-seo-tools-that-punch-above-their-weight)** | 🟩🟩 | 🟩 | 🟩 | 🟩🟩 | 🟩🟩 | Non-negotiable. First-party impressions/clicks/CTR. |
| **[Ahrefs Webmaster Tools](#free-seo-tools-that-punch-above-their-weight)** | 🟩🟩 | 🟩 | 🟩 | 🟩🟩 | 🟩🟩 | Massively undersold free tier — paid-tier audit + DR for verified domains. |
| **[Bing Webmaster Tools](#free-seo-tools-that-punch-above-their-weight)** | 🟩 | 🟩 | 🟨 | 🟩🟩 | 🟩🟩 | Free keyword research tool — surprisingly competitive. |
| **[Google Trends](#free-seo-tools-that-punch-above-their-weight)** | 🟩🟩 | 🟩🟩 | 🟨 | 🟩🟩 | 🟩🟩 | Relative trend data, geo-breakdowns. Free. |

### Technical SEO

| Tool | Authority | Accessibility | Depth | Currency | Cost | Verdict |
|---|:---:|:---:|:---:|:---:|:---:|---|
| **[Screaming Frog](#tools-for-technical-audits)** | 🟩🟩 | 🟩 | 🟩🟩 | 🟩🟩 | 🟨 | Industry-standard desktop crawler. £199/year unlimited. |
| **[Sitebulb](#tools-for-technical-audits)** | 🟩 | 🟩🟩 | 🟩 | 🟩🟩 | 🟨 | Friendlier prioritised audit reports than Screaming Frog. |
| **[Lighthouse](#tools-for-technical-audits)** | 🟩🟩 | 🟩🟩 | 🟩 | 🟩🟩 | 🟩🟩 | Google's open-source per-page audit. In Chrome DevTools. |
| **[PageSpeed Insights](#tools-for-technical-audits)** | 🟩🟩 | 🟩🟩 | 🟩 | 🟩🟩 | 🟩🟩 | Lighthouse + CrUX field data. Free. |
| **[Botify](#tools-for-technical-audits)** | 🟩🟩 | 🟨 | 🟩🟩 | 🟩🟩 | 🟥 | Enterprise log-file analysis. Required at 1M+ URLs. |

### Content optimization

| Tool | Authority | Accessibility | Depth | Currency | Cost | Verdict |
|---|:---:|:---:|:---:|:---:|:---:|---|
| **[Clearscope](#content-optimization-tools)** | 🟩🟩 | 🟩🟩 | 🟩 | 🟩🟩 | 🟥 | Premium content brief tool; the agency standard. |
| **[Surfer SEO](#content-optimization-tools)** | 🟩 | 🟩🟩 | 🟩 | 🟩🟩 | 🟥 | Mid-market; AI writer included. |
| **[Frase](#content-optimization-tools)** | 🟩 | 🟩🟩 | 🟩 | 🟩🟩 | 🟨 | Affordable brief + AI draft; underrated. |
| **[NeuronWriter](#content-optimization-tools)** | 🟨 | 🟩 | 🟩 | 🟩🟩 | 🟨 | AppSumo lifetime-deal favourite. |
| **[MarketMuse](#content-optimization-tools)** | 🟩 | 🟨 | 🟩🟩 | 🟩🟩 | 🟥 | Topical authority focus; enterprise. |

### Web analytics

| Tool | Authority | Accessibility | Depth | Currency | Cost | Verdict |
|---|:---:|:---:|:---:|:---:|:---:|---|
| **[GA4](#ga4--the-inescapable-default)** | 🟩🟩 | 🟨 | 🟩🟩 | 🟩🟩 | 🟩🟩 | The default. Imperfect, free, integrates with everything Google. |
| **[Plausible](#platform-landscape)** | 🟩 | 🟩🟩 | 🟩 | 🟩🟩 | 🟨 | Cookieless, privacy-friendly, no consent banner. Self-hostable. |
| **[Fathom](#platform-landscape)** | 🟩 | 🟩🟩 | 🟩 | 🟩🟩 | 🟨 | Plausible's closest competitor; cleaner UI; closed-source. |
| **[Matomo](#platform-landscape)** | 🟩 | 🟨 | 🟩🟩 | 🟩🟩 | 🟩 | Most feature-complete open-source GA replacement. |
| **[Umami](#platform-landscape)** | 🟩 | 🟩🟩 | 🟩 | 🟩🟩 | 🟩🟩 | Open-source, lightweight, self-host free. |
| **[PostHog](#platform-landscape)** | 🟩 | 🟩 | 🟩🟩 | 🟩🟩 | 🟩 | Product analytics + replay + flags. Open-source. Deep review in [UX article](ux-resources-and-tools.md#posthog--instrumentation-that-complements-dogfooding). |
| **[Mixpanel](#platform-landscape)** | 🟩🟩 | 🟩 | 🟩🟩 | 🟩🟩 | 🟩 | Closed-source; stronger BI / cohort UX than GA4. |
| **[Amplitude](#platform-landscape)** | 🟩🟩 | 🟨 | 🟩🟩 | 🟩🟩 | 🟥 | Enterprise product analytics; deepest analyst tooling. |
| **[Microsoft Clarity](#free-seo-tools-that-punch-above-their-weight)** | 🟩 | 🟩🟩 | 🟩 | 🟩🟩 | 🟩🟩 | Free unlimited replay + heatmap. Real Hotjar alternative. |
| **[Hotjar](#platform-landscape)** | 🟩🟩 | 🟩🟩 | 🟩 | 🟩🟩 | 🟨 | Heatmaps + replay + surveys. Clarity is the free alternative. |
| **[FullStory](#platform-landscape)** | 🟩 | 🟩 | 🟩🟩 | 🟩🟩 | 🟥 | Replay + frustration signals; enterprise. |

### Generative Engine Optimization (GEO)

| Tool | Authority | Accessibility | Depth | Currency | Cost | Verdict |
|---|:---:|:---:|:---:|:---:|:---:|---|
| **[Profound](#tracking-geo)** | 🟩 | 🟨 | 🟩🟩 | 🟩🟩 | 🟥 | Enterprise GEO category leader at snapshot. |
| **[Otterly.AI](#tracking-geo)** | 🟨 | 🟩 | 🟩 | 🟩🟩 | 🟨 | Mid-market LLM visibility. |
| **[Peec AI](#tracking-geo)** | 🟨 | 🟩 | 🟩 | 🟩🟩 | 🟨 | AI search analytics. |
| **[Semrush AI Toolkit](#tracking-geo)** | 🟩 | 🟩 | 🟩 | 🟩🟩 | 🟥 | Bundled with Semrush. |
| **[Ahrefs Brand Radar](#tracking-geo)** | 🟩 | 🟩 | 🟩 | 🟩🟩 | 🟥 | Bundled with Ahrefs. |

> [!IMPORTANT]
> **The GEO category is brand-new.** Most independent trackers launched 2024-2025; major SEO platforms added equivalents in 2025-2026. Expect significant churn — picks here are point-in-time and should be re-evaluated quarterly.

### Recommendation by situation

- **Solo founder, brand-new SaaS, $0 budget:** GSC + Bing WT + Ahrefs Webmaster Tools (free) + Microsoft Clarity (free) + Plausible self-host or GA4 + Google Trends + AnswerThePublic. Read [Backlinko](https://backlinko.com) and [Ahrefs Blog](https://ahrefs.com/blog) free. Total cost: $0. Sufficient for the first 12 months.
- **Small team, post-PMF, $200/mo budget:** Mangools KWFinder ($29) + Microsoft Clarity (free) + Plausible ($9) + PostHog free tier + Frase ($15). Total: ~$53/mo. Covers everything an indie SaaS needs through ~$1M ARR.
- **Growth-stage SaaS, $500-$1500/mo budget:** Ahrefs Lite or Standard ($129-$249) + Surfer SEO ($69) + PostHog (usage-based, likely $50-$300) + GA4 + Microsoft Clarity. Total: $250-$650/mo. The professional minimum.
- **Series-B+ with content-marketing team:** Ahrefs Advanced ($449) + Semrush Business ($499) + Clearscope ($189) + an enterprise rank tracker + GEO tracker (Otterly $89-$200) + PostHog or Amplitude. Total: $1500-$3000+/mo. Justified by 10+ content pieces shipped weekly and dedicated SEO headcount.

## Cross-links

This article touches several adjacent topics covered elsewhere in the repo:

- **[UX resources & tools](ux-resources-and-tools.md)** — the conversion-side of acquisition. Once SEO drives traffic, UX determines whether they convert. PostHog is reviewed in depth there.
- **[BDD with Gherkin](bdd-with-gherkin.md)** — encoding marketer/PM expectations about user flows as executable specs; downstream of acquisition.
- **[Navigating ecosystems](navigating-ecosystems.md)** — discovery techniques (awesome lists, comparison pages, ossinsight) overlap with how SEO researchers find ranking-opportunity gaps.
- **[Recent incidents in major technologies](recent-incidents-in-major-technologies.md)** — analytics tools handle PII; supply-chain and privacy incidents directly affect tool choice.

---

**Snapshot 2026-06-14.** Submit issues for missing tools, repo updates, or corrections.
