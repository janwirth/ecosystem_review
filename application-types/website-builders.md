# Website builders — cross-ecosystem survey

> [!NOTE]
> **Status:** DRAFT · **Authoring:** AI-assisted, human-reviewed.

> *You have decided the artifact is a [website](README.md#website). This article is about the second decision: whether a hosted builder ships it, and if so, which one — and what it will actually cost you over three years.*

**Snapshot 2026-07-27** — every price, cap and limitation below was checked against vendor pricing pages, help centres and changelogs on this date. **Pricing in this category moves monthly and is frequently not machine-readable** (see [A warning about the prices in this article](#a-warning-about-the-prices-in-this-article)). Treat exact numbers as a point-in-time reading and verify at checkout before committing money.

~60 platforms reviewed across six families, plus two adjacent categories reviewed only to draw a boundary.

## Table of Contents

1. [Why this article](#why-this-article)
2. [A warning about the prices in this article](#a-warning-about-the-prices-in-this-article)
3. [The six families at a glance](#the-six-families-at-a-glance)
4. [Pricing models — the taxonomy that actually predicts your bill](#pricing-models--the-taxonomy-that-actually-predicts-your-bill)
   - [The annual-vs-monthly trap](#the-annual-vs-monthly-trap)
   - [Intro-then-renewal — the hosting-native pattern](#intro-then-renewal--the-hosting-native-pattern)
   - [Two-axis pricing — site plans × seats](#two-axis-pricing--site-plans--seats)
   - [Credit metering — the AI-builder pattern](#credit-metering--the-ai-builder-pattern)
   - [Transaction fees — the second price list](#transaction-fees--the-second-price-list)
   - [Caps that bite in production](#caps-that-bite-in-production)
5. [Family 1 — mainstream all-in-one builders](#family-1--mainstream-all-in-one-builders)
6. [Family 2 — designer-first / visual-development builders](#family-2--designer-first--visual-development-builders)
7. [Family 3 — portfolio &amp; creative-niche builders](#family-3--portfolio--creative-niche-builders)
8. [Family 4 — WordPress and the open-source / self-hostable corner](#family-4--wordpress-and-the-open-source--self-hostable-corner)
9. [Family 5 — AI-first / prompt-to-site builders](#family-5--ai-first--prompt-to-site-builders)
10. [Family 6 — Notion-as-CMS renderers](#family-6--notion-as-cms-renderers)
11. [Adjacent categories — what these are not](#adjacent-categories--what-these-are-not)
12. [Capability comparison matrices](#capability-comparison-matrices)
13. [Lock-in and exit — what "you own your site" actually means](#lock-in-and-exit--what-you-own-your-site-actually-means)
14. [SEO capability by construction](#seo-capability-by-construction)
15. [Accessibility and the European Accessibility Act](#accessibility-and-the-european-accessibility-act)
16. [GDPR, data residency and cookie consent](#gdpr-data-residency-and-cookie-consent)
17. [Performance — Core Web Vitals by platform](#performance--core-web-vitals-by-platform)
18. [Market shape, consolidation and platform risk](#market-shape-consolidation-and-platform-risk)
19. [When NOT to use a website builder](#when-not-to-use-a-website-builder)
20. [Which builder for which job — decision table](#which-builder-for-which-job--decision-table)
21. [Discovery &amp; method](#discovery--method)
22. [Cross-links](#cross-links)

## Why this article

[Application types](README.md) answers *what kind of artifact ships*. If the answer was "a website", the framework table in that article lists Hugo, Astro, Eleventy, Jekyll — code-based static site generators, aimed at people who will write and deploy code.

That table is not the whole answer, because most websites in the world are not built that way. **WordPress alone runs 41.2% of all websites**, and Wix, Squarespace, Shopify and Duda add another ~13% between them ([W3Techs, surveyed 2026-07-27](https://w3techs.com/technologies/overview/content_management)). The dominant way a website gets made is not `npm create astro` — it's a hosted builder with a visual editor and a monthly bill.

This article reviews that landscape, on three questions the marketing pages will not answer:

1. **What does it actually cost?** Not the headline number — the number after annual-vs-monthly, after seats, after the renewal jump, after the transaction fee, after the add-on that turned out to be mandatory.
2. **What can't it do?** Every builder has a structural ceiling. Most of them are invisible until you hit them at month eight.
3. **Can you leave?** The single question with the widest variance in the category, and the one nobody asks before signing up.

The audience is the person choosing — a founder, a marketer, a CTO deciding whether the marketing site is worth an engineer's time, or an agency picking a platform to stand behind for a client for five years.

> [!IMPORTANT]
> **The categories in this article are not substitutable, and there is no global leaderboard.** Framer and WordPress and Lovable are not competing for the same job. A ranking that puts them in one column would be nonsense. What this article gives you instead is a [family taxonomy](#the-six-families-at-a-glance), [per-capability matrices](#capability-comparison-matrices) within each family, and a [decision table keyed by job](#which-builder-for-which-job--decision-table). Pick the family from the job, then pick within the family.

## A warning about the prices in this article

Vendor pricing pages in this category are increasingly client-rendered, geo-varying, and account-state-dependent. At snapshot date:

- **Wix, Squarespace, Jimdo, Square and Site123** served page structure — feature matrices, transaction-fee percentages, AI-credit counts — with **the dollar figures absent** from the fetched HTML.
- **GoDaddy** returned HTTP 403 to every automated request, including its generic `/pricing` page.
- **Wix instructs prospective Studio customers to view pricing in an incognito window** — an explicit admission that price presentation depends on your account state.
- **Site123 does not publish a tier table at all**; three independent review sites report prices spanning **$8.28 to $60** for nominally the same tier.
- Several fetches geolocated to Europe and returned **EUR**, not USD.

Consequences for how to read what follows:

| Marking | Meaning |
|---|---|
| *(no marking)* | Verified against the vendor's own pricing page, help centre, changelog or press release at snapshot date. |
| **⬜** | Not knowable at snapshot date. The reason is stated. |
| *secondary* | From a review site, agency blog or aggregator, not the vendor. Cross-checked where possible; flagged where sources disagree. |
| *community-reported* | From forums, Reddit, or user write-ups. Directional signal, not fact. |

**Verify every price at the vendor's checkout flow before committing money.** This is not boilerplate hedging — it is the single most reliable finding of this review.

## The six families at a glance

| Family | What it is | Representative tools | Typical monthly cost | Can you export? |
|---|---|---|---|---|
| [**Mainstream all-in-one**](#family-1--mainstream-all-in-one-builders) | One vendor for editor + hosting + domain + store + email. Non-technical audience. | Wix, Squarespace, Duda, GoDaddy, Hostinger, IONOS, Jimdo, Site123, Square Online, Google Sites | $10–$50 | Almost never (Duda is the exception, at $52/mo) |
| [**Designer-first**](#family-2--designer-first--visual-development-builders) | Professional visual development. Real CSS control, CMS, staging. Agency/designer audience. | Webflow, Framer, Webstudio, Dorik | $15–$150+ | Webflow partially, Webstudio fully, Framer never |
| [**Portfolio &amp; creative-niche**](#family-3--portfolio--creative-niche-builders) | Image-first publishing for photographers, artists, studios. | Readymag, Cargo, Format, Pixpa, Adobe Portfolio, Semplice, Carrd, Universe | $0–$60 | Rarely; Readymag and Pixpa partially |
| [**WordPress &amp; open-source**](#family-4--wordpress-and-the-open-source--self-hostable-corner) | You own the stack. Visual builders layered on a CMS you host. | WordPress + Elementor/Bricks/Divi, Ghost, Webstudio, Payload, Craft, Statamic | $6–$50 all-in | Yes — it's your filesystem |
| [**AI-first / prompt-to-site**](#family-5--ai-first--prompt-to-site-builders) | Describe the site; the model writes it. Credit-metered. | Lovable, Bolt.new, v0, Replit, Base44, Hostinger Horizons, Durable, 10Web | $0–$200+, non-deterministic | Developer-targeted ones yes; SMB-targeted ones no |
| [**Notion-as-CMS**](#family-6--notion-as-cms-renderers) | Notion is the editor; the tool is a renderer + domain host. | Super, Potion, Popsy | $10–$28 per site | Moot — content never left Notion |

Two adjacent categories are covered only to [draw the boundary](#adjacent-categories--what-these-are-not): **ecommerce platforms** (Shopify, BigCommerce, Ecwid, Square Online, WooCommerce) and **no-code app builders** (Bubble, Softr, Glide, Airtable Interfaces, Retool). People evaluate both against website builders and shouldn't.

## Pricing models — the taxonomy that actually predicts your bill

Six models. Each produces a characteristic way of surprising the buyer. Identify the model first; the specific numbers follow from it.

| Model | Who uses it | The failure mode |
|---|---|---|
| **Flat per-site subscription** | Squarespace, Wix, Cargo, Site123 | Cheapest to reason about. Fails by *tier-jump*: the one feature you need (0% transaction fee, unlimited storage, custom CSS) sits two tiers up. |
| **Two-axis: site plan × seats** | Webflow, Framer, Super, Duda | The advertised price is the *site* price only. A 3-person Webflow team pays ~$152/mo against a $15/mo headline. |
| **Credit / token metering** | Lovable, Bolt, v0, Replit, Base44, Framer AI, Webflow AI, Squarespace AI | Cost is **non-deterministic**. You cannot price a prompt before sending it, and you pay for the model's failures. |
| **Intro-then-renewal** | Hostinger, GoDaddy, IONOS | Advertised price is a first-term number, often on a 48-month prepay. Renewal is 2×–20×. |
| **Transaction fees** | Shopify, Squarespace, Webflow Ecommerce, Universe, Typedream | Levied on **gross revenue**, so it scales past any subscription saving. |
| **Metered overage on a flat plan** | Webflow, Framer, Webstudio, Readymag | The plan is a floor, not a ceiling. Behaviour at the cap varies from a bill to a forced upgrade to the site going offline. |

### The annual-vs-monthly trap

Near-universal: **the headline number is the annual-prepay price expressed per month.** Verified deltas at snapshot date:

| Tool | Advertised (annual, /mo) | Actual monthly-billed | Delta |
|---|---:|---:|---:|
| Webflow Basic | $15 | **$25** | +67% |
| Webflow Premium | $25 | **$39** | +56% |
| Shopify Basic | $29 | **$39** | +34% |
| Shopify Grow | $79 | **$105** | +33% |
| Shopify Advanced | $299 | **$399** | +33% |
| Duda Basic | $19 | **$25** | +32% |
| Duda Agency | $52 | **$69** | +33% |
| Format Pro Plus | $15 | **$36** | **+140%** |
| Dorik Personal (2-yr rate) | $10.38 | **$29** | **+179%** |
| Pixpa Basic (2-yr rate) | $4.05 | **$9** | **+122%** |
| GoDaddy Basic | $9.99 | **$21.99** *(secondary)* | +120% |
| Wix Light | $17 *(secondary)* | **$24** *(secondary)* | +41% |
| Squarespace Core (post-July-2026) | $29 | **$39** | +34% |

> [!WARNING]
> **Squarespace only shows the annual figure on its pricing page; Wix's page footnote reads "Displayed prices are for yearly subscriptions, paid in full at the time of purchase."** Neither publishes both rate cards side by side. Framer publishes monthly rates but not the discounted annual rate. **Assume the number you are shown is not the number you will pay unless you prepay a year.**

The compounding version is multi-year prepay: Hostinger's "$2.99/mo" is **$143.52 charged at once** for 48 months. Pixpa's "$4.05/mo" requires a 24-month prepay ($97.20 upfront). Dorik's "$10.38/mo" likewise. Site123 bills the **entire term upfront** with a 14-day non-refundable cliff and offers no monthly option at all.

### Intro-then-renewal — the hosting-native pattern

This pattern is confined almost entirely to **builders owned by hosting companies**, where the builder is sold through the hosting price book and inherits its promo mechanics.

| Vendor / plan | First term | Renewal | Multiple | Renewal disclosed on the page? |
|---|---:|---:|---:|:--|
| Hostinger Premium Builder | $2.99/mo (48 mo, $143.52 upfront) | **$10.99/mo** | **3.7×** | ✅ Yes |
| Hostinger Business Builder | $3.79/mo (48 mo, $181.92 upfront) | **$16.99/mo** | **4.5×** | ✅ Yes |
| IONOS Starter | $6/mo | **$14/mo** | 2.3× | ✅ Yes |
| IONOS **Plus** | **$1/mo** | **$20/mo** | **20×** | ✅ Yes |
| IONOS Pro | $17/mo | ⬜ not shown | — | ❌ |
| GoDaddy Basic | $9.99/mo | $16.99/mo *(secondary)* | 1.7× | ❌ No renewal rate anywhere on the page |
| GoDaddy Premium | $14.99/mo | $29.99/mo *(secondary)* | 2.0× | ❌ |
| GoDaddy Commerce | $20.99/mo | $34.99/mo *(secondary)* | 1.7× | ❌ |
| Shopify (promo) | $1/mo for 3 months | $39/mo monthly-billed | 39× off promo | ✅ Yes |

**IONOS deserves credit as the only vendor in this review that prints intro, regular and renewal price in the same table.** Hostinger prints the renewal. GoDaddy prints neither, on any page, including its generic `/pricing`.

> [!CAUTION]
> **IONOS Plus at $1/mo renewing at $20/mo is a 20× step** — the largest in the category. It is also paired with a **12-month contract with auto-rollover**; community reports describe cancellation windows that require phone or written confirmation, with a missed window silently rolling the contract forward *(community-reported)*. Separately, IONOS is running a **2026 price adjustment on existing contracts**, confirmed on its own help site, notified by email with a PDF attachment, **with no figures published publicly**.

### Two-axis pricing — site plans × seats

The single most misunderstood pricing model in the category, and the norm at the professional end.

**Webflow** bills on two independent axes that must both be paid:

- **Site plans** (per published site): Starter free · Basic **$15/mo** annual, $25 monthly · Premium **$25/mo** annual, $39 monthly · Team **$2,500/mo** annual-only *(secondary — Webflow's page says "contact sales")* · Enterprise custom.
- **Workspace plans** (per organisation): Starter free · Core **$19/mo** · Growth **$49/mo** · Enterprise custom.
- **Seats** (per person): Full **$39/mo** · Limited **$15/mo** · Reviewer $0.
- **Ecommerce**, layered on top: Standard $29/mo (2% fee) · Plus $74/mo (0%) · Advanced $212/mo (0%).
- **Add-ons**: Localize $9 or $29/mo **per locale** · Analyze from $9/mo · Optimize from $299/mo · AI credits $20/mo per 2,000.

| Scenario | Real monthly cost |
|---|---:|
| One person, one custom-domain marketing site, no CMS | $15 site + $19 workspace = **$34** |
| One person, one CMS site | $25 + $19 = **$44** |
| Three-person team, one CMS site | $25 site + $49 workspace + 2 × $39 seats = **$152** |
| Agency, 10 client CMS sites, 4 designers | 10 × $25 + $49 + 3 × $39 = **$416** |

**Framer** does the same with different weights: site plans Free / Basic **$10/mo** / Pro **$30/mo**, plus **$20/mo per additional editor**, **$10/mo per content editor**, **$20 per translation locale**, **$50 per 500,000 A/B-test events**, $200/mo advanced hosting. A 3-designer Pro site is $30 + 2×$20 = **$70/mo**. Framer's site plans are **per site** — a second site is a second subscription.

> [!TIP]
> **Which axis hurts depends on which side of the agency line you are on.** A freelancer with 10 client sites multiplies the *site* axis and barely touches seats — Webflow costs them $250+/mo in site plans. A 6-person in-house team with one site multiplies the *seat* axis. Tools that bill per *account* rather than per *site* — **Webstudio ($15/mo unlimited sites)**, **Cargo ($14/mo unlimited subdomain sites)**, **Carrd ($19/yr for 10 sites)**, **Dorik**, **Adobe Portfolio** — are one to two orders of magnitude cheaper for multi-site operators. Ten sites costs roughly: Webstudio **$15/mo** · Cargo **$32/mo** · Carrd **$19/yr** · Webflow **$250+/mo** · Super or Typedream **$120–280/mo**.

### Credit metering — the AI-builder pattern

Four distinct sub-models hide under the word "credits". Do not conflate them.

| Sub-model | Who | What you're buying |
|---|---|---|
| **Dollar-denominated token metering** | v0 | LLM tokens at a published per-million rate (v0 Mini $1 in / $5 out; v0 Max Fast **$10 in / $50 out** per 1M tokens). Transparent, unbounded. |
| **Abstract credits, variable cost per message** | Lovable, Framer, Base44, Squarespace, Webflow, 10Web, Hostinger Horizons | You cannot price a prompt before sending it. Lovable documents 0.50–2.00 credits per message depending on task. |
| **Raw token budgets** | Bolt.new | 1M free / 10M Pro / up to 1,200M at $2,000/mo. Legible unit — but Bolt re-syncs the whole codebase per interaction, so cost scales with *project size*, not request size. |
| **No AI metering at all** | Wix Harmony *(secondary)*, mainstream builders | AI folded into a feature-and-storage plan. This is the mainstream builders' structural advantage and they will market it hard. |

**Expiry and rollover rules are inconsistent and all favour the vendor:**

- **Bolt** — paid allocations valid **2 months**, consumed FIFO, **all forfeited on cancellation**.
- **Lovable** — monthly credits roll over but **expire 2 months after issue**; annual-plan credits expire 1 month after the annual period ends; daily grants expire same-day; Cloud/AI grants never roll over.
- **Framer** — credits **reset on the 1st of the calendar month regardless of your billing date**, no carry-over, and purchased top-ups **die at month end**.
- **Base44** — no stacking at all; credits "refresh each billing cycle rather than stacking up."
- **v0** — ⬜ rollover policy not published.

**Top-up pricing is punitive versus plan pricing.** Lovable's plan rate is $0.25/credit; the Pro top-up is $0.30 and the **Business top-up is $0.60 — 2× the Pro rate for an identical credit**. Top-up rates also change without announcement: community guides still quote a Lovable rate ($10/20 credits) that the current docs contradict.

> [!CAUTION]
> **You are billed for the model's failures.** This is the most-cited grievance across every credit-metered tool and it is structurally unavoidable — error loops, hallucinated APIs and self-inflicted rewrites all consume the meter. Replit users report *"spending $1.15 for the Agent to suggest a method that doesn't exist"*; Bolt reviewers estimate **up to half their tokens went to errors**; Lovable's most common complaint is repetitive error loops *(all community-reported)*. **Neither Bolt nor Replit documents whether failed generations are refundable. They are not.** The customer bears the model's error rate.

Two pricing-model changes are the cautionary tales:

- **Replit, mid-2025** — flat $0.25/checkpoint replaced by "effort-based pricing", effective immediately for new users and rolling to existing subscribers from 2025-07-01. Bills spiked unpredictably; one user reported *"$1K in the last week alone… whereas before it was never more than $180-200 a month for the same effort"* *(community-reported via [The Register](https://www.theregister.com/software/2025/09/18/replit-infuriating-customers-with-surprise-cost-overruns/1006671))*. A July 11 billing glitch hit ~6% of users. Replit publicly conceded *"our launch fell short of standards."* A further CEO apology followed in December 2025, and plans were restructured again in February 2026.
- **v0, 2025-05-13** — fixed message counts replaced by token-metered credits, **auto-migrating all existing users at their next billing cycle**. At snapshot date the $20 Premium tier has disappeared from the live pricing page, leaving **no individual paid plan between Free and $30/user Plus**.

### Transaction fees — the second price list

For anyone selling, the fee schedule frequently dominates the subscription and **inverts the apparent price ranking**.

| Platform | Physical goods | Digital / memberships | Note |
|---|---:|---:|---|
| Squarespace Basic | **2%** | **7%** | Plus 2.9% + $0.30 card processing. |
| Squarespace Core | 0% | **5%** | |
| Squarespace Plus | 0% | **1%** | Card rate improves to 2.7% + $0.30. |
| Squarespace Advanced | 0% | 0% | Card rate 2.5% + $0.30. |
| Shopify Basic / Grow / Advanced / Plus | **2% / 1% / 0.6% / 0.2%** | same | Only when **not** using Shopify Payments; stacks on top of your processor's rate. |
| Webflow Ecommerce Standard | **2%** | — | 0% on Plus/Advanced. |
| Universe Pro / Creator / Enterprise | **5% / 2% / 0%** | same | 0% only at $50/mo. |
| Typedream Free / paid | **5% / 2%** | same | **Never reaches 0%**, even at $42/mo. |
| Square Online free plan | — | — | **Online card rate raised from 2.9% + $0.30 to 3.3% + $0.30 on 2026-01-13.** |
| Wix (Business+), Hostinger, Pixpa, Cargo, Ghost, Format | **0%** | 0% | Processor fees still apply. |

> [!CAUTION]
> **Squarespace Basic's 7% digital-goods fee is the sharpest trap in the mainstream market.** A $10,000/month course business on Basic pays **$700/month in platform fees** to save $10/month on plan versus Core — and roughly 10% all-in once card processing is added. If you sell digital products or memberships, the fee schedule, not the plan price, is the decision.

### Caps that bite in production

Behaviour at the cap splits four ways, and **nobody advertises which one they do**.

| Behaviour | Who | What happens |
|---|---|---|
| **Grace, then forced upgrade, non-refundable** | **Webflow** | Month 1 over bandwidth: notification, no charge. Month 2 consecutive: *"automatically upgraded at the start of your next billing month… and you'll be charged an additional fee."* And explicitly: **"We are unable to issue refunds for bandwidth overages."** |
| **Transparent metered overage** | **Framer**, **Webstudio** | Framer publishes unit prices: **$20 per 100 extra pages** (max 700), **$40 per 10 CMS collections** (max 40), **$20 per 10,000 CMS items** (max 40,000), **$40 per 100 GB bandwidth** (max 2 TB). Webstudio: **$20 per additional 100,000 pageviews**, with capped overage protection — the only genuinely benign model in the review. |
| **Grace, then cliff** | **Framer** (bandwidth) | No overage billing exists for bandwidth. Community reports say a site that blows its cap **goes offline** until the cycle resets or you upgrade *(community-reported; not Framer's own wording)*. |
| **Tier-forcing, no overage billing** | **Wix**, **Squarespace**, **Jimdo**, **Readymag**, **Site123** | You simply cannot exceed. Upgrade or stop. |

Specific caps worth knowing before you commit:

- **Webflow**: 20,000 CMS items on Premium (raised from 2,000–10,000 in May 2026), 40 collections, 300 static pages, 50 GB bandwidth. Community reports say the item cap **does not lift even on Enterprise**, and that the Designer degrades well before it — lag at 5,000+ items, 15–30 minute publish times at 10,000+ *(community-reported)*.
- **Framer**: note the anti-pattern — **Basic has 2 CMS collections; Free has 10.** Downgrading from a trial can break a site.
- **Wix**: storage is the binding cap and it is steep — **500 MB free / 2 GB Light / 50 GB Core / 100 GB Business / unlimited Elite**. 2 GB is a few hundred unoptimised photos.
- **Squarespace**: video storage — 30 minutes on Basic, 5 hours Core, 50 hours Plus. Contributors capped at 2 on Basic.
- **Readymag**: **pageviews** — 10,000/mo on Personal, 75,000/mo even on the $58.50 Advanced tier. ⬜ Overage behaviour undocumented.
- **IONOS**: **hard page caps** — 10 pages on Starter, 200 on Plus. A 12-page brochure site forces the $20/mo renewal tier.
- **Jimdo**: page caps (5 / 10 / 50) **and** bandwidth caps (2 GB / 10 GB / 20 GB). Bandwidth metering on a brochure builder is unusual in 2026.
- **Format**: **70 hi-res images on Basic** — a hard, low cap for a photography product.
- **Webflow Starter**: **50 form submissions total, never resets.**

## Family 1 — mainstream all-in-one builders

One vendor for editor, hosting, domain, store, email and marketing. The audience is explicitly non-technical, and the product design assumes you will never want the HTML.

### Wix 🟩

**[wix.com](https://www.wix.com)** — the category's largest player, and since January 2025 the owner of the professional-tier **Wix Studio** as well.

| | |
|---|---|
| **Pricing** *(secondary — the pricing page does not render figures)* | Free · Light **$17/mo** annual, $24 monthly · Core **$29 / $36** · Business **$39 / $46** · Business Elite **$159 / $172** · Enterprise custom |
| **Storage** | 500 MB free · 2 GB Light · 50 GB Core · 100 GB Business · unlimited Elite |
| **Collaborator seats** | 2 / 5 / 10 / 100 by tier |
| **Transaction fee** | 0% on Business+; ~2.9% + $0.30 processor rate |
| **Code export** | ❌ **None** |

Wix Studio is a **separate SKU** — a Studio-built site requires a Studio plan. Reported tiers: Basic $19 · Standard $27 · Plus $34 · Elite $159, with Elite carrying 10M CMS items and 100 external collaborators *(secondary — Wix tells prospects to view Studio pricing in an incognito window)*.

**Pricing gotchas.** Free domain applies to yearly plans only, year one; ~$13–17/yr thereafter. Professional email is **not included** — Google Workspace at ~$6/user/mo. App Market apps run $3–$20/mo each. Some first-party verticals (Wix Bookings) require upgrading the **entire plan tier** rather than buying an add-on. Refunds: 14-day money-back on the initial payment only, domains excluded.

> [!CAUTION]
> **Template lock-in is absolute and it triggers at site *creation*, not at publish.** Wix's own help centre: *"While it's not possible to switch to a different template for a site you already created, you can create as many sites as you want in your account"* ([Switching Your Site Template](https://support.wix.com/en/article/switching-your-site-template)). A separate standing feature-request article confirms it is *"not currently possible to change your site's template, **even if you haven't added any content or elements**"*. The workaround is a manual rebuild on a new site, then transferring the premium plan and domain across. **No other vendor in this review has this constraint.**

> [!CAUTION]
> **No export, ever.** Wix's help centre states it plainly: *"Your Wix site is a standard HTML5 site, and is built with Wix's technology. In order for your site to work properly, it needs to be hosted and operated on Wix's servers"* ([Exporting or embedding your Wix site elsewhere](https://support.wix.com/en/article/exporting-or-embedding-your-wix-site-elsewhere)). Blog, contacts and store data are extractable through individual product tools. The rendered site is not. **The domain is the only genuinely portable asset.**

**What's good.** Velo gives you a real JS backend runtime, data collections and HTTP functions — the most capable extensibility story in this family. SEO is strong: editable `robots.txt`, per-page titles and meta descriptions, per-page `noindex`, `nofollow` robots meta, managed sitemap. The panel is now branded **"SEO & GEO"**, a 2025/26 rename acknowledging generative-engine optimisation. And Wix posts the **highest mobile Core Web Vitals pass rate** of the big platforms — see [Performance](#performance--core-web-vitals-by-platform). The old "Wix is bad for SEO because it's JS-rendered" claim no longer holds on performance grounds; the remaining constraint is structural (forced `/post/` URL prefix on blog posts).

**Recent.** Editor X was sunset into Wix Studio — transition began April 2024, **completed January 2025** with automatic migration and zero downtime, but with real feature losses (vertical sections can no longer be added; some image scroll effects and click/hover interactions cannot be recreated once deleted). New Editor X sites cannot be created. The Classic Editor has no announced sunset. Wix also acquired **Base44** for ~$80M cash plus earn-outs through 2029 (June 2025) and launched **Wix Harmony** (2026-01-21), an agentic AI editor driven by an agent called Aria.

### Squarespace 🟩

**[squarespace.com](https://www.squarespace.com)** — the design-led option; the strongest template aesthetics in the family.

| | |
|---|---|
| **Pricing, pre-increase** *(secondary; two 2026 sources disagree on the monthly column)* | Basic **$16/mo** annual · Core **$23** · Plus **$39** · Advanced **$99** |
| **Pricing, post-July-2026** | Basic **$19** (+19%) · Core **$29** (+26%) · Plus **$49** (+26%) · Advanced **$99** (unchanged) |
| **Transaction fees** *(from the vendor page)* | Store: 2% / 0% / 0% / 0% — Digital & memberships: **7% / 5% / 1% / 0%** |
| **AI credits** *(vendor page)* | 10 one-time / 20 per mo / 40 per mo / 120 per mo |
| **Code export** | 🟨 Lossy WordPress-format XML only |

> [!WARNING]
> **Squarespace raised prices by up to 26% in July 2026**, communicated **by customer email with no vendor changelog entry**. Context: **Permira took Squarespace private in October 2024 for $7.2bn**. Community sentiment is hostile — one user reported a **61% cumulative increase since 2021** *(community-reported via [PetaPixel](https://petapixel.com/2026/07/17/squarespace-is-increasing-prices-by-up-to-26/))*. **PE ownership is a forward-looking pricing risk worth naming when you plan a three-year budget.**

**Pricing gotchas.** Custom CSS/JavaScript is **paywalled above Basic**. Contributors capped at 2 on Basic. Video storage: 30 min / 5 h / 50 h / unlimited. Premium integrations (Mailchimp, Zapier, OpenTable) need Core minimum. Acuity Scheduling ($16–$49/mo) and Email Campaigns ($8–$118/mo) are **separate subscriptions**. **Plan migration is one-way** — legacy Personal/Business holders who move to the new lineup cannot revert.

**Export.** The XML targets WordPress and drops a lot: album, cover, index, info, calendar, portfolio and **store** pages; page-specific headers/footers/sidebars; audio, product and video blocks; drafts; style settings; **custom CSS**. It carries **one** blog page only. And: *"It's not possible to export content from one Squarespace site and import it into another"* ([Exporting your site](https://support.squarespace.com/hc/en-us/articles/206566687-Exporting-your-site)). Community reports add that the XML links to Squarespace-hosted images rather than embedding them, so images break once you cancel *(community-reported)*.

> [!TIP]
> **Squarespace has the best developer story in this family and almost nobody knows it.** [Developer Mode](https://developers.squarespace.com/) gives full template-file access — *"change anything from the doctype to the footer"* — plus **automatic git repositories per template**, a local development server, the JSON-Template language, and Commerce and Contacts APIs. This is the only real git workflow among the mainstream builders. The catch: enabling it locks you out of parts of the visual editor.

**SEO.** Strong. 301/302 redirects via Settings → Developer Tools → **URL Mappings**, with **wildcard support** (`/old/* -> /new/* 301`) and a `[name]` variable that auto-redirects a whole collection. Limits: same-domain only, and you **cannot redirect image/file URLs or the homepage**. Canonicals are emitted automatically and **cannot be overridden** *(community-reported)*. No native hreflang — multilingual needs code injection or Weglot.

### Duda 🟩🟩

**[duda.co](https://www.duda.co)** — the agency/reseller platform. Not sold to consumers, and the better for it.

| Plan | Monthly | Annual (/mo) | Sites included | Team members |
|---|---:|---:|---:|---:|
| Basic | $25 | $19 | 1 | — |
| Team | $39 | $29 | 1 | 3 |
| Agency | $69 | $52 | 4 | 6 |
| White Label | $199 | $149 | 4 | 6 |

Additional sites: **$19/mo** (Basic) or **$17/mo** (higher tiers). 14-day trial, **30-day money-back guarantee**. Source: [duda.co/pricing](https://www.duda.co/pricing).

**Pricing gotchas.** Per-site charging is the model and it scales linearly, not tiered: an agency with 40 client sites pays roughly **$52 + 36 × $17 ≈ $664/mo**. Seats are capped per tier (3 / 6). The advertised "coupon rate" is roughly 50% off — expect renewal at the non-coupon annual rate; Duda does not frame this as intro-vs-renewal, so verify at checkout.

> [!IMPORTANT]
> **Duda is the only mainstream builder with real code export — and it is gated at the $52/mo Agency tier.** Agency+ downloads a zip of HTML, JavaScript, CSS, images and media. Excluded: **Store** (comes out as CSV), **Blog** (comes out as `.rss`), **dynamic pages**, and **password protection is not preserved**. Post-export, *"you will not be able to make edits using the website builder"* and *"Duda is not able to support it on the new platform"* ([Site Export](https://support.duda.co/hc/en-us/articles/26519246857495-Site-Export)). The $19/mo Basic customer cannot get their site out at all.

**What's good.** A genuine JSON REST API covering site creation, content, domains, collections, dynamic pages and ecommerce, with white-labelling ([developer.duda.co](https://developer.duda.co/docs)). Built-in structured data. And the **best measured performance in the category** — 84.9% of Duda origins pass all three mobile Core Web Vitals, the highest of any platform in the HTTP Archive dataset. Duda also shipped an **AI Connector (MCP)** on Agency+, the first MCP endpoint among these builders.

**Weak spots.** Multilingual is folder-based but thinner than Wix or WordPress *(secondary)*. ⬜ Page/CMS limits and staging behaviour are not published.

### Hostinger Website Builder 🟨

**[hostinger.com/website-builder](https://www.hostinger.com/website-builder)** — cheapest credible all-in-one; absorbed Zyro.

| Plan | Intro | Regular | Renewal | Basis |
|---|---:|---:|---:|---|
| Premium | **$2.99/mo** | $10.99/mo | **$10.99/mo** | 48 months for **$143.52** upfront |
| Business | **$3.79/mo** | $16.99/mo | **$16.99/mo** | 48 months for **$181.92** upfront |

Premium: 3 sites, 20 GB SSD, 2 mailboxes/site (free 1 yr), free domain 1 yr. Business: 50 sites, 50 GB, 5 mailboxes/site, **up to 1,000 products with 0% transaction fee**, AI text/image/blog/product/logo/SEO tools.

> [!WARNING]
> **The "$2.99/mo" is a single upfront payment of $143.52.** Hostinger states it plainly: *"All plans are paid upfront. The monthly rate reflects the total plan price divided by the number of months in your plan."* Renewing the same 48-month term costs **$575.52**. Shorter terms carry much higher effective monthly rates — the headline price only exists at 48 months.

**No HTML export.** Custom code can go *in* (head, body, embed element — CSS, HTML and JS) but nothing comes out. ⚠️ **Do not confuse Website Builder with [Hostinger Horizons](#10web--hostinger-horizons--durable--base44)**, the separate AI app builder, which *does* export (a Node/React/Vite project, on an active subscription, one-way).

⬜ Refund policy unverified — the ToS URL 404'd at snapshot date. ⬜ Page/CMS/form caps not published.

### GoDaddy Website Builder (Websites + Marketing / Airo) 🟥

**[godaddy.com/websites/website-builder](https://www.godaddy.com/websites/website-builder)** — the registrar's upsell. Fastest path from "I bought a domain" to "there is a page there", and the hardest platform to leave.

| Plan | Annual (/mo) | Monthly | Renewal |
|---|---:|---:|---:|
| Basic | $9.99 | $21.99 | **$16.99** |
| Premium | $14.99 | $39.99 | **$29.99** |
| Commerce | $20.99 | $44.99 | **$34.99** |

*All figures secondary — **GoDaddy returned HTTP 403 to every automated request**, including its generic `/pricing` page and its UK mirror. A second source gives Basic $12.99 / Premium $22.99 / Commerce $26.99. Treat no GoDaddy figure as verified.*

**Pricing gotchas.** Renewal jumps of +67% to +100%. Monthly billing is +120% over annual on Basic. Domain free year one, then `.com` auto-renews at **$22.99/yr** (above market). Microsoft 365 free year one, then **$8.99/mo**. Domain privacy **$12.99 initial, $14.99/yr** — charged for something several competitors include. The best deals require **36-month or longer** commitments.

> [!CAUTION]
> **GoDaddy's custom-HTML block renders inside an iframe in the body.** This is not "limited custom code" — it is structurally broken. Styling does not inherit, most analytics and tracking snippets fail, and **embedded content is invisible to crawlers as page content**. There is also an HTML size limit on the block, and JavaScript cannot be injected into the page source at all. GoDaddy's own troubleshooting doc acknowledges display problems ([Troubleshoot HTML or custom code not displaying properly](https://www.godaddy.com/help/troubleshoot-html-or-custom-code-not-displaying-properly-28025)).

Also: **no multilingual option at all** *(secondary)*, no code export, no git, no staging, no custom backend. Leaving means a rebuild from scratch.

**Recent.** **Airo.ai** launched 2025-11-13 in beta — six agents including a Website Builder Agent that *"builds and customizes GoDaddy Website Builder sites by selecting themes, generating content, setting up pages, and configuring SEO settings"*. Explicitly an AI layer over existing products, not a replacement; no pricing disclosed.

### IONOS (MyWebsite Now / Creator) 🟨

**[ionos.com/websites/website-builder](https://www.ionos.com/websites/website-builder)** — European hosting incumbent; bundled domain + email + builder + rankingCoach.

| Plan | Intro | Regular | Renewal | Pages |
|---|---:|---:|---:|---:|
| Starter | $6/mo | $18/mo | **$14/mo** | **10** |
| Plus | **$1/mo** | $24/mo | **$20/mo** | **200** |
| Pro | $17/mo | $32/mo | ⬜ | unlimited |

All plans: free domain, professional email, 30-day money-back guarantee. Pro bundles **rankingCoach Standard**.

> [!CAUTION]
> **IONOS tells you to scrape your own site.** From its own help centre: *"For technical reasons, website projects created with a website builder from IONOS cannot be used outside the IONOS infrastructure."* The suggested workarounds are (1) browser "Save page as → Website, complete" **one page at a time**, and (2) **HTTrack**, a third-party site ripper. IONOS also warns that licences for images from its own image pool *"are not transferable"* ([Overview of export options](https://www.ionos.com/help/websites-stores/organize-websites-and-stores/website-builders-overview-of-export-options/)). **This is the clearest lock-in signal in the entire review.**

Other constraints: the HTML/JavaScript module *"is not available in all MyWebsite Now plans"*; you cannot build from a blank canvas; template selection is thin *(secondary)*. Note IONOS ships **two** builders — MyWebsite **Now** (simple) and MyWebsite **Creator** (more capable) — and reviews routinely conflate them.

### Weebly / Square Online 🟥

**[weebly.com](https://www.weebly.com)** · **[squareup.com/us/en/online-store](https://squareup.com/us/en/online-store)**

> [!CAUTION]
> **Do not start a new site on Weebly.** Square acquired it in 2018 and has put it in maintenance mode: signups closed, the mobile app pulled, the community forum closed, social accounts dormant 6+ months, **no new feature or theme in over a year**. Square insists it is *not* shutting Weebly down and walked back an earlier "support ends July 2025" statement — which arguably makes it worse: an **indefinitely undead platform with no roadmap**. Users are pushed toward Square Online, which *"lacks many of Weebly's features"* *(community-reported, consistent across [SiteBuilderReport](https://www.sitebuilderreport.com/weebly-review), [WebsiteBuilderExpert](https://www.websitebuilderexpert.com/news/is-weebly-shutting-down/) and Square's own community forum)*. **Weebly's lock-in is now temporal rather than technical — the platform is decaying under you.**

**Square Online pricing** *(vendor plan pages render features but not figures)*: Square Free **$0/mo** · Plus **$49/mo per location** · Premium **$149/mo per location** · Pro custom. Online card rates 3.3% + $0.30 (Free) or 2.9% + $0.30 (paid).

Two gotchas: **$49 and $149 are per location**, not per account; and on **2026-01-13 Square raised the free-tier online rate from 2.9% + $0.30 to 3.3% + $0.30** — a 14% increase in the rate itself. Square Online's processing is **Square-only**; you cannot bring Stripe or PayPal as the primary processor. That is the real lock-in — payments, not code.

### Jimdo 🟥 · Site123 🟥 · Google Sites 🟨

Three tools that share a ceiling, listed together because the finding is the same: *cheap, simple, and disqualifying if search traffic matters.*

**[Jimdo](https://www.jimdo.com)** — German lightweight builder. PLAY free / START ~$11 / GROW ~$17 / GROW LEGAL ~€26 / UNLIMITED ~€45 *(secondary; the pricing page rendered navigation only across multiple fetches, and sources mix USD and EUR within one table)*. Hard **page caps** (5 / 10 / 50) and **bandwidth caps** (2 GB / 10 GB / 20 GB). The simple editor has **no HTML embed element at all**, blocking most third-party widgets and tracking; the older **Creator** editor does have code features. No blog, no password protection, **no backups or restore**. SEO is reportedly limited to editing the **homepage title only** — no per-page meta descriptions, no 301 redirects, no alt text *(single secondary source, 2025-07-28; may describe only the simple editor — flagged as needing verification)*. Genuinely differentiated feature: **GROW LEGAL bundles German/EU legal texts**, which nothing else here does.

**[Site123](https://www.site123.com)** — wizard-driven, no canvas. **Does not publish a tier table**; the page says only "as low as $10.8 per month (annual, paid up front)". Three review sites report **$8.28–$60 for comparable tiers** — a spread far outside normal promo variance. Gotchas: **the full term is billed upfront and is non-refundable after 14 days** (a 10-year plan bills 120 months immediately); **tiers above Basic are hidden until after signup**, so you cannot price-compare before committing; **no monthly billing option**; bandwidth as low as 5 GB/mo on Basic. No export and no documented migration path.

**[Google Sites](https://sites.google.com)** — free with any Google account, bundled into every Workspace tier. Genuinely fine for intranets, team pages, school and club sites. **Structurally disqualifying for anything that needs to rank:**

> [!CAUTION]
> **Google's own website builder is the least SEO-capable product in this review.** No custom meta descriptions. No access to `robots.txt` or `.htaccess`. **No sitemap control — Google Sites stopped providing sitemaps in March 2021.** No redirects. No structured data. And no canonical tag, which matters because **every Google Sites page exists at two URLs simultaneously** — the long `sites.google.com/...` URL and your custom domain — with no way to tell Search which is authoritative. That is a duplicate-content problem baked into the product. What you *do* control: page titles, content, heading hierarchy, internal linking and image alt text.

## Family 2 — designer-first / visual-development builders

Real CSS control, a CMS, staging, and an audience of professionals. This is where the money and the lock-in both concentrate.

### Webflow 🟩🟩

**[webflow.com](https://webflow.com)** — the category's professional default. Visual development producing genuine HTML/CSS/JS.

Pricing is **two-axis** and covered in full [above](#two-axis-pricing--site-plans--seats). Headline: Site plans Basic **$15/mo** annual ($25 monthly) / Premium **$25** ($39); Workspace Core **$19** / Growth **$49**; Full seats **$39/mo**.

> [!IMPORTANT]
> **Webflow reset its pricing on 2026-05-13.** CMS and Business plans were **merged into a single Premium plan**; a **Team** plan was inserted between self-serve and Enterprise. Effective for new purchases 2026-05-13; existing sites migrate **2026-06-29**, or **2026-11-16** for sites in Freelancer/Agency/legacy workspaces.
>
> Read the change carefully, because it is not uniformly good news:
> - **Ex-CMS customers gain**: $14 → $25/mo annual, but with 20,000 CMS items (up from 2,000), 300 static pages (up from 150), and Webflow Cloud requests 1M → 2M.
> - **Ex-Business customers lose**: $39 → $25/mo annual sounds like a cut, but **bandwidth drops from 100 GB to 50 GB**, Webflow Cloud requests drop **10M → 2M**, and CPU units drop **120 → 30**. That is a 5× compute reduction dressed as a simplification.
> - **Basic monthly-billed rose 39%** ($18 → $25).
> - **CMS item add-ons were eliminated** — you can no longer buy past 20,000 outside Team/Enterprise.

**Other 2026 changes.** Client seats became free on freelancer/agency workspaces on **2026-02-02**. The **legacy Editor is being retired** — migration began 2026-05-04, gone **2026-08-04** — and **whitelabeling (removing Webflow branding from the client Editor) dies the same day**, which is a real hit for agencies. AI credits are now metered per Workspace tier (200 Starter / 300 Core / 400 Growth, +$20/mo per 2,000).

**Export — the thing everyone gets wrong.** Export exists, lives on the **Workspace** axis (needs a paid workspace, not just a site plan), and is a design snapshot rather than a site:

> [!CAUTION]
> **Webflow's export excludes CMS content.** From the vendor doc: CMS, User Accounts, Ecommerce content, code components and localized pages/content aren't in the export; on an exported site *"Collection lists will show the empty state, and Collection pages won't show any content bound to Collection fields"* ([How do I export my Webflow site code](https://help.webflow.com/hc/en-us/articles/33961386739347-How-do-I-export-my-Webflow-site-code)). Also lost: site search, form processing, reCAPTCHA, localization — and **password protection is stripped, so previously protected pages become public**. CMS content must be pulled separately as per-collection CSV or via the CMS API.
>
> **General rule: if a builder's export excludes CMS content, the export is a mockup, not a migration.**

**What's genuinely strong.** SEO is best-in-class among visual builders: server-rendered static HTML at the edge, per-page title/description, editable `sitemap.xml` and `robots.txt`, a global canonical setting, a built-in **301 redirect manager**, OG fields, and CMS-field interpolation into meta tags. **Webflow Cloud** now hosts Next.js/Astro apps with backend logic deployed from a linked **GitHub repo** with per-branch environments and automatic rollback; **DevLink** pulls Webflow components and CMS data into an external React codebase. That combination — high design freedom *and* full SEO control *and* a real code escape hatch — is why Webflow dominates the professional segment.

**Weak spots.** Localization is a **paid per-locale add-on** ($9 or $29/mo each) and localized content is **not exportable**. The Designer itself *"does not fully support assistive technology"* by Webflow's own admission — a blocker if your content team includes assistive-technology users. **No native cookie-consent manager**, and site-wide head custom code (needed to install one) requires a paid site plan. Data is **US-only**, with EU residency an open wishlist item since at least 2021.

### Framer 🟩🟩

**[framer.com](https://www.framer.com)** — design-tool-shaped site builder with the best motion story in the category, and as of June 2026 the most aggressive agentic-AI bet.

| Plan | Price (annual, /mo) | CMS collections | CMS items | Pages | Bandwidth | AI credits |
|---|---:|---:|---:|---:|---:|---:|
| Free | $0 | 10 | 1,000 | 30 | 1 GB | 500/mo |
| Basic | **$10** | **2** | 1,000 | 150 | 50 GB | 1,000/mo |
| Pro | **$30** | 10 | 2,500 | 150 | 100 GB | 3,000/mo |
| Enterprise | custom | custom | custom | custom | custom | volume |

**Seats and add-ons**: additional editor **$20/mo**, content editor **$10/mo**, viewers free · pages **$20 per 100** (max 700) · bandwidth **$40 per 100 GB** (max 2 TB) · CMS collections **$40 per 10** (max 40) · CMS items **$20 per 10,000** (max 40,000) · localization **$20 per locale** · A/B testing **$50 per 500,000 events** · advanced hosting **$200/mo**. **Site plans are per site.**

Note the anti-pattern in that table: **Free gets 10 CMS collections; Basic gets 2.** Free is a demo tier, not a small-site tier, and downgrading from a trial can break a site.

**May 2026 change, in the buyer's favour**: editor seats dropped **$40 → $20**, a $10 content-editor role was added, Basic bandwidth went 10 GB → 50 GB and Basic CMS collections 1 → 2, **with no price increase**. Existing subscribers grandfathered.

**June 2026 — Framer 3.0**: in-canvas **Agents** (editing pages, components, CMS, SEO and publishing inside the live project), **Branching** (the agent works on a branch, you review a diff and publish), and **External Agents** — connect Claude Code, Codex, Cursor or Gemini CLI to your Framer project. Credits reset on the **1st of the calendar month regardless of your billing date**, with no carry-over.

> [!CAUTION]
> **Framer has no code export, by explicit policy.** Its own help doc, verbatim: ***"Framer does not offer HTML export for self-hosting"*** and ***"Framer does not provide a way to export published sites as HTML files or static website bundles"*** ([Can I export my website to HTML and self-host it?](https://www.framer.com/help/articles/can-i-export-my-website-to-html-and-self-host-it/)). The stated reason is that pre-rendering, dynamic image resizing, font subsetting, SSR and the global CDN depend on Framer's infrastructure. **This is the largest single lock-in fact in the review.**
>
> **The content, however, is portable.** The [CMS Export](https://www.framer.com/community/marketplace/plugins/cms-export/) marketplace plugin dumps collections to CSV/JSON, and there is a CMS API. A realistic exit is: export CMS → import to a headless CMS → **rebuild the front end from scratch**.

**Bandwidth behaviour is the harshest in the review.** There is **no overage billing** — month 1 gets an email and an in-product banner, and continued overage forces an upgrade. Community reports say a site that blows its cap **goes offline entirely** until the cycle resets *(community-reported; not Framer's wording)*. A viral post is a worse outcome on Framer than anywhere else here.

**SEO.** Good, with two real holes. Pages are statically generated at publish and served from an edge CDN, so crawlers read content without executing JS; auto `sitemap.xml` including CMS collection pages, refreshed every publish; native **301/308 redirects** on Pro+ with automatic creation on URL change; user-uploadable `robots.txt` (2026); JSON-LD via custom code with CMS-field interpolation. The holes: **no hreflang support** despite selling localization at $20/locale, and **custom canonical links gated to Enterprise** *(secondary)*. Framer also documents *"Traffic-aware Pre-Rendering"* — ⬜ the article 404'd on every slug tried, so what happens to low-traffic pages is unverified, and it is load-bearing for the SEO claim.

### Webstudio 🟩🟩

**[webstudio.is](https://webstudio.is)** — open-source, headless Webflow. **AGPL-3.0-or-later**, 8.8k GitHub stars, 6,541 commits on main.

| Plan | Price | Hosting | Storage | Pageviews | Seats |
|---|---:|---|---:|---:|---:|
| Hobby | **$0** | `wstd.io` subdomain | 250 MB | — | 1 |
| Pro | **$15/mo** annual, $20 monthly | **unlimited sites** with custom domains | 20 GB | 100,000/mo | 1 |
| Team | **$35/mo** annual | same | 20 GB | 100,000/mo | **5** |

**Overage: $20 per additional 100,000 pageviews/mo, with capped overage protection.** The only transparent, bounded, pay-as-you-go overage model in this review.

> [!IMPORTANT]
> **Webstudio has the best multi-site economics in the entire category by a wide margin.** *Unlimited sites on one $15/mo Pro subscription.* Ten sites on Webflow costs $250+/mo in site plans alone. If you are a freelancer or small agency running many client sites, this is the number that should make you look.

**Export is real, and it's the only one here that produces a runnable, editable application.** Two modes:

- **Dynamic (default)** — a **Remix/React app**. Keeps CMS integrations, form webhooks, image optimization, redirects. Deploy to Netlify, Vercel, or your own box via Docker (min 1 GB RAM, 1 core).
- **Static** — plain HTML/CSS/JS, deploy anywhere. **Loses** dynamic pages, redirects, webhooks, image optimization, and auto-generated `sitemap.xml`/`robots.txt`.

**Project export is available on the free Hobby plan.**

**The trade-off is the CMS.** Webstudio has none by design — it integrates with Strapi, Supabase, Hygraph, Ghost, Notion, Airtable, Baserow, WordPress, Contentful, Drupal, Payload, Sanity, Directus and Decap. No item caps, but you are operating a second service. Also: still officially **beta**, and **self-hosting the Builder in production is explicitly "currently not recommended"** by their own docs (published sites self-host fine; the editor is dev-use-only). Nice touch: **you can paste Webflow elements straight into the canvas.**

### Dorik 🟨

**[dorik.com](https://dorik.com)** — AI-first no-code builder with white-label and client billing built in, aimed at solo agencies reselling to SMBs.

| Plan | Monthly | Annual (/mo) | 2-year (/mo) | Lifetime |
|---|---:|---:|---:|---:|
| Personal | $29 | $20.75 | **$10.38** | **$249** (1 site) |
| Business | $59 | $41.50 | **$20.75** | **$599** (3 sites) |
| Agency | $99 | $79 | custom | custom |

**Unlimited storage and bandwidth on every tier.** Code export, white-label dashboard, client billing, custom fields/collections and AI generation are on **every tier including Personal** — unusual generosity. Personal allows **0 collaborators** (genuinely single-user); Business 10; Agency unlimited.

> [!WARNING]
> Two flags. **(1)** Monthly billing is a **~2.8× penalty** versus the 2-year rate, and the advertised 2-year rates are attached to coupon codes — the "real" price is promo-dependent. **(2)** **Lifetime deals coexisting with subscriptions is a business-model smell** — it signals cash-flow-driven pricing. Weigh platform-longevity risk before buying a $599 lifetime licence. ⬜ Export scope, git integration, localization and staging are not documented in substance; the export is *claimed* on all tiers but unverified in content.

## Family 3 — portfolio & creative-niche builders

Image-first publishing. Different buyers, different failure modes — and, with one exception, the weakest SEO in the review.

### Readymag 🟨

**[readymag.com](https://readymag.com)** — editorial/art-direction canvas; closer to InDesign-on-the-web than to Webflow. Campaign microsites, digital magazines, lookbooks.

| Plan | Annual (/mo) | Monthly | Sites | Domains | Collaborators | **Views/mo** |
|---|---:|---:|---:|---:|---:|---:|
| Free | $0 | $0 | 1 (max 10 pages) | — | 1 | — |
| Personal | $14 | $19 | 1 | 1 | 1 | **10,000** |
| Freelancer | $29 | $38 | 5 | 3 | 2 | **25,000** |
| Advanced | $58.50 | $65 | unlimited | 10 | 10 | **75,000** |

**Pageview caps are the real constraint and they are low** — 75,000/mo even at $58.50. ⬜ Overage behaviour is undocumented. **Code export is Advanced-and-above only** — a 4× price jump purely to get your own files.

> [!CAUTION]
> **Readymag's export is a frozen JSON blob, not a codebase.** Per its own docs, the archive ships HTML, CSS, JS, images, **content encoded as JSON and rendered on the page via JavaScript**, plus mandatory NGINX/Apache config files, and *"SEO snippets for crawlers"*. Critically: ***"Exported projects cannot be changed"*** — to edit, you return to Readymag, re-publish and re-export. Form widgets lose their Google Docs / email / Mailchimp targets. And ***"Custom Open Graph tags and SEO tags are not exported for any page except the first one"*** ([Code export](https://help.readymag.com/hc/en-us/articles/360020647452-Code-export)).
>
> The JSON-rendered-by-JS architecture of the export strongly suggests **the hosted product renders the same way**, with the "SEO snippets" as a crawler shim. Readymag's own docs warn indexing takes *"several days up to a month"* and cannot be accelerated. **Treat Readymag as unsuitable for search-acquisition-dependent sites.** ⬜ Readymag publishes no rendering-architecture statement; this is inference from the export docs.

On the credit side: Readymag is one of very few builders where the vendor states the export makes you independent — *"You can even stop your Readymag subscription: it won't have any impact on the exported project."* SEO controls that do exist: per-page title/description/keywords, custom URL paths, **manual H1–H6 assignment on text objects**, alt text, auto canonical/`robots.txt`/`sitemap.xml`. Missing: structured data, redirect rules, favicon controls.

### Cargo 🟨

**[cargo.site](https://cargo.site)** — the anti-Squarespace. Idiosyncratic, design-forward publishing for the art/fashion/photography world.

**The most honest pricing page in the review:** one price, **$14/mo billed yearly or $19/mo monthly**, to make a site public. **Unlimited public sites on `*.cargo.site` subdomains at no extra cost.** One custom domain included; additional domains **$2/mo** (yearly) each. Commerce add-on **$5.50/mo** yearly, **and Cargo charges no per-transaction fee**. You can build privately for free indefinitely; there is no free trial of the public tier.

No seats, no bandwidth caps published, no CMS-item caps, no form caps. ⬜ Cargo publishes no traffic limits at all, so behaviour under load is unknown.

**Limits.** No code export documented anywhere. CSS and HTML editing is the ceiling — no backend, no API, no git, no localization, no staging. **Cargo 2 → Cargo 3 is a hard break**: migrating an existing Cargo 2 portfolio requires a **manual layout rebuild**; Cargo 2 still runs its own separate support site. Confirm which version you are being sold.

> [!WARNING]
> **Cargo's SEO surface is two fields.** Settings → Site Details exposes **"Tags"** and **"Description (SEO)"**, and Cargo auto-generates `/sitemap.xml`. Its support docs **do not cover page titles, alt text, `robots.txt`, canonical, redirects or structured data**, and explicitly warn that frameset redirection/masking *"may possibly prevent your website from being indexed at all"* ([Search Engine Optimization](https://support.cargocollective.com/Search-Engine-Optimization)). Fine for a portfolio people reach by name. Wrong for anything that needs to be found.

### Semplice 🟩

**[semplice.com](https://www.semplice.com)** — a WordPress-based portfolio system sold as software, not SaaS. Built by designers, for designers who want to own the thing.

**One-time purchase, no subscription:** Single **$119** (1 licence) · Studio **$168** (regular $229, currently discounted) · Business **$699** (10 licences). Free critical updates included. **No direct support** — documentation only, explicitly to keep the price down. **No refunds.** Current version is Semplice 7.

The sticker price excludes the real cost: WordPress hosting, domain, backups, security maintenance, and your time. But the trade is a good one for the right buyer — **$168 once plus ~$10/mo hosting** against $14/mo forever, and:

> [!IMPORTANT]
> **Semplice has the highest SEO ceiling and the lowest lock-in of any commercial product in this review, because it isn't a platform — it's a theme on your own WordPress install.** Full Yoast/RankMath, complete control over meta, canonical, robots, sitemaps, redirects, structured data and hreflang. Migration means "move a WordPress site." Switching themes means a design rebuild, but the content, the database and the server are yours.

### Pixpa 🟩 · Format 🟨 · Adobe Portfolio 🟨 · Universe 🟨 · Typedream 🟨 · Carrd 🟩

**[Pixpa](https://www.pixpa.com)** — all-in-one portfolio + client galleries + store, aggressively cheap. Basic $9/mo monthly, **$5.40/mo yearly, $4.05/mo on 2-year** · Creator $15 / $9 / $6.75 · Professional $20 / $12 / $9 · Advanced $25 / $15 / $11.25. **Zero commission on sales at every tier**, direct Stripe/PayPal payouts. Basic caps you at **200 website images and 1 blog** — the trap tier. Storage 3 GB / 5 GB / 25 GB / 100 GB. The headline "$4.05" requires **$97.20 paid upfront** for 24 months. **Best SEO in the portfolio family**: schema markup, per-gallery meta tags, clean URLs, **301-redirect support**, and bulk gallery export — which together make it the only portfolio platform you can leave with your URLs intact.

**[Format](https://www.format.com)** — portfolio + client workflow for working photographers. Basic $14/mo monthly, **$120/yr** · Pro $24 / **$144/yr** · Pro Plus $36 / **$180/yr**. Commission-free store on all tiers. **Monthly billing costs up to 2.4× annual** — the steepest penalty in the review. **70 hi-res images on Basic** is a hard, low cap for a photography product. **No export of any kind**, content or code. ⚠️ Multiple review aggregators report recurring complaints of unauthorised billing and price increases without notice *(community-reported and partly competitor-authored — unverified against Format's own statements, but consistent across independent sources)*.

**[Adobe Portfolio](https://portfolio.adobe.com)** — **$0 marginal cost** with any Creative Cloud subscription (entry point: Photography Plan $9.99/mo). **Maximum 5 sites per account**, hard-enforced; one custom domain per site, free to connect, SSL included. Behance import, Lightroom sync, Adobe Fonts, password-protected pages. Theme-parameter customisation only — the least design-flexible tool in the creative family despite the audience. No CMS, no ecommerce, no export, no localization. ⚠️ **Product-health warning**: `adobe.com/products/portfolio.html` and both `helpx.adobe.com` FAQ URLs **return 404**; documentation now lives on a Zendesk. The product page is live with no deprecation notice, but the broken Adobe-domain docs are a real neglect signal. ⬜ No official statement either way.

**[Universe](https://onuniverse.com)** — mobile-first grid builder; the editor is genuinely an **iPhone app**. Free (5 pages, Universe branding) · Pro **$12/mo, $72/yr** (25 pages, **5% ecom fee**) · Creator **$25/mo, $200/yr** (100 pages, **2% fee**, custom code) · Enterprise **$50/mo, $500/yr** (unlimited, **0% fee**). The transaction fees dominate the plan price for anyone selling more than ~$1,000/mo. Annual is a real discount on Pro ($72 vs $144) but **worse than two-months-free** on Creator and Enterprise. Custom code is Creator-tier and up. No export, no CMS, no localization. *(Note: the 2023 "Universe shutdown" stories refer to a **K-pop fan platform of the same name**, not this product. The builder is live and was still shipping updates in 2026.)*

**[Typedream](https://typedream.com)** — Notion-like editing for real websites, creator-oriented. **Billed per site**: Free · Launch **$15/mo** annual, $20 monthly · Grow **$42 / $49**. Three sites on Launch is **$45/mo, not $15**. **Transaction fees never reach 0%** — 2% floor even at $42/mo, on top of Stripe. Form-submission and email-subscriber caps of 1,000 on Launch are low for a creator platform. Password protection is Grow-only. No export.

**[Carrd](https://carrd.co)** — one-pagers, and the cheapest real tool in the review. **$19/yr Pro Standard** covers 10 sites with custom domains, forms, widgets and analytics; **$49/yr Pro Plus** adds advanced forms, redirects, password protection and **site download**. 16 published price points across Pro Lite/Standard/Plus × site count. For a landing page, a link-in-bio or a single-product site, nothing else here is close on price.

## Family 4 — WordPress and the open-source / self-hostable corner

The only family where **you own the stack**. Also the only family where the price you pay a vendor is not the price of the website — you supply hosting, and often an SEO plugin, and often an addon ecosystem nobody mentioned.

### The state of WordPress at snapshot date

**WordPress 7.0 "Armstrong"** shipped **2026-05-20** — an **AI Client in core**, a Client-Side Abilities JS package, a ⌘K command palette, a font-management page, new Gallery/Heading/Breadcrumbs/Icons blocks, device-specific visibility controls, server-side (PHP-only) block registration, and a more extensible Site Editor. 875+ contributors. 7.0.2 (security) landed 2026-07-17; 7.1 is in beta. Community reporting frames 7.0 as the start of **Gutenberg Phase 3 (collaboration)**, with real-time collaboration **pulled from the final 7.0 cycle in May 2026** over stability and server-load concerns *(community-sourced; not in the official release post)*.

**The market-share picture is more useful than any review.** HTTP Archive's April 2026 crawl of ~8.9M mobile origins, as % of WordPress sites:

| Builder | Share | YoY |
|---|---:|---:|
| **Elementor** | **32.67%** | +2.51 pp |
| **Block Editor (Gutenberg)** | **20.62%** | +1.04 pp |
| wpBakery | 8.52% | — |
| **Divi** | **5.72%** | +0.06 pp |
| **Site Editor (full FSE)** | **1.67%** | +0.52 pp |
| Beaver Builder | 1.11% | −0.05 pp |
| SiteOrigin | 0.76% | — |
| Oxygen | 0.44% | +0.00 pp |
| **Bricks** | **0.34%** | **+79% relative** |

*Source: [GravityKit's analysis of HTTP Archive](https://www.gravitykit.com/wordpress-page-builder-market-share-2026/).*

Two readings worth carrying into a decision:

> [!IMPORTANT]
> **Full-site editing has not won.** Block Editor sits at 20.62%; the **Site Editor at 1.67%** after four years. Everyone uses blocks; almost nobody uses Gutenberg to build the *whole site*. That is the strongest single data point against "just use core" as advice for a design-led site — and the reason a $100M+ paid builder market still exists.
>
> **And the builders the internet is loudest about hold under 1% between them.** Bricks (0.34%), Oxygen (0.44%) and Breakdance (below the 0.17% tracking cutoff) are the enthusiast picks. Elementor's growth is decelerating — from **+28% YoY in early 2023 to +8.3% in April 2026** — but it is still 32.67% of WordPress, which is ~13% of the entire web. **Separate "best tool" from "tool you can hire for."**

### WordPress.com (Automattic hosted) 🟨

**[wordpress.com/pricing](https://wordpress.com/pricing/)** — Free · **Personal $9/mo monthly, $4/mo annual** (6 GB) · **Premium $18 / $8** (13 GB) · **Business $40 / $25** (50 GB) · **Commerce $70 / $45** · Enterprise custom. Deeper discounts on 2- and 3-year prepay. Free domain first year on annual commitments.

> [!CAUTION]
> **The plugin-access rule on WordPress.com is genuinely ambiguous and the answer depends on when your plan was bought.** The current support doc says *"Installing plugins is available on all WordPress.com paid plans: Personal, Premium, Business, and Commerce"* (reviewed 2026-05-06). But that entitlement **originated as a two-week promotion** (2025-08-12 → 2025-08-25) which explicitly said: *"If you already have a paid Personal or Premium plan, this offer doesn't apply"*, *"After August 25, plugin access returns to WordPress.com Business and Commerce plans only"*, and *"not applicable for downgrades and renewals"* ([WordPress.com blog, 2025-08-12](https://wordpress.com/blog/2025/08/12/for-a-limited-time-unlock-plugin-power-on-personal-premium-plans/)). Community reporting says the change was made permanent from 2025-09-08 **but with grandfathering asymmetry — sites predating the promo may still be Business-gated** *(community-sourced)*.
>
> **Verify plugin capability on the actual account before committing.** Do not assume the current doc applies to a plan you already hold.

### The WP Engine ⇄ Automattic dispute — what it means for a buyer

A neutral summary, because it comes up in every WordPress decision since late 2024.

**Timeline.** 2024-09-21: Mullenweg publicly attacks WP Engine over trademark use and contribution levels. 09-23: mutual cease-and-desists. **09-25: WordPress.org blocks WP Engine's access to plugin and theme updates.** 10-02: WP Engine sues Automattic and Mullenweg (N.D. Cal.). 10-12: Mullenweg takes over WP Engine's **Advanced Custom Fields** plugin, forking it as "Secure Custom Fields". **2024-12-10: the court grants WP Engine a preliminary injunction** — Automattic ordered to stop blocking WordPress.org access and **restore ACF and account access within 72 hours** ([TechCrunch](https://techcrunch.com/2024/12/10/court-orders-mullenweg-and-automattic-to-restore-wp-engines-access-to-wordpress-org)). **2025-09-12: a mixed ruling** dismissed WP Engine's most aggressive claims (monopolisation/antitrust, attempted extortion) while letting intentional interference, unfair competition and defamation proceed. 2025-10-23: Automattic files counterclaims. **2026-02-12: newly unsealed discovery** underpins an amended complaint alleging Automattic planned royalty demands against ~10 hosting competitors and that Mullenweg contacted Stripe to pressure cancellation of WP Engine's contract; Automattic's response was that this is *"the same narrative WP Engine has been pushing for over a year"* ([TechCrunch](https://techcrunch.com/2026/02/12/automattic-planned-to-target-10-competitors-with-royalty-fees-wp-engine-claims-in-new-filing/)). **Discovery closed 2026-05-14; motion-to-dismiss argument 2026-06-25. No settlement as of 2026-07-27.** ⬜ Trial date conflicting across community sources (late 2026/early 2027 vs June 2027); no docket confirmation obtained.

> [!IMPORTANT]
> **The practical lesson is architectural, not legal.** Nothing in this dispute threatens WordPress the software — it is GPL-2.0-or-later and unrevocable. What the episode proved is that **`api.wordpress.org` is a single discretionary chokepoint** for updates and installs across the entire ecosystem, that access to it was withdrawn from a major commercial party overnight, and that it took a court order to restore.
>
> **Mitigations, now mainstream:** pin plugin sources via Composer / WPackagist / WP Composer; keep local mirrors of critical plugins; prefer plugins distributed from vendor servers over `.org`-only; treat update availability as a supply-chain dependency you should survive losing for a week. And know whether your ACF is **ACF or Secure Custom Fields**, and where its updates come from.
>
> Host choice is not a legal risk to you — WP Engine remained operational throughout, and no ruling restricts anyone from buying hosting from either party.

### The WordPress visual builders

| Builder | Licence cost | Sites | Lapse behaviour | Lock-in | Performance rep. |
|---|---|---:|---|---|---|
| **[Gutenberg / Block Editor](https://wordpress.org/gutenberg/)** | **$0** | ∞ | n/a | 🟩🟩 HTML with comment delimiters — degrades readably | good |
| **[Elementor](https://elementor.com)** Pro | ~$59–199/yr *(⬜ unverified)* | 1 / 3 / 25 by tier | keeps working; lose updates | 🟥 JSON in `_elementor_data` postmeta — page empties on deactivate | middling |
| **[Divi](https://www.elegantthemes.com/join/)** | **$89/yr unlimited sites**, or $249 lifetime | **∞** | keeps working; lose updates | 🟥🟥 **shortcodes in `post_content`** — visitors see raw shortcode text | weakest |
| **[Bricks](https://bricksbuilder.io)** | $79 / $149 / $249 per yr, or **$599 lifetime** | 1 / 3 / ∞ | **keeps working AND stays editable** | 🟥 postmeta; page empties | **best** |
| **[Beaver Builder](https://www.wpbeaverbuilder.com/pricing/)** | $89 / $179 / $299 / $546 per yr | 1 / 3 / 50 / ∞ | keeps working; lose updates | 🟩 **clean HTML into `post_content`** | good |
| **[Breakdance](https://breakdance.com/pricing/)** | **Free (∞ sites)**, Pro $99.99/yr (1), $199.99/yr (∞) | ∞ | **keeps working *with* Pro features** | 🟥 postmeta | good |
| **[Oxygen](https://oxygenbuilder.com)** | **$129–$199.50 once**, unlimited sites, no renewal | **∞** | n/a (lifetime) | 🟥🟥 **replaces the theme layer entirely** | strong |

**Notes that matter more than the table.**

- **Elementor's prices could not be verified from primary source.** Its pricing pages render prices client-side; the fetched DOM contains *"Billed annually. You pay ___ today"* with the numerals absent. The page's own meta description says *"starting from $49/year"*; third-party listings say Essential $59 / Advanced Solo $79 / Advanced $99 / Expert $199 per year. **The largest website builder in the world does not serve its prices in HTML.** Note also that **Essential deliberately withholds Popup Builder and Custom CSS** — the two things most people need within a week — and that a serious Elementor setup usually means 2–4 **third-party addon licences** (Essential Addons, PowerPack, Crocoblock JetEngine) that nobody counts.
- **Elementor One** is a separate all-in-one subscription (Pro widgets + AI + image optimisation + accessibility remediation + cookie consent + site management) metered in **monthly credits that do not roll over** — 25,000/mo on the base tier, at 20 credits per accessibility fix and 10 per image optimised. **It does not include hosting**, despite the framing.
- **Divi 5** left beta on **2026-02-26** and was stable at 5.2 with weekly updates by April 2026 — Elegant Themes describe it as having *"freed ourselves of a decade of technical debt."* Migration is a one-click Divi 5 Migrator run with a backward-compatibility mode, Divi 4 supported at least 12 months, and opt-out available. Their own warnings: back up first; **third-party plugin incompatibility may prevent full module migration**; **custom CSS may need adjustment**. Old Divi performance benchmarks may now be stale — the rewrite's stated purpose was fixing exactly that.
- **Bricks had a critical unauthenticated RCE (CVE-2024-25600) in February 2024 that was actively exploited** — the most severe incident of any builder here. Fixed in 1.9.6.1. ⬜ Not re-verified against a primary advisory in this pass; check Patchstack/Wordfence directly before making a security argument either way. Elementor's record by contrast is **40 patched vulnerabilities in Patchstack's database**, with 2025–2026 disclosures all medium/low, all authentication-required, and all patched in the normal release cycle.
- **Breakdance has the two best commercial terms in the WordPress cluster, both stated on its pricing page**: an **indefinite price lock** (*"Sign up for any plan, and lock in the price indefinitely"*) and a **lapse policy that costs you nothing** — sites keep functioning **with all pro features** if you don't renew. Its page also advertises Pro Unlimited as *"Soon to be $399.99"* against a current $199.99, which is a genuine time-sensitive signal.
- **Oxygen and Breakdance are the same vendor (Soflyy) and Oxygen 6 shares ~80% of its codebase and rendering engine with Breakdance** *(community-sourced)*. **Oxygen 6.2 is branded "MCP Edition"** and ships MCP-client integration for Claude Code, Claude Desktop, Codex, Cursor and OpenCode. Oxygen Classic is preserved as a **separate product at a separate URL**, because the rebuild was not a seamless upgrade — which is the concrete cautionary tale about lifetime licences.

> [!CAUTION]
> **The WordPress page-builder lock-in trap, stated plainly.** [Nelio Software's analysis](https://neliosoftware.com/blog/lock-in-effect-wordpress/) gives the rule: avoid tools that *"transform your content or put shortcodes in it, or use additional database tables beyond the standard WordPress ones."* **Every commercially successful WordPress page builder violates that rule except Beaver Builder.**
>
> Concretely, on deactivation: **Divi** shows visitors raw shortcode text (and pollutes feeds and any headless consumption); **Elementor, Bricks and Breakdance** leave the page empty; **Oxygen** removes the site's entire templating layer, not just page layouts. **Beaver Builder** — and Gutenberg blocks — leave readable formatted HTML. That single behavioural difference is Beaver Builder's whole reason to exist, and it is worth more than any feature comparison if you expect the site to outlive the builder.

### SEO plugins — the mandatory WordPress line item

Every WordPress option above needs one. Nothing in core does titles, meta, schema or redirects properly.

| Plugin | Price | Sites | Note |
|---|---|---|---|
| **[Rank Math](https://rankmath.com/pricing/)** | **PRO €95.88/yr, renews €107.88** · Business €299.88 → €335.88 · Agency €659.88 → €779.88 | unlimited personal / 100 / 500 client | Prices exclude VAT. **Free tier is genuinely usable** — unlimited keyword optimisation, redirect manager, 404 monitor, GA4, Search Console in-dashboard, 18 schema types. |
| **[Yoast SEO Premium](https://yoast.com)** | **~€118.80/yr *per site*** *(secondary)* | 1 | **Per-site pricing makes Yoast ~10× the alternatives at 10 sites — $1,188/yr vs ~$49–108/yr.** |
| **SEOPress Pro** | **~$49/yr unlimited** *(secondary)* | ∞ | Best raw value for agencies. |

> [!TIP]
> **A currency and staleness trap worth naming.** Rank Math's live pricing page is in **EUR with explicit renew-higher pricing**; third-party listicles still quote it in USD at $49.50/$199.50/$299.50 per year. Those numbers are stale. This is a compact illustration of why affiliate listings should never be trusted for price in this category.

### Ghost 🟩🟩

**[ghost.org](https://ghost.org)** — **MIT**, 54.6k★. Publishing + newsletters + paid memberships in one. Not a general-purpose site builder, and it does not pretend to be.

**Ghost Pro** (yearly billing): **Starter $18/mo** (1 staff, 1,000 members, basic design) · **Publisher $29/mo** (3 staff, marketplace themes, **paid subscriptions**, advanced analytics, Zapier + Admin API) · **Business $199/mo** (15 staff, **10,000 members**, custom SSL) · Custom. **Ghost takes 0% transaction fee** on all paid plans; Stripe's fees still apply.

> [!WARNING]
> **The member-count cliff is Ghost Pro's real price.** Pricing does *not* scale continuously — each tier has a hard member ceiling and you're notified to upgrade when you hit it. The jump from Publisher's 1,000 members to Business's 10,000 is **$29 → $199/mo, a 6.9× step with no intermediate tier**. Plan for it before you start growing a list. Also: **paid subscriptions require Publisher** — Starter cannot monetise at all — and the Admin API and Zapier are Publisher+, so any automation forces the upgrade.

**Self-hosting** is genuinely viable and cheap: Ubuntu 22.04/24.04, MySQL 8, NGINX ≥1.9.5, **≥1 GB RAM**. A 1 GB VPS at Hetzner/DO/Vultr is **$5–7/mo**, so **$7–12/mo all-in** against Ghost Pro's $18/mo floor. Two catches push people back to Pro: **Ghost-CLI installs get no web analytics**, and **ActivityPub is Ghost(Pro)-only unless you self-host via Docker Compose**. (Also, a system user literally named `ghost` conflicts with Ghost-CLI.)

**Ghost 6.0** shipped two things worth knowing about: **ActivityPub out of beta** — your publication becomes a followable profile (`@you@yourdomain.com`) from Mastodon, Threads, WordPress-with-ActivityPub and Bluesky via bridge, with an in-Admin Reader and short-form **Notes**, free on both Pro and self-hosted — and **native cookie-free analytics** (real-time visitors, top content and sources, newsletter performance, member growth, segmented by public/free/paid), which removes a third-party analytics bill.

> [!IMPORTANT]
> **Ghost has best-in-class native SEO with no plugin.** Automatic sitemaps, canonical URLs, structured data, meta/OG/Twitter cards, clean markup. That is a genuine differentiator against WordPress, where every one of those is a paid plugin. The trade: **it is a publication engine.** No page builder, no ecommerce beyond memberships, limited structured content modelling, and theming means editing Handlebars templates.

### The open-source builder shelf

**[Webstudio](https://webstudio.is)** — **AGPL-3.0**, reviewed in full [in Family 2](#webstudio-). The only visual builder here that is both open source and a credible Webflow replacement. Note the AGPL implication: **self-host a modified Webstudio and offer it as a service, and you must publish your changes** — fine for building sites with it, a constraint if you want to white-label the builder itself.

**[Silex](https://www.silex.me)** — **AGPL-3.0**, 2.9k★, maintained by the French non-profit **Silex Labs**. **Completely free** — *"All features are free of charge"* — funded by Open Collective donations. v3 is Node/TypeScript, using **GrapesJS** as the editing canvas and **11ty** for static generation, with a Tauri desktop app coming. Deploy via Docker, Node, or one-click CapRover; hosted instance at v3.silex.me. Can pull dynamic data from WordPress, Strapi and arbitrary APIs at build time. The project markets itself explicitly on *"no vendor lock-in"* and protection against *"enshittification."* Risks: small maintainer base, non-profit funding, no managed CMS/membership/commerce layer.

**[Publii](https://getpublii.com)** — **GPL-3.0**, at 0.47.9 (updated 2026-07-24). A **desktop** static-site CMS with a GUI — no server, no terminal, no build pipeline. Outputs static HTML with **auto-WebP responsive images and structured data built in**; one-click deploy to GitHub Pages, GitLab, Netlify, S3, Google Cloud or plain FTP. **Best native SEO of the free options.** The limitation is structural: it's a desktop app, so your content lives on one machine and multi-author collaboration means syncing a project folder yourself. No web editing, no dynamic features.

**[GrapesJS](https://grapesjs.com)** — **BSD-3-Clause**, 26.1k★. **Not an end-user builder** — it's *"the leading open-source framework for building your visual web builders."* You get an editing canvas; you supply storage, auth, publishing and hosting. Relevant here only if you're embedding an editor in your own SaaS. The commercial **Studio SDK** is closed-source: Free (1,000 sessions/mo, **$50 per extra 1,000**) · **Startup $200/mo** (20,000 sessions, $20/1,000 overage) · **Business $2,000/mo** (50,000 sessions). Note the **10× jump from Startup to Business for 2.5× the sessions** — Startup's overage rate is cheaper than upgrading until roughly 110k sessions. And "sessions" is **not defined on the pricing page**.

**[Ycode](https://www.ycode.com)** — markets itself as an open-source Framer/Webflow alternative. **Self-hosted $0** (fork, deploy to Vercel, connect Supabase — unlimited users, pages, CMS items, form entries, languages) · **Cloud $25/mo** yearly, $30 monthly, capped at 20,000 CMS items. ⬜ **Licence not stated** on the site and `/pricing` 404s — do not assume an SPDX. Note the inverted limits: the free self-hosted tier is *unlimited* while the paid Cloud tier is capped. Also note that "self-hosted $0" is only true inside Vercel and Supabase free tiers; production is realistically $25–45/mo, i.e. **possibly more than Cloud**.

### Headless CMSes and code-first platforms

Not website builders — you write the frontend — but they are what people migrate *to* when a builder's ceiling is hit, so the pricing matters.

| Tool | Licence | Free tier | First paid tier | The cliff |
|---|---|---|---|---|
| **[Payload](https://payloadcms.com)** | **MIT** | **Self-hosted free forever** (Node ≥20.9, Mongo/Postgres/SQLite) | **Enterprise, custom, demo required** | **No middle tier at all.** SSO, visual editing, publishing workflows and A/B testing are all Enterprise. `payloadcms.com/pricing` is a 404 — pricing lives at `/get-started`. |
| **[Directus](https://directus.com)** | **BSL 1.1** (moved off GPL) | **Core $0** — but **3 user seats**, 25 collections | **Team $499/mo** annual, $599 monthly | **$0 → $499/mo with nothing between.** SSO is Team-tier, and extra SSO seats are **$50/seat/mo** — a 20-person team is ~$999/mo. Cloud is a **$99/mo add-on**. |
| **[Strapi](https://strapi.io)** | **MIT** community | Self-host free (SSO, audit logs, advanced RBAC still Enterprise-gated) | **Cloud Starter $35/mo** (100k API requests) | Metering: **$1.50 per extra 25k API requests**, **$30 per 100 GB bandwidth** (~10–60× typical CDN rates), and **environments priced at $60–300/mo each**. |
| **[Craft](https://craftcms.com/pricing)** | source-available | **Solo free** — but *"not professional client work"* | **Team $279 / Pro $399 per project**, then **$99/yr** | Per-project. But the licence is **perpetual** — stop paying and it works forever at your last version. |
| **[Statamic](https://statamic.com/pricing)** | source-available | **Core free forever** (1 admin, 1 content form) | **Pro $349 per site**, then **$99/yr** | Per-site. Perpetual. **Purchase-parity pricing available** — rare in this whole review. |
| **[Kirby](https://getkirby.com/buy)** | source-available | free in dev | **Basic €99 / Enterprise €349 per site** | **3 years of updates**, then keep the last version forever free or pay **€59 / €249 for three more years**. Basic requires revenue/funding **under €1M**. |

> [!IMPORTANT]
> **Craft, Statamic and Kirby share a licence model that deserves more attention than it gets: a perpetual licence with an optional update subscription.** You buy once; the software never stops working; you pay again only if you want future updates. Renewal is **25–35% of the initial price** (Craft/Statamic $99/yr; Kirby €59 per *three* years). Compare that to every subscription builder, where lapsing means losing the product. If you are choosing something to run for a decade, this model is structurally safer than both subscriptions and lifetime deals.

> [!CAUTION]
> **Ownership and governance changed under two of these in 18 months.** **Payload was acquired by Figma** (announced 2025-06-17); maintainers confirmed in a GitHub discussion that the repo stays MIT and community-driven, but roadmap gravity now points at Figma Sites *(community-sourced)*. MIT code cannot be retracted — the risk is direction, not licence. Separately, **Directus moved off GPL to the Business Source License**, and its free use is now framed through an **"Open Innovation Grant"** available only to organisations under **$5M revenue AND fewer than 50 employees** — a revenue tripwire you will cross with no warning. ⬜ Exact BSL change-date terms not verified; read `directus.com/bsl` before self-hosting commercially.

### Astro / Hugo + a git-based CMS — the $0 floor

The pattern: a static site generator (**Astro**, MIT; **Hugo**, Apache-2.0 — both free, no site limits, no renewal) plus a git-backed editing UI so non-developers can edit. Content stays as Markdown **in your repo**; the CMS is a form over git commits. Hosting is **$0** on Cloudflare Pages, Netlify or GitHub Pages.

| Editor | Licence | Price | Notes |
|---|---|---|---|
| **[Sveltia CMS](https://github.com/sveltia/sveltia-cms)** | **MIT**, 2.6k★ | **$0** | Explicitly the successor to Decap, **drop-in compatible with Decap config**, claims 710 resolved issues reported against Decap. First-class i18n, mobile support, dark mode, DAM with stock-photo APIs. **Production-ready** — *"a growing number of organizations, including U.S. government websites, have migrated from Decap CMS to Sveltia CMS."* |
| **[Decap CMS](https://decapcms.org)** | **MIT** | **$0** (+ "Decap Turbo" paid add-on, ⬜ price unpublished) | ⚠️ The site states the project is *"seeking a strategic partner to help us take Decap CMS to the next level."* An explicit sustainability flag. Auth historically depends on Netlify Identity or a self-hosted OAuth proxy. |
| **[TinaCMS](https://tina.io/pricing)** | — | Free (2 users) · **Team $24/mo** · Team Plus $41/mo · **Business $249/mo** | **Priced per project, not per org** — three client sites is 3× the bill. Extra seats $90/seat/yr. Editorial workflow is Team Plus+. AI features marked "Coming Soon" on tiers you pay for now. |
| **[CloudCannon](https://cloudcannon.com/pricing)** | — | **Standard $49/mo** annual (3 users, **unlimited sites**) · Team $300/mo · Partner Lite $10/mo agencies-only | The only git-CMS here with true visual editing over an SSG. Watch the add-ons: extra users $10/mo, bandwidth from $15/100 GB, and **custom domains $2/mo each** — which is the real per-site cost hiding under "unlimited sites". |

> [!TIP]
> **Given Decap's "seeking a strategic partner" notice and Sveltia's drop-in config compatibility, Sveltia is the default recommendation for new git-CMS projects.** Same $0, same config format, active maintainer, migration path already proven at scale.

### Visual builders over your own codebase

**[Plasmic](https://www.plasmic.app/pricing)** — generates real React/Next.js and plugs into an existing codebase, so marketers can edit pages inside your app. **Free** (3 collaborators, **Plasmic badge required**) · **Starter $39/mo** — which buys *only* badge removal · **Pro $103/mo** (4–10 collaborators) · **Scale $399/mo** (A/B testing, scheduled content, targeting) · Enterprise. Additional collaborators **$20–40 each**. The features that justify a visual builder for a marketing team — A/B testing, scheduling, targeting — are all at $399/mo. Lock-in is medium-low: you can eject to React/Next.js code, but you give up the editing loop. Renders server-side, so it is SEO-viable.

**[Builder.io](https://www.builder.io/m/pricing)** — has **pivoted hard from visual headless CMS to AI agent / design-to-code** in the last 12–18 months. Pricing is now built around **Agent Credits**: Free (5 users per space, **25 daily / 75 monthly credits**) · Pro (per user/mo, credit rollovers, built-in MCP servers, still 5 users per space) · Team (up to 20 users, unlimited credits, roles, custom MCP servers) · Enterprise. On-demand credits **$25 per 500**. ⬜ **Per-seat prices are not rendered on the page**, and third-party figures ($19 / $24 / $40) are mutually inconsistent — do not publish one. **If you are evaluating Builder.io as a website builder or CMS, you are now a secondary use case.**

**[Tilda](https://tilda.cc/pricing/)** — hosted, block-driven, unusually strong long-form editorial blocks. Free (1 site) · **Personal $10/mo annual, $15 monthly** · **Business $20/mo annual, $25 monthly** (5 sites, **plus code export**). Three gotchas: **HTML export is Business-only**, so Personal is total lock-in; **"Made on Tilda" branding removal requires an annual subscription**; and —

> [!CAUTION]
> **Tilda has the harshest lapse policy in this review: if your subscription lapses, the site is unpublished, and your data is retained for 6 months and then permanently deleted.** Compare that to every WordPress builder, where the site keeps serving whatever happens to your licence.

### Realistic all-in monthly cost, one production site

Hosting + licence + SEO, at snapshot date:

| Stack | Monthly floor | Note |
|---|---:|---|
| Astro/Hugo + Sveltia + Cloudflare Pages | **$0** | + domain. The true floor. |
| Silex or Publii + static host | **$0** | + domain. |
| Webstudio self-hosted | **$0** | + your infra |
| WordPress + Gutenberg + free SEO plugin | **$3–12** | cheapest WordPress path |
| WordPress.com Personal (annual) | **$4** | but plugin access is conditional |
| Ghost self-hosted | **$7–12** | loses analytics + easy ActivityPub |
| Kirby | **$7–17** | €99 once, €59 every 3 yrs |
| Tilda Personal (annual) | **$10** | **no export at this tier** |
| WordPress + Divi | **$10–20** | $89/yr across *all* sites |
| WordPress + Bricks / Beaver / Elementor | **$10–21** | + $59–99/yr licence |
| Webstudio Pro | **$15** | hosting included, unlimited sites |
| Ghost Pro Starter | **$18** | no paid subscriptions until $29 |
| Craft / Statamic | **$20–35** | after year-one licence |
| CloudCannon Standard | **$49** | unlimited sites, 3 users, +$2/domain |
| Directus Team / Strapi Cloud Business | **$450–499** | the cliff tiers |

## Family 5 — AI-first / prompt-to-site builders

The 2025–2026 wave. Describe the site; a model writes it. Pricing is [credit-metered](#credit-metering--the-ai-builder-pattern), output quality is uneven, and the security defaults are the category's systemic problem.

> [!IMPORTANT]
> **Most of these build *applications*, not websites.** Lovable, Bolt, Replit, Base44 and v0 emit React apps with backends. Evaluating them against Squarespace on "can my client edit the copy" or "does it do 301 redirects" produces nonsense in both directions. The ones that genuinely compete with a website builder are **10Web**, **Hostinger Horizons**, **Durable**, and the AI layers inside **Wix**, **Squarespace**, **Webflow** and **Framer**.

### Lovable

**[lovable.dev](https://lovable.dev)** — chat to full-stack app: React/Vite/Tailwind/shadcn front end plus a Supabase-shaped backend ("Lovable Cloud"). Free · **Pro $25/mo** (100 credits, $21/mo annual) · **Business $50/mo** · Enterprise. Pro is a **ladder** — 100 credits $25 → 10,000 credits $2,250 — at a flat **$0.25/credit** until volume discounts.

Three separate credit currencies (**build**, **Cloud**, **AI**), documented burn of **0.50–2.00 credits per message** in default mode, and credits that roll over but **expire 2 months after issue**. On exhaustion: *"Building stops until credits are available. Your published site stays live… AI features in deployed apps stop working, and apps that rely on the built-in backend (Cloud) can pause."* Not seat-priced — *"plans are priced by the credits they include, not by seats."* Free plan has **no private projects, no custom domain, no Code view**, and a permanent "Edit with Lovable" badge.

**Code ownership is strong**: standard Vite + React + TypeScript + Tailwind + shadcn, continuous Git sync to GitHub/GitLab, self-host without restriction. Secrets and API keys are not included in the export. The lock-in is to Supabase, not to Lovable.

**SEO changed materially in 2026.** Projects created **from 2026-05-13** use **TanStack Start with true SSR**. Older React+Vite projects get **on-request pre-rendering served only to verified crawlers** — meaning *"third-party SEO tools see the SPA shell instead."* Anyone auditing a legacy Lovable site with Ahrefs or Screaming Frog will get misleading results.

Funding: Series B **$330M at a $6.6B valuation** (2025-12-18), ~$500M ARR, ~8M users.

### Bolt.new · v0 · Replit

**[Bolt.new](https://bolt.new)** (StackBlitz) — browser-native, runs in WebContainers, **best code ownership in the family**: one-click ZIP of a standard Vite/Next project, one-click GitHub push, two-way sync for a Bolt↔VS Code loop (GitHub only). Free (1M tokens/mo, **300K daily cap**) · **Pro $25/mo** (10M tokens, no daily cap, **unused tokens roll over**) · Teams $30/member. Pro is a ladder to 1,200M tokens at $2,000/mo. Reloads **$20 per 10M tokens**. Paid allocations valid **two months**, consumed FIFO, **forfeited on cancellation**. **The structural gotcha: Bolt syncs the entire codebase into context on each interaction, so cost scales with project size, not request size.**

**[v0](https://v0.app)** (Vercel) — prompt-to-UI in Next.js/RSC/Tailwind/shadcn. Free ($5 included monthly credits) · **Plus $30/user/mo** ($30 credits + $2/day on login) · **Business $100/user/mo** (*the same* $30 credits — you pay 3.3× for features, not capacity) · Enterprise. Credits are dollar-denominated and token-metered at published rates (v0 Mini $1/$5 per 1M in/out; **v0 Max Fast $10/$50**). `npx v0 add <url>` installs generated components straight into a local Next.js project. **Best SEO in the family by construction** — Next.js App Router means server-rendered HTML and the full metadata API. The lock-in is to the framework, not the vendor: output is idiomatically Next.js-only.

**[Replit](https://replit.com)** — cloud IDE + agent + hosting + Postgres, framework-agnostic. Starter free (**1 published project**) · **Core $25/mo** ($20 annual, $25 of credits, 2 parallel agents) · **Pro $100/mo** ($100 credits, 10 parallel agents) · Enterprise. **Deployment is billed separately out of the same credit pool**: static hosting free with **$0.10/GB** egress; Autoscale **$1/mo + $3.20/M compute units + $1.20/M requests**; Reserved VMs **$20–$160/mo**. Community-reported: *"a small app with light traffic might cost $5 to $10 per month in deployment fees, while a busy app can easily hit $50 or more."* Replit is an **app host, not a site host** — no platform SEO layer.

### 10Web · Hostinger Horizons · Durable · Base44

**[10Web](https://10web.io)** — agentic AI that emits a **real WordPress site** on managed Google Cloud. AI Starter **$10/mo** ($120/yr) · Premium $15 · Ultimate $23 · Agency Core $112 · Agency Pro custom. **Annual is 50% off**, so the headline monthly prices are commit-discounted. **The real ceiling is visitor caps** (10K / 20K / 50K / 200K per month), not credits.

> [!TIP]
> **10Web is structurally the best AI-first option for an SEO-led site, and it isn't close.** The output is server-rendered PHP/WordPress, fully indexable, with the entire Yoast/RankMath toolchain available — and *"you can export the site, install any of the 60,000+ plugins in the WordPress plugin directory, and move to a different host whenever you want."* Every other AI builder in this family emits a React SPA or locks the output. Agency Core carries a **7% billing fee**; Agency Pro goes "as low as 0%".

**[Hostinger Horizons](https://www.hostinger.com/horizons)** — prompt-to-web-app bundled with Hostinger hosting, domain and email. Free (5 AI credits, no domain/hosting) · Explorer **$6.99/mo** intro, $9.99 regular (30 credits, 1 site) · Starter **$13.99 / $19.99** (70 credits, 25 sites) · Hobbyist **$39.99 / $55.99** (200 credits, 50 sites, **code editor**). Hosting and domain are free for **one year only**, so year-2 cost is not the headline. **Code export is Hobbyist-only ($39.99/mo intro)** — and **one-way**: *"the exported code is turned into a static website and cannot be imported back to Horizons for further edits via prompting"* *(community-reported, corroborated across sources)*. One hands-on review is titled *"After 68 Prompts and No App"* — worth weighing against the marketing.

**[Durable](https://durable.com)** — "website in 30 seconds" plus CRM, invoicing, bookings and an AI blog writer, aimed at service-business solopreneurs. Free (no custom domain) · **Launch $25/mo, $22 annual** · **Grow $49/mo, $41 annual**. Every AI capability is a **separate monthly quota** — images, chat messages, blog posts, lead replies — so there are five meters to run dry instead of one. The free domain is capped by *dollar value* ("up to $20"), so premium TLDs cost extra. **No code export at all.** And:

> [!CAUTION]
> **Durable has no 301 redirects, no schema markup and no H1–H6 control** *(community-reported)*. Page slugs, SEO titles and meta descriptions are editable and that is roughly it. **No redirects is disqualifying for any site migration** — you cannot move to Durable from an existing site without losing every ranking URL, and you cannot leave without losing them again.

**[Base44](https://base44.com)** (Wix) — chat-to-internal-app with a bundled backend. Free · Starter **$20/mo** ($16 annual) · Builder **$50** · Pro **$100** · Elite **$200**. Wix acquired it for **~$80M cash plus earn-outs through 2029** in June 2025, when it was ~6 months old and solo-founded.

The distinctive gotcha is a **dual-currency credit model**: *message credits* burn when **you** prompt; *integration credits* burn when **your end users** exercise the live app. **Cost scales with your users' traffic, not your development effort.** Credits do not stack — they refresh each cycle.

**Code ownership is the worst in the family.** GitHub export is gated to Builder+ and *"Base44 only supports frontend code exports, while backend logic and database stay locked to Base44"* — exported code calls `base44-sdk`, so *"every button that does something real returns nothing because the backend it's calling isn't yours"* *(community-reported, consistent across independent sources)*.

### The AI layers inside the incumbents

- **Wix Harmony** (launched 2026-01-21) — an agentic editor driven by an agent called **Aria** that *"understands natural language and can execute tasks from simple color updates to complex page redesigns."* **No pricing stated in the press release**; secondary sources say it is free across plans and that Wix *"bundles its AI site builder into seat-style premium plans, so you pay for features and storage, not AI prompts."* ⬜ Unverified — but if true, **no AI metering is Wix's main commercial differentiator against this whole family.**
- **Squarespace Blueprint AI** — a **guided wizard, not a chatbot**: five steps of dropdowns and checkboxes, with brand personality chosen from **seven fixed options**. Included on all plans, but it consumes the metered AI credits (10 one-time on Basic is barely a trial). Community verdict: *"the process and end result feel somewhat cookie cutter."*
- **Webflow AI** — generates up to five pages from a prompt with a scalable design system, emitting semantic HTML with meta descriptions and image alt text; the AI Assistant can generate and deploy full-stack apps. Metered per Workspace tier (200/300/400 credits), +$20/mo per 2,000. *(Sources conflict on whether Webflow enforces hard credit limits — one claims reasonable-use rather than strict limits. ⬜ Neither verified from primary source; webflow.com/pricing failed to fetch.)*
- **Framer 3.0** — see [Framer](#framer-). The only incumbent that lets **external agents** (Claude Code, Codex, Cursor, Gemini CLI) drive the project.
- **Relume** — worth naming because people mis-file it. It is **not a builder**: it generates sitemaps, wireframes and component libraries that **export into Webflow, Figma, React or HTML**. Its cost sits **on top of** a Webflow subscription. React/HTML export is Pro-only. ⬜ **Prices unverifiable** — sources give Starter anywhere from $16 to $38 and Pro from $40 to "$250+", and at least one claims a move from seat-based to project-based pricing. **Do not quote a Relume price without a fresh manual check.**
- **Figma Make / Figma Sites** — priced per seat with AI credits attached (Professional Full seat $16/mo + 3,000 credits; Organization $55 + 3,500; Enterprise $90 + 4,250). Hosting is included while publishing is in beta. Two blockers for site work, both from Figma's own docs: ***"Figma Sites does not support code export"*** and ***"Figma Make optimizes all published files automatically, but does not currently offer specific customizability for SEO optimization."*** No export plus no meta control makes Figma Sites unsuitable for anything SEO-led today.
- **GoDaddy Airo**, **Google Stitch** and **Google Opal** — Airo is covered [above](#godaddy-website-builder-websites--marketing--airo-). **Stitch** (free Google Labs experiment, ~350 generations/mo *(community-reported)*) produces **designs and front-end code, not a hosted site** — it competes with Figma, not Wix. **Opal** builds shareable AI mini-apps with no custom domain, no SEO surface and no export — **not a website builder**, listed only to draw the line.

### Claude / ChatGPT + a static host — the "no builder at all" path

Credible in 2026 for content and brochure sites, and **the cheapest path with the best SEO**.

The stack: an LLM (Claude Code or ChatGPT) generates Astro/Eleventy/plain HTML; deploy to **Cloudflare Pages** or **Netlify**. Cloudflare Pages' free tier at snapshot date: **unlimited sites, unlimited bandwidth, unlimited static requests, 100 custom domains per project, 500 builds/month**, free SSL — **no branding, no badge, no plan gate on custom domains**. That is the strongest free-hosting offer in this review. Netlify ships an official Claude integration.

Where it wins: SEO (static HTML), ownership (files in git), cost ($0 hosting), portability. Where it loses: no CMS for a non-technical editor, no bookings/CRM/invoicing, no ecommerce, no visual editor — and the LLM subscription is not free. **Pair it with [Sveltia CMS](#astro--hugo--a-git-based-cms--the-0-floor) and the "non-technical editor" objection largely goes away.**

### Security — the family's systemic failure

> [!CAUTION]
> **This is not a per-vendor accident. It is a category-wide defaults problem, and it is now well-sourced.**
>
> **RedAccess, published May 2026** — scanned **380,000 publicly accessible assets** built with Lovable, Base44, Replit and Netlify; **~5,000 (≈1.3%) were leaking sensitive corporate or personal data**, and **~40% of the vulnerable apps exposed medical records, financial information, corporate strategy documents or customer-service chat transcripts**. The named root cause: *"privacy settings on some of the vibe-coding tools were set to make the apps publicly accessible unless users manually changed them to private"* — and many were **indexed by Google**. The same research found phishing sites impersonating Bank of America, FedEx, Trader Joe's and McDonald's built on Lovable ([Axios, 2026-05-07](https://www.axios.com/2026/05/07/loveable-replit-vibe-coding-privacy)).
>
> **Lovable / Supabase row-level security** — of 1,645 marketplace apps tested, **170 (≈1 in 10) were leaking user data**, and **70% had row-level security disabled**. The AI generated the data layer but not the access policies. Exposure window 2025-03-03 → 2025-04-20 ([TNW](https://thenextweb.com/news/lovable-vibe-coding-security-crisis-exposed)).
>
> **Base44 / Wiz, 2025-07-09** — two API endpoints (register and OTP-verify) required **no authentication**, and the `app_id` needed to abuse them was publicly exposed in app URLs and manifests. An attacker could self-register a verified account on **private, SSO-restricted** apps, including enterprise chatbots, knowledge bases and **PII/HR systems**. Patched within 24 hours, no evidence of exploitation ([Wiz](https://www.wiz.io/blog/critical-vulnerability-base44)).
>
> **The structural point:** these are less bugs in generated code than **defaults** — public-by-default sharing, RLS-off-by-default backends, and no security review step anywhere in the prompt→deploy loop. That is a platform design choice, and it is what distinguishes this generation of tools from the Wix/Squarespace generation, **which never handed users a database in the first place.**

## Family 6 — Notion-as-CMS renderers

Notion is the editor; the tool is a renderer, theme layer and domain host. Structurally the **least locked-in** family in the review — and the least operationally stable.

**[Super.so](https://super.so)** — Free (`super.site` hosting, "Made with Super" badge) · **Personal $16/mo, $144/yr** (custom domain, custom code and fonts, password protection, RSS, branding removed) · **Pro $28/mo, $336/yr** (manual publishing, advanced search, file uploads, **page redirects and hiding**, multi-language). **Billed per site**, and separately: **Teams $5/member/mo** and **Super Analytics** tiered by pageviews ($10/mo to 10K → $400/mo at 20M+). A 3-person team on Pro with 100K views is **$28 + $15 + $20 = $63/mo** across three line items. Custom domain is paywalled, so the free tier is unusable for a real site. SEO is better than most Notion wrappers because Super serves **optimized static HTML** rather than the Notion SPA, and auto-generates social cards.

**[Potion](https://potion.so)** — ⚠️ At snapshot date `potion.so` and `potion.so/pricing` both return a **Vercel `DEPLOYMENT_NOT_FOUND` error**, while the product appears alive at `beta.potion.so`. Read as a rebuild-in-progress or a botched DNS cutover, not necessarily a shutdown — **but verify before recommending.** Reported pricing *(competitor-authored source — label as such)*: 1 site **$10/mo annual** (250 pages), 3 sites $8/site, up to 8 sites $6/site. Potion states its renderer *"serves clean HTML to site visitors (and search engines)"* and offers in-Notion SEO management.

**[Popsy](https://popsy.co)** — ⚠️ **The site is down.** `popsy.co` returns a **Cloudflare Error 1016 — Origin DNS error** (verified 2026-07-27) at both root and `/pricing`. Community reports describe prolonged outages, a pivot away from Notion sites, support via Twitter DMs only, billing continuing after cancellation, and **no advance notice or migration instructions** to affected users *(all community-reported)*. **Do not use for new projects.**

> [!TIP]
> **The Notion family's saving grace is that a bad outcome is survivable.** The content never left Notion — switching between Super, Potion, Notion's own Sites feature, or a static generator means re-pointing a different renderer at the same Notion pages. You lose theming and domain config, not content. Given that **two of the three had infrastructure failures on the day of this snapshot**, that portability is doing real work. **Super is the default pick**, with the explicit note that its main competitor is cheaper and currently 404ing.
>
> The ceiling is the other side of the same coin: **your CMS is Notion**, with Notion's block model, API rate limits and uptime. No visual layout builder — you style with themes plus custom CSS. The design ceiling is far below Webflow, Framer or Readymag.

## Adjacent categories — what these are not

Two categories get evaluated against website builders and shouldn't. Both comparisons fail in both directions.

### Ecommerce platforms

Every website builder in this review ships a cart. So the trigger for moving to a dedicated commerce platform is **not** "I want to sell something." It's one of these:

1. **Catalogue scale and structure** — variants, option matrices, inventory across locations, bundles, price lists. Past a few hundred SKUs, a generic builder's product object collapses.
2. **Order operations** — fulfilment workflows, partial shipments, returns/RMA, tax nexus, multi-warehouse. This is the actual product of Shopify/BigCommerce/Shopware; the storefront is the least of it.
3. **Payments economics at volume** — at scale the *processing rate* dominates the *subscription*.
4. **A physical location** — Square, because a shared catalogue and one payment rail across counter and web is the whole value.
5. **B2B / ERP integration** — Shopware, at a €600/month floor for anything supported.

| Platform | Subscription | Processing | The distinctive gotcha |
|---|---|---|---|
| **[Shopify](https://www.shopify.com/pricing)** | Basic €36/mo monthly, €25 annual · Grow €105/€66 · Advanced €384/€289 · Plus **from €2,100/mo on a 3-yr term, €2,250 on 1-yr** (9 stores, extra stores €250/mo) *(EUR — the fetch geolocated to the EU)* | Online 2.1% / 1.8% / 1.6% + €0.30 by tier | **Third-party gateway penalty: 2% / 1% / 0.6% / 0.2% of order value**, on top of your own processor's rate, if you don't use Shopify Payments. On Basic that's a ~2% tax for the privilege of using Stripe directly. Above an **undisclosed** size, Plus switches to "a variable platform fee based on revenue". |
| **[BigCommerce](https://www.bigcommerce.com/essentials/pricing/)** | Core $39/$29 · Growth $105/$79 · Scale $399/$299 · Performance from $1,499/mo annual | 2.0% / 1.0% / 0.6% / 0% on **open** (non-embedded) payment providers; zero with embedded partners | **Published, automatic GMV-triggered tier bumps** — Core→Growth at **$30K trailing-twelve-month GMV**, Growth→Scale at **$100K TTM**, plus **0.9% of GMV above $33,333/month** on Scale. |
| **[Ecwid](https://www.ecwid.com/pricing)** (Lightspeed) | Starter $5 (10 products) · Venture $35/$29 (100) · Business $65/$49 (2,500) · Unlimited $149/$119 | your gateway's rate | **Zero transaction fees on every plan**, and the meter is **product count, not GMV** — a high-revenue 30-SKU store stays at $29/mo forever. It's a **bolt-on cart** for a site you already have. |
| **[Square Online](https://squareup.com/us/en/online-store/plans)** | Free · **Plus $49/mo per location** · **Premium $149/mo per location** · Pro custom | Online 3.3% / 2.9% / 2.9% + 30¢; in-person 2.6% / 2.5% / 2.4% + 15¢; international **+1.5%** | Tiering rewards **in-person** volume, not online — a pure-online seller gets almost nothing from Premium. **Custom domain requires Plus.** |
| **[WooCommerce](https://woocommerce.com/pricing/)** | plugin free, 0% revenue share | WooPayments **2.90% + $0.30** online, 2.70% + $0.10 in-person, **+1.50%** international, **+1.00%** currency conversion, **$15 flat** per dispute, **1.5%** instant payout, **$5/mo per active card reader**, **+1.00%** on Stripe Billing subscriptions | The real cost is elsewhere: Woo's own page says hosting **"$25 – $350/month for most stores"** and extensions **"$29 – $299/year each"** — annual, not monthly, and you lose updates when a licence lapses. |
| **[Shopware](https://www.shopware.com/en/pricing/)** | Community **free** (self-host) · Rise **from €600/mo** · Evolve **from €2,400/mo** · Beyond custom | ⬜ not mentioned on the pricing page | The **€600/mo floor** is the whole story. Note the inversion on the AI add-on: **€29/mo on the free Community Edition, €19/mo on paid tiers.** |

> [!IMPORTANT]
> **Two directions of lock-in, different in kind.** Shopify/BigCommerce/Square/Ecwid lock you in with *hosting and data*. You can CSV out your products — but Shopify's own export docs state that **images leave as URLs pointing back at Shopify's CDN**, which must stay publicly reachable for a re-import to work, and that products with **>100 variants get emailed rather than downloaded**. App-owned data (reviews, subscriptions, loyalty) never appears in an export at all, because it lives in the app vendor's database.
>
> WooCommerce and Shopware CE invert this: you own the database and the files, so there is no export step — but you now own hosting, patching, PCI scope and a PHP dependency. **Neither is free. Pick the failure mode you can staff.**

> [!WARNING]
> **The GMV cliff is the most under-priced risk in this corner.** BigCommerce publishes its thresholds. Shopify does not publish the revenue point at which Plus converts to a variable platform fee. A merchant who models cost at today's revenue rather than 3× today's revenue will be surprised on both — but only one of them said so in advance.

### No-code app builders

Bubble, Softr, Glide, Airtable Interfaces and Retool build **applications behind a login**. The boundary is not a matter of taste — it's a rendering fact.

| Tool | Metered unit | Rendering | Search-indexable? |
|---|---|---|---|
| **[Bubble](https://bubble.io/pricing)** | **Workload Units** — $0.30 per 1,000 overage. Starter $32/mo ($29 annual) web-only, up to Team $649/mo web+mobile | client-side SPA *(own observation — `bubble.io/pricing` returns an empty shell as static HTML, and bubble.io is itself built on Bubble; vendor docs are silent)* | effectively no |
| **[Softr](https://www.softr.io/pricing)** | **authenticated app users** — 10 / 20 / 100 / 500 by tier. Free · Basic $49/mo · Professional $139 · Business $269 | ⬜ not documented | **Yes, by design** — per-page index toggle, canonical URLs, per-record SEO with custom slugs, auto `/sitemap.xml` |
| **[Glide](https://www.glideapps.com/pricing)** | **updates** — $0.02 each beyond allowance, plus published-app count. Business **$199/mo** | irrelevant | **No — indexing is blocked at the platform level** |
| **[Airtable Interfaces](https://www.airtable.com/pricing)** | **seats** — Team $20/user/mo annual, Business $45 | client-side *(inferred)* | No — no meta, sitemap, canonical or custom-domain surface exists |
| **[Retool](https://retool.com/pricing)** | **builders AND internal users AND external users, simultaneously** — Team €9/builder + €5/user; Business €46 + €14; external users €7.33 → €3.60/mo on a volume schedule | **client-side — staff-confirmed** | **No** |

> [!CAUTION]
> **Two vendors say the quiet part out loud, and it settles the boundary.**
>
> **Glide** blocks search indexing deliberately: *"Glide now prevents apps from being indexed by search engines"*, described as *"a fundamental security measure within the platform"* because most users build private internal apps. Glide's own recommended workaround: ***"the best way would be to create a website that can be SEO-optimized and highlight your Glide app in the content of that website."*** The vendor is telling you to build a separate website. This applies **regardless of custom domain** — which, note, is gated at **$199/mo Business** anyway.
>
> **Retool** staff acknowledged in its community forum that public Retool pages cannot be indexed **because Retool is client-side rendered**, with no control over metadata or Open Graph tags. A user's summary: ***"google just sees a blank page."*** Staff response: *"I have logged it internally, I will update this thread if that changes."* No timeline.

> [!IMPORTANT]
> **The clean rule: a tool whose bill grows with your readership is not a website tool.** Website builders charge per site. These charge per workload unit, per authenticated user, per update, per seat, or per builder-plus-user-plus-external-user at once. Every one of those meters scales with usage or audience — which is precisely what you want a website to grow. A page with 10,000 readers is free on every website builder here and a five-figure monthly bill on Retool's external-user schedule.
>
> Reach for this family when the thing is **behind a login, has a bounded known audience, and holds state users mutate** — a portal, an admin panel, a directory, an internal ops console. **Softr is the only one that belongs near a Wix/Squarespace comparison**, and even then it competes on *gated portals with public marketing pages attached*, not on content sites.

## Capability comparison matrices

**How to use these.** Read **across a row** for "if I pick X, what am I giving up?" Read **down a column** for "who competes on this capability?" These are within-family comparisons — do not read across families.

**Legend:** ✅ first-class · 🟨 present but limited, gated to a high tier, or shallow · ⬜ not offered · ⬛ unknown at snapshot date

**Columns.** **CMS** — structured content collections · **Code** — custom HTML/CSS/JS injection · **Export** — get your markup out · **Backend** — server-side logic or API · **Stage** — staging/preview environment · **Git** — a real version-control workflow · **i18n** — multilingual/localization · **Store** — ecommerce · **Redir** — 301 redirect management · **Schema** — structured data · **A11y** — accessibility tooling beyond "you can write good HTML" · **Consent** — built-in cookie-consent manager

### Mainstream all-in-one

| Tool | CMS | Code | Export | Backend | Stage | Git | i18n | Store | Redir | Schema | A11y | Consent |
|---|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
| **Wix** | ✅ | ✅ | ⬜ | ✅ Velo | 🟨 | ⬜ | ✅ | ✅ | ✅ | ⬛ | 🟨 wizard | ✅ |
| **Squarespace** | 🟨 | 🟨 above Basic | 🟨 lossy XML | ⬜ | 🟨 | ✅ **Dev Mode** | ⬜ | ✅ | ✅ wildcards | ⬛ | ⬜ | ✅ |
| **Duda** | ✅ | ✅ | ✅ **Agency tier** | ✅ REST API | ⬛ | ⬜ | 🟨 | ✅ | ⬛ | ✅ | ⬜ | ⬛ |
| **Hostinger** | 🟨 | ✅ | ⬜ | ⬜ | ⬜ | ⬜ | 🟨 | ✅ 0% fee | ⬛ | ⬛ | ⬜ | ⬛ |
| **GoDaddy** | 🟨 | 🟥 **iframed** | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ✅ | ⬛ | ⬛ | ⬜ | ⬛ |
| **IONOS** | 🟨 | 🟨 not all plans | ⬜ | ⬜ | ⬜ | ⬜ | 🟨 | ✅ | ⬛ | ⬜ | ⬜ | ⬛ |
| **Jimdo** | 🟨 | 🟥 no embed (simple editor) | ⬜ | ⬜ | ⬜ | ⬜ | 🟨 | ✅ | ⬜ | ⬜ | ⬜ | 🟨 EU legal texts |
| **Site123** | 🟨 | 🟨 paid tiers | ⬜ | ⬜ | ⬜ | ⬜ | 🟨 paid | ✅ Pro+ | ⬛ | ⬛ | ⬜ | ⬛ |
| **Square Online** | 🟨 | ⬛ | ⬛ | ⬜ | ⬜ | ⬜ | ⬛ | ✅ | ⬛ | ⬛ | ⬜ | ⬛ |
| **Google Sites** | ⬜ | 🟨 embeds only | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ |

### Designer-first & portfolio

| Tool | CMS | Code | Export | Backend | Stage | Git | i18n | Store | Redir | Schema | A11y | Consent |
|---|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
| **Webflow** | ✅ | ✅ | 🟨 **no CMS content** | ✅ Webflow Cloud | ✅ | ✅ via Cloud | 🟨 $9–29/locale | ✅ | ✅ | 🟨 custom code | 🟨 audit panel | ⬜ **3rd-party only** |
| **Framer** | ✅ | 🟨 React components | ⬜ **none, by policy** | ⬜ | ✅ Pro | ⬜ | 🟨 $20/locale, **no hreflang** | 🟨 | ✅ Pro+ | 🟨 custom code | ⬜ | ⬛ |
| **Webstudio** | 🟨 external only | ✅ | ✅ **Remix/React app** | ✅ via integrations | ✅ Pro | ✅ | ⬛ | ⬜ | ✅ | ✅ all tiers | ⬜ | ⬛ |
| **Dorik** | ✅ | ✅ | ✅ claimed all tiers ⬛ | ⬜ | ⬛ | ⬜ | ⬛ | ✅ | ⬛ | ⬛ | ⬜ | ⬛ |
| **Readymag** | ⬜ | ✅ | 🟨 **Advanced tier, frozen JSON** | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | 🟥 canvas layout | ⬜ |
| **Cargo** | ⬜ | 🟨 CSS/HTML | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ✅ 0% fee | ⬜ | ⬜ | ⬜ | ⬜ |
| **Semplice** | ✅ WordPress | ✅ | ✅ **it's your server** | ✅ | ✅ | ✅ | ✅ | ✅ Woo | ✅ | ✅ | 🟨 | ✅ plugins |
| **Pixpa** | 🟨 | ✅ | 🟨 bulk gallery | ⬜ | ⬜ | ⬜ | ⬛ | ✅ 0% fee | ✅ | ✅ | ⬜ | ⬛ |
| **Format** | 🟨 | ⬛ | ⬜ | ⬜ | ⬜ | ⬜ | ⬛ | ✅ 0% fee | ⬛ | ⬛ | ⬜ | ⬛ |
| **Adobe Portfolio** | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬛ | ⬛ | ⬜ | ⬜ |
| **Carrd** | ⬜ | ✅ | ✅ Pro Plus | ⬜ | ⬜ | ⬜ | ⬜ | 🟨 | ✅ Pro Plus | ⬜ | ⬜ | ⬜ |
| **Super.so** | ✅ Notion | ✅ Personal+ | ⬜ | ⬜ | 🟨 Pro | ⬜ | ✅ Pro | ⬜ | ✅ Pro | ⬛ | ⬜ | ⬜ |

### Open-source, self-hostable & WordPress

| Tool | CMS | Code | Export | Backend | Stage | Git | i18n | Store | Redir | Schema | Native SEO |
|---|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
| **WordPress + Gutenberg** | ✅ | ✅ | ✅ | ✅ | 🟨 host | 🟨 code only | ✅ | ✅ Woo | ✅ plugin | ✅ plugin | ⬜ **plugin** |
| **WordPress + Elementor** | ✅ | ✅ | 🟥 **JSON in postmeta** | ✅ | 🟨 host | ⬜ | ✅ | ✅ | ✅ plugin | ✅ plugin | ⬜ **plugin** |
| **WordPress + Divi** | ✅ | ✅ | 🟥🟥 **shortcodes in content** | ✅ | 🟨 host | ⬜ | ✅ | ✅ | ✅ plugin | ✅ plugin | ⬜ **plugin** |
| **WordPress + Bricks** | ✅ | ✅ | 🟥 postmeta | ✅ | 🟨 host | ⬜ | ✅ | ✅ | ✅ plugin | ✅ plugin | ⬜ **plugin** |
| **WordPress + Beaver** | ✅ | ✅ | 🟩 **clean HTML in content** | ✅ | 🟨 host | ⬜ | ✅ | ✅ | ✅ plugin | ✅ plugin | ⬜ **plugin** |
| **Ghost** | 🟨 posts/pages | ✅ Handlebars | ✅ **MIT + JSON export** | ✅ APIs | ⬜ | ✅ themes | 🟨 | 🟨 memberships | ✅ | ✅ | ✅ **best-in-class** |
| **Webstudio** | 🟨 external | ✅ | ✅ | ✅ | ✅ Pro | ✅ | ⬛ | ⬜ | ✅ | ✅ | ✅ |
| **Silex** | 🟨 external | ✅ | ✅ | ⬜ | ⬜ | ✅ | ⬛ | ⬜ | 🟨 | 🟨 DIY | 🟨 static |
| **Publii** | ✅ local | ✅ | ✅ static HTML | ⬜ | ⬜ | 🟨 | ⬛ | ⬜ | 🟨 | ✅ | ✅ **strong** |
| **Craft / Statamic / Kirby** | ✅ | ✅ | ✅ **files/DB are yours** | ✅ | ✅ | ✅ **best** | ✅ | ✅ addon | ✅ | ✅ template | ⬜ addon |
| **Astro/Hugo + Sveltia** | ✅ Markdown | ✅ | ✅ **it's a git repo** | ✅ your code | ✅ | ✅ **best** | ✅ | 🟨 Ecwid/Snipcart | ✅ | ✅ | ✅ your code |
| **Tilda** | ✅ | ✅ | 🟨 **Business tier only** | ⬜ | ⬜ | ⬜ | 🟨 | ✅ | ⬛ | ✅ | ✅ |
| **Plasmic** | ✅ | ✅ | ✅ eject to React | ✅ your app | ✅ | ✅ | ⬛ | 🟨 | ✅ your code | ✅ your code | ✅ your code |

### AI-first

| Tool | Emits | Export | SSR / indexable | Credit model | Real CMS for a client |
|---|---|:-:|:-:|---|:-:|
| **Lovable** | Vite+React+TS+Tailwind+shadcn, Supabase backend | ✅ **continuous git sync** | 🟨 SSR **only for projects from 2026-05-13** | abstract credits, 0.50–2.00/msg | ⬜ |
| **Bolt.new** | Vite / Next project | ✅ **ZIP + GitHub, best in family** | 🟨 depends what you scaffolded | raw token budgets | ⬜ |
| **v0** | Next.js App Router / RSC | ✅ `npx v0 add` into your repo | ✅ **best by construction** | dollar-denominated tokens | ⬜ |
| **Replit** | any stack | ✅ ZIP + GitHub, re-importable | ⬜ no platform SEO layer | effort-based credits + separate deploy billing | ⬜ |
| **Base44** | React + `base44-sdk` backend | 🟥 **frontend only, Builder+ tier** | ⬛ | **dual currency — your users burn credits too** | ⬜ |
| **10Web** | **real WordPress** | ✅ **full — it's WordPress** | ✅ **server-rendered PHP** | ~1 credit per site generation; **visitor caps are the real ceiling** | ✅ |
| **Hostinger Horizons** | Node/React/Vite | 🟨 **Hobbyist tier, one-way** | ⬛ | credits per tier | ⬜ |
| **Durable** | proprietary | ⬜ **none** | 🟨 | five separate quotas | 🟨 |
| **Figma Sites/Make** | proprietary | ⬜ **"does not support code export"** | 🟥 **"does not currently offer specific customizability for SEO"** | seat-attached AI credits | ⬜ |

## Lock-in and exit — what "you own your site" actually means

The single question with the widest variance in the category, and the one nobody asks before signing up.

| Platform | Design / code export | Content export | What you actually own |
|---|---|---|---|
| **WordPress self-hosted**, Craft, Statamic, Kirby, Astro+git | ✅ Full | ✅ Full | **Everything.** It's your filesystem and your database. |
| **Ghost** | ✅ MIT, Handlebars themes are files | ✅ JSON export + CSV members | Everything. Pro→self-host migration is an import. |
| **Webstudio** | ✅ **Remix/React app** (dynamic) or static HTML | ✅ your external CMS never left | Everything. Export is on the **free** tier. |
| **Duda** | ✅ zip of HTML/CSS/JS/images — **Agency tier ($52/mo)** | 🟨 Store as CSV, Blog as `.rss` | A static snapshot. **Dynamic pages and password protection excluded**; Duda won't support it after. |
| **Readymag** | 🟨 **Advanced tier** — HTML + **JSON rendered by JS** + mandatory server config | 🟨 in the archive | A **frozen, non-editable artefact**. *"Exported projects cannot be changed."* OG/SEO tags export **only for the first page**. |
| **Webflow** | 🟨 static HTML/CSS/JS — **needs a paid Workspace** | ⬜ **CMS excluded**; per-collection CSV separately | The **markup, not the machine**. No CMS, no forms, no search, no ecommerce, no memberships, no localization — and **password protection is stripped, so protected pages become public**. |
| **Tilda** | 🟨 static HTML — **Business tier only** | 🟨 in the export | A snapshot. And on lapse: **site unpublished, data deleted after 6 months.** |
| **Shopify** | 🟨 Liquid theme downloadable; **paid theme licences are store-bound** | 🟨 CSV for products/customers/orders — **but images export as URLs pointing back at Shopify's CDN**, and >100-variant products get emailed | The **commercial data**, not the storefront. App data (reviews, subscriptions, loyalty) lives in the app vendor's DB and never appears. |
| **Squarespace** | ⬜ No code/design export; **custom CSS and style settings excluded** | 🟨 WordPress-format XML, **one blog page only** | A **lossy XML of one blog.** Store, portfolio, index, album, calendar, cover and info pages don't export. *"It's not possible to export content from one Squarespace site and import it into another."* |
| **Framer** | ⬜ **"Framer does not offer HTML export for self-hosting"** | ✅ CMS Export plugin → CSV/JSON, plus a CMS API | **The content, and nothing else.** Exit = export CMS, rebuild the front end from scratch. |
| **Wix** | ⬜ *"it needs to be hosted and operated on Wix's servers"* | 🟨 blog/contacts/store via individual product tools | **The domain.** That is the only genuinely portable asset. |
| **IONOS** | ⬜ *"cannot be used outside the IONOS infrastructure"* — vendor recommends **HTTrack** | ⬜ | Nothing. And image-pool licences *"are not transferable"*. |
| **GoDaddy**, **Site123**, **Jimdo**, **Cargo**, **Format**, **Adobe Portfolio**, **Durable**, **Typedream**, **Universe**, **Figma Sites** | ⬜ | ⬜ or partial | Nothing beyond your own source assets. |

> [!IMPORTANT]
> **The one rule to take away: if a builder's export excludes CMS content, the export is a mockup, not a migration.** Webflow's export is the case that catches people — it exists, it's advertised, it produces real HTML, and it leaves every Collection List rendering its empty state. Ranked honestly, "you own your site" means: **self-hosted WordPress / Craft / Statamic / Kirby / Astro** (own everything) → **Ghost, Webstudio** (own everything, hosted for convenience) → **Duda Agency, Readymag Advanced** (own a runnable but frozen artefact) → **Webflow** (own the static shell) → **Shopify** (own the data, rent the storefront) → **Squarespace** (own a lossy XML of one blog) → **Wix ≈ Framer ≈ IONOS** (own the domain).

## SEO capability by construction

Some SEO limitations are configuration. Others are baked into how the platform renders or routes, and no amount of tier upgrading fixes them.

| Handicap | Who | Detail |
|---|---|---|
| **Forced URL prefix on posts** | **Wix** (`/post/`), **Squarespace** (blog-page slug) | Wix documents the slug as editable; the `/post/` segment is not addressed as changeable. Squarespace post URLs always begin with the Blog Page slug — renameable, not removable. |
| **Forced URL prefix, sitewide** | **Shopify** | `/products/`, `/collections/`, `/pages/` are mandatory. No `.htaccess`, no rewriting, no hierarchical category paths, no root-level product URLs. Shopify also auto-generates a second product URL inside the collection path. Only escape: Plus + headless. *(Agency/consultancy sources, consistent across independents.)* |
| **Canonical not editable** | **Squarespace** | Emitted automatically, cannot be overridden *(community-reported)*. |
| **Canonical gated to Enterprise** | **Framer** | *(secondary)*. Framer's own SEO feature list omits canonical and hreflang entirely. |
| **No native hreflang** | **Squarespace**, **Framer** | Squarespace needs code injection or Weglot. Framer sells localization at $20/locale **without hreflang**. |
| **Localization breaks export** | **Webflow** | Localized pages, elements and content are excluded from code export. |
| **JS-dependent content** | **Readymag**, **legacy Lovable projects**, **Bubble**, **Retool**, **Airtable Interfaces** | Readymag's export encodes content as JSON rendered by JS with "SEO snippets for crawlers" as a shim. Lovable projects predating 2026-05-13 get pre-rendering **served only to verified crawlers** — third-party SEO tools see the SPA shell. |
| **Indexing blocked at the platform** | **Glide** | Deliberate. *"a fundamental security measure within the platform."* |
| **Head custom code paywalled** | **Webflow** | Site-wide head code — needed for canonical overrides, consent managers, schema — is unavailable on the free Starter plan. |
| **No 301 redirects at all** | **Durable**, **Jimdo** (simple editor), **Google Sites** | Disqualifying for any migration in either direction. |
| **Structural duplicate content** | **Google Sites** | Every page lives at both `sites.google.com/...` and your custom domain, with **no canonical tag** to disambiguate. |

> [!TIP]
> **A reputation correction worth making.** The old claim that "Wix is bad for SEO because it's JS-rendered" no longer holds. Wix posts the **highest mobile Core Web Vitals pass rate** of the major platforms and exposes an editable `robots.txt`, per-page `noindex`, and a managed sitemap. Its remaining SEO constraint is **structural** (the `/post/` prefix), not rendering.
>
> The genuinely weak SEO stories in this review are, roughly in order: **Google Sites** (no meta description, no robots.txt, no sitemap control since March 2021, no canonical, structural duplicate URLs), **Jimdo's simple editor** (homepage title only *(single secondary source — verify)*), **Figma Sites** (*"does not currently offer specific customizability for SEO optimization"* — vendor's own words), **Durable** (no redirects, no schema, no heading control), **Cargo** (two fields: Tags and Description), and **Readymag** (client-rendered with a crawler shim; indexing takes *"several days up to a month"* by the vendor's own admission).
>
> And note the uncomfortable pattern in the [performance data](#performance--core-web-vitals-by-platform): **the platforms that score best on Core Web Vitals are the ones that give you the least control.** High CWV is partly a *symptom* of lock-in, not independent of it.

## Accessibility and the European Accessibility Act

**The statute.** Directive (EU) 2019/882. Covered services per the European Commission include banking, e-books, transport, audio-visual media and **e-commerce**. ⬜ **The directive text itself could not be retrieved** — EUR-Lex returned empty responses to every fetch attempt — so the following are **secondary-sourced and should be verified against the statute before you rely on them**: applicable from **28 June 2025**, with new services complying from launch and existing services having until **June 2030**; a microenterprise exemption below **10 employees and €2m turnover/balance sheet**; and the operative technical benchmark being **WCAG 2.1 AA** via harmonised standard **EN 301 549** (WCAG 2.2 exists but is not yet incorporated).

**What the builders actually claim:**

| Vendor | Claim | Reality |
|---|---|---|
| **Wix** | *"comply with the highest global standards (WCAG 2.0)"* — **2.0, with no conformance level named**. Ships an Accessibility Wizard that scans and gives remediation steps. | Its own page: *"You are responsible for making sure the content and design are also accessible"* and ***"Wix cannot guarantee or ensure that the use of our services is compliant with all accessibility laws and worldwide regulations."*** **No EAA mention anywhere.** |
| **Webflow** | Three-way split: sites built in Webflow — most-used elements *"conform to levels as high as WCAG 2.1 Level AA"*; Webflow's own marketing sites *"aim to adhere"* to 2.1 AA; **the Designer itself "does not fully support assistive technology."** | *"When building an accessible site, the power lies in the hands of the builder."* **No EN 301 549, no VPAT, no EAA.** Third-party assessment: keyboard operability and screen-reader support are **not on by default**. |
| **Squarespace** | **No WCAG level claimed, no VPAT, no EAA mention.** | ***"You are responsible for ensuring that your site complies"*** and ***"Because Squarespace users have a lot of creative freedom, they also have the ability to build websites that are not always accessible by all."*** Directs users to external WCAG resources. |
| **Framer** | ⬜ No accessibility statement located. | The `data-nosnippet` control in "accessibility settings of any layer" is an SEO directive, not an accessibility feature. |

> [!IMPORTANT]
> **For an EU-facing buyer at snapshot date: no major website builder claims EAA conformance, and none claims to deliver a conformant site by default.** Every vendor examined has an explicit disclaimer transferring responsibility to the site owner. The strongest claim in the category — Webflow's *"as high as WCAG 2.1 Level AA"* — is element-scoped, not site-scoped, and undermined by Webflow's own admission that the Designer is not assistive-technology accessible (which matters if your *content editors* have disabilities). **Wix's claim is against WCAG 2.0, a standard superseded twice and below the EN 301 549 / EAA benchmark.** An EU e-commerce buyer above the microenterprise threshold cannot rely on any platform's defaults and must budget for an independent audit.
>
> Two design choices carry accessibility consequences worth naming: **Readymag and Cargo's absolutely-positioned canvas layouts** mean DOM order need not match visual order, and **GoDaddy's iframed custom-HTML block** isolates embedded content from assistive technology as well as from crawlers.

> [!CAUTION]
> **Do not solve this with an accessibility overlay.** The **FTC ordered accessiBe to pay $1,000,000** — announced 2025-01-03, final order approved April 2025 — over claims that accessWidget could *"automatically comply"* with WCAG 2.1 AA within 48 hours. The FTC alleged the claim was false and that **accessWidget itself created significant accessibility barriers** for users with disabilities, and that accessiBe formatted paid reviews to look independent. The final order **bars accessiBe from claiming its automated products can make any website WCAG-compliant** absent supporting evidence ([FTC](https://www.ftc.gov/news-events/news/press-releases/2025/01/ftc-order-requires-online-marketer-pay-1-million-deceptive-claims-its-ai-product-could-make-websites)).
>
> **And overlays do not reduce litigation.** UsableNet's data: **5,114 ADA digital accessibility lawsuits filed in the US in 2025, +20% YoY** — with **659 filed against companies already running an accessibility widget**, rising month over month. eCommerce was **70%** of all filings ([UsableNet](https://blog.usablenet.com/ada-web-lawsuit-trends-2026)).
>
> Relevance here: accessiBe ships first-party integrations for **Wix, Squarespace and Webflow**, and much of the "make your Wix site ADA compliant" content ranking in search is overlay-vendor marketing. **A buyer searching for a fix will land on the exact product the FTC fined.**

## GDPR, data residency and cookie consent

| Vendor | Where data lives | EU-only residency | Transfer mechanism | Built-in consent tool |
|---|---|:-:|---|:-:|
| **Wix** | US and Ireland; visitor data may also sit in **South Korea, Taiwan and Israel** | ❌ | SCCs plus additional safeguards; notes Israel's EU adequacy finding | ✅ **Yes** — cookie banner via the Privacy Center, opt-in for non-essential; plus visitor data-access and deletion tooling and a DPA incorporating SCCs |
| **Squarespace** | US; transfers to the US and other third countries | ❌ | **SCCs + UK IDTA + EU–U.S. Data Privacy Framework**; DPA **auto-accepted with the ToS** | ✅ **Yes** — configurable banner, opt-in or opt-in-and-out, Accept/Manage/Decline buttons; **Google Analytics and Meta Pixel consent modes auto-integrated** |
| **Webflow** | **United States only** — AWS + Fastly | ❌ **Explicitly not offered** (open wishlist items since 2021) | Certified under EU–U.S. DPF, Swiss–U.S. DPF and the UK Extension; DPA incorporates EU SCCs and the UK IDTA | ❌ **No native consent manager.** Scripts fire on page load unless a third-party CMP intercepts. Requires Consent Pro / CookieHub / Usercentrics / Finsweet — **and site-wide head code needs a paid Site plan** |
| **Framer** | ⬜ | ⬜ | ⬜ | ⬜ |
| **Shopify** | ⬜ — `shopify.com/legal/privacy/data-storage` returned 404 | ⬜ | ⬜ | ⬜ |

> [!IMPORTANT]
> **Two asymmetries a European buyer should price in.**
>
> **(1)** Wix and Squarespace ship consent as a **platform feature**; **Webflow makes it a procurement line item and a plan gate**. The true monthly cost of a Webflow site serving EU visitors includes a CMP subscription *and* a paid Site plan to install it.
>
> **(2) None of the three offers EU-only data residency.** For a public-sector or institutional EU client with strict residency requirements, **all three are structurally disqualified regardless of consent tooling and regardless of tier**. That is not a feature you can buy — it's a reason to be in [Family 4](#family-4--wordpress-and-the-open-source--self-hostable-corner), on infrastructure you choose.

## Performance — Core Web Vitals by platform

Primary source: the [HTTP Archive Core Web Vitals Technology Report](https://httparchive.org/reports/techreport/tech), which joins real-user CrUX field data with HTTP Archive technology detection. ⬜ The dashboard is client-rendered and its public API host is undocumented, so raw JSON could not be pulled at snapshot date — the figures below are **secondary readings of that dataset** and should be re-pulled before you rely on them.

**November 2025, mobile, % of origins passing all three CWV:**

| Platform | Pass rate | Note |
|---|---:|---|
| **Duda** | **84.9%** | Highest in the dataset; Duda markets CWV as a differentiator. |
| **Wix** | **74.9%** | INP 86.82%. **+23pp in ~19 months** — the largest platform improvement in the data. |
| **Squarespace** | **70.4%** | INP **95.85%** — best in class on interactivity. |
| **WordPress** | **46.3%** | INP 85.89%. Weakness is concentrated in **LCP/loading**, not interactivity. |

*Web-wide baseline for context: 48% of mobile origins and 56% of desktop origins pass all three; mobile has climbed 32% (2021) → 36% (2023) → 48% (2025) ([Web Almanac 2025](https://almanac.httparchive.org/en/2025/performance)).*

⬜ **Webflow, Framer and Shopify pass rates are unverified**; two secondary sources disagree materially, and one aggregator's May-2026 numbers are inconsistent with the November-2025 figures above. Do not publish a Webflow or Framer CWV number without re-pulling from HTTP Archive.

Three caveats that matter more than the numbers:

1. **These are platform-population medians, not what your site will do.** WordPress's 46% reflects an install base spanning $3/mo shared hosting with 40 plugins. A WordPress site on managed hosting with a lean theme beats most Squarespace sites.
2. **The causality is unflattering to freedom.** Duda, Wix and Squarespace score best because they centrally control theme rendering, image delivery and hosting. **High CWV is partly a symptom of lock-in.**
3. **WordPress's gap is purchasable.** Its INP is within 10pp of Wix's; the deficit is hosting and asset delivery, both of which you can buy.

⬜ **Per-WordPress-builder CWV pass rates are not published by HTTP Archive** — only market share is. The community consensus ordering (Bricks fastest, Elementor middling, Divi weakest) is benchmark folklore, not measured population data, and **Divi 5's February 2026 rewrite may have invalidated the Divi half of it.**

## Market shape, consolidation and platform risk

**Share** ([W3Techs](https://w3techs.com/technologies/overview/content_management), survey date **2026-07-27** — matching this snapshot exactly):

| Platform | % of all websites | % of sites using a known CMS |
|---|---:|---:|
| WordPress | **41.2%** | 59.1% |
| Shopify | **5.3%** | 7.6% |
| Wix | **4.3%** | 6.1% |
| Squarespace | **2.5%** | 3.5% |
| Joomla | 1.2% | 1.7% |
| Webflow | **0.8%** | 1.2% |
| Duda | **0.7%** | 1.1% |
| Drupal | 0.7% | 1.0% |
| Ghost | 0.1% | 0.1% |
| **No detectable CMS** | **30.4%** | — |

> [!NOTE]
> **Methodology caveat.** W3Techs measures the top 10 million sites by traffic rank, so it over-weights the long tail and under-weights enterprise. BuiltWith and Datanyze produce materially different numbers from different panels. **"Market share" in this category is three incompatible datasets wearing one label.** One aggregator argues the growing "no detectable CMS" bucket partly reflects AI/prompt-to-site builders and Framer shipping static output that fingerprints as no CMS — plausible, but a **hypothesis, not data**.

**Consolidation and decay, 2023–2026:**

| Event | Date | Detail |
|---|---|---|
| **Zyro folded into Hostinger** | announced Dec 2023, merged **April 2024** | Standalone Zyro discontinued; accounts, domains and sites migrated; **dormant accounts deleted Feb 2024**. Any 2026 "Zyro review" is a Hostinger review with a stale title. |
| **Editor X → Wix Studio** | announced Oct 2023, new-site creation ended Apr 2024, **transition completed Jan 2025** | Brand retired, entire installed base **auto-migrated**, zero downtime — but several features became view-only-and-deletable-but-not-re-addable. |
| **Webflow acquires Intellimize** | **2024-04-19** | AI personalisation / CRO. Repositioning from "site builder" to *"Website Experience Platform."* |
| **Squarespace taken private by Permira** | announced 2024-05-13, closed Q4 2024 | **$44.00/share, ~$6.6bn equity / ~$6.9bn enterprise value**, a 29% premium to 90-day VWAP. Founder Casalena rolled over and stayed. **Followed by a price rise of up to 26% in July 2026.** |
| **Wix acquires Base44** | **2025-06-18** | **~$80M cash** plus earn-outs through 2029, plus ~$25M retention bonuses. Base44 was **~6 months old**, solo-founded, ~250,000 users. The clearest signal that incumbents treat prompt-to-site as existential. |
| **Payload acquired by Figma** | **2025-06-17** | Whole team joined. Repo reportedly stays MIT; roadmap gravity now points at Figma Sites. |
| **Weebly** | ongoing | Not formally shut down, but signups closed, mobile app pulled, forum closed, **no new feature or theme in over a year**. Square walked back an earlier July-2026 support-floor statement. Treat as end-of-life risk. |
| **Divi 5** | out of beta **2026-02-26** | Ground-up rewrite; one-click migrator; Divi 4 supported ≥12 months. |
| **Webflow pricing reset** | **2026-05-13** | CMS + Business merged into Premium; Team tier added; **ex-Business bandwidth halved and compute cut 5×**. |
| **Webflow legacy Editor + whitelabeling retired** | **2026-08-04** | Agencies lose the ability to remove Webflow branding from the client editor. |
| **Wix Harmony** | **2026-01-21** | Agentic AI editor; ⬜ pricing not stated in the announcement. |
| **Framer 3.0** | **2026-06-16** | Agents, Branching, External Agents (Claude Code / Codex / Cursor / Gemini CLI). |
| **Builder.ai collapse** | 2025 | **$450M+ raised, once valued over $1B**, into insolvency amid reporting that its "AI" leaned heavily on human engineers. The cautionary tale for the AI-builder family. |

> [!WARNING]
> **The forward risk for a buyer is not that a builder disappears. It's the Editor X pattern:** your product gets rebranded into the vendor's next-generation editor, migration is automatic and irreversible, and a handful of features you depend on become view-only. Editor X went from "announced sunset" to "entire installed base force-migrated" in about nine months, and Wix's own FAQ lists features that existing sites keep but **cannot recreate once deleted**.
>
> Related signals worth weighing on a five-year horizon: **private-equity ownership at Squarespace** (26% price rise 20 months after the buyout, announced by email with no changelog); **IONOS's 2026 price adjustment on existing contracts**, notified by email with a PDF and **no figures published anywhere public**; **Dorik selling lifetime licences alongside subscriptions**; **Adobe Portfolio's product page and both helpx FAQ URLs returning 404**; **Popsy's origin server being down**; and **Potion's marketing site 404ing** on the day of this snapshot.
>
> **A note on a shutdown that didn't happen:** the 2023 "Universe shutdown" stories refer to a **K-pop fan platform of the same name** (NCSOFT, closed 2023-02-17), not the website builder. Universe the builder is live. Similarly, **Google Web Designer is not discontinued** — it's an HTML5 *ad* authoring tool, actively maintained; only old versions were retired. The confusion likely comes from Google sunsetting **Ads Creative Studio** in March 2025.

## When NOT to use a website builder

> [!IMPORTANT]
> **There is no credible independent data on the cost crossover between a builder and custom development.** Every source that surfaces is either an agency selling custom development ("after 2–3 years custom is cheaper") or a builder selling subscriptions. This article will not launder agency numbers into a crossover point. **The honest case against a builder is structural, not financial**, and every item below is a constraint verified above.

1. **You need more than ~20,000 content items.** Webflow hard-caps at 20,000 CMS items on Premium, and community reports say the cap does not lift even on Enterprise. Framer caps at 40,000 on Pro *with paid add-ons*. An SSG plus a headless CMS has no such ceiling.
2. **You need EU data residency.** Wix, Squarespace and Webflow all store data in the US, and **none offers an EU-only option at any tier**. Hard disqualification for many EU public-sector and institutional buyers.
3. **You need a native consent manager and you're on Webflow.** There isn't one; scripts fire before consent by default; installing a CMP requires a paid Site plan.
4. **You need control of your URL structure.** Shopify's `/products/`, `/collections/`, `/pages/`; Wix's `/post/`; Squarespace's blog-slug prefix. If your information architecture or a migration's redirect map depends on arbitrary paths, the platform will fight you forever.
5. **You need an exit.** Framer and Wix: no export at all, by explicit vendor policy. IONOS: no export, and the vendor suggests HTTrack. Squarespace: one blog page, no styling. Webflow: no CMS content. **If a future migration is foreseeable, the cheap subscription is buying a debt.**
6. **You need editor accessibility.** Webflow states its own Designer *"does not fully support assistive technology"* — a blocker if your content team includes assistive-technology users.
7. **You're a team, and the seat axis inverts the economics.** Webflow at three seats is ~$152/mo before add-ons; the "$15/mo" headline is one person publishing one site.
8. **Your traffic is spiky.** Webflow auto-upgrades your plan after two consecutive over-bandwidth months and **will not refund**. On Framer there is no overage billing at all — community reports say the site goes offline. **A viral post converts into a permanent price increase, or an outage.**
9. **Your organisation reviews changes through pull requests.** Content in `wp_postmeta` or a vendor's database cannot be branched, diffed or code-reviewed. Only Craft (project config as YAML), Statamic, Kirby and the Astro/Hugo + git-CMS stacks make a content change a reviewable commit.
10. **The thing is behind a login with mutable state.** You wanted an [app builder](#no-code-app-builders), or an actual application.

## Which builder for which job — decision table

| Your situation | Pick | Why | Watch out for |
|---|---|---|---|
| **Marketing site, professional team, SEO matters, budget exists** | **Webflow** | The only tool with high design freedom *and* full SEO control *and* a code escape hatch. | The [two-axis bill](#two-axis-pricing--site-plans--seats) — budget ~$152/mo for three people, not $15. No native consent manager. US-only data. |
| **Marketing site, design-led, small team, motion matters** | **Framer** | Best motion story; agentic editing; genuinely good SSG + SEO. | **Zero code export, by policy.** No hreflang. Bandwidth overage has no billing — the site can go offline. |
| **Freelancer or small agency, many client sites** | **Webstudio** ($15/mo unlimited) or **Duda Agency** ($52/mo + $17/site) | Webstudio is 1–2 orders of magnitude cheaper than Webflow at 10 sites and exports a real Remix app. Duda has the best measured performance and a white-label tier. | Webstudio is **beta** and has no built-in CMS. Duda's export is Agency-tier-only and drops store/blog/dynamic pages. |
| **Small business, no technical staff, one vendor for everything** | **Squarespace** or **Wix** | Squarespace for design; Wix for extensibility (Velo), the better SEO panel and the top CWV score. | Squarespace: **7% digital-goods fee on Basic**, one-way plan migration, PE-owned with a 26% rise in July 2026. Wix: **template lock-in from site creation**, and no export ever. |
| **You sell digital products or memberships** | **Not Squarespace Basic** | The 7% fee on Basic and 5% on Core dwarfs any plan saving. | Model the fee schedule before the plan price. Ghost takes 0%; Cargo takes 0%; Pixpa takes 0%. |
| **Newsletter + paid memberships + blog** | **Ghost** (self-hosted at $7–12/mo, or Pro at $18) | Best native SEO with no plugin, 0% transaction fee, ActivityPub, native cookie-free analytics. | The **$29 → $199/mo member cliff** at 1,000 members. Paid subscriptions need Publisher. Self-hosting loses analytics and easy ActivityPub. |
| **Content site you want to own outright, technical team** | **Astro/Hugo + Sveltia CMS + Cloudflare Pages** | **$0/mo**, static HTML, content is Markdown in git, unlimited scale, perfect SEO control. | You maintain it. No bookings/CRM/store out of the box. |
| **You need a real CMS and a pull-request workflow** | **Statamic**, **Kirby** or **Craft** | Content as files or project config as YAML in git. **Perpetual licences** — the software never stops working. | Per-site licensing. You supply hosting. SEO is an addon (SEO Pro / SEOmatic). |
| **WordPress, and you may drop the builder later** | **Beaver Builder** | The only WP builder that writes **clean HTML into `post_content`** — deactivate and you get readable content, not shortcode soup or an empty page. | Worst price-per-site at the low end ($89 for one site vs Divi's $89 for unlimited). |
| **WordPress, many sites, tight budget** | **Divi** ($89/yr unlimited) or **Breakdance** (free, unlimited sites) | Cheapest per-site licence in the category. Breakdance adds an **indefinite price lock** and a lapse policy that costs you nothing. | **Divi stores shortcodes in `post_content`** — the worst lock-in of any builder here. |
| **WordPress, performance-critical** | **Bricks** | The best CWV reputation of the WP builders; a real class/variable system; MCP support in 2.4-beta. | 0.34% market share — thin contractor pool. Had an actively-exploited unauthenticated RCE in Feb 2024. |
| **Photographer / artist portfolio** | **Pixpa** (if search matters) or **Cargo** (if it doesn't) | Pixpa has schema markup, **301 redirects** and bulk gallery export — the only portfolio platform you can leave with your URLs. Cargo is $14/mo flat, unlimited subdomain sites, 0% commission, the most honest pricing page here. | Cargo's SEO surface is **two fields**. Format has no export of any kind and a billing-complaint history. |
| **Designer who wants to own the portfolio forever** | **Semplice** ($119–699 once, on your WordPress) | Highest SEO ceiling and lowest lock-in of any commercial product in this review. | You run WordPress. Documentation-only support. No refunds. |
| **Campaign microsite, art-directed, one-off** | **Readymag** | Nothing else does editorial canvas layout as well. | **Pageview caps** (75,000/mo even at $58.50). Export is Advanced-tier and produces a frozen JSON artefact. Poor for organic search. |
| **Landing page or link-in-bio** | **Carrd** ($19/yr for 10 sites) | Nothing else is close on price. | Not a CMS. Redirects and site download need Pro Plus ($49/yr). |
| **You live in Notion and want it public** | **Super.so** | Serves optimized static HTML, not the Notion SPA. | Three separate bills (site + seats + analytics). **Potion is 404ing and Popsy's origin is down** as of this snapshot. |
| **Prompt-to-site, and it must rank** | **10Web** | The only AI builder emitting **server-rendered WordPress** you can export, plugin, and rehost freely. | Visitor caps (10K–200K/mo) are the real ceiling. Agency Core has a 7% billing fee. |
| **Prompt-to-app, and you want the repo** | **Bolt.new** or **Lovable** | Both emit standard Vite/React projects; Bolt has one-click ZIP + GitHub, Lovable has continuous git sync. | You are billed for the model's failures. Read the [security section](#security--the-familys-systemic-failure) before putting user data in one. |
| **Real store, hundreds of SKUs, order operations** | **Shopify** or **BigCommerce** | Order ops, not the storefront, is the product. | Shopify's **third-party gateway penalty** (2% on Basic). BigCommerce's **automatic GMV tier bumps** at $30K/$100K TTM. |
| **You have a site and want to add a cart** | **Ecwid** ($5–149/mo) | **Zero transaction fees**, metered on product count not GMV, designed as a bolt-on. | The Instant Site is a storefront, not a CMS. |
| **EU public sector, data residency required** | **None of the hosted builders** | Wix, Squarespace and Webflow are all US-hosted with no EU-only option at any tier. | Go to [Family 4](#family-4--wordpress-and-the-open-source--self-hostable-corner) on infrastructure you choose. |
| **Internal tool behind a login** | **Not a website builder** | See [no-code app builders](#no-code-app-builders). | Their bills scale with your audience. Glide blocks indexing outright. |

## Discovery & method

**How the candidate list was assembled.** Starting from the three tools named in the brief (Webflow, Wix, Readymag), the field was widened by: W3Techs and HTTP Archive CMS-share tables (to catch anything with real installed base); the "alternatives to X" surface for each of Webflow, Framer and Wix; GitHub topic searches for open-source builders; Hex-equivalent registry browsing for the WordPress builder market via HTTP Archive's technology detection; and the 2025–2026 AI-builder wave via funding and acquisition coverage. Tools were included if they *build and publish a website*; excluded if they only build applications, designs, or wireframes — with the excluded categories reviewed anyway in [Adjacent categories](#adjacent-categories--what-these-are-not) precisely because readers confuse them.

**How prices were verified.** Vendor pricing page first; vendor help centre and changelog second; vendor press releases for dates and acquisitions; and only then secondary sources, always labelled. Where two secondary sources disagreed, both figures are shown. Where a vendor's page failed to render prices, that failure is documented rather than papered over with a listicle number.

**Known verification gaps at snapshot date** — these are the specific things to re-check before relying on them:

- **Elementor's prices** — the largest builder in the world does not serve prices in HTML. Its own meta description says "$49/year"; listings say $59.
- **All GoDaddy figures** — 403 to every automated request, and two secondary sources conflict.
- **Site123 tier prices** — three sources span $8.28 to $60 for comparable tiers.
- **Wix and Squarespace USD monthly-billed rates** — neither publishes both rate cards; some figures used are EUR from third parties.
- **Relume's pricing** — sources span $16 to "$250+" and disagree on the pricing model.
- **Builder.io per-seat prices** — not rendered; third-party figures mutually inconsistent.
- **The EAA statute text** — EUR-Lex returned empty responses; application dates and thresholds are secondary-sourced.
- **Core Web Vitals for Webflow, Framer and Shopify** — unverified, sources disagree; re-pull from HTTP Archive.
- **Framer's "Traffic-aware Pre-Rendering"** — the vendor article 404s on every slug tried, and it is load-bearing for Framer's SEO claim.
- **Shopify data residency** — the vendor's own data-storage page 404s.
- **Craft Cloud, Decap Turbo, Strapi self-hosted Enterprise, Payload Enterprise, Directus Enterprise, Elementor Hosting, Ycode's licence** — unpublished or unfetchable.
- **IONOS's 2026 price adjustment magnitude** — deliberately unpublished.

## Cross-links

- [**Application types — what kind of thing are you building?**](README.md) — the prior decision. If you haven't established that the artifact is a website rather than a web app, PWA, desktop or mobile app, start there.
- [**Choosing a web-presence stack**](choosing-a-web-presence-stack.md) — the decision *between* this article's tiers and the ones past them: off-the-shelf builder vs visual development platform vs SSG + git CMS vs framework + headless CMS vs custom application, keyed by organizational capacity rather than feature lists. Read it if you're not yet sure a hosted builder is the right category at all — and for the break-even analysis showing where plugin and add-on costs stop being cheaper than building.
- [**SEO**](../marketing/seo.md) — everything in [SEO capability by construction](#seo-capability-by-construction) assumes you know what you're optimising for. The keyword-research and technical-SEO workflows live there.
- [**Analytics**](../marketing/analytics.md) — the measurement side, including the self-hosted PostHog resource warning. Several builders ship first-party analytics (Ghost 6.0, Super, Duda) that may remove a line item.
- [**UX resources & tools**](../design/ux.md) — a builder decides what your site *can* look like; UX decides whether it converts.
- [**Authentication**](../authentication.md) — relevant the moment your site has member areas, gated content or a store login.
- [**Building desktop apps**](desktop.md) · [**Building mobile apps**](mobile.md) — the sibling surveys for the other artifact types.
- [**Recent incidents in major technologies**](../industry-watch/recent-incidents.md) — the [AI-builder security section](#security--the-familys-systemic-failure) is a live example of the incident class tracked there.
- [**Navigating ecosystems**](../industry-watch/navigating-ecosystems.md) — the discovery techniques used to assemble this candidate list.
