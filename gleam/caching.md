# Caching in Gleam

> [!NOTE]
> **Status:** DRAFT · **Authoring:** AI-assisted, human-reviewed.

So you want to cache something in Gleam — memoise an expensive pure function, keep a hot key/value table in memory between requests, persist a computed result across restarts, share state between BEAM processes, or sit behind Redis. The choices look obvious from a distance and are weirdly fragmented up close.

The Gleam side of caching is **a thin layer of memoisation libraries plus a thick layer of ETS bindings, with no canonical "general-purpose cache with TTL + LRU"** in between. There is no `cachex`-equivalent (Elixir's batteries-included cache). There is no `ttl_cache` package. The most-recommended path is to **pick the right primitive** — memoisation table, ETS binding, persistent_term, Mnesia, Redis client — then layer your own eviction policy on top.

Two flagship facts shape every recommendation in this article:

1. **ETS is a BEAM-only primitive.** Every ETS-backed cache reviewed below works on the Erlang target only. On the JavaScript target the same packages either fall back to a `Map`-on-`globalThis` (when they're written dual-target on purpose, like [`booklet`](#booklet) or [`capuchin_crypt`](#capuchin_crypt)) or simply don't exist.
2. **Two of the most-Google-able packages are broken on new projects.** [`carpenter`](#carpenter-broken) (ETS bindings, ~30★) and [`glemo`](#glemo-broken) (memoisation built on carpenter) both pull in `gleam_erlang ~> 0.24`, whose source references `dynamic.from` — removed in `gleam_stdlib 1.0`. They install but **fail to compile** in a fresh project on current Gleam. Skip them; see the [Disregarded](#disregarded) section for details and replacements.

If you're picking a cache for a specific job, jump to **[When to use what](#when-to-use-what)**.

> [!TIP]
> **Quick recipes — copy-paste starting points for the six most common jobs.**
>
> **1. Memoise a pure recursive function** → [`memo_gleam`](#memo_gleam) (dual-target, self-referential pattern).
>
> ```gleam
> import memo_gleam.{memo}
>
> fn fibonacci(fib: fn(Int) -> Int, n: Int) -> Int {
>   case n {
>     0 | 1 -> 1
>     n -> fib(n - 1) + fib(n - 2)
>   }
> }
>
> pub fn main() {
>   use fib_memo <- memo(fibonacci)
>   fib_memo(50)
> }
> ```
>
> **2. Cache one expensive value for the lifetime of the app** (compiled regex, parsed config) → [`worm`](#worm).
>
> ```gleam
> import gleam/regexp
> import worm
>
> pub fn email_re() -> regexp.Regexp {
>   use <- worm.persist
>   let assert Ok(re) = regexp.from_string("^[^@]+@[^@]+$")
>   re
> }
> ```
>
> **3. Share mutable state between BEAM processes** (no Mnesia required) → [`booklet`](#booklet) (dual-target via ETS-on-BEAM, mutable-ref-on-JS).
>
> ```gleam
> import booklet
>
> pub fn main() {
>   let counter = booklet.new(0)
>   booklet.update(counter, fn(n) { n + 1 })
>   let assert 1 = booklet.get(counter)
> }
> ```
>
> **4. In-process key/value store with size-bounded LRU eviction** → [`immutable_lru`](#immutable_lru) (pure-Gleam, single-process).
>
> ```gleam
> import immutable_lru
>
> pub fn main() {
>   immutable_lru.new(capacity: 10)
>   |> immutable_lru.set("user:1", "alice")
>   |> immutable_lru.set("user:2", "bob")
> }
> ```
>
> **5. Cache HTTP responses behind Wisp** → built into Wisp itself (no separate package needed). Use [`wisp.serve_static`](https://hexdocs.pm/wisp/) which generates `ETag` headers automatically. The dedicated package [`cachmere`](#cachmere-deprecated) has been upstreamed and is no longer maintained.
>
> **6. Distributed cache via Redis** → [`glimr_redis`](#glimr_redis) (Glimr-framework) or [`valkyrie`](https://hex.pm/packages/valkyrie) (general client). For a hot Erlang term cache that's expensive to update and cheap to read, use [`capuchin_crypt`](#capuchin_crypt) (`persistent_term`-backed).
>
> Other jobs — pure memoisation on JS only, GraphQL normalisation, HTTP-data stale-while-revalidate, ETS bag/queue/counter, persistent ETS, Mnesia, memcached — see [When to use what](#when-to-use-what).

## Table of Contents

1. [Summary](#summary)
2. [State of the ecosystem](#state-of-the-ecosystem)
3. [Background: caching primitives across targets](#background-caching-primitives-across-targets)
4. [Research Method](#research-method)
   - [Scoring Dimensions](#scoring-dimensions)
   - [Discovery](#discovery)
5. [Disregarded](#disregarded)
6. [When to use what](#when-to-use-what)
7. [Categories](#categories)
   - [Memoisation](#memoisation) — [memo_gleam](#memo_gleam) · [gemo](#gemo) · [rememo_erlang](#rememo_erlang) · [rememo_javascript](#rememo_javascript) · [worm](#worm)
   - [In-memory caches & state cells](#in-memory-caches--state-cells) — [booklet](#booklet) · [cell](#cell) · [capuchin_crypt](#capuchin_crypt) · [immutable_lru](#immutable_lru) · [keystore](#keystore) · [gacache](#gacache)
   - [ETS bindings (foundations)](#ets-bindings-foundations) — [bravo](#bravo) · [rasa](#rasa) · [dream_ets](#dream_ets) · [mala](#mala) · [shelf](#shelf) · [lamb](#lamb)
   - [Persistent / disk-backed caches](#persistent--disk-backed-caches) — [hardcache](#hardcache) · [trove](#trove) · [shelf](#shelf-ets--dets) · [amnesiac](#amnesiac)
   - [Out-of-process caches](#out-of-process-caches) — [glimr_redis](#glimr_redis) · [glemcached](#glemcached) · [valkyrie](#valkyrie-cross-link)
   - [HTTP / web framework caches](#http--web-framework-caches) — [wisp.serve_static](#wispserve_static) · [cachmere (deprecated)](#cachmere-deprecated)
   - [Domain-shaped caches](#domain-shaped-caches) — [gquery](#gquery) · [squall_cache](#squall_cache) · [lustre element.memo](#lustre-elementmemo)
8. [What's missing](#whats-missing)
9. [Comparison matrix](#comparison-matrix)
10. [Leaderboard](#leaderboard)

## Summary

Snapshot: **2026-05-14**.

| Category | Pick | Notes |
| --- | --- | --- |
| **Memoise a pure function** | [`memo_gleam`](#memo_gleam) (dual-target) · or [`rememo_erlang`](#rememo_erlang) / [`rememo_javascript`](#rememo_javascript) (target-specific) | Skip [`glemo`](#glemo-broken) — broken on new projects. Skip [`gemo`](#gemo) for any non-trivial use — single-commit, 1★. |
| **Cache one value for app lifetime** | [`worm`](#worm) (MIT, 4★, dual-target, "deterministic calculation" framing) | For values you want to share across the whole BEAM node, [`capuchin_crypt`](#capuchin_crypt) (`persistent_term`) is more honest about the trade-offs. |
| **Mutable cell shared across processes** (BEAM) | [`cell`](#cell) (lpil, 25★) | For dual-target, use [`booklet`](#booklet) (ETS on BEAM, mutable-ref on JS). |
| **Size-bounded LRU** (single process) | [`immutable_lru`](#immutable_lru) (MIT, 2★, pure-Gleam) | The only LRU package. **No TTL.** Build your own with `gleam_time` if you need expiry. |
| **General-purpose in-memory cache** (BEAM) | DIY on [`bravo`](#bravo) or [`rasa`](#rasa) — there is **no Gleam `cachex`** | [`gacache`](#gacache) is an actor-based 1★ starter; [`keystore`](#keystore) has TTL but no concurrency story. |
| **ETS bindings — comprehensive** | [`bravo`](#bravo) (30★, Apache-2.0, Erlang-only, USet/OSet/Bag/DBag) | The most-feature-complete ETS wrapper. Latest version 4.0.1 is from June 2024 — stale but works. |
| **ETS — actively maintained, simple shape** | [`rasa`](#rasa) (MIT, 1★, March 2026) · or [`mala`](#mala) for bags · or [`dream_ets`](#dream_ets) | Pick by the table type you need. |
| **Persistent ETS** (ETS + automatic disk flush) | [`shelf`](#shelf) (MIT, 4★, May 2026) | The cleanest persistence story. |
| **Crash-safe embedded KV store** (on-disk) | [`trove`](#trove) (Apache-2.0, 1★, CubDB-inspired, May 2026) | Append-only B+ tree, single-writer/multi-reader, MVCC snapshots. |
| **File-backed cache** (one entry per file) | [`hardcache`](#hardcache) (MIT, 6★, BEAM-only) | Stale (May 2024) but works. |
| **Distributed (Redis-shaped)** | [`glimr_redis`](#glimr_redis) for Glimr apps · [`valkyrie`](https://hex.pm/packages/valkyrie) standalone | Both wrap the same Valkey/KeyDB/Redis/Dragonfly protocol. |
| **Memcached** | [`glemcached`](#glemcached) (1★, stale) | The only Gleam memcached client. |
| **Mnesia** (distributed BEAM database) | [`amnesiac`](#amnesiac) (3★, stale) | Stub; one of the few packages where FFI directly to Erlang `:mnesia` is often easier. |
| **HTTP caching** (web app) | Use Wisp's built-in [`wisp.serve_static`](#wispserve_static) | [`cachmere`](#cachmere-deprecated) is upstreamed and unmaintained. |
| **Stale-while-revalidate** (frontend HTTP data) | [`gquery`](#gquery) (TanStack Query–style, JS-only, May 2026) | Lustre integration is first-class. |
| **GraphQL normalised cache** | [`squall_cache`](#squall_cache) (0★, Apache-2.0, "unstable") | Relay-style; tied to Lustre. |
| **Memoise a Lustre `view`** | `lustre/element.memo` (built into Lustre) | Reference-equality dependency list. Not a third-party package. |

> [!IMPORTANT]
> **The leaderboard ranks within a category, not across.** A 9-score memoisation library cannot persist across restarts; a 3-score Mnesia binding might be the only viable path for the problem you're solving. Use [When to use what](#when-to-use-what) to pick by job; use the [Leaderboard](#leaderboard) to choose **between** competing implementations of the same role.

## State of the ecosystem

Gleam's cache landscape splits into **four shapes**, each with different maturity:

**Memoisation (mature plurality).** Five viable packages (`memo_gleam`, `gemo`, `rememo_erlang`, `rememo_javascript`, `worm`), all small (≤9★), all functional, none with deep upstream usage. The two strongest patterns are:
- **Self-referential** (`memo_gleam`) — your function takes the memoised version of itself as a parameter. Elegant for recursive functions.
- **Explicit cache handle** (`rememo_*`) — you create a cache up front and pass it through. Closer to imperative.

The user-flagged "bad" package [`glemo`](#glemo-broken) sits here and is genuinely broken (build error on any fresh project — see the Disregarded section).

**ETS bindings (mature foundation, fragmented top layer).** ETS is the BEAM's gold-standard in-memory key/value store, and Gleam has **six** wrappers of it ([`bravo`](#bravo), [`rasa`](#rasa), [`dream_ets`](#dream_ets), [`mala`](#mala), [`shelf`](#shelf), [`lamb`](https://hex.pm/packages/lamb)) plus the broken [`carpenter`](#carpenter-broken). [`bravo`](#bravo) leads on feature completeness; [`rasa`](#rasa) on recency. The dual-target [`booklet`](#booklet) wraps ETS on BEAM and a mutable ref on JS — the closest thing to a portable "shared cell."

**General-purpose caches (thin and gappy).** There is **no Gleam `cachex`**. The closest options are [`gacache`](#gacache) (actor, 1★, stale, Erlang-only) and [`keystore`](#keystore) (in-memory with TTL but no concurrency story). For a real production cache with TTL + size limit + eviction, you assemble it yourself on top of [`bravo`](#bravo) or [`rasa`](#rasa), or you reach for Redis via [`valkyrie`](https://hex.pm/packages/valkyrie).

**Specialised caches (one of each).** Domain-shaped caches exist as single-purpose packages: [`gquery`](#gquery) for HTTP-data stale-while-revalidate, [`squall_cache`](#squall_cache) for Relay-style GraphQL, `lustre/element.memo` for vdom memoisation, [`hardcache`](#hardcache) for file-backed, [`shelf`](#shelf) for ETS+DETS persistence, [`trove`](#trove) for embedded crash-safe KV. Each is the only Gleam option in its slot.

**The gaps that hurt most:**

- **No TTL primitive** anywhere except [`keystore`](#keystore) (which has no concurrency story) and [`glimr_redis`](#glimr_redis) (which requires Redis). Every other in-process cache requires you to bring your own expiry.
- **No LRU on ETS.** [`immutable_lru`](#immutable_lru) exists but is pure-Gleam, single-process, and immutable (re-creates the cache on each `set`).
- **No size-bounded cache backed by a concurrent table.** You'd write this yourself by composing [`bravo`](#bravo) tables with [`gleam_time`](https://hex.pm/packages/gleam_time)-based expiry.
- **No `nebulex` / `cachex` / multi-tier cache** (RAM + disk + Redis cascade).

## Background: caching primitives across targets

A short tour of what's *under* the Gleam packages. Most of the design decisions you'll make depend on knowing these.

### Erlang target — ETS, persistent_term, Mnesia, DETS

**[ETS (Erlang Term Storage)](https://www.erlang.org/doc/man/ets.html)** is the BEAM's built-in in-memory, mutable, concurrent table store. It's the foundation for every serious caching library on Erlang/Elixir (Cachex, Nebulex, all of Phoenix's hot paths).

Key trade-offs to know:

- **Tables are not garbage collected** — you have to drop them yourself. An ETS table outlives the process that created it unless that process owned it.
- **Process-owned (default) vs `:named_table`** — by default a table is referenced by an opaque handle; with `:named_table` it's referenced by an atom name globally.
- **Access control: `public` / `protected` / `private`** — `public` lets any process read/write; `protected` (default) lets any process read but only the owner write; `private` is owner-only.
- **Table type: `set` / `ordered_set` / `bag` / `duplicate_bag`** — `set` enforces unique keys, `ordered_set` adds sort-order, `bag` allows multiple distinct values per key, `duplicate_bag` allows verbatim duplicates.
- **No TTL natively.** You implement expiry yourself, usually via a periodic cleanup process scanning timestamps stored alongside values.
- **No LRU natively.** Same — you build the eviction policy.
- **`read_concurrency` / `write_concurrency` flags** — opt-in performance tuning for hot tables.
- **Cost: memory only.** All values live in BEAM memory until dropped. There is no automatic spill-to-disk.

**[`persistent_term`](https://www.erlang.org/doc/apps/erts/persistent_term.html)** is a different primitive: a global term store optimised for *cheap reads and expensive writes*. Reading is O(1) and as fast as a function call (no copying); writing triggers a global GC. **Use only for things that never change after init** — compiled regexes, config, lookup tables. The package [`capuchin_crypt`](#capuchin_crypt) wraps this.

**[Mnesia](https://www.erlang.org/doc/man/mnesia.html)** is the BEAM's distributed transactional database. Supports RAM-only, disk-only, or hybrid tables; transactions across multiple tables; replication. The Gleam wrapper [`amnesiac`](#amnesiac) is a stub — for any real Mnesia work, FFI directly to `:mnesia` is usually easier.

**[DETS](https://www.erlang.org/doc/man/dets.html)** is the on-disk sibling of ETS — same API shape, persistent. Slower than ETS; smaller in scope than Mnesia. Wrapped by [`shelf`](#shelf) (ETS-with-DETS-flush) and [`slate`](https://hex.pm/packages/slate).

### JavaScript target — Map, WeakMap, Cache API, none-of-the-above

On the JS target Gleam compiles to plain JavaScript, so any cache is one of:

- **`Map` on `globalThis`** — what [`booklet`](#booklet) does on JS, what [`capuchin_crypt`](#capuchin_crypt) does on JS, what [`memo_gleam`](#memo_gleam) does for memoisation. Lives for the lifetime of the module/process.
- **`WeakMap`** — not currently wrapped by any reviewed package; useful for memoisation keyed by object identity (no Gleam package surfaces this — you'd write the FFI).
- **Browser [`Cache` API](https://developer.mozilla.org/en-US/docs/Web/API/Cache)** — the Service Worker / `fetch`-response cache. No Gleam package wraps this; bind directly via `@external(javascript, ...)` if you need it.
- **No ETS, no `persistent_term`, no Mnesia, no DETS.** Anything written against these primitives is **BEAM-only**.

### Implications for dual-target

A package that wants to work on both targets has to either:

1. **Use FFI on both sides** to opposing primitives — what [`booklet`](#booklet) (ETS / mutable-ref), [`capuchin_crypt`](#capuchin_crypt) (`persistent_term` / module-level `Map`), and [`worm`](#worm) (`persistent_term` — but actually erlang-only despite the dual-target shape; double check) do.
2. **Stay pure-Gleam** — what [`memo_gleam`](#memo_gleam), [`gemo`](#gemo), and [`immutable_lru`](#immutable_lru) do, paying the cost that the cache is per-process (per-module on JS), not shared between BEAM processes.

The decision matrix:

| Need | BEAM only | Dual-target | JS only |
| --- | --- | --- | --- |
| Memoise a pure function | [`rememo_erlang`](#rememo_erlang) | [`memo_gleam`](#memo_gleam), [`gemo`](#gemo) | [`rememo_javascript`](#rememo_javascript) |
| Shared mutable cell | [`cell`](#cell), [`bravo`](#bravo) | [`booklet`](#booklet) | *(any plain Gleam ref)* |
| Cache one value | [`capuchin_crypt`](#capuchin_crypt) | [`worm`](#worm), [`capuchin_crypt`](#capuchin_crypt) | — |
| LRU | — (use DIY on ETS) | [`immutable_lru`](#immutable_lru) (pure Gleam, no concurrency) | [`immutable_lru`](#immutable_lru) |
| Distributed | [`glimr_redis`](#glimr_redis), [`valkyrie`](https://hex.pm/packages/valkyrie), [`amnesiac`](#amnesiac) | — | — |

## Research Method

### Scoring Dimensions

Same 7-dimension rubric as [databases.md#scoring-dimensions](databases.md#scoring-dimensions). Recap:

- **Stars:** 🟩🟩 ≥200★, 🟩 ≥100★, 🟨 ≥10★, 🟥 <10★. *Caching packages skew tiny — almost everything lands in 🟥.*
- **License:** 🟩 permissive (MIT/Apache/BSD), 🟥 viral (GPL/LGPL/AGPL) or missing.
- **Gleam compat:** `gleam_stdlib` constraint format. 🟩 range, 🟥 `~>` pin or missing.
- **Maintenance:** max(recency, responsiveness). 🟩🟩 <1 mo / clean tracker, 🟩 <6 mo, 🟨 <1 yr, 🟥 older.
- **Age:** 🟩🟩 ≥3 yrs, 🟩 ≥1 yr, 🟨 ≥3 mo, 🟥 <3 mo.
- **README maturity:** 🟩🟩 full guide + examples, 🟩 clear tagline + usage, 🟥 minimal/template.
- **Idiomaticity:** 🟩 typed/explicit, 🟥 magic or unsafe.

**Leaderboard:** 🟥 = −1, 🟨 = 0, 🟩 = 1, 🟩🟩 = 2. Sum of 7 dims, max 13.

### Discovery

~25 search terms run against the [Gleam packages registry](https://packages.gleam.run/). Cross-checked against [hex.pm](https://hex.pm/packages?_search=&_sort=recent_downloads) and GitHub `language:gleam` searches.

**Cache-keyword queries:**
- [cache](https://packages.gleam.run/?search=cache) · [memo](https://packages.gleam.run/?search=memo) · [memoization](https://packages.gleam.run/?search=memoization) · [memoize](https://packages.gleam.run/?search=memoize) · [lru](https://packages.gleam.run/?search=lru) · [ttl](https://packages.gleam.run/?search=ttl) — *no results for `ttl`*

**Storage / primitive keywords:**
- [ets](https://packages.gleam.run/?search=ets) · [dets](https://packages.gleam.run/?search=dets) · [mnesia](https://packages.gleam.run/?search=mnesia) · [persistent](https://packages.gleam.run/?search=persistent) · [store](https://packages.gleam.run/?search=store) · [kv](https://packages.gleam.run/?search=kv) · [in_memory](https://packages.gleam.run/?search=in_memory) · [lazy](https://packages.gleam.run/?search=lazy)

**Out-of-process keywords:**
- [redis](https://packages.gleam.run/?search=redis) · [memcached](https://packages.gleam.run/?search=memcached) · [valkey](https://packages.gleam.run/?search=valkey) · [keyvalue](https://packages.gleam.run/?search=keyvalue) — *no results*

**GitHub repository searches:**
- [`language:gleam cache`](https://github.com/search?q=language%3Agleam+cache&type=repositories) · [`language:gleam memo`](https://github.com/search?q=language%3Agleam+memo&type=repositories) · [`language:gleam ets`](https://github.com/search?q=language%3Agleam+ets&type=repositories)

GitHub `language:gleam` surfaced a few experimental, in-progress, and educational repos (`monkey-cache`, `banana_cache`, `kvstore`, `concurrent-dict`, `glets`) not on Hex. None are production-targeted; mentioned only in [Disregarded](#disregarded).

## Disregarded

Listed up-front so reviewers see "this corner has been considered" before per-category content. **The first two are the user-flagged "bad" packages** — verified with reproduced build errors on fresh projects.

| Package | Reason disregarded |
| --- | --- |
| <a id="carpenter-broken"></a>[`carpenter`](https://hex.pm/packages/carpenter) | **Broken on new projects.** ETS bindings, 30★, MPL-2.0, last commit **2024-04-08** (over a year stale). Pins `gleam_erlang ~> 0.24`, which pulls in `gleam_erlang 0.34.0`, whose `process.gleam` calls `dynamic.from/1`. That function was **removed in `gleam_stdlib 1.0.0`**. Reproduced in a fresh `gleam new` project: install succeeds, `gleam build` fails with `The module gleam/dynamic does not have a from value`. **Replacements:** [`bravo`](#bravo) (more comprehensive), [`rasa`](#rasa) (smaller, recent), [`dream_ets`](#dream_ets) (TrustBound), [`mala`](#mala) (for bags). |
| <a id="glemo-broken"></a>[`glemo`](https://hex.pm/packages/glemo) | **Broken on new projects** — transitively, via the same `carpenter` chain. `glemo` depends on `carpenter >= 0.3.1`; resolving the manifest pulls in the same broken `gleam_erlang 0.34.0`. Same exact build error. Reproduced. **Replacements:** [`rememo_erlang`](#rememo_erlang) (closest API match — explicit cache handle), [`memo_gleam`](#memo_gleam) (self-referential pattern, dual-target), [`gemo`](#gemo) (`use`-style, dual-target, single-commit). |
| [`gts`](https://hex.pm/packages/gts) | **Predecessor of `carpenter`.** 3 years stale, last commit pre-2023. Same expected breakage; carpenter forked it specifically to update. Skip. |
| [`rememo`](https://hex.pm/packages/rememo) | **Marked retired on Hex.** Author split it into [`rememo_erlang`](#rememo_erlang) and [`rememo_javascript`](#rememo_javascript). Use one of those. |
| [`functx`](https://hex.pm/packages/functx) | **GitHub repo archived 2024-12-29** by the author. Was a "tiny Gleam caching Context" but the author redirected to `klubok-gleam`, which turned out to be a *testing/mocking* library, not a cache. The caching-context shape isn't really replicated by anything in the current ecosystem; if you need it, port the pattern by hand. |
| [`carpenter` predecessors and forks](https://hex.pm/packages?_search=ets) | The chain `gts` → `carpenter` was a community attempt to maintain ETS bindings as the language evolved. Both are now stale; the live maintained options are `bravo`, `rasa`, `dream_ets`, `mala`, `shelf`. |
| [`directories`](https://hex.pm/packages/directories) | Looks up XDG-spec **cache directory paths** (`$XDG_CACHE_HOME`, `~/Library/Caches`, etc.) — useful as a companion when *implementing* a file-backed cache, but is not itself a cache. Surfaces under `cache` searches. |
| [`store`](https://hex.pm/packages/store) | "Stores and subscriptions" — Lustre-style reactive state store, not a cache in the eviction/expiry sense. Listed because it surfaces under `store` searches. |
| [`mxpak`](https://github.com/GG-O-BP/mxpak) | CLI package manager with internal "content-addressable caching" — uses caching, isn't a caching library. |
| [`monkey-cache`](https://github.com/igorabreu29/monkey-cache), [`banana_cache`](https://github.com/Victor-Palha/banana_cache) | Personal learning projects, not published to Hex, no maintenance commitment. |
| [`kvstore`](https://github.com/mweatherley/kvstore), [`glets`](https://github.com/i-am-tanni/glets), [`concurrent-dict`](https://github.com/jrstrunk/concurrent-dict) | Personal ETS-shape experiments. Not on Hex; use one of the published bindings. |
| [`amnesiac`](https://github.com/VioletBuse/amnesiac) | **Stub.** "Gleam bindings to mnesia," 3★, README is the project template ("`gleam run`, `gleam test`, `gleam shell`") with no real description. Last commit 2024-06-18. Listed in [Categories](#amnesiac) for completeness as the only Mnesia option, but expect to FFI to `:mnesia` directly for any real work. |
| [`kvite`](https://hex.pm/packages/kvite) | "A simple KV store in SQLite" — listed in [databases.md](databases.md), not a cache as such. |
| [`storail`](https://hex.pm/packages/storail) | "Simple on-disc JSON based data store" — overlaps with file-backed cache but the framing is "data store" not "cache". Listed in [databases.md](databases.md). |
| [`git_store`](https://hex.pm/packages/git_store) | Library for storing files in git forge repos — not a cache. Surfaces under `store`. |

## When to use what

| You want to… | Use | Notes |
| --- | --- | --- |
| **Memoise a pure recursive function** (dual-target) | [`memo_gleam`](#memo_gleam) | Self-referential pattern; your function receives its memoised version as the first parameter. Cleanest for Fibonacci-shaped problems. |
| **Memoise with an explicit cache handle you pass around** | [`rememo_erlang`](#rememo_erlang) or [`rememo_javascript`](#rememo_javascript) | Pick by target; the `rememo` umbrella is retired in favour of these two siblings. |
| **Memoise a `use`-style block** | [`gemo`](#gemo) | `use <- gemo.memoize1(fn_name, arg)` pattern. Dual-target. 1★ — caveat. |
| **Cache one value for the application lifetime** (compiled regex / parsed config / startup table) | [`worm`](#worm) | "Deterministic calculations." Pure-Gleam wrapper around BEAM-internal state. README is unusually honest about *not* using it when you don't need it. |
| **Same, with explicit `persistent_term` semantics** | [`capuchin_crypt`](#capuchin_crypt) | Spells out the global-GC-on-write trade-off. Dual-target. |
| **Mutable cell shared across BEAM processes** | [`cell`](#cell) | Pure ETS-backed mutable refs. BEAM-only. |
| **Same, dual-target** | [`booklet`](#booklet) | ETS on BEAM, mutable-ref on JS. Atomic compare-and-swap on both sides. |
| **In-process LRU with size limit** | [`immutable_lru`](#immutable_lru) | Pure-Gleam, immutable (returns a new cache on every `set`). Single-process. No TTL. |
| **In-memory key/value cache with TTL** | [`keystore`](#keystore) | Single-process, BEAM-target. No concurrency story — fine for per-request caches, not for shared state. |
| **Actor-based concurrent cache** (BEAM) | [`gacache`](#gacache) | 1★, stale (Jan 2025); use as a starter rather than a battle-tested library. |
| **Anything resembling Elixir's `cachex` or `nebulex`** | *(no Gleam package — DIY on [`bravo`](#bravo) or [`rasa`](#rasa))* | Or FFI to Elixir Cachex directly. |
| **Persistent ETS** (in-memory speed + automatic disk flush) | [`shelf`](#shelf) | ETS + DETS combination. The cleanest persistence story for cache-shaped workloads. |
| **Crash-safe embedded KV store** (on-disk, ACID-ish) | [`trove`](#trove) | CubDB-inspired append-only B+ tree with MVCC snapshots. Single-writer, multi-reader. |
| **File-per-key cache on disk** | [`hardcache`](#hardcache) | Simple `try_get`/`try_set` on filesystem. Useful for build-tool–style caches. |
| **Mnesia (distributed BEAM database)** | [`amnesiac`](#amnesiac) — but expect to FFI to `:mnesia` for anything real | The Gleam binding is a stub. |
| **Distributed cache via Redis-compatible server** | [`valkyrie`](https://hex.pm/packages/valkyrie) (standalone) or [`glimr_redis`](#glimr_redis) (Glimr-framework) | Both work with Redis / Valkey / KeyDB / Dragonfly. |
| **Memcached** | [`glemcached`](#glemcached) | Pure-Gleam client. 1★, stale. |
| **HTTP response caching for a web app** | Built into Wisp — [`wisp.serve_static`](#wispserve_static) generates ETags automatically | The dedicated [`cachmere`](#cachmere-deprecated) package has been upstreamed and is no longer maintained. |
| **Stale-while-revalidate frontend data cache** (TanStack Query–shape) | [`gquery`](#gquery) | Lustre integration first-class. JS-only. |
| **Normalised GraphQL cache** (Relay-shape) | [`squall_cache`](#squall_cache) | Tied to Lustre. README flags it as "unstable, API will change." |
| **Memoise a Lustre `view` re-render** | `lustre/element.memo` (built-in) | Reference-equality dependency list. Not a third-party package. |
| **Build your own cache on top of ETS** | [`bravo`](#bravo) for the comprehensive feature surface · [`rasa`](#rasa) for active maintenance · [`mala`](#mala) for bags · [`dream_ets`](#dream_ets) as a TrustBound alternative | Pick by feature need. |

> [!IMPORTANT]
> **Three rules to take with you:**
> 1. **Don't `gleam add carpenter` or `gleam add glemo`.** Both fail to compile on fresh projects due to a `gleam_stdlib 1.0` breaking change combined with their `gleam_erlang ~> 0.24` pin. See [Disregarded](#disregarded) for the diagnosis and the replacement table.
> 2. **There is no general-purpose TTL+LRU cache in Gleam.** If you need both, plan on either (a) composing [`bravo`](#bravo) + [`gleam_time`](https://hex.pm/packages/gleam_time) yourself, or (b) reaching for Redis via [`valkyrie`](https://hex.pm/packages/valkyrie), or (c) FFI to Elixir Cachex.
> 3. **ETS is BEAM-only.** Any package whose description says "ETS" or "uses Erlang Term Storage" will not work on the JavaScript target. The dual-target packages ([`booklet`](#booklet), [`capuchin_crypt`](#capuchin_crypt), [`memo_gleam`](#memo_gleam)) explicitly fall back to JS-side primitives — read their READMEs to see the fallback semantics.

## Categories

### Memoisation

Five packages, three patterns, two targets. The split is:

| Pattern | BEAM | JS | Dual |
| --- | --- | --- | --- |
| **Self-referential** (fn receives its own memoised version) | — | — | [`memo_gleam`](#memo_gleam) |
| **Explicit cache handle** (create, pass around) | [`rememo_erlang`](#rememo_erlang) | [`rememo_javascript`](#rememo_javascript) | *(was `rememo`, retired)* |
| **`use`-callback** | — | — | [`gemo`](#gemo) |
| **One-shot persist** (cache the *first call*, return forever) | — | — | [`worm`](#worm) |

(The broken [`glemo`](#glemo-broken) sat in the "explicit cache handle" slot and is documented in [Disregarded](#disregarded).)

| Criterion | [memo_gleam](#memo_gleam) | [gemo](#gemo) | [rememo_erlang](#rememo_erlang) | [rememo_javascript](#rememo_javascript) | [worm](#worm) |
| --- | --- | --- | --- | --- | --- |
| Pattern | Self-referential | `use`-callback | Explicit handle | Explicit handle | One-shot persist |
| Stars | 0 · 🟥 | 1 · 🟥 | 0 · 🟥 | 0 · 🟥 | 4 · 🟥 |
| License | MIT · 🟩 | MIT · 🟩 | (none) · 🟥 | (none) · 🟥 | MIT · 🟩 |
| Target | ☎️ BEAM + 📜 JS | ☎️ BEAM + 📜 JS | ☎️ BEAM | 📜 JS | ☎️ BEAM + 📜 JS |
| Gleam compat | `>= 1.0 and < 2.0` · 🟩 | (range) · 🟩 | (range) · 🟩 | (range) · 🟩 | `>= 0.34 and < 2.0` · 🟩 |
| Maintenance | 🟩🟩 (last commit 2026-05-08, 6 days before snapshot, 0 open) | 🟥 (last commit 2024-12-13, 0 open) | 🟩🟩 (last commit 2026-03-17, 1 open) | 🟩🟩 (last commit 2026-03-17, 0 open) | 🟨 (last commit 2024-10-10, 0 open) |
| Age | 🟥 (created May 2026; single commit) | 🟩 (Dec 2024) | 🟨 (Mar 2026) | 🟨 (Mar 2026) | 🟩 (Oct 2024 → ~1.5 yrs) |
| README | 🟩 (clear tagline + Fibonacci example) | 🟥 (terse — just install + Fibonacci snippet) | 🟩 (clear tagline + install + Fibonacci) | 🟩 (clear tagline + install + Fibonacci) | 🟩 (clear; "not the best solution for many situations" disclaimer) |
| Idiomaticity | 🟩 (`use`-style, typed) | 🟩 (`use`-style, typed) | 🟩 (typed) | 🟩 (typed) | 🟩 (`use`-style, typed) |

#### memo_gleam
[hex](https://hex.pm/packages/memo_gleam) · [repo](https://github.com/aDifferentJT/memo_gleam) · 0★

The **self-referential** memoisation pattern: your function takes the memoised version of itself as a parameter, and inside the body you call **that** parameter rather than recursing directly. The library handles the cache invisibly.

```gleam
import memo_gleam.{memo}

fn fibonacci(fib: fn(Int) -> Int, n: Int) -> Int {
  case n {
    0 | 1 -> 1
    n -> fib(n - 1) + fib(n - 2)
  }
}

pub fn main() {
  use fib_memo <- memo(fibonacci)
  fib_memo(50)  // ~linear time instead of exponential
}
```

Dual-target via plain Gleam on both sides — no ETS, no FFI, the cache is a per-process `dict`. Brand-new (single commit, May 2026) — no track record yet — but the code is small and the pattern is the cleanest in the ecosystem for recursive memoisation. MIT, README is a tight tagline + working example.

#### gemo
[hex](https://hex.pm/packages/gemo) · [repo](https://github.com/lv37/gemo) · 1★

The **`use`-callback** pattern. Inside any function, write `use <- gemo.memoize1(fn_name, arg)` and the rest of the function body becomes the cache miss path.

```gleam
import bool
import gemo

fn fib(n) {
  use <- gemo.memoize1(fib, n)
  use <- bool.guard(n <= 1, n)
  fib(n - 1) + fib(n - 2)
}
```

Stale (last commit Dec 2024), single commit, 1★ — caveat for production. The pattern is elegant; the package is undertested. README is the bare minimum — install + Fibonacci snippet, no API documentation.

#### rememo_erlang
[hex](https://hex.pm/packages/rememo_erlang) · [repo](https://github.com/hunkyjimpjorps/rememo_erlang) · 0★

The **explicit cache handle** pattern, BEAM-target. Create a cache up front, pass it through your call sites, and `memoize` against it.

```gleam
import rememo/memo

pub fn fib(n: Int) -> Int {
  use cache <- memo.create()
  fib_with_cache(cache, n)
}

fn fib_with_cache(cache, n) {
  use <- memo.memoize(cache, n)
  case n {
    0 | 1 -> n
    _ -> fib_with_cache(cache, n - 1) + fib_with_cache(cache, n - 2)
  }
}
```

The `rememo_erlang` / `rememo_javascript` split exists because the unified `rememo` package was retired (split per target after the author found cross-target gotchas weren't worth the dual-target promise). The umbrella package on Hex is marked retired and redirects you here.

#### rememo_javascript
[hex](https://hex.pm/packages/rememo_javascript) · [repo](https://github.com/hunkyjimpjorps/rememo_javascript) · 0★

Same API as `rememo_erlang`, JavaScript target. The cache is a JS `Map` rather than ETS. Sibling to `rememo_erlang`; pick by target.

#### worm
[hex](https://hex.pm/packages/worm) · [repo](https://github.com/mscharley/gleam-worm) · 4★ · [🥈](#leaderboard)

The **one-shot persist** pattern: a `worm.persist` block computes a value the first time it's called and returns the same cached value forever afterwards. Designed for "deterministic calculations" — compiled regex, parsed config, lookup tables — that you want to compute once at the use site rather than at boot.

```gleam
import gleam/regexp
import worm

pub fn email_regex() -> regexp.Regexp {
  use <- worm.persist
  let assert Ok(re) = regexp.from_string("^[^@]+@[^@]+$")
  re
}
```

3,071 downloads in the last 30 days — by far the most-installed of the memoisation packages, a sign that the "cache one expensive value" use case is more common than the recursive-memoisation flavour these other libs target. MIT, dual-target (`@external` clauses for both Erlang and JavaScript — Erlang uses `persistent_term`, JS uses a module-level cache via `worm_ffi.mjs`). README explicitly tells you to "read the documentation before using this library as it is not the best solution for many situations." Stale upstream (last commit Oct 2024) but the surface is small and the bus-factor risk is manageable.

### In-memory caches & state cells

Five published packages plus the user-flagged broken [`glemo`](#glemo-broken). The category overlaps with [ETS bindings (foundations)](#ets-bindings-foundations) — the difference is shape: an ETS binding *is* a table API, a "cache" or "state cell" wraps that table with a higher-level pattern (single value, key/value with TTL, LRU eviction).

| Criterion | [booklet](#booklet) | [cell](#cell) | [capuchin_crypt](#capuchin_crypt) | [immutable_lru](#immutable_lru) | [keystore](#keystore) | [gacache](#gacache) |
| --- | --- | --- | --- | --- | --- | --- |
| Shape | Mutable cell (compare-and-swap) | Typed mutable cell (ETS) | One-value persistent_term | Size-bounded LRU map | Map with per-key TTL | Actor with key/value API |
| Stars | (GitLab, n/a) · ⬜ | 25 · 🟨 | 0 · 🟥 | 2 · 🟥 | 0 · 🟥 | 1 · 🟥 |
| License | BSD-3-Clause · 🟩 | (none) · 🟥 | Apache-2.0 · 🟩 | MIT · 🟩 | MIT · 🟩 | Apache-2.0 · 🟩 |
| Target | ☎️ BEAM + 📜 JS | ☎️ BEAM | ☎️ BEAM + 📜 JS | ☎️ BEAM + 📜 JS | ☎️ BEAM + 📜 JS | ☎️ BEAM |
| Gleam compat | (range) · 🟩 | (range) · 🟩 | `>= 0.44 and < 2.0` · 🟩 | (range) · 🟩 | (range) · 🟩 | (range) · 🟩 |
| Maintenance | 🟩 (last release Aug 2025) | 🟩 (last commit 2025-10-07) | 🟩🟩 (last commit 2026-05-01) | 🟥 (last commit 2024-07-19) | 🟨 (last commit 2025-09-11) | 🟥 (last commit 2025-01-06) |
| Age | 🟨 (Aug 2025) | 🟩 (>1 yr) | 🟩 (Apr 2026; thinking through the package shape took the author a while) | 🟩 (>1 yr) | 🟨 (Sep 2025) | 🟩 (>1 yr) |
| README | 🟩 (clear; CAS + dual-target notes) | 🟩 (clear; honest about manual cleanup) | 🟩🟩 (full guide + "you probably don't need this" warning) | 🟩 (tagline + Fibonacci-style example) | 🟩 (TTL example + roadmap notes) | 🟩 (start/set/get/keys/stop) |
| Idiomaticity | 🟩 (typed cell + atomic) | 🟩 (typed cell + table) | 🟩 (typed value, breaks immutability honestly) | 🟩 (typed, immutable) | 🟩 (typed) | 🟩 (typed actor) |

#### booklet
[hex](https://hex.pm/packages/booklet) · [repo (GitLab)](https://gitlab.com/arkandos/booklet) · [hexdocs](https://hexdocs.pm/booklet/)

**A simple in-memory cache using ETS tables or mutable references.** The package's tagline; what it actually is: a **dual-target atomic mutable cell**. On BEAM, the value lives in a managed ETS table behind atomic compare-and-swap. On JavaScript, the value lives in a mutable reference. Same Gleam API on both sides.

```gleam
import booklet

pub fn main() {
  let counter = booklet.new(0)
  booklet.update(counter, fn(n) { n + 1 })  // atomic
  let assert 1 = booklet.get(counter)
}
```

The README is explicit: **"Booklets are never automatically deleted or garbage collected."** Call `booklet.erase` to clean up. Designed for thread-safe, atomic updates and fast concurrent reads of values that persist for program lifetime. BSD-3-Clause, hosted on GitLab (so no GitHub star count); the package owner is `yoshi-monster` on Hex. Maintained alongside the [`arkandos`](https://gitlab.com/arkandos) family of small Gleam utility packages.

#### cell
[hex](https://hex.pm/packages/cell) · [repo](https://github.com/lpil/cell) · 25★

**Mutable references that can be concurrently accessed, based on ETS tables.** The lpil-flavoured BEAM-only counterpart to `booklet`. Adds **typed cells in a shared table**: each cell carries a distinct type, all cells live in one ETS table, no cross-process locking.

```gleam
import cell

pub fn main() {
  let assert Ok(table) = cell.new_table()
  let counter = cell.new(table, 0)
  cell.write(counter, 1)
  let assert Ok(1) = cell.read(counter)
}
```

Intended for **cached / precomputed values accessed by multiple processes**, not for mutation-driven algorithms. Manual memory management (no automatic GC — call `cell.drop(table)` yourself). 25★ — high for a small package, reflects the lpil-and-Hayleigh "house brand" attention. License field is empty in `gleam.toml` (🟥 in the matrix above) — the project page doesn't surface one.

#### capuchin_crypt
[hex](https://hex.pm/packages/capuchin_crypt) · [repo](https://github.com/halostatue/capuchin_crypt) · 0★

**"A persistent cache for Gleam. Expensive to update, cheap to read."** Wraps Erlang's [`persistent_term`](https://www.erlang.org/doc/apps/erts/persistent_term.html) on BEAM and a module-level `Map` on JS. The README is unusually direct about when *not* to use it:

> If you think you need this, think again — you probably don't. As the warning at the top of `persistent_term` says: "Persistent terms is an advanced feature and is not a general replacement for ETS tables. Before using persistent terms, make sure to fully understand the consequence to system performance when updating or deleting persistent terms."

```gleam
import capuchin_crypt

pub fn main() {
  capuchin_crypt.put(
    "compiled_regex:email",
    expensive_compile(),
  )
  capuchin_crypt.get("compiled_regex:email")
}
```

The right use is for values **never updated after init** — compiled regex, parsed config, the result of expensive startup work. The wrong use is anything with frequent writes, because every `persistent_term:put/2` triggers a global GC pass for every process referencing the old value. Apache-2.0, well-maintained (last commit 2026-05-01), 0★ but recent (April 2026 release).

#### immutable_lru
[hex](https://hex.pm/packages/immutable_lru) · [repo](https://github.com/chrstntdd/immutable_lru) · 2★

**An immutable, size-bounded LRU cache** implemented in pure Gleam. The only LRU package in the ecosystem. Every operation returns a new cache value (functional style — no mutation), so the cache fits naturally inside a Lustre/redraw model.

```gleam
import immutable_lru

pub fn main() {
  let c =
    immutable_lru.new(10)
    |> immutable_lru.set("1", ["first"])
    |> immutable_lru.set("2", ["second"])
    |> immutable_lru.set("3", ["third"])

  immutable_lru.get(c, "3")
}
```

Single-process; no shared-memory story. **No TTL** — eviction is purely by capacity + access recency. Pure-Gleam dual-target. MIT, 8 commits total, stale (Jul 2024) but the implementation is small enough that the bus-factor risk is low.

#### keystore
[hex](https://hex.pm/packages/keystore) · [repo](https://github.com/Caleb-o/keystore) · 0★

**An in-memory data-structure key/value store similar to Redis.** The closest Gleam package to a "cache with TTL" — provides `set`, `expire`, and `new` in a single-process map. No concurrency story (no actor wrapping, no ETS); fine for per-request caches inside a single Gleam process, **not** for state shared across a Wisp request handler.

```gleam
import keystore

pub fn main() {
  keystore.new()
  |> keystore.set("name", "bob")
  |> keystore.expire("name", 5)  // 5 seconds
}
```

The roadmap in the README mentions encoding/decoding options and alternative expiration cleanup mechanisms — both unimplemented. MIT, dual-target. 4 commits total — preview-quality.

#### gacache
[hex](https://hex.pm/packages/gacache) · [repo](https://github.com/BradBot1/gleam_gacache) · 1★

**A simple actor-based cache for Erlang environments.** Wraps a `gleam_otp` actor around a key/value map, exposing `start`, `set`, `get`, `keys`, `stop`. Concurrency-safe via the actor mailbox.

```gleam
import gacache

pub fn main() {
  let assert Ok(cache) = gacache.start()
  gacache.set(cache, "key", "value")
  let assert Ok("value") = gacache.get(cache, "key")
  gacache.stop(cache)
}
```

The closest Gleam package to an Elixir Cachex *shape* — but vastly less feature-complete (no TTL, no LRU, no multi-table, no streaming, no telemetry). Apache-2.0, BEAM-only, 4 commits total, last commit Jan 2025 — preview-quality but functional.

### ETS bindings (foundations)

Six maintained ETS wrappers — the foundation for any serious BEAM-side caching. None of them is a "cache" in the eviction/TTL sense; they're the tables you build a cache on top of. The user-flagged [`carpenter`](#carpenter-broken) belongs here logically but is broken (see [Disregarded](#disregarded)).

| Criterion | [bravo](#bravo) | [rasa](#rasa) | [dream_ets](#dream_ets) | [mala](#mala) | [shelf](#shelf) | [lamb](#lamb) |
| --- | --- | --- | --- | --- | --- | --- |
| Scope | Comprehensive (USet/OSet/Bag/DBag) | Typed tables + queues + counters | Type-safe ETS | Bags (multi-value per key) | ETS + DETS persistence | ETS + match specs |
| Stars | 30 · 🟨 | 1 · 🟥 | 44 · 🟨 (parent monorepo) | 8 · 🟥 | 4 · 🟥 | (unknown — sparse repo) · ⬜ |
| License | Apache-2.0 · 🟩 | MIT · 🟩 | MIT · 🟩 | (none) · 🟥 | MIT · 🟩 | (range) · 🟩 |
| Target | ☎️ BEAM (`target = "erlang"`) | ☎️ BEAM (`target = "erlang"`) | ☎️ BEAM | ☎️ BEAM | ☎️ BEAM (`target = "erlang"`) | ☎️ BEAM |
| Gleam compat | `>= 0.58 and < 1.0` · 🟥 | `>= 0.44 and < 2.0` · 🟩 | (range) · 🟩 | (range) · 🟩 | `>= 0.48 and < 2.0` · 🟩 | (range) · 🟩 |
| Maintenance | 🟥 (last commit 2026-02-28, 2 open) | 🟩🟩 (last commit 2026-03-21, 0 open) | 🟩🟩 (last commit 2026-03-28, parent has 3 open) | 🟩🟩 (last commit 2026-04-30, 0 open) | 🟩🟩 (last commit 2026-05-02, 3 open) | 🟥 (last release 2024) |
| Age | 🟩 (>1 yr; v4.0.1 from Jun 2024) | 🟩 (>1 yr) | 🟩 (>1 yr) | 🟩 (>1 yr) | 🟩 (>1 yr) | 🟩 (>1 yr) |
| README | 🟩🟩 (full guide + table-type explainer) | 🟩 (clear builder-pattern intro) | 🟩 (clear) | 🟩 (clear + Irish etymology footnote) | 🟩🟩 (full guide + ETS-vs-DETS explainer) | 🟨 (terse) |
| Idiomaticity | 🟩 (typed, builder pattern, OTP 27+) | 🟩 (typed, builder pattern) | 🟩 (typed) | 🟩 (typed) | 🟩 (typed) | 🟩 (typed) |

> [!CAUTION]
> **`bravo`'s `gleam_stdlib` constraint is `>= 0.58.0 and < 1.0.0`.** On a fresh Gleam project the resolver downgrades `gleam_stdlib` to `0.71.0` to satisfy this — and that, in turn, pulls in `gleam_erlang 0.34.0`, whose `dynamic.from` reference breaks the build the same way as carpenter. The current published version `4.0.1` is from June 2024 and predates the `gleam_stdlib 1.0` release. The library compiles in *existing* projects already pinned to pre-1.0 stdlib but **fails to build a new project on current toolchain** — same root cause as carpenter, same workaround (an explicit `< 1.0.0` lock on stdlib if you accept living on the old line). Score lowered to 🟥 on Gleam compat. Reproduced in `/tmp/test_bravo2` with `gleam add bravo@4`.

#### bravo
[hex](https://hex.pm/packages/bravo) · [repo](https://github.com/Michael-Mark-Edu/bravo) · 30★ · [🥈](#leaderboard)

The **most comprehensive ETS wrapper** in Gleam. Four table types (`USet`, `OSet`, `Bag`, `DBag`), full insert/lookup/delete/take/member API, file persistence via `tab2file` / `file2tab`. The library emphasises *why* you'd reach for ETS over Gleam dicts:

> ETS tables are inherently mutable, allowing for better performance in write-heavy situations.

Apache-2.0, 30★, OTP-target-only. Stale-but-current at v4.0.1 (June 2024) with the gleam_stdlib < 1.0 issue flagged above.

#### rasa
[hex](https://hex.pm/packages/rasa) · [repo](https://github.com/stndrs/rasa) · 1★

**"Type-safe ETS tables, queues, and counters for Gleam."** A more compact ETS wrapper than `bravo`, with a fluent builder API. Adds **queues** (FIFO backed by ordered_set + atomic counter) and **counters** (multiple strategies — sequential, monotonic time, monotonic, user-supplied) as first-class concerns alongside tables.

```gleam
import rasa/table

pub fn main() {
  let assert Ok(t) =
    table.new("sessions")
    |> table.privacy(table.Public)
    |> table.build()
  table.insert(t, "user:1", "alice")
}
```

MIT, BEAM-only, OTP 27+. Current `gleam_stdlib` constraint (`>= 0.44 and < 2.0`) — no resolver pain. Active (last commit 2026-03-21).

#### dream_ets
[hex](https://hex.pm/packages/dream_ets) · [repo](https://github.com/TrustBound/dream) · 44★ (parent)

**Type-safe ETS bindings** from the [TrustBound/dream](https://github.com/TrustBound/dream) ecosystem (also home to several other Gleam utility packages — `dream_uri`, etc.). MIT, BEAM-only. Smaller surface than `bravo` but actively maintained.

#### mala
[hex](https://hex.pm/packages/mala) · [repo](https://github.com/lpil/mala) · 8★

**"ETS bags, an in-memory table where one key can have multiple values."** Name is Irish (`mála` = "bag"). The narrowest ETS wrapper — just `bag`-type tables, no `set`/`ordered_set`. Use it when you specifically need multi-value-per-key semantics.

```gleam
import mala

pub fn main() {
  let table = mala.new()
  mala.insert(table, "numbers", 1)
  mala.insert(table, "numbers", 2)
  mala.insert(table, "numbers", 3)
  let assert [1, 2, 3] = mala.lookup(table, "numbers")
}
```

Recent (last commit 2026-04-30) and active. License unset in `gleam.toml` — 🟥 in the matrix.

#### shelf
[hex](https://hex.pm/packages/shelf) · [repo](https://github.com/tylerbutler/shelf) · 4★

**"Persistent ETS tables backed by DETS — fast in-memory access with automatic disk persistence for the BEAM."** The cleanest persistence story in Gleam: an ETS table that writes through to a DETS table on disk, so your cache survives restarts.

MIT, BEAM-only, gleam ≥ 1.7. Active (last commit 2026-05-02). Use this if your cache contents are worth keeping across BEAM restarts — most production caches benefit.

#### lamb
[hex](https://hex.pm/packages/lamb)

**ETS bindings with match-spec support.** Adds the `:ets.match/2,3` and `:ets.select/2,3` surface that the other wrappers omit. Useful if you need to query the table rather than just key-lookup. Last release 2024 — stale; mentioned for completeness.

### Persistent / disk-backed caches

For caches that survive restarts or need to spill to disk.

#### hardcache
[hex](https://hex.pm/packages/hardcache) · [repo](https://github.com/katekyy/hardcache) · 6★

**File-based key/value caching primitives** — one entry per file on the filesystem. Useful for build-tool–style caches (e.g., "cache compilation outputs in `.cache/`"), not for fast-path runtime caches.

```gleam
import hardcache

pub fn main() {
  let cache = hardcache.new(".cache/")
  let assert Ok(_) = hardcache.try_set(cache, "key", "value")
  let assert Ok(Some("value")) = hardcache.try_get(cache, "key")
}
```

MIT, BEAM-only, stale (last commit May 2024) but functional. 6★.

#### trove
[hex](https://hex.pm/packages/trove) · [repo](https://github.com/jtdowney/trove) · 1★

**"An embedded, crash-safe key/value store for Gleam, inspired by CubDB."** Append-only copy-on-write B+ tree on disk; single-writer / multi-reader with MVCC snapshots. Transactions with commit/cancel. Manual or automatic compaction.

Apache-2.0, BEAM-only, active (last commit 2026-05-13). Not strictly a cache — it's a real KV store — but well-suited as a durable cache layer where you want O(log n) reads on a disk-backed store, transactional updates, and crash safety. 1★ is a star-count fluke; the project is technically rich.

#### shelf (ETS + DETS)
*See [shelf](#shelf) in ETS bindings — same package, different lens. Use when you want in-memory speed with disk durability for restarts.*

#### amnesiac
[repo](https://github.com/VioletBuse/amnesiac) · 3★

**"Gleam bindings to mnesia."** Stub-quality: 10 commits, no releases, README is the project template. Listed here as the only Mnesia option in Gleam; for any real Mnesia work, FFI directly to `:mnesia` via `@external(erlang, ...)` declarations — the wrapper isn't pulling its weight yet.

Mnesia matters when you need: distributed transactions across multiple BEAM nodes, schema-managed tables, or hybrid RAM/disk storage. For single-node cache work, ETS (`bravo` / `rasa`) is simpler.

### Out-of-process caches

Caches that live in a separate process (typically a separate machine).

#### glimr_redis
[hex](https://hex.pm/packages/glimr_redis) · [repo](https://github.com/glimr-org/redis) · 0★

**Redis cache driver for the [Glimr](https://github.com/glimr-org/glimr) web framework.** Wraps [`valkyrie`](https://hex.pm/packages/valkyrie) (the canonical Gleam Redis-protocol client) with a cache-shaped API: `get`, `put`, `forget`, `increment`, `remember`. TTL is first-class, JSON serialisation for complex values, connection pooling via [`bath`](https://hex.pm/packages/bath).

```gleam
import glimr_redis
import glimr/cache

pub fn handler(ctx) {
  let value = cache.remember("user:1", 60, fn() {
    fetch_user_from_db(1)
  })
  // ...
}
```

MIT, 0★ but actively maintained (last commit 2026-04-29). Glimr-coupled — for non-Glimr apps, drop down to `valkyrie` directly.

#### glemcached
[hex](https://hex.pm/packages/glemcached) · [repo](https://github.com/arnu515/glemcached) · 1★

**"A memcached client in pure Gleam."** The only Gleam memcached client. Pure-Gleam (no NIF), BEAM-only, last release 2024-05 (stale). Use this if you have an existing memcached deployment; for new infrastructure, Redis is more flexible and `valkyrie` is more maintained.

#### valkyrie (cross-link)

[`valkyrie`](https://hex.pm/packages/valkyrie) is the canonical Gleam client for **Valkey / KeyDB / Redis / Dragonfly**. Not a cache library *per se* — it's a Redis-protocol client — but it's what every Gleam Redis-based cache builds on. Use it directly when:
- You want a general-purpose Redis client (not just for caching — pub/sub, streams, etc.).
- You're not on the Glimr framework (which would use [`glimr_redis`](#glimr_redis) on top).

Reviewed in [databases.md](databases.md) — not re-scored here.

### HTTP / web framework caches

#### wisp.serve_static

Not a separate package — **`wisp.serve_static` (in [Wisp](https://hex.pm/packages/wisp) itself)** generates `ETag` and `Cache-Control` headers automatically for statically served assets. Use this for the common case of "I have built frontend assets and want them cached aggressively." No separate dependency required.

The dedicated package [`cachmere`](#cachmere-deprecated) used to provide this; the author upstreamed it into Wisp via [PR #113](https://github.com/gleam-wisp/wisp/pull/113) and stopped maintaining the package.

#### cachmere (deprecated)
[hex](https://hex.pm/packages/cachmere) · [repo](https://github.com/ross-byrne/cachmere) · 0★

> [!CAUTION]
> **Deprecated by the author.** The README states:
>
> > This package is no longer maintained. Some parts of this have been upstreamed into wisp. `wisp.serve_static` now generates etags for all statically served assets.
>
> Use Wisp's built-in static-asset caching instead. Listed here for historical context and so searches for "cache + wisp" find the breadcrumb.

### Domain-shaped caches

Caches with a domain-specific API rather than a general key/value shape.

#### gquery
[hex](https://hex.pm/packages/gquery) · [repo](https://github.com/andresgutgon/gleam_query) · 0★

**A type-safe query/cache library for Gleam, inspired by TanStack Query.** Stale-while-revalidate caching for HTTP-ish data fetching, with a four-state lifecycle (`NotAsked` → `Loading` → `Loaded` | `Failed`) and staleness tracking baked in.

Key distinction from TanStack Query: **the cache is yours, not the library's.** You define a typed cache record in your app model; the library manages the fetch lifecycle and staleness logic. Framework-agnostic core with first-class Lustre integration. MIT, JS-only (the natural target for browser data-fetching), recent (last commit 2026-05-10).

#### squall_cache
[repo](https://github.com/bigmoves/squall_cache) · 0★

**Relay-style normalised GraphQL cache for Lustre apps.** Entities stored by global ID and referenced throughout the cache, preventing data duplication. Optimistic mutation support, automatic query batching and deduplication.

Apache-2.0, marked **"unstable and under active development, APIs subject to change"** in the README. Not on Hex — clone-and-build only. Use it as a starting point if you're building a Lustre + GraphQL app; expect to vendor it.

#### lustre/element.memo

**Built into [Lustre](https://hex.pm/packages/lustre)** — not a third-party package. `lustre/element.memo` takes a dependencies list and a view function; Lustre skips re-rendering the view if all dependencies are reference-equal to their previous values. Useful for:
- Many instances of the same element where only one changes at a time.
- Parts of the vdom that update frequently while other parts stay static.

The Lustre docs caution: *"in most cases the naive approach of re-rendering everything will be perfectly fine"* — reach for `element.memo` only after profiling.

## What's missing

Capabilities with **no Gleam package** and (where possible) the FFI path to the equivalent Elixir/Erlang library:

| Missing | Why you might want it | FFI path |
| --- | --- | --- |
| **General-purpose cache with TTL + LRU + multi-tier** (Cachex / Nebulex shape) | Sane default for any production cache | FFI to Elixir [`cachex`](https://hex.pm/packages/cachex) (full feature surface) or [`nebulex`](https://hex.pm/packages/nebulex) (multi-tier). Both are mature Elixir libs callable from Gleam BEAM-side via `@external(erlang, "Elixir.Cachex", ...)`. |
| **Distributed in-memory cache** (no Redis) | Cache that replicates across BEAM nodes without an external service | Mnesia (`:mnesia`) via FFI or the [`amnesiac`](#amnesiac) stub. For Elixir, [`nebulex`](https://hex.pm/packages/nebulex) with the cluster adapter. |
| **TTL on a Gleam in-memory cache** | The most-asked-for cache feature | Roll your own: store `#(value, expiry_unix_seconds)` tuples in [`bravo`](#bravo) / [`rasa`](#rasa); run a periodic cleanup actor scanning for expired keys. Or use [`keystore`](#keystore) for single-process. |
| **LRU on a concurrent table** | Bounded memory + concurrent access | None. Roll your own on [`bravo`](#bravo) by tracking access timestamps + a periodic eviction actor. |
| **`WeakMap`-keyed memoisation** (JS) | Memoise on object identity, garbage-collected when key dies | `@external(javascript, ...)` to `WeakMap` directly — one-line FFI. |
| **PASETO-signed cache keys / signed cookies** | Encrypted cache values | Not strictly a cache concern; see [authentication.md](authentication.md). |
| **Read-through / write-through / refresh-ahead patterns** | Application-level cache patterns built on a primitive | None. Write the pattern by hand around any of the above libraries. |
| **Telemetry / hit-rate metrics** | Observability for cache effectiveness | None — wire your own `gleam_otp` telemetry events. |
| **Multi-tier cache** (RAM → disk → Redis) | Cost-tier hot/warm/cold data | None — compose [`bravo`](#bravo) + [`shelf`](#shelf) + [`valkyrie`](https://hex.pm/packages/valkyrie) yourself. |
| **Content-defined chunking / immutable content-addressed cache** | IPFS-style cache | See [hashing.md#content-addressing--specialty](hashing.md#content-addressing--specialty) — use [`multiformats`](hashing.md#multiformats) for CIDs, then any KV store for storage. |
| **Cache-Aside helper** (with stampede protection / singleflight) | Prevent thundering-herd on cache miss | None — write it with [`gleam_otp`](https://hex.pm/packages/gleam_otp) actors and a "pending" map. |
| **Bloom-filter membership pre-check** | Skip the cache lookup for keys definitely-not-there | [`bloomfilter_gleam`](hashing.md#bloomfilter_gleam) — WIP, no license. Roll your own on [`gsiphash`](hashing.md#gsiphash). |

## Comparison matrix

All in-process Gleam cache packages on the canonical 7 dimensions. Out-of-process clients (`glimr_redis`, `glemcached`) excluded — they're scored where they fit naturally.

| Package | Role | Stars | License | Gleam compat | Maintenance | Age | README | Idiomaticity |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| [`worm`](#worm) | One-shot persist | 🟥 | 🟩 | 🟩 | 🟨 | 🟩 | 🟩 | 🟩 |
| [`memo_gleam`](#memo_gleam) | Self-referential memo | 🟥 | 🟩 | 🟩 | 🟩🟩 | 🟥 | 🟩 | 🟩 |
| [`rememo_erlang`](#rememo_erlang) | Explicit-handle memo (BEAM) | 🟥 | 🟥 | 🟩 | 🟩🟩 | 🟨 | 🟩 | 🟩 |
| [`rememo_javascript`](#rememo_javascript) | Explicit-handle memo (JS) | 🟥 | 🟥 | 🟩 | 🟩🟩 | 🟨 | 🟩 | 🟩 |
| [`gemo`](#gemo) | `use`-callback memo | 🟥 | 🟩 | 🟩 | 🟥 | 🟩 | 🟥 | 🟩 |
| [`booklet`](#booklet) | Atomic dual-target cell | ⬜ | 🟩 | 🟩 | 🟩 | 🟨 | 🟩 | 🟩 |
| [`cell`](#cell) | ETS-backed typed cell | 🟨 | 🟥 | 🟩 | 🟩 | 🟩 | 🟩 | 🟩 |
| [`capuchin_crypt`](#capuchin_crypt) | `persistent_term` wrapper | 🟥 | 🟩 | 🟩 | 🟩🟩 | 🟩 | 🟩🟩 | 🟩 |
| [`immutable_lru`](#immutable_lru) | Pure-Gleam LRU | 🟥 | 🟩 | 🟩 | 🟥 | 🟩 | 🟩 | 🟩 |
| [`keystore`](#keystore) | Map with TTL | 🟥 | 🟩 | 🟩 | 🟨 | 🟨 | 🟩 | 🟩 |
| [`gacache`](#gacache) | Actor-based cache | 🟥 | 🟩 | 🟩 | 🟥 | 🟩 | 🟩 | 🟩 |
| [`bravo`](#bravo) | Comprehensive ETS | 🟨 | 🟩 | 🟥 (`< 1.0.0` stdlib) | 🟥 | 🟩 | 🟩🟩 | 🟩 |
| [`rasa`](#rasa) | ETS + queues + counters | 🟥 | 🟩 | 🟩 | 🟩🟩 | 🟩 | 🟩 | 🟩 |
| [`dream_ets`](#dream_ets) | Type-safe ETS | 🟨 | 🟩 | 🟩 | 🟩🟩 | 🟩 | 🟩 | 🟩 |
| [`mala`](#mala) | ETS bags | 🟥 | 🟥 | 🟩 | 🟩🟩 | 🟩 | 🟩 | 🟩 |
| [`shelf`](#shelf) | ETS + DETS | 🟥 | 🟩 | 🟩 | 🟩🟩 | 🟩 | 🟩🟩 | 🟩 |
| [`lamb`](#lamb) | ETS + match specs | ⬜ | 🟩 | 🟩 | 🟥 | 🟩 | 🟨 | 🟩 |
| [`hardcache`](#hardcache) | File-per-key | 🟥 | 🟩 | 🟩 | 🟥 | 🟩 | 🟩 | 🟩 |
| [`trove`](#trove) | Embedded crash-safe KV | 🟥 | 🟩 | 🟩 | 🟩🟩 | 🟩 | 🟩🟩 | 🟩 |
| [`amnesiac`](#amnesiac) | Mnesia bindings (stub) | 🟥 | 🟥 | 🟩 | 🟥 | 🟩 | 🟥 | 🟨 |
| [`gquery`](#gquery) | TanStack-Query–shape | 🟥 | 🟩 | 🟩 | 🟩🟩 | 🟨 | 🟩🟩 | 🟩 |
| [`squall_cache`](#squall_cache) | Relay GraphQL cache | 🟥 | 🟩 | 🟩 | 🟨 | 🟨 | 🟩 | 🟩 |
| [`glimr_redis`](#glimr_redis) | Redis cache (Glimr) | 🟥 | 🟩 | 🟩 | 🟩🟩 | 🟩 | 🟩 | 🟩 |
| [`glemcached`](#glemcached) | Memcached client | 🟥 | 🟩 | 🟩 | 🟥 | 🟩 | 🟩 | 🟩 |

## Leaderboard

Score = sum of the 7 dimensions (🟥 = −1, 🟨 = 0, 🟩 = 1, 🟩🟩 = 2). Max 13.

| Rank | Package | Score | Highlights |
| --- | --- | --- | --- |
| 🥇 | [`shelf`](#shelf) | **8** | ETS + DETS persistence · the cleanest "in-memory speed, disk durability" story · actively maintained · BEAM-only |
| 🥇 | [`capuchin_crypt`](#capuchin_crypt) | **8** | `persistent_term` wrapper · dual-target · unusually honest README about when not to use it · actively maintained |
| 🥇 | [`trove`](#trove) | **8** | Embedded crash-safe KV (CubDB-shape) · MVCC snapshots · single-writer/multi-reader · Apache-2.0 |
| 🥇 | [`gquery`](#gquery) | **8** | Stale-while-revalidate (TanStack Query–shape) · Lustre-integrated · only of its kind |
| 🥈 | [`worm`](#worm) | **6** | One-shot persist · 3,071 downloads/30 days (highest in the memoisation slot) · MIT · dual-target (`persistent_term` on BEAM, module-level cache on JS) |
| 🥈 | [`memo_gleam`](#memo_gleam) | **6** | Self-referential memo · dual-target · brand-new but well-shaped |
| 🥈 | [`rasa`](#rasa) | **6** | ETS + queues + counters · MIT · active · builder-pattern API |
| 🥈 | [`dream_ets`](#dream_ets) | **6** | Type-safe ETS from TrustBound · MIT · active |
| 🥈 | [`booklet`](#booklet) | **6** | Atomic dual-target cell (ETS / mutable-ref) · BSD-3-Clause · GitLab-hosted |
| 🥈 | [`glimr_redis`](#glimr_redis) | **6** | Redis cache for Glimr · MIT · active · TTL native via Redis |
| 🥉 | [`cell`](#cell) | **5** | ETS-backed typed cell · 25★ · lpil-flavoured · BEAM-only |
| 🥉 | [`bravo`](#bravo) | **5** | Comprehensive ETS · 30★ · Apache-2.0 · **gleam_stdlib `< 1.0.0` issue on new projects** — same root cause as carpenter |
| 🥉 | [`mala`](#mala) | **5** | ETS bags · 8★ · active · license unset |
| 🥉 | [`hardcache`](#hardcache) | **4** | File-per-key cache · MIT · stale · 6★ |
| 14 | [`keystore`](#keystore) | **4** | TTL primitive · single-process · MIT · dual-target |
| 14 | [`squall_cache`](#squall_cache) | **4** | Relay-shape GraphQL cache · "unstable" · Apache-2.0 · Lustre-tied |
| 14 | [`glemcached`](#glemcached) | **4** | Memcached client · MIT · stale · 1★ |
| 14 | [`immutable_lru`](#immutable_lru) | **3** | Only LRU package · pure Gleam · stale · single-process |
| 18 | [`gemo`](#gemo) | **2** | `use`-callback memo · single-commit · 1★ · README is install-and-snippet only |
| 18 | [`gacache`](#gacache) | **3** | Actor-based cache · 1★ · preview-quality |
| 18 | [`rememo_erlang`](#rememo_erlang) | **3** | Explicit-handle memo · license unset · single-commit · active |
| 18 | [`rememo_javascript`](#rememo_javascript) | **3** | Explicit-handle memo (JS) · license unset · single-commit · active |
| 22 | [`lamb`](#lamb) | **2** | ETS + match specs · stale · terse README |
| 23 | [`amnesiac`](#amnesiac) | **0** | Mnesia stub · 3★ · README is project template |

> [!IMPORTANT]
> **The leaderboard does not pick the right tool for your job.** A 🥇-tied score for [`gquery`](#gquery) means it executes the stale-while-revalidate pattern well — it tells you nothing about whether SWR is what you need. Use [When to use what](#when-to-use-what) to pick by job; use the leaderboard to choose **between** implementations of the same role.

> [!NOTE]
> **Carpenter and glemo are not on this leaderboard.** Both are broken on new projects (see [Disregarded](#disregarded) for the reproduced build error). If they worked, they would score around 4–5 — but they don't, so they sit at score −∞ in practical terms.
