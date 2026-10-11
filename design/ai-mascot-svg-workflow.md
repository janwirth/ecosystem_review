# From AI mascot exploration to reusable SVG artwork

> [!NOTE]
> **Status: DRAFT, ready for human review. Snapshot: 2026-10-11.** This is a recommended process, not an executed production project. Public examples are attributed. No new mascot artwork, paid generations or animation demo was created.

The goal is an insurance broker's character that looks like the same character in different website poses and illustrations, with a path to animation or interaction. The user prioritizes visual quality, then consistency, ease and cost. The [tool review](ai-mascot-tools.md) covers the broader candidate landscape; a human reviewer will shortlist five after reading both articles.

## The two stages

**Stage 1: choose the visual direction.** Examine public outputs from several tools. Compare flat illustration, dimensional artwork, line art and other relevant directions. Decide which direction communicates the actual brand. Do not decide species, palette or personality from a tool's stock prompt.

**Stage 2: turn an approved design into a controlled asset system.** Create a vector master, approve its proportions and style, add a small pose set, then choose the animation handoff. Source ownership and reusable geometry matter here. An attractive generative result and a maintainable SVG are separate acceptance decisions.

| Input | Operation | Reviewable result | Human gate |
| --- | --- | --- | --- |
| Brand requirements and public examples | Explore visual directions | Annotated references and candidate styles | Approve direction before generation or drawing |
| Approved direction | Create a character sheet | Front/side/three-quarter views and expressions | Approve one identity, not just a hero image |
| Approved identity | Native vector generation or deliberate redrawing | Editable SVG master | Inspect paths and visual fidelity |
| SVG master | Create poses using reusable parts | Website pose set | Approve identity and style across every placement |
| Approved pose set | Add an interaction or animation workflow | Browser asset or animation project | Verify handoff, rendering and reduced motion |

This sequence is a research recommendation. It has not been demonstrated end to end with this broker's brief.

## 1. Approve a direction without pretending a gallery is a benchmark

The tool review contains flat Recraft, dimensional Google, Midjourney reference/editing and Adobe editor previews. They are different jobs and different prompts. Use them to identify what is worth looking at, not to decide which model has the highest acceptance rate.

