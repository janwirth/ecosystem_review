# Marketing — SEO & Analytics

> [!NOTE]
> **Status:** DRAFT · **Authoring:** AI-assisted, human-reviewed.

**Two disciplines, one feedback loop.** This folder covers **SEO** (how you get found by people who don't already know you exist) and **web/product analytics** (how you measure what they do once they arrive). They are different jobs with different tools — but neither works without the other. SEO without analytics is faith. Analytics without acquisition is a clipboard with nothing to count.

**Snapshot 2026-07-02** — pricing, tool feature sets, and database sizes pulled from logged-out marketing pages and public docs at snapshot date. Tool pricing in particular fluctuates monthly; treat exact numbers as a point-in-time reading.

## What's in this folder

- **[SEO](seo.md)** — the acquisition side. Technical SEO, keyword research, competitor analysis, backlinks, on-page, content, GEO (Generative Engine Optimization), tool tiers, per-capability feature matrix, "which tool for which job" table.
- **[Analytics](analytics.md)** — the measurement side. Web analytics vs product analytics, session replay, heatmaps, funnels, A/B testing, GA4, privacy/consent, per-tool feature matrix, PostHog OSS resource-hunger warning.

## The SEO vs analytics line

When someone says "we need to improve our marketing", they usually mean one of three things:

1. **Nobody finds us.** Direct traffic is flat, search impressions are low, the site doesn't rank for terms the team thinks it should. *This is SEO.*
2. **People find us but don't convert.** Traffic is fine, but visitors bounce, the funnel leaks, the activation event never fires. *This is analytics + UX, not SEO.* (See [UX resources & tools](../design/ux.md).)
3. **We don't know what's happening.** No instrumentation, no dashboards, no source attribution. *This is the analytics setup phase — prerequisite to both of the above.*

This folder covers **(1)** in [seo.md](seo.md) and **(3)** in [analytics.md](analytics.md). The (2)-shaped problem is downstream — you need to know who's arriving (analytics) and from where (SEO attribution) before you can ask why they're leaving.

The operational distinction: **SEO is about the impressions and clicks you haven't earned yet**. Analytics is about the sessions you already have. SEO tools forecast — they tell you what searches happen, how hard it is to rank for them, who currently ranks. Analytics tools observe — they tell you what real users did. The two perspectives correct each other: SEO without analytics over-invests in keywords that don't convert; analytics without SEO optimises a leaky funnel without ever growing the top.

## Cross-links

- **[UX resources & tools](../design/ux.md)** — the conversion-side of acquisition. Once SEO drives traffic, UX determines whether they convert. PostHog is reviewed in depth there.
- **[BDD with Gherkin](../practices/bdd-with-gherkin.md)** — encoding marketer/PM expectations about user flows as executable specs; downstream of acquisition.
- **[Navigating ecosystems](../industry-watch/navigating-ecosystems.md)** — discovery techniques (awesome lists, comparison pages, ossinsight) overlap with how SEO researchers find ranking-opportunity gaps.
- **[Recent incidents in major technologies](../industry-watch/recent-incidents.md)** — analytics tools handle PII; supply-chain and privacy incidents directly affect tool choice.
