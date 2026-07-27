# Analytics — A Curated Review

> [!NOTE]
> **Status:** DRAFT · **Authoring:** AI-assisted, human-reviewed.

> **Analytics is about the sessions you already have.** This article covers the measurement side: web analytics vs product analytics, session replay, heatmaps, funnels, retention, A/B testing, GA4, privacy/consent, and the tool landscape. See [seo.md](seo.md) for the acquisition side.

**Snapshot 2026-07-02** — pricing and tool feature sets pulled from logged-out marketing pages and public docs at snapshot date. Pricing fluctuates monthly; treat exact numbers as a point-in-time reading.

## Table of Contents

1. [Web vs product analytics — which to pick](#web-vs-product-analytics--which-to-pick)
2. [Platform landscape](#platform-landscape)
3. [Feature comparison matrix — which tool does what](#feature-comparison-matrix--which-tool-does-what)
   - [How to read the matrix](#how-to-read-the-matrix)
   - [The matrix](#the-matrix)
   - [Notes on specific cells](#notes-on-specific-cells)
4. [Self-hosted PostHog — resource requirements](#self-hosted-posthog--resource-requirements)
5. [Which tool for which job — decision table](#which-tool-for-which-job--decision-table)
6. [GA4 — the inescapable default](#ga4--the-inescapable-default)
7. [Privacy and cookie-consent shifts](#privacy-and-cookie-consent-shifts)
8. [Leaderboard — analytics tools at a glance](#leaderboard--analytics-tools-at-a-glance)
9. [Cross-links](#cross-links)

## Web vs product analytics — which to pick

The categories overlap but aren't identical:

| If you want to know… | Use |
|---|---|
| Where my traffic comes from, what's growing/shrinking, which pages perform | Web analytics (GA4, Plausible, Fathom, Matomo) |
| What users do *inside* my product (event funnels, retention, cohorts) | Product analytics (PostHog, Mixpanel, Amplitude) |
| Why users are dropping off (replay, heatmap, frustration signal) | Session replay / heatmap (Clarity, Hotjar, FullStory, PostHog) |
| Which version of a UI converts better | Experimentation (PostHog, GrowthBook, Optimizely, VWO) |
| Are real visitors hitting our Core Web Vitals targets | Real-User Monitoring (Sentry, Datadog, SpeedCurve, Cloudflare Web Analytics) |

For a typical SaaS website + product combo: **Plausible (or GA4) for marketing-site web analytics + PostHog for product analytics + Microsoft Clarity for free replay**. Total cost: ~$9/mo Plausible + free tiers of PostHog/Clarity = ~$108/yr until you exceed the PostHog free tier.

## Platform landscape

| Tool | Position | Pricing |
|---|---|---|
| **[Google Analytics 4 (GA4)](https://analytics.google.com)** | The default; event-based model replacing Universal Analytics (sunset 2023-07-01) | Free up to 10M events/month; GA4 360 enterprise from ~$50k/yr |
| **[Plausible](https://plausible.io)** | Privacy-first, cookieless, EU-based, GDPR-compliant by design | From $9/mo; self-hostable (open-source AGPL) |
| **[Fathom Analytics](https://usefathom.com)** | Privacy-first, simple UI, no cookies | From $15/mo |
| **[Umami](https://umami.is)** | Open-source, self-hostable, privacy-focused | Free self-host; $9/mo cloud |
| **[Matomo (Piwik)](https://matomo.org)** | Open-source GA replacement; full-featured | Free self-host; €19/mo (Matomo Cloud) |
| **[PostHog](https://posthog.com)** | Product analytics + session replay + flags + experiments + surveys | Free tier 1M events/mo; usage-based after. Open-source. See [UX article](../design/ux.md#posthog--instrumentation-that-complements-dogfooding) for deep review. |
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
| **[Cloudflare Web Analytics](https://www.cloudflare.com/web-analytics/)** | Free, server-side (edge), cookieless — bundled with any Cloudflare-proxied domain | Free |
| **[Countly](https://countly.com)** | Open-source product analytics + heatmaps + push notifications; strong mobile focus | Free self-host (Countly Lite / Community); Enterprise from custom |
| **[Snowplow](https://snowplow.io)** | Data-infrastructure CDP: schema-first event pipeline into your warehouse; you own the data end-to-end | Open-source core (AGPL/Apache) is free; managed BDP from ~£1,200/mo |
| **[RudderStack](https://www.rudderstack.com)** | Warehouse-native CDP; open-source Segment alternative | Community Edition free (unlimited events, self-host); Cloud from $29/mo |
| **[Segment (Twilio)](https://segment.com)** | The canonical CDP: source-of-truth identity + destination routing across marketing stack | Free tier (1k MTUs); paid from $120/mo |
| **[GrowthBook](https://www.growthbook.io)** | Open-source A/B testing + feature flags; runs experiments on top of your existing warehouse | Free self-host (MIT); Cloud free tier + paid plans |
| **[Optimizely](https://www.optimizely.com)** | Enterprise experimentation platform; web + feature experimentation + personalisation | Custom (enterprise; typically $50k+/yr) |
| **[VWO](https://vwo.com)** | Digital experience optimisation: A/B testing + heatmaps + surveys + session replay | From $199/mo (Growth); custom enterprise |
| **[LaunchDarkly](https://launchdarkly.com)** | Enterprise feature flags first, experimentation as an adjacent feature | Free tier (limited MAUs); paid from $10/mo/seat |

## Feature comparison matrix — which tool does what

### How to read the matrix

Rows are tools, columns are capabilities. Cells use three states:

- ✅ **First-class** — the tool ships this capability as a headline feature, well-documented, and typically included on the default plan (or in a marketplace plugin for a modest additional fee).
- 🟨 **Present but limited** — the capability exists but is behind an enterprise tier, requires third-party integration, is a paid add-on that noticeably shifts pricing, is limited in scope (e.g. click-tracking only, no full replay), or is beta / semi-official.
- ⬜ **Absent** — the tool does not offer this capability; you'd need a separate tool.

**Do not use the matrix as a global ranking.** A ✅ in every column is neither achievable nor desirable — cookieless tools deliberately omit identity resolution, warehouse-native tools deliberately omit session replay. Read the matrix by scanning the **column** for your must-have capability, then reading down the row of each candidate to check the *other* capabilities it happens to bundle.

Legend for column shorthand:

- **Web** = web analytics (pageviews, sessions, referrers, sources)
- **Product** = product analytics (event funnels, retention, cohorts)
- **Autocap** = autocapture (no manual instrumentation for clicks/events)
- **Replay** = session replay
- **Heat** = heatmaps
- **Scroll** = scrollmaps
- **Funnel** = funnels + conversion analysis
- **Retain** = retention + cohort analysis
- **A/B** = A/B testing / experimentation
- **Flags** = feature flags
- **Survey** = surveys / in-product feedback widgets
- **RUM** = Real-User Monitoring (Core Web Vitals field data)
- **API** = server-side / API-based event ingest
- **DWH** = data-warehouse export (BigQuery / Snowflake / Redshift / S3)
- **Self** = self-hostable (open-source or single-tenant on-prem option)
- **Cookieless** = works without cookies (no consent banner in most EU jurisdictions)
- **EU-res** = EU data residency available on managed cloud tier
- **Identity** = CDP-like cross-device / cross-session identity resolution

### The matrix

| Tool | Web | Product | Autocap | Replay | Heat | Scroll | Funnel | Retain | A/B | Flags | Survey | RUM | API | DWH | Self | Cookieless | EU-res | Identity |
|---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| **GA4** | ✅ | ✅ | ✅ | ⬜ | 🟨 | ⬜ | ✅ | ✅ | 🟨 | ⬜ | ⬜ | ⬜ | ✅ | ✅ | ⬜ | ⬜ | 🟨 | ✅ |
| **Adobe Analytics** | ✅ | ✅ | 🟨 | 🟨 | 🟨 | ⬜ | ✅ | ✅ | 🟨 | ⬜ | ⬜ | ⬜ | ✅ | ✅ | ⬜ | ⬜ | ✅ | ✅ |
| **Plausible** | ✅ | 🟨 | ⬜ | ⬜ | ⬜ | ⬜ | ✅ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ✅ | 🟨 | ✅ | ✅ | ✅ | ⬜ |
| **Fathom** | ✅ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | 🟨 | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ✅ | ⬜ | ⬜ | ✅ | ✅ | ⬜ |
| **Umami** | ✅ | 🟨 | ⬜ | ⬜ | ⬜ | ⬜ | ✅ | 🟨 | ⬜ | ⬜ | ⬜ | ⬜ | ✅ | ⬜ | ✅ | ✅ | ✅ | ⬜ |
| **Matomo** | ✅ | ✅ | 🟨 | 🟨 | 🟨 | 🟨 | ✅ | ✅ | 🟨 | ⬜ | 🟨 | ⬜ | ✅ | 🟨 | ✅ | ✅ | ✅ | ✅ |
| **PostHog** | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ⬜ | ✅ | ✅ | 🟨 | 🟨 | ✅ | ✅ |
| **Mixpanel** | ✅ | ✅ | ✅ | ✅ | ⬜ | ⬜ | ✅ | ✅ | ✅ | ✅ | ⬜ | ⬜ | ✅ | ✅ | ⬜ | 🟨 | ✅ | ✅ |
| **Amplitude** | ✅ | ✅ | 🟨 | ✅ | ⬜ | ⬜ | ✅ | ✅ | ✅ | ✅ | ⬜ | ⬜ | ✅ | ✅ | ⬜ | 🟨 | ✅ | ✅ |
| **Heap** | 🟨 | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | 🟨 | ⬜ | ⬜ | ⬜ | ✅ | ✅ | ⬜ | ⬜ | 🟨 | ✅ |
| **FullStory** | 🟨 | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ⬜ | ⬜ | ⬜ | ⬜ | ✅ | ✅ | ⬜ | ⬜ | ✅ | ✅ |
| **Hotjar** | ⬜ | 🟨 | 🟨 | ✅ | ✅ | ✅ | ✅ | ⬜ | ⬜ | ⬜ | ✅ | ⬜ | ⬜ | 🟨 | ⬜ | ⬜ | ✅ | ⬜ |
| **Microsoft Clarity** | 🟨 | ⬜ | ✅ | ✅ | ✅ | ✅ | 🟨 | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ |
| **Mouseflow** | 🟨 | 🟨 | ✅ | ✅ | ✅ | ✅ | ✅ | ⬜ | ⬜ | ⬜ | ✅ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ✅ | ⬜ |
| **Pirsch** | ✅ | 🟨 | ⬜ | ⬜ | ⬜ | ⬜ | ✅ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ✅ | ⬜ | ⬜ | ✅ | ✅ | ⬜ |
| **GoatCounter** | ✅ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ✅ | 🟨 | ✅ | ✅ | ✅ | ⬜ |
| **Simple Analytics** | ✅ | 🟨 | ⬜ | ⬜ | ⬜ | ⬜ | ✅ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ✅ | ✅ | ⬜ | ✅ | ✅ | ⬜ |
| **Cloudflare Web Analytics** | ✅ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ✅ | ⬜ | ⬜ | ⬜ | ✅ | ⬜ | ⬜ |
| **Countly** | ✅ | ✅ | 🟨 | 🟨 | ✅ | 🟨 | ✅ | ✅ | 🟨 | 🟨 | ✅ | ⬜ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Snowplow** | 🟨 | ✅ | ⬜ | ⬜ | ⬜ | ⬜ | 🟨 | 🟨 | ⬜ | ⬜ | ⬜ | ⬜ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| **RudderStack** | 🟨 | ✅ | ⬜ | ⬜ | ⬜ | ⬜ | 🟨 | 🟨 | ⬜ | ⬜ | ⬜ | ⬜ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Segment (Twilio)** | 🟨 | ✅ | ⬜ | ⬜ | ⬜ | ⬜ | 🟨 | 🟨 | ⬜ | ⬜ | ⬜ | ⬜ | ✅ | ✅ | ⬜ | ⬜ | ✅ | ✅ |
| **GrowthBook** | ⬜ | 🟨 | ⬜ | ⬜ | ⬜ | ⬜ | 🟨 | 🟨 | ✅ | ✅ | ⬜ | ⬜ | ✅ | ✅ | ✅ | ✅ | ✅ | 🟨 |
| **Optimizely** | 🟨 | 🟨 | ⬜ | ⬜ | ⬜ | ⬜ | ✅ | 🟨 | ✅ | ✅ | ⬜ | ⬜ | ✅ | ✅ | ⬜ | ⬜ | ✅ | ✅ |
| **VWO** | 🟨 | 🟨 | 🟨 | ✅ | ✅ | ✅ | ✅ | 🟨 | ✅ | ✅ | ✅ | ⬜ | ✅ | 🟨 | ⬜ | ⬜ | ✅ | 🟨 |
| **LaunchDarkly** | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ✅ | ✅ | ⬜ | ⬜ | ✅ | ✅ | ⬜ | ⬜ | ✅ | ⬜ |

### Notes on specific cells

- **GA4 heatmaps (🟨).** GA4 has no dedicated heatmap UI, but the "clickmap" report reconstructs click-density using autocapture events. It's not a Hotjar substitute.
- **GA4 A/B testing (🟨).** Google Optimize was sunset 2023-09-30. GA4 alone can't run experiments; you're expected to pair it with a separate tool or use Google's Firebase A/B Testing for mobile.
- **GA4 EU residency (🟨).** GA4 lets you choose region for the collection endpoint (via `region` config), but the underlying storage still touches US infrastructure — several EU DPAs (French CNIL, Austrian DSB, Italian Garante) have ruled GA4 non-compliant absent additional safeguards. The EU-US Data Privacy Framework restored a legal basis in 2023 but the posture is fragile.
- **Matomo replay / heatmaps / A/B (🟨).** Available as paid plugins: heatmaps €199/yr, session recording €149/yr, A/B testing €249/yr. Core Matomo is free-forever self-hosted; these are add-ons.
- **PostHog self-host (🟨).** Self-hostable, but resource-intensive. See the [Self-hosted PostHog resource requirements](#self-hosted-posthog--resource-requirements) section directly below. New paid open-source Kubernetes deployments are no longer supported by PostHog.
- **PostHog cookieless (🟨).** Can be configured cookieless (`persistence: 'memory'`), but the default install uses cookies. Cookieless mode disables cross-session identity, which defeats most of PostHog's product-analytics value.
- **Amplitude autocapture (🟨).** Amplitude's "autocapture" is opt-in per element / event class, not the Heap-style capture-everything default.
- **Heap web analytics (🟨).** Heap can serve marketing-site analytics but the UX is product-analytics-oriented (events, not pageview reports). You lose GA4-style acquisition dashboards.
- **Hotjar autocapture (🟨).** Captures clicks and mouse movement for replay/heatmap; does not create a queryable event stream like Heap or PostHog.
- **Clarity funnels (🟨).** Recent addition (2024); basic vs. Hotjar/Mouseflow. No cohorting.
- **Cloudflare RUM (✅).** Cloudflare Web Analytics uniquely surfaces Core Web Vitals field data (LCP, FID/INP, CLS) from real visitors at no cost because it runs at the edge.
- **Snowplow / RudderStack / Segment funnel & retention (🟨).** These are pipelines, not analysis UIs. You get the *raw events* in your warehouse; funnel/retention is whatever your BI tool (Looker, Metabase, Hex) draws on top. Score reflects "the data is there" not "the UI is there."
- **Segment self-host (⬜).** Segment (Twilio) is closed cloud-only. RudderStack (open-source Segment alternative) is the self-hostable option in this slot.
- **GrowthBook web/product (🟨).** GrowthBook is experimentation-first; it queries *your* analytics data (from your warehouse or PostHog/Mixpanel/GA4) rather than collecting its own. Score reflects "reads analytics" not "is analytics."
- **VWO warehouse export (🟨).** Data export available on higher tiers; not a first-class feature.
- **LaunchDarkly.** Feature-flags-first. Experiments were added in 2022 (LaunchDarkly Experimentation) but the flagship value is flag management. Almost every other analytics column is out-of-scope.

## Self-hosted PostHog — resource requirements

> [!CAUTION]
> **Self-hosted PostHog is resource-hungry.** The open-source self-host is not a $10-VPS hobby project. Community-reported minimums:
>
> - **Idle stub install:** ~2 GB RAM used at rest with no traffic. PostHog's hobby Docker-Compose stack runs **7+ services** (ClickHouse, Postgres, Redis, Kafka, Zookeeper or KRaft, MinIO, PostHog web + workers).
> - **PostHog's own docs recommend:** Linux VM at **4 vCPU / 16 GB RAM / 30+ GB SSD** as the *starting* configuration for Docker-Compose self-host.
> - **Practical thresholds reported by users:** 4 GB RAM boots the stack but has almost no headroom under real event volume; **8 GB is the practical minimum**; **16 GB+** for anything past a POC. Storage grows fast because ClickHouse retains raw events.
> - **Kubernetes:** PostHog **no longer supports new paid Kubernetes deployments** of the open-source product (announced in the self-host docs). If you already run K8s, you're on your own for upgrades.
>
> **Why so hungry?** The stack replaces Mixpanel + Amplitude + FullStory + LaunchDarkly + a surveys tool + a CDP simultaneously. That capability set requires ClickHouse (columnar event store), Kafka (event ingest), Postgres (metadata), Redis (cache), MinIO (blob storage for replays). Each service has independent resource ceilings and independent upgrade paths.
>
> **Practical guidance:**
> - **PostHog Cloud free tier is generous** (1M events + 5k session recordings + 1M flag requests + 1.5k survey responses per month). Unless you have a compliance mandate that forbids US-based SaaS (Cloud is available in both US and EU regions), **Cloud is the recommended path**.
> - **Self-host only if:** (a) EU/regulated data residency or on-prem-only compliance forces it, **and** (b) you have dedicated ops capacity (real SRE time, not "we'll figure it out"). Otherwise the ops burden dominates the value.
> - **Do not confuse "open source" with "cheap".** The licence is free; the RAM is not.
>
> Sources: [PostHog self-host docs](https://posthog.com/docs/self-host), [PostHog developing-locally handbook](https://posthog.com/handbook/engineering/developing-locally), and community deep-dives (e.g. [Cotera's honest self-host review](https://cotera.co/articles/posthog-self-hosted-guide)).

## Which tool for which job — decision table

Pick by the *job you have*, not by the tool with the most ✅ marks in the matrix.

| Job to be done | Recommended tool(s) | Why |
|---|---|---|
| I want privacy-friendly web analytics on a marketing site, no consent banner, minimal setup | **Plausible** (€9/mo) or **Fathom** ($15/mo) | Cookieless by design, EU-hosted, GDPR-safe without a CMP. Simple pageview + referrer reporting. |
| I want the free tier and I can accept less polish | **Umami** (self-host free) or **GoatCounter** (free <100k pageviews/mo) or **Cloudflare Web Analytics** (free if already on Cloudflare) | Zero-cost cookieless. Cloudflare is easiest if you already proxy through it. |
| I want product analytics on a $0 budget | **PostHog Cloud** (1M events/mo free) or **Mixpanel** (1M events/mo free) | Both offer generous product-analytics free tiers. PostHog bundles replay + flags + surveys; Mixpanel has cleaner cohort UX. |
| I want everything in one tool (product analytics + replay + flags + experiments + surveys) | **PostHog Cloud** | Only tool that ships all five under one roof at a startup-friendly price point. Do **not** self-host lightly — see the [resource-requirements callout](#self-hosted-posthog--resource-requirements). |
| I need enterprise product analytics with deep analyst tooling | **Amplitude** or **Mixpanel** | Amplitude for the deepest analyst UX and predictive analytics; Mixpanel for a friendlier learning curve. |
| I want session replay + heatmaps and nothing else | **Microsoft Clarity** (free, unlimited) or **Hotjar** (paid, more polish) | Clarity is genuinely free at any volume; Hotjar is worth the money only if you specifically need its user-interview feature. |
| I want feature flags + analytics in one tool | **PostHog** or **GrowthBook** | PostHog bundles both first-class. GrowthBook is stronger for warehouse-native teams that want experimentation on data they already have. |
| I want enterprise-grade feature flags with the analytics attached | **LaunchDarkly** + separate analytics | LaunchDarkly is the flag-management gold standard but treats experimentation as an adjacent feature; pair with GA4/Amplitude/Mixpanel for the analytics side. |
| I must self-host for compliance (health, gov, finance, EU-only) | **Matomo** (web) + **PostHog** self-host (product) or **Countly** | Matomo is the mature GPL-3 web-analytics option with EU support. PostHog self-host is doable **only with real ops capacity** (see callout). Countly bundles product + heatmaps in one open-source install. |
| I want the raw events in my own warehouse and I'll build the analysis myself | **Snowplow** (schema-first, opinionated) or **RudderStack** (Segment-shape, permissive) | Both self-hostable, both stream typed events into BigQuery/Snowflake/Redshift. Snowplow validates at ingestion; RudderStack is faster to instrument but more permissive. |
| I want the CDP layer (identity + routing to marketing tools) and I'm OK paying | **Segment (Twilio)** | The canonical CDP. Highest integration count. Self-host alternative: RudderStack. |
| I want A/B testing that isn't tied to my analytics tool | **GrowthBook** (self-host free) or **Optimizely** (enterprise) or **VWO** (mid-market) | GrowthBook is the open-source pick and reads from your existing warehouse or analytics tool. Optimizely/VWO if you want a full DXP-style visual editor. |
| I want to know if real users hit my Core Web Vitals targets (RUM) | **Cloudflare Web Analytics** (free, if proxied) or **Sentry Performance** or **SpeedCurve** | GA4 doesn't do RUM. Cloudflare has it free at the edge. Sentry/SpeedCurve for deeper performance-observability integration. See [UX article](../design/ux.md) cross-links. |
| I want GA4 replacement without the GA4 UI complaints | **Matomo** (feature-parity, self-host or cloud) or **Plausible** + **PostHog** combo | Matomo is the closest 1:1 feature swap. Plausible + PostHog is the modern "web + product, one each" split. |

## GA4 — the inescapable default

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

## Privacy and cookie-consent shifts

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

## Leaderboard — analytics tools at a glance

Five-dimension scoring across the tools reviewed here. The dimensions:

- **Authority** — depth of underlying data / institutional credibility / industry adoption. 🟩🟩 = category-defining; 🟩 = strong contender; 🟨 = useful niche; 🟥 = thin.
- **Accessibility** — how easy is it to actually use as a non-expert? 🟩🟩 = signup-to-insight in minutes; 🟩 = readable but takes time; 🟨 = steep curve; 🟥 = enterprise-only.
- **Depth** — how far down does the rabbit hole go? 🟩🟩 = full-platform, weeks-of-learning; 🟩 = solid coverage; 🟨 = single-purpose treatment; 🟥 = surface only.
- **Currency** — is it actively maintained, feature-current? 🟩🟩 = updated monthly; 🟩 = quarterly; 🟥 = stale.
- **Cost** — 🟩🟩 = entirely free; 🟩 = free tier covers most use; 🟨 = affordable paid ($15-$100/mo); 🟥 = expensive ($100+/mo or enterprise).

| Tool | Authority | Accessibility | Depth | Currency | Cost | Verdict |
|---|:---:|:---:|:---:|:---:|:---:|---|
| **[GA4](#ga4--the-inescapable-default)** | 🟩🟩 | 🟨 | 🟩🟩 | 🟩🟩 | 🟩🟩 | The default. Imperfect, free, integrates with everything Google. |
| **[Plausible](#platform-landscape)** | 🟩 | 🟩🟩 | 🟩 | 🟩🟩 | 🟨 | Cookieless, privacy-friendly, no consent banner. Self-hostable. |
| **[Fathom](#platform-landscape)** | 🟩 | 🟩🟩 | 🟩 | 🟩🟩 | 🟨 | Plausible's closest competitor; cleaner UI; closed-source. |
| **[Matomo](#platform-landscape)** | 🟩 | 🟨 | 🟩🟩 | 🟩🟩 | 🟩 | Most feature-complete open-source GA replacement. |
| **[Umami](#platform-landscape)** | 🟩 | 🟩🟩 | 🟩 | 🟩🟩 | 🟩🟩 | Open-source, lightweight, self-host free. |
| **[PostHog](#platform-landscape)** | 🟩 | 🟩 | 🟩🟩 | 🟩🟩 | 🟩 | Product analytics + replay + flags. Open-source. Deep review in [UX article](../design/ux.md#posthog--instrumentation-that-complements-dogfooding). |
| **[Mixpanel](#platform-landscape)** | 🟩🟩 | 🟩 | 🟩🟩 | 🟩🟩 | 🟩 | Closed-source; stronger BI / cohort UX than GA4. |
| **[Amplitude](#platform-landscape)** | 🟩🟩 | 🟨 | 🟩🟩 | 🟩🟩 | 🟥 | Enterprise product analytics; deepest analyst tooling. |
| **[Microsoft Clarity](#platform-landscape)** | 🟩 | 🟩🟩 | 🟩 | 🟩🟩 | 🟩🟩 | Free unlimited replay + heatmap. Real Hotjar alternative. |
| **[Hotjar](#platform-landscape)** | 🟩🟩 | 🟩🟩 | 🟩 | 🟩🟩 | 🟨 | Heatmaps + replay + surveys. Clarity is the free alternative. |
| **[FullStory](#platform-landscape)** | 🟩 | 🟩 | 🟩🟩 | 🟩🟩 | 🟥 | Replay + frustration signals; enterprise. |
| **[Cloudflare Web Analytics](#platform-landscape)** | 🟩 | 🟩🟩 | 🟨 | 🟩🟩 | 🟩🟩 | Free + RUM at the edge if you already proxy through Cloudflare. Cookieless. |
| **[Countly](#platform-landscape)** | 🟨 | 🟩 | 🟩🟩 | 🟩 | 🟩 | Open-source product analytics + heatmaps + mobile focus. Solid self-host. |
| **[Snowplow](#platform-landscape)** | 🟩🟩 | 🟨 | 🟩🟩 | 🟩🟩 | 🟨 | Schema-first CDI; you own the pipeline end-to-end. Warehouse-native. |
| **[RudderStack](#platform-landscape)** | 🟩 | 🟩 | 🟩🟩 | 🟩🟩 | 🟩 | Open-source Segment alternative. Faster to instrument than Snowplow. |
| **[Segment (Twilio)](#platform-landscape)** | 🟩🟩 | 🟩 | 🟩🟩 | 🟩🟩 | 🟥 | Canonical CDP. Highest integration count; expensive at scale. |
| **[GrowthBook](#platform-landscape)** | 🟩 | 🟩 | 🟩 | 🟩🟩 | 🟩🟩 | Open-source A/B + flags on your warehouse. Best free experimentation. |
| **[Optimizely](#platform-landscape)** | 🟩🟩 | 🟨 | 🟩🟩 | 🟩🟩 | 🟥 | Enterprise-only experimentation platform; visual editor. |
| **[VWO](#platform-landscape)** | 🟩 | 🟩 | 🟩🟩 | 🟩🟩 | 🟥 | Experimentation + heatmap + replay bundled. Mid-market pricing. |
| **[LaunchDarkly](#platform-landscape)** | 🟩🟩 | 🟩 | 🟩🟩 | 🟩🟩 | 🟥 | Flags-first gold standard; per-seat pricing scales fast. |

## Cross-links

- **[SEO](seo.md)** — the acquisition side. Analytics without SEO measures a leaky top of funnel.
- **[UX resources & tools](../design/ux.md)** — the conversion-side of acquisition. PostHog is reviewed in depth there.
- **[BDD with Gherkin](../practices/bdd-with-gherkin.md)** — encoding marketer/PM expectations about user flows as executable specs.
- **[Recent incidents in major technologies](../industry-watch/recent-incidents.md)** — analytics tools handle PII; supply-chain and privacy incidents directly affect tool choice.

---

**Snapshot 2026-07-02.** Submit issues for missing tools, repo updates, or corrections.