![Recraft's published flat drone mascot as an example of simple graphic geometry](assets/ai-mascot-tools/recraft-drone.webp)

**Attribution:** Mitya Meshcheryakov / Recraft, [Mascot Design](https://www.recraft.ai/blog/mascot-design), **2026-10-09**, retrieved 2026-10-11. This is a vendor WebP preview, not an inspected SVG or proposed broker identity. The [tool article's preview register](ai-mascot-tools.md#public-previews-look-first-then-read-the-claims) includes dated, older and undated examples.

Before producing new assets, record the broker's audience, actual proposition, website uses and visual references. Approve the desired personality and style. Keep illustrative examples separate from brand decisions: a friendly animal, an abstract shape and a human adviser communicate different things. This research does not choose one on the broker's behalf.

**Decision output:** a short visual brief and approved references. Human review can now pick five tools that cover the work, including a vector-production route if SVG is required. A model with beautiful painterly output can still be a good exploration tool even when it cannot export paths.

## 2. Define what must stay the same

Create a reference sheet that shows the character from the angles needed on the site. Record silhouette, body ratios, eye placement, outline weight, palette, shading rules and signature accessories. Separate those invariants from pose, expression and scene, which are allowed to change.

For this task, consistent means a visitor recognizes one character and one illustration style across placements. Exact pixel replay is unnecessary. Nevertheless, saving the approved artwork avoids asking a model to rediscover the same design for every placement.

Reference-driven editing is a documented route in [Midjourney's Edit Model](https://docs.midjourney.com/hc/en-us/articles/48495453462797-Edit-Model), [Google's image guide](https://ai.google.dev/gemini-api/docs/image-generation), and [OpenAI's image guide](https://developers.openai.com/api/docs/guides/image-generation). Those mechanisms do not guarantee that a set of mascot poses will pass human review.

**Decision output:** one approved identity sheet. Do not chain every edit from the previous edited image indefinitely; return to approved references when drift appears. That is a recommended review practice, not a measured comparison result.

## 3. Choose the route into actual vector geometry

| Route | When it fits | Main risk | Evidence and verification boundary |
| --- | --- | --- | --- |
| Native vector generation | Direction suits graphic shapes and the output is visually strong | Messy paths, unwanted fragments, weak pose identity | [Recraft V4.1 docs](https://www.recraft.ai/docs/recraft-models/recraft-v4-1) and [Adobe vector workflow](https://helpx.adobe.com/illustrator/desktop/use-generative-ai/generate-scenes-subjects-and-icons.html); no exported file tested here |
| Redraw approved raster artwork | Raster model wins the visual exploration and an illustrator can simplify it | Loss of texture or subtle form; extra labor | A recommended production method; conversion fidelity has not been measured |
| Trace, then repair | Flat, clean input makes tracing a useful starting point | Many small paths and poor semantic grouping | Investigate tracing as a conversion step, not an automatic character rig |
| Source-author or edit SVG with a coding agent | Simple geometry and a human can review the rendered changes | Structurally valid SVG that looks wrong | Potential Claude Code/source-edit workflow; no mascot-generation or edit test ran |

SVG is a container capable of holding an embedded raster image. Saving a PNG as an `<image>` inside an SVG does not create editable mascot geometry. Look for the shapes that form the character and confirm the export contains the expected artwork. [MDN's SVG/CSS tutorial](https://developer.mozilla.org/en-US/docs/Web/SVG/Tutorials/SVG_from_scratch/SVG_and_CSS) explains selecting and styling vector elements.

Do not assume the best raster character can be converted without aesthetic loss. Fur, complex lighting, texture and painterly strokes may be central to its appeal. If the broker wants that style, it may be sensible to keep campaign illustrations raster and build a simplified vector character for interactive website uses. This is a tradeoff for human approval, not a compulsory SVG-first style choice.

**Decision output:** an SVG that opens as editable shapes and matches the approved design. Inspect the export before judging vector generation successful.

## 4. Turn the master into a pose system

Organize the master by the parts that need independent changes: body, head, eyes, mouth, limbs and accessories as appropriate to the chosen character. Keep IDs and grouping readable. Preserve one palette and a consistent coordinate system. Add only the parts the approved designs require.

Create a small set of site uses first: neutral welcome, pointing at information, explaining a choice, concerned/supportive expression and confirmation. These are suggested test uses, not approved production deliverables. Pose variety should not silently change eye spacing, proportions, accessory design or outline style.

For a coding-agent edit, provide the existing SVG and approved pose reference, then request the smallest relevant change. Record the resolved model and keep a visual diff alongside the source diff. [Claude Code's model configuration](https://code.claude.com/docs/en/model-config) distinguishes aliases from resolved provider versions; it does not prove that source edits preserve visual quality.

Review each pose at its actual website size, against both light and dark placements if required, and beside the other poses. An isolated image can look attractive while breaking the set. If a pose requires a new silhouette, approve that view as part of the identity sheet before treating it as reusable.

**Decision output:** a reviewed set of poses and expressions sharing one character/style system. No claim is made that this research already supplies that system.

## 5. Verify the SVG before choosing animation tooling

| Check | Why it matters | Acceptance evidence |
| --- | --- | --- |
| Actual vector elements | Rules out a bitmap hidden in an SVG wrapper | Inspect the source and edit individual shapes |
| Useful groups and origins | Makes poses and motion manageable | Select a limb/eye/accessory without selecting unrelated fragments |
| Palette and stroke behavior | Keeps the illustration style coherent | Render side by side at actual sizes |
| Small-size and monochrome readability | Detects detail that disappears in placement | Review intended icon and website sizes |
| External references and filters | Can break portability or target import | Open the export in the actual target editor/browser |
| Baseline identity and style | A technically valid file can still be the wrong mascot | Human comparison against approved sheet |

Keep the editable master and derived exports separate in purpose, even if the repository stores them together. A compressed or flattened delivery file should not replace the editable source. Record fonts, color tokens and any linked dependencies that the final artwork needs.

## 6. Choose the smallest animation handoff that meets the design

| Intended behavior | Candidate handoff | What stays reusable | What must still be verified |
| --- | --- | --- | --- |
| Blink, wave, hover reaction | Inline SVG with CSS or a small script | Existing vector elements and pose parts | Transform origins, rendering, reduced-motion behavior |
| Several connected states and richer character motion | Investigate an animation editor such as Rive | A deliberately structured rig and animation project | SVG import compatibility, grouping, export/runtime and licensing |
| Campaign clip | Reference-led video, such as Kling | Approved reference artwork | Frame-to-frame identity; video is not the editable rig |
| Interactive 3D mascot | Model/rig production, then a web runtime | 3D geometry, materials and animation data | Image-to-3D quality, rigging, mobile performance and style fidelity |

SVG/CSS is supported as a browser workflow by [MDN](https://developer.mozilla.org/en-US/docs/Web/SVG/Tutorials/SVG_from_scratch/SVG_and_CSS). Rive was discovered as a relevant handoff candidate, but its import documentation could not be retrieved during this review. **Rive-specific portability is unverified**; do not treat an SVG extension as an import guarantee. The repository should not add an animation dependency until the approved behavior needs it.

WebGL is a rendering technology, not an automatic conversion from a 2D mascot into a coherent animated character. A dimensional direction can be explored later without requiring the initial brand artwork to be 3D. A generative video and an interactive character also have different deliverables: a finished clip versus reusable geometry and behaviors.

## What the linked spaceship example actually tells us

The [Reddit cross-post](https://www.reddit.com/r/TopologyAI/comments/1schgvp/vibecoded_space_game_ship_selection_ui_with/) describes a chain: Nano Banana and Midjourney for ship imagery, Hunyuan3D for 3D assets, and Nano Banana plus Gemini Pro for the UI. **Historical example, older than three months:** the accessible page describes it as roughly six months old; the exact post date was not established here. Its external X source was inaccessible.

This supports investigating **a process composed of specialized tools**. It does not establish the engine, complete prompts, number of attempts, cleanup labor, exact model versions or production readiness. Comments also question model geometry and interface decisions. Those observations are anecdotal rather than a reproducible technical test.

For a mascot, the analogous question is whether concept imagery can become an approved identity sheet, then editable paths, poses and finally an interactive asset. The attractive game UI does not prove that SVG production or character consistency is solved. This article recommends explicit review gates at those transitions.

## Rubric and evidence boundary

Use the [approved 50/30/15/5 rubric](ai-mascot-tools.md#approved-scoring-rubric-and-ranking-limits). The workflow should be judged by the quality of approved results, consistency across placements, total editing effort and total cost. Exportability is a feasibility condition when SVG is required, not a substitute for visual quality.

No route here has a measured end-to-end score. Native vector generation may reduce conversion work; raster-first may preserve the strongest visual exploration. Which wins depends on the approved style and actual export/repair results. The linked tool review shows unknown scores rather than declaring a workflow winner without those results.

## Research and preview provenance

**Research date: 2026-10-11.** Consulted the repository methodology and approved its domain adaptation before writing. Source discovery included `site.helpx.adobe.com illustrator text to vector graphic generate SVG firefly`, `site.recraft.ai blog V4.1 vector September 2026`, `site.rive.app docs editor import svg animation`, `site.inkscape.org learn tutorials tracing bitmaps`, and searches for Claude Code SVG workflows and the supplied spaceship example. Sources actually opened are linked beside the supported claims.

Inkscape tracing and Rive import documentation requests failed; no current feature compatibility was inferred from snippets. The workflow uses general geometry-review recommendations and marks target-specific import behavior unverified. No repo-health-metrics command ran because this is a process recommendation, not a repository-health review. The proposed process was not executed.

Downloaded previews are unchanged source files. These are critical-review examples, not licensed broker assets. Reuse them only as references for this research; commercial reuse rights were not established. All retrieved **2026-10-11**:

| Local file | Original asset URL | Attribution date / age | SHA-256 |
| --- | --- | --- | --- |
| `recraft-drone.webp` | [Recraft CDN](https://cdn.prod.website-files.com/655741af3f04e006606d26ad/6ac8fedbdcc0b42c30dd09c0_6ac8fe8b72d01b9b5368e336_mascot-design-vector-drone-v3.webp) | Page 2026-10-09 | f9619c15132cc68d4863095bad13a41e77d05d6c31696af288a257593e92a9ae |
| `google-dog.jpg` | [Google storage](https://storage.googleapis.com/generativeai-downloads/images/Nano%20Banana%20Pro%20outputs%20for%20docs/01-an-icon-representing-a-cute-dog-the-background-is-.jpg) | Unknown; three-month freshness unverified | 82e1a67c460ac1d845f27d26787e2c68997d2fad242de8e5a116fc8d30dbab36 |
| `midjourney-edit.png` | [Midjourney attachment](https://docs.midjourney.com/hc/article_attachments/48495453457165) | Unknown; three-month freshness unverified | b1675e90d34926ed57eed7eaf21538742ca407c1044350341142787a34997c1d |
| `midjourney-omni.png` | [Midjourney attachment](https://docs.midjourney.com/hc/article_attachments/36285152349837) | Undated legacy V7; potentially older than three months | 608934e2832f503153c39c9ab3393a689007b74dcce8296875bfa9cfaf780a1e |
| `adobe-vector.jpg` | [Adobe asset](https://helpx-prod.scene7.com/is/image/HelpxProdLoc/Text-to-vector-graphic-Desktop?%24png%24=&jpegSize=200&wid=1000) | Page update 2026-06-01; older than three months | c36d264508d894afa7f4ca6e11c0c3ce7ee10ab68f5f3b4e3326b4e9f3f0fcd0 |

Downloaded with Python 3 `urllib.request.urlopen`; `file design/assets/ai-mascot-tools/*` verified types and dimensions. Each image was visually inspected. The Adobe response is JPEG despite its URL parameters; the stored extension matches the actual type. Research queries and limitations remain inside these two articles, not in an additional research Markdown file.

**Next human action:** review the visual directions in the companion article and shortlist five candidates. A subsequent hands-on evaluation requires an approved identity brief and spending authorization; it has not been performed as part of this documentary review.
