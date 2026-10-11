# AI mascot tools — evidence before the five-tool shortlist

> [!NOTE]
> **Status: DRAFT, ready for human review. Snapshot: 2026-10-11.** Documentary research with public, attributed previews. No model generations, paid accounts, or generation credits were used. The human reviewer selects five tools after reviewing this landscape; this article does not silently make that selection.

This review helps a reader with some design knowledge choose tools to explore an insurance broker's mascot. The priorities are **visual quality, character and style consistency, ease, then cost**. Consistency means recognizable poses and illustrations across a website, not identical pixels from rerunning a prompt. Animation is a later handoff. The companion article covers the [complete SVG workflow](ai-mascot-svg-workflow.md).

## Start with the job, then choose the tool

| Job | Candidates to review | What to inspect |
| --- | --- | --- |
| Explore attractive characters and styles | Midjourney, OpenAI image models, Google Nano Banana, Recraft, Ideogram, Leonardo | A range of examples, not one impressive hero image |
| Produce editable vector artwork | Recraft Vector, Adobe Illustrator's vector generation; human redrawing | Actual paths, useful groups, cleanup time, small-size readability |
| Make more poses without losing identity | Reference-image editing, an approved model sheet, source edits | Face, proportions, palette, outline style and accessories together |
| Use several models with one budget | Recraft Studio, Higgsfield, Artlist, Krea; fal or Replicate for API use | Exact models, credit pool, expiry, controls and export formats |
| Add motion | SVG/CSS for small interactions; investigate Rive for a rig; Kling for rendered clips | Reusable animation data versus a finished video |

These jobs overlap, but their products are not interchangeable. A subscription platform can expose several providers' models. A coding agent can edit source artwork. Neither is an image-model family. A flat-looking PNG is not editable vector geometry.

## Public previews: look first, then read the claims

All files below were retrieved and visually inspected on **2026-10-11**. Attribution dates describe the source page unless explicitly stated otherwise; retrieval is not the date of generation. Public examples are curated by vendors, not a random sample, and their prompts and settings are not comparable. They demonstrate directions worth inspecting, not success rates.

### Recraft: a simple graphic mascot

