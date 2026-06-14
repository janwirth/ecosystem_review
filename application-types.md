# Application types — what kind of thing are you building?

> [!NOTE]
> **Status:** DRAFT · **Authoring:** AI-assisted, human-reviewed.

> *Before you pick a language or a framework, you pick an artifact. This article is about that earlier choice.*

**Snapshot 2026-04-30** — frameworks named here are illustrative, not scored. For per-framework, snapshot-dated reviews see the cross-linked articles (e.g. [Building mobile apps](building-mobile-apps.md), [Building desktop apps](building-desktop-apps.md), [Gleam web apps](gleam/web-and-http/web-apps.md)).

Most "what should I build with?" conversations skip a step. Before language, before framework, before stack, there is a more fundamental decision: *what kind of artifact ships?* A static website, a single-page web app, an installable PWA, a desktop binary, and a mobile-store app are five different products with different distribution channels, different update cadences, different offline expectations, and different security models. This article is a pragmatic orientation for the engineer or CTO standing at that fork — not a catalogue of every framework, but a map of the five archetypes and when each one earns its keep.

## Table of Contents

1. [Why this article](#why-this-article)
2. [The five archetypes at a glance](#the-five-archetypes-at-a-glance)
3. [Website](#website)
4. [Web app](#web-app)
5. [Progressive Web App (PWA)](#progressive-web-app-pwa)
6. [Desktop app — native and cross-platform](#desktop-app--native-and-cross-platform)
7. [Mobile app — native and cross-platform](#mobile-app--native-and-cross-platform)
8. [Decision matrix](#decision-matrix)
9. [Cross-cutting concerns](#cross-cutting-concerns)
10. [Related reading](#related-reading)

## Why this article

The framework wars are downstream of a more important question. Picking React vs Svelte vs Lustre is a meaningful conversation only after you've decided you are building a *web app* in the first place. Picking Flutter vs Swift vs Capacitor is a conversation that only matters after you've decided you need a *mobile app* on the App Store, rather than a PWA, rather than a responsive web app, rather than a desktop tool.

The cost of getting this top-level choice wrong is high. A team that builds a full Electron desktop app for a workflow that would have been a 5-page website ships slower, hires worse, and pays distribution friction forever. A team that builds a marketing site as a single-page React app loses SEO and pays a complexity tax for state they never use. A team that ships a native iOS app for an internal tool with 40 users gets to enjoy app-store review delays and provisioning-profile renewals for the rest of the product's life.

This article is the orientation step. It assumes you already know *what the thing should do*; it helps you decide *what kind of thing it is*.

## The five archetypes at a glance

| Type | One-line definition | Ships as | User installs how |
| --- | --- | --- | --- |
| [**Website**](#website) | Static or mostly-static content, server-rendered HTML, SEO-first. | HTML/CSS/JS files served by CDN or origin. | Visits a URL. |
| [**Web app**](#web-app) | Interactive app served over HTTPS; auth, state, possibly real-time. | SPA bundle + API, or server-rendered pages with rich interactivity. | Visits a URL, signs in. |
| [**PWA**](#progressive-web-app-pwa) | Web app + manifest + service worker = installable, offline-capable, push-able. | Same as web app, plus `manifest.json` and a service worker. | Visits a URL, taps "Install" / "Add to Home Screen". |
| [**Desktop app**](#desktop-app--native-and-cross-platform) | Runs locally on macOS / Windows / Linux. | Signed binary / installer / package. | Downloads and runs an installer, or `brew install` / `winget install`. |
| [**Mobile app**](#mobile-app--native-and-cross-platform) | iOS / Android, app-store-distributed. | `.ipa` / `.aab` uploaded to the stores. | Installs from the App Store / Play Store. |

The boundaries are not hard. A PWA is a web app with extra metadata. A modern Electron desktop app is a web app in a native shell. A Capacitor mobile app is a web app in a native shell with app-store paperwork. The archetypes still matter because **distribution determines product behaviour** — install friction, update cadence, what runs offline, what hardware you can touch — and those properties shape the experience more than implementation choices do.

## Website

### Definition

A site whose primary job is to deliver *content* to visitors who arrived via a URL. Pages may be fully static (HTML files generated at build time), or server-rendered on each request, or a hybrid (incremental static regeneration). The defining property is that the *page itself* is the unit, not an app shell holding state across navigations.

### When to pick it

- **Marketing sites, product landing pages, brochureware.** Conversion + SEO are the goal.
- **Documentation, technical writing, knowledge bases.** Writers want to publish Markdown, not deploy code.
- **Blogs, personal sites, portfolios.** Long-tail content; cheap-to-host wins.
- **Anywhere SEO matters.** Static HTML is the only thing search engines never struggle to index.
- **Anywhere build-time correctness beats runtime flexibility.** A typo on a static page is a deploy away from being fixed and shows the same to every visitor.

### When to avoid it

- You need authenticated, per-user state. (You're building a web app.)
- You need real-time interactivity beyond a contact form. (You're building a web app.)
- You need to mutate a database on every page load. (You're building a web app, possibly poorly.)
- Content editors need WYSIWYG with live preview and no Git. (Pair the website with a headless CMS, or step up to a server-rendered web app.)

### Frameworks (illustrative, not scored)

| Framework | Language | Style | Notable for |
| --- | --- | --- | --- |
| Hugo | Go | SSG | Speed; large content sets build in seconds. |
| Astro | TS / JS | SSG with islands | Ships zero JS by default; embeds React/Svelte/Vue components as needed. |
| Eleventy (11ty) | JS | SSG | Minimalist, no opinion on templating. |
| Jekyll | Ruby | SSG | The original; powers GitHub Pages. |
| Next.js (SSG mode) | TS | SSG / hybrid | When the rest of the app is also Next.js. |
| Nuxt (generate) | TS | SSG / hybrid | Vue equivalent of Next.js. |
| MkDocs / Docusaurus / VitePress | Various | Docs-tuned SSG | When the site *is* docs. |
| Plain HTML + CSS | — | Hand-written | Still completely valid for small sites. |

### Distribution & install model

- **Distribution:** any static host — Netlify, Vercel, Cloudflare Pages, GitHub Pages, S3+CloudFront, your own nginx.
- **Install:** none. The browser is the runtime. URL is the install.
- **Update cadence:** on every deploy; visitors see the new version on their next request. CDN cache invalidation is the only knob.

### Offline & state

- **Offline:** none by default. Add a service worker and you have started building a PWA.
- **State:** none on the page itself. Forms POST to an endpoint or to a third-party (Formspree, Netlify Forms). Comments / likes / search live in third-party widgets or in a small server-rendered web-app slice.

## Web app

### Definition

An interactive application served over HTTPS, with authentication, persistent server state, and a UI that updates in response to user actions without a full page reload (or with server-rendered partials that *feel* equivalent). The user's primary mental model is "I'm using an app that happens to live in my browser."

### When to pick it

- **Authenticated dashboards, admin panels, internal tools.** No app-store, no installer, no per-user binary distribution.
- **Collaborative software.** Multiplayer state benefits from the always-online assumption.
- **Cross-platform reach with one codebase.** Every device has a browser. Almost no device has every desktop or mobile runtime.
- **Fast iteration loops.** Push to prod and every user has the new version on their next request.
- **B2B SaaS.** The dominant shape of the category for two decades; users expect a URL.

### When to avoid it

- You need offline-first behaviour as the *default*, not an enhancement. (Step up to a [PWA](#progressive-web-app-pwa) or a [desktop](#desktop-app--native-and-cross-platform) / [mobile](#mobile-app--native-and-cross-platform) app.)
- You need deep OS integration — file-system watchers, system tray, USB devices, low-level audio, kernel APIs. (Browser sandboxes; pick desktop.)
- You need to be in the App Store for distribution / billing reasons. (Pick mobile.)
- You're building something whose value proposition is "no internet required, ever." (Pick desktop or mobile; PWA is a partial answer.)

### Frameworks (illustrative, not scored)

| Framework | Language | Style | Notable for |
| --- | --- | --- | --- |
| React (+ Next.js / Remix / Vite) | TS / JS | SPA / SSR | Largest ecosystem; default in many shops. |
| Vue (+ Nuxt) | TS / JS | SPA / SSR | Approachable; strong in Asia-Pacific and indie. |
| Svelte (+ SvelteKit) | TS / JS | Compiler-based SPA / SSR | Small bundles, simple component model. |
| SolidJS (+ SolidStart) | TS / JS | Fine-grained reactive | React-shaped API, Svelte-like perf. |
| Angular | TS | Opinionated SPA | Enterprise-flavoured; batteries-included. |
| Phoenix LiveView | Elixir | Server-rendered + diffing | Real-time UI without JS framework. |
| Rails Hotwire (Turbo + Stimulus) | Ruby | Server-rendered + sprinkles | Ship fast; minimal JS budget. |
| Laravel Livewire | PHP | Server-rendered + diffing | Phoenix-LiveView-shaped, PHP-flavoured. |
| Lustre (Gleam) | Gleam | Elm-style SPA / SSR | Type-safe end-to-end; see [Gleam web apps](gleam/web-and-http/web-apps.md). |
| HTMX + your-server-of-choice | HTML | Server-rendered + sprinkles | The "no SPA" web app revival. |

### Distribution & install model

- **Distribution:** your servers + a CDN, or a managed PaaS (Vercel, Fly.io, Render, Heroku, Railway).
- **Install:** none. URL + login.
- **Update cadence:** continuous deploy. Hours, not days. Users may need to refresh to pick up a new bundle (or your shell can prompt them).

### Offline & state

- **Offline:** typically none. Refresh = network round-trip. Light reads can be cached; writes require connectivity.
- **State:** server is the source of truth; client holds a copy. Auth lives in cookies (session) or tokens (JWT / opaque bearer). See [Authentication](authentication.md) for the practical floor.

> [!NOTE]
> **Gleam-specific cousin:** [Tools for building web applications with Gleam](gleam/web-and-http/web-apps.md) reviews the Gleam-side options (Lustre, wisp, dream, glimr, mist) on the same axes used elsewhere in this repo.

## Progressive Web App (PWA)

### Definition

A web app with three extra ingredients: a `manifest.json` that tells the browser "I'm an installable app," a service worker that intercepts network requests and can serve cached responses, and (optionally) push-notification + background-sync hooks. The result is a web app that can be added to the home screen, launched from an app icon, run offline, receive push notifications (everywhere except — historically — iOS, which began closing the gap from iOS 16.4 onward), and feel app-shaped without an app-store appearance.

### When to pick it

- **You already have a web app and want app-shaped affordances cheaply.** A manifest + a service worker is days of work, not months.
- **You want offline-tolerant reads** (think: a documentation reader, a notes app, a transit timetable).
- **You want install-from-the-browser to bypass app-store fees / review.** No 30 % cut, no week-long review cycle.
- **Your audience is desktop-and-Android-first.** PWAs are best supported on Chromium desktop and Android. iOS has improved but remains the conservative platform.
- **You need an "installed app" feel without paying installer-distribution costs.**

### When to avoid it

- You need iOS feature-parity with native (background sync, fine-grained push, deep hardware access). iOS PWA support is real but trails Android meaningfully.
- You need to be in the App Store for billing or discoverability. (PWAs are not.)
- You need true offline-first with a complex local database, conflict resolution, and write replication. Achievable, but at that point you are building a sync engine and the PWA shell is the smaller half.
- Your audience is non-technical and "Add to Home Screen" is a discoverability brick wall. (App-store install is what they understand.)

### Frameworks & tooling (illustrative)

| Tool | What it does |
| --- | --- |
| Workbox | Google's service-worker toolkit; routing, precaching, runtime caching. |
| `vite-plugin-pwa` | Drop-in PWA support for Vite (Vue/React/Svelte/Solid); wraps Workbox. |
| `next-pwa` / `@ducanh2912/next-pwa` | Next.js PWA plugin. |
| Quasar (PWA mode) | Vue-based meta-framework with PWA build target. |
| Angular PWA schematic | `ng add @angular/pwa`. |
| Manifest + hand-rolled SW | Always an option for small apps; the spec is small. |

### Distribution & install model

- **Distribution:** same as a web app — your CDN / origin. The manifest links the icons, theme colours, and start URL.
- **Install:** Chrome / Edge / Safari / Firefox prompt or "Add to Home Screen." Some app stores (Microsoft Store, Play Store via TWA) accept PWAs as first-class submissions.
- **Update cadence:** continuous, with the catch that the *service worker itself* is cached aggressively and may take a refresh (or two) to update. Workbox documents the update lifecycle in detail.

### Offline & state

- **Offline:** the headline feature. The service worker decides what to cache and what to serve when the network is down. Patterns: cache-first (static assets), network-first-falling-back-to-cache (HTML), stale-while-revalidate (API reads).
- **State:** IndexedDB for structured local storage; Cache Storage for HTTP responses; LocalStorage for small key/value (synchronous, blocking — avoid for anything large).

## Desktop app — native and cross-platform

### Definition

A program that runs locally on macOS, Windows, or Linux, distributed as a signed binary or installer. The user double-clicks an `.app` / `.exe` / `.AppImage` / `.deb`, or runs `brew install` / `winget install` / `apt install`, and the program lives outside the browser sandbox. It can read the file system, hold long-running background state, talk to USB devices, integrate with the system menu bar / tray, and generally do things a web app cannot.

Two sub-archetypes:

- **Native** — one toolchain per OS. Cocoa/Swift on macOS; .NET MAUI / WPF / WinUI on Windows; Qt/C++ or GTK on Linux. Maximum platform fidelity; multiple codebases (or per-OS UI layers behind a shared core).
- **Cross-platform** — one codebase compiled or packaged for all three. Electron (Chromium + Node), Tauri (Rust + system webview), Flutter Desktop (Skia/Impeller renderer), Compose Multiplatform Desktop (Skia, JVM), .NET MAUI (Windows + macOS via Catalyst), Wails (Go + system webview).

> [!IMPORTANT]
> **In-depth review:** [Building Desktop Apps — Cross-Ecosystem Survey](building-desktop-apps.md) reviews 22 desktop frameworks plus 7 disregarded options on the same scoring rubric used elsewhere in this repo, with a dedicated pitfalls section (drag-files-out-of-window — Electron-only; Linux WebKitGTK fragmentation; code signing & notarisation; auto-update fragmentation). The summary below is a pointer; the cross-linked article is where to look for an actual stack decision.

### When to pick it

- **The product needs to run when the network is down.** Editors, IDEs, design tools, DAWs, terminals.
- **The product needs deep OS integration.** File-system watchers, system tray, global hotkeys, USB / serial / Bluetooth, printer drivers, hardware monitoring.
- **The product is performance-critical and benefits from native code paths.** Video editors, 3D modelling, code editors with millions of lines of source.
- **The product holds significant local state that the user owns.** Notes apps, password managers, local-first SaaS.
- **The product is a developer tool.** Developers expect a binary they can install with their package manager.

### When to avoid it

- The product is fundamentally a server with a UI. (You wanted a web app.)
- The audience is not technical and won't get past a Gatekeeper / SmartScreen / Linux-permissions warning. (PWA or web app.)
- You can't afford signing certificates, notarisation, and an updater pipeline. (Web app sidesteps all of this.)
- You only have web-developer skills and the product doesn't actually need OS integration. (Electron is the slot, but consider whether a PWA covers your needs at a fraction of the cost.)

### Frameworks (illustrative, not scored)

| Framework | Language | Style | Notable for |
| --- | --- | --- | --- |
| Cocoa / SwiftUI / AppKit | Swift / Obj-C | Native (macOS) | Day-one access to every Apple platform feature. |
| WPF / WinUI / WinForms | C# / XAML | Native (Windows) | Decades of Windows desktop heritage. |
| .NET MAUI | C# / XAML | Cross-platform native | Windows + macOS-via-Catalyst + iOS + Android. |
| Qt | C++ / QML | Cross-platform native | Long-standing cross-platform GUI; commercial + LGPL. |
| GTK | C / Rust / Vala | Native (Linux-leaning) | The GNOME stack. |
| Electron | TS / JS + Chromium + Node | Web-in-shell | Largest ecosystem; biggest binaries; VS Code, Slack, Discord, Figma desktop. |
| Tauri | Rust core + system webview + JS UI | Web-in-shell, lightweight | Smaller binaries; Rust backend; system webview. |
| Flutter Desktop | Dart + Skia/Impeller | Custom-renderer cross-platform | Same Flutter codebase as mobile; pixel-identical UI. |
| Compose Multiplatform Desktop | Kotlin + Skia | Custom-renderer cross-platform | JVM target; shares code with Android Compose. |
| Wails | Go + system webview | Web-in-shell | Go backend, like Tauri but Go-flavoured. |

### Distribution & install model

- **Distribution:**
  - Direct download (signed binary) from your site.
  - Mac App Store / Microsoft Store (review + sandboxing required).
  - Package managers: Homebrew, winget, Scoop, apt, dnf, Flatpak, Snap, AUR.
- **Install friction:** medium-to-high. The user must trust the binary, satisfy OS gatekeepers, and follow OS-specific install conventions.
- **Update cadence:** auto-update frameworks (Squirrel, Sparkle, Tauri Updater, MSIX, custom) deliver weekly-to-monthly. Slower than a web app, faster than a mobile-store release.

### Offline & state

- **Offline:** offline-first by default. Network is an enhancement, not a prerequisite.
- **State:** the user's machine is the source of truth (or a peer of it). Local databases (SQLite, LMDB, RocksDB), filesystem files, OS keychain for secrets.

## Mobile app — native and cross-platform

### Definition

An app installed via the iOS App Store or Google Play Store (and on Android, side-loaded `.apk` or alternative stores), running on a phone or tablet. As with desktop, the split is **native** (one toolchain per OS) versus **cross-platform** (one codebase, packaged for both).

> [!IMPORTANT]
> **In-depth review:** [Building Mobile Apps — Cross-Ecosystem Survey](building-mobile-apps.md) reviews 14 mobile frameworks plus 7 disregarded / EOL options on the same scoring rubric used elsewhere in this repo. The summary below is a pointer; the cross-linked article is where to look for an actual stack decision.

### When to pick it

- **The audience expects to find you in the App Store / Play Store.** Consumer products, anything billed via in-app purchase.
- **You need first-class hardware access.** Camera, GPS, accelerometer, Bluetooth LE, NFC, secure enclave, ARKit/ARCore, HealthKit/Health Connect, push notifications with full mobile-OS semantics.
- **You need to run as a foreground / background process with proper OS lifecycle.** (PWAs cannot fully match this on iOS.)
- **The use case is mobile-first.** Ride-sharing, on-the-go scanning, fitness, photo capture, AR.

### When to avoid it

- The product is a desktop or server tool with a phone view bolted on. (Build a [web app](#web-app) and make it responsive.)
- You don't have the resources for app-store review cycles, account management, and per-platform compliance. (PWA, web app.)
- You can deliver the experience as a [PWA](#progressive-web-app-pwa) and the audience will find / install it that way.

### Frameworks (illustrative — see [building-mobile-apps.md](building-mobile-apps.md) for scored reviews)

| Framework | Language | Archetype | Notable for |
| --- | --- | --- | --- |
| Swift + SwiftUI / UIKit | Swift | Native (iOS) | Day-one Apple feature access. |
| Kotlin + Jetpack Compose | Kotlin | Native (Android) | Day-one Android feature access. |
| Flutter | Dart | Cross-platform native renderer | One codebase, custom Skia/Impeller pipeline. |
| React Native (bare CLI) | TS / JS | JS bridge to native widgets | Real `UIView` / `View` driven by JS. |
| Expo | TS / JS | RN + managed tooling | The default RN starting point in 2026. |
| Capacitor (+ Ionic) | TS / JS + WebView | Web-view wrapper | Web app in a native shell. |
| Tauri Mobile | Rust + system webview | Rust shell + web UI | Tauri 2 mobile target. |
| Kotlin Multiplatform + Compose Multiplatform | Kotlin | Cross-platform native renderer | Share Kotlin across iOS/Android/desktop/web. |
| .NET MAUI | C# / XAML | Cross-platform native widgets | The .NET answer to Flutter. |
| NativeScript | TS / JS | Direct JS-to-native binding | No bridge, fewer plugins. |
| Lynx | TS / JS | Dual-thread JS engine | ByteDance's RN-shaped offering. |
| PWA | HTML / CSS / JS | Browser-installed | The control case; no app store. |

### Distribution & install model

- **Distribution:** Apple App Store, Google Play Store, alternative Android stores (Samsung Galaxy Store, F-Droid, Amazon Appstore), enterprise MDM, TestFlight / internal testing tracks.
- **Install friction:** lowest among installable types — users know the App Store gesture. But you pay distribution friction at the *developer* end (Apple Developer Program, Play Console, signing, provisioning, review, in-app-purchase compliance).
- **Update cadence:** typically days (review-mediated). Hotfixes via OTA are possible on RN/Expo (CodePush, EAS Update) and Capacitor (Capgo, Appflow), but Apple's policy bounds what can change OTA versus what requires a binary resubmission.

### Offline & state

- **Offline:** typically offline-tolerant. SQLite (via WatermelonDB / Drift / Room / Core Data), file system, secure storage.
- **State:** the device is a peer. Sync engines (Replicache, ElectricSQL, PowerSync, Couchbase Lite, Realm) are the standard answer for serious offline-first.

## Decision matrix

The five archetypes side-by-side. Read each row as: *if this property matters to me, how do the types compare?* No single column wins on all rows; you are picking the column where the *important-to-you* rows are good enough.

| Axis | Website | Web app | PWA | Desktop | Mobile |
| --- | --- | --- | --- | --- | --- |
| **Distribution** | CDN / static host | CDN / origin | CDN / origin (+ optional Microsoft Store / Play Store via TWA) | Direct download · Mac/Microsoft Store · package managers | App Store · Play Store · alternative stores · TestFlight / internal tracks |
| **Install friction** | None — visit a URL | None — visit a URL + sign in | Low — "Add to Home Screen" / install prompt | Medium — installer + signing + OS gatekeeper | Low for users (app-store gesture) · High for developers (review, signing, provisioning) |
| **Offline** | None by default | None by default | Yes — service-worker-driven, design choice | Yes — default | Yes — default |
| **Discoverability** | High — SEO is a primary channel | Medium — known URL or paid acquisition; SEO partial | Medium — same as web app; install discovery is weak | Low-medium — package managers, direct site, store listing | Highest in-store; depends on app-store SEO |
| **Update cadence** | Continuous (every deploy) | Continuous (every deploy) | Continuous (with service-worker update lifecycle quirks) | Days-to-weeks (auto-updater) · slower if store-distributed | Days (review) + OTA for code-only changes where allowed |
| **Native APIs** | None | None (browser APIs only) | Browser APIs + web-platform "capabilities" (Web Bluetooth, Web USB on Chromium; iOS lags) | First-class — full OS SDK | First-class — full OS SDK + sensors / camera / push / hardware |
| **Best for** | Marketing, docs, blogs, brochureware | SaaS, dashboards, internal tools, B2B | Web apps wanting app-shaped affordances cheaply | Local-first tools, dev tools, deep OS integration | Consumer mobile-first, hardware-driven, store-distributed billing |

A pragmatic reading of this matrix:

- **Default to the *thinnest* type that satisfies your requirements.** Website beats web app beats PWA beats desktop beats mobile in *operational* terms (every step right is more friction, more review, more compliance). Pay only for what you need.
- **Compose, don't pick once.** Most non-trivial products are *several* archetypes at once: a marketing site (website) + the product itself (web app) + a mobile companion (mobile app) + occasionally a desktop sync helper. The five types are not exclusive.
- **Distribution is destiny.** App-store distribution is a different *business model* than CDN distribution, and the engineering choice carries the business choice along with it.

## Cross-cutting concerns

Some properties cut across all five types and deserve their own articles or sections:

- **Authentication.** Every type that has users also has the same authentication-failure modes. Cookies vs tokens, OAuth/OIDC, passkeys, session lifecycle. See [Authentication on the web — a high-level guide](authentication.md). The mobile flavour adds keychain storage, biometric unlock, and OS-level credential providers; the desktop flavour adds OS keychain integration; the web/PWA flavour is the canonical reference.
- **Observability.** Web apps measure with browser RUM; mobile apps with Firebase / Sentry / proprietary; desktop with the platform's crash reporters. The instrumentation question carries across types.
- **Build / signing / release.** Each type has a different release artifact and a different signing story. Conflating them is the most common reason teams underestimate mobile or desktop projects.
- **Domain modelling.** Independent of artifact type. See [Domain-Driven Design](domain-driven-design.md).

## Related reading

- [Building Desktop Apps — Cross-Ecosystem Survey](building-desktop-apps.md) — full per-framework review of desktop-app stacks (Electron, Tauri 2, Electrobun, Wails, Flutter Desktop, Compose MP, Avalonia, Slint, iced, egui, .NET MAUI, Qt 6, GTK 4, RN Desktop, native Swift / WinUI / WPF, plus pitfalls deep-dive).
- [Building Mobile Apps — Cross-Ecosystem Survey](building-mobile-apps.md) — full per-framework review of mobile-app stacks (Flutter, React Native, Expo, Capacitor, Tauri Mobile, KMP, .NET MAUI, NativeScript, Lynx, Quasar, Solito, PWA, native iOS, native Android).
- [Tools for building web applications with Gleam](gleam/web-and-http/web-apps.md) — web-app archetype, Gleam-specific.
- [Building mobile apps with Gleam](gleam/mobile-apps.md) — mobile archetype, Gleam-specific (every path goes through JS + a shell).
- [Authentication on the web — a high-level guide](authentication.md) — cross-cutting; primer for any artifact with users.
- [Domain-Driven Design](domain-driven-design.md) — cross-cutting; orientation for any artifact with non-trivial business logic.
- [UX resources & tools](ux-resources-and-tools.md) — cross-cutting; UX laws and dogfooding apply to all five types.
