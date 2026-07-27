# Audio Genre & BPM Detection

> [!NOTE]
> **Status:** DRAFT · **Authoring:** AI-assisted, human-reviewed.

Snapshot: **2026-07-07**.

So you have an audio file — an MP3, a WAV, a decoded browser `AudioBuffer`, a live microphone stream — and you want to know its **tempo (BPM)** and/or its **genre**. This article surveys every practical tool for those two jobs across JavaScript / Node / browser, the BEAM (Erlang / Elixir / Gleam), standalone binaries, and hosted cloud APIs.

Two things you should know before reading further:

1. **Two APIs you might have reached for are gone.** [Spotify's `/audio-features`](#spotify-web-api--audio-features-) endpoint was **deprecated 2024-11-27** — new apps get a 403. [AcousticBrainz](#acousticbrainz) **shut down 2022** — but its 7.5M-recording frozen dataset dump is still downloadable, and useful as an offline lookup table. See [Disregarded](#disregarded).
2. **The BEAM ecosystem has no native genre/BPM package.** Not on Hex, not on `packages.gleam.run`. Every BEAM story here is a Port to a CLI, a NIF wrapping a native library, or ONNX inference via [Bumblebee](https://github.com/elixir-nx/bumblebee). See [The BEAM gap](#the-beam-gap).

If you're picking a tool for a specific job, jump to **[When to use what](#when-to-use-what)**.

## Table of Contents

1. [Summary](#summary)
2. [State of the ecosystem](#state-of-the-ecosystem)
3. [Background — how these detectors actually work](#background--how-these-detectors-actually-work)
4. [Research Method](#research-method)
5. [Disregarded](#disregarded)
6. [When to use what](#when-to-use-what)
7. [BPM / tempo / beat detection](#bpm--tempo--beat-detection)
   - [Standalone binaries & C/C++ libraries](#standalone-binaries--cc-libraries)
   - [Python libraries](#python-libraries--bpm)
   - [JavaScript / npm / browser](#javascript--npm--browser--bpm)
8. [Genre / mood classification](#genre--mood-classification)
   - [Essentia + Essentia Models](#essentia--essentia-models)
   - [Python-side deep-learning classifiers](#python-side-deep-learning-classifiers)
   - [Browser / WASM genre detection](#browser--wasm-genre-detection)
9. [The BEAM gap — Erlang, Elixir, Gleam](#the-beam-gap)
10. [Hosted / cloud APIs](#hosted--cloud-apis)
11. [Accuracy realities](#accuracy-realities)
    - [BPM in 2026 — not solved for complex material](#bpm-in-2026--not-solved-for-complex-material)
    - [Genre — GTZAN is broken, top-k is the right contract](#genre--gtzan-is-broken-top-k-is-the-right-contract)
12. [Leaderboards](#leaderboards)

## Summary

| Capability | 🖥️ Standalone CLI / C++ | 🐍 Python | 🌐 JS / npm / browser | ☁️ Hosted API | ☎️ BEAM |
| --- | --- | --- | --- | --- | --- |
| **BPM / tempo — classical DSP** | · [🥇](#leaderboards) [aubio](#aubio) (GPL-3.0) · [SoundTouch / BPMDetect](#soundtouch--bpmdetect) (LGPL-2.1) · [bpm-tools](#bpm-tools) (GPL-2.0) | · [librosa](#librosa) (ISC) | · [🥇](#leaderboards) [web-audio-beat-detector](#web-audio-beat-detector) (MIT) · [realtime-bpm-analyzer](#realtime-bpm-analyzer) (Apache-2.0) · [music-tempo](#music-tempo) (MIT, dormant) · [bpm-detective](#bpm-detective) (⚠️ no license) | · [Sonic API by Zplane](#sonic-api-zplane) | · Port → [aubio](#aubio) / [bpm-tools](#bpm-tools) |
| **BPM / tempo — deep learning** | · [Sonic Annotator](#sonic-annotator) + [QM Vamp Plugins](#qm-vamp-plugins) (GPL-2.0) | · [🥇](#leaderboards) [Beat This!](#beat-this-) (MIT, SOTA 2024) · [madmom](#madmom) (BSD code, non-commercial weights; ⚠️ broken on new Python) · [TempoCNN](#tempocnn) (AGPL-3.0) | — (no deep-NN tempo model shipped for tfjs) | · [Cyanite.ai](#cyaniteai) · [AudD](#audd) (ID → metadata lookup) | · Bumblebee + ONNX export of TempoCNN — no packaged recipe today |
| **Genre / mood / tag classification** | · Essentia CLI (`essentia_streaming_extractor_music`) + Essentia Models | · [🥇](#leaderboards) [Essentia](#essentia) + [Essentia Models](#essentia-models-discogs-effnet--mtg-jamendo--tempocnn) (AGPL-3.0 + non-commercial weights) · [musicnn](#musicnn) (dormant) · [OpenL3](#openl3) embeddings (dormant) | · [🥇](#leaderboards) [essentia.js](#essentiajs) (AGPL-3.0) · YAMNet-tfjs (coarse ~15 music tags) | · [🥇](#leaderboards) [Cyanite.ai](#cyaniteai) (23 main + 58 sub + 5000 tags, from €290/mo) · [AudD](#audd) · Musiio (⚠️ SoundCloud-only) | · Bumblebee + ONNX Discogs-EffNet-400 — no packaged recipe today |
| **Song ID → tag lookup** | · [Chromaprint](#chromaprint--acoustid) / `fpcalc` (LGPL-2.1+) | — | · npm `chromaprint` bindings | · [AcoustID](#chromaprint--acoustid) (free) · [MusicBrainz](#musicbrainz) (free, no BPM, sparse genre) · [GetSongBPM](#getsongbpm) (free, attribution) · [Songstats](#songstats) (enterprise) | · Port → `fpcalc` |
| **Frozen dataset lookup** | · [AcousticBrainz dump](#acousticbrainz) (CC0, ≤2022 catalogue only) | · same | · same | — | · same |

> [!IMPORTANT]
> **Licensing is the deal-breaker in this space, not accuracy.** The classical-DSP leaders are GPL/LGPL (aubio GPL-3.0, SoundTouch LGPL-2.1, bpm-tools GPL-2.0). Essentia and essentia.js are AGPL-3.0, and their pre-trained model weights are **CC BY-NC-SA 4.0** (non-commercial only). The MIT-licensed shortlist for commercial closed-source apps is small: **[Beat This!](#beat-this-)** (Python, MIT), **[web-audio-beat-detector](#web-audio-beat-detector)** (JS, MIT), and paid hosted APIs. If you're building a proprietary product, filter this article by license before capability.

## State of the ecosystem

**BPM detection** is a mature space with a clear split between:
- **Classical DSP** (onset detection + autocorrelation): fast, CPU-only, MIT/GPL, and *good enough for 4/4 dance music*. This is [aubio](#aubio), [bpm-tools](#bpm-tools), [SoundTouch's BPMDetect](#soundtouch--bpmdetect), [web-audio-beat-detector](#web-audio-beat-detector).
- **Deep learning** (RNN / transformer beat trackers): higher accuracy on complex material — jazz, classical, orchestral, non-4/4 meter — but requires PyTorch/TensorFlow and typically a GPU. This is [Beat This!](#beat-this-) (current SOTA per ISMIR 2024), [madmom](#madmom) (superseded but still competitive), [TempoCNN](#tempocnn).

For most music library indexing and DJ tooling, classical DSP is fine. For a mixed music library that includes jazz, classical, or world music, use Beat This! or a hosted API.

**Genre detection** has a very different shape:
- There is **no MIT-licensed deep-NN music-genre classifier** in the open-source ecosystem. [Essentia](#essentia) + [Essentia Models](#essentia-models-discogs-effnet--mtg-jamendo--tempocnn) is the closest thing to a canonical stack — but it's AGPL-3.0 code with CC-BY-NC-SA weights, which excludes most commercial use.
- [essentia.js](#essentiajs) is the only serious in-browser deep-learning genre classifier (WASM build of Essentia + tfjs models). TensorFlow.js has **no music-genre model** in the official `@tensorflow-models` catalogue; YAMNet-tfjs covers ~15 coarse music tags mixed into AudioSet's 521-class ontology.
- Historical Python classifiers ([musicnn](#musicnn), [OpenL3](#openl3), [Marsyas](#marsyas)) are dormant and superseded by [Essentia](#essentia)'s Discogs-EffNet family.
- Commercial hosted classification via [Cyanite.ai](#cyaniteai) is the strongest option if closed-source licensing is a constraint — but starts at €290/month.

**The BEAM ecosystem has a total gap here.** No Hex or `packages.gleam.run` package computes BPM or genre. See [The BEAM gap](#the-beam-gap) for the four FFI paths (Port to `aubiotempo`, Port to `sonic-annotator`, NIF wrapping libaubio/Essentia, ONNX inference via Nx/Bumblebee).

**Hosted APIs** are split into three shapes:
- **Detection APIs** — you upload audio, they return BPM + genre + tags: [Cyanite.ai](#cyaniteai), [Sonic API by Zplane](#sonic-api-zplane).
- **Identification APIs** — you upload audio, they return the *known* track's metadata (which may or may not include BPM/genre): [AudD](#audd), [AcoustID](#chromaprint--acoustid).
- **Lookup APIs** — you already know the track ID, look up metadata: [GetSongBPM](#getsongbpm), [MusicBrainz](#musicbrainz), [Songstats](#songstats).

Two former staples are dead: [Spotify `/audio-features`](#spotify-web-api--audio-features-) (deprecated 2024-11-27) and [AcousticBrainz](#acousticbrainz) (shut down 2022, dataset still downloadable).

## Background — how these detectors actually work

Three algorithm families cover almost every tool in this article. Which family a tool uses determines its accuracy ceiling, its CPU/GPU needs, and (indirectly) its license story.

**Classical BPM detection** = onset detection + autocorrelation.
1. Compute a *spectral flux* or *energy envelope* per short frame (e.g. 512 samples at 44.1 kHz → 11.6 ms).
2. Peak-pick the envelope to get *onset events* (drum hits, note attacks).
3. Autocorrelate the onset series across candidate lags (e.g. 60–200 BPM → lags 300 ms to 1000 ms).
4. Pick the lag with the highest autocorrelation → tempo.

Cheap (single-threaded CPU, ~10× realtime on a phone), MIT/GPL-friendly, and *reliable on 4/4 dance music*. Fails on rubato, non-4/4 meter, sparse percussion, or ambiguous octave (½× or 2×).

**RNN/DBN BPM detection** (madmom, TempoCNN era) trains a recurrent network to predict a per-frame beat probability, then a Dynamic Bayesian Network post-processes the sequence to a globally-consistent beat/downbeat track. Better accuracy on complex material; needs a trained model + Python.

**Transformer / frame-wise BPM detection** (Beat This! 2024) drops the DBN and lets a transformer predict beats directly. Current SOTA on standard benchmarks per ISMIR 2024.

**Genre classification** in 2026 typically means one of:
- **Feature-engineering + classifier** — extract MFCC / chroma / spectral centroid / etc. (via [meyda](#meyda) or [librosa](#librosa)), feed a SVM or shallow classifier. Historical baseline (Tzanetakis 2002 style).
- **Embedding + classifier** — run audio through a pre-trained embedding network ([OpenL3](#openl3), CLAP, MERT, YAMNet), then classify the embedding with a small head. Common for zero-shot / few-shot.
- **End-to-end CNN** — spectrogram or waveform → CNN → tag distribution. This is Essentia's [Discogs-EffNet-400](#essentia-models-discogs-effnet--mtg-jamendo--tempocnn), [MTG-Jamendo classifiers](#essentia-models-discogs-effnet--mtg-jamendo--tempocnn), and historically [musicnn](#musicnn).

Genre classifiers always output a **distribution over tags** — teach yourself to consume top-*k* probabilities, not a single label. See [Genre realities](#genre--gtzan-is-broken-top-k-is-the-right-contract).

## Research Method

### Scoring Dimensions

Same rubric as [gleam/databases.md#scoring-dimensions](gleam/databases.md#scoring-dimensions), adapted for the cross-ecosystem scope of this article:

- **Stars:** 🟩🟩 ≥5000★, 🟩 ≥500★, 🟨 ≥50★, 🟥 <50★. For npm packages a weekly-downloads ceiling is used as a proxy (🟩🟩 ≥50k/wk, 🟩 ≥5k/wk, 🟨 ≥500/wk, 🟥 <500/wk).
- **License:** 🟩🟩 MIT/Apache-2.0/BSD/ISC, 🟩 LGPL, 🟥 GPL/AGPL/no-license/proprietary. This article weights license more heavily than the Gleam articles — many readers are picking for a commercial product.
- **Runtime compat:** 🟩🟩 dual-target-ish (works on multiple runtimes: Python + CLI + WASM), 🟩 one runtime, 🟥 heavy deps (GPU-required, TF 1.x-pinned).
- **Maintenance:** 🟩🟩 <3 mo, 🟩 <1 yr, 🟨 <2 yr, 🟥 older.
- **Age:** 🟩🟩 ≥3 yrs, 🟩 ≥1 yr, 🟨 ≥3 mo, 🟥 <3 mo.
- **README maturity:** 🟩🟩 full guide + examples, 🟩 clear tagline + usage, 🟥 minimal/template.
- **Accuracy tier:** 🟩🟩 deep-NN SOTA, 🟩 classical DSP or older DL, 🟨 tag-lookup only, 🟥 dormant/broken.

**Leaderboard:** 🟥 = −1, 🟨 = 0, 🟩 = 1, 🟩🟩 = 2. Sum of 7 dims, max 14.

### Discovery

Searches run against:
- GitHub Topics: `music-information-retrieval`, `beat-detection`, `tempo-detection`, `genre-classification`, `bpm`, `audio-analysis`.
- npm `beat`, `bpm`, `tempo`, `audio-analysis`, `music-tempo`, `genre`.
- PyPI keywords `music`, `mir`, `beat-tracking`, `tempo`, `genre-classification`.
- Hex.pm and `packages.gleam.run`: `audio`, `bpm`, `tempo`, `beat`, `music`, `dsp`, `genre` — **all returned zero audio-analysis packages** (only unrelated BPMN engines, Swatch time, and music-theory helpers).
- Papers with Code: `beat-tracking`, `music-genre-classification`, `music-tagging`.
- ISMIR 2023 / 2024 proceedings for current SOTA references.
- Vendor sites for hosted APIs (Cyanite, AudD, Zplane, Songstats, GetSongBPM).

## Disregarded

Listed up-front so readers see "this corner has been considered" before drilling into recommendations. Each row is a tool that will surface in searches but should **not** be used for new work — with the reason.

| Tool | Reason disregarded |
| --- | --- |
| [Spotify Web API `/audio-features`](https://developer.spotify.com/blog/2024-11-27-changes-to-the-web-api) | **Deprecated 2024-11-27.** Returns 403 for all new apps. Only pre-cutoff apps with an approved quota extension still have access. No public replacement roadmap 18 months later. Do not build on this. |
| [AcousticBrainz](https://acousticbrainz.org/download) API | **Shut down 2022-02-16.** But the **frozen dataset dump (~7.5M recordings, CC0)** is still downloadable and useful as a lookup table for tracks that existed in the pre-2022 catalogue. Treat as a static resource keyed by MusicBrainz Recording ID, not an API. |
| Musiio | Acquired by SoundCloud 2022. No third-party API — Musiio-by-SoundCloud is an internal product. Not procurable. |
| [musicnn](https://github.com/jordipons/musicnn) | Dormant since 2023-06; pinned to TensorFlow 1.x which breaks on modern Python. Historically the reference small-CNN music tagger; **superseded by Essentia's Discogs-EffNet family**. |
| [OpenL3](https://github.com/marl/openl3) | Dormant since 2023-06; TF-1.x-era. Embeddings work only inside a larger classifier pipeline; superseded by **CLAP** and **MERT** embeddings — but neither of those has shipped as a batteries-included genre CLI yet either. |
| [Marsyas](https://github.com/marsyas/marsyas) | Historically important (Tzanetakis, originator of GTZAN); dormant since 2023-04. Include as **prior art**, not for new work. |
| [MIRtoolbox](https://www.jyu.fi/hytk/fi/laitokset/mutku/en/research/materials/mirtoolbox) | MATLAB-only, closed runtime. Not viable for cross-ecosystem work. |
| ffmpeg / SoX / ffprobe | **Read** BPM/genre from ID3/Vorbis tags if present; **do not compute** either. Use `ffprobe -show_entries format_tags` if the tag is already there. Not detection. |
| [`bpm-detective`](https://github.com/tornqvist/bpm-detective) | Included in [JS section](#bpm-detective) but flagged — **no license declared** (all-rights-reserved by default under copyright law), dormant since 2021. High weekly-download count (~24k/wk) is misleading; likely CDN/build-graph rather than active adoption. Prefer [web-audio-beat-detector](#web-audio-beat-detector) or [realtime-bpm-analyzer](#realtime-bpm-analyzer). |
| VST BPM-detector plugins | DAW-only; not usable from code. Out of scope. |
| MusicBrainz (as a BPM/genre source) | **No BPM field** in the schema; genre is user-editable tags with sparse coverage. Include as one line under [song-ID lookup](#musicbrainz). |

> [!CAUTION]
> **[madmom](#madmom)'s PyPI release is broken on modern Python.** `pip install madmom` v0.16.1 pins `python < 3.10` and `numpy < 1.20`, both of which conflict with any current Python 3.11+ environment. Workaround: `pip install git+https://github.com/CPJKU/madmom.git` (the `master` branch relaxed the pins; no new PyPI release since 2018). If you want a maintained MIT-licensed alternative from the same lab, use **[Beat This!](#beat-this-)** instead.

## When to use what

| Your job | Recommended tool | Runtime | License | Cost | Accuracy tier |
| --- | --- | --- | --- | --- | --- |
| **Batch BPM on 10k MP3s, offline, want highest accuracy** | [Beat This!](#beat-this-) | Python + PyTorch (GPU strongly preferred) | MIT | Free | Deep-NN SOTA (ISMIR 2024) |
| **Batch BPM on 10k MP3s, offline, no GPU, no Python** | [aubio](#aubio) (`aubiotempo`) or [bpm-tools](#bpm-tools) (`bpm`) | Standalone CLI | GPL-3.0 / GPL-2.0 | Free | Classical DSP — good on 4/4 dance, weak on complex meter |
| **BPM in the browser from a decoded `AudioBuffer`** | [web-audio-beat-detector](#web-audio-beat-detector) | JS (browser + Node) | MIT | Free | Classical DSP |
| **BPM realtime from microphone or live audio stream** | [realtime-bpm-analyzer](#realtime-bpm-analyzer) | AudioWorklet | Apache-2.0 | Free | Classical DSP |
| **BPM + genre + mood + key + everything, self-hosted, non-commercial OK** | [Essentia](#essentia) + [Essentia Models](#essentia-models-discogs-effnet--mtg-jamendo--tempocnn) | Python / C++ / WASM | AGPL-3.0 + CC-BY-NC-SA weights | Free (non-commercial) | Deep-NN |
| **BPM + genre in the browser** | [essentia.js](#essentiajs) | WASM in browser | AGPL-3.0 + CC-BY-NC-SA weights | Free (non-commercial) | Deep-NN |
| **Genre + mood + BPM + key for a closed-source commercial product** | [Cyanite.ai](#cyaniteai) | Cloud REST | Proprietary | From €290/mo | Deep-NN |
| **Recognise a known commercial track → look up its metadata** | [AcoustID](#chromaprint--acoustid) + [MusicBrainz](#musicbrainz) + [GetSongBPM](#getsongbpm) | Cloud (all three free) | LGPL / CC / attribution | Free | N/A (lookup) |
| **Fingerprint an unknown snippet → identify it (Shazam-style)** | [AudD](#audd) | Cloud | Proprietary | $2–5 / 1000 files | N/A (recognition) |
| **Anything from Elixir / Gleam / Erlang** | Port to [aubio](#aubio) / [bpm-tools](#bpm-tools) / [Sonic Annotator](#sonic-annotator) | Shell-out | GPL (of the shelled binary) | Free | Classical DSP or deep-NN via Sonic Annotator + Beat This! wrapper |
| **Look up BPM on a pre-2022 track without any API call** | Download the [AcousticBrainz dataset dump](https://acousticbrainz.org/download) | Static file lookup | CC0 (dataset) | Free | N/A (frozen data) |
| **Read a BPM tag already in the file's metadata** | `ffprobe -show_entries format_tags` (ffmpeg CLI) | Standalone CLI | LGPL/GPL | Free | Tag read only |

> [!IMPORTANT]
> Two rules for reading this table:
> 1. **Genre is not a single label.** Every deep-NN classifier outputs a probability distribution. Design your product's data model for "top-*k* tags with confidence." A single-label API contract is a design smell — the top-1 is often wrong by one row (Discogs-400 has many neighbouring styles).
> 2. **License filters your options harshly.** For closed-source commercial products, your practical open-source shortlist is **Beat This! (BPM)** + **web-audio-beat-detector (BPM in browser)**. Everything else is either GPL/AGPL, has non-commercial model weights, or is a paid hosted API.

## BPM / tempo / beat detection

### Standalone binaries & C/C++ libraries

The workhorses. Every large open-source DJ/DAW project (Mixxx, Audacity, Rekordbox-alternatives) uses one of these under the hood. All classical DSP; MIT-licensed options do not exist in this tier.

#### aubio

- 🔗 [github.com/aubio/aubio](https://github.com/aubio/aubio) · 3,721★ · **GPL-3.0** · last commit **2026-04-10** 🟩
- **Capability:** BPM + onset + pitch + note detection. No genre.
- **Algorithm:** Classical DSP — spectral flux onset detection + autocorrelation tempo. Multiple candidate algorithms tunable via CLI flags.
- **Distribution:** C library + Python bindings (PyPI `aubio` 0.4.9, from Feb 2019 — build-from-source is typical) + CLIs (`aubiotrack`, `aubiotempo`, `aubioonset`, `aubiocut`, `aubionotes`).
- Ships in Homebrew, apt, most Linux distros.

```bash
# Batch: tempo of every MP3 in a folder
for f in *.mp3; do
  echo -n "$f: "
  aubiotempo "$f"
done

# Streaming beat timestamps
aubiotrack track.wav
```

**Gotchas.** GPL-3.0 blocks proprietary linking. The 2019 PyPI wheel is 7 years old; the fresh `master` builds fine but you'll need `pip install git+https://github.com/aubio/aubio` or brew/apt. No maintained JavaScript binding (the `aubio-js` npm package is a 2018 fork). Good on 4/4 dance material 60–200 BPM; weaker on complex meter and rubato.

#### SoundTouch / BPMDetect

- 🔗 [codeberg.org/soundtouch/soundtouch](https://codeberg.org/soundtouch/soundtouch) (moved off GitHub) · **LGPL-2.1** · active
- **Capability:** BPM only (offline). Also pitch-shifting / time-stretching — the BPMDetect class is one component of a broader audio-processing library.
- **Algorithm:** Onset envelope + autocorrelation, classical.
- **Distribution:** C++ library, embedded in **Mixxx** (default analyzer), **Audacity**, and dozens of open-source DJ tools.
- **License win:** LGPL-2.1 is friendlier than aubio's GPL-3.0 for linking into proprietary products — you can link dynamically without contaminating your app.

Not typically used as a standalone CLI. The path is: `#include <soundtouch/BPMDetect.h>`, feed PCM samples in chunks, call `getBpm()`. See Mixxx's analyzer source for a reference integration.

#### bpm-tools

- 🔗 [pogo.org.uk/~mark/bpm-tools/](https://www.pogo.org.uk/~mark/bpm-tools/) (upstream) · GitHub mirrors: [MrKyr/bpm-tools](https://github.com/MrKyr/bpm-tools) · **GPL-2.0** · last upstream release ~2016
- **Capability:** BPM only.
- **Algorithm:** Autocorrelation over energy envelope. Old-school and well-tuned for 4/4 dance music (60–180 BPM).
- **Distribution:** Single small C binary + `bpm-tag` shell wrapper. Ships in Homebrew, apt, most distros.

```bash
# Feed raw PCM from any format via SoX
sox track.mp3 -r 44100 -c 1 -t raw - | bpm

# One-liner for a folder — the `bpm-tag` wrapper writes ID3 BPM tags
find . -name '*.mp3' -exec bpm-tag -f {} \;
```

**Gotchas.** Input must be raw mono PCM at 44.1 kHz — hence the `sox … | bpm` pattern. Tuned for dance music; less reliable outside 60–180 BPM. Excellent choice for a Port-based BEAM integration because the binary is tiny (~10 KB) and the CLI is UNIX-clean.

#### Sonic Annotator

- 🔗 [github.com/sonic-visualiser/sonic-annotator](https://github.com/sonic-visualiser/sonic-annotator) · 46★ · **GPL-2.0** · last commit 2025-05-28 🟩
- **Capability:** Runs any installed **Vamp plugin** over an audio file and emits RDF or CSV. With [QM Vamp Plugins](#qm-vamp-plugins) installed → BPM, beats, downbeats, key, chords, segmentation, timbre.
- **Distribution:** Standalone binary (Linux / macOS / Windows). Vamp plugins are separate `.so`/`.dylib`/`.dll` files.

```bash
# Batch: extract beats + downbeats from every WAV in a folder using QM Bar/Beat Tracker
sonic-annotator -t qm-barbeat-tracker.n3 -w csv --csv-force *.wav
```

Use case: batch analysis pipelines where you want multiple features per pass (BPM + beats + downbeats + key in one command). Slower than aubio for BPM-only jobs but more flexible.

#### QM Vamp Plugins

- 🔗 [github.com/c4dm/qm-vamp-plugins](https://github.com/c4dm/qm-vamp-plugins) · 36★ · **GPL-2.0** · last push 2021-06-02 🟨 (quiet but stable)
- Ships **13 plugins** including Tempo & Beat Tracker (BeatRoot), Bar/Beat Tracker, Key Detector, Chord Detector.
- The canonical academic MIR plugin set from Queen Mary University of London Centre for Digital Music.

Use with [Sonic Annotator](#sonic-annotator) for batch, or with Sonic Visualiser for GUI inspection.

### Python libraries — BPM

Where the state-of-the-art beat trackers live. Requires a Python environment; typically pairs with PyTorch or TensorFlow for the deep-learning options.

#### Beat This!

- 🔗 [github.com/CPJKU/beat_this](https://github.com/CPJKU/beat_this) · 327★ · **MIT** · last commit 2026-05-28 🟩 · v1.1.0 (2026-04-14)
- **Capability:** Beat + downbeat detection. Tempo is derivable from beat interval.
- **Algorithm:** Transformer / frame-wise beat prediction from the ISMIR 2024 paper "Accurate Beat Tracking Without DBN Postprocessing." Drops madmom's Dynamic Bayesian Network post-processing.
- **Distribution:** Python + PyTorch 2.0+.
- **License win:** MIT — the strongest open-source SOTA option for closed-source commercial use.

```python
from beat_this.inference import File2Beats

# Pretrained "final0" checkpoint is downloaded automatically on first run
f2b = File2Beats(checkpoint_path="final0", device="cuda", dbn=False)
beats, downbeats = f2b("track.mp3")  # numpy arrays of timestamps in seconds
```

**Gotchas.** PyTorch dependency is heavy. GPU strongly preferred — CPU fallback exists but is slow (roughly 5–10× realtime on CPU vs 100× on GPU). No genre. Optional `dbn=True` mode falls back to madmom's DBN for edge cases if you want the belt-and-braces approach.

#### madmom

- 🔗 [github.com/CPJKU/madmom](https://github.com/CPJKU/madmom) · 1,670★ · **BSD-3-Clause** (code) + **CC BY-NC-SA 4.0** (model weights) · last commit **2024-08-25** 🟨 · last release v0.16.1 (Nov 2018)
- **Capability:** BPM + downbeat + beat + onset + key + chord + piano transcription. Broadest MIR feature set on Python.
- **Algorithm:** RNN + DBN (Dynamic Bayesian Network) post-processing. The classic offline high-accuracy stack.
- **Distribution:** Python.

> [!CAUTION]
> **`pip install madmom` is broken on Python ≥3.10.** The PyPI v0.16.1 wheel pins `python < 3.10` and `numpy < 1.20`. Workaround: `pip install git+https://github.com/CPJKU/madmom.git` — master relaxes the pins. Author's focus has moved to [Beat This!](#beat-this-) which is MIT-licensed and outperforms madmom on standard benchmarks.

```python
from madmom.features.beats import RNNBeatProcessor, DBNBeatTrackingProcessor

rnn = RNNBeatProcessor()
tracker = DBNBeatTrackingProcessor(fps=100)
beats = tracker(rnn("track.wav"))  # numpy array of timestamps in seconds
```

**Gotchas.** DBN post-processing model weights are non-commercial. Author acknowledgement that Beat This! is the successor — use it for new work unless you specifically need madmom's chord/key/transcription features.

#### librosa

- 🔗 [github.com/librosa/librosa](https://github.com/librosa/librosa) · 8,493★ · **ISC** · last commit **2026-07-07** 🟩🟩 · v0.11.0
- **Capability:** BPM + beat tracking (`librosa.beat.beat_track`). No genre classifier — but the canonical Python feature-extraction stack that feeds every downstream classifier.
- **Algorithm:** Ellis 2007 dynamic-programming beat tracker; onset envelope + tempogram.
- **Distribution:** Python only (`pip install librosa`).

```python
import librosa

y, sr = librosa.load("track.wav")
tempo, beats = librosa.beat.beat_track(y=y, sr=sr)
print(f"Estimated tempo: {float(tempo):.1f} BPM")
beat_times = librosa.frames_to_time(beats, sr=sr)
```

**Gotchas.** Tempo estimate is a **mean** across the track, not a per-beat trace — for time-varying tempo pair with madmom or Beat This! Python-only; no CLI, no bindings.

#### TempoCNN

- 🔗 [github.com/hendriks73/tempo-cnn](https://github.com/hendriks73/tempo-cnn) · 107★ · **AGPL-3.0** · last commit 2024-10-17 🟨 · PyPI `tempocnn`
- **Capability:** Tempo classification (single BPM value per track — not beat timestamps) + key estimation.
- **Algorithm:** Schreiber & Müller CNN (ISMIR 2018). Models: `cnn` / `fcn` / `deepsquare`.
- **Distribution:** Python + TensorFlow. Also embedded inside Essentia as `TensorflowPredictTempoCNN`.

Use case: you want a single BPM number per track (not beat timestamps), and you want deep-NN accuracy. If you need beat timestamps, use Beat This! instead.

**Gotchas.** AGPL-3.0 propagates to any network-service use. TensorFlow dep.

### JavaScript / npm / browser — BPM

Where BPM detection *actually happens for most product engineers* — in a browser, on a decoded `AudioBuffer` from a `<audio>` element or a microphone `MediaStream`. All classical DSP; the deep-NN options don't have JS/WASM ports outside essentia.js.

#### web-audio-beat-detector

- 🔗 [github.com/chrisguttandin/web-audio-beat-detector](https://github.com/chrisguttandin/web-audio-beat-detector) · 674★ · **MIT** · last commit 2026-06-20 🟩 · npm v8.2.37 · **~8,260 weekly downloads**
- **Capability:** BPM only.
- **Algorithm:** Web Audio API–based onset detection + autocorrelation (adapted from Joe Sullivan's blog post).
- **Distribution:** npm — works in browser and Node (with the [`web-audio-api`](https://www.npmjs.com/package/web-audio-api) polyfill).
- **License win:** MIT — the go-to for closed-source commercial browser apps.

```js
import { analyze } from 'web-audio-beat-detector';

const audioContext = new AudioContext();
const response = await fetch('/track.mp3');
const buffer = await audioContext.decodeAudioData(await response.arrayBuffer());

const bpm = await analyze(buffer);
console.log('BPM:', bpm);
```

**Gotchas.** Needs a decoded `AudioBuffer` (not raw file bytes). Best on 4/4 dance material 90–180 BPM; if the BPM is outside that range or the meter is complex, you'll get octave errors (½× or 2×). Guttandin also maintains the wider Standardized-Audio-Context ecosystem and the analyzer is well-integrated with it.

#### realtime-bpm-analyzer

- 🔗 [github.com/dlepaux/realtime-bpm-analyzer](https://github.com/dlepaux/realtime-bpm-analyzer) · 147★ · **Apache-2.0** · last commit 2026-05-28 🟩 · npm v5.0.15 · **~1,280 weekly downloads**
- **Capability:** BPM, **realtime**. Also handles offline analysis.
- **Algorithm:** AudioWorklet-based onset detection + peak analysis over a rolling window.
- **Distribution:** npm (browser only — needs a real `AudioContext` with AudioWorklet).

```js
import { createRealTimeBpmProcessor } from 'realtime-bpm-analyzer';

const audioContext = new AudioContext();
const realtimeAnalyzer = await createRealTimeBpmProcessor(audioContext);

const mediaStream = await navigator.mediaDevices.getUserMedia({ audio: true });
const source = audioContext.createMediaStreamSource(mediaStream);
source.connect(realtimeAnalyzer);

realtimeAnalyzer.port.onmessage = (event) => {
  if (event.data.message === 'BPM') console.log('BPM:', event.data.data.bpm);
};
```

Use case: DJ-mixer-style live monitoring, karaoke apps, dance-training apps. If you don't need realtime, use [web-audio-beat-detector](#web-audio-beat-detector) instead — the offline algorithm is more accurate.

#### music-tempo

- 🔗 [github.com/killercrush/music-tempo](https://github.com/killercrush/music-tempo) · 136★ · **MIT** · last commit **2020-03-15** 🟥 · npm v1.0.3 · **~3,316 weekly downloads**
- **Capability:** BPM only.
- **Algorithm:** Ellis 2007 dynamic programming, ported to JS.
- **Distribution:** npm (Node + browser).

Dormant since 2020. Included because the algorithm port is faithful and the download count suggests real usage in build graphs. Prefer [web-audio-beat-detector](#web-audio-beat-detector) for new work.

#### bpm-detective

- 🔗 [github.com/tornqvist/bpm-detective](https://github.com/tornqvist/bpm-detective) · 147★ · **⚠️ no license declared** · last commit **2021-07-26** 🟥 · npm v2.0.5 · **~24,716 weekly downloads**
- **Capability:** BPM only.
- **Algorithm:** Web Audio–based onset + autocorrelation, 90–180 BPM range.

> [!WARNING]
> **No license file** — under copyright law this is all-rights-reserved by default. The high npm download count is misleading (likely CDN/build-graph rather than active adoption). Project marked "inactive" by Snyk since 2021. Prefer [web-audio-beat-detector](#web-audio-beat-detector) (MIT) for any real product.

#### meyda

- 🔗 [github.com/meyda/meyda](https://github.com/meyda/meyda) · 1,650★ · **MIT** · last commit **2024-07-15** 🟨 · npm v5.6.3 · **~14,014 weekly downloads**
- **Capability:** Feature extraction (MFCC, chroma, spectral centroid, energy, RMS, ZCR, and ~20 others). **Not BPM** and **not genre** directly — the input side of any classifier pipeline.
- **Distribution:** npm (browser + Node).

Include Meyda when you're building a *custom* classifier: extract MFCCs with Meyda in the browser, ship them to a TF.js head, or feed them into a small SVM. Not a detector on its own.

## Genre / mood classification

There is **no MIT-licensed deep-NN music-genre classifier** in the open-source ecosystem as of the snapshot. Your options: [Essentia](#essentia) (AGPL-3.0 + non-commercial weights), a paid API ([Cyanite.ai](#cyaniteai)), or roll your own with an embedding network + downstream classifier.

### Essentia + Essentia Models

The strongest open genre stack. Ships in three flavours: [Essentia](#essentia) (C++/Python), [essentia.js](#essentiajs) (WASM), and hosted through the [Essentia Models catalogue](#essentia-models-discogs-effnet--mtg-jamendo--tempocnn).

#### Essentia

- 🔗 [github.com/MTG/essentia](https://github.com/MTG/essentia) · 3,612★ · **AGPL-3.0** · last commit 2026-05-20 🟩 · PyPI `essentia` (rolling betas)
- **Capability:** BPM + genre + mood + key + ~1000 other MIR descriptors. Biggest surface area in the space.
- **Algorithm:** Classical DSP for `RhythmExtractor2013` and `PercivalBpmEstimator`; deep-NN via TensorFlow models for genre/mood/tempo (see [Essentia Models](#essentia-models-discogs-effnet--mtg-jamendo--tempocnn)).
- **Distribution:** C++ library + `essentia_streaming_extractor_music` CLI + Python + WASM.
- **Origin:** Music Technology Group, Universitat Pompeu Fabra Barcelona. Reference MIR toolkit.

```python
import essentia.standard as es

# BPM (classical DSP)
loader = es.MonoLoader(filename="track.mp3")
audio = loader()
rhythm_extractor = es.RhythmExtractor2013(method="multifeature")
bpm, beats, beats_confidence, _, beats_intervals = rhythm_extractor(audio)
print(f"BPM: {bpm:.1f}, confidence: {beats_confidence:.2f}")

# Genre (deep NN via Discogs-EffNet)
embeddings_model = es.TensorflowPredictEffnetDiscogs(
    graphFilename="discogs-effnet-bs64-1.pb",
    output="PartitionedCall:1")
predictions_model = es.TensorflowPredict2D(
    graphFilename="genre_discogs400-discogs-effnet-1.pb",
    input="serving_default_model_Placeholder",
    output="PartitionedCall:0")
embeddings = embeddings_model(audio)
predictions = predictions_model(embeddings)  # shape (n_frames, 400)
```

**Gotchas.** AGPL-3.0 — network service use triggers copyleft, poison for closed-source SaaS. Model weights are **CC BY-NC-SA 4.0** (non-commercial only). Python build from source is often needed (the PyPI wheel doesn't ship all extractors). No genre model runs without downloading a matching pair of graphs (embeddings + classifier head).

#### Essentia Models — Discogs-EffNet / MTG-Jamendo / TempoCNN

- 🔗 [essentia.upf.edu/models.html](https://essentia.upf.edu/models.html) (catalogue) · [github.com/MTG/essentia-models](https://github.com/MTG/essentia-models)
- **Weights license:** mostly **CC BY-NC-SA 4.0** (non-commercial). A few CC-BY variants exist for research embeddings.
- **Formats shipped per model:** `.pb` (TF frozen graph) + `.json` (metadata) + `.tfjs` (for essentia.js) + `.onnx` (for cross-runtime inference — Bumblebee, ONNX Runtime).

Key models to know:

| Model | Task | Output |
| --- | --- | --- |
| `genre_discogs400-discogs-effnet` | Genre classification | 400 Discogs styles |
| `genre_discogs519-discogs-maest-30s-pw` | Genre classification | 519 styles, MAEST architecture, 30-second window |
| `mtg_jamendo_genre-discogs-effnet` | Genre classification | 87 MTG-Jamendo genres |
| `mtg_jamendo_moodtheme-discogs-effnet` | Mood/theme tagging | 56 mood tags |
| TempoCNN family | BPM classification | Single BPM value |

**Gotchas.** Non-commercial weights license is the biggest single filter in this article — most commercial products cannot ship these models. Weights are separately versioned from the Essentia code; check the model card for the matched Essentia version.

#### essentia.js

- 🔗 [github.com/MTG/essentia.js](https://github.com/MTG/essentia.js) · 854★ · **AGPL-3.0** · last commit 2025-12-10 🟩 · npm v0.1.3 · **~12,199 weekly downloads**
- **Capability:** BPM + genre + mood + key. Essentia's C++ + models compiled to WASM.
- **Distribution:** npm (WASM + JS bindings). Also usable in browser via `<script>`.
- **The only** serious in-browser deep-learning genre classifier as of the snapshot.

```js
import Essentia from 'essentia.js';
import { EssentiaWASM } from 'essentia.js';

const essentia = new Essentia(EssentiaWASM);

// BPM (classical DSP)
const bpm = essentia.PercivalBpmEstimator(audioSignal).bpm;

// Genre via Discogs-EffNet (also load the tfjs model separately)
// See essentia.js Discogs-EffNet example in the repo's examples/ folder
```

**Gotchas.** AGPL-3.0. WASM bundle is large (~5 MB unpacked). Model weights CC-BY-NC-SA. Latest npm release is 0.1.3 — the pace of releases has been slow but the codebase is active on `master`.

### Python-side deep-learning classifiers

#### musicnn

- 🔗 [github.com/jordipons/musicnn](https://github.com/jordipons/musicnn) · 596★ · **ISC** · last commit **2023-06-17** 🟥
- Historically the reference small-CNN music tagger (Pons/Serrat, trained on MTT + Million Song Dataset).
- **Superseded by** Essentia's Discogs-EffNet family. Pinned to TensorFlow 1.x which breaks on modern Python. Listed here for context; do not use for new work.

#### OpenL3

- 🔗 [github.com/marl/openl3](https://github.com/marl/openl3) · 596★ · **MIT** · last commit **2023-06-17** 🟥
- Self-supervised audio embeddings (L3-Net). Not a genre classifier on its own — embeddings feed a downstream classifier.
- Dormant since 2023. Current SOTA embeddings have moved to CLAP (LAION) and MERT.

#### Marsyas

- 🔗 [github.com/marsyas/marsyas](https://github.com/marsyas/marsyas) · 424★ · **GPL-2.0** · last commit **2023-04-19** 🟥
- Tzanetakis's historical MIR toolkit; originator of GTZAN. Dormant. Include as prior art only.

### Browser / WASM genre detection

Two options, both severely constrained:

- **[essentia.js](#essentiajs)** — the only serious deep-NN genre classifier in the browser. AGPL-3.0 + non-commercial weights.
- **YAMNet-tfjs** — TensorFlow.js port of YAMNet. Trained on AudioSet (521 classes) so it *includes* music genre tags mixed in (`Rock music`, `Pop music`, `Country`, `Hip hop music`, ~15 genre-adjacent classes). **Not** fine-grained enough for a music-app UX. Apache-2.0. Useful when you want a broad audio-scene classifier that happens to include genre.

`@tensorflow-models` has no music-genre model in its official catalogue as of the snapshot. If you want fine-grained genre in the browser and have license flexibility, essentia.js is the only path.

## The BEAM gap

**Zero audio-analysis packages exist on Hex.pm or `packages.gleam.run` as of the snapshot.** Every keyword search (`bpm`, `tempo`, `beat`, `audio`, `genre`, `music`, `dsp`) returns either unrelated packages (BPMN workflow engines, Swatch time, music-theory helpers) or nothing. This is a total ecosystem gap — stronger than the caching or CLI gaps documented elsewhere in the almanac.

The [Membrane Framework](https://github.com/membraneframework) (Elixir multimedia pipeline, v1.3.2, active) ships extensive **codec and container** plugins (Opus, AAC, FFmpeg swresample, WebRTC, HLS) — but **no beat/tempo/genre plugin exists**. Membrane is the correct entry point for building a pipeline that hands audio off to an analyzer, but the analyzer itself has to be FFI-shaped.

**Four practical paths from Elixir / Gleam / Erlang:**

**1. Port to a CLI (simplest).** Shell out to `aubiotempo`, `bpm-tag`, or `sonic-annotator`. Fine for batch, poor for realtime.

```elixir
# Elixir — Port to aubiotempo
defmodule TempoDetector do
  def bpm(path) do
    case System.cmd("aubiotempo", [path]) do
      {output, 0} ->
        output |> String.trim() |> Float.parse() |> elem(0)
      {err, _} ->
        {:error, err}
    end
  end
end
```

```gleam
// Gleam — via shellout
import shellout

pub fn bpm(path: String) -> Result(String, #(Int, String)) {
  shellout.command(run: "aubiotempo", with: [path], in: ".", opt: [])
}
```

**2. Port to Sonic Annotator + Beat This! wrapper (SOTA offline).** Wrap Beat This! in a small Python CLI that emits JSON on stdout, then Port to it from Elixir/Gleam. This gets you MIT-licensed SOTA accuracy for batch jobs, at the cost of a Python runtime.

**3. NIF wrapping libaubio or libessentia.** No maintained Elixir NIF for either exists as of the snapshot. libaubio is GPL-3.0 — a NIF wrapping it would inherit the license. libessentia is AGPL-3.0. This is a build project, not a `mix.exs` line.

**4. Nx / Bumblebee / Axon + ONNX-exported model.** The only *in-BEAM* path. [Essentia Models](#essentia-models-discogs-effnet--mtg-jamendo--tempocnn) ship ONNX exports of Discogs-EffNet-400 and TempoCNN. In principle you can load one via [Bumblebee](https://github.com/elixir-nx/bumblebee) and run inference with EXLA. In practice: nobody has published this recipe as a package, and the pre-processing pipeline (Essentia's mel spectrogram, log-scaling, chunking) has to be reproduced in Nx before the model call. This is a from-scratch project — worth it if you're committed to a pure-BEAM stack; not something you can `mix deps.get` today.

**Recommendation for new BEAM code:** use path 1 (Port to `aubiotempo` for BPM, `sonic-annotator` for multi-feature). If you need SOTA accuracy and are OK with a Python co-process, path 2. Do not attempt paths 3 or 4 unless you have MIR expertise on hand.

## Hosted / cloud APIs

Reach for these when: (a) you don't want to maintain a model, (b) you need licensing that doesn't touch your product's code, (c) you want deep-NN accuracy without provisioning a GPU. Three shapes: **detection** (upload audio → returns BPM/genre), **identification** (upload audio → returns known-track metadata), **lookup** (already have an ID → look up metadata).

### Cyanite.ai

- 🔗 [cyanite.ai](https://cyanite.ai/) · [FAQ / pricing](https://cyanite.ai/faq/)
- **Shape:** Detection (deep-NN auto-tagging).
- **Capability:** **Genre** (23 main + 58 sub + 5,000 free-form tags) + **BPM** + **key** + **mood** (131 advanced tags) + 23 total output categories. The broadest single-vendor auto-tagging surface as of the snapshot.
- **Pricing:** **From €290/month API fee** + catalog-size-based per-track fee (custom). Enterprise-only. AWS Marketplace listing also available.
- **Use case:** Music-tech products, DSP-adjacent SaaS, ad-tech that needs mood/genre for creative matching.

Not viable for hobby projects. Strongest recommendation if you're a music-industry company and need a single-vendor deep-NN auto-tagger.

### AudD

- 🔗 [audd.io](https://www.audd.io/) · [docs.audd.io](https://docs.audd.io/)
- **Shape:** Identification (Shazam-style ID) → returns known-track metadata.
- **Capability:** Song ID from ~80M-track database → title/artist/album/ISRC/UPC/label + optional lyrics.
- **Not a BPM/genre detector.** BPM/genre come from the *identified* track's metadata (which may or may not include them). For an unknown or unreleased track: AudD returns nothing.
- **Pricing:** **$2–5 per 1,000 file requests**; **$25–45/month per audio stream**.

Pair AudD (ID) with [GetSongBPM](#getsongbpm) (lookup BPM) or [MusicBrainz](#musicbrainz) (lookup metadata) for a full pipeline on known commercial tracks.

### Sonic API (Zplane)

- 🔗 [sonicapi.com](https://www.sonicapi.com/)
- **Shape:** Detection.
- **Capability:** BPM detection, key detection, source separation (stems), auto-tune, time-stretch. REST API, per-call pricing.
- **Vendor:** Zplane — audio DSP company whose libraries ship inside DAWs.

Good middle-ground between hobby-friendly and enterprise Cyanite pricing; more DSP-flavoured (BPM/key/stems) than tag-flavoured (genre/mood). Verify pricing directly with vendor.

### GetSongBPM

- 🔗 [getsongbpm.com/api](https://getsongbpm.com/api)
- **Shape:** Lookup — you provide a track by artist/title, they return BPM + key.
- **Capability:** BPM + key only. No genre. Community-edited; strong on older catalogue, sparse on obscure or brand-new material.
- **Pricing:** **Free**, mandatory attribution link-back, email registration required.

> [!IMPORTANT]
> The attribution requirement is legally load-bearing — you must link to `getsongbpm.com` from any page that displays BPM data. Some enterprise deployments cannot use this (e.g. embedded/OEM, whitelabel).

### Chromaprint / AcoustID

- 🔗 [github.com/acoustid/chromaprint](https://github.com/acoustid/chromaprint) · 1,313★ · **LGPL-2.1+** · last commit 2026-06-16 🟩 · v1.6.0 (2025-08-28)
- **Shape:** Fingerprinting → identification against [AcoustID](https://acoustid.org).
- **Capability:** Audio fingerprint → track ID → [MusicBrainz](#musicbrainz) Recording ID. **No BPM, no genre.**
- **Pricing:** Free (AcoustID lookup API); Chromaprint itself is a library + CLI (`fpcalc`).

The "if it's a known commercial track, get its MusicBrainz ID for free, then look up BPM elsewhere" building block. Very useful as the first stage of a lookup pipeline.

### MusicBrainz

- 🔗 [musicbrainz.org](https://musicbrainz.org/)
- **Shape:** Lookup — free open-catalogue metadata service.
- **Capability:** Track metadata (artist, release, ISRC, ISWC, recording relationships). **No BPM field** in the schema. Genre is user-editable *tags* with sparse coverage — do not rely on it as authoritative.

Use MusicBrainz to *identify* a track after AcoustID lookup; look up BPM in GetSongBPM or the AcousticBrainz frozen dump.

### Songstats

- 🔗 [songstats.com/for/developers](https://songstats.com/for/developers) · [docs.songstats.com](https://docs.songstats.com/)
- **Shape:** Lookup — enterprise music-industry metadata + stats.
- **Capability:** Playlist placements, chart positions, streaming stats across Spotify/Apple/Amazon/Deezer/TikTok. **No confirmed BPM/genre detection endpoint** — they aggregate platform metadata rather than analyzing audio.
- **Pricing:** Enterprise-only — contact `api@songstats.com` for a key.

For music-industry analytics, not for BPM/genre detection.

### AcousticBrainz

- 🔗 [acousticbrainz.org/download](https://acousticbrainz.org/download)
- **Status:** **Shut down 2022-02-16.** API is gone. **The frozen dataset dump (~7.5M recordings, CC0) is still downloadable** as of the snapshot.
- **Contents:** Essentia-computed **BPM + high-level tags (genre, mood, danceability, gender, etc.)** keyed by MusicBrainz Recording ID.
- **Use case:** Offline lookup table for **pre-2022 tracks**. Nothing added after Feb 2022.

For a music-catalogue product whose reference library is largely pre-2022, this dataset is basically free Cyanite. Ingest the JSON dump into a database (PostgreSQL, DuckDB, ClickHouse) keyed by MBID, then query offline. New/unreleased tracks: not present.

### Spotify Web API — `/audio-features`

- 🔗 [Deprecation blog post (2024-11-27)](https://developer.spotify.com/blog/2024-11-27-changes-to-the-web-api)
- **Status:** **Deprecated 2024-11-27.** New apps get a 403 on `/audio-features` and `/audio-analysis`. Only apps with a quota-extension approved before the cutoff still have access. **No public replacement roadmap** 18 months on.

Historically the fastest first-party path to BPM + key + energy + valence + danceability for any track in the Spotify catalogue. **Do not build on this.** For known commercial tracks, the AcoustID → MusicBrainz → GetSongBPM chain is the current best replacement. For deep-NN accuracy on any track, Cyanite.

## Accuracy realities

### BPM in 2026 — not solved for complex material

Consensus from the [2024 review paper "AI and Tempo Estimation: A Review" (arxiv:2401.00209)](https://arxiv.org/pdf/2401.00209) and the [Beat This! ISMIR 2024 paper](https://github.com/CPJKU/beat_this):

- Tempo estimation is **not solved**. Standard datasets (Ballroom, ACM Mirum, GTZAN-tempo, Hainsworth) ceiling around **80–85% Acc1**, **90–95% Acc2** for the best deep-NN systems. Acc2 counts octave errors (½× and 2×) as correct — a common failure mode.
- **Deep-NN clearly beats classical DSP on complex material** — orchestra, jazz, world music, non-4/4 meter. On steady 4/4 dance music, classical autocorrelation ([aubio](#aubio), [bpm-tools](#bpm-tools)) is close enough that the extra compute is rarely worth it.
- **[Beat This!](#beat-this-)** (ISMIR 2024) is the current reference for beat/downbeat tracking without needing DBN post-processing (which was madmom's classical trick). On the hard SMC dataset, Beat Transformer's tempo head hits ~59% vs madmom's TCN at ~22% — nearly 3× (per arxiv:2605.12287 "SMC Blind Spot"). SMC is deliberately hard material — slow, sparse, complex meter.
- **Hardest failure modes:**
  - Octave errors (predicted BPM is ½× or 2× the true tempo)
  - Non-4/4 meter (waltz, prog rock, math rock)
  - Slow ambient or drone with no percussion
  - Rubato and tempo drift in classical or jazz
- Classical DSP hits **~65–75% Acc1 on Ballroom**. For DJ software indexing house/techno/hip-hop, this is fine. For an arbitrary music library that includes jazz/classical/orchestral, you need Beat This! or a hosted API.

**Practical implication:** if your product's audio catalogue is dance/pop, aubio/bpm-tools/web-audio-beat-detector are fine. If it's arbitrary or leans classical/jazz, use Beat This! or Cyanite.

### Genre — GTZAN is broken, top-*k* is the right contract

- **GTZAN is the standard benchmark and it is deeply broken.** Documented by Sturm 2013 (arxiv:1306.1461): repeated files, mislabels, artist contamination in the test set, low-quality audio, ~1,000 total clips across 10 classes. Reported "90%+ GTZAN accuracy" figures are **not** meaningful without artist-filter fixups, and even then don't port to real-world data.
- **10-class taxonomies (GTZAN, FMA-small)** are toys. Real music-industry taxonomies are **[Discogs-400](#essentia-models-discogs-effnet--mtg-jamendo--tempocnn)** (400 genre "styles") or Beatport's ~150-style taxonomy. Essentia's `genre_discogs400-discogs-effnet` and `genre_discogs519-discogs-maest-30s-pw` target realistic taxonomies.
- **Zero-shot / open-set is the hard problem.** A model trained on Discogs-400 struggles on brand-new subgenres (hyperpop, dariacore, drift phonk, sextrance) that emerged after training. The 2024 shift toward **CLAP embeddings + text queries** (LAION-CLAP, MERT) is the current direction — but nobody has packaged a batteries-included CLAP-based genre CLI yet.
- **[Essentia](#essentia)'s Discogs-EffNet family is the strongest open, ready-to-use genre classifier as of snapshot.** [Cyanite.ai](#cyaniteai)'s proprietary offering is probably better on latest music but not openly measurable.

**Practical implication:** consume genre outputs as **top-*k* probability lists**, not single labels. A reader wiring genre detection into a product should design the UI and data model around "top-3 tags with confidence" — a single-label API contract is a design smell. Discogs-400 has many neighbouring styles (e.g. `House` vs `Deep House` vs `Progressive House`); the top-1 will often be wrong by one row while top-3 will contain the right answer.

## Leaderboards

Two leaderboards, one per capability. Runtimes are not substitutable across the leaderboards — a Python-only tool cannot replace a browser-only tool; scoring compares within a capability rather than across.

### BPM / tempo detection

| Rank | Tool | Runtime | License | Notes |
| --- | --- | --- | --- | --- |
| 🥇 | [Beat This!](#beat-this-) | Python + PyTorch | **MIT** | SOTA 2024, MIT — the best-in-class open-source option for offline batch |
| 🥇 | [web-audio-beat-detector](#web-audio-beat-detector) | JS (browser + Node) | **MIT** | The best-in-class option for in-browser BPM |
| 🥈 | [aubio](#aubio) | Standalone CLI + Python + C | GPL-3.0 | Ubiquitous, fast, classical DSP; license blocks proprietary linking |
| 🥈 | [realtime-bpm-analyzer](#realtime-bpm-analyzer) | AudioWorklet | Apache-2.0 | The best-in-class option for realtime BPM in browser |
| 🥉 | [madmom](#madmom) | Python | BSD + non-commercial weights | Historically SOTA; broken on new Python; superseded by Beat This! |
| 🥉 | [librosa](#librosa) | Python | **ISC** | The Python MIR starting point; tempo is a mean, not a per-beat trace |
| 5 | [SoundTouch / BPMDetect](#soundtouch--bpmdetect) | C++ library | LGPL-2.1 | Embedded in Mixxx / Audacity; linker-friendly LGPL |
| 5 | [Sonic Annotator](#sonic-annotator) + [QM Vamp Plugins](#qm-vamp-plugins) | Standalone CLI + plugins | GPL-2.0 | Batch multi-feature pipeline; slower than aubio for BPM-only |
| 7 | [bpm-tools](#bpm-tools) | Standalone CLI | GPL-2.0 | Tiny UNIX-y CLI, great for Port from BEAM; dance-music-tuned only |
| 7 | [music-tempo](#music-tempo) | npm (Node + browser) | **MIT** | Dormant since 2020; use web-audio-beat-detector instead |
| 8 | [TempoCNN](#tempocnn) | Python + TF | AGPL-3.0 | Tempo class only (no beats); mostly relevant as an Essentia component |
| — | [bpm-detective](#bpm-detective) | npm | **⚠️ no license** | High downloads misleading; dormant since 2021; use w-a-b-d instead |

### Genre / mood classification

| Rank | Tool | Runtime | License | Notes |
| --- | --- | --- | --- | --- |
| 🥇 | [Essentia](#essentia) + [Essentia Models](#essentia-models-discogs-effnet--mtg-jamendo--tempocnn) | Python / C++ | AGPL-3.0 + CC-BY-NC-SA weights | Deepest open MIR toolkit; Discogs-400 is the realistic taxonomy |
| 🥇 | [Cyanite.ai](#cyaniteai) | Cloud REST | Proprietary | Broadest single-vendor tagging; from €290/mo |
| 🥈 | [essentia.js](#essentiajs) | WASM in browser | AGPL-3.0 + CC-BY-NC-SA weights | The only serious in-browser deep-NN genre classifier |
| 🥉 | [AudD](#audd) | Cloud REST | Proprietary | Identification-then-lookup; not detection on unknown tracks |
| 4 | [AcousticBrainz frozen dump](#acousticbrainz) | Static file | CC0 (dataset) | Free lookup for pre-2022 catalogue only |
| — | [musicnn](#musicnn) | Python + TF 1.x | ISC | Dormant; superseded by Essentia Discogs-EffNet |
| — | [OpenL3](#openl3) | Python + TF | MIT | Dormant; embeddings only, no classifier head |
| — | [Marsyas](#marsyas) | C++ | GPL-2.0 | Historical; do not use for new work |

---

**Cross-links.** This article is a cross-ecosystem loner (per [the loner rule in CLAUDE.md](CLAUDE.md)) — no sibling articles yet. If a second sibling emerges (e.g., music synthesis, MIDI toolchains, audio effects processing), promote to a folder. Related in-repo material: [`gleam/hashing.md`](gleam/hashing.md) (for content-addressing an audio file, not for BPM), [`gleam/serialization/`](gleam/serialization/README.md) (if you're persisting BPM/genre results).
