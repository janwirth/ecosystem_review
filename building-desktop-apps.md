# Building Native Desktop Apps — Cross-Ecosystem Survey

> [!NOTE]
> **Status:** DRAFT · **Authoring:** AI-assisted, human-reviewed.

> The state of "ship one app to macOS, Windows, and Linux" in 2026, scored side-by-side.

**Snapshot 2026-06-14** — metrics from live GitHub web UI only (no API, no clones). Star counts, last-commit dates, and open-issue counts reflect what a logged-out visitor sees today.

## Table of Contents

1. [Goal](#goal)
2. [Legend](#legend)
3. [Categories — the six archetypes](#categories--the-six-archetypes)
4. [What you actually pick when you pick a framework](#what-you-actually-pick-when-you-pick-a-framework)
5. [Per-framework reviews](#per-framework-reviews)
   - **Web view, bundled engine** — [Electron](#electron) · [NW.js](#nwjs)
   - **Web view, system webview** — [Tauri 2](#tauri-2) · [Electrobun](#electrobun) · [Wails](#wails) · [Neutralinojs](#neutralinojs)
   - **Custom canvas, cross-platform** — [Flutter Desktop](#flutter-desktop) · [Compose Multiplatform for Desktop](#compose-multiplatform-for-desktop) · [Avalonia](#avalonia) · [Slint](#slint) · [iced](#iced) · [egui](#egui) · [Dioxus Desktop](#dioxus-desktop)
   - **Native widgets, cross-platform** — [.NET MAUI Desktop](#net-maui-desktop) · [Uno Platform](#uno-platform) · [Qt 6](#qt-6) · [GTK 4](#gtk-4) · [React Native Desktop](#react-native-desktop)
   - **Native, one toolchain per OS** — [Swift + SwiftUI / AppKit (macOS)](#native-macos-swift--swiftui--appkit) · [WinUI 3 / WPF (Windows)](#native-windows-winui-3--wpf)
   - **Outliers** — [WebUI](#webui) · [Sciter](#sciter)
6. [Big comparison table](#big-comparison-table)
7. [Pitfalls — the things you'll bleed on](#pitfalls--the-things-youll-bleed-on)
   - [Drag files OUT of the window](#drag-files-out-of-the-window)
   - [Linux WebKitGTK fragmentation](#linux-webkitgtk-fragmentation)
   - [Wayland title-bar quirks](#wayland-title-bar-quirks)
   - [Bundle size & memory footprint](#bundle-size--memory-footprint)
   - [Code signing & notarisation](#code-signing--notarisation)
   - [Auto-update is per-OS and unfun](#auto-update-is-per-os-and-unfun)
   - [WebView2 install UX on Windows](#webview2-install-ux-on-windows)
8. [Disregarded / EOL / niche](#disregarded--eol--niche)
9. [Leaderboards (per use-case)](#leaderboards-per-use-case)
10. [Cross-link](#cross-link)
11. [Discovery — search queries](#discovery--search-queries)

## Goal

Help a tech lead or engineer choose a desktop-app stack in 2026 by laying every meaningful option side-by-side, scored on the same rubric, with desktop-specific dimensions added (targets, code language, rendering model, bundle size, auto-update, OS-integration depth). The article answers: *given my team, my distribution channel, and my tolerance for "feels like a web page in a window" vs "feels native," which row of the comparison table is the right starting point?*

Out-of-scope: game engines (Unity / Unreal / Godot — different design intent), terminal UIs / TUIs (Ratatui / Textual — different platform assumption), backend-as-a-service choice.

This article is the desktop sibling of [Building Mobile Apps](building-mobile-apps.md) and lives one level below [Application types — what kind of thing are you building?](application-types.md). Read that one first if you haven't decided you actually need a desktop binary.

## Legend

Standard scoring scaffold from `workflows/REVIEW_METHODOLOGY.md`:

- **Stars (community)** — ≥10k = 🟩🟩 · ≥1k = 🟩 · <100 = 🟥
- **License** — 🟩 permissive (MIT/Apache-2.0/BSD/MPL) · 🟨 weak copyleft (LGPL) · 🟥 viral (GPL/AGPL) or commercial-only
- **Maintenance** — latest commit vs snapshot. 🟩🟩 within last month · 🟩 within last year · 🟥 > 1 year stale
- **README maturity** — 🟩🟩 guide-style + feature list · 🟩 clear tagline + basic usage · 🟥 minimal/scaffold
- **Idiomaticity** — does it feel native to its ecosystem? 🟩🟩 yes · 🟩 partial · 🟥 alien
- **Issues** — count + qualitative read (high count on active project ≠ bad)
- **Age** — first-release year (older ≠ better; just signal of stability vs novelty)

Desktop-specific extra rows (added per the brief):

- **Targets** — macOS · Windows · Linux (X11 vs Wayland matters) · plus any bonus (iOS / Android / web / embedded)
- **Code language** — what the developer writes (Swift / C# / Rust / TS / JS / Dart / Kotlin / Go / C++ / C)
- **Rendering model** — *native widgets* (uses platform AppKit / Win32 / GTK / Qt) · *system web view* (WKWebView / WebView2 / WebKitGTK) · *bundled web engine* (full Chromium) · *custom canvas* (Skia / wgpu / Impeller / software) · *uses-user-browser* (no engine bundled at all)
- **Bundle size** — rough size of a hello-world install image. **Tiny** <5 MB · **Small** 5–20 MB · **Medium** 20–60 MB · **Huge** >100 MB
- **Auto-update** — *built-in* (framework ships an updater) · *DIY* (you wire Sparkle / Squirrel / MSIX / electron-updater yourself)
- **OS-integration depth** — *first-class* (native menus, tray, global hotkeys, system dialogs, drag-out-of-window all just work) · *plugin-mediated* (community crates / npm packages exist for most) · *limited* (you'll hit a wall on something)

## Categories — the six archetypes

Desktop frameworks split into six disjoint design-intents. The 7-dim score is comparable *within* an archetype, less so *across* — an Electron app and a SwiftUI app are not playing the same game.

1. **Web view + bundled engine** — *one codebase, ship a full browser engine with every app*. Electron, NW.js. UI is HTML/CSS/JS in a Chromium you control entirely. Maximum web-platform feature reach; multi-hundred-MB binaries; one Chromium per app means the second one you install starts a second copy in RAM.
2. **Web view + system web view** — *one codebase, use the OS's installed web engine*. Tauri 2, Wails, Electrobun, Neutralinojs, Dioxus (via `wry`). Tiny binaries (5–10 MB), but you inherit the OS's WebKit/WebView2 — including all the fragmentation that brings on Linux.
3. **Custom canvas (cross-platform)** — *one codebase, draw every pixel yourself*. Flutter Desktop, Compose Multiplatform Desktop, Avalonia, Slint, iced, egui, Dioxus's Blitz (in development). Pixel-perfect identical across OSes; widgets are not real `NSButton` / `Win32 Button` / `GtkButton`; A11y is the perpetual weakest area.
4. **Native widgets (cross-platform)** — *one codebase, real platform widgets via an abstraction layer*. .NET MAUI, Uno Platform, Qt 6 (QWidget), GTK 4, React Native Desktop. Real `UIButton` / `Button` / `GtkButton`; new platform APIs land in the abstraction layer later than native; lighter-weight than canvas-based.
5. **Native, one toolchain per OS** — *N codebases for N platforms, maximum fidelity*. Swift + SwiftUI / AppKit for macOS; WinUI 3 / WPF / WinForms for Windows; GTK / Qt for Linux. Day-zero access to every new platform feature; you staff every team separately.
6. **Outliers** — designs that don't fit any of the above. **WebUI** opens a browser the user already has installed (no engine bundled, no app window in the traditional sense). **Sciter** ships its own proprietary HTML/CSS engine (not Chromium, not WebKit) — historically used by antivirus UIs.

## What you actually pick when you pick a framework

When you adopt a stack, you're committing to a tuple:

```
┌─────────────────────────┐
│  Code language          │  ← Swift / C# / Rust / TS / Dart / Kotlin / Go / C++ / C
└────────────┬────────────┘
             │
             ▼
┌─────────────────────────┐
│  UI framework           │  ← SwiftUI / WPF / Electron / Tauri / Flutter / Compose / Qt
└────────────┬────────────┘
             │
             ▼
┌─────────────────────────┐
│  Rendering pipeline     │  ← Native widgets · Skia / Impeller · wgpu · WebView · Chromium
└────────────┬────────────┘
             │
             ▼
┌─────────────────────────┐
│  Packaging              │  ← .dmg + .pkg · .msi / .msix / .exe · .deb / .rpm / .AppImage / Flatpak / Snap
└────────────┬────────────┘
             │
             ▼
┌─────────────────────────┐
│  Code signing           │  ← Apple Developer ID + notarisation · Win EV cert + SmartScreen · Linux key (optional)
└────────────┬────────────┘
             │
             ▼
┌─────────────────────────┐
│  Distribution           │  ← Direct download · Mac/MS Store · Homebrew/winget/apt · Flatpak/Snap/AppImage
└────────────┬────────────┘
             │
             ▼
┌─────────────────────────┐
│  Auto-update            │  ← Sparkle (mac) · Squirrel/MSIX (Win) · AppImageUpdate / Flatpak / Snap (Linux)
└─────────────────────────┘
```

The **language** decision tends to be the most opinionated: a Rust shop will gravitate to Tauri / Dioxus / Slint / iced / egui; a .NET shop to MAUI / Uno / Avalonia / WPF; a Kotlin shop to Compose Multiplatform; a TS/JS shop to Electron / Tauri / Electrobun. Going native (Swift + WinUI + GTK in parallel) is the highest-fidelity outcome and the highest-headcount cost.

Every framework listed below also makes a **rendering decision** on your behalf — and that decision drives nearly every "feels native?" complaint downstream. If you can't tolerate "feels like a styled web page in a window," archetype 5 is the only honest answer. If you can, everything from Electron through Avalonia is on the table.

## Per-framework reviews

### Electron

**[github.com/electron/electron](https://github.com/electron/electron)** — 122k★ · MIT · latest commit 2026-06-14 · 🟩🟩 · 731 open issues · latest release **v42.4.0** (2026-06-09)

Atom/GitHub's web-engine-in-a-shell, the de-facto standard for "ship a web app as a desktop binary" since 2015. Bundles a full Chromium per app + a Node.js runtime; you get every Web Platform API at the same level as the latest Chrome, and a full Node API for native integration. The price is the size and the upgrade treadmill — every Chromium security release is your problem to ship.

- **Targets:** macOS 11+, Windows 10+, Linux (deb / rpm / AppImage / snap via [electron-builder](https://github.com/electron-userland/electron-builder)).
- **Code language:** TypeScript / JavaScript (+ optional native Node addons in C++ / Rust via N-API).
- **Rendering model:** **bundled Chromium** — your app ships its own browser engine.
- **Bundle:** **huge** — ~115 MB minimum hello-world on disk; 150–300 MB RSS for a running window after Chromium boot.
- **Auto-update:** **built-in** `autoUpdater` API — Squirrel.Mac on macOS, Squirrel.Windows or MSIX on Windows, `electron-updater` for AppImage on Linux. The mature path.
- **OS integration:** **first-class** — native menus, tray icons, global shortcuts, native dialogs, native file drag-out of the window all just work. **The drag-out story is unique in this list.**

**README maturity:** 🟩🟩 — comprehensive docs at electronjs.org including "Native File Drag & Drop", a maintained release cadence, and the largest community in this article.

**Production users:** VS Code, Slack, Discord, Figma Desktop, Notion, 1Password 8, Signal, Cursor, Claude Desktop, ChatGPT Desktop. The phrase "is it an Electron app?" answers itself for any product you've installed in the last five years that wasn't first-party.

**Pick when:** you have a web team and the bundle size doesn't matter (B2B SaaS desktop companion, dev tool, anything where the user accepts a 150 MB install); you need the full Web Platform without compatibility worries; you need drag files out of the window to Finder/Explorer (see [Pitfalls](#drag-files-out-of-the-window)).
**Pass when:** RAM / disk is a marketing decision (consumer utility, lightweight productivity tool, anything competing with a tray app); your audience is on Linux where competition from native GTK is sharper; you can stomach the smaller webview surface of Tauri.

> [!NOTE]
> Microsoft Teams left Electron in October 2023 for WebView2; this is the highest-profile "moved off Electron because it was too heavy" example to date and is widely cited as a wake-up call for any consumer-facing Electron product.

### NW.js

**[github.com/nwjs/nw.js](https://github.com/nwjs/nw.js)** — 41.2k★ · MIT · latest commit 2026-06-13 · 🟩🟩 · 887 open issues · latest release **v0.112.0** (Node 26.1 + Chromium 149, 2026-05-24) · first release 2011

Electron's older cousin — same idea (bundled Chromium + Node), different API. NW.js exposes both the Web Platform and the Node API on **the same context**, which feels convenient until it isn't (security model is more permissive than Electron's).

- **Targets:** macOS, Windows, Linux.
- **Code language:** JavaScript / TypeScript.
- **Rendering model:** bundled Chromium.
- **Bundle:** **huge** (~100–150 MB).
- **Auto-update:** **DIY** — no built-in path comparable to Electron's `autoUpdater`.

**Pick when:** you're already on NW.js and migration cost dominates; you specifically want unified Node + DOM context.
**Pass when:** new project — Electron has the larger community, the maintained auto-updater, and the more polished tooling (electron-builder).

### Tauri 2

**[github.com/tauri-apps/tauri](https://github.com/tauri-apps/tauri)** — 108k★ · Apache-2.0 + MIT (dual) · latest commit 2026-06-14 · 🟩🟩 · ~1.3k open issues · latest CLI **2.11.2** (2026-05-16) · Tauri 2.0 GA 2024-10

The Rust-core-plus-system-webview alternative. **WebView2 on Windows**, **WKWebView on macOS**, **WebKitGTK on Linux** — wired via the `wry` and `tao` crates. Tauri 2 added mobile targets (iOS / Android) and a new plugin system. Hello-world is **~3–10 MB** on disk — about 1/20 the size of Electron.

- **Targets:** Windows 7+, macOS 10.15+, Linux (deb / rpm / AppImage), iOS, Android.
- **Code language:** Rust (backend) + any web frontend (React, Svelte, Solid, Leptos, Yew, vanilla — the framework doesn't care).
- **Rendering model:** **system web view** — you inherit the OS's web engine.
- **Bundle:** **small** (~3–10 MB hello-world).
- **Auto-update:** **built-in** `tauri-plugin-updater` — signature-verified JSON manifest; works on macOS / Windows; handles AppImage on Linux.
- **OS integration:** **plugin-mediated** — Tauri plugins for the common cases (FS, dialog, clipboard, notifications, shell). Custom Rust plugins are documented but the catalogue is younger than npm's.

**README maturity:** 🟩🟩 — v2 docs at v2.tauri.app are guide-style + reference.

**Production users:** Cap (screen recorder), Spacedrive (file manager), Ariadne (Git client), various commercial SaaS desktop apps. Adoption is real and growing but the marquee names (1Password / VS Code-scale) still ship on Electron.

**Pick when:** you want a small binary, the bundle size matters for downloads or first-run experience, you're already a Rust shop or willing to invest, your audience is mostly mac + Windows.
**Pass when:** you need drag-files-out-of-the-window (see [Pitfalls](#drag-files-out-of-the-window) — Tauri does not ship this in core); you ship to Linux as a first-class target and need consistent rendering across distros (WebKitGTK fragmentation will bite you — see below); you need every Web Platform API at the level of the latest Chrome.

> [!CAUTION]
> **The Linux WebKitGTK story is the single biggest gotcha for new Tauri adopters in 2026.** See the dedicated [Linux WebKitGTK fragmentation](#linux-webkitgtk-fragmentation) section.

### Electrobun

**[github.com/blackboardsh/electrobun](https://github.com/blackboardsh/electrobun)** — 12.2k★ · MIT · latest commit 2026-06-13 · 🟩🟩 · 192 open issues · first release 2024

Bun-runtime-meets-system-webview. Positions itself between Tauri (tiny, system webview, no JS runtime) and Electron (full JS runtime, huge). You write TypeScript that runs on Bun (not Node), and the UI renders in the OS's web view.

- **Targets:** macOS (most mature), Windows, Linux.
- **Code language:** TypeScript (Bun runtime).
- **Rendering model:** system web view.
- **Bundle:** **small** (~10–20 MB hello-world — bigger than Tauri because Bun is bundled, smaller than Electron because Chromium isn't).
- **Auto-update:** **built-in** — Sparkle-style update channels with delta updates.

**Production users:** the author's own portfolio and a small set of indie apps; pre-1.0 — no marquee public production case yet.

**Pick when:** you want Tauri's bundle size with a JS-native backend (no Rust on the team); macOS is your primary target.
**Pass when:** you need a mature ecosystem today (Tauri 2 and Electron both have years of head start); production-readiness on Windows/Linux is critical (still maturing).

### Wails

**[github.com/wailsapp/wails](https://github.com/wailsapp/wails)** — 34.8k★ · MIT · latest commit 2026-06-12 · 🟩🟩 · 128 open issues · latest release **v2.12.0** (2026-03-26) · v3 in alpha

Tauri-shaped but Go-backed. Same system-webview approach (WKWebView / WebView2 / WebKitGTK), Go on the backend instead of Rust. The Go community's headline desktop framework.

- **Targets:** macOS, Windows, Linux.
- **Code language:** Go (backend) + any web frontend.
- **Rendering model:** system web view.
- **Bundle:** **small** (~10 MB hello-world).
- **Auto-update:** **DIY** — no built-in updater; users wire `go-update` or platform-specific tooling.

**Production users:** [October.dev](https://october.dev), various Go shop internal tools. No name-brand consumer app at Electron's level of recognition.

**Pick when:** you're a Go shop and want a desktop UI in your native language; bundle size matters; you can build the updater yourself.
**Pass when:** you need a built-in auto-updater out of the box (Tauri ships one, Wails doesn't); you ship to Linux first-class (same WebKitGTK fragmentation as Tauri); v3 churn — production teams sit on v2 while v3 stabilises.

### Neutralinojs

**[github.com/neutralinojs/neutralinojs](https://github.com/neutralinojs/neutralinojs)** — 8.5k★ · MIT · latest commit 2026-06-11 · 🟩🟩 · 156 open issues · latest release **v6.8.0** (2026-06-03) · first release 2020

The lightest of the system-webview wrappers. C++ core, no embedded JS runtime, no Node API — you talk to the native layer via a small bridge from your web frontend. Hello-world binary is **under 2 MB**.

- **Targets:** macOS, Windows, Linux, "cloud mode" (run as a local server, talk to via any browser).
- **Code language:** any (HTML/CSS/JS frontend; backend extensions in any language via stdio).
- **Rendering model:** system web view.
- **Bundle:** **tiny** (<2 MB binary).
- **Auto-update:** **built-in** updater API (manifest-based).

**Pick when:** you want the absolute smallest binary; you don't need a rich native API (Neutralino's surface is narrower than Tauri's by design); you're shipping a single-purpose utility.
**Pass when:** you need a deep native plugin ecosystem; you need WebSocket / native menus / system tray; you need first-class macOS feel.

### Flutter Desktop

**[github.com/flutter/flutter](https://github.com/flutter/flutter)** — 177k★ · BSD-3-Clause · latest commit 2026-06-14 · 🟩🟩 · ~5k+ open issues · desktop GA Flutter 3 (2022)

Same Flutter as on mobile, with desktop targets. Skia → Impeller renders every pixel yourself; widgets are *Flutter's*, not the OS's; one Dart codebase ships to six surfaces (iOS, Android, macOS, Windows, Linux, web).

- **Targets:** macOS, Windows, Linux (GTK backend), iOS, Android, web. Linux Wayland support depends on the GTK backend.
- **Code language:** Dart.
- **Rendering model:** **custom canvas** (Impeller via Metal on mac, Vulkan on Linux, ANGLE/Direct3D on Windows).
- **Bundle:** **medium** (~15–30 MB hello-world — engine bundled).
- **Auto-update:** **DIY** — no built-in; community packages like [`auto_updater`](https://pub.dev/packages/auto_updater) cover the common path.

**Production users:** Canonical Ubuntu installer (the install-time UI on recent Ubuntu releases is Flutter), Superlist, BMW infotainment, Google Pay desktop, ByteDance internal tools. Desktop adoption is real but thinner than mobile.

**Pick when:** you already have a Flutter mobile app and want a desktop sibling sharing 90 %+ of code; pixel-perfect identical UX across OSes matters more than feels-native; you can absorb the limitation that *every* widget is a Flutter widget.
**Pass when:** native look-and-feel is non-negotiable; you need first-party desktop A11y on day 1 (still trails mobile); Linux is your headline platform and you want GTK-native behaviour (Flutter renders its own widgets through GTK, but the result is still custom-canvas, not native).

### Compose Multiplatform for Desktop

**[github.com/JetBrains/compose-multiplatform](https://github.com/JetBrains/compose-multiplatform)** — 19.1k★ · Apache-2.0 · latest commit 2026-06-14 · 🟩🟩 · ~1 open issue *(positive surface signal; most tracking happens on JetBrains' YouTrack)* · latest release **1.11.1** (2026-06-02)

JetBrains' Kotlin-native UI toolkit, now stable across iOS, Android, desktop (JVM), and web (Wasm beta). Desktop targets compile to JVM and use [`jpackage`](https://docs.oracle.com/en/java/javase/21/docs/specs/man/jpackage.html) to produce native installers (`.dmg`, `.msi`, `.deb`).

- **Targets:** macOS, Windows, Linux (via JVM); also Android, iOS, web.
- **Code language:** Kotlin.
- **Rendering model:** **Skia custom canvas** — same engine family as Flutter, different toolkit shape.
- **Bundle:** **medium-to-large** (~30–50 MB hello-world — JRE bundled).
- **Auto-update:** **DIY** (community packages; no first-party updater).

**Production users:** **JetBrains' own products** (Toolbox app; **Fleet** is built entirely on it); Wrike, Netflix Prodicle. The JetBrains dogfooding is the strongest production signal in the cross-platform category.

**Pick when:** you're already a Kotlin / Android shop; you value JetBrains tooling (IntelliJ / Android Studio); you want one Kotlin codebase from server to desktop to mobile via KMP.
**Pass when:** JVM cold-start (~1–2 s) is a marketing problem; bundle size matters more than native widgets; A11y depth matters today (the weakest area).

### Avalonia

**[github.com/AvaloniaUI/Avalonia](https://github.com/AvaloniaUI/Avalonia)** — 31k★ · MIT · latest commit 2026-06-13 · 🟩🟩 · ~1.8k open issues · latest release **12.0.4** (2026-05-28)

WPF-spiritual-successor for cross-platform. .NET runtime + Skia rendering; XAML dialect (AXAML) for declarative UI. The strongest non-Microsoft cross-platform .NET desktop story.

- **Targets:** macOS, Windows, Linux (X11 + Wayland), iOS, Android, WebAssembly, embedded.
- **Code language:** C# + XAML (AXAML).
- **Rendering model:** **custom canvas** (Skia-based).
- **Bundle:** **medium** (~30–50 MB self-contained .exe / .app).
- **Auto-update:** **DIY** — [Velopack](https://github.com/velopack/velopack) is the most popular community updater (former Squirrel.Windows-derivative reborn for .NET).

**Production users:** **JetBrains** uses Avalonia for dotTrace / dotMemory on Linux and macOS, and for Rider integrations. Wasabi Wallet. Microsoft has formally partnered with the Avalonia team to bring .NET MAUI to Linux via Avalonia (announced November 2025 — see .NET MAUI section).

**Pick when:** you're a .NET shop and want cross-platform without Microsoft's roadmap risk on MAUI; you need a real WPF replacement that targets more than Windows; XAML is already on your team's CV.
**Pass when:** you need native widgets (Avalonia is canvas-based — A11y on Linux relies on AT-SPI plumbing the project maintains); your team isn't on .NET.

### Slint

**[github.com/slint-ui/slint](https://github.com/slint-ui/slint)** — 22.9k★ · GPL-3 / royalty-free / commercial (tri-license) · latest commit 2026-06-12 · 🟩🟩 · ~750 open issues · latest release **1.16.1** (2026-04-23)

Embedded-first declarative UI that grew up. `.slint` DSL files describe the UI; the runtime is **<300 KiB on embedded targets** and renders via Femtovg / Skia / software. Desktop is now a first-class target alongside MCU-class embedded.

- **Targets:** macOS, Windows, Linux (X11 + Wayland), web (WASM), embedded (down to MCU).
- **Code language:** Slint DSL + Rust / C++ / JavaScript / Python.
- **Rendering model:** **custom canvas** (Femtovg / Skia / software).
- **Bundle:** **small** — desktop hello-world under 5 MB.
- **Auto-update:** DIY.

**Production users:** **LibrePCB** is mid-migration from Qt to Slint for v2.0; embedded vendors (specific names typically under NDA). Desktop adoption growing.

**Pick when:** you ship to both desktop and embedded from one codebase; you want Rust-native UI without the immediate-mode trade-offs of egui; you can tolerate (or pay for) the GPL/commercial license model.
**Pass when:** you need a permissive license without paying; you need a deep widget gallery comparable to Qt / Avalonia; you specifically want WebKit / Chromium under the hood.

> [!WARNING]
> The default tri-license includes **GPL-3.0** — any proprietary distribution requires either the royalty-free license (with telemetry / attribution constraints) or the **commercial license**. This is a real cost for closed-source apps.

### iced

**[github.com/iced-rs/iced](https://github.com/iced-rs/iced)** — 30.7k★ · MIT · latest commit 2026-06-11 · 🟩🟩 · ~350 open issues · latest release **0.14.0** (2025-12-07)

Elm-inspired retained-mode Rust GUI on wgpu. Smallest cross-platform Rust footprint among toolkits that are not immediate-mode; pre-1.0 so the API still moves between releases.

- **Targets:** macOS, Windows, Linux (X11 + Wayland), web (WASM).
- **Code language:** Rust.
- **Rendering model:** **custom canvas via wgpu**.
- **Bundle:** **small** (~5–15 MB).
- **Auto-update:** DIY.

**Production users:** **System76 COSMIC desktop environment** is the flagship adopter — iced is the official toolkit for COSMIC apps (Pop!_OS / System76's GNOME-replacement DE). Squad lobbies and a long tail of Rust indie tools.

**Pick when:** you're building Rust GUI apps and you specifically want Elm-style architecture; you're shipping to COSMIC or want to align with the System76 ecosystem.
**Pass when:** you want native widgets; you need a stable 1.0+ API (iced is still on 0.x); the widget gallery vs Slint/Avalonia matters.

### egui

**[github.com/emilk/egui](https://github.com/emilk/egui)** — 29.4k★ · Apache-2.0 + MIT (dual) · latest commit 2026-06-11 · 🟩🟩 · ~915 open issues · latest release **0.34.3** (2026-05-27)

Immediate-mode Rust GUI on wgpu. No retained widget tree — you describe the UI every frame, and egui draws it. The dev loop is fast and the API is small; the trade-off is that complex stateful UIs (with text editing, accessibility, deeply nested layouts) become awkward.

- **Targets:** macOS, Windows, Linux, web (WASM), embedded.
- **Code language:** Rust.
- **Rendering model:** **custom canvas via wgpu / glow**.
- **Bundle:** **small** (~5–15 MB).
- **Auto-update:** DIY.

**Production users:** **[Rerun](https://rerun.io)** is the flagship adopter — visualisation SDK; Bevy editor tooling; cargo-binstall TUI; many Bevy game tools.

**Pick when:** you want the fastest path to a usable Rust GUI for a tool or visualizer; the UI is mostly read-and-display rather than complex stateful input; immediate-mode is a feature, not a bug.
**Pass when:** you're shipping a productivity app with deep text editing, accessibility, or complex nested forms; you need native menus / dialogs (you'll need to bring your own platform crates).

### Dioxus Desktop

**[github.com/DioxusLabs/dioxus](https://github.com/DioxusLabs/dioxus)** — 36.4k★ · Apache-2.0 + MIT (dual) · latest commit 2026-06-13 · 🟩🟩 · ~609 open issues · latest release **v0.7.9** (2026-05-08)

React-shaped Rust UI library with multiple renderers: desktop currently uses **`wry`** (Tauri's underlying web view) under the hood, with the **Blitz** custom wgpu renderer in development as a native option that would shift Dioxus from archetype 2 to archetype 3.

- **Targets:** macOS, Windows, Linux, iOS (alpha), Android (alpha), web.
- **Code language:** Rust (JSX-style RSX macro).
- **Rendering model:** today, **system web view via `wry`** (same as Tauri); future, **Blitz custom wgpu renderer**.
- **Bundle:** **small** (~5 MB hello-world — similar to Tauri).
- **Auto-update:** DIY.

**Pick when:** you want React-shaped DX with Rust under the hood; you're building cross-platform with a strong web-component story; you can ride the 0.x API.
**Pass when:** you need today's drag-out-to-Finder (same `wry` limitation as Tauri); you need a stable 1.0+ API; you want native widgets right now (Blitz is not production-ready).

### .NET MAUI Desktop

**[github.com/dotnet/maui](https://github.com/dotnet/maui)** — 23.3k★ · MIT · latest commit 2026-06-13 · 🟩🟩 · ~3.8k open issues · latest release **10.0.71** (2026-06-10)

Microsoft's Xamarin successor. **No native Linux target** in 2026 — Microsoft announced a partnership with the Avalonia team in November 2025 to bring MAUI to Linux *via* Avalonia.

- **Targets:** Windows (WinUI 3), **macOS (via Mac Catalyst only)**, iOS, Android. Linux via Avalonia partnership (announced Nov 2025).
- **Code language:** C# + XAML.
- **Rendering model:** **native widgets via abstraction** — `<Button>` becomes `Microsoft.UI.Xaml.Controls.Button` on Windows, `UIButton` on iOS, `Android.Widget.Button` on Android. **macOS uses Mac Catalyst** (UIKit-via-AppKit), not native AppKit.
- **Bundle:** **medium** (~30–50 MB self-contained).
- **Auto-update:** **DIY** — MSIX background updates on Windows; nothing built-in for macOS.

**Production users:** mostly the mobile side; desktop adoption thin. **Microsoft Teams itself does not use MAUI** — it uses WebView2.

**Pick when:** you're a .NET shop committed to first-party Microsoft tooling; iOS + Android + Windows mobile-and-desktop from one codebase is the goal; you can tolerate Mac Catalyst's iPad-shaped behaviour on macOS.
**Pass when:** macOS feel matters (use Avalonia or native Swift instead); Linux is on your roadmap and you don't want to wait; the high open-issue count concerns you (3.8k — second-highest in this article).

> [!IMPORTANT]
> **macOS-via-Mac-Catalyst is a real limitation.** Programmatic window resize/reposition doesn't work the way an AppKit app would; the app is sandboxed; the UX feels "iPad-on-Mac" rather than "Mac." If your audience cares about macOS feel, the partnership-with-Avalonia is going to land on Linux earlier than full AppKit support on macOS.

### Uno Platform

**[github.com/unoplatform/uno](https://github.com/unoplatform/uno)** — 10k★ · Apache-2.0 · latest commit 2026-06-13 · 🟩🟩 · ~1.3k open issues · latest release **6.5.64** (2026-02-11)

The "WinUI everywhere" project — write WinUI XAML once, run on Windows (native WinUI), macOS / Linux (Skia canvas), iOS / Android (native widgets), WebAssembly.

- **Targets:** Windows (native WinUI), macOS, Linux (Skia + GTK / framebuffer), iOS, Android, WASM.
- **Code language:** C# + XAML (WinUI dialect).
- **Rendering model:** **mixed** — native widgets on Win/iOS/Android, Skia canvas on macOS/Linux.
- **Bundle:** **medium** (~30–60 MB).
- **Auto-update:** DIY.

**Pick when:** you want WinUI on every surface (specifically Microsoft Store + cross-platform); you're invested in the Uno tooling ecosystem (Hot Reload).
**Pass when:** you want consistent rendering (Uno's split model means platform-specific bugs); you don't already have WinUI XAML expertise; Avalonia's pure-canvas model is simpler to reason about for your team.

### Qt 6

**[code.qt.io/cgit/qt/qtbase.git](https://code.qt.io/cgit/qt/qtbase.git)** (canonical) · [github.com/qt/qtbase](https://github.com/qt/qtbase) (read-only mirror) — LGPL-3 / GPL-3 / commercial · latest commit 2026-06-12 (dev branch) · latest release **Qt 6.11** (March 2026); Qt 6.12 Beta 1 available · first release Qt 6.0 in 2020 (Qt 1.0 in 1995)

The grand old man of cross-platform desktop. C++ + QML, multi-decade history, ships in some of the world's most-shipped applications. The license model is the trade-off.

- **Targets:** macOS, Windows, Linux (X11 + Wayland), iOS, Android, embedded.
- **Code language:** C++ (QML for declarative UI); also Python (PyQt / PySide).
- **Rendering model:** native-ish widgets (`QWidget`) + custom canvas (QML / Scene Graph).
- **Bundle:** **medium** (~20–50 MB).
- **Auto-update:** **DIY** — Qt Installer Framework (Qt IFW) supports it.

**Production users:** **KDE Plasma**, **Telegram Desktop**, **Autodesk Maya**, **OBS Studio**, **VLC**, **Krita**, Bitwarden CLI tools. By breadth of well-known native-feeling apps shipped, Qt's record is unmatched in this article.

**Pick when:** you need the deepest cross-platform native-widget toolkit available; you ship to Linux as a first-class target where Qt's KDE-lineage feels at home; you have C++ or Python expertise.
**Pass when:** the LGPL caveat (dynamic-linking-only for free use) is incompatible with your distribution model; you need to static-link without buying commercial; Web Platform feature reach matters.

> [!WARNING]
> **License caveats** — Qt is LGPL-3 + GPL-3 + commercial tri-license. Using Qt under LGPL **requires dynamic linking**; static linking pushes you to the commercial license (~€5,500+/yr per developer). Embedded distribution typically requires commercial too. This is well-documented sales friction and the single biggest reason new projects in 2026 look at Slint / Avalonia / Flutter first.

### GTK 4

**[gitlab.gnome.org/GNOME/gtk](https://gitlab.gnome.org/GNOME/gtk)** (canonical) · [github.com/GNOME/gtk](https://github.com/GNOME/gtk) (read-only mirror) — LGPL-2.1+ · latest release **GTK 4.22.4** (2026-04-30) · first release GTK 4.0 December 2020 (GTK 1.0 in 1998)

The other elder cross-platform native toolkit, with a strong Linux centre of gravity. GTK 4's GSK renderer is GPU-accelerated; the modern Linux desktop stack is largely GTK + Wayland.

- **Targets:** Linux (X11 + Wayland) — first-class. Windows, macOS — community ports of varying quality.
- **Code language:** C (canonical) + first-class bindings: Rust ([gtk4-rs](https://github.com/gtk-rs/gtk4-rs)), Python (PyGObject), JavaScript (GJS), Vala.
- **Rendering model:** native widgets with GPU-accelerated GSK renderer.
- **Bundle:** **small on Linux** (system library); **larger on Windows / macOS** (must bundle GTK + dependency tree, ~80 MB).
- **Auto-update:** **DIY** — Flatpak handles updates on Linux; no story for Windows / macOS ports.

**Production users:** **GNOME core apps** (Files / Nautilus, GIMP 3, Builder), Fractal, Inkscape (via GTK port), Mozilla Firefox UI on Linux.

**Pick when:** Linux is your headline platform; you're building a GNOME-aligned app and want full HIG compliance; you want first-class Wayland support today.
**Pass when:** macOS / Windows are first-class targets (the ports lag); your audience uses KDE Plasma (Qt is the native fit there); theming on non-GNOME desktops will be an ongoing maintenance cost.

### React Native Desktop

Microsoft maintains two production-grade RN forks for desktop:

**[github.com/microsoft/react-native-windows](https://github.com/microsoft/react-native-windows)** — 17.4k★ · MIT · 🟩🟩 — uses **native WinUI 3** widgets on Windows.
**[github.com/microsoft/react-native-macos](https://github.com/microsoft/react-native-macos)** — 17.3k★ · MIT · 🟩🟩 — uses **native AppKit** widgets on macOS.

Both are Microsoft-shepherded forks of RN's New Architecture (Fabric + TurboModules) with native renderers per OS. Linux is **not** a target — community attempts (`react-native-linux`) exist but are not production-grade.

- **Targets:** Windows (`react-native-windows`), macOS (`react-native-macos`). No Linux.
- **Code language:** TypeScript.
- **Rendering model:** **native widgets** — `<Text>` becomes real `TextBlock` (WinUI 3) / `NSTextView` (AppKit). Not a canvas, not a webview.
- **Bundle:** **medium** (~20–50 MB).
- **Auto-update:** DIY — uses platform updaters (MSIX / Sparkle / Squirrel).

**Production users:** Microsoft Office desktop modules use RN-for-Windows for some UI surfaces (this is the headline production usage for the project).

**Pick when:** you already have an RN mobile codebase and want to share components with a Windows / macOS app; you're in the Microsoft ecosystem (Office add-ins, Teams components); native widgets matter.
**Pass when:** Linux is on the roadmap; you want a single one-fork RN for desktop (you'd need to maintain Windows and macOS forks separately); the project's roadmap dependence on Microsoft's continued investment is a strategic concern.

### Native (macOS): Swift + SwiftUI / AppKit

**[github.com/swiftlang/swift](https://github.com/swiftlang/swift)** — language · 70.1k★ · Apache-2.0 · latest commit 2026-06-13 · 🟩🟩 · latest release Swift 6.3.2 (2026-06-04)
**SwiftUI / AppKit** ship inside the macOS SDK (closed source, distributed via Xcode).

Apple's first-party macOS stack. SwiftUI hit feature-parity with AppKit for most common cases around macOS 14 (2023) and the bar continues to rise; AppKit remains the answer for deeply customised UI, document-based apps with complex state, and anything where SwiftUI's declarative model gets in the way.

- **Targets:** macOS 10.15+ (SwiftUI minimum); also iOS / iPadOS / tvOS / watchOS / visionOS via the same SDKs.
- **Code language:** Swift (Objective-C still works for legacy code).
- **Rendering model:** native AppKit (Core Animation / Metal under the hood).
- **Bundle:** **small** (~5–20 MB).
- **Auto-update:** **[Sparkle](https://sparkle-project.org)** — the gold-standard third-party updater used by virtually every major Mac app; EdDSA-signed appcasts, delta updates, hosted on any static file server.
- **OS integration:** **first-class** — everything. Native menu bar, Touch ID prompt, Apple Intelligence on-device APIs, Continuity Camera, Stage Manager, ARKit, HealthKit, etc.

**Production users:** Things 3, Bear, Ulysses, Reeder, Pixelmator Pro, Acorn, Linear (macOS app), Apple's own apps. The standard for "feels like a Mac app."

**Pick when:** macOS is your primary or only target; you need ARKit / Metal / HealthKit / on-device Apple Intelligence; print-quality animation and Apple-grade A11y matter.
**Pass when:** Windows / Linux matter (Swift compiles cross-platform but SwiftUI does **not** — there's no UI story); your team has zero Swift bandwidth.

### Native (Windows): WinUI 3 / WPF

**[github.com/microsoft/microsoft-ui-xaml](https://github.com/microsoft/microsoft-ui-xaml)** — 7.7k★ · MIT · 🟩🟩 — WinUI 3 controls
**[github.com/microsoft/WindowsAppSDK](https://github.com/microsoft/WindowsAppSDK)** — 4.6k★ · MIT · 🟩🟩 · latest release **WindowsAppSDK 2.2.0** (2026-06-10) — Win32 + WinRT bridge
**[github.com/dotnet/wpf](https://github.com/dotnet/wpf)** — 7.7k★ · MIT · 🟩🟩 — WPF (Windows-only, legacy but maintained)

Microsoft's modern native Windows stack is WinUI 3 + WindowsAppSDK (formerly Project Reunion); WPF remains for legacy and is still actively maintained. Both produce native Win32 / DirectX-backed apps.

- **Targets:** Windows 10 1809+, Windows 11.
- **Code language:** C++ / C# + XAML.
- **Rendering model:** native widgets (DirectX-backed).
- **Bundle:** **small** (~10 MB self-contained for WinUI 3 with shared WindowsAppRuntime; ~70 MB self-contained for WPF).
- **Auto-update:** **MSIX** if packaged; otherwise DIY (ClickOnce, MSI, custom).

**Production users:** Microsoft Files app, Microsoft PC Manager, Windows Terminal (WinUI 3), parts of Visual Studio (WPF). Microsoft Teams notably uses **WebView2**, not native — illustrative of how internal Microsoft preferences vary.

**Pick when:** Windows is your only or primary target; you want platform-native feel; you can absorb the install-time WindowsAppRuntime dependency for WinUI 3.
**Pass when:** macOS / Linux / mobile matter; the WinUI 3 tooling churn (Project Reunion → WindowsAppSDK rename, MSIX vs unpackaged story) is a concern.

### WebUI

**[github.com/webui-dev/webui](https://github.com/webui-dev/webui)** — 4.1k★ · MIT · latest commit 2026-06-13 · 🟩🟩 · 6 open issues *(very low — positive signal)* · latest release **v2.5.0-beta.4**

Not really a "desktop app" framework in the conventional sense — WebUI is a **library you embed in any program** to open a window of the user's installed browser as your UI. No engine bundled, no app framework, no GUI library. The smallest of the small.

- **Targets:** macOS, Windows, Linux — uses whatever browser the user has installed.
- **Code language:** any (C / C++ / Rust / Go / Python / Node / Deno / Zig bindings).
- **Rendering model:** **uses the user's installed browser** (Chrome / Edge / Firefox / etc. opens; your app talks to it via local WebSocket).
- **Bundle:** **tiny** (<1 MB binary).
- **Auto-update:** DIY.

**Pick when:** you're a CLI tool author who wants a quick UI without bundling 100+ MB; you're shipping to a technical audience that has a browser installed; you want the absolute minimum binary.
**Pass when:** you need a "real" app window that feels like an app; your audience expects a polished install experience; you need cross-frame native menus, system tray, etc.

### Sciter

**[gitlab.com/c-smile/sciter-js-sdk](https://gitlab.com/c-smile/sciter-js-sdk)** (canonical; **GitHub mirrors archived 2023**) — closed-core proprietary · BSD-3 on SDK wrappers · commercial from $310 one-time

Proprietary HTML/CSS engine — neither Chromium nor WebKit. Originally targeted by antivirus shops looking for a small, sandboxed UI runtime; the engine itself is closed source and the modern Sciter.JS variant ships with QuickJS instead of V8.

- **Targets:** macOS, Windows, Linux.
- **Code language:** HTML / CSS + custom JS (QuickJS).
- **Rendering model:** **custom HTML/CSS engine** (proprietary, ~5 MB DLL).
- **Bundle:** **very small** (~5 MB).
- **Auto-update:** DIY.

**Production users:** **Norton, Bitdefender, ESET, Comodo** antivirus UIs; eMule. Legacy antivirus stack mostly; modern adoption is rare.

**Pick when:** you specifically need a sandboxed, tiny, proprietary HTML/CSS UI runtime — basically the antivirus / security-tool corner where the requirement set is unusual.
**Pass when:** you want any of: open-source engine, modern Web Platform features, large community, GitHub-discoverable issues, an active commercial roadmap visible to OSS users.

> [!CAUTION]
> The GitHub repos were archived in 2023; canonical development moved to GitLab. The one-maintainer (Andrew Fedoniouk / c-smile) story is a concentration risk worth flagging.

## Big comparison table

| Dimension | [Electron](#electron) | [Tauri 2](#tauri-2) | [Electrobun](#electrobun) | [Wails](#wails) | [Neutralinojs](#neutralinojs) | [Flutter Desktop](#flutter-desktop) | [Compose MP](#compose-multiplatform-for-desktop) | [Avalonia](#avalonia) | [Slint](#slint) | [iced](#iced) | [egui](#egui) | [Dioxus](#dioxus-desktop) | [.NET MAUI](#net-maui-desktop) | [Uno](#uno-platform) | [Qt 6](#qt-6) | [GTK 4](#gtk-4) | [RN Windows](#react-native-desktop) | [RN macOS](#react-native-desktop) | [Swift+SwiftUI](#native-macos-swift--swiftui--appkit) | [WinUI 3 / WPF](#native-windows-winui-3--wpf) | [NW.js](#nwjs) | [WebUI](#webui) | [Sciter](#sciter) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| **Stars** | 122k · 🟩🟩 | 108k · 🟩🟩 | 12.2k · 🟩🟩 | 34.8k · 🟩🟩 | 8.5k · 🟩 | 177k · 🟩🟩 | 19.1k · 🟩🟩 | 31k · 🟩🟩 | 22.9k · 🟩🟩 | 30.7k · 🟩🟩 | 29.4k · 🟩🟩 | 36.4k · 🟩🟩 | 23.3k · 🟩🟩 | 10k · 🟩🟩 | mirror † | mirror † | 17.4k · 🟩🟩 | 17.3k · 🟩🟩 | 70.1k (Swift) · 🟩🟩 | 7.7k+4.6k · 🟩 | 41.2k · 🟩🟩 | 4.1k · 🟩 | 1.6k · 🟩 |
| **License** | MIT · 🟩 | Apache-2.0 + MIT · 🟩 | MIT · 🟩 | MIT · 🟩 | MIT · 🟩 | BSD-3 · 🟩 | Apache-2.0 · 🟩 | MIT · 🟩 | GPL-3 / commercial · 🟥 | MIT · 🟩 | Apache-2.0 + MIT · 🟩 | Apache-2.0 + MIT · 🟩 | MIT · 🟩 | Apache-2.0 · 🟩 | LGPL-3 / GPL-3 / commercial · 🟨 | LGPL-2.1+ · 🟨 | MIT · 🟩 | MIT · 🟩 | Apache-2.0 (Swift) · 🟩 | MIT · 🟩 | MIT · 🟩 | MIT · 🟩 | proprietary · 🟥 |
| **Latest release** | v42.4.0 (2026-06-09) | CLI 2.11.2 (2026-05-16) | pre-1.0 (could not verify) | v2.12.0 (2026-03-26) | v6.8.0 (2026-06-03) | rolling | 1.11.1 (2026-06-02) | 12.0.4 (2026-05-28) | 1.16.1 (2026-04-23) | 0.14.0 (2025-12-07) | 0.34.3 (2026-05-27) | v0.7.9 (2026-05-08) | 10.0.71 (2026-06-10) | 6.5.64 (2026-02-11) | Qt 6.11 (Mar 2026) | GTK 4.22.4 (2026-04-30) | tracks RN | tracks RN | Swift 6.3.2 (2026-06-04) | WindowsAppSDK 2.2.0 (2026-06-10) | v0.112.0 (2026-05-24) | v2.5.0-beta.4 | 4.4.8.34 (2022 on GitHub mirror) |
| **Open issues** | 731 | ~1.3k | 192 | 128 | 156 | 5k+ | ~1 ‡ | ~1.8k | ~750 | ~350 | ~915 | ~609 | ~3.8k | ~1.3k | tracker on code.qt.io | tracker on gitlab.gnome.org | tracks RN | tracks RN | 5k+ (Swift compiler) | ~2.4k | 887 | 6 *(positive)* | archived on GitHub |
| **Targets** | mac / Win / Linux | mac / Win / Linux + iOS / Android | mac / Win / Linux | mac / Win / Linux | mac / Win / Linux | mac / Win / Linux + iOS / Android / web | mac / Win / Linux + Android / iOS / web (Wasm) | mac / Win / Linux + iOS / Android / WASM / embedded | mac / Win / Linux + web / embedded | mac / Win / Linux + web | mac / Win / Linux + web / embedded | mac / Win / Linux + iOS / Android / web | Win / **macOS via Catalyst** / iOS / Android (Linux via Avalonia partnership Nov 2025) | Win (native WinUI) / mac / Linux (Skia) / iOS / Android / WASM | mac / Win / Linux + iOS / Android / embedded | Linux (first-class) + Win / mac (community ports) | Windows | macOS | macOS / iOS / iPadOS / tvOS / watchOS / visionOS | Windows | mac / Win / Linux | mac / Win / Linux (uses installed browser) | mac / Win / Linux |
| **Code language** | TS / JS | Rust + web | TS (Bun) | Go + web | any (HTML/CSS/JS frontend) | Dart | Kotlin | C# + XAML | Slint DSL + Rust / C++ / JS / Py | Rust | Rust | Rust | C# + XAML | C# + WinUI XAML | C++ + QML (or Python PyQt/PySide) | C (+ Rust / Python / JS / Vala bindings) | TS | TS | Swift | C++ / C# + XAML | TS / JS | C / C++ / Rust / Go / Python / Node | HTML / CSS + JS (QuickJS) |
| **Rendering** | bundled Chromium | system webview | system webview | system webview | system webview | custom canvas (Impeller) | custom canvas (Skia) | custom canvas (Skia) | custom canvas (Femtovg / Skia / SW) | custom canvas (wgpu) | custom canvas (wgpu / glow) | system webview (via wry) → Blitz wip | native widgets (mac via Catalyst) | mixed (native Win/iOS/Android; Skia mac/Linux) | native-ish (QWidget + QML) | native widgets (GSK) | native widgets (WinUI 3) | native widgets (AppKit) | native widgets (AppKit) | native widgets (DirectX) | bundled Chromium | uses user browser | proprietary HTML/CSS engine |
| **Bundle** | huge (~115–200 MB) | small (~3–10 MB) | small (~10–20 MB) | small (~10 MB) | tiny (<2 MB) | medium (~15–30 MB) | medium-large (~30–50 MB, JRE) | medium (~30–50 MB) | small (<5 MB on desktop) | small (~5–15 MB) | small (~5–15 MB) | small (~5 MB) | medium (~30–50 MB) | medium (~30–60 MB) | medium (~20–50 MB) | small on Linux; larger on Win/mac (~80 MB) | medium (~20–50 MB) | medium (~20–50 MB) | small (~5–20 MB) | small (~10 MB WinUI; ~70 MB WPF self-contained) | huge (~100–150 MB) | tiny (<1 MB) | very small (~5 MB) |
| **Auto-update** | **built-in** (Squirrel / MSIX / electron-updater) | **built-in** (signature-verified manifest) | **built-in** (Sparkle-style) | DIY | **built-in** | DIY | DIY | DIY (Velopack popular) | DIY | DIY | DIY | DIY | DIY (MSIX on Win) | DIY | DIY (Qt IFW) | DIY (Flatpak on Linux) | DIY | DIY (Sparkle / Squirrel) | **Sparkle** (de-facto standard) | MSIX or DIY | DIY | DIY | DIY |
| **Drag-out to Finder/Explorer** | ✅ first-class | ❌ core; community [drag-rs](https://github.com/crabnebula-dev/drag-rs) | ❌ | ❌ | ❌ | ❌ (platform code) | ❌ (platform code) | ❌ (platform code) | ❌ | ❌ | ❌ | ❌ (shared wry gap) | platform-specific | platform-specific | ✅ (Qt's native APIs) | ✅ (GTK's native APIs) | platform-specific | platform-specific | ✅ first-class (AppKit) | ✅ first-class (Win32) | ✅ first-class | ❌ | ❌ |
| **First release** | 2013 | 2022 (v2 GA Oct 2024) | 2024 | 2019 | 2020 | 2017 (desktop GA Flutter 3 in 2022) | 2021 | 2017 alpha; 11.0 2023 | 2020 (was SixtyFPS); 1.0 in 2023 | 2019 alpha | 2020 | 2021 | 2022 (.NET 6) | 2018 | Qt 6.0 in 2020 (Qt 1.0 in 1995) | GTK 4.0 Dec 2020 (GTK 1.0 in 1998) | 2018 | 2019 | 2014 (Swift) · 2019 (SwiftUI) | WPF 2006; WinUI 3 GA 2021 | 2011 | 2020 | ~2006 |

> † Qt and GTK GitHub repos are read-only mirrors; canonical development happens on code.qt.io and gitlab.gnome.org respectively. The mirror star counts (Qt qtbase ~3k, GTK ~1.7k) are not representative of community size — both projects have multi-decade community footprints.
>
> ‡ Compose Multiplatform's GitHub Issues tab shows ~1 open. Most issue tracking happens on JetBrains' YouTrack. Treat as a venue artifact, not a maintenance signal.

## Pitfalls — the things you'll bleed on

The "stars + license + last commit" rubric will get you to a shortlist of three. The things below are what separates the framework that ships your product from the one that becomes a six-month detour.

### Drag files OUT of the window

This is the single most-asked-about cross-framework feature in 2026, and the answer is **Electron is uniquely good here**.

- **Electron** — first-class via [`startDrag` on the WebContents](https://www.electronjs.org/docs/latest/tutorial/native-file-drag-drop). You can drag a generated file from your app to Finder / Explorer / Slack / a Mail compose window with one API call.
- **Tauri 2** — **not in core**. Tracking issue [tauri-apps/tauri#6664](https://github.com/tauri-apps/tauri/issues/6664) ("[feat] Support for dragging files from Tauri window to filesystem") and the user lament in [#7551](https://github.com/tauri-apps/tauri/issues/7551) ("File drag and drop problem, why can't it be the same as Electron?"). The community plugin **[drag-rs](https://github.com/crabnebula-dev/drag-rs)** (by crabnebula-dev) implements it for mac / Win / Linux(GTK); the rough edges and per-platform tweaks are on you.
- **Wails, Electrobun, Neutralinojs, Dioxus Desktop** — same gap as Tauri (shared `wry` / WebView2 / WKWebView / WebKitGTK layer).
- **Native (Swift / WinUI / WPF / Qt / GTK)** — first-class via the platform's drag-and-drop APIs. The "feels native" benefit, in concrete form.
- **Flutter / Compose MP / Avalonia / Slint / iced / egui** — possible with platform-specific code; no built-in cross-platform API. You write the macOS / Windows / Linux variants yourself.

**Verdict:** if your product's job involves *generating files the user wants to drag elsewhere* (export an image, drop a CSV into a Mail compose, drop a video into a chat), Electron solves this in one line and the rest of the field doesn't. This is one of the few places where Electron's "ship a whole browser" approach is technically the correct answer.

### Linux WebKitGTK fragmentation

The most-cited reason for adopters to leave Tauri after 6 months. Tauri / Wails / Electrobun / Dioxus all use **WebKitGTK** on Linux via `wry` (Tauri's underlying webview crate, shared by the others). Different Linux distros ship different WebKitGTK versions, and the rendering behaviour diverges in ways that are not visible until you test on Fedora / Ubuntu / Arch / Debian separately.

Documented issues (all on the Tauri repo, but the WebKitGTK root cause is shared):

- [tauri-apps/tauri#7021](https://github.com/tauri-apps/tauri/issues/7021) — WebKit2GTK 2.40 caused a perf regression that landed silently in a routine `apt upgrade` for Tauri + Preact apps.
- [tauri-apps/tauri#13157](https://github.com/tauri-apps/tauri/issues/13157) — "Glitchy rendering on Linux" — shadow copies of DOM elements after `window.maximize() / .unmaximize()`.
- [tauri-apps/tauri/discussions#8524](https://github.com/orgs/tauri-apps/discussions/8524) — community wishlist titled "Webkit is totally unstable, so we need to use chromium or firefox instead."
- [tauri-apps/tauri/discussions#9088](https://github.com/tauri-apps/tauri/discussions/9088) — "Problem with WebKitGTK".

**Verdict:** if Linux is a first-class target *and* the rendering quality must be identical across distros, the system-webview frameworks are the wrong choice. Move to a bundled-engine option (Electron) for pixel parity, or a canvas-based option (Flutter / Compose MP / Avalonia / Slint / iced) where the renderer is yours and the distro can't break it.

### Wayland title-bar quirks

Tauri-specific cluster, all on the upstream `tao` window manager + GTK-bridge layer:

- [#13749](https://github.com/tauri-apps/tauri/issues/13749) — `Window.setTitle` updates the taskbar but not the header bar on Wayland.
- [#13440](https://github.com/tauri-apps/tauri/issues/13440) — window control buttons unresponsive on Wayland until double-click.
- [#11631](https://github.com/tauri-apps/tauri/issues/11631) — broken buttons when `resizable: false` + `skip_taskbar: true` combination.
- [#12074](https://github.com/tauri-apps/tauri/issues/12074) — weird menu behaviour with custom titlebar.
- [#13142](https://github.com/tauri-apps/tauri/issues/13142) — feature request to toggle custom GTK title bar.
- [#9458](https://github.com/tauri-apps/tauri/issues/9458) — feature request for Electron-style custom titlebar with native window controls.

**Verdict:** if you want an iOS-style custom titlebar AND first-class Wayland support, the year-2026 answer is "wait, or do it yourself in Rust." Standard system titlebars work fine. Custom is a sharp edge.

### Bundle size & memory footprint

Hello-world install sizes from a fresh `init` template, on disk:

| Framework | On-disk install | Memory (post-boot) |
| --- | --- | --- |
| **Electron** | **~115–200 MB** | **~150–300 MB RSS** |
| NW.js | ~100–150 MB | ~150–300 MB RSS |
| Tauri / Wails / Electrobun / Dioxus | ~3–10 MB | ~50–100 MB RSS |
| Neutralinojs | <2 MB | ~30–60 MB RSS |
| Flutter Desktop | ~15–30 MB | ~80–150 MB RSS |
| Compose Multiplatform (JVM) | ~30–50 MB | ~150–250 MB RSS (JVM cold-start: 1–2 s) |
| Avalonia / .NET MAUI | ~30–50 MB | ~80–150 MB RSS |
| Slint / iced / egui | ~5–15 MB | ~30–80 MB RSS |
| Qt 6 (dynamic LGPL) | ~20–50 MB | ~50–120 MB RSS |
| GTK 4 (Linux, system lib) | small | ~30–80 MB RSS |
| Swift + SwiftUI (macOS) | ~5–20 MB | ~50–100 MB RSS |
| WinUI 3 (Windows) | ~10 MB self-contained | ~50–100 MB RSS |
| WPF (Windows, self-contained) | ~70 MB | ~50–100 MB RSS |

**Verdict:** if your product's job is "open quickly, sit small in the tray, sip RAM" (consumer utility, menu-bar app, Spotlight-like launcher), Electron is the wrong choice. Tauri / Slint / native are right. If your product opens once a session and stays open (VS Code, Slack), bundle size is a marketing footnote and Electron's developer velocity advantage is the real driver.

### Code signing & notarisation

The boring, per-platform infrastructure cost.

**macOS:**
- Apple Developer Program: **$99/year**.
- Developer ID Application certificate (for direct downloads outside the Mac App Store): renewable every 5 years; expiry silently breaks CI.
- **Notarisation** (the actual Apple-staple step that runs the binary through a malware scan): typically 2–5 minutes, can be 15–20+. The 2023 `altool` → `notarytool` migration broke many CI pipelines.
- Universal binaries (Intel + Apple Silicon) require manual `lipo` step with Swift sidecars.
- Free Apple Developer accounts **cannot notarise**.
- Hardened-runtime conflicts with native Node modules in Electron — see [forasoft.com/blog/article/the-pain-of-publishing-electron-apps-on-macos-303](https://www.forasoft.com/blog/article/the-pain-of-publishing-electron-apps-on-macos-303).

**Windows:**
- EV (Extended Validation) code-signing certificate: ~**$249–$580/year** depending on CA.
- **Since 2023 CA/B Forum mandate, the EV private key must live on a FIPS 140-2 / EAL 4+ hardware token** — this breaks naive CI signing workflows (you can't just stash the cert in GitHub Secrets and call `signtool`). Cloud HSMs (Azure Key Vault, AWS CloudHSM, DigiCert KeyLocker) are the production answer.
- **As of 2024, EV no longer bypasses SmartScreen on first download** — reputation rebuild is required regardless of EV.
- Standard (non-EV) signing certs work but trigger more SmartScreen warnings on initial download.

**Linux:**
- No mandatory signing equivalent. Optional: GPG-sign your release artifacts; Flatpak / Snap stores handle their own signing.

**Verdict:** budget at least **$350–$700/year** for signing, plus 1–2 days of one-time CI setup per platform. If you don't have a CI engineer, AppImage on Linux + Mac App Store on macOS + Microsoft Store on Windows let you outsource most of this to the stores in exchange for review delays.

### Auto-update is per-OS and unfun

| Platform | Mature options | Notes |
| --- | --- | --- |
| **macOS** | [**Sparkle**](https://sparkle-project.org) (gold standard) · electron-updater (uses Squirrel.Mac) | Sparkle is what virtually every native Mac app uses. EdDSA-signed appcasts, delta updates, hosted as static files. **Squirrel.Mac was last released 2017 and is widely considered abandoned.** |
| **Windows** | MSIX background updates (if packaged) · electron-updater · Velopack · Squirrel.Windows | MSIX is Microsoft's modern path. **Squirrel.Windows is "intermittently maintained, abandoned several times" per [Conveyor's comparison](https://conveyor.hydraulic.dev/6.1/comparisons/electron-comparisons/).** Velopack (former Squirrel.Windows fork, now its own thing) is the modern .NET answer. |
| **Linux** | AppImageUpdate · Flatpak · Snap · electron-updater | **AppImage has no standardised built-in update mechanism** — some apps embed AppImageUpdate, most don't. Flatpak (Flathub) and Snap both auto-update via their stores. Per industry consensus, **Flatpak has won the Linux universal-package fight as of 2026** (see [computingforgeeks.com Snap vs Flatpak vs AppImage](https://computingforgeeks.com/snap-vs-flatpak-vs-appimage/)). |

**Verdict:** the only framework that ships a comprehensive built-in story across all three OSes is **Electron** (via electron-updater) and **Tauri** (via tauri-plugin-updater). Everyone else, you're shopping for an updater per platform. Plan for it.

### WebView2 install UX on Windows

Specific to system-webview frameworks (Tauri / Wails / Electrobun / Dioxus):

- WebView2 runtime is **pre-installed on Windows 11**. **Windows 10 may not have it** — the installer must bootstrap it.
- Default Tauri Windows installer **downloads** the WebView2 bootstrapper at install time, which requires internet on first install ([tauri-apps/tauri#4389](https://github.com/tauri-apps/tauri/issues/4389)).
- Options: embed the bootstrapper (+1.8 MB installer), or embed the **fixed-version runtime** (+**180 MB** installer — defeats the small-bundle pitch).

**Verdict:** if you ship to corporate Windows fleets that block runtime downloads, the bootstrapper-embed option is the right one (1.8 MB is still tiny). If you ship to consumer Windows where users may be offline at install, embed the runtime or document the prerequisite.

## Disregarded / EOL / niche

These are real options but explicitly **not recommended for new 2026 projects** — included so the corner is auditable.

| Tool | Reason |
| --- | --- |
| **Xamarin.Forms** ([dotnet/xamarin-forms](https://github.com/dotnet/xamarin-forms)) | **End-of-support 2024-05-01.** Migrate to .NET MAUI. |
| **Squirrel.Mac** ([Squirrel/Squirrel.Mac](https://github.com/Squirrel/Squirrel.Mac)) | Last release 2017; widely considered abandoned. **Sparkle** is the macOS answer. |
| **AppImage as a primary distribution model on its own** | Without AppImageUpdate or a side-channel updater, AppImage has no update mechanism. Use it as a fallback, not the primary path. |
| **NW.js** for new projects | Functional and maintained, but Electron has the larger community, better tooling (electron-builder), and a maintained auto-updater. Existing NW.js apps may stay; new projects start on Electron. |
| **Cordova on desktop** | Cordova's electron platform was officially deprecated. Use Electron directly. |
| **Carlo** (Google's now-removed Puppeteer-shaped framework) | Removed by Google in 2020. Use Electron / Tauri / WebUI. |
| **Sciter** for new mainstream desktop apps | Closed-core engine; GitHub repos archived 2023 (active dev on GitLab); single-maintainer story; legacy antivirus stack mostly. Modern projects pick Tauri / Electron / Slint. |

## Leaderboards (per use-case)

The 7-dim score is comparable within an archetype, not across. These leaderboards collapse along **task** instead.

### Maximum native feel (every platform pixel + every new SDK on day 0)

1. 🥇 **Native (Swift + SwiftUI / WinUI 3 / GTK or Qt)** — by definition. New Apple / Microsoft / GNOME APIs land here first.
2. 🥈 **Qt 6** — the strongest single-codebase native-toolkit answer; downside is the license model.
3. 🥉 **GTK 4** — native on Linux first-class; ports on Win/mac lag.
4. **React Native Desktop (Windows + macOS)** — native widgets via JS bridge; the React-to-real-AppKit / WinUI 3 story is real.
5. **.NET MAUI** — native widgets via abstraction, but macOS-via-Catalyst is a real limit and Linux is "via Avalonia partnership."

### Smallest binary / lightest install

1. 🥇 **Neutralinojs** — <2 MB. The literal smallest.
2. 🥈 **WebUI** — <1 MB binary, but you're depending on the user having a browser.
3. 🥉 **Tauri 2** — ~3–10 MB. The most-mature small option.
4. **Slint / Wails / Electrobun** — ~5–15 MB tier.
5. **iced / egui / Dioxus Desktop** — ~5–15 MB.

### Maximum code reuse with an existing web team

1. 🥇 **Electron** — your existing React/Vue/Svelte/Solid app is the desktop app, plus full Node API for native integration.
2. 🥈 **Tauri 2** — same code-reuse story with a Rust backend instead of Node, smaller binary, system webview's risks attached.
3. 🥉 **Wails** — same idea, Go backend.
4. **Electrobun** — same idea, Bun-as-Node.
5. **Neutralinojs** — barest possible C++ shell; works if you want minimal native surface.

### Best developer experience for fast iteration / solo / small team

1. 🥇 **Electron** — the deepest community (Stack Overflow / blog posts), the most npm packages, electron-builder, electron-updater, the most production examples.
2. 🥈 **Tauri 2** — second-deepest community among cross-platform options; great docs at v2.tauri.app; the Rust learning curve is the tax.
3. 🥉 **Flutter Desktop** — `flutter create` and you're on `flutter run`; stateful hot reload is gold-standard.
4. **Compose Multiplatform** — JetBrains tooling is excellent; JVM cold-start is the friction.
5. **Avalonia** — Visual Studio + Rider tooling; XAML Hot Reload; the most polished .NET cross-platform DX.

### Performance-sensitive / animation-heavy / data-visualisation

1. 🥇 **Native (Swift + Metal / DirectX)** — uncontested on raw frame budgets and GPU access.
2. 🥈 **Flutter Desktop (Impeller)** — 90–120 fps stable on Impeller; precompiled shaders mean no runtime jank.
3. 🥉 **Slint / iced / egui** — wgpu-based Rust toolkits; the lightest-overhead cross-platform options.
4. **Qt 6 with QML Scene Graph** — Qt's QML rendering is GPU-accelerated and battle-tested in production (Maya, Krita, OBS).
5. **Compose Multiplatform** — Skia is competitive; JVM cold-start hurts perception.
6. **Electron / Tauri / Wails / web-view-based** — WebView ceiling. Fine for line-of-business UI; not for 60+ fps custom animation.

### Drag files OUT of the window (the export-to-Finder workflow)

1. 🥇 **Electron** — one-line API, first-class.
2. 🥈 **Native (Swift+AppKit / WinUI / Qt / GTK)** — first-class via the platform's drag APIs; you write per-platform code anyway.
3. 🥉 **Tauri + [drag-rs](https://github.com/crabnebula-dev/drag-rs)** — community plugin works, rough edges on platform parity.
4. **Wails / Electrobun / Dioxus** — same gap as Tauri, same community workarounds.
5. **Flutter / Compose MP / Avalonia / Slint / iced / egui** — possible with platform code; no built-in cross-platform API.

### Headless / scripting / "I want a CLI tool that opens a window"

1. 🥇 **WebUI** — designed for exactly this. <1 MB, multi-language bindings.
2. 🥈 **Neutralinojs** — tiny, language-agnostic, system webview.
3. 🥉 **Tauri 2** — heavier than WebUI but with a proper plugin / API surface.

### Best Linux story (where Linux is the primary target)

1. 🥇 **GTK 4** — native on Linux; Wayland-first; the GNOME default.
2. 🥈 **Qt 6** — native on KDE Plasma and beyond; license caveats attached.
3. 🥉 **Electron** — bundles its own Chromium, so distros can't break rendering; large but consistent.
4. **Flutter Desktop** — GTK backend; canvas-based so distro variance doesn't break visual output (though native integration is lighter).
5. **iced** — System76 COSMIC's official toolkit; the Rust-native answer for Linux DEs.

Tauri / Wails / Electrobun / Dioxus / Neutralinojs are all on the **avoid for headline Linux apps** list due to [WebKitGTK fragmentation](#linux-webkitgtk-fragmentation).

### Existing Rust / .NET / Go / Kotlin shop wanting desktop

| Existing skill | Best fit | Reasoning |
| --- | --- | --- |
| **Rust** | Tauri 2 (web frontend) / Slint or iced (native canvas) / Dioxus (React-shaped) | Only major options that put Rust at the application core. |
| **.NET / C#** | Avalonia (cross-platform Skia) / .NET MAUI (Win + mobile + future Linux via Avalonia) / WPF (Win-only legacy) / WinUI 3 (Win-only modern) | Avalonia is the strongest pure cross-platform option for new .NET projects in 2026. |
| **Go** | Wails | The only mainstream Go-native desktop framework. |
| **Kotlin / Android team** | Compose Multiplatform Desktop | Share code with Android Compose; JVM cold-start is the tax. |
| **TypeScript / React** | Electron (mature) / Tauri 2 (small) / Electrobun (smaller Bun-native) | Pick by bundle-size tolerance and willingness to take on Rust (Tauri) or Bun (Electrobun). |
| **Swift / Apple-only shop** | Native Swift + SwiftUI / AppKit | The native answer; ship to Mac App Store and direct download with Sparkle. |
| **C++** | Qt 6 (license-aware) / native Win32 + Cocoa + GTK in parallel | Qt is the historical default; native triple-stack is the highest-fidelity option for AAA-quality desktop. |

## Cross-link

> See also: **[Application types — what kind of thing are you building?](application-types.md)** — the orientation step *before* picking a desktop framework. If you're not 100 % sure you need a desktop binary at all, read that first; the [Desktop app section](application-types.md#desktop-app--native-and-cross-platform) has the "when desktop earns its keep vs PWA" analysis.

> See also: **[Building Mobile Apps — Cross-Ecosystem Survey](building-mobile-apps.md)** — the sister article for mobile. Many of the same frameworks appear (Flutter, .NET MAUI, Compose Multiplatform, Tauri 2, Capacitor) with different per-platform trade-offs.

Other adjacent ecosystem reviews:

- [Web apps in Gleam](gleam/web-and-http/web-apps.md) — full-stack frameworks, the input side of a "JS-compile-then-shell" desktop pipeline.
- [Authentication on the web](authentication.md) — cross-cutting; OS keychain integration is a desktop-specific extension of the same primer.
- [Diagramming tools](diagramming.md) — sister cross-ecosystem survey under a top-level dir, same style.

## Discovery — search queries

Searches that surfaced the candidates above (so the next snapshot can re-run the sweep):

- `desktop app framework 2026 cross-platform`
- `Tauri 2 vs Electron 2026 bundle size`
- `Electrobun Bun runtime desktop framework`
- `Wails v3 Go desktop framework 2026`
- `Neutralinojs lightweight desktop framework`
- `Flutter Desktop 2026 production apps`
- `Compose Multiplatform 1.11 desktop release notes`
- `Avalonia 12 cross-platform .NET desktop`
- `Slint 1.16 desktop framework Rust`
- `iced GUI Rust System76 COSMIC 2026`
- `egui Rerun production Rust GUI`
- `Dioxus 0.7 desktop Blitz renderer`
- `.NET MAUI Linux Avalonia partnership 2025`
- `Uno Platform Skia macOS Linux 2026`
- `Qt 6.11 LGPL commercial license 2026`
- `GTK 4 Wayland 2026 release`
- `react-native-windows microsoft 2026`
- `react-native-macos 2026`
- `WebUI library cross-language 2026`
- `Sciter.JS 2026 status GitLab archive`
- `Tauri Linux WebKitGTK fragmentation issues`
- `Electron drag files out of window API`
- `Tauri drag files Finder Explorer plugin drag-rs`
- `macOS notarytool altool migration code signing Electron`
- `Windows EV code signing certificate hardware token 2024`
- `Sparkle vs Squirrel auto update macOS comparison`
- `AppImage Flatpak Snap auto update Linux 2026`
- `WebView2 install UX Windows Tauri runtime`

Frameworks intentionally excluded from this snapshot (out-of-scope, not "disregarded"):

- **Game engines** (Unity, Unreal, Godot, Cocos, defold, Bevy as a UI framework) — different design intent.
- **TUI / terminal UI** (Ratatui, Textual, Bubble Tea, Charm, ncurses) — terminal target, not desktop window.
- **Mobile-first frameworks treated as mobile-only here** — covered in [Building Mobile Apps](building-mobile-apps.md): Expo, Capacitor (on mobile), Lynx, NativeScript, Solito, KMP without Compose Multiplatform Desktop, Quasar (mobile build target).
- **In-IDE plugin frameworks** (VS Code extensions, JetBrains plugin SDK) — extend an existing host, not a standalone desktop product.
- **Backend-as-a-service / desktop sync engines** (Replicache, ElectricSQL, Couchbase Lite, Realm) — orthogonal layer; can pair with any framework above for local-first apps.
