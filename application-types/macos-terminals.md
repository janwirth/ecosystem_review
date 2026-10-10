# macOS terminal emulators: choose for configuration ownership

> [!NOTE]
> **Status:** DRAFT · **Authoring:** AI-assisted; macOS hands-on evaluation pending.

**Snapshot: 2026-10-10.** Goal: choose a terminal whose configuration is understandable, recoverable, and suited to the workflow. Companion guide: [recovering terminal configuration](macos-terminal-recovery.md). Replacing the emulator can improve configuration ownership; it does not repair a broken shell startup file.

## Evaluation criteria

Judge configuration portability, precedence, discoverability, native macOS integration, tabs and panes, remote compatibility, accessibility, and upgrade stability. Rendering speed matters when it fixes a measured problem. It should not outweigh recoverability for this request.

Use the [shared review method](../workflows/REVIEW_METHODOLOGY.md), adapted to applications rather than language libraries. Repository health is context; capability and fit decide the shortlist. Documentation-based recommendations are separate from the unrun hands-on checks below.

## Choosing a configuration model

Text configuration makes review and backup straightforward, but file discovery and defaults can change between versions. GUI profiles provide discoverability and richer integration, but need an explicit export strategy. A system-bundled app has the lowest installation cost; a third-party app has a separate upgrade lifecycle. No model is automatically immune to macOS changes.

