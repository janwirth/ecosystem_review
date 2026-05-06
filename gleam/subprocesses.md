# Tools for spawning subprocesses with Gleam

> [!NOTE]
> **Status:** DRAFT · **Authoring:** AI-assisted, human-reviewed.

Need to shell out from Gleam? Run `tailwindcss -w`, pipe into `cat`, or just capture `ls`?
This is the shortlist.

## Table of Contents

1. [Summary](#summary)
2. [Research Method](#research-method)
   - [Scoring Dimensions](#scoring-dimensions)
   - [Discovery](#discovery)
3. [Categories](#categories)
   - [Command Execution](#command-execution) — [shellout](#shellout)
   - [Interactive / Streaming Processes](#interactive--streaming-processes) — [child_process](#child_process) · [sceall](#sceall)
4. [Leaderboard](#leaderboard)

## Summary

Snapshot: **2026-04-23**.

Gleam has three live options for spawning OS processes. They carve up the space by ambition: one-shot command execution vs. long-lived interactive processes with stdin/stdout streaming.

| Category | ☎️ BEAM | 📜 JS |
| --- | --- | --- |
| **[Command Execution](#command-execution)** | · [🥇](#leaderboard) [shellout](#shellout) ([repo](https://github.com/tynanbe/shellout), 74★) — *one-shot `command()`, args, exit codes, terminal styling* | · [🥇](#leaderboard) [shellout](#shellout) — *also targets JS* |
| **[Interactive / Streaming Processes](#interactive--streaming-processes)** | · [🥈](#leaderboard) [child_process](#child_process) ([repo](https://gitlab.com/arkandos/child_process), GitLab) — *builder; sync/async/shell; stdin streams, kill, PID*<br>· [🥉](#leaderboard) [sceall](#sceall) ([repo](https://github.com/lpil/sceall), 15★) — *BEAM ports, message-driven stdio* | · [🥈](#leaderboard) [child_process](#child_process) — *also targets Node.js* |

> [!IMPORTANT]
> `child_process` is the only library with full process control (stdin streams + kill + PID) on **both** BEAM and Node.js. `sceall` is BEAM-only. `shellout` is one-shot only.

> <details>
> <summary><strong>Dependency Graph</strong></summary>
>
> Arrows read "uses."
>
> - [shellout](#shellout) → `gleam_stdlib` — no further runtime deps
> - [child_process](#child_process) → `gleam_erlang` + `gleam_otp` + `splitter` (BEAM); uses Node.js `child_process` FFI on JS
> - [sceall](#sceall) → `gleam_erlang` — BEAM ports only
>
> None of these depend on the HTTP / web stack — they sit parallel to it.
>
> </details>

## Research Method

Methodology matches [web-apps.md](./web-and-http/web-apps.md). Same scoring dimensions, same snapshot-date discipline.

### Scoring Dimensions

- **Stars:** Community adoption signal. 🟩🟩 = ≥200★, 🟩 = ≥100★, 🟨 = ≥10★, 🟥 = <10★. GitLab-hosted repos have no comparable star culture; hex download count is used as a rough proxy (<1k all-time → 🟥).
- **License:** 🟩 = permissive OSS (MIT, Apache-2.0, BSD). 🟥 = viral (GPL, AGPL) or no license.
- **Gleam compat:** `gleam_stdlib` version constraint in `gleam.toml`. 🟩 = range constraint (`>= X and < Y`), 🟥 = non-range (`~>` style).
- **Maintenance:** `max(recency, responsiveness)`. Recency: 🟩🟩 <1 mo, 🟩 <6 mo, 🟨 <1 yr, 🟥 >1 yr. Responsiveness: 🟩🟩 <2 days, 🟩 <1 week, 🟨 <1 mo, 🟥 ignored.
- **Age:** First commit → snapshot. 🟩🟩 ≥3 yr, 🟩 ≥1 yr, 🟨 ≥3 mo, 🟥 <3 mo.
- **README maturity:** 🟩🟩 guide-style + examples + feature docs, 🟩 clear description + basic usage, 🟥 minimal or broken.
- **Idiomaticity:** 🟩 = typed, explicit, no magic. 🟥 = magic directives / implicit wiring.

**Leaderboard scoring:** 🟥 = −1, 🟨 = 0, 🟩 = 1, 🟩🟩 = 2. Max = 13.

### Discovery

Searches on [Gleam packages registry](https://packages.gleam.run/) — terms: `subprocess`, `spawn`, `process`, `shell`.

4 relevant repos found — **3 included**, **1 disregarded**.

- [subprocess](https://packages.gleam.run/?search=subprocess) — no matches
- [spawn](https://packages.gleam.run/?search=spawn)
- [process](https://packages.gleam.run/?search=process)
- [shell](https://packages.gleam.run/?search=shell)

> <details>
> <summary>1 disregarded — unmaintained</summary>
>
> - **[darky/gleamyshell](https://github.com/darky/gleamyshell)** — Cross-platform sync shell runner (Erlang/Deno/Node). Last commit 2024-05-29. Maintainer notice 2024-08-11: "no longer investing time in Gleam." ~2 years dormant at snapshot. Maintenance 🟥.
>
> Also surfaced but out of scope: `working_actors` (spawns BEAM actors, not OS processes); `process_waiter`, `group_registry`, `processgroups` (BEAM process primitives, not subprocesses); `bg_jobs` (in-process job queue).
>
> </details>


## Categories

### Command Execution

Run a command, wait, get output. No stdin streaming, no long-lived handle.

| Criterion | [shellout](https://github.com/tynanbe/shellout) [🥇](#leaderboard) |
| --- | --- |
| Stars | 74★ · 🟨 |
| License | Apache-2.0 · 🟩 |
| Target | ☎️📜 Both (BEAM + JS) |
| Deps | 1 (`gleam_stdlib`) |
| Gleam compat | `>= 0.47 and < 2.0` · 🟩 |
| Maintenance | 🟩 (last commit 2026-02-19, ~2 mo) |
| Age | ~3.9 years (Jun 2022) · 🟩🟩 |
| README maturity | 🟩 (tagline + runnable examples) |
| Idiomaticity | 🟩 (`command()` / `arguments()`) |
| | |
| **Features** | |
| Sync exec | ✅ `command()` |
| Args builder | ✅ `arguments()` |
| Exit codes | ✅ `Result(String, #(Int, String))` |
| stdin streaming | — |
| stdout streaming | — (captured only) |
| Kill / PID / is_running | — |
| Env vars | ✅ (via `LetBeStderr` etc. opts) |
| cwd | ✅ (`in:` arg) |
| Shell string | ✅ |
| Bundled extras | Terminal styling (colors, bg, display) |

#### shellout
[repo](https://github.com/tynanbe/shellout) · [🥇](#leaderboard)

"A Gleam library for cross-platform shell operations." Oldest + most-starred option. Runs a command, captures output, returns exit code. Dual-target (BEAM + JS). Zero runtime deps beyond stdlib. Also bundles terminal styling helpers — mild scope creep, but useful if you're building a CLI.

Use when: you want `exec` semantics — one-shot, capture output, done. No interactive process needed.

```gleam
import shellout

pub fn main() {
  let result =
    shellout.command(
      run: "ls",
      with: ["-lah"],
      in: ".",
      opt: [],
    )
  case result {
    Ok(output) -> io.println(output)
    Error(#(code, msg)) -> io.println_error(msg)
  }
}
```


### Interactive / Streaming Processes

Long-lived subprocess. Write to stdin, read stdout line-by-line, kill when done. Think `tailwindcss -w`, `ffmpeg`, REPL wrappers.

| Criterion | [child_process](https://gitlab.com/arkandos/child_process) [🥈](#leaderboard) | [sceall](https://github.com/lpil/sceall) [🥉](#leaderboard) |
| --- | --- | --- |
| Stars | N/A (GitLab) · 898 hex dl · 🟥 | 15★ · 🟨 |
| License | BSD-3-Clause · 🟩 | Apache-2.0 · 🟩 |
| Target | ☎️📜 Both (BEAM + Node.js) | ☎️ BEAM (uses BEAM ports) |
| Deps | 4 (stdlib, splitter, gleam_erlang, gleam_otp) | 2 (stdlib, gleam_erlang) |
| Gleam compat | `>= 0.44 and < 2.0` · 🟩 | `>= 0.44 and < 2.0` · 🟩 |
| Maintenance | 🟩🟩 (last commit 2026-04-10, 8 days) | 🟩🟩 (last commit 2026-01-29, clean tracker) |
| Age | ~4.5 months (Dec 2025) · 🟨 | ~2.6 months (Jan 2026) · 🟥 |
| README maturity | 🟩🟩 (builder guide, multiple examples, sync/async/stream patterns) | 🟩 (clear `cat` example, API surface documented) |
| Idiomaticity | 🟩 (builder pattern, explicit APIs) | 🟩 (spawn/send/select, BEAM-native idiom) |
| | | |
| **Features** | | |
| Sync exec | ✅ `run()` / `exec()` | — |
| Async spawn | ✅ `spawn()` (with stdio handler), `spawn_raw()` | ✅ `spawn_program()` |
| stdin write | ✅ `write()` / `writeln()` / `write_bits()` / `close()` | ✅ `send()` |
| stdout streaming | ✅ line callbacks + `stdio.capture()` / `stdio.lines()` | ✅ BEAM message selector (`select()`) |
| stderr | ✅ | ✅ (merged into port messages) |
| Kill (SIGTERM / SIGKILL) | ✅ `stop()` + `kill()` | ✅ `exit_program()` |
| Env vars | ✅ `env()` / `envs()` | ✅ (spawn arg) |
| cwd | ✅ `cwd()` | ✅ (spawn arg) |
| Shell string | ✅ `shell()` | — |
| PID / is_running | ✅ `os_process_id()` / `is_running()` | — |
| Utilities | `find_executable()`, `open()`, `reveal()` | — |

#### child_process
[repo](https://gitlab.com/arkandos/child_process) · [🥈](#leaderboard)

"A Gleam library for spawning OS processes." Builder-pattern API, dual-target (BEAM + Node.js), the most feature-complete of the three. Three execution modes: `run()` (sync, capture), `spawn()` (async, stdio handler), `shell()` (shell string). Full process control: write to stdin, close stdin, SIGTERM via `stop()`, SIGKILL via `kill()`, query PID, check `is_running()`.

GitLab-hosted, which hurts the star signal — hex tells a clearer story: 898 all-time downloads, 32 last-7-days, active release cadence (9 tags in ~4 months). Young but moving fast.

Use when: you need a long-lived subprocess with stdio, and you want the same API on BEAM and Node.

```gleam
import child_process

pub fn main() {
  let assert Ok(process) =
    child_process.from_name("tailwindcss")
    |> child_process.args(["-w", "-i", "in.css", "-o", "out.css"])
    |> child_process.cwd("./frontend")
    |> child_process.spawn(fn(line) { io.println(line) })

  // Later: child_process.stop(process)
}
```

#### sceall
[repo](https://github.com/lpil/sceall) · [🥉](#leaderboard)

"Spawn shell programs and stream their stdio using BEAM ports!" Tiny, BEAM-only, message-driven. `spawn_program()` returns a handle; stdout / stderr / exit arrive as BEAM messages via a `Selector`; `send()` writes to stdin; `exit_program()` terminates.

Natural fit if you're already using `gleam/erlang/process` selectors and want the subprocess's output in the same receive loop as your actor messages. Very young (2.6 months), 15 stars, 7 commits — lpil-authored (wisp, http), which explains the idiom alignment. "Sceall" = shell in Irish.

Use when: BEAM target only, and you want port-style message-driven I/O rather than callbacks.

```gleam
import sceall

pub fn main() {
  let assert Ok(prog) =
    sceall.spawn_program(
      path: "/bin/cat",
      cwd: ".",
      args: [],
      env: [],
    )

  sceall.send(prog, "hello\n")

  let selector = sceall.select(prog)
  // receive sceall.Data(bytes) / sceall.Exit(code) via selector

  sceall.exit_program(prog)
}
```


## Leaderboard

Small field, so the podium is the leaderboard.

**🥇 Gold**
- **shellout** ([tynanbe](https://github.com/tynanbe)) — The old guard. 3.9 years of stable one-shot `command()`, dual-target, zero non-stdlib deps. Doesn't do interactive processes — doesn't try to. Wins on age + simplicity.

**🥈 Silver**
- **child_process** ([arkandos](https://gitlab.com/arkandos)) — The feature leader. Full process control on both BEAM and Node.js, builder pattern, active releases. Penalised by youth (4.5 months) and low adoption signal (GitLab, 898 hex dl). Most likely to top this list in a year.

**🥉 Bronze**
- **sceall** ([lpil](https://github.com/lpil)) — The BEAM idiom. Tiny surface, message-driven, native BEAM port ergonomics. Too young and too BEAM-specific to rank higher, but the right choice inside an OTP application.

| Position | Award | Repo | ★ | Lic | Compat | Maint | Age | README | Idiom | Score |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 🥇 | [tynanbe/shellout](https://github.com/tynanbe/shellout) | 🟨 | 🟩 | 🟩 | 🟩 | 🟩🟩 | 🟩 | 🟩 | **7** |
| 2 | 🥈 | [arkandos/child_process](https://gitlab.com/arkandos/child_process) | 🟥 | 🟩 | 🟩 | 🟩🟩 | 🟨 | 🟩🟩 | 🟩 | **6** |
| 3 | 🥉 | [lpil/sceall](https://github.com/lpil/sceall) | 🟨 | 🟩 | 🟩 | 🟩🟩 | 🟥 | 🟩 | 🟩 | **5** |

**By target:** ☎️ BEAM **18** (3 repos) · 📜 JS **13** (2 repos). `shellout` and `child_process` count toward both.

[How scores are calculated →](#scoring-dimensions)
