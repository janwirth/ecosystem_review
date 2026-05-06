# Building mobile apps with Gleam

> [!NOTE]
> **Status:** DRAFT · **Authoring:** AI-assisted, human-reviewed.

So you want to ship an iOS or Android app and you'd like to write Gleam.
The honest answer in 2026: **Gleam has no first-class mobile target**, and every realistic path goes through Gleam's JavaScript backend, then plugs into a JS-based mobile shell borrowed wholesale from the JavaScript ecosystem. The "Gleam-on-BEAM mobile" story does not exist in any practical 2026 form.

This article reviews the *paths* (Lustre+Capacitor, Lustre+Tauri, Gleam-as-business-logic+RN, PWA, bare WebView) — not the shells themselves. The shells are reviewed once in [Building Mobile Apps — Cross-Ecosystem Survey](../building-mobile-apps.md); link out to that for any shell-internal detail.

> [!IMPORTANT]
> **See also:** [Building Mobile Apps — Cross-Ecosystem Survey](../building-mobile-apps.md) — full review of every mobile framework Gleam piggybacks on (Capacitor, Tauri Mobile, React Native / Expo, PWA, native WebView).

**Snapshot: 2026-04-29.**

## Table of Contents

1. [TL;DR](#tldr)
2. [Framing — why every path is JS-compile-then-shell](#framing--why-every-path-is-js-compile-then-shell)
3. [Research method](#research-method)
   - [Scoring dimensions](#scoring-dimensions)
   - [Discovery](#discovery)
4. [The paths](#the-paths)
   - [Path A — Lustre + Capacitor](#path-a--lustre--capacitor)
   - [Path B — Lustre + Tauri Mobile](#path-b--lustre--tauri-mobile)
   - [Path C — Gleam logic + React Native / Expo UI](#path-c--gleam-logic--react-native--expo-ui)
   - [Path D — PWA only](#path-d--pwa-only)
   - [Path E — Bare WebView in a native shell](#path-e--bare-webview-in-a-native-shell)
5. [The gap](#the-gap)
6. [Per-path leaderboard](#per-path-leaderboard)
7. [Related reviews](#related-reviews)

## TL;DR

| Path | What you write in Gleam | Native shell | Plugin bridge | Verdict |
| --- | --- | --- | --- | --- |
| **[A. Lustre + Capacitor](#path-a--lustre--capacitor)** | Full UI + logic (Lustre on JS target) | Capacitor (web JS bundle in iOS/Android shell) | TS shim → `@external` JS interop | 🥇 Most idiomatic Gleam mobile path. Battle-tested shell, 15.5k★. |
| **[B. Lustre + Tauri Mobile](#path-b--lustre--tauri-mobile)** | Full UI + logic (Lustre on JS target) | Tauri 2 (Rust shell, mobile stable) | Rust commands → JS `invoke` → `@external` | 🥈 Type-safe Rust core if you want it; thinner mobile plugin ecosystem. |
| **[C. Gleam logic + RN UI](#path-c--gleam-logic--react-native--expo-ui)** | Business logic only (parsers, codecs, validation) | Expo / RN (native views, not DOM) | TS imports the Gleam-emitted JS | 🥉 UI must be React/TS; only viable for *shared* logic. |
| **[D. PWA only](#path-d--pwa-only)** | Full UI + logic (Lustre on JS target) | None — browser is the shell | None (or Web APIs only) | 4ᵗʰ. Lowest friction; iOS limits (no background sync, capped storage) hurt for app-like use. |
| **[E. Bare WebView](#path-e--bare-webview-in-a-native-shell)** | Full UI + logic (Lustre on JS target) | Hand-written Kotlin/Swift WebView | Kotlin/Swift `addJavascriptInterface` ↔ `@external` | Fallback. Maximum native control, the Gleam side is identical to a PWA. |

**One sentence:** if you want a mobile app and you want it written in Gleam, run `gleam build --target javascript`, build a Lustre SPA, and let Capacitor wrap it. Everything else is a variation of that theme.

## Framing — why every path is JS-compile-then-shell

Gleam compiles to two targets: **Erlang/BEAM** and **JavaScript**. The BEAM target is irrelevant for mobile — neither iOS nor Android runs a production-grade BEAM. (BEAM-on-mobile attempts exist — Lumen was archived, AtomVM is microcontroller-only as of 2026 — but none are realistic for an app you'd ship to the App Store.)

That leaves the JavaScript target. Gleam→JS produces ECMAScript modules with a small runtime; the output runs anywhere a modern JS engine runs, which on mobile means **inside a WebView**. From there the choice is mechanical:

1. **Render to DOM** — Lustre's runtime diffs a virtual DOM and patches a real one. Works in any WebView. *This is the dominant path.*
2. **Render to native views** — would require bindings between Gleam and React Native's bridge, or a Gleam→native compiler. Neither exists. (Compiling Gleam into a JS module that an RN app *imports for logic only* is fine — see [Path C](#path-c--gleam-logic--react-native--expo-ui).)

So the article reduces to: pick a WebView shell. The rest of the work is the same.

The shells themselves vary on:
- **Native plugin model** (Capacitor: TS plugins → Swift/Kotlin · Tauri: Rust commands · Expo: native modules → JSI)
- **Bridge mechanism into your code** (Capacitor exposes JS `Plugin` calls · Tauri exposes a JS `invoke()` · RN exposes JS imports of native modules)
- **What goes on the App Store as the binary** (Capacitor: native iOS/Android project · Tauri: Rust-compiled native project · Expo: native iOS/Android project · PWA: nothing — it's a website · WebView shell: a hand-rolled native project)

For all of A/B/D/E, the Gleam author writes 100 % of the UI in Gleam-via-Lustre. For C, the UI is TypeScript-React; Gleam holds only the cross-cutting modules.

## Research method

### Scoring dimensions

Same 7-dim rubric used across the Gleam folder (inherited from [databases.md](databases.md#scoring-dimensions) and [web-and-http/web-apps.md](web-and-http/web-apps.md#scoring-dimensions)) — but scored against the **path** as the unit, not against any single library.

- **Stars (community signal):** Sum of community signals around the path's primary moving parts (Lustre + the shell). 🟩🟩 ≥200★, 🟩 ≥100★, 🟨 ≥10★, 🟥 <10★ for the *Gleam-side* contribution to the path.
- **License:** Permissive end-to-end (Lustre + shell + any binding lib). 🟩 fully permissive (MIT/Apache-2.0/BSD), 🟥 viral or unclear.
- **Gleam compat:** Whether the Gleam-side libraries on the path use range-style `gleam_stdlib` constraints. 🟩 range, 🟥 non-range.
- **Maintenance:** Worst-of (max-of-emoji) for the Gleam-side libraries on the path. The shell's own activity is reviewed in the cross-ecosystem article.
- **Age:** Maturity of the Gleam-side bindings on the path (not of the shell).
- **README / docs maturity:** How well the *Gleam path* is documented — README on the shim package, plus availability of an end-to-end "Gleam + shell X" recipe.
- **Idiomaticity:** Whether the Gleam-side path can be expressed with typed, explicit code (no JS shim hidden behind magic). `@external` JS interop is fine — it's the standard escape hatch.

**Leaderboard scoring:** 🟥 = −1, 🟨/⬜ = 0, 🟩 = 1, 🟩🟩 = 2. Sum across 7 dims. Max = 13.

### Discovery

Searched the [Gleam packages registry](https://packages.gleam.run/) on 2026-04-29 to find Gleam packages targeting mobile shells. The list is short.

| Search query | URL | Mobile-relevant hits |
| --- | --- | --- |
| `capacitor` | [packages.gleam.run/?search=capacitor](https://packages.gleam.run/?search=capacitor) | **0** |
| `tauri` | [packages.gleam.run/?search=tauri](https://packages.gleam.run/?search=tauri) | **2** — `tauri` (retired), `lustre_tauri` |
| `mobile` | [packages.gleam.run/?search=mobile](https://packages.gleam.run/?search=mobile) | **0** |
| `ios` | [packages.gleam.run/?search=ios](https://packages.gleam.run/?search=ios) | **0** (5 hits, all `spacetraders.io` SDK) |
| `android` | [packages.gleam.run/?search=android](https://packages.gleam.run/?search=android) | **0** |
| `react native` | [packages.gleam.run/?search=react+native](https://packages.gleam.run/?search=react+native) | **0 mobile-specific** (3 hits — `redraw`, `react_gleam`, `gild_frontend` — all DOM-React, none target RN) |
| `expo` | [packages.gleam.run/?search=expo](https://packages.gleam.run/?search=expo) | **0** |
| `webview` | [packages.gleam.run/?search=webview](https://packages.gleam.run/?search=webview) | **0** |
| `pwa` | [packages.gleam.run/?search=pwa](https://packages.gleam.run/?search=pwa) | **0** |
| `service worker` | [packages.gleam.run/?search=service+worker](https://packages.gleam.run/?search=service+worker) | **0** |
| `native` | [packages.gleam.run/?search=native](https://packages.gleam.run/?search=native) | **1 GUI-relevant** — `plushie_gleam` (desktop GUI via Iced — *not mobile*; noted for context) |
| `swift` | [packages.gleam.run/?search=swift](https://packages.gleam.run/?search=swift) | **0** |
| `kotlin` | [packages.gleam.run/?search=kotlin](https://packages.gleam.run/?search=kotlin) | **0** |
| `flutter` | [packages.gleam.run/?search=flutter](https://packages.gleam.run/?search=flutter) | **0** |

**Total mobile-relevant Gleam packages discovered: 2** — both Tauri-flavoured (one retired, one shim with 1 commit). For Capacitor, RN, Expo, PWA, WebView paths, **no Gleam bindings exist as of snapshot**. Anyone going deep will write `@external` JS interop themselves.

## The paths

### Path A — Lustre + Capacitor

**Thesis:** the most idiomatic Gleam mobile path. Lustre is the dominant Gleam frontend (2.3k★, [reviewed in detail in web-apps.md](web-and-http/web-apps.md#lustre)); Capacitor is the most-used "wrap a JS app in a native shell" tool in the JS ecosystem (15.5k★, MIT, on v8.3.1 as of 2026-04-16). The bridge between them is a TS shim plus `@external` calls.

#### Score (path)

| Criterion | Score | Reason |
| --- | --- | --- |
| Stars (Gleam-side) | 🟩🟩 | Lustre 2.3k★ carries the path. |
| License | 🟩 | Lustre MIT, Capacitor MIT. End-to-end permissive. |
| Gleam compat | 🟩 | Lustre `>= 0.60 and < 2.0` — range-style. |
| Maintenance | 🟩🟩 | Lustre last commit 2026-04-28 (yesterday); Capacitor 8.3.1 released 2026-04-16. |
| Age | 🟩🟩 | Lustre Feb 2022 (~4.2 years); Capacitor 2019. |
| README / path docs | 🟨 | Lustre & Capacitor docs each excellent. **No "Gleam + Capacitor" guide exists** — you assemble it yourself from the two. |
| Idiomaticity | 🟩 | Lustre code is fully idiomatic Gleam. Plugin calls go through `@external` (the standard escape hatch — fine). |

**Path score: 9** — see [leaderboard](#per-path-leaderboard).

#### What you actually do

```sh
# 1. Build the Gleam app to JS (Lustre SPA)
gleam build --target javascript

# 2. lustre_dev_tools bundles to dist/
gleam run -m lustre/dev build app

# 3. Initialize Capacitor against the bundle
npm init -y
npm i @capacitor/core @capacitor/cli
npx cap init "MyApp" "com.example.myapp" --web-dir=dist

# 4. Add native platforms
npx cap add ios
npx cap add android

# 5. Sync + open native IDEs
npx cap sync
npx cap open ios       # → Xcode
npx cap open android   # → Android Studio
```

`capacitor.config.ts` (the entire JS hand-written surface for a UI-only app):

```ts
import type { CapacitorConfig } from '@capacitor/cli';
const config: CapacitorConfig = {
  appId: 'com.example.myapp',
  appName: 'MyApp',
  webDir: 'dist',
};
export default config;
```

Calling a native plugin (e.g. Geolocation) from Gleam — no Gleam binding exists, so you write a thin shim.

```ts
// src/capacitor_bridge.ts
import { Geolocation } from '@capacitor/geolocation';
export async function get_position(): Promise<{lat: number, lng: number}> {
  const p = await Geolocation.getCurrentPosition();
  return { lat: p.coords.latitude, lng: p.coords.longitude };
}
```

```gleam
// src/capacitor_bridge.gleam
import gleam/javascript/promise.{type Promise}

pub type Position {
  Position(lat: Float, lng: Float)
}

@external(javascript, "./capacitor_bridge.ts", "get_position")
pub fn get_position() -> Promise(Position)
```

#### Gotchas

- **No Gleam → Capacitor plugin bindings exist** ([discovery: 0 hits for `capacitor`](https://packages.gleam.run/?search=capacitor)). Every native plugin you want (Geolocation, Camera, Filesystem, Push Notifications, ...) needs a hand-rolled TS shim and a matching Gleam `@external` declaration.
- **Capacitor 8 hard requirements (as of April 2026):** Xcode 26+, iOS 15.0+ minimum, Android Studio Otter (2025.2.1)+. App Store submissions since 2026-04-28 require Xcode 26 / iOS 26 SDK.
- **lustre_dev_tools bundles for the browser**, not for a Capacitor `webDir`. They produce the same artifact (an HTML file + JS chunks); you point Capacitor's `webDir` at the output directory.
- The Capacitor shell ships hot-reload for development (live-reload from `localhost`), which works fine alongside `lustre/dev start`.

> [!NOTE]
> Full Capacitor review (architecture, plugin model, alternatives) lives in [../building-mobile-apps.md](../building-mobile-apps.md). This article only covers what changes when you bring Gleam.

### Path B — Lustre + Tauri Mobile

**Thesis:** same Lustre frontend as Path A, but the shell is Tauri 2 instead of Capacitor. Tauri's mobile support went stable with Tauri 2.0 (released 2024, mobile stabilized through 2024-2025); the shell is Rust, native plugins are Rust crates, and the JS↔native bridge is Tauri's `invoke()`. The Tauri ecosystem is the only mobile shell with **any existing Gleam bindings** as of snapshot.

#### Score (path)

| Criterion | Score | Reason |
| --- | --- | --- |
| Stars (Gleam-side) | 🟨 | `lustre_tauri` 8★, `tauri` (retired) 0★ visible. Lustre 2.3k★ carries the path's UI side. |
| License | 🟩 | Lustre MIT, `lustre_tauri` Apache-2.0, Tauri Apache-2.0/MIT dual. `tauri` shim is MPL-2.0 (weak copyleft — 🟥 if your shop is permissive-only; otherwise OK). |
| Gleam compat | 🟨 | `lustre_tauri` 1 commit and v1.0.0 since 2024-11-10 — `gleam_stdlib` constraint not verified live. Treat as unknown. |
| Maintenance | 🟥 | `lustre_tauri`: 1 commit, last published 2024-11-10 (~17 months stale at snapshot). `tauri` shim: explicitly **retired by maintainer**, "no longer maintained" notice on Hex. |
| Age | 🟨 | `lustre_tauri` ~17 months; `tauri` shim Hex publish history ends 2025-11-04. |
| README / path docs | 🟥 | `lustre_tauri` README is a tagline + 1 example for `invoke`. **Neither shim was authored against Tauri Mobile** — both predate the focus on iOS/Android shipping. |
| Idiomaticity | 🟩 | Lustre is idiomatic; the bridge is `effect`-based via `lustre_tauri` (mirrors `lustre_http`'s shape — clean). |

**Path score: 4** — see [leaderboard](#per-path-leaderboard). The path *works* — but you're carrying stale shims, or you skip them and roll your own `@external` calls to `@tauri-apps/api`'s `invoke()`. Most teams will choose the latter.

#### What you actually do

```sh
# 1. Build the Gleam app to JS
gleam build --target javascript
gleam run -m lustre/dev build app

# 2. Initialize Tauri (mobile-capable)
npm create tauri-app@latest    # pick "vanilla", "TypeScript", point at dist/
cd my-tauri-app

# 3. Add mobile targets
npm run tauri ios init
npm run tauri android init

# 4. Run on a simulator/device
npm run tauri ios dev
npm run tauri android dev
```

Point `src-tauri/tauri.conf.json` at the Lustre bundle:

```json
{
  "build": {
    "frontendDist": "../dist"
  }
}
```

Calling a Rust command from Gleam — you can either depend on `lustre_tauri` (1.0.0, last touched 2024) or write the `@external` directly:

```gleam
import gleam/javascript/promise.{type Promise}

@external(javascript, "@tauri-apps/api/core", "invoke")
pub fn invoke(cmd: String, args: a) -> Promise(b)

pub fn greet(name: String) -> Promise(String) {
  invoke("greet", #(name))
}
```

The Rust side (in `src-tauri/src/lib.rs`):

```rust
#[tauri::command]
fn greet(name: &str) -> String {
  format!("Hello, {}!", name)
}
```

#### Gotchas

- **Both Gleam-side Tauri shims are stale.** `tauri` (Hex package, by `beeauvin`) is **retired** — the maintainer's note on Hex says "no longer maintained, contact me to take over." `lustre_tauri` has a single commit and was last published 2024-11-10. Neither was authored against Tauri Mobile.
- **The `beeauvin/tauri` GitHub repo returns 404 as of snapshot** — the Hex package is now a frozen artifact pointing at a dead source URL.
- **Tauri Mobile is younger than Capacitor's mobile shell**; the official guidance is "production-ready, but not all desktop plugins are ported to mobile yet." Verify per plugin in [tauri-apps/plugins-workspace](https://github.com/tauri-apps/plugins-workspace).
- **Rust shells require a Rust toolchain.** Capacitor doesn't. If your team is JS-only (plus Gleam), Path A is friendlier.

### Path C — Gleam logic + React Native / Expo UI

**Thesis:** Lustre renders to the DOM. React Native renders to native views (UIView on iOS, View on Android). The two are not interoperable. **You cannot run a Lustre UI on React Native.**

What you *can* do: write your business logic (parsing, validation, decoders, codecs, state machines) in Gleam, compile to a JS module, and `import` it from your React Native app. The UI is then 100 % TypeScript-React; Gleam owns the cross-cutting modules.

#### Score (path)

| Criterion | Score | Reason |
| --- | --- | --- |
| Stars (Gleam-side) | 🟥 | No Gleam-side libraries are involved beyond `gleam_stdlib` and any decoders/parsers you depend on. |
| License | 🟩 | All your Gleam deps are typically MIT/Apache-2.0; RN is MIT. |
| Gleam compat | 🟩 | N/A — you're not depending on a mobile-specific Gleam library because none exists. |
| Maintenance | 🟩 | RN/Expo are some of the best-maintained projects in the JS ecosystem; the Gleam side is whatever you depend on. |
| Age | 🟩🟩 | RN is 10+ years old; Expo SDK is mature. |
| README / path docs | 🟥 | **Nobody has written this guide.** No Gleam→RN integration docs exist; the closest analogue is Elm-as-RN-logic (also rare). |
| Idiomaticity | 🟩 | Gleam→JS module is a normal Gleam package compiled with `--target javascript`. The interop boundary is just imports. |

**Path score: 5** — see [leaderboard](#per-path-leaderboard). Use this if you need to **share business logic** between a web app and a mobile app, where the web app already happens to be in Lustre.

#### What you actually do

```sh
# Gleam module — no UI, just typed logic
gleam new shared_logic
cd shared_logic
gleam build --target javascript
# Output: build/dev/javascript/shared_logic/*.mjs
```

Publish to npm (or use a local file dependency from the RN app):

```json
// shared_logic/package.json
{
  "name": "@myorg/shared-logic",
  "version": "0.1.0",
  "type": "module",
  "main": "build/dev/javascript/shared_logic/shared_logic.mjs"
}
```

Consume from a React Native / Expo app:

```ts
// MyExpoApp/App.tsx
import { validate_email } from '@myorg/shared-logic/validation.mjs';
import { Text } from 'react-native';

export default function App() {
  const result = validate_email("hi@example.com");
  return <Text>{JSON.stringify(result)}</Text>;
}
```

#### Gotchas

- **Lustre is off the table for this path** — its rendering pipeline emits DOM, not RN views. Don't try to make `lustre.start()` run inside an RN app; it will not find a DOM.
- **Gleam's JS output uses standard ESM**; Metro (RN's bundler) supports ESM in modern versions, but you may need `package.json` `"main"` and `"type": "module"` set correctly. Test early.
- **No native RN modules in Gleam.** If your shared logic needs to touch the camera or filesystem, it can't — those are RN-side. Keep Gleam pure.
- **React Native's New Architecture (Fabric / TurboModules)** is the default in Expo SDK 51+ (2024) and required in 53+ (2025). It changes nothing about how you import a Gleam-emitted JS module.

### Path D — PWA only

**Thesis:** compile Gleam→JS, build a Lustre SPA, ship it as a Progressive Web App. No native shell, no app store, no plugins. The "mobile" requirement is satisfied by "works on a phone."

#### Score (path)

| Criterion | Score | Reason |
| --- | --- | --- |
| Stars (Gleam-side) | 🟩🟩 | Lustre 2.3k★ carries the path. |
| License | 🟩 | Lustre MIT; everything else is web standards. |
| Gleam compat | 🟩 | Lustre `>= 0.60 and < 2.0`. |
| Maintenance | 🟩🟩 | Lustre last commit 2026-04-28. |
| Age | 🟩🟩 | Lustre Feb 2022. PWA spec is mature. |
| README / path docs | 🟨 | No "Gleam PWA" guide exists; you wire `manifest.json` + a service worker yourself. The PWA recipe is identical for any JS frontend. |
| Idiomaticity | 🟩 | Lustre is idiomatic. The service worker (if you write one) is JS, not Gleam — typical web app split. |

**Path score: 10** — high, but read the gotchas.

#### What you actually do

```sh
gleam build --target javascript
gleam run -m lustre/dev build app
# Output: dist/index.html, dist/*.mjs
```

Add a `manifest.json`:

```json
{
  "name": "MyApp",
  "short_name": "MyApp",
  "start_url": "/",
  "display": "standalone",
  "icons": [{ "src": "/icon-512.png", "sizes": "512x512", "type": "image/png" }]
}
```

Reference it from `index.html`:

```html
<link rel="manifest" href="/manifest.json">
```

Optional service worker (`sw.js`) for offline. None of this is Gleam-specific.

#### Gotchas

- **iOS PWA is partial:**
  - Push notifications: **supported since iOS 16.4** (Web Push API), but only after the user adds the PWA to their Home Screen.
  - **Background Sync API: not implemented on iOS** — and Apple has indicated no timeline.
  - **Periodic Background Sync: not implemented on iOS.**
  - **Background Fetch: not implemented on iOS.**
  - **Storage limits: ~50 MB Cache API**, with a **7-day cap on script-writable storage** if the user doesn't return to the app.
- **Android PWA support is solid** — Chrome treats PWAs as near-first-class apps (install banners, push, background sync).
- **No app-store presence** — for some products this is a feature (instant updates), for others a deal-breaker (discovery, payments, parental controls).
- **The Gleam side is identical to a PWA you'd write in any other JS framework.** The only Gleam-specific concern is making sure your `lustre.start("#app")` runs after the DOM is ready.

### Path E — Bare WebView in a native shell

**Thesis:** write a one-screen native app whose only job is `WebView.loadUrl("file:///android_asset/index.html")` (Android) or `WKWebView.load(...)` (iOS), pointing at the Gleam-compiled bundle. Maximum native control, near-zero Gleam relevance.

#### Score (path)

| Criterion | Score | Reason |
| --- | --- | --- |
| Stars (Gleam-side) | 🟩🟩 | Lustre 2.3k★. |
| License | 🟩 | Lustre MIT. Native shell is your code. |
| Gleam compat | 🟩 | Lustre. |
| Maintenance | 🟩🟩 | Lustre. |
| Age | 🟩🟩 | Lustre. WebView APIs are decade-old stable platform features. |
| README / path docs | 🟥 | **You are the integration.** No prebuilt template for "Gleam in a hand-rolled WebView." Plenty of generic "JS in WebView" docs to crib from. |
| Idiomaticity | 🟩 | Same as PWA from the Gleam side. |

**Path score: 9** — but you're paying for it in native-side work that Capacitor would do for you.

#### What you actually do

Bundle the Lustre app the same way:

```sh
gleam build --target javascript
gleam run -m lustre/dev build app
```

Copy `dist/` into `app/src/main/assets/` (Android) or include it in your iOS app bundle. Then:

```kotlin
// Android — MainActivity.kt
class MainActivity : AppCompatActivity() {
  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    val webview = WebView(this).apply {
      settings.javaScriptEnabled = true
      addJavascriptInterface(NativeBridge(), "Native")
      loadUrl("file:///android_asset/index.html")
    }
    setContentView(webview)
  }
}
class NativeBridge {
  @JavascriptInterface fun showToast(msg: String) { /* ... */ }
}
```

```swift
// iOS — ViewController.swift
class ViewController: UIViewController, WKScriptMessageHandler {
  override func loadView() {
    let cfg = WKWebViewConfiguration()
    cfg.userContentController.add(self, name: "native")
    let webview = WKWebView(frame: .zero, configuration: cfg)
    let url = Bundle.main.url(forResource: "index", withExtension: "html",
                              subdirectory: "dist")!
    webview.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
    view = webview
  }
}
```

Bridge into Gleam via `@external` calls to whatever JS-side handles the bridge (`window.Native.showToast(...)` or `window.webkit.messageHandlers.native.postMessage(...)`).

#### Gotchas

- **You write and maintain two native projects.** Capacitor exists precisely to spare you this; pick this path only if you have a strong reason (existing native team, custom WebView config, security policy).
- **App Store / Play Store reviews can be hostile to "wrapper apps."** Capacitor / Tauri have established reviewer recognition; a hand-rolled WebView app is more likely to attract scrutiny.
- **Native plugins are now your job from scratch** — every native API is a hand-written `@JavascriptInterface` (Android) or `WKScriptMessageHandler` (iOS) call.

## The gap

What does **not** exist for Gleam mobile, as of 2026-04-29:

- **No Gleam → native bytecode compilation.** Gleam has no LLVM backend, no Dart-equivalent ahead-of-time native compile, no Swift/Kotlin emitter. The compiler emits Erlang or JavaScript. Period.
- **No Gleam-on-BEAM mobile path.** AtomVM (the only credible "tiny BEAM") targets ESP32/STM32 microcontrollers; iOS/Android are out of scope. Lumen (the WASM/native BEAM project) is archived. There is no production BEAM you can run on iPhone or Android in 2026.
- **No Gleam bindings to Capacitor plugins.** [0 hits on `packages.gleam.run` for `capacitor`](https://packages.gleam.run/?search=capacitor). Every plugin call you want is a hand-rolled `@external` shim.
- **No Gleam bindings to Tauri Mobile commands.** The two existing Tauri shims (`tauri`, `lustre_tauri`) predate Tauri Mobile and one is explicitly retired. You will write `@external` calls to `@tauri-apps/api`.
- **No Gleam bindings to React Native components.** Path C exists for shared logic, not for UI. There is no Gleam-on-RN equivalent to `redraw` (which is web-React only).
- **No Gleam packages for `mobile`, `ios`, `android`, `expo`, `webview`, `pwa`, `service worker`, `swift`, `kotlin`, or `flutter`.** The Gleam ecosystem treats mobile as a JS-ecosystem problem.
- **No "Gleam mobile" guide on `gleam.run` or anywhere on Hex.** This article and the [cross-ecosystem mobile survey](../building-mobile-apps.md) are the closest references.

If you go deep on any of A/B/C/E, **plan to write the JS interop layer yourself.** It is small, but it is yours to maintain.

## Per-path leaderboard

Scored against the [7-dim rubric](#scoring-dimensions), with the *path* (not any single library) as the unit.

| Position | Award | Path | ★ | Lic | Compat | Maint | Age | README | Idiom | Score |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 🥇 | [D — PWA only](#path-d--pwa-only) | 🟩🟩 | 🟩 | 🟩 | 🟩🟩 | 🟩🟩 | 🟨 | 🟩 | **10** |
| 2 | 🥈 | [A — Lustre + Capacitor](#path-a--lustre--capacitor) | 🟩🟩 | 🟩 | 🟩 | 🟩🟩 | 🟩🟩 | 🟨 | 🟩 | **9** |
| 2 | 🥈 | [E — Bare WebView](#path-e--bare-webview-in-a-native-shell) | 🟩🟩 | 🟩 | 🟩 | 🟩🟩 | 🟩🟩 | 🟥 | 🟩 | **9** |
| 4 | 🥉 | [C — Gleam logic + RN/Expo UI](#path-c--gleam-logic--react-native--expo-ui) | 🟥 | 🟩 | 🟩 | 🟩 | 🟩🟩 | 🟥 | 🟩 | **5** |
| 5 | | [B — Lustre + Tauri Mobile](#path-b--lustre--tauri-mobile) | 🟨 | 🟩 | 🟨 | 🟥 | 🟨 | 🟥 | 🟩 | **4** |

**One-sentence justifications:**

1. 🥇 **PWA** — highest score on paper because the Gleam side is fully covered by Lustre and the path inherits 30 years of web platform stability. **Caveat:** the score reflects developer-side ergonomics; iOS PWA *user* experience is hobbled (no background sync, capped storage). For "works on a phone," it wins. For "looks and feels like an installed app on iPhone," drop to A.
2. 🥈 **Lustre + Capacitor** — the strongest *true mobile* path. You give up the lowest-friction setup (no extra native tooling) for app-store presence and full plugin reach. Pick this when "mobile" means "App Store + Play Store + native plugins." This is the recommendation for **building a real Gleam mobile app** in 2026.
2. 🥈 **Bare WebView** — ties with Capacitor on rubric points (loses on README, gains on... nothing in particular). In practice it is strictly worse than Capacitor for most teams — Capacitor *is* this path with a project template. Pick E only if you have a specific reason to write your own native shell.
4. 🥉 **Gleam logic + RN UI** — only viable for code-sharing between a web app and a native mobile app. The UI is TypeScript-React, not Gleam. Score reflects "this is a real path with real value, but the Gleam content is a fraction of the app."
5. **Lustre + Tauri Mobile** — works mechanically, but the Gleam-side bindings (`tauri`, `lustre_tauri`) are stale or retired, and Tauri Mobile's plugin ecosystem is younger than Capacitor's. Pick this if you want Rust in the shell anyway (security policy, native crate reuse) and are comfortable maintaining your own `invoke()` wrapper.

> [!IMPORTANT]
> **None of these scores are about the shells themselves.** Capacitor, Tauri, and Expo are all excellent products. The rubric here scores the *Gleam-side* path — what exists in Hex, what's documented, what you write vs. what you import. For shell-internal comparisons (native plugin ecosystem depth, build performance, App Store review experience), see the [cross-ecosystem mobile survey](../building-mobile-apps.md).

## Related reviews

- **[../building-mobile-apps.md](../building-mobile-apps.md)** — full review of every mobile framework Gleam piggybacks on (Capacitor, Tauri, RN/Expo, PWA, native WebView). Read this for shell-internal detail.
- **[web-and-http/web-apps.md](web-and-http/web-apps.md)** — Lustre, mist, wisp, and the rest of the Gleam web stack. Path A/B/D/E all assume you're comfortable building a Lustre SPA first.
- **[web-and-http/lustre-server-components.md](web-and-http/lustre-server-components.md)** — server-driven Lustre (BEAM-side state, WebSocket DOM patches). **Not directly mobile-applicable** — server components require a live BEAM, which you don't have on the device — but useful context for how Lustre splits client/server responsibilities.
- **[web-and-http/ui-development.md](web-and-http/ui-development.md)** — component libraries, layout primitives, animations, and form helpers above the Lustre choice. All apply to mobile WebView paths (A/B/D/E).
- **[web-and-http/hot-reloading.md](web-and-http/hot-reloading.md)** — JS dev servers and file watchers. Capacitor's live-reload composes cleanly with `lustre/dev start`.

> [!IMPORTANT]
> **See also:** [Building Mobile Apps — Cross-Ecosystem Survey](../building-mobile-apps.md) — the per-shell deep dives live there. This article only covers what changes when you bring Gleam.
