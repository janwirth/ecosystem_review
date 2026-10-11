# From design exploration to website assets

**Reading time: about 3 minutes.** Research checked 2026-10-11. These are proposed workflows, not completed tests.

## Start with the look you like

The [Google dog](brand-concept-mascot-development.md#the-google-dog-where-it-comes-from) is your preferred reference so far. It is a **Nano Banana Pro image**, not a 3D model. Its tactile appearance can work as a website image immediately; SVG conversion and 3D conversion are optional routes.

## The full flow

1. **Explore designs.** Use an image tool to try characters and styles. Save the attractive results.
2. **Approve one character.** Keep a reference sheet for its face, proportions, colors and material/style. Use that reference for new poses.
3. **Choose the website asset.** Follow one route below. Different placements can use different routes.
4. **Build the interface.** Give a coding tool the approved layout references and exported assets. Describe what each control does.
5. **Check the actual website.** Review identity, appearance, load time and interactions on mobile as well as desktop.

| Route | Process | Website result |
| --- | --- | --- |
| **Images** | Approved design; reference-based pose edits; export images | Hero art, illustrations and static mascot poses |
| **SVG** | Approved design; generate vectors or redraw; clean and group shapes | Scalable graphic assets; optional simple animation |
| **3D** | Approved image; image-to-3D; inspect/repair mesh and textures; export GLB | Rotatable mascot or interactive scene; character animation needs a rig |

For the dog’s textured look, **images or 3D are natural routes to investigate**. SVG redrawing may simplify away the texture you like. That is a visual tradeoff, not a reason to force the design into vectors.

## Dilum Sanjaya’s ship-selection process

**Source:** [original X thread](https://x.com/DilumSanjaya/status/2016193959408836932), January 27 thread supplied by the user. **Historical example, older than three months.** X retrieval returned 403; this extraction uses the text you pasted, with the [Reddit cross-post](https://www.reddit.com/r/TopologyAI/comments/1schgvp/vibecoded_space_game_ship_selection_ui_with/) as supporting context.

| Track | Extracted process |
| --- | --- |
| **3D assets** | Make ship images with Nano Banana and Midjourney. Convert the images into 3D assets with Hunyuan3D. |
| **Interface** | Use the ship images to generate UI ideas with Nano Banana. Use Gemini Pro to turn the chosen UI direction into code. |

He says Midjourney’s UI elements can be unclear as coding inputs. The practical lesson: **choose a readable layout reference**, not only an attractive image.

The supplied material does **not** identify complete prompts, exact versions, engine, cleanup work or rigging. A commenter’s question about bones and sizes is not evidence that those problems were solved.

## What image-to-3D adds—and what it does not

[Tencent’s Hunyuan3D repository](https://github.com/Tencent-Hunyuan/Hunyuan3D-2) documents shape generation, texture generation and mesh export. [Artlist’s Hunyuan 3D v3.1 Pro guide](https://help.artlist.io/hc/en-us/articles/39755179247517-Hunyuan-3D-v3-1-Pro), published **2026-10-08**, describes image-to-3D but explicitly excludes rigging and animation in that workflow.

A ship can rotate as one object. A mascot that walks or gestures needs usable joints, skinning and animation, plus a check that hidden sides still match the design. A 3D-looking image does not supply those parts. [Meshy’s browser rigging guide](https://docs.meshy.ai/en/webapp/guides/3d-model/rigging) covers quadrupeds; its [API guide](https://docs.meshy.ai/en/api/rigging) is limited to standard humanoids. Check the actual route for a dog.

GLB is a practical web handoff; [Three.js GLTFLoader](https://threejs.org/docs/pages/GLTFLoader.html) loads glTF assets. That loader is a possible implementation route, not evidence that Sanjaya used Three.js.

**Next:** review the [tool list and examples](brand-concept-mascot-development.md), then choose which website uses need images, SVG or 3D. No grading or forced five-tool selection.
