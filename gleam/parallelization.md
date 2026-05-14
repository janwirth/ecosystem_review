# Parallelization in Gleam

> [!NOTE]
> **Status:** DRAFT · **Authoring:** AI-assisted, human-reviewed.

So you've got work to do faster: a list of HTTP requests that should fan out, a directory tree to scan, a CPU-bound transform that should use every core, a queue of background jobs that should retry on failure, or a flood of UI events you'd like to coalesce. This article is about the Gleam packages — and the BEAM patterns underneath them — for doing that **on a single node, in a single process tree**.

> [!IMPORTANT]
> **Before reaching for any of these packages, find your bottleneck.**
>
> Concurrency primitives are not a speedup — they're a tool for *overlapping I/O* or *spreading CPU across cores*. Adding actors or pools to code that's bottlenecked on a slow database query, an N+1, a synchronous external call, or an algorithm with the wrong big-O **will not make it faster**, and may make it slower (scheduler thrashing, mailbox backlogs, observability holes).
>
> Measure first. The Gleam-native tooling for this is covered in [Bottleneck identification](#bottleneck-identification--observability) — start there. The short version:
>
> 1. Wrap the suspect with `:timer.tc/1` for a quick wall-clock check.
> 2. If you want statistical noise rejection, use [`glychee`](#glychee) (Benchee) or [`gleamy_bench`](#gleamy_bench).
> 3. To inspect a running system — mailboxes, ETS sizes, scheduler load — open [`spectator`](#spectator).
> 4. Only then decide *what* to parallelize and *how much* to bound it.

> [!CAUTION]
> **This article does not cover scaling across multiple BEAM nodes.** Distributed Erlang, `:rpc`, `libcluster`, `Horde`, `glyn`'s clustering surface, Kubernetes-level horizontal scaling — all out of scope. The author is a single-node practitioner and would only confuse you about clustering. See [Non-goals](#non-goals).

> [!TIP]
> **Quick recipes — copy-paste starting points for the six most common jobs.**
>
> **1. Run N things in parallel, bounded by CPU count** → [`parallel_map`](#parallel_map).
>
> ```gleam
> import parallel_map
>
> pub fn main() {
>   let urls = ["https://a", "https://b", "https://c"]
>   let results =
>     parallel_map.list_pmap(
>       urls,
>       fetch,
>       parallel_map.MatchSchedulersOnline,
>       1000,
>     )
> }
> ```
>
> **2. Pool of reusable resources** (DB conns, file handles, ports) → [`bath`](#bath).
>
> ```gleam
> import bath
>
> let pool = bath.new(fn() { open_connection() })
>   |> bath.with_size(10)
>   |> bath.start
>
> use conn <- bath.apply(pool, timeout: 1000)
> query(conn, "select 1")
> ```
>
> **3. Pool of stateful workers** (actor per worker) → [`lifeguard`](#lifeguard).
>
> ```gleam
> import lifeguard
>
> let pool = lifeguard.new(parse_worker_spec)
>   |> lifeguard.with_size(8)
>   |> lifeguard.start
>
> lifeguard.send(pool, ParseLine("foo,bar,baz"))
> ```
>
> **4. Background job queue** (durable, with retries + scheduling) → [`m25`](#m25).
>
> ```gleam
> import m25
>
> m25.enqueue(queue, EmailJob(to: "user@example.com"), max_retries: 3)
> ```
>
> **5. Rate-limit incoming requests** (token bucket) → [`glimit`](#glimit).
>
> ```gleam
> import glimit
>
> let limiter = glimit.new()
>   |> glimit.per_second(100)
>   |> glimit.with_key(fn(req) { req.ip })
>   |> glimit.build
>
> case glimit.check(limiter, req) {
>   Ok(_) -> handle(req)
>   Error(_) -> reply_429()
> }
> ```
>
> **6. Debounce a flood of UI events** (Lustre 5.x) → [`lustre/event.debounce`](#debouncing--throttling).
>
> ```gleam
> import lustre/event
>
> // Fire `OnInput(value)` once the user stops typing for 300 ms (trailing edge).
> event.on_input(OnInput) |> event.debounce(300)
> ```

## Table of Contents

1. [Bottleneck identification](#bottleneck-identification--observability) — the part you should read first
2. [Recursive directory anecdote](#recursive-directory-anecdote--why-unbounded-taskasync-blows-up) — a foot-gun told as a story
3. [Summary](#summary)
4. [State of the ecosystem](#state-of-the-ecosystem)
5. [Non-goals](#non-goals)
6. [Research method](#research-method)
   - [Scoring dimensions](#scoring-dimensions)
   - [Discovery](#discovery)
7. [Disregarded](#disregarded)
8. [When to use what](#when-to-use-what)
9. [Categories](#categories)
   - [Bottleneck identification / observability](#bottleneck-identification--observability) — [`spectator`](#spectator) · [`glychee`](#glychee) · [`gleamy_bench`](#gleamy_bench) · [`viva_telemetry`](#viva_telemetry)
   - [Concurrency primitives](#concurrency-primitives) — [`gleam_otp`](#gleam_otp) · [`glixir`](#glixir) · [`glyn`](#glyn) · [`reki`](#reki) · [`singularity`](#singularity) · [`processgroups`](#processgroups) · [`cell`](#cell) · [`eparch`](#eparch) · [`glubsub`](#glubsub)
   - [Parallel-map / task abstractions](#parallel-map--task-abstractions) — [`parallel_map`](#parallel_map) · [`taskle`](#taskle) · [`working_actors`](#working_actors) · [`future`](#future)
   - [Resource pools / actor pools](#resource-pools--actor-pools) — [`bath`](#bath) · [`lifeguard`](#lifeguard) · [`crew`](#crew)
   - [Background job queues](#background-job-queues) — [`m25`](#m25) · [`bg_jobs`](#bg_jobs)
   - [Rate limiting](#rate-limiting) — [`glimit`](#glimit) · [`speedbump`](#speedbump) · [`crabbucket_pgo`](#crabbucket_pgo) · [`crabbucket_redis`](#crabbucket_redis) · [`ezconfig`](#ezconfig)
   - [Debouncing & throttling](#debouncing--throttling) — Lustre core · [`lustre_limiter`](#lustre_limiter) · the non-Lustre gap
   - [Scheduling](#scheduling) — [`clockwork`](#clockwork) · [`clockwork_schedule`](#clockwork_schedule)
   - [Circuit breakers (adjacent)](#circuit-breakers-adjacent) — [`circuit_breaker`](#circuit_breaker) · [`circuit`](#circuit)
10. [What's missing](#whats-missing)
11. [Comparison matrix](#comparison-matrix)
12. [Per-category leaderboards](#per-category-leaderboards)

## Summary

Snapshot: **2026-05-13**.

| You need to… | Pick | Notes |
| --- | --- | --- |
| **Run N things in parallel, bounded** | [`parallel_map`](#parallel_map) | `MatchSchedulersOnline` is the right default. |
| **Pool reusable values** (DB conns, file handles) | [`bath`](#bath) | Generic resource pool. Most active in this slot. |
| **Pool stateful workers** (one actor per worker) | [`lifeguard`](#lifeguard) | Actor pool with fire-and-forget + call/response. |
| **Pool of pre-computed work units** | [`crew`](#crew) | Named pools, blocking + non-blocking APIs. |
| **Durable job queue with retries** | [`m25`](#m25) | Postgres-backed. The current standard. |
| **Cron / time-based scheduling** | [`clockwork_schedule`](#clockwork_schedule) | In-process. Pair with [`m25`](#m25) for durable+scheduled. |
| **Rate limit by key** (IP, user) | [`glimit`](#glimit) | Token bucket, ETS-backed default, pluggable storage. |
| **Debounce / throttle UI events** | Lustre 5.x — `event.debounce` / `event.throttle` | Built in. Trailing-edge by default. |
| **Inspect running processes** | [`spectator`](#spectator) | The Gleam-native answer to `:observer`. |
| **Benchmark a function** | [`glychee`](#glychee) (Benchee) or [`gleamy_bench`](#gleamy_bench) (pure) | Pick by whether you mind an Elixir build dep. |
| **Find one Pevensie "short m-name" library** | [`m25`](#m25), [`bath`](#bath) | If you half-remembered "m7 or m2" — that's `m25`. |
| **Reach Elixir libs** (Broadway, Oban, Flow, GenStage, :poolboy) | [`glixir`](#glixir) | Typed wrappers for FFI to Elixir/Erlang OTP. |

> [!IMPORTANT]
> **The leaderboard is not a recommendation order.** An actor pool can't replace a rate limiter; a benchmark tool can't replace a job queue. Use the [When to use what](#when-to-use-what) table to pick by job; use the per-category leaderboards to pick **between** competing implementations of the same role.

## State of the ecosystem

Gleam's parallelization story in 2026-05 is a **two-tier landscape**:

**Tier 1 — primitives.** [`gleam_otp`](#gleam_otp) 1.x is the bedrock: actors, supervisors, process refs. It is the **only** library here you'd reach for to write a brand-new concurrent module from scratch. Notably, **`gleam_otp` v1.0.0-rc1 (2025-05-16) removed the `task` module** in favour of actor-shaped abstractions — this stranded several earlier libraries pinned to `gleam_otp < 1.0.0` (see [Disregarded](#disregarded)). The supervisor API also went through a split (`static_supervisor` / `factory_supervisor`), which means any 2024-era OTP code on the BEAM is likely to need a refresh.

**Tier 2 — applied patterns.** A thin but functional ring of small libraries handles **resource pools** ([`bath`](#bath), [`lifeguard`](#lifeguard), [`crew`](#crew)), **rate limiting** ([`glimit`](#glimit), [`speedbump`](#speedbump)), **background jobs** ([`m25`](#m25)), **parallel map** ([`parallel_map`](#parallel_map), [`taskle`](#taskle), [`working_actors`](#working_actors)), and **observability** ([`spectator`](#spectator), [`glychee`](#glychee), [`gleamy_bench`](#gleamy_bench)). Each tends to be a single-author, <30★ project. The most prolific maintainer is **Pevensie** (Isaac Harris-Holt), who owns [`bath`](#bath), [`lifeguard`](#lifeguard), [`m25`](#m25), `barnacle`, `argus`, `valkyrie` — a cohesive cluster you'll see recurring across articles.

**Debouncing and throttling** is, for Lustre apps, **solved by Lustre 5.x core** — `event.debounce(ms)` and `event.throttle(ms)` are first-class attributes on events. Outside Lustre, **no general-purpose Gleam package implements `debounce(fn, ms)` / `throttle(fn, ms)`**. That gap is small but real (see [the non-Lustre gap](#non-lustre-gap)).

**Background jobs** has a clear current leader in [`m25`](#m25) (Pevensie, Postgres-backed, v1.0.0 2025-08, 34★). The older [`bg_jobs`](#bg_jobs) is more flexible (SQLite + Postgres) but **pinned to `gleam_otp < 1.0.0`** and **won't resolve in new projects**. Treat it as obsolete unless upstream re-resolves the cap.

**No Gleam equivalents** of Elixir's `Broadway`, `Flow`, `GenStage`, `Oban`, `Exq`, or Erlang's `:poolboy` exist as native packages. [`glixir`](#glixir) (typed wrappers for `GenServer` / `DynamicSupervisor` / `Agent` / `Registry` / `Phoenix.PubSub` + libcluster bindings) is the closest, but it stops at OTP primitives — for the higher-level libraries you FFI directly to the Elixir/Erlang packages.

## Recursive directory anecdote — why unbounded `task.async` blows up

> [!CAUTION]
> **Real foot-gun.** Don't do this:
>
> ```gleam
> // ❌ BAD: spawn an unbounded task per directory entry.
> pub fn count_files(root: String) -> Int {
>   let assert Ok(entries) = simplifile.read_directory(root)
>
>   entries
>   |> list.map(fn(entry) {
>     task.async(fn() {
>       let full = root <> "/" <> entry
>       case simplifile.is_directory(full) {
>         Ok(True) -> count_files(full)
>         _ -> 1
>       }
>     })
>   })
>   |> list.map(task.await_forever)
>   |> int.sum
> }
> ```
>
> On a small repo, this finishes fine and feels brilliant. Pointed at `/` or `node_modules` it will:
>
> - Hit your file-descriptor `ulimit` (typically 1024) and start failing opens.
> - Grow the await stack linearly with the **total node count** of the tree, holding every awaiter alive at once.
> - Saturate the file-driver port pool.
> - Eventually OOM or hang, **without crashing the BEAM** — the schedulers are still happy; it's the OS resources that ran out.

The lesson is not "the BEAM is fragile." The BEAM handles 200,000 short compute processes trivially. What it does *not* handle is **200,000 simultaneous file-system ports plus a deep recursive await stack**. The cheap thing (process spawn) is genuinely cheap; the expensive thing (OS resources held open until every child returns) is what bites you.

**The fix is bounded concurrency:** workers pull from a shared queue rather than each level spawning its own fan-out.

```gleam
// ✅ GOOD: bounded fan-out via a queue + fixed worker count.
//
// Phase 1: walk the tree sequentially to gather paths.
// Phase 2: parallel_map.list_pmap with MatchSchedulersOnline over the file list.
pub fn count_files(root: String) -> Int {
  root
  |> walk_paths    // ordinary recursive walk, no spawns
  |> parallel_map.list_pmap(
       worker: fn(_path) { 1 },
       workers: parallel_map.MatchSchedulersOnline,
       batch_size: 100,
     )
  |> list.map(fn(r) { result.unwrap(r, 0) })
  |> int.sum
}
```

For "I don't know the work upfront, it's discovered by walking" — the actual recursive-directory case — the BEAM-idiomatic answer is a **single queue actor with N pulling workers**, where you *push* discovered directories into the queue rather than spawn-and-await. No Gleam library ships this as `walk_directory_parallel` today (see [What's missing](#whats-missing)); the closest off-the-shelf option is [`crew`](#crew)'s named-pool API for dispatch + a hand-rolled queue using [`gleam_deque`](#gleam_deque).

The longer-form version of this pattern with running code is in [axkira's "Parallel tasks from pool" DEV.to post][devto-pool] — worth reading as the closest documented prior art.

[devto-pool]: https://dev.to/axkira/code-gleam-parallel-tasks-from-pool-2bjo

## Non-goals

To keep the article honest about its scope:

- **Distributed BEAM clustering** — `libcluster`, `barnacle`, `nessie_cluster`, `glyn`'s clustering surface, `processgroups`'s distributed mode. Mentioned briefly where adjacent (e.g. `glyn` is in scope as a *local* PubSub/Registry; its distributed half is footnoted).
- **`:rpc` cross-node calls**, distribution protocol, Erlang cookies, TLS distribution.
- **Kubernetes / Nomad / fly.io horizontal scaling** of BEAM nodes.
- **`GenStage` / `Broadway` / `Flow` back-pressured pipelines** at the architectural level. We note they exist in Elixir and are reachable via [`glixir`](#glixir) but don't review them in depth.
- **BEAM VM tuning** — scheduler bind types, dirty schedulers, `+S` flags, async-thread pool sizing, `+P` max-processes.

What we **do** cover: single-node, in-process parallelism — actors, pools, queues, parallel-map, rate limiting, debounce/throttle, scheduling, in-process observability.

## Research method

### Scoring dimensions

Same 7-dimension rubric as [databases.md#scoring-dimensions](databases.md#scoring-dimensions). Recap:

- **Stars:** 🟩🟩 ≥200★, 🟩 ≥100★, 🟨 ≥10★, 🟥 <10★.
- **License:** 🟩 permissive (MIT/Apache/BSD), 🟥 viral (GPL/LGPL/AGPL) or missing.
- **Gleam compat:** `gleam_stdlib` constraint format. 🟩 range, 🟥 `~>` pin or missing.
- **Maintenance:** max(recency, responsiveness). 🟩🟩 <1 mo / clean tracker, 🟩 <6 mo, 🟨 <1 yr, 🟥 older.
- **Age:** 🟩🟩 ≥3 yrs, 🟩 ≥1 yr, 🟨 ≥3 mo, 🟥 <3 mo.
- **README maturity:** 🟩🟩 full guide + examples, 🟩 clear tagline + usage, 🟥 minimal/template.
- **Idiomaticity:** 🟩 typed/explicit, 🟥 magic or unsafe.

**Leaderboard:** 🟥 = −1, 🟨 = 0, 🟩 = 1, 🟩🟩 = 2. Sum of 7 dims, max 13.

### Discovery

~30 search terms run against the [Gleam packages registry](https://packages.gleam.run/). Cross-checked against [hex.pm](https://hex.pm/), GitHub `language:gleam` searches, and GitLab.

**Primitives:**
- [actor](https://packages.gleam.run/?search=actor) · [process](https://packages.gleam.run/?search=process) · [supervisor](https://packages.gleam.run/?search=supervisor) · [registry](https://packages.gleam.run/?search=registry) · [pubsub](https://packages.gleam.run/?search=pubsub) · [otp](https://packages.gleam.run/?search=otp)

**Pools / parallel-map / workers:**
- [pool](https://packages.gleam.run/?search=pool) · [worker](https://packages.gleam.run/?search=worker) · [parallel](https://packages.gleam.run/?search=parallel) · [task](https://packages.gleam.run/?search=task) · [concurrency](https://packages.gleam.run/?search=concurrency) · [concurrent](https://packages.gleam.run/?search=concurrent) · [pmap](https://packages.gleam.run/?search=pmap) · [async](https://packages.gleam.run/?search=async)

**Job queues / batching:**
- [job](https://packages.gleam.run/?search=job) · [queue](https://packages.gleam.run/?search=queue) · [batch](https://packages.gleam.run/?search=batch) · [pipeline](https://packages.gleam.run/?search=pipeline) · [background](https://packages.gleam.run/?search=background) · [scheduler](https://packages.gleam.run/?search=scheduler) · [cron](https://packages.gleam.run/?search=cron)

**Rate / debounce / throttle:**
- [rate](https://packages.gleam.run/?search=rate) · [limit](https://packages.gleam.run/?search=limit) · [throttle](https://packages.gleam.run/?search=throttle) · [debounce](https://packages.gleam.run/?search=debounce) · [bucket](https://packages.gleam.run/?search=bucket) · [token](https://packages.gleam.run/?search=token) (filtered) · [breaker](https://packages.gleam.run/?search=breaker) · [circuit](https://packages.gleam.run/?search=circuit)

**Observability:**
- [observer](https://packages.gleam.run/?search=observer) · [profile](https://packages.gleam.run/?search=profile) · [bench](https://packages.gleam.run/?search=bench) · [telemetry](https://packages.gleam.run/?search=telemetry) · [tracing](https://packages.gleam.run/?search=tracing)

Direct probes for short-name candidates the user vaguely recalled: `m7`, `m2`, `m25`, `bath`. (`m7`/`m2` returned no results; `m25` and `bath` are the matches — see [m25](#m25) and [bath](#bath).)

## Disregarded

Surfaced in searches but **not** scored. Listed up-front so readers see "this corner has been considered" before drilling in.

| Package | Reason disregarded |
| --- | --- |
| [`glimmer`](https://hex.pm/packages/glimmer) (RyanBrewer317) | "A concurrency library for Gleam." Capped at `gleam_otp ~> 0.7` / `gleam_stdlib ~> 0.30`. **~2.7 years stale.** **GPL-3.0** (viral). Won't resolve in modern projects. |
| [`puddle`](https://hex.pm/packages/puddle) (massivefermion) | Resource pool, pre-OTP-v1. Capped at `gleam_otp ~> 0.8`. **~17 months stale.** Won't resolve. Cited by [`lifeguard`](#lifeguard) as design inspiration. |
| [`task_limiter`](https://hex.pm/packages/task_limiter) (devries) | Pinned to `gleam_otp < 1.0.0`. Won't resolve. Sister package [`working_actors`](#working_actors) was bumped to gleam_otp 1.x; this one wasn't. |
| [`bg_jobs`](https://hex.pm/packages/bg_jobs) (MaxHill) | **See [bg_jobs](#bg_jobs) for the full callout.** Capped at `gleam_otp < 1.0.0` and `gleam_stdlib < 1.0.0`. Will not resolve in new projects. Was useful as a predecessor to [`m25`](#m25); now effectively obsolete unless upstream re-resolves. Listed in [Background job queues](#background-job-queues) with a `[!CAUTION]` rather than fully disregarded because the SQLite-backed option is valuable if you're on an older toolchain. |
| [`kairos`](https://github.com/ccarvalho-eng/kairos) | **Archived on GitHub.** Author has explicitly stopped maintaining. |
| [`glimiter`](https://hex.pm/packages/glimiter) (H-274) | "Simple sliding window limiter." GitHub repo **returns 404** — source deleted. Hex package may still resolve but no audit trail. Same edge case as `cosmo_cli` in [cli.md](cli.md). |
| [`fresnel`](https://hex.pm/packages/fresnel) (bnprtr) | Actor utilities. 24 months stale, v0.1.1, pre-v1 OTP. |
| [`shakespeare`](https://hex.pm/packages/shakespeare) (maxdeviant) | "General-purpose OTP actors." 17 months stale; predates `gleam_otp` v1. |
| [`db_pool`](https://hex.pm/packages/db_pool) (stndrs) | 1★, minimal README, undocumented Gleam compat. [`pog`](https://hex.pm/packages/pog) ships its own pool — this is redundant. |
| [`dinosoup`](https://hex.pm/packages/dinosoup) (kodumbeats) | Dynamic supervisor, 4★, Feb 2024 stale. Superseded by `gleam_otp`'s `factory_supervisor`. |
| [`small_supervisor`](https://hex.pm/packages/small_supervisor) (vpribish) | Learning project, not a library. |
| [`glydamic`](https://hex.pm/packages/glydamic) (karlsson) | 0★, sparse README. |

Disregarded for **not being concurrency primitives** but surfacing in keyword searches: `nessie` (DNS), `nanoworker` (browser Web Workers — JS target only, UI-thread off-loading), `miniflare` (Cloudflare emulator), `midas` (build task runner), `claude_gleam` (LLM SDK), `event_hub` (event sourcing pub/sub, not a concurrency primitive), `fluentci` / `dagger_gleam` (CI pipelines).

## When to use what

| You want to… | Use | Notes |
| --- | --- | --- |
| **Find your bottleneck first** | [`spectator`](#spectator) + [`glychee`](#glychee) | Always step 1. Don't parallelize before measuring. |
| **Fan out N independent items, bounded by CPU** | [`parallel_map`](#parallel_map) | `MatchSchedulersOnline` is the default. |
| **Run M of N async tasks at a time (Elixir `Task`-shaped)** | [`taskle`](#taskle) | Closest Elixir-`Task` ergonomics. |
| **Hand-rolled N workers over a list** | [`working_actors`](#working_actors) | One function, minimal surface. |
| **Pool reusable values** (conns, file handles) | [`bath`](#bath) | The generic resource pool. |
| **Pool stateful workers** (one actor each) | [`lifeguard`](#lifeguard) | Actor pool. |
| **Named worker pools, blocking + non-blocking dispatch** | [`crew`](#crew) | The most flexible pool API. |
| **Durable retry-with-backoff job queue** | [`m25`](#m25) | Postgres-backed. Production-grade. |
| **In-process cron** | [`clockwork_schedule`](#clockwork_schedule) | Pairs with [`clockwork`](#clockwork). |
| **Token-bucket rate limit by key** | [`glimit`](#glimit) | ETS-backed default, pluggable. |
| **Simple per-process rate limit** | [`speedbump`](#speedbump) | One actor, simpler than glimit. |
| **Rate-limit defaults for popular APIs** (OpenAI etc) | [`ezconfig`](#ezconfig) | Data, not runtime. |
| **Debounce / throttle in a Lustre app** | Lustre 5.x `event.debounce` / `event.throttle` | Built in. Trailing edge. |
| **Debounce / throttle outside Lustre** | **DIY** — see [non-Lustre gap](#non-lustre-gap) | No library covers this. |
| **Circuit breaker** | [`circuit_breaker`](#circuit_breaker) (BEAM) or [`circuit`](#circuit) (dual-target) | Niche but solid. |
| **Reach Elixir's Broadway/Oban/Flow/Poolboy** | [`glixir`](#glixir) | Typed FFI wrappers. |
| **Local PubSub between actors** | [`glubsub`](#glubsub) or [`glyn`](#glyn) (local API) | glyn also supports clustering — local API is in scope here. |
| **Actor registry by key** | [`reki`](#reki) | ETS-backed. |
| **Singleton actor registry** | [`singularity`](#singularity) | One known actor per name. |
| **Shared mutable state across processes** | [`cell`](#cell) | ETS-backed concurrent ref. |
| **Mailbox / queue inspection of a running system** | [`spectator`](#spectator) | The Gleam answer to `:observer`. |
| **Benchmark with Benchee features** | [`glychee`](#glychee) | Statistical noise rejection, formatters. |
| **Benchmark with no Elixir build dep** | [`gleamy_bench`](#gleamy_bench) | Pure Gleam. |
| **Half-remembered "m7 or m2 or…"** | [`m25`](#m25) (and probably also [`bath`](#bath)) | Same author — easy to conflate. |

## Categories

### Bottleneck identification / observability

> [!IMPORTANT]
> **Read this section before any of the others.** Adding actors, pools, or parallel-map to code with the wrong bottleneck won't help — and may hurt. Find what's slow before you decide how to spread the work.
>
> A short workflow:
>
> 1. **Quick wall-clock check** — `:timer.tc/1` is in Erlang stdlib. No deps. `let #(microseconds, result) = erlang.timer_tc(fn() { thing() })`.
> 2. **Statistical benchmark** — [`glychee`](#glychee) for full Benchee features (warmup, parallel runs, formatters), [`gleamy_bench`](#gleamy_bench) for pure-Gleam with no Elixir dep.
> 3. **Live process inspection** — [`spectator`](#spectator) for "which process is stuck, what's in its mailbox, which ETS table is huge."
> 4. **Mailbox depth / scheduler load** — surface via `spectator`'s dashboard, or FFI to `erlang:system_info/1`, `erlang:statistics/1`.
> 5. **Per-function profiling** — no Gleam wrapper; FFI to `:eprof` / `:fprof` / `:cprof` (see [What's missing](#whats-missing) for FFI recipes).
> 6. **Production-safe diagnostics** — `:recon` for "what's the most memory-hungry process right now." FFI inline.

#### spectator

- **Repo:** [JonasGruenwald/spectator](https://github.com/JonasGruenwald/spectator) · [hex](https://hex.pm/packages/spectator)
- **Stars:** 94★ · **License:** MIT · **Target:** Erlang · **Last commit:** 2026-04-21

The **Gleam-native answer to `:observer`** — a web UI for inspecting BEAM processes, ETS tables, ports, and a dashboard view. Run it in-app for local dev or stand-alone (Docker) to connect to a remote node. Tag processes for easy filtering, sort by mailbox size or memory, drill into individual process state.

> [!NOTE]
> **Two production caveats.** (1) Probing processes via `erlang:process_info/2` puts a lock on each target — on a very busy system this can slow things down noticeably. (2) Spectator ships no authentication; **don't expose it to the public internet**. Put it behind a VPN, reverse proxy with basic auth, or only run it locally and SSH-tunnel.

```gleam
import spectator

pub fn main() {
  // Embedded mode — serve the observer alongside your app.
  let assert Ok(_) = spectator.start_observer(port: 4040)
  // … your normal app startup …
}
```

#### glychee

- **Repo:** [inoas/glychee](https://github.com/inoas/glychee) · [hex](https://hex.pm/packages/glychee)
- **Stars:** 23★ · **License:** MPL-2.0 · **Target:** Erlang · **Last commit:** 2026-05-10

Wraps Elixir's [Benchee](https://github.com/bencheeorg/benchee) for Gleam. Most active benchmark tool. Gets you warmup, parallel runs, statistical noise rejection, formatters (console / HTML / CSV / JSON), memory measurements.

```gleam
import glychee/benchmark
import glychee/configuration

pub fn main() {
  configuration.initialize()

  benchmark.run(
    configuration.new()
      |> configuration.warmup(2)
      |> configuration.time(5),
    [
      benchmark.Function(label: "naive", callable: fn(_) { naive_sort(big_list) }),
      benchmark.Function(label: "merge", callable: fn(_) { merge_sort(big_list) }),
    ],
    inputs: [#("big_list", big_list)],
  )
}
```

> [!NOTE]
> MPL-2.0 is weak copyleft — file-level reciprocity, not project-level. Fine for most uses including closed-source distribution; you only need to share modifications to glychee itself if you fork it.

#### gleamy_bench

- **Repo:** [schurhammer/gleamy_bench](https://github.com/schurhammer/gleamy_bench) · [hex](https://hex.pm/packages/gleamy_bench)
- **Stars:** 17★ · **License:** Apache-2.0 · **Target:** Erlang · **Last commit:** 2025-02-17

Pure-Gleam benchmark library. No Elixir build dep. Simpler than glychee — less statistical machinery, but you avoid pulling in the Elixir compiler. Pick this if your project doesn't already build Elixir.

```gleam
import gleamy/bench

pub fn main() {
  bench.run(
    [bench.Input("100 items", list.range(0, 100))],
    [bench.Function("naive", naive_sort), bench.Function("merge", merge_sort)],
    [bench.Duration(1000), bench.Warmup(100)],
  )
  |> bench.table([bench.IPS, bench.Min, bench.P(99)])
  |> io.println
}
```

#### viva_telemetry

- **Repo:** [gabrielmaialva33/viva_telemetry](https://github.com/gabrielmaialva33/viva_telemetry) · [hex](https://hex.pm/packages/viva_telemetry)
- **Stars:** (low) · **License:** unknown · **Target:** Erlang

Self-described "observability suite: structured logging, metrics, statistical benchmarking." Broader scope than profiling. Listed here for completeness — verify the license before adopting (no SPDX surfaced).

---

### Concurrency primitives

The foundation. You'll write `actor` and `supervisor` calls when nothing higher-level fits.

#### gleam_otp

- **Repo:** [gleam-lang/otp](https://github.com/gleam-lang/otp) · [hex](https://hex.pm/packages/gleam_otp)
- **Stars:** 850★ · **License:** Apache-2.0 · **Target:** Erlang · **Last commit:** 2026-04-29

The bedrock. Actors, `static_supervisor`, `factory_supervisor`, port + system modules. Type-safe message passing.

> [!CAUTION]
> **The `task` module was removed in v1.0.0-rc1 (2025-05-16).** If you have older code that does `import gleam/otp/task`, it won't compile on `gleam_otp` 1.x. The official replacement is to write an actor (or use [`taskle`](#taskle) / [`parallel_map`](#parallel_map) / [`working_actors`](#working_actors), which provide Task-shaped APIs on top of 1.x).

#### glixir

- **Repo:** [rjpruitt16/genserver](https://github.com/rjpruitt16/genserver) · [hex](https://hex.pm/packages/glixir)
- **Stars:** 17★ · **License:** (no SPDX surfaced) · **Target:** Erlang · **Last commit:** 2025-11-18

The **FFI bridge to Elixir OTP.** Typed wrappers for `GenServer`, `Agent`, `DynamicSupervisor`, `Registry`, `Phoenix.PubSub`, plus libcluster / Syn bindings. Use this when you need to reach an Elixir-only library (Broadway, Oban, Flow, GenStage, `:poolboy`) — glixir gives you the OTP primitives typed; you build the higher-level wrapper yourself.

```gleam
import glixir/agent

let counter = agent.start(fn() { 0 })
agent.update(counter, fn(n) { n + 1 })
let v = agent.get(counter, fn(n) { n })
```

> [!NOTE]
> **No SPDX license field surfaced.** Audit before adopting in a project with licensing constraints.

#### glyn

- **Repo:** [mbuhot/glyn](https://github.com/mbuhot/glyn) · [hex](https://hex.pm/packages/glyn)
- **Stars:** 89★ · **License:** MIT · **Target:** Erlang · **Last commit:** 2025-08-16

Type-safe PubSub + Registry built on Syn. Supports distributed clustering — **the distributed surface is [out of scope](#non-goals) here**; the local PubSub/Registry surface is in scope and is a credible alternative to [`glubsub`](#glubsub) + [`reki`](#reki).

#### reki

- **Repo:** [alii/reki](https://github.com/alii/reki) · [hex](https://hex.pm/packages/reki)
- **Stars:** 8★ · **License:** MIT · **Target:** Erlang · **Last commit:** 2026-02-17

Actor registry by key. ETS-backed, automatic cleanup of dead processes. Local-only — pick this for "look up an actor by user_id" without the clustering overhead.

#### singularity

- **Repo:** [jhillyerd/singularity](https://github.com/jhillyerd/singularity) · [hex](https://hex.pm/packages/singularity)
- **Stars:** 13★ · **License:** Apache-2.0 · **Target:** Erlang · **Last commit:** 2026-01-26

Singleton OTP actor registry — exactly one actor per name. Useful for "the one cache" or "the one config-watcher."

#### processgroups

- **Repo:** [RudolfVonKrugstein/gleam_processgroups](https://github.com/RudolfVonKrugstein/gleam_processgroups) · [hex](https://hex.pm/packages/processgroups)
- **Stars:** 0★ · **License:** Apache-2.0 · **Target:** Erlang · **Last commit:** 2025-10-01

Type-safe wrapper around Erlang's `:pg` (process groups). Supports both local and distributed groups. Use the local API for "broadcast to all subscribers" patterns; the distributed half is [out of scope](#non-goals).

#### cell

- **Repo:** [lpil/cell](https://github.com/lpil/cell) · [hex](https://hex.pm/packages/cell)
- **Stars:** 25★ · **License:** (no SPDX) · **Target:** Erlang · **Last commit:** 2025-10-07

By Louis Pilfold (gleam-lang creator). Mutable references **via ETS** — concurrent-access shared state without an actor in the hot path. Use for caches, request-scoped counters, anywhere you'd reach for an `Agent` in Elixir but want lock-free reads.

```gleam
import cell

let counter = cell.new(0)
cell.update(counter, fn(n) { n + 1 })
let v = cell.get(counter)
```

#### eparch

- **Repo:** [byzantine-systems/eparch](https://github.com/byzantine-systems/eparch) · [hex](https://hex.pm/packages/eparch)
- **Stars:** 2★ · **License:** **LGPL-3.0** · **Target:** Erlang · **Last commit:** 2026-05-12

Typed wrappers for Erlang behaviours `gen_statem` and `gen_event` (which `gleam_otp` doesn't natively cover). Useful for state-machine actors. Very active.

> [!WARNING]
> **LGPL-3.0** — weak copyleft, but more demanding than MIT/Apache. If you statically link / vendor / fork eparch, the LGPL terms apply. Dynamic linking via standard Hex deps is typically fine. Audit before commercial use.

#### glubsub

- **Repo:** [okkdev/glubsub](https://github.com/okkdev/glubsub) · [hex](https://hex.pm/packages/glubsub)
- **Stars:** 6★ · **License:** (no SPDX) · **Target:** Erlang · **Last commit:** 2025-10-06

Simple local PubSub. Pick this over [`glyn`](#glyn) if you explicitly don't want the clustering surface at all.

---

### Parallel-map / task abstractions

For when you have a list and want each item processed concurrently.

#### parallel_map

- **Repo:** [PastMoments/parallel_map](https://github.com/PastMoments/parallel_map) · [hex](https://hex.pm/packages/parallel_map)
- **Stars:** 11★ · **License:** Apache-2.0 · **Target:** Erlang · **Last commit:** 2026-01-05

The **most idiomatic "I want pmap" answer for the BEAM target.** Parallel `list.map` / `yielder.map` plus `find_pmap`. Worker count is explicit (`WorkerAmount(16)`) or auto (`MatchSchedulersOnline`). Tunable batch size. Each result wrapped in `Result` so failures don't bring down the whole batch.

```gleam
import parallel_map

let results: List(Result(Response, Error)) =
  parallel_map.list_pmap(
    urls,
    fetch,
    parallel_map.MatchSchedulersOnline,
    batch_size: 1000,
  )
```

**Default sizing:** `MatchSchedulersOnline` maps roughly to "use all your CPU cores." Increase batch size if work units are very small (per-item overhead dominates); decrease if they're large (better load balancing).

#### taskle

- **Repo:** [bondiano/taskle](https://github.com/bondiano/taskle) · [hex](https://hex.pm/packages/taskle)
- **Stars:** 9★ · **License:** Apache-2.0 · **Target:** Erlang · **Last commit:** 2025-07-30

Elixir-`Task`-style `async` / `await` / `cancel` + `parallel_map`. Designed to replace the removed `gleam_otp.task` module. Picks if you want Elixir-ish ergonomics.

```gleam
import taskle

let t1 = taskle.async(fn() { fetch("https://a") })
let t2 = taskle.async(fn() { fetch("https://b") })
let r1 = taskle.await(t1, 5000)
let r2 = taskle.await(t2, 5000)
```

> [!NOTE]
> ~10 months stale at snapshot. Last release is v2.0.0; no open issues. Still works fine — Gleam libraries that don't depend on internal stdlib changes tend to age gracefully.

#### working_actors

- **Repo:** [devries/working_actors](https://github.com/devries/working_actors) · [hex](https://hex.pm/packages/working_actors)
- **Stars:** 0★ · **License:** MIT · **Target:** Erlang · **Last commit:** 2025-08-07

`spawn_workers(count, args, fn)` — spawn N workers to process a list. Minimal surface (one function), if that's all you need.

#### future

- **Repo:** [BradBot1/gleam_future](https://github.com/BradBot1/gleam_future) · [hex](https://hex.pm/packages/future)
- **Stars:** 3★ · **License:** Apache-2.0 · **Target:** **dual** (Erlang + JS) · **Last commit:** 2025-07-16

The **only dual-target option** in this list — async futures for both runtimes. Notable because the JS target genuinely needs this (no BEAM scheduler to lean on).

> [!NOTE]
> The `gleam.toml` declares no `gleam_stdlib` / `gleam_otp` runtime deps, which is unusual — the library appears to implement its primitives directly. Audit before adopting in a project that needs strong stdlib version coupling.

---

### Resource pools / actor pools

For pooling expensive-to-create things: DB connections, file handles, parser state, etc.

#### bath

- **Repo:** [Pevensie/bath](https://github.com/Pevensie/bath) · [hex](https://hex.pm/packages/bath)
- **Stars:** 19★ · **License:** MIT · **Target:** Erlang · **Last commit:** 2026-02-20

**Generic resource pool.** Checkout/apply pattern with timeouts. Resources can be anything — DB connections, file handles, HTTP clients, parser state.

```gleam
import bath

let pool =
  bath.new(fn() { open_conn() })
  |> bath.with_size(10)
  |> bath.with_max_age(60_000)
  |> bath.start

use conn <- bath.apply(pool, timeout: 1000)
query(conn, "select 1")
```

Supervision-tree friendly via `bath.supervised`. `gleam_otp 1.x`. The most active general-purpose pool at snapshot.

> [!NOTE]
> **This is one of two libraries the user asked about by name** ("there is some lib called m7 or m2 or sth like that, also bath"). The other is [`m25`](#m25) (same author).

#### lifeguard

- **Repo:** [Pevensie/lifeguard](https://github.com/Pevensie/lifeguard) · [hex](https://hex.pm/packages/lifeguard)
- **Stars:** 18★ · **License:** MIT · **Target:** Erlang · **Last commit:** 2025-06-25

**Actor pool** (vs `bath`'s generic resource pool). Each pool member is a Gleam actor; you send it messages with fire-and-forget or call-and-await patterns. Inspired by Erlang's poolboy + [`puddle`](https://hex.pm/packages/puddle).

```gleam
import lifeguard

let spec = lifeguard.worker_spec(init: init_parser, handle: parse)
let pool =
  lifeguard.new(spec)
  |> lifeguard.with_size(8)
  |> lifeguard.start

lifeguard.send(pool, ParseLine("foo,bar,baz"))
let parsed = lifeguard.call(pool, ParseAndReturn("..."), 1000)
```

Pick this when each worker needs to hold state (open files, accumulators, statemachine state). Pick [`bath`](#bath) when the pooled thing is a value, not a process.

#### crew

- **Repo:** [gitlab.com/arkandos/crew](https://gitlab.com/arkandos/crew) · [hex](https://hex.pm/packages/crew)
- **Stars:** n/a (GitLab) · **License:** BSD-3-Clause · **Target:** Erlang · **Last commit:** 2025-09-17

Worker/task pool with limited concurrency. **Named pools** (multiple pools per app), blocking + non-blocking APIs, global concurrency limit. `crew.call_parallel` for batched work. `gleam_otp 1.1+`.

```gleam
import crew

let assert Ok(_) = crew.start_pool(name: "downloads", workers: 4)
let results = crew.call_parallel(pool: "downloads", inputs: urls, fn: fetch)
```

> [!NOTE]
> **GitLab-hosted** (not GitHub). No star count surfacing via the standard tooling; verify activity by visiting the repo. License: BSD-3-Clause.

---

### Background job queues

For "do this later, with retries, even if the process crashes."

#### m25

- **Repo:** [Pevensie/m25](https://github.com/Pevensie/m25) · [hex](https://hex.pm/packages/m25)
- **Stars:** 34★ · **License:** MIT · **Target:** Erlang · **Last commit:** 2026-01-01

**The current background-job standard.** Postgres-only backend (via [`pog`](https://hex.pm/packages/pog)). At-least-once delivery, retries with backoff, scheduled jobs, multiple named queues, heartbeats, stuck-job recovery. CLI for migrations. v1.0.0 released 2025-08-28.

Named after the **London ring road** — a Pevensie naming convention (`barnacle`, `valkyrie`, `argus`, `bath` for the family resemblance).

```gleam
import m25
import pog

pub fn main() {
  let assert Ok(conn) = pog.connect_default()
  let assert Ok(queue) =
    m25.new(conn)
    |> m25.with_queue("emails", workers: 4, max_retries: 3)
    |> m25.start

  m25.enqueue(queue, "emails", EmailJob(to: "user@example.com"))
}
```

**Recommended for new code.** If you need SQLite backing, see [`bg_jobs`](#bg_jobs)'s caveats below.

> [!TIP]
> **This is the package the user half-remembered as "m7 or m2 or sth like that."** The "M-and-number" naming pattern (M1, M11, M25, M40 are the London orbital motorways) is a Pevensie thing.

#### bg_jobs

- **Repo:** [MaxHill/bg_jobs](https://github.com/MaxHill/bg_jobs) · [hex](https://hex.pm/packages/bg_jobs)
- **Stars:** 16★ · **License:** Apache-2.0 · **Target:** Erlang · **Last commit:** 2025-05-12

Older but more flexible: **SQLite and Postgres** adapters. Cron and interval scheduling. Retry mechanism (default 3 retries). Supervisor-builder injection.

> [!CAUTION]
> **Pinned to `gleam_otp < 1.0.0` and `gleam_stdlib < 1.0.0`** at snapshot. **Will not resolve in new projects** depending on current stdlib/OTP. README is labelled WIP. Same gotcha pattern as the [`deriv` issue documented in serialization](serialization/codegen-json.md). Use only if your project is pinned to pre-v1 stdlib, or wait for upstream to re-resolve. For new code, prefer [`m25`](#m25).

---

### Rate limiting

Token-bucket / leaky-bucket limiters for shedding load.

#### glimit

- **Repo:** [nootr/glimit](https://github.com/nootr/glimit) · [hex](https://hex.pm/packages/glimit)
- **Stars:** 6★ · **License:** MIT · **Target:** Erlang · **Last commit:** 2026-05-11

**Token-bucket rate limiter, framework-agnostic.** Pluggable storage (ETS default; Redis or Postgres via custom store). Identifies requests by key (IP, user_id, API token). Fail-open default. Auto-cleanup of expired buckets every 10s. **Most active rate limiter** — committed two days before snapshot.

```gleam
import glimit

let limiter =
  glimit.new()
  |> glimit.per_second(100)
  |> glimit.with_key(fn(req) { req.ip })
  |> glimit.build

case glimit.check(limiter, req) {
  Ok(_) -> handle(req)
  Error(_) -> reply_429()
}
```

#### speedbump

- **Repo:** [bcpeinhardt/speedbump](https://github.com/bcpeinhardt/speedbump) · [hex](https://hex.pm/packages/speedbump)
- **Stars:** 0★ · **License:** Apache-2.0 · **Target:** Erlang · **Last commit:** 2025-08-02

Token-bucket rate limiter as a **single Gleam actor**. Simpler than glimit — pick this if you want one-process-one-limiter ergonomics and don't need pluggable storage.

#### crabbucket_pgo

- **Repo:** [skinkade/crabbucket_pgo](https://github.com/skinkade/crabbucket_pgo) · [hex](https://hex.pm/packages/crabbucket_pgo)
- **Stars:** 0★ · **License:** (no SPDX) · **Target:** Erlang · **Last commit:** 2024-07-24

**Postgres-backed token bucket** — durability across restarts. Use if you already have Postgres and want the rate-limit state to survive a deploy. ~22 months stale.

#### crabbucket_redis

- **Repo:** [skinkade/crabbucket_redis](https://github.com/skinkade/crabbucket_redis) · [hex](https://hex.pm/packages/crabbucket_redis)
- **Stars:** 1★ · **License:** (no SPDX) · **Target:** Erlang · **Last commit:** 2024-07-21

Same author, Redis backend. Useful for multi-node deployments where you want a shared rate-limit state. ~22 months stale.

#### ezconfig

- **Repo:** [rjpruitt16/ezconfig](https://github.com/rjpruitt16/ezconfig) · [hex](https://hex.pm/packages/ezconfig)
- **Stars:** 0★ · **License:** (no SPDX) · **Target:** Erlang · **Last commit:** 2026-03-24

**Not a rate limiter** — a **data catalogue** of community-maintained rate-limit defaults for popular APIs (OpenAI, Anthropic, Stripe, GitHub, Slack, etc.). Pair with a runtime limiter (glimit/speedbump). Useful as a single source of truth for "what does OpenAI's tier-3 actually allow?"

---

### Debouncing & throttling

> [!IMPORTANT]
> **Debounce and throttle are not the same thing.**
>
> - **Debounce**: collapse a burst of events into one, fired *after* the burst quietens. "User stopped typing — now search." Good for: search-as-you-type, window-resize handlers, autosave.
> - **Throttle**: cap the firing rate to "at most once per N ms," regardless of event volume. "Scrolling — only handle once per 100 ms." Good for: scroll handlers, mouse-move tracking, rate-limited API client calls.
>
> Both have **leading-edge** vs **trailing-edge** variants:
>
> | Variant | When the function fires |
> | --- | --- |
> | **Trailing edge** (default for both in most libraries) | After the quiet period (debounce) or at the end of the interval (throttle). The user-perceived "last event wins." |
> | **Leading edge** | Immediately on the first event, then suppress subsequent events for the quiet period or interval. Lower perceived latency. |
> | **Both edges** | Fire on the first event *and* after the quiet period. Useful for "show something now, finalise later." |

#### Lustre 5.x core (the canonical Gleam answer)

`event.debounce(ms)` and `event.throttle(ms)` are **built into Lustre 5.x** as first-class attributes on events. No extra dependency. They can be stacked on the same event.

```gleam
import lustre/event
import lustre/element/html

// Debounce: fire OnInput once the user stops typing for 300ms.
html.input([
  event.on_input(OnInput)
  |> event.debounce(300),
])

// Throttle: at most one OnScroll per 100ms.
html.div([
  event.on_scroll(OnScroll)
  |> event.throttle(100),
])

// Stacked: throttle scrolls AND debounce a "stopped scrolling" event.
html.div([
  event.on_scroll(OnScroll) |> event.throttle(100),
  event.on_scroll(OnScrollEnd) |> event.debounce(200),
])
```

> [!NOTE]
> **Edge semantics in Lustre 5.x are trailing by default.** As of snapshot, the Lustre changelog does not explicitly expose leading-edge variants — the implementation fires after the quiet period (debounce) or at the end of the interval (throttle). If you need leading-edge behaviour, the workaround is to track "first-event-of-burst" in your update function with a `Bool` flag in the model, resetting on the trailing-edge event.

#### lustre_limiter

- **Repo:** [7verdy/lustre-limiter](https://github.com/7verdy/lustre-limiter) · [hex](https://hex.pm/packages/lustre_limiter)
- **Stars:** 0★ · **License:** MIT · **Target:** Erlang · **Last commit:** 2024-07-30

Port of Hayleigh's `elm-limiter`. **Effectively superseded** by Lustre 5.x core's built-in `event.debounce` / `event.throttle`. ~22 months stale at snapshot. Useful only for projects pinned to Lustre 4.x or earlier. For new code on Lustre 5.x, use the core API.

#### Non-Lustre gap

**No standalone Gleam package implements `debounce(fn, delay)` / `throttle(fn, delay)` for plain functions.** The Lustre integration covers UI events, but anyone wanting these primitives in a back-end actor, a CLI, or a non-Lustre frontend rolls their own.

**DIY recipe — debounce (trailing edge) via an actor:**

```gleam
import gleam/erlang/process
import gleam/otp/actor

type Msg(a) {
  Event(a)
  Tick(ref: process.Selector(Msg(a)))
}

type State(a) {
  State(last: option.Option(a), timer: option.Option(process.Timer))
}

pub fn start_debouncer(
  delay_ms: Int,
  on_fire: fn(a) -> Nil,
) -> Result(actor.Subject(Msg(a)), actor.StartError) {
  actor.start(State(option.None, option.None), fn(msg, state) {
    case msg {
      Event(value) -> {
        // Cancel any pending timer, schedule a new one.
        option.map(state.timer, process.cancel_timer)
        let new_timer = process.send_after(self, delay_ms, Tick(...))
        actor.continue(State(option.Some(value), option.Some(new_timer)))
      }
      Tick(_) -> {
        option.map(state.last, on_fire)
        actor.continue(State(option.None, option.None))
      }
    }
  })
}
```

**Throttle (leading edge)** is even simpler — track `last_fired_at`, drop events while inside the window.

If filling this gap as a library, the natural API surface would be:

```gleam
// Hypothetical.
debounce.new(delay: 300, mode: debounce.Trailing, fn: on_fire)
throttle.new(interval: 100, mode: throttle.Leading, fn: on_fire)
```

— but no such package exists at snapshot. Worth a future contribution.

---

### Scheduling

For "run this at 02:00 every Tuesday" — in-process cron.

#### clockwork

- **Repo:** [renatillas/clockwork](https://github.com/renatillas/clockwork) · [hex](https://hex.pm/packages/clockwork)

Cron-expression parser + evaluator. The base layer — use it directly for "next fire time after T" calculations, or pair with [`clockwork_schedule`](#clockwork_schedule) for a full scheduler actor.

#### clockwork_schedule

- **Repo:** [renatillas/clockwork_schedule](https://github.com/renatillas/clockwork_schedule) · [hex](https://hex.pm/packages/clockwork_schedule)
- **Stars:** 6★ · **License:** (no SPDX) · **Target:** Erlang · **Last commit:** 2025-10-18

Scheduling expansion for clockwork — define and manage recurring tasks. **In-process** (not durable across restarts). For durability use [`m25`](#m25) with scheduled enqueues; for in-process recurring work this is the cleanest option.

```gleam
import clockwork_schedule

let assert Ok(_) =
  clockwork_schedule.new()
  |> clockwork_schedule.every("0 */15 * * * *", fn() { sync_users() })
  |> clockwork_schedule.every("0 0 2 * * *", fn() { nightly_backup() })
  |> clockwork_schedule.start
```

---

### Circuit breakers (adjacent)

Not strictly parallelization, but they show up in any "high-throughput external call" design.

#### circuit_breaker

- **Repo:** [manelsen/circuitbreaker](https://github.com/manelsen/circuitbreaker) · [hex](https://hex.pm/packages/circuit_breaker)
- **Stars:** 0★ · **License:** Apache-2.0 · **Target:** Erlang · **Last commit:** 2026-04-22

Closed / open / half-open states, OTP-actor backed. `gleam_otp 1.x`.

#### circuit

- **Repo:** [jsquardo/circuit](https://github.com/jsquardo/circuit)
- **Stars:** 0★ · **License:** MIT · **Target:** **dual** (Erlang + JS) · **Last commit:** 2026-03-30

Sliding-window tracking. **Dual-target** — rare in this corner. Pick this if you want a circuit breaker on a Lustre frontend or Deno backend.

---

## What's missing

Categories where Gleam has no library (or a stale-only library), with the FFI escape hatch to reach the equivalent Erlang/Elixir package.

| Capability | Gleam status | FFI escape hatch |
| --- | --- | --- |
| **Back-pressured pipeline framework** (Elixir `GenStage` / `Flow` / `Broadway`) | No Gleam port. | FFI via [`glixir`](#glixir) for OTP primitives; build the pipeline shape yourself. Or call Elixir's `GenStage` / `Broadway` directly from Gleam-Erlang via `@external`. |
| **`:poolboy` (Erlang)** | No native wrapper. | [`bath`](#bath) and [`lifeguard`](#lifeguard) cover the same shape natively. If you need poolboy's specific config knobs (overflow, queue-strategy), `@external(erlang, "poolboy", "...")`. |
| **Erlang `:fprof` / `:eprof` / `:cprof`** | No Gleam wrapper. | `@external(erlang, "eprof", "start_profiling")` → `@external(erlang, "eprof", "analyze")`. Three lines. |
| **`:recon`** (production-safe diagnostics — `proc_count`, `bin_leak`, etc.) | No Gleam wrapper. | `@external(erlang, "recon", "proc_count")`. The `recon` Hex package needs to be added to deps. |
| **General-purpose debounce/throttle** (non-Lustre) | Empty slot. | DIY via `process.send_after` + a stateful actor — recipe in [Non-Lustre gap](#non-lustre-gap). |
| **Walk a directory tree in parallel** (bounded fan-out) | No off-the-shelf walker. | Hand-roll using [`crew`](#crew) + [`gleam_deque`](#gleam_deque) (queue) — see [Recursive directory anecdote](#recursive-directory-anecdote--why-unbounded-taskasync-blows-up). |
| **Distributed pubsub / registry** (multi-node) | [`glyn`](#glyn) and [`processgroups`](#processgroups) exist but [out of scope here](#non-goals). | Use them; this article won't review them. |
| **Bulkhead pattern** | No dedicated library. | Approximate via [`crew`](#crew) — multiple named pools, each capped, isolates failures between concerns. |
| **Saga / distributed transaction coordinator** | No Gleam library. | Out of scope; usually a layer above what this article covers. |
| **GenStage-shaped back-pressure** (producer-consumer with demand) | No Gleam library. | DIY with two actors + an explicit `request_more(n)` message. Or FFI. |

### Recipe — wrap `:eprof` for per-function profiling

```gleam
@external(erlang, "eprof", "start_profiling")
fn eprof_start(pids: List(process.Pid)) -> a

@external(erlang, "eprof", "stop_profiling")
fn eprof_stop() -> a

@external(erlang, "eprof", "analyze")
fn eprof_analyze() -> a

pub fn profile(pids: List(process.Pid), work: fn() -> a) -> a {
  eprof_start(pids)
  let result = work()
  eprof_stop()
  eprof_analyze()  // prints to stdout
  result
}
```

### Recipe — wrap `:recon.proc_count/2`

```gleam
@external(erlang, "recon", "proc_count")
fn recon_proc_count(attr: Atom, n: Int) -> List(a)

pub fn top_memory_hogs(n: Int) -> List(a) {
  recon_proc_count(atom.create("memory"), n)
}
```

Add `{:recon, "~> 2.5"}` to your `gleam.toml` deps to make these resolve.

---

## Comparison matrix

| Package | Category | ★ | License | Compat | Maint | Age | README | Idiomatic | Score |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | ---: |
| [`gleam_otp`](#gleam_otp) | Primitives | 🟩🟩 | 🟩 | 🟩 | 🟩🟩 | 🟩🟩 | 🟩🟩 | 🟩 | **12** |
| [`spectator`](#spectator) | Observability | 🟨 | 🟩 | 🟩 | 🟩🟩 | 🟩 | 🟩🟩 | 🟩 | **9** |
| [`glyn`](#glyn) | PubSub/Registry | 🟨 | 🟩 | 🟩 | 🟩 | 🟩 | 🟩 | 🟩 | **7** |
| [`m25`](#m25) | Job queue | 🟨 | 🟩 | 🟩 | 🟩 | 🟨 | 🟩🟩 | 🟩 | **8** |
| [`cell`](#cell) | Shared state | 🟨 | 🟥 | 🟩 | 🟩 | 🟨 | 🟩 | 🟩 | **5** |
| [`glychee`](#glychee) | Benchmark | 🟨 | 🟩 | 🟩 | 🟩🟩 | 🟩 | 🟩 | 🟩 | **8** |
| [`bath`](#bath) | Resource pool | 🟨 | 🟩 | 🟩 | 🟩 | 🟩 | 🟩 | 🟩 | **7** |
| [`lifeguard`](#lifeguard) | Actor pool | 🟨 | 🟩 | 🟩 | 🟩 | 🟩 | 🟩 | 🟩 | **7** |
| [`crew`](#crew) | Worker pool | 🟥 | 🟩 | 🟩 | 🟩 | 🟩 | 🟩 | 🟩 | **5** |
| [`gleamy_bench`](#gleamy_bench) | Benchmark | 🟨 | 🟩 | 🟩 | 🟨 | 🟩 | 🟩 | 🟩 | **6** |
| [`glixir`](#glixir) | OTP FFI | 🟨 | 🟥 | 🟩 | 🟩 | 🟩 | 🟩 | 🟩 | **5** |
| [`parallel_map`](#parallel_map) | Parallel-map | 🟨 | 🟩 | 🟩 | 🟩 | 🟩 | 🟩 | 🟩 | **7** |
| [`taskle`](#taskle) | Tasks | 🟥 | 🟩 | 🟩 | 🟨 | 🟩 | 🟩 | 🟩 | **5** |
| [`working_actors`](#working_actors) | Tasks | 🟥 | 🟩 | 🟩 | 🟩 | 🟨 | 🟨 | 🟩 | **3** |
| [`future`](#future) | Tasks (dual) | 🟥 | 🟩 | 🟥 | 🟨 | 🟨 | 🟨 | 🟩 | **1** |
| [`glimit`](#glimit) | Rate limit | 🟥 | 🟩 | 🟩 | 🟩🟩 | 🟩 | 🟩 | 🟩 | **6** |
| [`speedbump`](#speedbump) | Rate limit | 🟥 | 🟩 | 🟩 | 🟩 | 🟩 | 🟩 | 🟩 | **5** |
| [`bg_jobs`](#bg_jobs) | Job queue | 🟨 | 🟩 | 🟥 | 🟨 | 🟩 | 🟨 | 🟩 | **4** |
| [`clockwork_schedule`](#clockwork_schedule) | Scheduling | 🟥 | 🟥 | 🟩 | 🟩 | 🟩 | 🟩 | 🟩 | **4** |
| [`reki`](#reki) | Registry | 🟥 | 🟩 | 🟩 | 🟩 | 🟩 | 🟩 | 🟩 | **5** |
| [`singularity`](#singularity) | Registry | 🟨 | 🟩 | 🟩 | 🟩 | 🟩 | 🟩 | 🟩 | **7** |
| [`processgroups`](#processgroups) | PubSub | 🟥 | 🟩 | 🟩 | 🟩 | 🟩 | 🟨 | 🟩 | **4** |
| [`glubsub`](#glubsub) | PubSub | 🟥 | 🟥 | 🟩 | 🟩 | 🟨 | 🟩 | 🟩 | **3** |
| [`eparch`](#eparch) | Behaviours | 🟥 | 🟥 | 🟩 | 🟩🟩 | 🟨 | 🟩 | 🟩 | **4** |
| [`circuit_breaker`](#circuit_breaker) | Circuit | 🟥 | 🟩 | 🟩 | 🟩 | 🟩 | 🟩 | 🟩 | **5** |
| [`circuit`](#circuit) | Circuit (dual) | 🟥 | 🟩 | 🟩 | 🟩 | 🟨 | 🟨 | 🟩 | **3** |
| [`lustre_limiter`](#lustre_limiter) | Debounce | 🟥 | 🟩 | 🟩 | 🟥 | 🟩 | 🟩 | 🟩 | **3** |

---

## Per-category leaderboards

Because the article spans heterogeneous concerns (a benchmark tool can't replace an actor pool), the global score is **only meaningful within a category**. Per-category leaderboards:

### Observability / profiling

| Rank | Package | Score |
| --- | --- | --- |
| 🥇 | [`spectator`](#spectator) | 9 |
| 🥈 | [`glychee`](#glychee) | 8 |
| 🥉 | [`gleamy_bench`](#gleamy_bench) | 6 |

### Concurrency primitives

| Rank | Package | Score |
| --- | --- | --- |
| 🥇 | [`gleam_otp`](#gleam_otp) | 12 |
| 🥈 | [`glyn`](#glyn) | 7 |
| 🥈 | [`singularity`](#singularity) | 7 |
| 4 | [`cell`](#cell) | 5 |
| 4 | [`reki`](#reki) | 5 |
| 4 | [`glixir`](#glixir) | 5 |
| 7 | [`processgroups`](#processgroups) | 4 |
| 7 | [`eparch`](#eparch) | 4 |
| 9 | [`glubsub`](#glubsub) | 3 |

### Parallel-map / tasks

| Rank | Package | Score |
| --- | --- | --- |
| 🥇 | [`parallel_map`](#parallel_map) | 7 |
| 🥈 | [`taskle`](#taskle) | 5 |
| 🥉 | [`working_actors`](#working_actors) | 3 |
| 4 | [`future`](#future) | 1 |

### Resource / actor pools

| Rank | Package | Score |
| --- | --- | --- |
| 🥇 | [`bath`](#bath) | 7 |
| 🥇 | [`lifeguard`](#lifeguard) | 7 |
| 🥉 | [`crew`](#crew) | 5 |

### Background job queues

| Rank | Package | Score |
| --- | --- | --- |
| 🥇 | [`m25`](#m25) | 8 |
| 🥈 | [`bg_jobs`](#bg_jobs) | 4 *(but won't resolve — see [caution](#bg_jobs))* |

### Rate limiting

| Rank | Package | Score |
| --- | --- | --- |
| 🥇 | [`glimit`](#glimit) | 6 |
| 🥈 | [`speedbump`](#speedbump) | 5 |

### Scheduling

| Rank | Package | Score |
| --- | --- | --- |
| 🥇 | [`clockwork_schedule`](#clockwork_schedule) | 4 |

### Circuit breakers

| Rank | Package | Score |
| --- | --- | --- |
| 🥇 | [`circuit_breaker`](#circuit_breaker) | 5 |
| 🥈 | [`circuit`](#circuit) | 3 |

### Debounce / throttle

Not enough Gleam libraries to rank — Lustre 5.x core is the answer for Lustre apps; [`lustre_limiter`](#lustre_limiter) is superseded; outside Lustre is a gap.

---

**Snapshot:** 2026-05-13. Submit corrections or additions via the repo issue tracker.
