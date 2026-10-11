# Brand concept / mascot development

**Reading time: about 6 minutes, excluding expandable sections.** Research checked 2026-10-11. Public examples, not our own model tests.

This is a one-off concept decision: try different tools and play with ideas before choosing a direction. You do not need to choose a technical stack.

1. Write a short brief: brand personality, audience, and what the mascot should communicate.
2. Try the same brief in several image tools. Save promising designs and note the tool, model, and prompt.
3. Pick a few directions by visual appeal. Use reference images to explore expressions, poses, and scenes.
4. Choose a concept after looking at the variations. Decide how to turn it into website assets later.

No grading or automatic winner. The examples below help you find looks worth trying. The optional [website-asset workflow](ai-mascot-workflows.md) covers later image, SVG, and 3D routes.

## The Google dog: where it comes from

![Google’s Nano Banana Pro example: textured orange dog with a teal collar](assets/ai-mascot-tools/google-dog.jpg)

**Creator/source:** Google’s [official image-generation guide](https://ai.google.dev/gemini-api/docs/image-generation). The page explicitly credits **Nano Banana Pro** for this example. That model’s API name is `gemini-3-pro-image`.

**Published prompt:**

> An icon representing a cute dog. The background is white. Make the icons in a colorful and tactile 3D style. No text.

[Original image file](https://storage.googleapis.com/generativeai-downloads/images/Nano%20Banana%20Pro%20outputs%20for%20docs/01-an-icon-representing-a-cute-dog-the-background-is-.jpg). Retrieved **2026-10-11**. **Generation/publication date unknown; freshness within three months is unverified.** It is a raster image, not an SVG or 3D model. We did not generate it or test whether repeating the prompt reproduces it.

This is your preferred visual reference so far. Use its **tactile character style** to guide exploration; it does not yet establish a consistent set of poses.

## More public designs to inspect

<details>
<summary>Recraft: flat graphic mascot</summary>

![Recraft’s drone mascot](assets/ai-mascot-tools/recraft-drone.webp)

Mitya Meshcheryakov / Recraft, [Mascot Design](https://www.recraft.ai/blog/mascot-design), **2026-10-09**; retrieved 2026-10-11. Vendor identifies V4.1 Vector. This WebP preview does not let us inspect the original paths.

</details>

<details>
<summary>Midjourney: reference images combined into a scene</summary>

![Midjourney’s Edit Model example combining a boy and a monster](assets/ai-mascot-tools/midjourney-edit.png)

Midjourney, [Edit Model](https://docs.midjourney.com/hc/en-us/articles/48495453462797-Edit-Model); retrieved **2026-10-11**. **Example date unknown; three-month freshness unverified.** Exact generating version unspecified.

</details>

<details>
<summary>Older examples: Midjourney’s duck and Adobe’s illustration</summary>

![Legacy Midjourney duck reference example](assets/ai-mascot-tools/midjourney-omni.png)

Midjourney, [Omni Reference](https://docs.midjourney.com/hc/en-us/articles/36285124473997-Omni-Reference); retrieved 2026-10-11. **Legacy V7, undated and potentially older than three months.** Not a current V8.2 benchmark.

![Illustration accompanying Adobe’s vector-generation documentation](assets/ai-mascot-tools/adobe-vector.jpg)

Adobe, [vector documentation](https://helpx.adobe.com/illustrator/desktop/use-generative-ai/generate-scenes-subjects-and-icons.html), page updated **2026-06-01—older than three months**. Retrieved 2026-10-11. Image creation date/model unspecified; an accompanying illustration, not a verified generation output.

</details>

## Try the mascot in motion

**Start from your chosen character image, not a new text-only design.** Try a blink, head tilt, or small greeting with a fixed camera. This is a proposed experiment, not a test we ran. Large turns reveal invented details and can change the character; [Hailuo’s own guide](https://hailuoai.video/pages/blog/what-is-image-to-video) acknowledges this limitation.

The animation list below separates **image-to-video**, **performance transfer**, and **talking portraits**. Pick by the kind of motion you want. A rendered clip can help you judge personality; it does not provide a 3D rig or interactive mascot.

For the Google dog style, my first exploration would be **Flow or Kling image-to-video**. Add **Runway Act-Two** if you want to act out an expression, or **Pikaframes** if you already have two approved poses. This is a recommendation by documented workflow fit, not a quality ranking. Compare the face, collar, texture, and silhouette throughout the clip—not only its first frame.

## Multiple models with one budget

**Yes.** A browser platform can let you try several models with one credit pool. For concept exploration, check which models your plan includes and how much each attempt consumes. API services also centralize billing, but are optional for this decision.

| Platform | Useful route | Budget boundary |
| --- | --- | --- |
| [Recraft Studio](https://www.recraft.ai/pricing) | Explore several models alongside vector work | Browser credits and API Units are separate. |
| [Higgsfield](https://higgsfield.ai/creator-hub/help-center/credits/how-credits-work) | Image/video workflows | Subscription credits expire each cycle; free browser generations do not carry into CLI/MCP. |
| [Artlist](https://help.artlist.io/hc/en-us/articles/37462605912861-Studio-Understanding-AI-Credits) | Image, video and voiceover in one pool; also inspect its 3D tools | Generation costs depend on model/settings. Verify 3D entitlement separately. |
| [Krea](https://www.krea.ai/pricing) | Multi-model browser workspace | Model access varies by plan; personal monthly units do not roll over. |
| [fal](https://fal.ai/pricing) / [Replicate](https://replicate.com/docs/topics/billing) | Call different models from code | Usage-based billing; endpoint versions can differ from direct providers. |

For video exploration, [Artlist’s catalog](https://artlist.io/ai/video-generator), [Krea’s catalog](https://www.krea.ai/models), and [Higgsfield’s video workspace](https://higgsfield.ai/ai-video) list multiple model families. They are platforms, not additional model families. Check that the platform exposes the reference or motion-control feature you want before buying credits. Catalog listings alone do not prove live access: some pages still advertise Sora despite OpenAI’s shutdown notice.

No subscription or paid experiment was started. Shared billing does not guarantee consistent characters across different models.

<details>
<summary>Research notes and limits</summary>

This revision follows the user’s **no-grading** instruction. Public samples are selected examples, not comparable tests. Priorities remain visual quality, consistency, ease and cost, but there is no scoring table or automatic shortlist.

Research on 2026-10-11 opened primary documentation linked above. Discovery covered vector generation, reference consistency, model versions, shared-budget platforms, billing limits and conflicting claims. Follow-ups added `Dilum Sanjaya January 27 2026 ship selection Nano Banana Hunyuan3D Gemini Pro workflow` and official image-to-3D/export documentation. The supplied X thread returned 403; its pasted text is attributed separately in the workflow article. Freepik/Magnific billing pages were inaccessible and are not presented as verified alternatives.

A Recraft comparison claimed Adobe lacks vector generation; Adobe’s own documentation contradicts it. Vendor comparisons are not independent evidence. Independent issue reports about Artlist billing and legacy Midjourney references were anecdotal, not current performance measurements. Exact account access, repeatable poses, source-path quality, rigging, cleanup time, costs per accepted asset and commercial rights remain untested.

Repository-health tooling is inapplicable to this workflow discovery and was not run. No generation, conversion, coding prototype or rigging test ran. Public images are references for review, not broker-owned production assets.

### Animation research trail — 2026-10-11

Search-engine discovery and follow-ups used these queries, among others:

- `image to video mascot character reference animation Runway Kling Veo tools`
- `AI image to video character consistency limitations Luma Pika Adobe Firefly`
- `AI video generator mascot animation tools comparison independent tests 2026`
- `site.runwayml.com Act Two non human characters limitations`
- `site.seed.bytedance.com Seedance 2.0 video reference availability`
- `site.adobe.com firefly image to video first last frame motion reference`
- `site.github.com Wan-Video Wan2.2 Animate character`
- `site.artlist.io AI video models Kling Veo Seedance`

Opened primary pages: Runway Act-Two input guidance; Kling Motion Control; Flow’s model/feature matrix; Luma Ray3 Modify and licensing; Pika Pikaframes and pricing; Adobe camera-motion and transparency guides; Hedra Avatar; ByteDance Seedance 2.0 and Dreamina; Hailuo image-to-video; Grok Imagine Video 1.5; Wan2.2; the three platform catalogs above; and [official OpenAI deprecations](https://developers.openai.com/api/docs/deprecations). The linked tables below are the output location for verified capabilities and limitations. Runway and Kling explicitly expose performance transfer; ordinary image-to-video is a different trial.

**Evidence quality:** These are provider-documented capabilities, not our measurements. [AnimationBench](https://arxiv.org/abs/2604.15299), submitted 2026-04-16 (**older than three months**), argues that realism benchmarks miss stylized-animation and character-preservation differences. We opened the paper/abstract; its results do not establish a winner for this dog or current tool versions. An [anonymous Pika cropping report](https://www.reddit.com/r/pika_ai/comments/1t3m2dv/pikaframes_issues/) is a useful failure case, not a failure rate. A [ten-model user comparison](https://www.reddit.com/r/generativeAI/comments/1vds1uu/i_tested_10_ai_video_generation_models_heres_are/) discloses Adobe-provided credits and uses older/mixed versions; its subjective ranking is not adopted.

**Exclusions and gaps:** Human presenter products are less direct fits than tools accepting your mascot image. Wan remains an advanced option because its documented route needs a technical setup. Sora is excluded: OpenAI scheduled removal of Sora 2 and the Videos API for **2026-09-24**, before this snapshot. Provider claims of perfect consistency, rankings, and nominally free trials are not treated as verified performance or account entitlement. We did not log in, purchase credits, generate clips, run AnimationBench, inspect videos frame by frame, or test loops, audio, transparency exports, or commercial account rights. Linked showcases are vendor examples; creation dates are unknown unless explicitly supplied. No new preview files were added.

</details>

## List of tools

### Design exploration

| Tool | What people use it for | Example or starting point |
| --- | --- | --- |
| **Google / Nano Banana** | Character imagery, reference edits and UI concept images | Dog above uses **Pro**. Current guide also lists **2.1** as a distinct option. [Google guide](https://ai.google.dev/gemini-api/docs/image-generation) |
| **Midjourney** | Visual exploration and reference-based scene/character edits | Sanjaya used it for ship imagery. Current default is **V8.2**, with Edit Model replacing legacy Omni Reference. [Version](https://docs.midjourney.com/hc/en-us/articles/32199405667853-Version), [editing examples](https://docs.midjourney.com/hc/en-us/articles/48495453462797-Edit-Model) |
| **OpenAI image models** | Generate and edit raster artwork from prompts/references | Current guide lists **GPT Image 2.5 Sunburst / Flare**; warns recurring characters can drift. [Guide](https://developers.openai.com/api/docs/guides/image-generation) |
| **Recraft** | Graphic illustration and native vector generation | Published drone mascot uses **V4.1 Vector**; preview above. [Mascot tutorial](https://www.recraft.ai/blog/mascot-design) |
| **Adobe Illustrator / Firefly** | Generate vector subjects/icons, then refine in an editor | Style and color controls in [Adobe’s vector workflow](https://helpx.adobe.com/illustrator/desktop/use-generative-ai/generate-scenes-subjects-and-icons.html). This is an SVG route, not the only workflow. |
| **Ideogram / Leonardo** | Image exploration and reference-led variations | [Ideogram](https://docs.ideogram.ai/) documents 4.5 and editing tools; [Leonardo](https://leonardo.ai/learn/core-feature/how-to-create-consistent-characters-with-character-reference) teaches character references. Mascot reliability not tested here. |
| **Hunyuan3D** | Turn images into textured 3D meshes | Used in Sanjaya’s process. [Tencent repository](https://github.com/Tencent-Hunyuan/Hunyuan3D-2); [Artlist’s current hosted route](https://help.artlist.io/hc/en-us/articles/39755179247517-Hunyuan-3D-v3-1-Pro) lacks rigging/animation. |
| **Tripo / Meshy** | Alternative 3D-generation workflows | [Tripo](https://www.tripo3d.ai/) accepts images/text; investigate [Meshy’s browser rigging route](https://docs.meshy.ai/en/webapp/guides/3d-model/rigging) separately. No comparative test or production claim here. |
| **Gemini Pro / Claude Code** | Turn layout references into code; modify website/source assets | Gemini Pro is named in Sanjaya’s UI process. [Claude Code](https://code.claude.com/docs/en/model-config) is a coding agent, not an image model; record the actual selected model. |

### Animation and video: five distinct workflows to try

**Checked 2026-10-11. No grading; versions below identify the documented feature, not necessarily the provider’s newest model.** Follow the source links for tutorials and vendor showcases. Showcase creation dates are unknown unless stated; freshness within three months is unverified. Kling’s linked guide is dated 2026-03-05 (**older than three months**).

| Tool / feature | What to try with a mascot | Important boundary |
| --- | --- | --- |
| **Google Flow / Veo 3.1** — [feature matrix](https://support.google.com/flow/answer/16352836?hl=en) | Animate an approved image with Frames to Video; use Ingredients/References for character-led scenes | Features depend on model. Veo 3.1 reference-based clips are 8 seconds in the documented modes; consistency is not guaranteed. Nano Banana makes the still, Veo makes the video. |
| **Kling / VIDEO 3.0 Motion Control** — [guide and showcases](https://kling.ai/quickstart/motion-control-user-guide) | Give a character image and action video to copy a gesture or performance | Facial binding uses facial information, not clothing/props. The guide warns animal-to-human face differences can degrade results; only one element is supported. For a nonhuman dog, also try ordinary image-to-video. |
| **Runway / Act-Two** — [performance guide and examples](https://help.runwayml.com/hc/en-us/articles/42311337895827-Performance-Capture-with-Act-Two) | Record yourself expressing a mood; transfer it to a character image with defined eyes and mouth | Runway documents nonhuman characters, but recommends waist-up framing. Image inputs add camera/environment motion; gesture control is unavailable with character-video inputs. Not a dog-walking rig. |
| **Luma Dream Machine / Ray3 Modify** — [character-reference guide](https://lumalabs.ai/learning-hub/ray3-modify-user-guide) | Use character references with keyframes, or replace a performer in existing footage | Referenced characters adapt to the footage’s lighting/style. Modify input video is limited to 10 seconds in this guide. [Free/Lite generations remain noncommercial after upgrading](https://lumalabs.ai/learning-hub/licensing). |
| **Pika / Pikaframes** — [keyframe guide](https://create.pika.art/apps/pikaframes) | Connect two to five approved poses, such as neutral to happy | Consecutive images become transitions, not an editable character rig. Five keyframes are limited to 720p; up to four allow 1080p. [Browser top-up credits do not cover API/iOS](https://pika.art/pricing). |

<details>
<summary>More options: speech, transparent backgrounds, other models, and manual animation</summary>

| Tool / feature | Why investigate it | Boundary / source |
| --- | --- | --- |
| **Hedra Avatar** | Talking or singing mascot from a portrait and audio | Audio is required; optimized for talking portraits, not general locomotion. [Model page](https://www.hedra.com/models/video/hedra/avatar) and Hedra’s [talking blue mascot example](https://www.hedra.com/examples/chat-mascot-app-demo-hedra-avatar) provide vendor-attributed outputs (**creation dates unknown; three-month freshness unverified**). |
| **Adobe Firefly Video** | Start/end frames, camera-motion references, and background-free compositing | [Camera reference](https://helpx.adobe.com/firefly/web/work-with-audio-and-video/work-with-video/match-camera-motion-to-reference-video.html) copies camera motion, not an actor’s body. [Transparency guide](https://helpx.adobe.com/firefly/web/work-with-audio-and-video/work-with-video/generate-videos-with-transparent-backgrounds.html), updated 2026-08-18, requires transparent PNG frame inputs and exports separate foreground/alpha videos for compositing. It does not promise a ready-to-use transparent website clip. |
| **ByteDance Seedance 2.0 / Dreamina** | Combine image, video, and audio references for scenes and motion ideas | [ByteDance model page](https://seed.bytedance.com/en/seedance2_0) establishes inputs; [Dreamina’s guide](https://dreamina.capcut.com/tools/seedance-2-0) provides a browser route. Exact regional/account access was not tested. |
| **MiniMax / Hailuo** | Another image-to-video route for simple movement | [Provider guide](https://hailuoai.video/pages/blog/what-is-image-to-video) acknowledges drift, invented hidden areas, and smudged text. Record the selected model; Hailuo is the interface. |
| **Grok Imagine / Video 1.5 Fast** | Another browser/app trial for short clips with sound | [Official release](https://x.ai/news/grok-imagine-video-1-5) distinguishes the browser/app Fast model from API offerings. No claim here that current access is free or that it preserves mascots better. |
| **Wan2.2 / Wan-Animate** | Advanced character motion transfer or replacement from an image plus driving video | [Official repository](https://github.com/Wan-Video/Wan2.2) documents both modes. Setup and compute make it a less direct one-off browser trial; newer research is not proof of the same downloadable feature. |
| **Rive** | Manually authored, repeatable expressions and interactive states if generated motion drifts | [Official state-machine documentation](https://rive.app/docs/editor/state-machine) describes interactive animation. This is authored animation, not video generation or automatic conversion of the textured dog. |

</details>
