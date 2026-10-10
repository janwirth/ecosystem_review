# Recovering a macOS terminal configuration

> [!NOTE]
> **Status:** DRAFT · **Authoring:** AI-assisted; commands require verification on your Mac.

**Snapshot: 2026-10-10.** The reported symptom is that macOS broke a terminal configuration again. The machine, update, shell, and failing setting were not inspected. This guide diagnoses the layer before changing it; it does not assign a cause to that incident.

## Start by separating three layers

| Symptom | Inspect first | What changing terminal apps cannot fix |
| --- | --- | --- |
| Font, colours, key mapping, window restore | Emulator profile or text config | Nothing about the shell's aliases or PATH |
| Missing commands, prompt, aliases, completion | Shell startup and executable paths | The same broken startup file loaded by another emulator |
| Lost remote session or multiplexed panes | SSH connection and tmux state | Server process lifetime or a missing remote binary |

A terminal emulator draws characters and launches a process. zsh or another shell reads startup files. tmux is a separate session manager. Treat the configurations as separate assets. [Terminal default-shell settings](https://support.apple.com/guide/terminal/change-the-default-shell-trml113/mac).

## Five-minute evidence capture

Run the following in the affected window. These commands inspect state; they do not overwrite configuration.

```sh
sw_vers
uname -m
ps -p $$ -o command=
printf 'SHELL=%s\nTERM=%s\nZDOTDIR=%s\n' "$SHELL" "$TERM" "${ZDOTDIR:-unset}"
printf '%s\n' "$PATH" | tr ':' '\n'
command -v zsh
command -v brew
```

`$SHELL` is the account's configured shell, not proof of the currently running process. Compare the process output with Terminal's Settings → General shell choice and the selected profile's startup command. Do not change the account shell before identifying the mismatch. [Apple shell settings](https://support.apple.com/guide/terminal/change-the-default-shell-trml113/mac).

If the running shell is zsh, inspect its mode:

```zsh
print -r -- "login=$options[login] interactive=$options[interactive]"
```

Open a second window before experimenting. Preserve the working window as a recovery route. Save diagnostic output privately; paths and account names can identify your machine.

## Startup files: inspect the right one

| File | Normal zsh startup condition | Appropriate content |
| --- | --- | --- |
| `.zshenv` | Every invocation, subject to zsh startup options | Minimal environment needed by all invocations |
| `.zprofile` | Login shell | Login environment setup |
| `.zshrc` | Interactive shell | Prompt, aliases, completion, interactive bindings |
| `.zlogin` | Login shell, after interactive startup | Late login actions, when required |

Files live under `$ZDOTDIR`, or `$HOME` when unset. Global files precede their user counterparts. A changed `ZDOTDIR` can make intact files appear ignored. Keep terminal output and plugin loading out of `.zshenv`. [Official zsh startup order](https://zsh.sourceforge.io/Doc/Release/Files.html).

A comparison shell can help isolate user startup:

```sh
/bin/zsh -f
```

This starts another shell; type `exit` to return. It skips normal user startup files, but does not undo the inherited environment or skip `/etc/zshenv`. If the prompt problem disappears, inspect startup code rather than replacing the emulator. It is an isolation test, not a repair.

Check syntax in existing files without executing their contents:

```sh
startup_dir=${ZDOTDIR:-$HOME}
for name in .zshenv .zprofile .zshrc .zlogin; do
  if [ -f "$startup_dir/$name" ]; then
    /bin/zsh -n "$startup_dir/$name" || break
  fi
done
```

A successful syntax check does not prove plugin paths, side effects, or runtime commands are correct. Inspect the actual error and change one responsible line at a time. Avoid verbose shell tracing in shared logs: startup files can contain secrets.

## Homebrew paths: architecture matters

Homebrew documents `/opt/homebrew` for Apple Silicon and `/usr/local` for Intel macOS. Its installer provides the shell setup command for the actual installation. An update, migration, or Rosetta launch can expose an old path assumption; that is a hypothesis to test, not the established cause here. [Installation documentation](https://docs.brew.sh/Installation).

Use the absolute `brew` path that exists on your machine. The documented login-shell setup belongs in `.zprofile` for zsh on macOS. For an Apple Silicon installation at the default prefix, the line is:

```sh
eval "$(/opt/homebrew/bin/brew shellenv)"
```

Do not append this repeatedly or copy it to every startup file. Inspect the existing file first, back it up, and edit the single intended setup location. An Intel installation needs its own real path. GUI-launched and nested shells can inherit different environments; test a fresh login window and a fresh interactive subshell after the change. [Homebrew shellenv manual](https://docs.brew.sh/Manpage).

## Back up before editing

Export Apple Terminal profiles through Settings → Profiles → action menu → Export. Keep the `.terminal` file with your configuration backup. It captures the profile; it does not contain shell dotfiles. Importing the profile and restoring startup files are separate operations. [Apple profile export/import](https://support.apple.com/guide/terminal/import-and-export-terminal-profiles-trml4299c696/mac).

For a startup-file backup, use a new directory and copy only files that exist:

```sh
startup_dir=${ZDOTDIR:-$HOME}
backup_dir="$HOME/terminal-backup-$(date +%Y%m%d-%H%M%S)-$$"
mkdir "$backup_dir" || exit 1
for name in .zshenv .zprofile .zshrc .zlogin; do
  if [ -f "$startup_dir/$name" ]; then
    cp -p "$startup_dir/$name" "$backup_dir/" || exit 1
  fi
done
printf 'Backup: %s\n' "$backup_dir"
```

Backups can contain tokens. Keep them private. For long-term version control, extract secrets first and commit only reviewed configuration. Do not reset preference domains or delete dotfiles as an exploratory fix.

## Make the next incident cheap to recover

Keep one canonical copy of emulator settings and shell configuration in a private dotfiles repository. Record expected file paths, terminal version, macOS version, architecture, fonts, and installed plugins. Track machine-specific paths deliberately instead of assuming the same prefix everywhere. A simple symlink or copied config is enough; no dotfile framework is required.

After an update, compare this evidence with the previous known-good record. Test a new window, a nested shell, and SSH to a representative server. Check command lookup, prompt, completion, Unicode, keybindings, and remote terminfo separately. Keep Apple Terminal available as a fallback even when another emulator becomes the default.

This repository's Linux authoring environment cannot reproduce a macOS update or validate your actual startup files. The guide's commands were reviewed for quoting and non-destructive intent; machine-specific execution remains a user-side check.

## Related and discovery

[Choosing a macOS terminal](macos-terminals.md) compares emulator trade-offs. [Browser SSH terminals](browser-ssh-terminals.md) covers hosted browser access, which is a different deployment choice.

Discovery used provider-scoped searches for Apple default-shell settings and profile export, zsh startup order, Homebrew shellenv, and current Ghostty/Alacritty config locations. Prefer the installed program's help and matching-version docs over an old copied dotfile.
