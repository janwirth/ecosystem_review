# Choosing a web-presence stack — from Wix to a custom application

> [!NOTE]
> **Status:** DRAFT · **Authoring:** AI-assisted, human-reviewed.

> *You know you're building a [website](README.md#website). You've seen [what the builders cost](website-builders.md). This article is about the question underneath both: **how much machinery does your organisation actually need, and how much can it carry?***

**Snapshot 2026-07-27** — prices verified at snapshot date; see [the pricing warning in the builders article](website-builders.md#a-warning-about-the-prices-in-this-article), which applies here too.

## Table of Contents

1. [The question this article answers](#the-question-this-article-answers)
2. [The spectrum — five tiers](#the-spectrum--five-tiers)
3. [The two axes that actually decide it](#the-two-axes-that-actually-decide-it)
4. [Tier 1 — Off-the-shelf builders](#tier-1--off-the-shelf-builders)
5. [Tier 2 — Visual development platforms](#tier-2--visual-development-platforms)
6. [Tier 3 — Static site generator + git-based CMS](#tier-3--static-site-generator--git-based-cms)
7. [Tier 4 — Server-rendered framework + headless CMS](#tier-4--server-rendered-framework--headless-cms)
8. [Tier 5 — Custom application](#tier-5--custom-application)
9. [Pick by organizational need and capacity](#pick-by-organizational-need-and-capacity)
10. [The counter-intuitive case — no technical staff does not mean Tier 1](#the-counter-intuitive-case--no-technical-staff-does-not-mean-tier-1)
11. [The break-even — when off-the-shelf stops being cheaper](#the-break-even--when-off-the-shelf-stops-being-cheaper)
12. [One-way doors and migration paths](#one-way-doors-and-migration-paths)
13. [Cross-links](#cross-links)

## The question this article answers

Three articles in this folder answer three different questions, in order:

1. **[Application types](README.md)** — *what kind of artifact ships?* Website, web app, PWA, desktop, mobile.
2. **This article** — *given that it's a website, how much machinery does it need, and who will run it?*
3. **[Website builders](website-builders.md)** — *given a tier, which specific product, and what will it really cost?*

Skipping step 2 is the most expensive mistake in the sequence, and it goes wrong in both directions:

- **Over-building.** A five-page brochure site for a company with no engineers gets built as a Next.js app on Vercel with a headless CMS, because that's what the contractor knows. Eighteen months later nobody can change the opening hours without a deploy, the contractor is gone, the dependencies have rotted, and the CMS free tier has become a $300/month bill.
- **Under-building.** A site with four content editors, an approval step, two languages and a members-only area gets built on an off-the-shelf builder because "it's just a website." Two years later it's a plan tier nobody predicted, six plugin subscriptions, a workflow that runs on someone remembering not to publish before Legal replies, and a platform you [can't export from](website-builders.md#lock-in-and-exit--what-you-own-your-site-actually-means).

Both failures come from picking on the wrong variable. Teams pick on **what the site should do**, when the binding constraint is almost always **who will still be maintaining it in three years, and what they can do unsupervised.**

## The spectrum — five tiers

| Tier | What it is | Editing model | Who maintains it | Realistic all-in cost | Ceiling |
|---|---|---|---|---|---|
| **[1 — Off-the-shelf builder](#tier-1--off-the-shelf-builders)** | Wix, Squarespace, Duda, Hostinger, GoDaddy | Visual editor in the browser, live | Anyone in the org | **$10–50/mo** | Structural — the platform's feature set is the ceiling, and there is no escape hatch |
| **[2 — Visual development platform](#tier-2--visual-development-platforms)** | Webflow, Framer, Webstudio | Visual editor with real CSS + a CMS | A designer or a marketing team; agencies | **$15–150+/mo** | CMS item caps, seat costs, per-locale add-ons, [partial-or-no export](website-builders.md#lock-in-and-exit--what-you-own-your-site-actually-means) |
| **[3 — SSG + git-based CMS](#tier-3--static-site-generator--git-based-cms)** | Astro, Hugo, Eleventy, Hakyll + Sveltia/Decap/CloudCannon | Web form that writes a git commit | Non-technical editors day-to-day; a technical person for structure | **$0–50/mo** | No per-request server logic, no authenticated per-user state |
| **[4 — Framework + headless CMS](#tier-4--server-rendered-framework--headless-cms)** | Next.js, Nuxt, SvelteKit, Astro-SSR + Sanity/Storyblok/Payload | CMS UI, decoupled from the frontend | Requires a developer, permanently | **$50–500+/mo** | You now run software; the ceiling is your team, not the tool |
| **[5 — Custom application](#tier-5--custom-application)** | Your own app, any stack | Whatever you build | A development team, permanently | **build cost + maintenance forever** | None — and that's the problem |

Two things about this table that matter more than the rows:

- **The cost column is not the decision.** The gap between Tier 1 and Tier 5 in *subscription* terms is trivial next to the gap in *labour* terms. Tier 1 costs $30/month and zero staff. Tier 5 costs $30/month in hosting and a fraction of a developer forever. **The salary line is the real price**, and it never appears on a pricing page.
- **The tiers are not a maturity ladder.** Nobody "graduates" from Tier 1 to Tier 5. A 200-person company with a brochure site should be on Tier 1 or 3. A two-person startup selling a subscription product needs Tier 5 for the product and probably Tier 1 for the marketing site. **Most organisations should be on more than one tier at once** — see [Split the site](#split-the-site-before-you-upgrade-it).

## The two axes that actually decide it

Not "how big is the company." Two axes:

**Axis 1 — Organizational capacity: who will change this, unsupervised, in three years?**

| Level | Description |
|---|---|
| **A. Nobody technical, ever** | The person editing is a business owner, an office manager, a volunteer. If it breaks, there is no one in the building who can fix it. |
| **B. Non-technical but procedure-following** | Will happily follow a written checklist, use a web form, click "Publish". Will not open a terminal. Can be taught one workflow and will keep doing it. |
| **C. One technical person, part-time** | A founder who codes, a freelancer on retainer, an IT generalist. Can deploy, can read a stack trace, is not available on demand. |
| **D. A development team** | Someone is paid to maintain this. There is a code review process and an on-call story. |

**Axis 2 — Requirement shape: what must the site actually do?**

| Level | Description |
|---|---|
| **i. Publish** | Pages, images, contact form. Changes are occasional and made by one person. |
| **ii. Publish frequently, by several people** | A blog, events, news. Multiple editors. **This is where a CMS stops being optional.** |
| **iii. Publish under governance** | Roles, draft/review/approve, scheduled publishing, audit trail, multiple languages. |
| **iv. Serve per-user state** | Logins, member areas, customer portals, dashboards, anything where two visitors see different data. |
| **v. Be the product** | The website *is* the application. |

**The grid:**

| | **i. Publish** | **ii. Frequent, multi-editor** | **iii. Governed** | **iv. Per-user state** | **v. Is the product** |
|---|---|---|---|---|---|
| **A. Nobody technical** | **Tier 1** | **Tier 1** | Tier 1 + accept the gaps, or buy the service | **Buy a SaaS**, don't build | Don't |
| **B. Procedure-following** | **Tier 1** or **Tier 3** | **Tier 1**, or **Tier 3** with a git CMS | Tier 2 or 4 — needs someone to set it up | Buy a SaaS, or Tier 4 with help | Don't |
| **C. One technical person** | **Tier 3** | **Tier 3** | **Tier 4** | **Tier 4** | Tier 5 — but honestly assess bus factor |
| **D. A development team** | Tier 1 or 3 — **do not spend the team on this** | Tier 3 or 4 | **Tier 4** | **Tier 4 or 5** | **Tier 5** |

> [!IMPORTANT]
> **Read the diagonal, not the corners.** The two most common real-world mistakes are both off-diagonal:
>
> **Bottom-left** — a team of engineers builds the brochure site in the framework they use for the product. It works, it's beautiful, and it consumes engineering time forever on a page nobody edits. *If you have a development team and a Tier-i requirement, the correct answer is still a builder or an SSG.* Spend the team on the product.
>
> **Top-right** — an organisation with no technical capacity commits to governed multi-role publishing or per-user state on an off-the-shelf builder, because the pricing page implies it's included. It isn't, quite, and the gap gets filled with plugins and human process. See [the break-even](#the-break-even--when-off-the-shelf-stops-being-cheaper).

### Two things that are not on either axis

**Company size.** A 300-person manufacturer with a 12-page site and no marketing team belongs on Tier 1. A three-person agency with daily case-study publishing and four editors belongs on Tier 3 or 4. Headcount predicts nothing here.

**Design ambition.** Every tier can look good. Tier 1 constrains layout more than the others, and Tier 2 exists precisely because designers hit that wall — but "we want it to look distinctive" is a Tier 1→2 argument, not a Tier 1→4 argument. Wanting a custom look is not a reason to need a framework. This confusion is expensive and common.

## Tier 1 — Off-the-shelf builders

**Wix · Squarespace · Duda · Hostinger · IONOS · GoDaddy · Jimdo · Site123 · Google Sites**

Full per-vendor reviews, pricing and gotchas: **[Website builders → mainstream all-in-one](website-builders.md#family-1--mainstream-all-in-one-builders)**.

**What you're buying.** One vendor for the editor, hosting, domain, TLS, backups, uptime, a store, email marketing, and a support line. The product design assumes you will never want the HTML — which is a feature, not an oversight, because *nobody in a Level-A organisation should be responsible for the HTML.*

**What it costs.** $10–50/month for the plan, plus the parts nobody budgets: the domain after year one, professional email (~$6/user/month — **not** included on Wix), App Market subscriptions at $3–20/month each, and [transaction fees](website-builders.md#transaction-fees--the-second-price-list) if you sell anything.

**The real ceiling isn't features — it's three structural limits.**

1. **Governance.** Editor seats are capped by tier (Wix: 2/5/10/100; Squarespace: 2 contributors on Basic, unlimited above). More importantly, **approval workflows barely exist**. You can restrict who can edit; you generally cannot express "Marketing drafts it, Legal approves it, it publishes on Tuesday." That gap gets filled by a human remembering — which is fine at two editors and a liability at eight.
2. **Per-user state.** Member areas exist on most Tier 1 platforms and are shallow. The moment "logged-in users see their own data" means *their* invoices, *their* bookings, *their* order history joined against a system you already run, you have left the tier. Not "you should upgrade" — you have left it.
3. **The exit.** Wix, GoDaddy, IONOS, Jimdo and Site123 have **no code export at all**. Squarespace exports [a lossy XML of one blog page](website-builders.md#lock-in-and-exit--what-you-own-your-site-actually-means). Duda exports properly but only on its $52/month Agency tier. Tier 1 is the tier where "we'll migrate later" is most often said and least often possible.

> [!TIP]
> **Tier 1 is the right answer far more often than technical people want it to be.** For a Level-A or Level-B organisation with a publish-shaped requirement, it is not a compromise — it is the correct engineering decision, because *the maintenance burden is zero and that is the scarcest resource in the room.* The failure mode of Tier 1 is not that it's limiting; it's that people stay on it two years after the requirement changed, paying for plugins to simulate a tier they should have moved to.

**Leave Tier 1 when:** you need real editorial governance · you need per-user data · you need URL structures the platform won't give you ([Wix forces `/post/`](website-builders.md#seo-capability-by-construction), Shopify forces `/products/`) · you need EU data residency (**none of Wix, Squarespace or Webflow offer it at any tier**) · or the plugin bill has started climbing (see [the break-even](#the-break-even--when-off-the-shelf-stops-being-cheaper)).

## Tier 2 — Visual development platforms

**Webflow · Framer · Webstudio**

Full reviews: **[Website builders → designer-first](website-builders.md#family-2--designer-first--visual-development-builders)**.

**What you're buying.** Real CSS control, a structured CMS, staging, and output that a professional would recognise as a website rather than a template instance. Webflow additionally gives you [a genuine code escape hatch](website-builders.md#webflow-) — Webflow Cloud hosts Next.js/Astro from a linked GitHub repo, and DevLink pulls components into an external React codebase.

**What it actually costs — and this is the tier where the sticker price lies hardest.** Webflow bills on [two axes](website-builders.md#two-axis-pricing--site-plans--seats): site plan **plus** workspace **plus** per-seat. One person publishing one CMS site is $44/month against a $25 headline. Three people is **$152/month**. Framer does the same at different weights: $30 site plan plus **$20/month per additional editor**, plus **$20 per translation locale**.

**Who this tier is really for.** Two distinct buyers, and it's worth knowing which you are:

- **A design-led marketing team** that wants control over how the site looks and a CMS the marketers can use. This is Webflow's core market and it serves it better than anything else.
- **An agency or freelancer** building for clients. Here the economics invert — the *site* axis multiplies, not the seat axis, and it gets expensive fast. Ten client sites on Webflow is $250+/month in site plans before workspace and seats. **[Webstudio at $15/month for unlimited sites](website-builders.md#webstudio-) is one to two orders of magnitude cheaper for exactly this shape**, exports a real Remix/React application, and is open source — at the cost of being officially beta and having no built-in CMS.

**The ceiling.** CMS item caps (Webflow: 20,000 on Premium, community-reported as not lifting even on Enterprise). Localization as a paid per-locale add-on. **No native cookie-consent manager on Webflow** — you buy a CMP *and* a paid site plan to install it. And on the exit: Framer has **no code export at all, by explicit policy**; Webflow's export omits all CMS content, so [it's a mockup, not a migration](website-builders.md#lock-in-and-exit--what-you-own-your-site-actually-means).

> [!WARNING]
> **Tier 2 does not solve the governance problem either, and it's frequently bought as though it does.** Webflow and Framer both give you seats and roles. Neither gives you a draft → review → approve → schedule pipeline with an audit trail. If governance is the requirement that pushed you off Tier 1, **Tier 2 is a lateral move that costs more** — you want Tier 3 (where review is a pull request) or Tier 4 (where the CMS has workflow states). Buy Tier 2 for *design control* and *CMS structure*, not for process.

## Tier 3 — Static site generator + git-based CMS

**Astro · Hugo · Eleventy · Jekyll · Hakyll · Zola** + **Sveltia · Decap · Keystatic · CloudCannon · TinaCMS**

**What you're buying.** The site is a folder of Markdown and templates in a git repository. A build step turns it into HTML. A CDN serves it. The "CMS" is a web form that writes a git commit on the editor's behalf — so **content changes are reviewable commits**, and the site has no server to break, no database to back up, and no plugin to patch on a Tuesday.

**What it costs.** Hosting is genuinely **$0** for most company sites — Cloudflare Pages' free tier is unlimited sites, unlimited bandwidth, unlimited static requests, 100 custom domains per project and 500 builds/month. The generator is free. The only recurring line is the editing layer, and only if your editors can't use git directly.

**Why it's the most under-used tier.** It sits at the exact point where cost is near-zero, portability is total, performance is best-in-class, and SEO control is complete — and it gets skipped because "static" sounds like a limitation and "git" sounds like it needs engineers. Both readings are wrong, and [the next section](#the-counter-intuitive-case--no-technical-staff-does-not-mean-tier-1) is about why.

**The ceiling is real and worth stating precisely.** No per-request server logic. No authenticated per-user state. A contact form needs a third-party endpoint (Formspree, Netlify Forms, a Worker). Search needs a client-side index (Pagefind, Lunr) or a hosted service. **Anything where two visitors must see different data is out of tier** — that's the line, and it's a clean one.

**Rebuild latency** is the other practical limit: a content change triggers a build. That's seconds for Astro/Eleventy on a small site, minutes on a large Hugo site, and it means "fix the typo in the next 10 seconds" is not a promise you can make. For most company sites this is irrelevant. For a newsroom it isn't.

### On Hakyll specifically

[Hakyll](https://hackage.haskell.org/package/hakyll) is a Haskell static-site *library* — you write `site.hs` and compile your own generator, xmonad-style, with Pandoc doing the document conversion. Status at snapshot date: **4.17.0.0, released 2026-04-30**; **BSD-3-Clause** per Hackage (GitHub's licence detector reports `NOASSERTION`, which is a detection failure, not a licensing ambiguity); 2,865 stars, 122 open issues, single primary maintainer since 2009, last push 2026-07-22, commits roughly monthly.

> [!NOTE]
> **Read that as healthy-but-thin, and choose accordingly.** Hakyll works, it is maintained, and it produces exactly the small hand-shaped output this tier is good at. But it is a library with no CLI, no theme ecosystem, no plugin market, and **no path for a non-technical editor to plug a git CMS into it**. Choosing it means the site's maintainability is bounded by the availability of someone who writes Haskell — a far narrower hiring pool than Hugo, Astro or Eleventy. That is a legitimate trade if the person maintaining it is a Haskell programmer and expects to remain one. It is a bad trade made on aesthetics.
>
> The same reasoning generalises: **at this tier, pick the generator by who can maintain it, not by which one you enjoy.** Hugo and Astro are the safe defaults precisely because the hiring pool is deep.

### The editing layer — and the thing that recently broke

The differentiator between git CMSes is **not** the editing UI. They all have one, and they're all fine. It is **whether your editor needs a GitHub account, and who runs the OAuth broker.**

> [!CAUTION]
> **The classic recipe for this tier is deprecated.** "Deploy Decap CMS to Netlify, enable Identity + Git Gateway, invite the client by email" was the standard way to give a non-technical editor a login without a GitHub account. Netlify's own docs now state: *"Git Gateway is deprecated. While Git Gateway continues to function for sites that currently have it enabled, **new Git Gateway configurations are not recommended**. While we will keep fixing any major security issues that arise, we will no longer fix bugs in the functionality of Git Gateway"* ([Netlify docs](https://docs.netlify.com/manage/security/secure-access-to-sites/git-gateway/)) — **with no recommended replacement offered.**
>
> If you are following a tutorial written before this, it will appear to work and will be building on deprecated infrastructure. Use one of the paths below instead.

| Editing layer | Editor needs a git account? | Cost | Verdict for a non-technical editor |
|---|:-:|---|---|
| **[Keystatic](https://keystatic.com/docs/cloud) + Keystatic Cloud** | **No** — Cloud exists explicitly to allow *"team members to edit content without needing a GitHub account"*, and removes the custom GitHub-App setup | Keystatic free/OSS (⬜ licence not stated on that page). **Cloud Free: 3 users per team.** Pro **from $10/mo per team + $5/user/mo** | ✅ **Best default.** Zero-config for the developer, no git account for the editor. |
| **[Decap](https://decapcms.org) + [DecapBridge](https://decapbridge.com/)** | **No** — email invites plus Google/Microsoft social login | Decap free. **DecapBridge free: 3 sites, 10 collaborators/site.** Pro **$9/mo** unlimited; **lifetime $199** incl. commercial self-hosting | ✅ **Best value at scale.** Purpose-built to replace exactly the Git-Gateway hole. |
| **[CloudCannon](https://cloudcannon.com/pricing)** | No | **$49/mo** annual (3 users, unlimited sites); +$10/user, **+$2/mo per custom domain** | ✅ The managed, supported, visual-editing option. The only one here with real WYSIWYG over an SSG. |
| **[TinaCMS](https://tina.io/pricing)** | No | Free (2 users) · Team **$24/mo** · Business $249/mo — **priced per project** | 🟨 Fine, but per-project pricing punishes agencies. |
| **[Sveltia](https://github.com/sveltia/sveltia-cms)** | **Yes** (git-provider OAuth) | Free, **MIT** | 🟨 Excellent software — drop-in Decap-config-compatible, 2.6k stars, actively developed, already used by US government sites. But **the editor needs a git account**, so it fits Level C, not Level A/B. |
| **[Pages CMS](https://pagescms.org)** | **Yes, in practice** — GitHub App integration, no documented email-invite path | Hosted instance free; self-host needs **PostgreSQL + a configured GitHub App + migrations** | ⬜ Not for the non-technical case. |
| **[Front Matter CMS](https://frontmatter.codes/docs)** | n/a — **it's a VS Code extension** | Free | ❌ **Disqualified here.** The editor would need VS Code and a cloned repo. Its own docs frame it as for developers. |

## Tier 4 — Server-rendered framework + headless CMS

**Next.js · Nuxt · SvelteKit · Astro (SSR mode) · Remix** + **Sanity · Storyblok · Prismic · Contentful · Hygraph · Payload**

**What you're buying.** A real runtime. Per-request logic, authenticated sessions, personalisation, API integration, incremental static regeneration, and a CMS with editorial workflow states that a marketing team uses without touching the repo. This is the first tier where "logged-in users see their own data" is comfortably in scope.

**What you're taking on: you now run software, permanently.** Dependency upgrades, framework major versions, a build pipeline, a hosting bill with usage components, and someone who understands all of it. **The subscription cost is the smallest part of the total.**

### Hosting — the cost model diverges by an order of magnitude

For the same static-ish marketing site at 1M pageviews/month (~15 requests and ~1.5 MB per view):

| Host | Model | ~1M pageviews/mo |
|---|---|---|
| **[Cloudflare Workers/Pages](https://developers.cloudflare.com/workers/platform/pricing/)** | $5/mo min; 10M requests included, +$0.30/M; **static assets free and unlimited**, and *"there are no additional charges for data transfer (egress) or throughput (bandwidth)"* | **$0–5** |
| **[Vercel Pro](https://vercel.com/docs/plans/pro)** | $20/mo platform fee incl. 1 seat + $20 usage credit; **1 TB transfer** and **10M edge requests** included; then $0.15–0.35/GB and $2.00–3.20 per 1M requests | **~$85–105** *(derived, not a vendor quote)* |
| **[Netlify Pro](https://www.netlify.com/pricing/)** | $20/mo for 3,000 **credits**; bandwidth **20 credits/GB** | **~$195+** *(derived)* |
| **[DigitalOcean Droplet](https://www.digitalocean.com/pricing/droplets)** | $6/mo for 1 GiB / 1 vCPU / **1,000 GB transfer**; $12 for 2 GiB / 2,000 GB | **$6–24** + you operate it |

At **100k** pageviews Vercel is just the **$20 platform fee** — the scary unit prices never fire. Note that Netlify has replaced published bandwidth allowances with credits, so you can no longer read a bandwidth number off its pricing page.

> [!WARNING]
> **Vercel bill shock is real, and it does not come from traffic.** It comes from **page count × revalidation frequency × function invocations**. A community write-up reports a **$4,700/month** bill on a Next.js monorepo with ~90% of it from three lines: ISR revalidation across **50,000 product pages** at 3 ISR calls per update (*"a $200/month estimate became $2,800"*), edge functions making 8 parallel service calls per request, and image optimization across 10,000 user images at multiple sizes. The author reports ending at **$287/month** after moving ISR to Cloudflare Pages + KV and functions to Workers *(community-reported, single author, not independently verified)*.
>
> The lesson generalises past Vercel: **at Tier 4 your bill is a function of your architecture, not your audience.** Model the meter — ISR writes, function invocations, image transforms — before you commit, and set a spend cap. Vercel's default spend-notification threshold for new customers is **$200 per billing cycle**, which is a notification, not a cap.

### Headless CMS — and the pattern nobody warns you about

| CMS | Free tier | First paid tier | **Workflows / approvals gated at** | **Custom roles gated at** |
|---|---|---|---|---|
| **[Sanity](https://www.sanity.io/pricing)** | $0, **20 seats**, 10k docs, 2 roles | **$15/seat/mo** (to 50 seats), 5 roles | **Content Releases → Enterprise** | **Enterprise** |
| **[Storyblok](https://www.storyblok.com/pricing)** | $0, **1 user** (max 2, +$15 each) | **Growth $99/mo**, 5 users, +$15/user to 10 | ✅ **Growth — the only published self-serve price for approval workflows** | **Premium/Elite (unpublished)** |
| **[Prismic](https://prismic.io/pricing)** | $0, **1 user** | Starter **$10/mo** (3 users) → Medium **$150/mo** (25 users) | ✅ Releases + scheduled publishing **on every tier including Free** | **User roles → Medium ($150/mo)**; custom roles → Enterprise |
| **[Hygraph](https://hygraph.com/pricing)** | $0, 3 seats, 1k entries | **Growth $199/mo**, 10 seats | **Enterprise** | **Enterprise** |
| **[Contentful](https://www.contentful.com/pricing/)** | €0, 10 users, **2 roles** | **Lite €300/mo**, 20 users, 3 roles | **Enterprise** | **Enterprise** |
| **[Payload](https://payloadcms.com)** | **Self-hosted free forever, MIT** | Enterprise, sales-quoted | Enterprise | Enterprise |
| **[Kontent.ai](https://kontent.ai/pricing/)** | ⬜ | ⬜ | ⬜ | ⬜ |

> [!IMPORTANT]
> **The trap, stated plainly: across five of six vendors, editorial workflow and custom roles are precisely the two features held back for Enterprise — and those are precisely the two features that made you outgrow Tier 1 in the first place.**
>
> Hygraph: workflows require **$199/mo → sales-quoted**. Contentful: **€300/mo → sales-quoted**. Sanity is the cheapest entry at $15/seat but gates Content Releases and custom roles at Enterprise. **Storyblok at $99/mo is the only vendor in this set that sells approval workflows at a published self-serve price** — and even there custom roles are Premium/Elite with no published price, and scheduled publishing is capped at **2 stories** on Growth. **Prismic** is the only one giving releases and scheduled publishing away on the free tier, but charges **$150/mo** before you get user roles at all.
>
> **If governance is your requirement, price the CMS first and the framework second** — it is the line item that will determine your bill, and the demo will not volunteer where the wall is.
>
> ⬜ **Kontent.ai publishes no prices at all** — verified twice; there is not a single `$` figure in 875 KB of served markup, only a savings-slider and a quote form under the copy *"No complicated tiers. No excessive add-ons. No unexpected price jumps."*

## Tier 5 — Custom application

**What you're buying.** No ceiling. Any requirement is implementable. That is the entire pitch, and it is also the whole risk: **the constraint that was protecting you is gone.**

**When it's genuinely correct:**

- **The website *is* the product.** SaaS, marketplaces, anything where the page and the application are the same artifact.
- **Per-user state that no SaaS models.** The todo's own example is the right shape: a **customer invoice access portal** — customers log in, see *their* invoices, joined against the accounting system you already run, with your access rules. No builder does this, no CMS does this, and the SaaS that does this generically will not match your ledger.
- **Deep integration with internal systems.** ERP, warehouse, scheduling, ticketing — where the site is a view onto systems of record.
- **Regulatory constraints no vendor satisfies.** Data residency is the common one: **none of Wix, Squarespace or Webflow offer EU-only hosting at any tier.**

**What it costs, honestly.** Hosting is the trivial part — the same $6–48/month Droplet. The cost is people.

The one solid primary figure available is the **[Stack Overflow Developer Survey 2025](https://survey.stackoverflow.co/2025/work/)** (49,000+ respondents; 23,928 supplied salary data), median annual **salary**:

| Role | Global | US | Germany | UK | India |
|---|---:|---:|---:|---:|---:|
| Back-end | $79,742 | $175,000 | $87,011 | $108,913 | $22,086 |
| Full-stack | $72,509 | $138,000 | $75,410 | $85,429 | $13,949 |
| Front-end | $62,015 | $145,000 | $79,637 | $84,544 | $10,462 |

Those are **employee salaries, not contractor day rates** — do not read them as quotes. As a rough internal-cost anchor: German full-stack median $75,410 over ~220 working days is ~$343/day at 1.0×, or roughly **$430–480/day fully loaded at 1.25–1.4×** *(this arithmetic is derived here, not a published figure)*.

> [!CAUTION]
> **On the "maintenance is 15–20% of build cost per year" rule of thumb: every source for it is an agency selling custom development or a maintenance retainer.** A full search returned eleven such sources and **not one neutral study with a described methodology**. They cite each other and "decades of enterprise data" without naming a dataset, and each sells the retainer the number justifies. **This article will not repeat that figure as fact.**
>
> What *does* have provenance is **Lientz & Swanson (1980)**, a survey of **487 data-processing organisations** ([CACM](https://dl.acm.org/doi/10.1145/358790.358796)), which found maintenance at **~50% of the software budget** and — the useful finding — that **~60% of maintenance effort was adaptive and perfective** rather than corrective. Note this is widely misquoted: the 60% is *"60% of maintenance is not bug-fixing"*, not *"60% of lifecycle cost is maintenance."*
>
> **Use the shape, not the percentage.** Most post-launch spend is not fixing bugs — it is dependency upgrades, platform migrations, and new requirements. **That is exactly the cost an off-the-shelf platform absorbs on your behalf and bills as a subscription, and exactly the cost a custom build transfers back to you.** Framed that way you don't need the contaminated number at all: the question isn't "what percent?", it's "who is doing the adaptive work in year three, and are they still here?"

## Pick by organizational need and capacity

Read down the left column to find the statement that is most true about your organisation. The rightmost column is the one that actually decides.

| If this is true of you | Tier | Why | The thing that will bite |
|---|---|---|---|
| **Nobody in the org is technical, and nobody will be** | **1** | Zero maintenance burden is worth more than any feature. | You can't leave. Pick a vendor with an export path ([Duda Agency](website-builders.md#duda-), or Squarespace's partial XML) if migration is even faintly foreseeable. |
| **One person edits the site a few times a year** | **1** or **3** | Both are near-zero effort. Tier 3 is cheaper and more portable; Tier 1 is faster to start. | On Tier 3, the *setup* needs a technical person once. Budget a day of someone's time, not zero. |
| **Content changes weekly or more, by more than one person** | **1** or **3** | **This is where a CMS stops being optional.** Frequency plus multiple authors is the CMS trigger — not site size. | Tier 1 seat caps (Squarespace: 2 contributors on Basic). On Tier 3, pick an editing layer whose *free* tier covers your editor count. |
| **Editors are non-technical but will follow a written procedure** | **3** | See [the next section](#the-counter-intuitive-case--no-technical-staff-does-not-mean-tier-1). A web form that writes a commit is not harder than Wix's editor. | Choose **Keystatic Cloud** or **Decap + DecapBridge** so the editor needs no git account. Do **not** use plain Decap + Netlify Git Gateway — it's deprecated. |
| **You need draft → review → approve → schedule, with an audit trail** | **4** (or **3**, see right) | Governance is a CMS-workflow feature, and Tiers 1–2 largely don't have it. | **This is the expensive requirement.** Price the CMS first: workflows are Enterprise-gated on Hygraph, Contentful and Sanity. **Storyblok Growth $99/mo** is the only published self-serve price for approval workflows. **But if your reviewers are comfortable with pull requests, Tier 3 gives you review, approval, audit trail and rollback for $0** — git already is a workflow engine. |
| **The site must be in several languages** | **1**, **3** or **4** | All are possible; the cost differs wildly. | Webflow charges **$9–29/mo per locale** and **excludes localized content from export**. Framer charges **$20/locale and has no hreflang**. WPML is **€99 first year** with no published renewal. Squarespace has **no native multilingual at all**. |
| **Logged-in users must see their own data** | **4** or **5** | You've left Tiers 1–3 by definition. | Before building: check whether a SaaS already does it. An invoice portal you buy beats an invoice portal you maintain, unless it must join against your own ledger. |
| **A custom internal workflow is the point** (invoice portal, booking against internal systems, member dashboard) | **5** | No off-the-shelf product models your business rules. | The build is the small half. Ask who does the [adaptive maintenance](#tier-5--custom-application) in year three. |
| **You have engineers, but the site is brochureware** | **1** or **3** | **Do not spend the team on this.** | The temptation to build it in the product's framework. It will work and it will cost engineering attention forever. |
| **You're an agency or freelancer running many client sites** | **2** or **3** | Per-*account* billing, not per-site. | Ten sites: **[Webstudio $15/mo](website-builders.md#webstudio-)** or **Cargo $32/mo** vs **Webflow $250+/mo**. Also: Webflow **retires agency whitelabeling on 2026-08-04**. |
| **You must host in the EU** | **3**, **4** or **5** | **Wix, Squarespace and Webflow are US-hosted with no EU-only option at any tier.** | Not buyable at any price. This alone disqualifies Tiers 1–2 for many public-sector and institutional buyers. |
| **You need to sell more than a handful of products** | **1** with a store, or a commerce platform | See [the ecommerce boundary](website-builders.md#ecommerce-platforms). | [Transaction fees](website-builders.md#transaction-fees--the-second-price-list) dominate plan price. **Squarespace Basic takes 7% on digital goods.** |
| **Traffic is spiky or you might go viral** | **3** (or **4** on Cloudflare) | Static on a CDN absorbs spikes for free. | **Webflow auto-upgrades your plan after two consecutive over-bandwidth months and will not refund. Framer has no overage billing — community reports say the site goes offline.** |
| **Budget is genuinely near zero and someone technical is available** | **3** | Astro/Hugo + Sveltia + Cloudflare Pages is **$0/month** plus a domain. | It's free in money and not free in attention. Someone must own upgrades. |

### Split the site before you upgrade it

The most common expensive mistake in this article is treating "the website" as one artifact that must sit in one tier. It usually shouldn't.

A company with a marketing site *and* a customer invoice portal has **two** requirements: Tier 1-or-3 publishing and Tier 5 per-user state. Building both in Tier 5 because of the portal means the marketing team files a ticket to change a headline, forever. **Run the marketing site on `www.example.com` in Tier 1 or 3, and the portal on `portal.example.com` in Tier 5.** Two artifacts, two maintenance stories, two tiers — and the marketing team gets its autonomy back.

This is the norm, not a compromise: most organisations should be on more than one tier at once. The question is never "what tier is my company" — it's "what tier is *this surface*."

## The counter-intuitive case — no technical staff does not mean Tier 1

The default reasoning runs: *no engineers → must use a hosted builder → Wix or Squarespace.* That reasoning is wrong often enough to be worth attacking directly.

**The observation this article is built on** *(supplied by the author from direct experience, not independently verified here)*: **a yoga studio runs its own site on a static site generator, editing content through GitHub, with no technical staff.** The author's cited example of the pattern is **[werdewechsel.de](https://werdewechsel.de)**, described by the author as a **[Hakyll](https://hackage.haskell.org/package/hakyll)** site.

> [!NOTE]
> **What is independently verifiable about werdewechsel.de at snapshot date:** it is a German-language one-person consultancy site (training, coaching and yoga), served over HTTP/2 from **Netlify**, **5,774 bytes of hand-shaped static HTML**, one stylesheet, two images, **no JavaScript bundle**, extensionless clean URLs, exactly five `<meta>` tags, and **no `<meta name="generator">` of any kind**. No public source repository was found.
>
> That is fully consistent with Hakyll — which emits no generator tag and produces exactly this kind of small hand-templated output — but **consistency is not confirmation**, and this review could not confirm the generator independently. The Hakyll attribution here rests on the author's own knowledge of the site, which is a better source than fingerprinting; it is flagged only so the claim's provenance is clear.

**Why the pattern works, when it does.** The assumption buried in "non-technical people need a hosted builder" is that *editing must be effortless*. But the real requirement is narrower: editing must be **learnable once and repeatable**. A person who can be taught "open this page, click Edit, type, click Publish" can be taught that whether the form is Wix's editor or [Keystatic](https://keystatic.com/docs/cloud). Neither requires understanding what happens next.

What the SSG path buys such an organisation is substantial:

- **The bill is ~$0/month instead of $30**, which matters more to a yoga studio than to anyone reading a pricing page thinks it does.
- **Nothing rots.** No plugins to update, no PHP version to bump, no security patch cycle, no "your plan no longer includes this feature" email. A static site left alone for four years still works. A WordPress site left alone for four years is a liability.
- **The exit is free.** The content is Markdown in a repo. Every migration path stays open forever — which is the exact opposite of [Tier 1's lock-in](website-builders.md#lock-in-and-exit--what-you-own-your-site-actually-means).
- **Performance and SEO are best-in-class by default**, with no tier to upgrade to get them.

**What it actually requires, stated honestly — because this is where the pattern fails:**

1. **A technical person for the setup, once.** Repo, generator, templates, deploy pipeline, CMS wiring, editor accounts. A day, maybe two. This is not zero and pretending otherwise is how the pattern gets oversold.
2. **An editing layer that does not require the editor to hold a git account.** This is the load-bearing choice, and the ground moved recently — **[Netlify Git Gateway is deprecated with no replacement offered](https://docs.netlify.com/manage/security/secure-access-to-sites/git-gateway/)**, which kills the old standard recipe for new sites. The current honest options are **Keystatic Cloud** (free to 3 users; **$10/mo per team + $5/user** beyond) or **Decap + [DecapBridge](https://decapbridge.com/)** (free to 3 sites and 10 collaborators/site; **$9/mo** unlimited; **$199 lifetime**). **Sveltia, Pages CMS and Front Matter are excellent tools that do not fit this case** — the first two need a git account, and Front Matter is a VS Code extension.
3. **A named person who owns the site**, even if they never touch code — someone who knows who to call.
4. **Accepting the ceiling.** No logins, no per-user data, no instant publish. If the studio later wants a members' area with class bookings, that's a separate surface — see [Split the site](#split-the-site-before-you-upgrade-it).

> [!IMPORTANT]
> **The generalisable rule: the question is not "do we have engineers?" but "do we have one technical person for one day, and then a procedure-following editor forever?"** If the answer is yes, Tier 3 dominates Tier 1 on cost, portability, performance and longevity. If the answer is *no — there is genuinely nobody, not even for a day* — then **Tier 1 is correct and you should stop reading and go buy Squarespace.** That is a real and common situation and there is no shame in it.
>
> The failure mode to avoid is the middle: a Tier-3 site set up by a contractor who then disappears, with no editing layer configured and no named owner. That is worse than Wix, because now nobody can change the opening hours *and* nobody knows why.

## The break-even — when off-the-shelf stops being cheaper

The pitch for Tier 1 is that $30/month beats paying developers. It does — right up until the requirements grow a shape the platform doesn't have, at which point the gap gets filled with **plugins, add-on subscriptions, and human process**. Each of those is individually cheap and collectively not.

Here is the curve, with real prices.

### What a "simple website with governance" actually costs on WordPress

The scenario is deliberately unglamorous: a corporate site with **editorial workflow, several roles, two languages, gated content for partners, and real forms.** Nothing exotic. All prices are **annual, per-site-limited subscriptions**.

| Need | Plugin | First year | At renewal |
|---|---|---:|---:|
| Editorial workflow, roles, revisions, checklists | **[PublishPress](https://publishpress.com/pricing/)** Agency (5 sites, 5 team members) | $299 | $299 |
| Multilingual with translator roles + translation queue | **[WPML](https://wpml.org/purchase/)** Multilingual CMS | €99 | ⬜ **renewal price not published** |
| Forms with user registration and partial entries | **[Gravity Forms](https://www.gravityforms.com/pricing/)** Pro (3 sites) | $159 | $159 |
| Gated partner content / memberships | **[MemberPress](https://memberpress.com/plans/pricing/)** Growth | $314.55 | **$699** |
| CRM/role sync | **[WP Fusion](https://wpfusion.com/pricing/)** Plus | $427 | $427 |
| | **Total** | **≈ $1,300** | **≈ $1,700–1,800** |

**Plus hosting, plus a theme, plus an [SEO plugin](website-builders.md#seo-plugins--the-mandatory-wordpress-line-item), plus everyone's time.** And note the individual traps: **MemberPress is intro-priced** — its own page states *"all annual renewals are at full price"*, so Growth goes **$314.55 → $699, a 2.2× step**, and the Launch tier additionally carries **4.9% transaction fees**. WPML and Polylang both publish first-year prices; only Polylang publishes a renewal discount (50%).

> [!CAUTION]
> **The licence-lapse trap is what makes this worse than it looks.** These plugins keep *working* when the subscription lapses — you only lose updates. That sounds merciful and is the opposite: **you now have five unpatched pieces of third-party code handling authentication, roles and payments on a public site.** The plugins that fill governance gaps are precisely the ones that must stay patched. The renewal is not optional, so treat the ≈$1,700/year as a fixed cost, not a discretionary one.

### The same requirement on hosted platforms

Not cheaper — mostly just unavailable:

- **Squarespace**: fixed role list, **no custom roles**, and **no approval workflow on any self-serve plan**. The only thing resembling one is the **Draft Editor** role, which exists **only on Squarespace Enterprise** — *"can create, edit, save, and delete page drafts, but can't edit non-draft pages, or publish any changes."*
- **Wix**: a large role catalogue and — genuinely better than Webflow's self-serve tiers — **custom roles with no plan restriction stated**. But the only approval workflow is **blog-scoped**: a Blog Guest Writer submits, a Blog Editor publishes. **No site-wide content approval.**
- **Webflow**: **publishing permissions** ("manage which teammates can publish which sites") arrive at **Growth, $49/mo + seats**. But **custom roles**, **granular per-page/per-Collection access**, and **design approvals** ("require sign-off from designated reviewers") are all **Enterprise-only, sales-quoted**. Seats are **$39/mo full, $15/mo limited** on top of the workspace fee.

### And on headless (Tier 4)

Covered [above](#tier-4--server-rendered-framework--headless-cms) — the same wall in a different building: **workflows and custom roles are the Enterprise-gated pair** at Hygraph (past $199/mo), Contentful (past €300/mo) and Sanity. **Storyblok Growth at $99/mo is the only published self-serve price for approval workflows in the set.**

### Reading the curve

> [!IMPORTANT]
> **The break-even is not a dollar amount — it's a shape.** Three signals, any one of which means the tier has stopped fitting:
>
> 1. **You are paying for plugins or add-ons to simulate a capability the platform doesn't have** (rather than to add one it never claimed). Governance is the classic: five subscriptions and a human process, approximating one feature.
> 2. **A requirement's answer is "Enterprise, contact sales."** Workflow and custom roles hit this wall on Webflow, Squarespace, Hygraph, Contentful and Sanity alike. That's the market telling you the requirement is a different product.
> 3. **Human process is standing in for a missing feature.** "We just remember not to publish before Legal replies" is a control that fails silently, and it is the actual risk — not the subscription cost.
>
> **The honest arithmetic at that point:** ≈**$1,700/year** in WordPress plugin renewals, or ≈**$1,200/year** for Storyblok Growth, or a **Webflow Enterprise quote** — against a Tier 4/5 build whose *hosting* is $5–100/month and whose real cost is [adaptive maintenance forever](#tier-5--custom-application). **The subscription comparison is close. The labour comparison is not.** That is why the break-even so often resolves in favour of *staying* off-the-shelf and simplifying the requirement instead — which is a legitimate answer this article recommends more often than "build it."
>
> **Before you cross the line, try deleting the requirement.** Do four roles need to exist, or did the org chart leak into the CMS? Does Legal need an approval gate in software, or a Slack message? **Governance requirements are the most expensive and the least examined**, and they are frequently cheaper to solve socially than technically.

## One-way doors and migration paths

Some tier moves are cheap. Some are rebuilds. Know which before you commit.

| Move | Difficulty | Why |
|---|---|---|
| **1 → 2** | 🟥 Rebuild | Neither tier exports usefully. You are re-creating the site from your own source assets. |
| **1 → 3 or 4** | 🟥 Rebuild | [Wix, GoDaddy, IONOS, Jimdo and Site123 have no export at all.](website-builders.md#lock-in-and-exit--what-you-own-your-site-actually-means) Squarespace gives you a lossy XML of one blog. Budget a full rebuild and a redirect map. |
| **2 → 3 or 4** | 🟨 Content moves, design doesn't | Webflow: static export exists but **omits all CMS content** (pull that separately via CSV or the CMS API). Framer: **no export at all**, but the CMS Export plugin and CMS API get your content out. |
| **3 → 4** | 🟩 **Easy** | Content is already Markdown in a repo. Add a runtime, keep the content, keep the URLs. This is the cheapest upgrade path in the article and a strong argument for starting at Tier 3. |
| **3 → 5** | 🟩 Easy | Same reason. |
| **4 → 5** | 🟩 Easy | You already have a runtime; you're adding surface. |
| **Anything → 1** | 🟨 Usually a rebuild, sometimes right | Downgrading is rare and underrated. If the org's capacity shrank, moving a Tier-4 site nobody can maintain onto Squarespace is a *good* decision. |

> [!TIP]
> **Tier 3 is the best hedge in the spectrum, and this table is why.** It is the cheapest tier to run *and* the cheapest to leave — upward moves are easy because content is already files in git, and there is no vendor to negotiate with. If you're genuinely unsure between tiers and you have one technical person available, **start at Tier 3.** Starting at Tier 1 and being wrong costs a rebuild; starting at Tier 3 and being wrong costs an afternoon.
>
> The corollary for the one-way doors: **before entering Tier 1 or 2, check the export story first, not last.** It is the cheapest due diligence in this article and the one nobody does.

## Cross-links

- [**Application types**](README.md) — the prior question: is this a website at all, or a web app, PWA, desktop or mobile app?
- [**Website builders — cross-ecosystem survey**](website-builders.md) — the next question once you've picked Tier 1 or 2: *which product?* ~60 platforms, per-capability matrices, full pricing-gotcha taxonomy, export/lock-in table, SEO-by-construction, EAA accessibility, GDPR residency.
  - [Family 1 — mainstream all-in-one](website-builders.md#family-1--mainstream-all-in-one-builders) is Tier 1.
  - [Family 2 — designer-first](website-builders.md#family-2--designer-first--visual-development-builders) is Tier 2.
  - [Family 4 — WordPress and open-source](website-builders.md#family-4--wordpress-and-the-open-source--self-hostable-corner) straddles Tiers 3 and 4.
  - [Adjacent categories](website-builders.md#adjacent-categories--what-these-are-not) covers ecommerce platforms and no-code app builders — relevant if your Tier 5 requirement might be a purchase instead.
- [**SEO**](../marketing/seo.md) — every tier can rank; the tiers differ in how much control they give you. Pair with [SEO capability by construction](website-builders.md#seo-capability-by-construction).
- [**Analytics**](../marketing/analytics.md) — measurement, and the self-hosted PostHog resource warning.
- [**UX resources & tools**](../design/ux.md) — the tier decides what's possible; UX decides whether it converts.
- [**Authentication**](../authentication.md) — required reading the moment you reach "logged-in users see their own data", i.e. the Tier 3 → 4/5 boundary.
- [**Domain-Driven Design**](../practices/domain-driven-design.md) — if you're at Tier 5, the modelling question outlives the stack question.