![Recraft's public flat drone mascot with a blue eye, ring and orange antenna](assets/ai-mascot-tools/recraft-drone.webp)

**Attribution:** Mitya Meshcheryakov / Recraft, [Mascot Design](https://www.recraft.ai/blog/mascot-design), **published 2026-10-09**. The page identifies V4.1 Vector. This local WebP is a preview, not the SVG source; path structure was not tested. A bold outline and few major shapes make this a useful example of a character that could survive simplification. It is not a proposed broker mascot.

### Google: dimensional, textured character art

![Google's public cute-dog example with a textured orange body and teal collar](assets/ai-mascot-tools/google-dog.jpg)

**Attribution:** Google, [Gemini image-generation documentation](https://ai.google.dev/gemini-api/docs/image-generation), retrieved **2026-10-11**. **Publication/generation date unknown; freshness within three months is unverified.** The source asset is filed under Nano Banana Pro examples, not evidence of a Nano Banana 2.1 output. Texture and shading produce a different design direction from flat vector art. One dog image does not demonstrate consistent additional poses.

### Midjourney: current editing examples and a legacy reference example

![Midjourney's public Edit Model example combining a boy and a monster](assets/ai-mascot-tools/midjourney-edit.png)

**Attribution:** Midjourney, [Edit Model documentation](https://docs.midjourney.com/hc/en-us/articles/48495453462797-Edit-Model), retrieved **2026-10-11**. **Example date unknown; freshness within three months is unverified.** The documentation supports V8.1/V8.2; the exact version used for this image is not stated.

![Midjourney's legacy Omni Reference example reusing a top-hat duck in different scenes](assets/ai-mascot-tools/midjourney-omni.png)

**Attribution:** Midjourney, [Omni Reference documentation](https://docs.midjourney.com/hc/en-us/articles/36285124473997-Omni-Reference), retrieved **2026-10-11**. **Legacy V7 workflow; example date unknown and potentially older than three months.** It illustrates identity reuse but must not be presented as a benchmark of the current Edit Model. In the sample, scenes and clothing details change; a brand review must decide which changes are acceptable.

### Adobe: vector generation inside a production editor

![Adobe's public illustration accompanying its Text to Vector Graphic documentation](assets/ai-mascot-tools/adobe-vector.jpg)

**Attribution:** Adobe, [Generate scenes, subjects, and icons](https://helpx.adobe.com/illustrator/desktop/use-generative-ai/generate-scenes-subjects-and-icons.html), **page updated 2026-06-01 — older than three months**. Individual image creation date, generating model and source paths are not provided. This is an illustration accompanying the documentation, not an editor screenshot or a verified model output.

## Candidate landscape and verified baselines

“Current” below means the opened documentation on the snapshot date, not that every account or aggregator exposes that version. Model aliases and website selectors can move. Save the actual selection when evaluating.

| Candidate | Kind and verified baseline | Relevant control or output | Remaining question for this mascot |
| --- | --- | --- | --- |
| [Recraft](https://www.recraft.ai/docs/recraft-models/recraft-v4-1) | Model family plus Studio platform; V4.1 documentation | Raster and vector routes; recent mascot tutorial | Does the exported SVG need extensive cleanup, and do new poses preserve identity? |
| [Adobe Illustrator / Firefly](https://helpx.adobe.com/illustrator/desktop/use-generative-ai/generate-scenes-subjects-and-icons.html) | Editor plus generative features; the vector workflow has Adobe/partner model selection | Vector subjects/icons/scenes, style references, color controls | Which selected model and settings produce acceptable editable mascot paths? |
| [Midjourney](https://docs.midjourney.com/hc/en-us/articles/32199405667853-Version) | Image platform; default V8.2, released 2026-07-24 | V8 Edit Model and separate style-reference controls; raster artwork | Does identity hold through pose and expression changes in the chosen style? |
| [OpenAI](https://developers.openai.com/api/docs/guides/image-generation) | GPT Image model family; current guide uses GPT Image 2.5 Sunburst / Flare | Reference-based raster generation and editing | Which model produces the best character for this brief, with how many repairs? |
| [Google Nano Banana](https://ai.google.dev/gemini-api/docs/image-generation) | Gemini image-model family; `gemini-nano-banana-2.1`, with `gemini-3-pro-image` a separate Pro option | Multi-image references and multi-turn raster edits | Compare Pro and 2.1 explicitly; an aggregator's “Nano Banana” label is insufficient |
| [Ideogram](https://docs.ideogram.ai/) | Model family and platform; current docs name Ideogram 4.5 and partner models | Reference images, remix, transparent PNGs, custom models | Current character workflow and non-human identity retention need review |
| [Leonardo](https://leonardo.ai/learn/core-feature/how-to-create-consistent-characters-with-character-reference) | Creative platform with reference workflows | Character reference and separate style reference | Current model compatibility and non-human mascot performance remain unverified |
| [FLUX via fal](https://fal.ai/pricing) | Additional image-model family; fal lists a FLUX 3 edit endpoint | Raster editing alternative exposed through a model API | Direct-provider latest baseline and comparable mascot outputs were not verified; catalogue presence is not a quality score |
| [Claude Code](https://code.claude.com/docs/en/model-config) | Coding agent; Anthropic API aliases currently resolve to 5.5 models | Source-code editing; potential SVG maintenance route | Can it preserve approved paths while changing only the requested pose? No source-edit benchmark ran |
| [Kling](https://kling.ai/blog/kling40-kling-visual-realism-creative-control-introducing-storytelling?tab=all) | Video/image platform and model family; September 30 announcement puts 4.0 in early access | Reference-driven video; rendered clips rather than an SVG rig | Account access, identity across frames, and actual clip repair effort |
| [Artlist](https://help.artlist.io/hc/en-us/articles/37462605912861-Studio-Understanding-AI-Credits) | Aggregator and creative workflow | Shared image/video/voiceover credit pool | Selected model, reference controls and export need checking in the actual plan |
| [Higgsfield](https://higgsfield.ai/creator-hub/help-center/credits/how-credits-work) | Creative platform with multiple models and native tools | Shared credits; model-specific image/video workflows | Cartoon identity performance and differences between browser and API entitlements |

### What the primary sources do and do not establish

**Vector generation deserves its own comparison.** Recraft's recent mascot tutorial establishes a relevant route, and Adobe documents vector generation with style and color controls. A Recraft comparison article dated April 2 says Adobe lacks vector generation. That assertion conflicts with [Adobe's own documentation](https://helpx.adobe.com/illustrator/desktop/use-generative-ai/generate-scenes-subjects-and-icons.html). Treat [the comparison](https://www.recraft.ai/blog/recraft-vs-adobe-firefly) as vendor advocacy, not independent ranking evidence.

**Midjourney's old advice needs version labels.** V8.2 replaces Omni Reference with Edit Model. Edit Model accepts up to four references; it does not currently support `--tile`, and its results do not support Remix. A good V7 reference example cannot establish V8.2 reliability. [Version](https://docs.midjourney.com/hc/en-us/articles/32199405667853-Version), [Edit Model](https://docs.midjourney.com/hc/en-us/articles/48495453462797-Edit-Model).

**OpenAI documents a limitation relevant to the decision.** Its guide explicitly warns of difficulty maintaining recurring characters and brand elements across generations. Sunburst and Flare are distinct options, and outputs are raster formats. A saved reference and iterative editing are a route to evaluate, not proof of consistency. [Image guide](https://developers.openai.com/api/docs/guides/image-generation), [edit API and dated snapshots](https://developers.openai.com/api/reference/resources/images/methods/edit).

**Google's models must not be collapsed into one name.** The current guide lists 2.1, previous Flash image variants, and Pro separately. It documents character/object reference support, but that is not a measured acceptance rate for a cartoon broker mascot. [Google guide](https://ai.google.dev/gemini-api/docs/image-generation).

**Leonardo's strongest dated consistency example is historical.** Its [2024-05-30 example](https://leonardo.ai/news/character-consistency-with-leonardo-character-reference-6-examples) identifies Kino XL, Alchemy V2 and reference strength. **Older than three months:** useful workflow provenance, not proof of current performance. The newer [tutorial](https://leonardo.ai/learn/core-feature/how-to-create-consistent-characters-with-character-reference) does not settle current compatibility.

**Higgsfield's Soul ID is not a generic mascot rig.** Its August 1 guide describes training a face from portraits, including generated portraits, and acknowledges drift. The trained identity is not an exportable standalone file. Cartoon-animal performance is unverified. [Soul ID guide](https://higgsfield.ai/creator-hub/help-center/ai-models/how-do-i-create-and-use-a-soul-id-character).

**Kling is a later motion candidate.** The September announcement describes early access and features still coming soon. It does not verify availability to this user. Generated motion can be useful for campaigns but does not provide editable SVG joints. [Kling announcement](https://kling.ai/blog/kling40-kling-visual-realism-creative-control-introducing-storytelling?tab=all).

## One budget, multiple models: yes, with important boundaries

The practical answer is **yes**. Browser suites use a shared pool of credits or compute units. API services centralize usage billing. Neither guarantees every model, every control, or the newest version. API billing and a browser subscription can be separate even on the same platform.

| Platform | Access and budget evidence | Important limit | Suggested role, not a purchased recommendation |
| --- | --- | --- | --- |
| [Recraft Studio](https://www.recraft.ai/pricing) | Browser credits; Studio lists external image/video models alongside its own | API Units are purchased separately; subscription credits reset, top-ups do not expire | Inspect first when vector creation and raster exploration should share one workspace |
| [Higgsfield](https://higgsfield.ai/creator-hub/help-center/credits/how-credits-work) | Model costs draw from credits; cost appears before generation | Subscription credits expire each cycle; free browser generations do not carry into CLI/MCP | Inspect for a browser image-to-video workflow |
| [Artlist](https://help.artlist.io/hc/en-us/articles/37462605912861-Studio-Understanding-AI-Credits) | Monthly credits shared across image, video and voiceover | Price depends on model and settings; “unlimited” applies to selected models, not everything | Inspect if campaign media production matters alongside still images |
| [Krea](https://www.krea.ai/pricing) | Multiple image/video models and compute-unit plans | Plan access varies; personal monthly units do not roll over; purchased extras expire after 90 days | Inspect its workspace and iteration experience |
| [fal](https://fal.ai/pricing) | Pay-per-use model API pricing in one service, including Google, OpenAI and Kling endpoints | Endpoint catalogue versions can lag direct vendors; listed price depends on billing unit and settings | Inspect for scripted multi-model evaluation |
| [Replicate](https://replicate.com/docs/topics/billing) | Central pay-as-you-go billing, with prepaid or arrears accounts | Compute-based versus output-based charges need checking per model | Inspect for code-driven experiments and reproducible request records |
| Freepik / Magnific | Discovered as a relevant browser-platform alternative | Credit documentation could not be retrieved; shared-pool terms and exact naming not verified | Keep on the discovery list; no unsupported score or purchasing recommendation |

Recraft's [Studio model catalogue](https://www.recraft.ai/blog/recraft-vs-adobe-firefly) lists outside model families, while its pricing page establishes budget separation. Do not infer Studio subscription access to external models through its own-model API.

For cost context, fal's opened pricing page lists **Nano Banana 2 at $0.08/image** and **Nano Banana Pro at $0.15/image**. These are endpoint-specific advertised rates, not a quote for Nano Banana 2.1, and not cost per accepted mascot. Failed attempts, repairs and export work may dominate the final cost. [fal pricing](https://fal.ai/pricing).

Artlist's [unlimited-plan explanation](https://artlist.io/blog/artlist-ai-unlimited-pricing-plan/) describes selected-model access. A [user complaint](https://www.reddit.com/r/editors/comments/1v8qf50/warning_artlist_ai_suite_unlimited_plan_is_a/) reports confusion about that boundary. The complaint is anecdotal and cannot establish incidence or fraud; the documented model restriction is the useful procurement fact. Check the exact model and generation cost before subscribing.

## Approved scoring rubric and ranking limits

The repository's [standard methodology](../workflows/REVIEW_METHODOLOGY.md) evaluates code repositories. The user approved this domain rubric on 2026-10-11. **`tools/repo-health-metrics` was not run:** repository stars, Gleam compatibility and issue counts do not measure these hosted models' visual suitability. No replacement mechanical tool or benchmark was implied.

Score each criterion **0–4**: 0 unacceptable; 1 poor with major repair; 2 usable with substantial repair; 3 good with minor repair; 4 meets the brief without meaningful repair. Unknown is **U**, never zero. Scores are human judgment supported by identified examples; repeated acceptance counts and spend, when available, are separate measured data.

| Criterion | Weight | Required evidence |
| --- | --- | --- |
| Visual quality Q | 50% | Human review of actual artwork for the agreed direction, including small-size readability |
| Consistency C | 30% | Same character and style across multiple poses/scenes; a feature called “reference” is insufficient |
| Ease E | 15% | A documented or observed complete workflow, including revisions and export; hands-on time preferred |
| Cost K | 5% | Total spend per accepted asset, including retries; a credit price alone is insufficient |

`Total = 100 × (0.50Q + 0.30C + 0.15E + 0.05K) / 4`.

Example arithmetic only: Q=3, C=3, E=2, K=2 gives **70/100**. Those numbers are not an assessment of any tool. When any criterion is unknown, report **total U**; do not renormalize the remaining weights or manufacture precision.

### Scoring table for human review

| Category | Option | Q | C | E | K | Weighted total | Performance rank | Evidence available now |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Native vector generation | Recraft V4.1 Vector | U | U | U | U | U | Unresolved | Recent relevant public sample and vector documentation |
| Native vector generation | Adobe Illustrator vector workflow | U | U | U | U | U | Unresolved | Accompanying illustration, documented style/color controls; no mascot pose series |
| Raster concept/reference editing | Midjourney V8.2 Edit | U | U | U | U | U | Unresolved | Current editing example; legacy identity series clearly separated |
| Raster concept/reference editing | GPT Image 2.5 Sunburst / Flare | U | U | U | U | U | Unresolved | Current editing docs; no comparable mascot series here |
| Raster concept/reference editing | Nano Banana 2.1 / Pro | U | U | U | U | U | Unresolved | Pro style sample and current reference docs; no matched series |
| Raster concept/reference editing | Ideogram 4.5 | U | U | U | U | U | Unresolved | Current reference/editing documentation |
| Raster concept/reference editing | Leonardo, selected model TBD | U | U | U | U | U | Unresolved | Current tutorial and clearly historical consistency example |
| Raster concept/reference editing | FLUX 3 edit endpoint via fal | U | U | U | U | U | Unresolved | Host catalogue only; direct baseline and mascot evidence unverified |
| Source maintenance | Claude Code, resolved model recorded | U | U | U | U | U | Unresolved | Model configuration; no source-edit test |
| Rendered motion | Kling, available version recorded | U | U | U | U | U | Unresolved | Current announcement; no mascot video test |
| Browser multi-model workflow | Recraft / Higgsfield / Artlist / Krea | U | U | U | U | U | Unresolved | Budget documentation; hosted performance depends on selected model |
| API multi-model workflow | fal / Replicate | U | U | U | U | U | Unresolved | Billing documentation; API integration not tested |

**A numerical winner is not established.** Public examples allow visual exploration but do not support complete comparative scores. This is the requested first documentary stage, not a completed benchmark. All unknowns stay visible for human review.

### Ranked order for reviewing the evidence, not a performance leaderboard

| Review order within category | Category | Candidate | Reason to examine at this point |
| --- | --- | --- | --- |
| 1 | Vector production | Recraft Vector | Most directly relevant recent mascot example in this research |
| 2 | Vector production | Adobe Illustrator | Direct editor workflow offers a production counterpoint |
| Equal priority | Raster exploration | Midjourney, Google, OpenAI | Different documented generation/editing routes; evidence cannot order quality |
| Next evidence pass | Raster exploration | Ideogram, Leonardo | Worth considering beyond the supplied examples; current mascot evidence is thinner |
| After still identity is accepted | Motion | Kling | Motion evidence cannot decide the still-image/vector winner |

This ordering describes evidence relevance, not the weighted result, and does not select five. More emphasis on source editability favors vector workflows as a **feasibility gate**. More emphasis on visual richness can favor a raster-first workflow with later redrawing. Raising consistency's weight could reverse a visual-quality ranking; current evidence does not identify that winner. Convenience may favor a browser suite over an API even when both expose the same underlying model.

## Human review and the second stage

Review examples for the intended visual direction before buying access. Record what appeals and what should remain constant; do not let a provider gallery choose the brand. Select five candidates across the jobs actually needed, rather than five aggregators exposing the same model.

For any later authorized comparison, use one approved character sheet. Request a neutral pose, a wave, an explanatory gesture, a concerned expression and a second website scene. Keep every output and record exact model, platform, references, settings, retries, credits and repair time. A changed face or style is a failure even if the new image is attractive. Vector candidates also need actual exported-path inspection. **This protocol is proposed and was not run.**

## Research trail, source access and gaps

**Investigation date: 2026-10-11.** Search-engine discovery used multiple rounds, including:

- `AI mascot character consistency vector SVG tools Recraft Adobe Firefly Midjourney 2026`
- `AI image video aggregator shared credits fal Replicate Freepik Krea Higgsfield Artlist models`
- `site.docs.midjourney.com Omni Reference Style Reference version 2026`
- `site.developers.openai.com image generation models editing limitations consistency`
- `site.recraft.ai blog V4.1 vector September 2026`
- `site.artlist.io help AI credits models image video generation credits`
- `site.leonardo.ai character reference style reference consistency`
- `site.ideogram.ai character reference 2026`
- `site.freepik.com ai credits models Magnific`
- Follow-ups: current model/version pages, billing/expiry documents, reference limits, Artlist unlimited complaints, and Midjourney reference failures.

Opened primary sources are linked beside the claims above. Unopened search snippets were not used to establish versions or prices. Several guessed documentation paths failed and were replaced with links from opened vendor pages. Recraft's general brand-mascot article and initial API page, Freepik/Magnific credit pages, and a guessed fal billing page were inaccessible; the review uses accessible current Recraft docs/pricing, fal pricing and leaves Freepik/Magnific unverified.

Independent discovery included the [WACV 2026 image-editing study](https://openaccess.thecvf.com/content/WACV2026/papers/Collins_Understanding_Generative_AI_Capabilities_in_Everyday_Image_Editing_Tasks_WACV_2026_paper.pdf), opened as methodological context. It is not a matched test of the current model versions above. [Midjourney's legacy reference complaint](https://www.reddit.com/r/midjourney/comments/1t5v1io/omni_reference_not_working/) is anecdotal and about an older workflow, so it does not prove V8.2 failure. The Artlist complaint above informs a billing question, not a reliability statistic.

**Reproduction trail:** public-page retrieval used search/open operations; assets were downloaded with Python 3 `urllib.request.urlopen` into `design/assets/ai-mascot-tools/` and checked with `file` plus visual inspection. No API generation commands ran. Asset URLs and hashes are recorded in the companion workflow article. Research stays in these two requested articles; there is no separate duplicate research article.

Remaining gaps: comparable latest-model mascot previews for every option, repeated identity tests, actual SVG topology, account-specific availability, current model-specific exports, paid workflow ease, total production cost, and plan-specific commercial rights. A subscription's commercial-use permission does not establish exclusive brand ownership. These gaps limit the ranking; they do not disappear because documentation is available.
