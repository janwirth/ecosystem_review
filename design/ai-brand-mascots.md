# AI design tools for a consistent insurance-broker mascot

> [!NOTE]
> **Status:** DRAFT · **Authoring:** AI-assisted; human brand approval pending.

**Snapshot: 2026-10-10.** Ranking goal: explore a credible broker mascot, preserve its identity across campaigns, and retain an editable production asset. This is a source-based evaluation, not a paid-model bake-off. Embedded artwork is original SVG authored for this article; it is not evidence of any vendor's image quality.

## Recommendation

Use image models to explore directions, then approve and save a vector master. Use Claude Code or Codex to edit that master under a written character specification. Reuse the saved geometry for the website, print, and animation. Reference-guided image generation can produce convincing scenes; it does not make the character's geometry deterministic.

This follows the source-first approach in [diagramming](diagramming.md) and the separation of rendering targets in [charts](charts.md). [Typography](typography.md) covers the wordmark and surrounding layout. The [shared review rubric](../practices/formalization.md) informs evaluation, but stars do not compare proprietary image services with coding tools. The domain criteria below take precedence.

## Embedded concept preview

![Three original editable insurance broker mascot concepts](assets/broker-mascot.svg)

[Open the full-size SVG and inspect its source](assets/broker-mascot.svg). No installation or service account is needed. These are exploration directions, not an approved brand or a claim of trademark clearance.

| Concept | Brand proposition | Risk to test with customers |
| --- | --- | --- |
| Owl adviser | Explains complicated policies clearly | Can look patronising or resemble education brands |
| Turtle protector | Long-term protection and calm | Can imply slow claims handling |
| Dog companion | Friendly support through renewals and claims | Can look like pet insurance only |

For a broker, the character should communicate advice and choice, not promise that every risk is covered. Test the owl first when clarity is the main proposition. Keep facial expression calm and avoid emergency-services symbols. Treat palette and species as proposals until a human approves them.

## What “reproducible” means

| Requirement | Reliable mechanism | Remaining limit |
| --- | --- | --- |
| Exact source asset | Commit the approved SVG bytes and their checksum | Browser text rasterisation can differ; outline final wordmark lettering |
| Consistent web character | Reuse named SVG groups and fixed palette | New poses still need review |
| Similar character in new scenes | Reference sheet plus constrained image edits | Eye shape, proportions, accessories can drift |
| Replay an image-generation request | Save model ID, prompt, input files, settings, and response | Repeating the request does not guarantee identical pixels |
| Repeat an animation | Save timeline, rig, geometry, and export settings | Generative video can change anatomy between frames |

An embedded PNG inside an SVG wrapper is still a bitmap. Automatic tracing produces paths but does not reconstruct intentional joints, editable expressions, or a reusable character rig.

## Production route: SVG first

1. Approve one species, silhouette, palette, and expression sheet. Include front, side, and three-quarter views.
2. Save a master with named groups: body, eyes, beak or muzzle, arms, and accessories. Keep colour tokens and proportions explicit.
3. Ask a coding agent to modify only named groups. Review the visual diff and commit approved changes.
4. Export SVG for web and vector print workflows; rasterise a copy for social platforms. Keep the vector original.
5. Animate transforms of the existing groups before adding a new renderer. Canvas is useful for many moving instances; WebGL earns its cost for 3D or shaders.

The preview uses SVG primitives and fixed geometry. Its three groups are `owl`, `turtle`, and `dog`. SVG scales without regenerating the character. It is not yet a multi-pose rig: an artist must approve joints and additional views before animation.

### Reusable exploration brief

```text
Create three distinct branding directions for an independent insurance broker.
The character communicates clear advice, calm protection, and continuing support.
Use a flat vector-like style with navy #17324d, teal #168b87, cream #fffaf0.
Show one front view, one side view, and three expressions per direction.
No policy promises, lettering, gradients, or existing brand references.
After approval, preserve species, silhouette, eye spacing, and accessory design.
Change only the requested pose or expression. Use the approved sheet as reference.
```

“Vector-like” describes appearance; it does not request genuine paths from an image model. For production, give a coding agent the actual SVG and request a source edit. Do not ask it to recreate the mascot from the prompt on each run.

## Evaluation protocol

Use one approved reference sheet across every service. Request a neutral front view, a side view, a waving pose, a concerned expression, and a small monochrome icon. Repeat each request three times and retain every output, including failures. This protocol is proposed; it has not been run against paid services here.

Score each output 0–2 on silhouette, face, palette, accessory identity, and required pose. Zero means wrong, one means repairable, two means approved. A wrong species, extra limb, or changed signature accessory is a rejection regardless of total. Record time, retries, credits consumed, model ID, and whether output can be edited as actual paths. Review at 24 px, at normal web size, and in monochrome.

Treat vendor consistency claims as documented capabilities, not measured reliability. The winner for concept imagery can differ from the winner for exact production assets.

## Current model baseline

OpenAI's current API guide recommends `gpt-image-2.5-sunburst` for precise editing and `gpt-image-2.5-flare` for faster everyday generation. The guide also warns that recurring characters and brand elements can lose consistency. Use saved references, not a prompt alone. These are raster workflows, not native SVG generation. [Official OpenAI image-generation documentation](https://developers.openai.com/api/docs/guides/image-generation).

