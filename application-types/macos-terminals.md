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

Record macOS version, hardware, emulator version, configuration, and test outcome. No performance ranking is claimed without that record. The next comparison section evaluates Alacritty, Ghostty, and alternatives from current primary sources.
