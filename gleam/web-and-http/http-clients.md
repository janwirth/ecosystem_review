# HTTP clients in Gleam

> [!NOTE]
> **Status:** DRAFT · **Authoring:** AI-assisted, human-reviewed.

Need to call an API, scrape a page, or stream a download from Gleam?
This article maps out what's available.

## Table of Contents

1. [Summary](#summary)
2. [Research Method](#research-method)
   - [Scoring Dimensions](#scoring-dimensions)
   - [Discovery](#discovery)
3. [Categories](#categories)
   - [BEAM HTTP Clients](#beam-http-clients) — [gleam_httpc](#gleam_httpc) · [gleam_hackney](#gleam_hackney) · [dream_http_client](#dream_http_client)
   - [JavaScript HTTP Clients](#javascript-http-clients) — [gleam_fetch](#gleam_fetch)
   - [Lustre-integrated Clients](#lustre-integrated-clients) — [rsvp](#rsvp)
   - [JSON-RPC](#json-rpc) — [pollux](#pollux)
   - [Related Work](#related-work) — [http](#related-work) · [libero](#related-work)
4. [Leaderboard](#leaderboard)

## Summary

The BEAM side of the HTTP-client story is solid: official `gleam_httpc` covers most cases, `gleam_hackney` covers the rest, and `dream_http_client` layers a typed streaming/recording API on top. The JS side is `gleam_fetch` (official) plus `rsvp` for Lustre apps.

RPC is thinner. JSON-RPC 2.0 coverage exists (`pollux`) but only at the codec level — no batteries. For typed Gleam-to-Gleam RPC over WebSocket see [libero](./web-apps.md#libero).

Snapshot: **2026-04-18**.

| Category | ☎️ BEAM | 📜 JS |
| --- | --- | --- |
| **[BEAM HTTP Clients](#beam-http-clients)** | · [🥇](#leaderboard) [gleam_httpc](#gleam_httpc) ([repo](https://github.com/gleam-lang/httpc), 163★) — *official; Erlang `httpc` bindings*<br>· [🥈](#leaderboard) [gleam_hackney](#gleam_hackney) ([repo](https://github.com/gleam-lang/hackney), 59★) — *official; Hackney bindings*<br>· [🥉](#leaderboard) [dream_http_client](#dream_http_client) ([repo](https://github.com/TrustBound/dream), 39★) — *typed streaming, recording/playback, built on `httpc`* | — |
| **[JavaScript HTTP Clients](#javascript-http-clients)** | — | · [🥇](#leaderboard) [gleam_fetch](#gleam_fetch) ([repo](https://github.com/gleam-lang/fetch), 58★) — *official; Fetch API bindings* |
| **[Lustre-integrated Clients](#lustre-integrated-clients)** | · [🥈](#leaderboard) [rsvp](#rsvp) ([repo](https://github.com/hayleigh-dot-dev/rsvp), 34★) — *universal: runs on both targets via `httpc` + `fetch`* | · [🥈](#leaderboard) [rsvp](#rsvp) ([repo](https://github.com/hayleigh-dot-dev/rsvp), 34★) — *effect-based, integrates with Lustre `update`* |
| **[JSON-RPC](#json-rpc)** | · [pollux](#pollux) ([repo](https://github.com/CrowdHailer/pollux), 2★) — *JSON-RPC 2.0 codec; bring your own transport* | · [pollux](#pollux) — *pure Gleam, runs on both targets* |

> [!IMPORTANT]
> All clients here share `gleam/http` request/response types. Switching clients = swapping one call. See [http](./web-apps.md#http) for the core types.

> [!NOTE]
> **No single HTTP client runs on both targets — this is the [function coloring problem](https://journal.stuffwithstuff.com/2015/02/01/what-color-is-your-function/).** The two runtimes disagree on how I/O composes:
>
> - **BEAM** — `httpc.send(req) -> Result(Response, Error)`. Blocking signature. The scheduler parks the process during the syscall, so "blocking" is cheap and synchronous composition (`use <- result.try`) Just Works.
> - **JavaScript** — `fetch.send(req) -> Promise(Result(Response, Error))`. Async signature. The runtime has no blocking primitive — every caller must also be `Promise`-returning, all the way up.
>
> Sync and async are different *colours*. A cross-target client would have to pick one signature and lie about the other: either force the JS target into a blocking API the runtime can't provide, or force BEAM callers into promise plumbing the BEAM doesn't need. Gleam's type system correctly refuses to paper over this — so the split is load-bearing, not a library gap.
>
> **The workaround:** build libraries against `gleam_http/request` types and let the **consumer inject the adapter** — `fetch.send` on JS, `httpc.send` on BEAM. Most code stays shared; only the final send call swaps per target, and each consumer uses the colour native to their target. `rsvp` does this internally for Lustre apps; do the same for your own library.
>
> ```gleam
> // lib/api.gleam — target-agnostic
> import gleam/http/request.{type Request}
> import gleam/http/response.{type Response}
>
> pub type Sender(error) = fn(Request(String)) -> Result(Response(String), error)
>
> pub fn get_user(send: Sender(error), id: String) {
>   let assert Ok(req) = request.to("https://api.example.com/users/" <> id)
>   send(req)
> }
> ```
> BEAM consumers pass `httpc.send` directly. JS consumers pass a wrapper that awaits the `Promise` inside a `promise.try_await` chain and returns the inner `Result`.

> <details>
> <summary><strong>Dependency Graph</strong></summary>
>
> Arrows read "uses."
>
> **[BEAM HTTP Clients](#beam-http-clients):**
> - [gleam_httpc](#gleam_httpc) → Erlang `httpc` (OTP built-in)
> - [gleam_hackney](#gleam_hackney) → Erlang `hackney`
> - [dream_http_client](#dream_http_client) → Erlang `httpc` (plus typed builder + streaming actors)
>
> **[JavaScript HTTP Clients](#javascript-http-clients):**
> - [gleam_fetch](#gleam_fetch) → browser/runtime `fetch`
>
> **[Lustre-integrated Clients](#lustre-integrated-clients):**
> - [rsvp](#rsvp) → [gleam_httpc](#gleam_httpc) (BEAM) + [gleam_fetch](#gleam_fetch) (JS) + lustre
>
> **[JSON-RPC](#json-rpc):**
> - [pollux](#pollux) → `gleam_json` (codec only, no transport)
>
> All of the above → [http](./web-apps.md#http) (shared request/response types).
>
> </details>

## Research Method

### Scoring Dimensions

Same rubric as [web-apps.md](./web-apps.md#scoring-dimensions). Recap:

- **Stars:** 🟩🟩 ≥200★, 🟩 ≥100★, 🟨 ≥10★, 🟥 <10★.
- **License:** 🟩 permissive (MIT/Apache/BSD), 🟥 viral or missing.
- **Gleam compat:** `gleam_stdlib` constraint format. 🟩 range (`>= X and < Y`), 🟥 `~>` pin.
- **Maintenance:** max(recency, responsiveness). 🟩🟩 <1 mo / <2 days / clean tracker, 🟩 <6 mo / <1 wk, 🟨 <1 yr / <1 mo, 🟥 older / ignored.
- **Age:** 🟩🟩 ≥3 yrs, 🟩 ≥1 yr, 🟨 ≥3 mo, 🟥 <3 mo.
- **README maturity:** 🟩🟩 full guide + examples, 🟩 clear tagline + usage, 🟥 minimal.
- **Idiomaticity:** 🟩 typed/explicit, 🟥 magic directives or template extraction.

**Leaderboard:** 🟥 = −1, 🟨 = 0, 🟩 = 1, 🟩🟩 = 2. Sum of 7 dims, max 13.

### Discovery

22 repos found via [packages.gleam.run](https://packages.gleam.run/) searches — **6 included** (see [Categories](#categories)), **16 disregarded** (below).

- [http](https://packages.gleam.run/?search=http)
- [fetch](https://packages.gleam.run/?search=fetch)
- [rest](https://packages.gleam.run/?search=rest)
- [rpc](https://packages.gleam.run/?search=rpc)
- [client](https://packages.gleam.run/?search=client)

> <details>
> <summary>16 disregarded — maintenance, scope, or traction issues</summary>
>
> **Unmaintained:**
> - **[lpil/nerf](https://github.com/lpil/nerf)** — Bindings to Erlang's `gun` (HTTP/1.1, HTTP/2, WebSocket). 17★, last commit 2024-03-20 (2+ years dormant), no license. Maintenance 🟥.
> - **[aosasona/falcon](https://github.com/aosasona/falcon)** — Axios-like wrapper over Hackney. 1★, last commit 2024-03-21 (2+ years dormant), no license. Maintenance 🟥.
> - **[massivefermion/dove](https://github.com/massivefermion/dove)** — Pure-Gleam HTTP client. 6★, last commit 2024-12-04 (~16 months dormant). Maintenance 🟥.
>
> **Low Traction / Niche:**
> - **[VioletBuse/httpp](https://github.com/VioletBuse/httpp)** — Hackney-based streaming client. 5★, no license. Redundant with `gleam_hackney` + `dream_http_client`. Stars 🟥, License 🟥.
> - **[lv37/efetch](https://github.com/lv37/efetch)** — Dual-target (BEAM+JS) client. 5★, last commit 2025-06-18 (~10 months stale). Stars 🟥.
> - **nicd/finch_gleam** ([git.ahlcode.fi](https://git.ahlcode.fi/nicd/finch_gleam)) — Gleam wrapper for Elixir's Finch client. Hosted off-GitHub, no star signal, low adoption.
> - **[mikan-laboratory/jsonrpcx](https://github.com/mikan-laboratory/jsonrpcx)** — JSON-RPC 2.0 codec. 0★, last commit 2025-10-17. Overlaps with `pollux`. Stars 🟥.
> - **[ryanmiville/jsonrpc](https://github.com/ryanmiville/jsonrpc)** — JSON-RPC 2.0 codec. 3★, last commit 2025-10-02, no license. Overlaps with `pollux`. Stars 🟥, License 🟥.
>
> **Out of Scope — Domain-Specific API Wrappers:**
> - **[sisou/gleam-nimiq-rpc](https://github.com/sisou/gleam-nimiq-rpc)** — Nimiq blockchain JSON-RPC client.
> - **[czepluch/gleeth](https://github.com/czepluch/gleeth)** — Ethereum JSON-RPC + wallet toolkit.
> - **fireball** — Firebase REST API wrapper.
> - **[gleam-br/gbr_gh](https://github.com/gleam-br/gbr_gh)** — GitHub REST API v3 client.
> - **[johnwesonga/joker](https://github.com/johnwesonga/joker)** (jokeapi) — JokeAPI wrapper.
> - **spacetraders_api_fetch** — spacetraders.io game API wrapper.
>
> **Out of Scope — Not a Client:**
> - **[joshgillies/fetch_event](https://github.com/joshgillies/fetch_event)** — WinterCG event-driven server stubs. 2+ years dormant, not a request-sending library.
>
> </details>

## Categories

### BEAM HTTP Clients

Send HTTP from an Erlang/BEAM Gleam program. All three share `gleam/http` request/response types — switching is mostly a one-line change.

| Criterion | [gleam_httpc](https://github.com/gleam-lang/httpc) [🥇](#leaderboard) | [gleam_hackney](https://github.com/gleam-lang/hackney) [🥈](#leaderboard) | [dream_http_client](https://github.com/TrustBound/dream) [🥉](#leaderboard) |
| --- | --- | --- | --- |
| Stars | 163★ · 🟩 | 59★ · 🟨 | 39★ · 🟨 (dream monorepo) |
| License | Apache-2.0 · 🟩 | Apache-2.0 · 🟩 | MIT · 🟩 |
| Target | ☎️ BEAM | ☎️ BEAM | ☎️ BEAM |
| Deps | 3 | 3 (+ Erlang `hackney`) | 8 |
| Gleam compat | `>= 0.32 and < 2.0` · 🟩 | `>= 0.45 and < 2.0` · 🟩 | `>= 0.60 and < 1.0` · 🟩 ([see caveat](#dream_http_client-compat)) |
| Maintenance | 🟩 (issues triaged recently; last commit 2025-07-12) | 🟩 (last commit 2025-12-20) | 🟩 (last commit 2026-03-17) |
| Age | ~6.3 yrs (Jan 2020) · 🟩🟩 | ~4.3 yrs (Dec 2021) · 🟩🟩 | ~5 months (Nov 2025) · 🟨 |
| README maturity | 🟩 (tagline + runnable example + TLS warning) | 🟩 (tagline + example + cross-reference to `httpc`) | 🟩🟩 (full guide, execution modes, recording docs, API reference) |
| Idiomaticity | 🟩 | 🟩 | 🟩 |
| | | | |
| **Features** | | | |
| Blocking send | ✅ | ✅ | ✅ |
| Streaming body | — | — (full-body only) | ✅ (yielder + actor) |
| TLS | ✅ (OTP 26+) | ✅ | ✅ (via `httpc`) |
| Recording/playback | — | — | ✅ |
| Cancellation | — | — | ✅ (in-flight) |

#### gleam_httpc
[repo](https://github.com/gleam-lang/httpc) · [🥇](#leaderboard)

Official bindings to Erlang's built-in `httpc`. Zero extra runtime deps (part of OTP). Default pick for BEAM HTTP calls. Warn: OTP <26 skips TLS verification — upgrade OTP or use `hackney`.

```gleam
import gleam/http/request
import gleam/httpc
import gleam/result

pub fn send_request() {
  let assert Ok(base_req) =
    request.to("https://test-api.service.hmrc.gov.uk/hello/world")

  let req =
    request.prepend_header(base_req, "accept", "application/vnd.hmrc.1.0+json")

  use resp <- result.try(httpc.send(req))
  assert resp.status == 200
  Ok(resp)
}
```

#### gleam_hackney
[repo](https://github.com/gleam-lang/hackney) · [🥈](#leaderboard)

Official bindings to the Erlang `hackney` HTTP client. Useful when `httpc` defaults bite — e.g., older OTP TLS, connection pooling, proxy support. The README itself says "most the time `gleam_httpc` is a better choice" — reach for this when you've hit a specific `httpc` limitation.

```gleam
import gleam/hackney
import gleam/http/request
import gleam/result

pub fn main() {
  let assert Ok(req) =
    request.to("https://test-api.service.hmrc.gov.uk/hello/world")

  use resp <- result.try(
    req
    |> request.prepend_header("accept", "application/vnd.hmrc.1.0+json")
    |> hackney.send
  )
  assert resp.status == 200
  Ok(resp)
}
```

#### dream_http_client
[repo](https://github.com/TrustBound/dream) (in `modules/http_client`)

Typed builder-pattern client built on `httpc`, with three execution modes (blocking, yielder streaming, process/actor streaming) and first-class recording/playback for tests. Published from the TrustBound/dream monorepo but framework-independent — usable in any Gleam project. Most feature-rich of the BEAM clients.

<a id="dream_http_client-compat"></a>
**Compat caveat:** `gleam.toml` pins `gleam_stdlib` to `>= 0.60.0 and < 1.0.0`. Formally a range (🟩), but the upper bound `< 1.0.0` will conflict with any project already on a `1.x` stdlib. Widen to `< 2.0.0` to unblock.

```gleam
import dream_http_client/client.{host, method, path, port, scheme, send}
import gleam/http

pub fn simple_get() {
  client.new()
  |> method(http.Get)
  |> scheme(http.Http)
  |> host("localhost")
  |> port(9876)
  |> path("/text")
  |> send()
}
```

### JavaScript HTTP Clients

Send HTTP from a Gleam program compiled to JavaScript (browser, Deno, Node, Workers).

| Criterion | [gleam_fetch](https://github.com/gleam-lang/fetch) [🥇](#leaderboard) |
| --- | --- |
| Stars | 58★ · 🟨 |
| License | Apache-2.0 · 🟩 |
| Target | 📜 JavaScript |
| Deps | 3 |
| Gleam compat | `>= 0.32 and < 2.0` · 🟩 |
| Maintenance | 🟩🟩 (last commit 2026-04-02, ~2 weeks) |
| Age | ~4.6 yrs (Sep 2021) · 🟩🟩 |
| README maturity | 🟩 (tagline + example + target warning) |
| Idiomaticity | 🟩 |

#### gleam_fetch
[repo](https://github.com/gleam-lang/fetch) · [🥇](#leaderboard)

Official thin wrapper over the platform `fetch` API. Returns a `Promise` — compose with `gleam/javascript/promise`. Only for the JS target; errors loudly on BEAM.

```gleam
import gleam/fetch
import gleam/http/request
import gleam/javascript/promise

pub fn main() {
  let assert Ok(req) = request.to("https://example.com")

  use resp <- promise.try_await(fetch.send(req))
  use resp <- promise.try_await(fetch.read_text_body(resp))

  resp.status
  // -> 200
  promise.resolve(Ok(Nil))
}
```

### Lustre-integrated Clients

Clients that know about a framework's runtime and return effects, not raw promises.

| Criterion | [rsvp](https://github.com/hayleigh-dot-dev/rsvp) [🥈](#leaderboard) |
| --- | --- |
| Stars | 34★ · 🟨 |
| License | MIT · 🟩 |
| Target | ☎️📜 Both (uses `httpc` on BEAM, `fetch` on JS) |
| Deps | 7 |
| Gleam compat | `>= 0.60 and < 2.0` · 🟩 |
| Maintenance | 🟩 (last commit 2026-01-10) |
| Age | ~1.4 yrs (Nov 2024) · 🟩 |
| README maturity | 🟩🟩 (recipes for GET JSON, POST JSON, auth headers — [links broken at snapshot](#rsvp)) |
| Idiomaticity | 🟩 |

#### rsvp
[repo](https://github.com/hayleigh-dot-dev/rsvp) · [🥈](#leaderboard)

HTTP effects for Lustre apps (SPAs, components, server components). You define a `Handler` that turns the response into a `Msg`, then return an `Effect` from `init`/`update`. Works on both targets, so universal components stay universal. Authored by hayleigh-dot-dev (Lustre creator) — tight fit with the framework.

**README caveat:** recipe links (`./recipes/get-json.html`, `./recipes/post-json.html`, `./recipes/authorization-headers.html`) 404 on both GitHub and HexDocs at snapshot — the recipe sources are declared in `gleam.toml` but the rendered pages aren't published. Fall back to the API docs on HexDocs for now.

```gleam
import lustre/effect
import rsvp

pub type Msg {
  GotQuote(Result(Quote, rsvp.Error))
}

fn get_quote() -> effect.Effect(Msg) {
  let handler = rsvp.expect_json(quote_decoder(), GotQuote)
  rsvp.get("https://api.example.com/quote", handler)
}
```

### JSON-RPC

Codec for the JSON-RPC 2.0 envelope. Pair with any of the HTTP clients (or a WebSocket) above for transport.

| Criterion | [pollux](https://github.com/CrowdHailer/pollux) |
| --- | --- |
| Stars | 2★ · 🟥 |
| License | Apache-2.0 · 🟩 |
| Target | ☎️📜 Both |
| Deps | 3 |
| Gleam compat | `>= 0.44 and < 2.0` · 🟩 |
| Maintenance | 🟩🟩 (0 open issues; last commit 2025-12-31) |
| Age | ~3.5 months (Dec 2025) · 🟨 |
| README maturity | 🟩 (usage snippet + context) |
| Idiomaticity | 🟩 |

#### pollux
[repo](https://github.com/CrowdHailer/pollux)

JSON-RPC 2.0 request/notification/response codecs. You bring your own app types and encoders/decoders — pollux composes them into a valid jsonrpc envelope. Extracted from the EYG project. Transport-agnostic: wire it to any HTTP client or WebSocket layer.

```gleam
import pollux

pub type MyRequest { MyRequest }
pub type MyResponse { MyResponse }
pub type MyNotification { MyNotification }

fn request_decoder() {
  pollux.request_decoder(
    my_request_decoder,
    my_notification_decoder,
    ZeroNotification,
  )
}

pub fn server() {
  case json.parse(input, request_decoder()) {
    pollux.Request(id:, ..) -> {
      pollux.response(id, Ok(MyResponse))
      |> pollux.response_encode(my_response_encode)
    }
    pollux.Notification(..) -> todo
  }
}
```

### Related Work

Covered fully in [web-apps.md](./web-apps.md):

- **[http](./web-apps.md#http)** — `Request`/`Response`/`Header`/`Method` types shared by every client here. Not a client; the thing every client consumes.
- **[libero](./web-apps.md#libero)** — Typed RPC for Lustre + any Gleam server. WebSocket transport with codegen'd client stubs. Use when both ends are Gleam and you want compile-time type safety across the wire — as opposed to the lower-level JSON-RPC envelope that `pollux` provides.

## Leaderboard

Special thanks to the maintainers keeping Gleam's HTTP story coherent.

**🥇 Gold**
- **gleam_httpc** ([lpil](https://github.com/lpil) 81 commits) — Default BEAM client. Boring in the best way.
- **gleam_fetch** ([lpil](https://github.com/lpil) 66 commits, [ghivert](https://github.com/ghivert) 10, [CrowdHailer](https://github.com/CrowdHailer) 7) — Default JS client. Same API shape as httpc so code ports easily.

**🥈 Silver**
- **gleam_hackney** ([lpil](https://github.com/lpil) 36 commits) — Escape hatch when `httpc` defaults don't fit.
- **rsvp** ([hayleigh-dot-dev](https://github.com/hayleigh-dot-dev) 47 commits) — HTTP the Lustre way. Lets universal components stay universal.

**🥉 Bronze**
- **dream_http_client** ([dcrockwell](https://github.com/dcrockwell) 186 commits across dream monorepo) — Typed streaming + recording/playback. Biggest README in the category.

| Position | Award | Repo | ★ | Lic | Compat | Maint | Age | README | Idiom | Score |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 🥇 | · [gleam-lang/httpc](https://github.com/gleam-lang/httpc)<br>· [gleam-lang/fetch](https://github.com/gleam-lang/fetch) | 🟩<br>🟨 | 🟩<br>🟩 | 🟩<br>🟩 | 🟩<br>🟩🟩 | 🟩🟩<br>🟩🟩 | 🟩<br>🟩 | 🟩<br>🟩 | **8** |
| 2 | 🥈 | · [gleam-lang/hackney](https://github.com/gleam-lang/hackney)<br>· [hayleigh-dot-dev/rsvp](https://github.com/hayleigh-dot-dev/rsvp) | 🟨<br>🟨 | 🟩<br>🟩 | 🟩<br>🟩 | 🟩<br>🟩 | 🟩🟩<br>🟩 | 🟩<br>🟩🟩 | 🟩<br>🟩 | **7** |
| 3 | 🥉 | [TrustBound/dream_http_client](https://github.com/TrustBound/dream) | 🟨 | 🟩 | 🟩 | 🟩 | 🟨 | 🟩🟩 | 🟩 | **6** |
| 4 | | [CrowdHailer/pollux](https://github.com/CrowdHailer/pollux) | 🟥 | 🟩 | 🟩 | 🟩🟩 | 🟨 | 🟩 | 🟩 | **5** |

**By target:** ☎️ BEAM **33** (5 repos) · 📜 JS **20** (3 repos). Dual-target (rsvp, pollux) count toward both.

[How scores are calculated →](#scoring-dimensions)
