# macOS terminals: minimal upkeep for SSH development

**Snapshot: 2026-10-12. Documentary research; no local macOS or VPS tests.**

**Try iTerm2 first. Try Ghostty second if you prefer a small text configuration.** You use zsh on reported macOS Tahoe 26.5.2 and SSH into a development VPS. The useful decision is which terminal needs the least attention, not which has the longest feature list.

iTerm2 offers settings through a GUI, a full settings backup, and ordinary shell sessions without requiring its optional SSH integration. Its current recommended stable download is **3.7.4, built 2026-10-08**, for macOS 13+. The release notes include macOS 26 fixes. This establishes active compatibility work, **not immunity to future macOS updates**. [Download and release notes](https://iterm2.com/downloads.html), [profile settings](https://iterm2.com/documentation-preferences-profiles-general.html), [settings export](https://iterm2.com/documentation-preferences-general.html).

## What switching can and cannot fix

A terminal draws the window and launches a shell. zsh loads shell configuration; SSH connects to the remote machine. Replacing Apple Terminal changes the first layer. It does not repair broken shell files, PATH changes, SSH configuration, or operating-system permissions.

zsh reads `.zprofile` for login shells and `.zshrc` for interactive shells, under `$ZDOTDIR` or the home directory. A different shell launch mode can therefore make the same configuration behave differently. The original failure remains undiagnosed: an update preceded it, but that alone does not establish which layer broke. [zsh's own startup-file documentation](https://github.com/zsh-users/zsh/blob/master/Doc/Zsh/files.yo).

## Ranked fit for your use

This is a **judgment about documented setup burden**, not measured reliability. Minimal upkeep receives **100%** of the decision weight because that is your stated priority; splits, scripting, AI and managed SSH receive no bonus. Scale follows the repository convention: **2 = strong fit, 1 = usable with a relevant tradeoff, 0 = no compelling fit advantage for this use, unknown = insufficient evidence**. Total = upkeep fit × 1.00. Ties remain ties; the first-trial choice within a tie is explained below. Actual reliability on **26.5.2 is unknown for every option**.

| Rank | Terminal | Upkeep fit / total | Evidence and tradeoff |
| --- | --- | ---: | --- |
| 1= | **iTerm2** | 2 / 2 | GUI profiles and full export/import; use a login shell and normal `ssh`. Optional SSH integration is beta and unnecessary here. [Profiles](https://iterm2.com/documentation-preferences-profiles-general.html), [backup](https://iterm2.com/documentation-preferences-general.html). |
| 1= | **Ghostty** | 2 / 2 | Defaults need no configuration; small key/value file. Remote `xterm-ghostty` terminfo may need attention. [Configuration](https://ghostty.org/docs/config), [remote compatibility](https://ghostty.org/docs/help/terminfo). |
| 3= | **Alacritty** | 1 / 1 | Sensible defaults and TOML configuration; customization is a file-editing task. Project still labels itself beta. Useful if its focused terminal feature set is enough. [Project](https://alacritty.org/), [configuration](https://alacritty.org/config-alacritty.html). |
| 3= | **kitty** | 1 / 1 | Text configuration; its SSH helper can handle remote terminfo but adds a helper workflow. Good when you want its richer terminal functions. [Configuration](https://sw.kovidgoyal.net/kitty/conf/), [SSH helper](https://sw.kovidgoyal.net/kitty/kittens/ssh/). |
| 3= | **Rio** | 1 / 1 | Defaults work without a file; customization uses `~/.config/rio/config.toml`. A reasonable additional trial, with no evidence here that it needs less maintenance than the leading pair. [Configuration](https://rioterm.com/docs/config). |
| 3= | **Tabby** | 1 / 1 | Integrated SSH connection manager, jump hosts and forwarding are useful for many connections; you already use ordinary SSH, so these do not earn a bonus. [Feature list](https://github.com/Eugeny/tabby). |
| 3= | **Warp** | 1 / 1 | Login is now optional, and local operation is supported after the first online launch. Its AI/collaboration workflow supplies no stated benefit for this decision. [Current setup documentation](https://docs.warp.dev/getting-started/quickstart/installation-and-setup). |
| 8= | **WezTerm** | 0 / 0 | Lua configuration and multiplexing are powerful. Current API latest-release metadata still names the February 2024 stable tag, despite recent repository activity; release-channel choice adds a question you do not need. [Configuration](https://wezterm.org/config/files.html), [release](https://github.com/wezterm/wezterm/releases/tag/20240203-110809-5046fc22). |
| 8= | **Hyper** | 0 / 0 | Web-technology terminal with an extension-oriented ecosystem. Choose it for those customization goals; there is no documented advantage for your minimal-upkeep SSH use. [Project](https://github.com/vercel/hyper). |

**Why iTerm2 gets the first trial:** its GUI and complete export/import match the complaint about configuration recovery. Ghostty ties on broad fit because you can leave it unconfigured; it moves ahead if you prefer a short, inspectable text file. That tie cannot be resolved with stars or anecdotes.

If your priority changes to programmable layouts and cross-platform configuration, WezTerm and kitty become more relevant. If managing many SSH connections becomes the problem, Tabby becomes more relevant. Apple Terminal remains the zero-install baseline, but you have explicitly asked for alternatives after a failure. Browser SSH services and standalone session managers are outside this local-terminal decision; [browser SSH terminals](browser-ssh-terminals.md) covers that separate category.

## The SSH detail that matters

**Ghostty:** its default `TERM` is `xterm-ghostty`. Older remote terminfo databases may not recognize it. The project documents copying the entry or using a host-specific compatibility setting, with reduced advanced-feature support. This is a potential setup cost, not a claim that SSH itself fails. [Terminfo guidance](https://ghostty.org/docs/help/terminfo).

Do not confuse documentation for future releases with today's stable app. **`ghostty +ssh` requires a tip build or future 1.4.0; it is absent from 1.3.x.** Stable 1.3.x has optional `ssh-env` and `ssh-terminfo` shell-integration wrappers, disabled by default. [Version-specific SSH documentation](https://ghostty.org/docs/features/ssh), [stable download](https://ghostty.org/download).

**iTerm2:** its beta SSH integration is optional and requires remote Python 3. Your workflow can remain a normal shell running `ssh`; there is no reason to introduce this integration for the trial. [Profile settings](https://iterm2.com/documentation-preferences-profiles-general.html).

**kitty:** its SSH kitten handles terminal setup and can copy configuration to the remote host. That is useful, but it is a different workflow from doing nothing beyond ordinary SSH. [SSH kitten documentation](https://sw.kovidgoyal.net/kitty/kittens/ssh/).

## Configuration recovery

For iTerm2, use **Export/Import All Settings and Data** after a trial succeeds. That backup includes app settings and its support data; it is not a backup of all your zsh or SSH files. [Backup scope](https://iterm2.com/documentation-preferences-general.html).

For Ghostty, keep one configuration location. It reads both XDG and macOS Application Support locations, with later settings overriding earlier ones. The current filename is `config.ghostty`; `config` is also supported for older setups. Duplicate files can make changes appear ineffective. [Configuration search and precedence](https://ghostty.org/docs/config).

Do not replace shell files during a terminal comparison. Otherwise you cannot tell whether the app or the shell change improved the result.

## A bounded trial: 15 minutes per candidate

1. Open the official stable app with defaults. Keep Apple Terminal available.
2. Connect to the same VPS with your existing `ssh` command. Check your normal editor, copy/paste, scrolling and resize behavior.
3. If a remote program reports an unknown terminal, inspect `printf '%s\n' "$TERM"` and `infocmp "$TERM"` on that remote shell. Check the candidate's terminfo instructions before changing anything.
4. Quit and reopen the app; reconnect. Include one sleep/wake cycle during normal use before choosing.
5. Keep the candidate only if normal work succeeds without additional setup you dislike. Back up its settings afterward.

This is a proposed trial, **not an executed test**. Fifteen minutes can reject an inconvenient setup; it cannot establish long-term reliability. If both apps reproduce the original shell problem, investigate the shared shell/SSH/OS layer rather than installing a third terminal.

<details>
<summary>Evidence, repository metrics and research trail</summary>

### Repository health is supporting context

Required project tooling ran on 2026-10-12:

```sh
cd tools/repo-health-metrics
gleam run -- ghostty-org/ghostty gnachman/iTerm2 alacritty/alacritty wezterm/wezterm kovidgoyal/kitty raphamorim/rio Eugeny/tabby vercel/hyper --snapshot 2026-10-12 --json
```

The run's output was captured at `/tmp/empress-terminal-repo-health-2026-10-12.json`; its unchanged review artifact is [repo-health-2026-10-12.json](assets/macos-terminals/repo-health-2026-10-12.json). These are API observations, not performance tests. Warp received documentary coverage; no repository-health run was made for Warp.

| Repository | Stars | API license | API pushed date | Open issues | API latest release |
| --- | ---: | --- | --- | ---: | --- |
| [Ghostty](https://github.com/ghostty-org/ghostty) | 62,100 | MIT | 2026-10-12 | 256 | v1.3.1 |
| [iTerm2](https://github.com/gnachman/iTerm2) | 18,144 | GPL-2.0 | 2026-10-12 | 78 | vv3.4.0beta13; **not current stable download** |
| [Alacritty](https://github.com/alacritty/alacritty) | 65,939 | Apache-2.0 | 2026-10-05 | 342 | v0.17.0 |
| [WezTerm](https://github.com/wezterm/wezterm) | 29,202 | NOASSERTION | 2026-10-12 | 1,908 | 20240203-110809-5046fc22 |
| [kitty](https://github.com/kovidgoyal/kitty) | 35,244 | GPL-3.0 | 2026-10-12 | 14 | v0.49.2 |
| [Rio](https://github.com/raphamorim/rio) | 7,602 | MIT | 2026-10-11 | 328 | v0.5.28 |
| [Tabby](https://github.com/Eugeny/tabby) | 74,934 | MIT | 2026-10-12 | 2,830 | v1.0.238 |
| [Hyper](https://github.com/vercel/hyper) | 44,738 | MIT | 2026-08-21 | 1,049 | v3.4.1 |

Raw tool grades remain in the JSON for audit. No repository-health total is used to select an installed terminal: Gleam compatibility and idiomaticity do not apply, copyleft is not a disadvantage for this app-use decision, and `NOASSERTION` is unknown rather than evidence of a bad license. `pushed_at` is repository push activity, not a verified newest-commit timestamp. The tool's GPL and unknown-license penalties are not carried into the fit table.

The rendered project pages and linked documentation were inspected for setup information. Code idiomaticity and commit volume were not evaluated; README byte length is not a maturity score. This limits the repository review and prevents a misleading full rubric total. The decision table instead makes its single user-selected criterion explicit.

### Conflicting evidence and limitations

- **iTerm2:** official downloads supersede stale GitHub release metadata. A user reports SSH local-network failures on Tahoe 26.1 after updates/network changes. This is one report, not a failure rate or evidence about 26.5.2. [User discussion](https://groups.google.com/g/iterm2-discuss/c/WvSl-O16yP8).
- **Ghostty:** a 1.3.1/Tahoe 26.0 freeze report was closed because non-maintainers must start in Discussions; closure does **not** prove a fix. This policy also makes raw issue counts incomparable across projects. [Issue and bot response](https://github.com/ghostty-org/ghostty/issues/12629).
- **WezTerm:** issue #7051 starts with Tahoe **26.0 beta**, June 2025, and reports freezing with the 20240203 stable build. Later comments include other builds. This is not a controlled current-version comparison. [Issue](https://github.com/wezterm/wezterm/issues/7051).
- A third-party 2026 comparison asserts “minimal code means minimal bugs” and calls Alacritty a performance benchmark. No reproducible macOS experiment was established from that page; those statements do not support a reliability ranking. [Luminoid comparison](https://blog.luminoid.dev/Terminal-Emulator-Comparison-2026/).

Vendor documentation establishes features and setup paths; issue reports are first-hand accounts with uncontrolled environments. The fit scores are this article's judgments. Latency, memory use, crash rate, recovery after OS updates and compatibility with the actual VPS remain **unmeasured**. macOS 26.5.2 is user-reported; this article does not certify it as Apple's latest release.

### Discovery and verification trail

All discovery and source opens occurred on **2026-10-12**. Queries included:

- `macOS terminal alternatives Ghostty iTerm2 Alacritty WezTerm Kitty Rio 2026 comparison reliability`
- `macOS update Terminal zsh configuration login shell zprofile zshrc Apple Terminal`
- `site.ghostty.org docs ssh terminfo remote unknown terminal`
- `site.github.com ghostty-org ghostty macOS Tahoe 26 crash 2026`
- `site.iterm2.com FAQ settings export import tmux SSH`
- `site.sw.kovidgoyal.net kitty ssh kitten terminfo macOS`
- `site.docs.warp.dev login optional local mode privacy telemetry`
- `site.wezterm.org config files reload errors stable release 2024`
- `iTerm2 Tahoe 26 SSH bug settings crash 2026`
- `Alacritty macOS Tahoe 26 issues tabs splits FAQ`
- `WezTerm macOS Tahoe stable 20240203 nightly issues`

Follow-ups checked current distribution versions, remote terminal compatibility, backup scope and conflicting issue reports. Opened evidence is linked beside the relevant claims. Search snippets were not treated as verification. Direct zsh manual hosts and older kitty URL forms failed; the zsh source documentation and current trailing-slash kitty documentation were opened instead. No paid services, generated examples, or installations were used.

Verification checked all eight copied metric rows, all nine score totals, local links and whitespace. A direct HTTP check covered 28 distinct cited URLs: 25 returned 200, while two iTerm2 documentation pages and the Luminoid page timed out in that client. All three were independently accessible through the research browser; a timeout is not a broken-link finding.

</details>