For Apple Terminal, export profiles and back up shell files separately. For Ghostty and Alacritty, keep one canonical config and verify which path the installed version reads. [Apple profile export](https://support.apple.com/guide/terminal/import-and-export-terminal-profiles-trml4299c696/mac), [Ghostty configuration](https://ghostty.org/docs/config), [Alacritty configuration](https://alacritty.org/config-alacritty.html).

## Configuration drift that changes recommendations

Ghostty's current docs call the file `config.ghostty`, with `config` used before 1.2.3. They list both XDG and macOS Application Support locations. Keeping conflicting copies makes debugging harder. Check the installed version and its effective configuration rather than copying an old blog's filename. Reload support is useful, but some changes still require a new surface or restart. [Ghostty current config docs](https://ghostty.org/docs/config).

Alacritty's current configuration format is TOML. A YAML example from an older setup is not a current configuration recipe. Its macOS search includes XDG paths and `$HOME/.alacritty.toml`; inspect current documentation for precedence before migrating files. Its narrower UI can suit users who already rely on tmux. [Alacritty config reference](https://alacritty.org/config-alacritty.html).

## Hands-on acceptance before switching

1. Launch from Finder and from a shell. Compare shell mode, PATH, and working directory.
2. Restore settings on a clean macOS user account. Confirm fonts, keys, tabs/panes, and shell startup.
3. Test Unicode, clipboard, search, and a real long-output workload. Check VoiceOver and keyboard navigation for your needs.
4. Connect to a representative SSH host. Check terminal capabilities and your editor; do not pretend a different `TERM` value proves compatibility.
5. Upgrade one version and restore the backup. Confirm defaults and config paths, then decide whether to change the default app.

Record macOS version, hardware, emulator version, configuration, and test outcome. No performance ranking is claimed without that record. The comparison below evaluates Alacritty, Ghostty, and alternatives from current primary sources.

## Current releases and feature matrix

Versions below are snapshot observations, not upgrade instructions. iTerm2's official download page is authoritative for its stable distribution; its GitHub “latest release” entry is stale.

| Terminal | Verified release baseline | Config ownership | Native tabs / independent panes | Best reason to choose it |
| --- | --- | --- | --- | --- |
| Ghostty | 1.3.1, 2026-03-13 | Small text config; XDG and macOS paths | Yes / yes | Native macOS interface with reviewable configuration |
| Alacritty | v0.17.0, 2026-04-06 | TOML, imports, live reload | No / no | Focused renderer when tmux already owns the session workflow |
| iTerm2 | 3.7.4, 2026-10-08; macOS 13+ | GUI, exported settings, Dynamic Profiles | Yes / yes | Rich established macOS workflows and configuration UI |
| kitty | v0.49.2, 2026-10-01 | `kitty.conf`, layouts and session files | Yes / yes | Cross-platform keyboard-driven layouts and extensions |
| WezTerm | Stable `20240203-110809-5046fc22` | Lua configuration, multiplexing | Yes / yes | Programmable cross-platform terminal and session topology |
| Apple Terminal | Bundled with macOS; no separate release baseline | GUI profiles exported as `.terminal` | Yes / no independent shell panes | Existing fallback with no third-party install |

Primary release sources: [Ghostty release index](https://ghostty.org/docs/install/release-notes), [Alacritty v0.17.0](https://github.com/alacritty/alacritty/releases/tag/v0.17.0), [iTerm2 stable downloads](https://iterm2.com/downloads.html), [kitty v0.49.2](https://github.com/kovidgoyal/kitty/releases/tag/v0.49.2), [WezTerm stable release](https://github.com/wezterm/wezterm/releases/tag/20240203-110809-5046fc22). Features: [Ghostty actions](https://ghostty.org/docs/config/keybind/reference), [Alacritty FAQ](https://github.com/alacritty/alacritty), [iTerm2 features](https://iterm2.com/features.html), [kitty overview](https://sw.kovidgoyal.net/kitty/overview/), [WezTerm multiplexing](https://wezterm.org/multiplexing.html), [Apple Terminal guide](https://support.apple.com/guide/terminal/welcome/mac).

### Ghostty: first trial for text config plus native UI

Keep one authoritative file, usually `~/.config/ghostty/config.ghostty`. On macOS, Application Support configuration loads after XDG configuration and can override it. Legacy `config` filenames remain supported. Check both locations before diagnosing an ignored setting. Ghostty offers automatic shell integration and native tabs/splits without introducing tmux solely for local panes. [Configuration](https://ghostty.org/docs/config), [shell integration](https://ghostty.org/docs/features/shell-integration).

This is the first trial for this request because reviewable settings and native UI address configuration ownership with few moving parts. It does not promise that future upgrades retain every default, or that macOS cannot affect its fonts and input handling.

### Alacritty: excellent when the session layer already exists

Start with `~/.config/alacritty/alacritty.toml`, subject to the documented discovery order. TOML imports let common settings and machine-specific values stay separate. Alacritty deliberately leaves tabs and splits to a multiplexer or window manager. If you already use tmux, this division is a strength; if you expect an integrated GUI, it introduces another config and keybinding layer. [Configuration](https://alacritty.org/config-alacritty.html), [project FAQ](https://github.com/alacritty/alacritty).

Do not migrate an existing tabs/panes workflow by silently dropping it. Either preserve it through tmux with tested keys or choose an emulator that retains it. A smaller emulator is not a smaller overall setup when it requires a new session manager.

### iTerm2: retain it when the richer workflow matters

iTerm2's GUI, native panes, search, and integration features suit users whose terminal is an interactive workspace. Dynamic Profiles can keep profile definitions as JSON or XML under `~/Library/Application Support/iTerm2/DynamicProfiles`; they do not capture every global preference. Global settings have a separate custom folder/URL facility. Decide which settings each mechanism owns and test restoration rather than assuming one export captures everything. [Dynamic Profiles](https://iterm2.com/documentation-dynamic-profiles.html), [general preferences](https://iterm2.com/documentation-preferences-general.html).

The 3.7.4 changelog explicitly fixes macOS automatic spelling correction, capitalization, smart quotes/dashes, and double-space period insertion changing terminal input. This is a verified example of OS-level interference, not a diagnosis of your incident. It also includes state-save and settings-export fixes. Check the app's installed version before debugging an already fixed issue. [Current release notes](https://iterm2.com/downloads.html).

### kitty: text-driven layouts and extensions

kitty uses `~/.config/kitty/kitty.conf`, with its documented overrides. Tabs, window layouts, and session files provide a broader built-in workflow than Alacritty. Automatic shell integration improves shell-aware behaviour. Its extra capabilities are useful when you need them, but configuration and remote integration should stay deliberate. Test required graphics and keyboard protocols on actual SSH hosts; do not assume every server knows the local terminal's capabilities. [Configuration](https://sw.kovidgoyal.net/kitty/conf/), [layouts and sessions](https://sw.kovidgoyal.net/kitty/overview/), [shell integration](https://sw.kovidgoyal.net/kitty/shell-integration/).

### WezTerm: strongest fit when programming the terminal is a requirement

WezTerm's Lua configuration, built-in tabs/panes, and multiplexing support are useful when the terminal is part of a cross-platform workflow. `~/.wezterm.lua` is a documented starting location; `~/.config/wezterm/wezterm.lua` is another. Lua can encode behaviour that static settings cannot, but increases the amount of configuration code to maintain. [Config locations](https://wezterm.org/config/files.html), [multiplexing](https://wezterm.org/multiplexing.html).

The latest stable release found is from February 2024 even though repository activity continues. Distinguish “active project” from “recent stable build”. Do not rely on a nightly-only feature in a stable installation, and record the channel in your backup. The macOS installation page documents compatibility separately from release recency. [Stable release](https://github.com/wezterm/wezterm/releases/tag/20240203-110809-5046fc22), [macOS installation](https://wezterm.org/install/macos.html).

### Apple Terminal: keep a known recovery route

Apple Terminal has tabs, window groups, and exportable profiles. Its split view is scrollback viewing rather than independent running shells. Keep it available even if another app becomes the default. A second emulator helps distinguish an app setting from shell configuration, provided both launches use the same shell mode. [Apple Terminal guide](https://support.apple.com/guide/terminal/welcome/mac), [profile transfer](https://support.apple.com/guide/terminal/import-and-export-terminal-profiles-trml4299c696/mac).

## Fit evaluation

This is a documentation-based fit judgement, not a latency or crash-rate leaderboard.

| Your requirement | First choice | Why | Decision that would change the choice |
| --- | --- | --- | --- |
| Small text config, native macOS tabs/panes | Ghostty | Few additional workflow layers | A required iTerm2-only integration |
| Existing GUI-heavy terminal workflow | iTerm2 | Preserve proven features and export settings | Preference for a smaller text-first setup |
| tmux already owns sessions and panes | Alacritty | Avoid duplicate session controls | Need local GUI tabs and panes without tmux |
| Cross-platform layouts/extensions | kitty | Config and sessions are explicit | Existing WezTerm Lua workflow |
| Programmable cross-platform multiplexer | WezTerm | Lua and mux capabilities | Requirement for a recently published stable release |
| Lowest installation friction or rescue window | Apple Terminal | Bundled and available | Independent panes or specialised capabilities required |

For this complaint, fix and version the shell configuration first, then trial Ghostty alongside the current app. If the current app is iTerm2 and its features are important, test settings export and the current stable release before migrating. None of these recommendations changes the user's actual system.

## Mechanical repository evidence

Captured with `tools/repo-health-metrics --snapshot 2026-10-10`. Raw tool output follows so disagreements remain visible. Its coloured licence row reflects a library-consumer rubric, not whether an end user can run a terminal. Inapplicable Gleam/target/dependency cells stay unknown; README and idiomaticity judgements were not scored. Open counts are API-reported open items and may include pull requests.
| Criterion | [alacritty/alacritty](https://github.com/alacritty/alacritty) | [ghostty-org/ghostty](https://github.com/ghostty-org/ghostty) | [gnachman/iTerm2](https://github.com/gnachman/iTerm2) | [kovidgoyal/kitty](https://github.com/kovidgoyal/kitty) | [wezterm/wezterm](https://github.com/wezterm/wezterm) |
| --- | --- | --- | --- | --- | --- |
| Stars | 65928★ · 🟩🟩 | 62047★ · 🟩🟩 | 18139★ · 🟩🟩 | 35228★ · 🟩🟩 | 29190★ · 🟩🟩 |
| License | Apache-2.0 · 🟩 | MIT · 🟩 | GPL-2.0 · 🟥 | GPL-3.0 · 🟥 | NOASSERTION · 🟥 |
| Target | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ |
| Deps | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ |
| Gleam compat | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ |
| Open issues | 342 | 268 | 79 | 15 | 1904 |
| Latest release | v0.17.0 | v1.3.1 | vv3.4.0beta13 | v0.49.2 | 20240203-110809-5046fc22 |
| Maintenance | 🟩🟩 (last activity 2026-10-05, 4d before 2026-10-10) | 🟩🟩 (last activity 2026-10-10, 0d before 2026-10-10) | 🟩🟩 (last activity 2026-10-10, 0d before 2026-10-10) | 🟩🟩 (last activity 2026-10-10, 0d before 2026-10-10) | 🟩🟩 (last activity 2026-10-10, 0d before 2026-10-10) |
| Age | 🟩🟩 (~10y, created 2016-02-18) | 🟩🟩 (~4y, created 2022-03-29) | 🟩🟩 (~15y, created 2011-04-07) | 🟩🟩 (~9y, created 2016-10-16) | 🟩🟩 (~8y, created 2018-02-07) |
| README maturity | ⬜ (human judgement — README is 4365 bytes) | ⬜ (human judgement — README is 10501 bytes) | ⬜ (human judgement — README is 8996 bytes) | ⬜ (human judgement — no README fetched) | ⬜ (human judgement — README is 1871 bytes) |
| Idiomaticity | ⬜ (human judgement) | ⬜ (human judgement) | ⬜ (human judgement) | ⬜ (human judgement) | ⬜ (human judgement) |

- **alacritty/alacritty**: no `gleam.toml` reachable — not a Gleam package, or the default branch could not be resolved
- **ghostty-org/ghostty**: no `gleam.toml` reachable — not a Gleam package, or the default branch could not be resolved
- **gnachman/iTerm2**: no `gleam.toml` reachable — not a Gleam package, or the default branch could not be resolved
- **kovidgoyal/kitty**: no `gleam.toml` reachable — not a Gleam package, or the default branch could not be resolved
- **wezterm/wezterm**: no `gleam.toml` reachable — not a Gleam package, or the default branch could not be resolved


### Corrections and limits on the mechanical table

- **iTerm2 release:** the tool returns `vv3.4.0beta13`; the official stable download is 3.7.4. Use the official distribution channel for this application, not the stale GitHub release entry.
- **WezTerm licence:** API detection returns `NOASSERTION` with a negative tool score. The rendered [LICENSE.md](https://github.com/wezterm/wezterm/blob/main/LICENSE.md) establishes MIT for WezTerm itself and separate font licences. The detection failure is not evidence of a restrictive licence.
- **Maintenance:** exact displayed activity dates matter more than rounded relative-day estimates. Recent commits do not establish stable-build recency, specifically for WezTerm.
- **Health:** stars and open-item totals are context. Neither establishes successful restore, accessibility, correct keyboard input, or resistance to macOS regressions.

## Discovery and evidence boundary

Searches included provider-scoped terms for Ghostty config/release/shell integration, Alacritty TOML/tabs/FAQ, iTerm2 stable downloads/Dynamic Profiles/settings, kitty layouts/sessions, WezTerm stable/Lua/macOS, and Apple Terminal profiles/default shell. Official docs, public release pages, and API metadata support the comparison. No terminal was installed or benchmarked on macOS during authoring.

The evaluation follows the actual requirement: recoverable settings with preserved features. Before adopting a recommendation, run the five checks above on the intended Mac and record the result. The recovery article supplies the initial evidence capture.