Claude Code is a coding tool, not an image-model name. Anthropic announced Opus 5.5 on 2026-09-22; record the resolved model rather than a moving `opus` alias. Claude Design's April launch described brand systems, iterative editing, and HTML/PDF/PPTX/Canva exports, with handoff to Claude Code. That launch's Opus 4.7 description is historical, not the current Code model baseline. [Opus 5.5 announcement](https://www.anthropic.com/claude-opus-5-5), [Code model configuration](https://code.claude.com/docs/en/model-config), [Claude Design launch](https://www.anthropic.com/news/claude-design-anthropic-labs).

The named-provider comparison and its research trail are expanded in subsequent sections. Prices and commercial-use terms need checking for the exact plan before purchase; account access was not tested.

## Research trail

[Primary-source register, discovery queries, and evidence limits](ai-mascot-research.md).

## Six requested tools: what belongs where

| Tool | Current baseline or role | Character-control mechanism | Native editable production asset | Fit for this brief |
| --- | --- | --- | --- | --- |
| Claude Code | Coding agent; record resolved model, with Opus 5.5 a current option | Edit the same SVG and preserve named geometry | SVG, canvas code, or WebGL code when explicitly authored | Best fit for maintaining the approved vector master; inspect every edit |
| OpenAI | GPT Image 2.5 Sunburst / Flare; Codex is a separate coding workflow | Reference-based edits and conversational iteration | Image API outputs raster; a coding agent can separately author SVG | Sunburst for controlled raster edits; source-authored SVG for exact reuse |
| Nano Banana | `gemini-nano-banana-2.1`; Pro `gemini-3-pro-image` is a separate premium choice | References and multi-turn editing | Raster images, not a guaranteed SVG export | Shortlist for exploration and variations; measure identity drift |
| Kling | Production 3.0 / 3.0 Omni; 4.0 Preview / Flash early access separately | Elements with multiple views and image-to-video controls | Video rather than an editable vector rig | Animate an approved reference after still-image acceptance |
| Artlist | Hosted toolkit aggregating image/video models | Image-to-image and model-specific video controls | JPEG/PNG and video; native SVG not verified | Convenient campaign production; record underlying model, not only platform name |
| Higgsfield | Hosted creative suite with Nano Banana 2.1 workflows | Image references and multi-turn edits; Soul ID is human-face oriented | Still images and video; native SVG not verified | Creative campaign scenes; do not treat Soul ID as proven mascot training |

Sources: [Claude Code configuration](https://code.claude.com/docs/en/model-config), [OpenAI image API](https://developers.openai.com/api/docs/guides/image-generation), [Google model selection](https://ai.google.dev/gemini-api/docs/image-generation), [Kling API catalogue](https://kling.ai/dev/api), [Artlist image workflow](https://artlist.io/ai/image-generator/image-to-image), [Higgsfield model catalogue](https://github.com/higgsfield-ai/skills/blob/main/higgsfield-generate/references/model-catalog.md).

### Nano Banana: name the exact model

Google recommends 2.1 for new workhorse integrations. Nano Banana 2 (`gemini-3.1-flash-image`) is the previous generation; Lite (`gemini-3.1-flash-lite-image`) prioritises speed and cost and is not optimised for multiple references or sequential edits. Pro remains a distinct option for complex scenes. All generated images include SynthID. Avoid buying a service merely labelled “Nano Banana” without checking its model selector. [Google documentation](https://ai.google.dev/gemini-api/docs/image-generation).

### Kling: preview is not a production baseline

The September announcement describes full Kling 4.0 availability for October and limited Flash early access from September 28. Do not infer that every account can use the full model on this snapshot date. For an immediate experiment, compare the available 3.0/Omni workflow and record actual account access separately. Elements can use up to four views per element and bind up to three elements for image-to-video consistency. That helps references, not vector replay. [4.0 announcement](https://kling.ai/blog/kling40-kling-visual-realism-creative-control-introducing-storytelling?tab=all), [Elements guide](https://kling.ai/quickstart/klingai-element-library-3-user-guide).

### Artlist and Higgsfield: workflow convenience versus source ownership

Artlist and Higgsfield bundle multiple models and creative controls. Their convenience is selecting, editing, and producing campaign assets without assembling API tools. It is not evidence that the same character will pass repeated identity tests. Artlist lists JPEG/PNG image downloads. Higgsfield advertises reference-led Nano Banana workflows; Soul ID's documented photo training is aimed at human faces, not a demonstrated cartoon rig. [Artlist formats](https://artlist.io/ai/image-generator/text-to-image?ai_suite_modal=1), [Higgsfield Soul ID](https://higgsfield.ai/creator-hub/help-center/ai-models/how-do-i-create-and-use-a-soul-id-character).

Artlist's terms include restrictions on output use giving rise to trademark-related claims. That is material for a broker's primary brand mascot: obtain a plan-specific answer before adopting generated output as a protected mark. Higgsfield's API terms also distinguish commercial use from guaranteed originality and exclusivity. This is a procurement flag, not a legal clearance assessment. [Artlist terms](https://artlist.io/help-center/privacy-terms/terms-of-use/), [Higgsfield API terms](https://open.higgsfield.ai/terms-of-service).

## Fit-based shortlist

| Job | First experiment | Why | Acceptance gate |
| --- | --- | --- | --- |
| Explore mascot directions | Nano Banana 2.1 and GPT Image 2.5 | Current reference/editing workflows | Run the same brief and retain all outputs |
| Ship exact web/print character | Claude Code or Codex editing approved SVG | Geometry stays in source control | Visual approval, small-size check, and source diff |
| Generate campaign scenes | Best passing raster workflow, direct or aggregated | References preserve more than prompts alone | Face, silhouette, and accessory identity pass |
| Produce short campaign video | Kling's actually available Elements workflow | Multi-view references address temporal identity | Review every frame; reject identity drift |
| Avoid native-code work | Artlist or Higgsfield | Hosted creative workflow | Export, plan terms, and credit cost meet requirements |

These are workflow recommendations derived from documented capabilities. They are not performance scores. Keep the vector master even when a hosted platform wins campaign production. A single tool need not own both exploration and production.
