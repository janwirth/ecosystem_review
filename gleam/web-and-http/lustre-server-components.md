# Lustre Server Components

> [!NOTE]
> **Status:** DRAFT · **Authoring:** AI-assisted, human-reviewed.

A guided tour through every example in [`lustre-labs/lustre/examples/06-server-components`](https://github.com/lustre-labs/lustre/tree/main/examples/06-server-components) so you don't have to clone the repo and `cd` into six directories to figure out which one shows the trick you need.

**Snapshot: 2026-04-24.**

A Lustre **server component** is a normal Lustre app — `init` / `update` / `view` — that runs as a BEAM process on the server. The browser only loads a ~10 kB JavaScript runtime that registers a `<lustre-server-component>` custom element, opens a WebSocket back to the server, and applies DOM patches the runtime sends down. UI updates are diff streams; user events are decoded payloads going the other way. Same shape as Phoenix LiveView, but the components are typed Gleam end-to-end and the transport is yours to wire (Lustre takes no opinion — Mist, Wisp, raw process messaging, all fine).

The six examples in the repo each isolate one concern. They build incrementally, but each ships its own `app.gleam` so picking up the trick from #5 means you also get the boilerplate from #1 every time. This article extracts the deltas.

## Table of Contents

1. [TL;DR](#tldr)
2. [What is a server component?](#what-is-a-server-component)
3. [The base case — `01-basic-setup`](#the-base-case--01-basic-setup)
4. [Variants](#variants)
   - [`02-attributes-and-events` — outside ↔ inside the component](#02-attributes-and-events--outside--inside-the-component)
   - [`03-event-include` — custom event handlers and what crosses the wire](#03-event-include--custom-event-handlers-and-what-crosses-the-wire)
   - [`04-multiple-clients` — one runtime, many viewers](#04-multiple-clients--one-runtime-many-viewers)
   - [`05-publish-subscribe` — per-client runtimes that gossip](#05-publish-subscribe--per-client-runtimes-that-gossip)
   - [`06-csrf-protection` — securing the WebSocket handshake](#06-csrf-protection--securing-the-websocket-handshake)
5. [Comparison cheat sheet](#comparison-cheat-sheet)
6. [Common pitfalls (lifted from the comments in the source)](#common-pitfalls-lifted-from-the-comments-in-the-source)
7. [Related Work](#related-work)

## TL;DR

| # | Example | What it teaches | New API surface |
| --- | --- | --- | --- |
| 1 | [`01-basic-setup`](#the-base-case--01-basic-setup) | Minimum scaffold: HTML + runtime.mjs + WS handler + a `lustre.simple` counter | `lustre.start_server_component`, `server_component.element`, `server_component.route`, `server_component.register_subject` |
| 2 | [`02-attributes-and-events`](#02-attributes-and-events--outside--inside-the-component) | HTML attributes drive the component; the component fires real DOM CustomEvents back | `lustre.component`, `component.on_attribute_change`, `component.on_property_change`, `event.emit` |
| 3 | [`03-event-include`](#03-event-include--custom-event-handlers-and-what-crosses-the-wire) | Custom `event.on(...)` decoders; whitelisting which event-payload fields cross the WebSocket; `:host` styles | `event.on` + `decode`, `server_component.include`, `keyed.div`, `:host {}` |
| 4 | [`04-multiple-clients`](#04-multiple-clients--one-runtime-many-viewers) | One server-component instance shared by N WebSockets — collaborative shared state for free | Runtime hoisted to `main`, `server_component.deregister_subject`, `event.throttle`, `.min.mjs` runtime |
| 5 | [`05-publish-subscribe`](#05-publish-subscribe--per-client-runtimes-that-gossip) | Per-client runtimes that broadcast via a `group_registry` (BEAM `pg` topic); shared + private state side-by-side | `lustre.application`, `group_registry`, `server_component.select` effect, two message types (`Message` vs `SharedMessage`) |
| 6 | [`06-csrf-protection`](#06-csrf-protection--securing-the-websocket-handshake) | Reject the WebSocket upgrade unless a CSRF token in the page meta tag matches | `<meta name="csrf-token">` (read by client runtime), `request.get_query` validation before `mist.websocket` |

The other 90 % of every `app.gleam` (mist routing for `/`, `/lustre/runtime.mjs`, `/ws`; the WebSocket handler that ferries `mist.Text` ↔ `lustre.send` and serialises `mist.Custom` back out as a text frame; the cleanup on close) is the same boilerplate from #1 reused in every example. **Read #1 once; for the rest, only read the diff highlighted below.**

## What is a server component?

```
Browser                                                Server (BEAM)
┌──────────────────────────────┐    WebSocket    ┌─────────────────────────────┐
│ <lustre-server-component>    │ ◄──── DOM ────► │ Lustre runtime (per-client  │
│   ↑ ~10 kB client runtime    │    diff /       │   or shared) holding Model  │
│   ↑ applies patches to DOM   │    decoded      │                             │
│   ↑ serialises events to JSON│    event        │ init / update / view        │
└──────────────────────────────┘                 └─────────────────────────────┘
        ▲                                                 ▲
        │ standard DOM events from page JS                │ optional process messaging
        │ (CustomEvent fired via event.emit)              │ (group_registry, Subjects)
```

Three moving parts:

1. **HTML page** — Lustre renders it (or you do); it includes a `<script type="module" src="/lustre/runtime.mjs">` and a `<lustre-server-component route="/ws">` element.
2. **Client runtime** (`lustre-server-component.mjs`, ~10 kB) — registers the custom element, opens the WebSocket, applies DOM diffs, serialises events, and (in #6) auto-picks up CSRF tokens.
3. **Server runtime** — a BEAM process started by `lustre.start_server_component(component, init_arg)`. You wire it to the WebSocket process via `server_component.register_subject(subject)` and forward messages either way using `lustre.send`.

The runtime is **transport-agnostic**. The examples all use Mist WebSockets, but you could equally use SSE, polling, or any other duplex channel — Lustre just hands you typed messages and asks you to ferry them.

## The base case — `01-basic-setup`

[Source](https://github.com/lustre-labs/lustre/tree/main/examples/06-server-components/01-basic-setup) · [`app.gleam`](https://github.com/lustre-labs/lustre/blob/main/examples/06-server-components/01-basic-setup/src/app.gleam) · [`counter.gleam`](https://github.com/lustre-labs/lustre/blob/main/examples/06-server-components/01-basic-setup/src/counter.gleam)

A `+`/`–` counter rendered server-side, clicks streamed back over WebSocket. Two files:

### `counter.gleam` — a *universal* component

A normal Lustre `simple` app. The only thing that makes it "server component shaped" is that it exposes `pub fn component()` (returns the `App`) rather than `pub fn register()` (registers a custom element on `window`). Same module can run in either place.

```gleam
pub fn component() -> App(_, Model, Message) {
  lustre.simple(init, update, view)
}

pub opaque type Message {
  UserClickedIncrement
  UserClickedDecrement
}

fn update(model: Int, message: Message) -> Int {
  case message {
    UserClickedIncrement -> model + 1
    UserClickedDecrement -> model - 1
  }
}

fn view(model: Int) -> Element(Message) {
  element.fragment([
    html.h1([], [html.text("Hi")]),
    html.div([attribute.styles([#("display", "flex")])], [
      view_button(label: "-", on_click: UserClickedDecrement),
      html.p([], [html.text("Count: "), html.text(int.to_string(model))]),
      view_button(label: "+", on_click: UserClickedIncrement),
    ]),
  ])
}
```

### `app.gleam` — three responsibilities

The Mist handler matches three paths:

```gleam
case request.path_segments(request) {
  // 1. The HTML document containing the <lustre-server-component> custom element.
  [] -> serve_html()
  // 2. The pre-built JS runtime that registers and drives that element.
  ["lustre", "runtime.mjs"] -> serve_runtime()
  // 3. The WebSocket the client runtime connects to.
  ["ws"] -> serve_counter(request)
  _ -> response.set_body(response.new(404), mist.Bytes(bytes_tree.new()))
}
```

`serve_html` renders a Lustre tree containing `server_component.element([server_component.route("/ws")], [])` — that single line is the entire client-side wiring.

`serve_runtime` ships the bundled JS shipped inside the `lustre` Hex package's `priv` directory — `application.priv_directory("lustre")` gives you the path; the file is `static/lustre-server-component.mjs` (the minified `.min.mjs` is also there, ~10 kB).

`serve_counter` is the WebSocket handler. The pattern repeats in every example; learn it once:

```gleam
fn init_counter_socket(_) -> CounterSocketInit {
  let counter = counter.component()
  // Construct the runtime; no DOM selector — there's no DOM here!
  let assert Ok(component) = lustre.start_server_component(counter, Nil)

  // The runtime talks to *this* WebSocket process via a Gleam Subject.
  let self = process.new_subject()
  let selector = process.new_selector() |> process.select(self)

  // Tell the runtime to send all client-bound messages to our subject.
  server_component.register_subject(self)
  |> lustre.send(to: component)

  #(CounterSocket(component:, self:), Some(selector))
}

fn loop_counter_socket(state, message, connection) {
  case message {
    // Browser → server: parse the JSON envelope, hand it to the runtime.
    mist.Text(json) -> {
      case json.parse(json, server_component.runtime_message_decoder()) {
        Ok(runtime_message) -> lustre.send(state.component, runtime_message)
        Error(_) -> Nil
      }
      mist.continue(state)
    }
    // Server → browser: encode and ship as a text frame.
    mist.Custom(client_message) -> {
      let json = server_component.client_message_to_json(client_message)
      let assert Ok(_) = mist.send_text_frame(connection, json.to_string(json))
      mist.continue(state)
    }
    mist.Binary(_) -> mist.continue(state)
    mist.Closed | mist.Shutdown -> mist.stop()
  }
}

fn close_counter_socket(state) -> Nil {
  // Don't forget this — otherwise you leak a process per dropped connection.
  lustre.shutdown() |> lustre.send(to: state.component)
}
```

That's the whole base case. Every variant below changes only what's strictly needed.

## Variants

### `02-attributes-and-events` — outside ↔ inside the component

[Source](https://github.com/lustre-labs/lustre/tree/main/examples/06-server-components/02-attributes-and-events) · [`counter.gleam`](https://github.com/lustre-labs/lustre/blob/main/examples/06-server-components/02-attributes-and-events/src/counter.gleam)

**What it adds:** the page can drive the component (set the counter's value via an HTML attribute), and the component can fire real DOM `CustomEvent`s back at the page (so plain JavaScript can listen).

**How it adds it:** the component is built with `lustre.component(...)` instead of `lustre.simple(...)` so it can register attribute/property change handlers, and the update function uses the `event.emit` effect.

```gleam
// counter.gleam — opt into attribute + property change handlers
pub fn component() -> lustre.App(_, Model, Message) {
  lustre.component(init, update, view, [
    component.on_attribute_change("value", fn(value) {
      int.parse(value) |> result.map(ParentChangedValue)
    }),
    // Properties carry arbitrary JSON, not just strings — decode richly.
    component.on_property_change("value", {
      decode.int |> decode.map(ParentChangedValue)
    }),
  ])
}

// In update:
UserClickedSubmit -> #(
  model,
  // Fires a real DOM CustomEvent. `detail` will hold the JSON we encode.
  event.emit("change", json.int(model)),
)
```

```gleam
// app.gleam — render with the attribute set, listen for the event in plain JS
server_component.element(
  [server_component.route("/ws"), counter.value(10)], // <-- initial attr
  [],
),
html.script([], "
  const counter = document.querySelector('lustre-server-component');
  counter.addEventListener('change', event => {
    window.alert(`The counter value is now ${event.detail}`);
  })
"),
```

**When to use it:** when the server component needs to live inside a larger non-Lustre page (e.g. a static site, another framework, an existing form) and exchange data with it through standard DOM mechanics. Editing the attribute in DevTools also live-updates the component, which is a fun demo.

### `03-event-include` — custom event handlers and what crosses the wire

[Source](https://github.com/lustre-labs/lustre/tree/main/examples/06-server-components/03-event-include) · [`chat.gleam`](https://github.com/lustre-labs/lustre/blob/main/examples/06-server-components/03-event-include/src/chat.gleam)

**What it adds:** a chat widget with a free-text input. Three new ideas appear at once because they tend to come together:

1. **Custom `event.on(...)` handlers** with a `decode` block, the same as a regular Lustre app.
2. **`server_component.include(...)`** — the load-bearing trick. DOM event objects have non-enumerable properties; the default JSON serialisation in the browser would strip almost everything. You have to *whitelist* the field paths you want to ship over the WebSocket.
3. **`:host { ... }`** styles — server components are custom elements (Shadow DOM), so component styles target `:host` rather than the body.

A keyed `div` clears the uncontrolled input on submission by changing the React-style `key`.

```gleam
let on_keydown =
  event.on("keydown", {
    use key <- decode.field("key", decode.string)
    use value <- decode.subfield(["target", "value"], decode.string)

    case key {
      "Enter" if value != "" -> decode.success(handle_keydown(value))
      _ -> decode.failure(handle_keydown(""), "")
    }
  })
  // *** This is the new bit. Without it, `target.value` and `key` are absent
  // *** from the JSON the browser sends, and your decoder fails silently.
  |> server_component.include(["key", "target.value"])
```

**When to use it:** any time you need event data beyond the click target — keyboard input, mouse coordinates, form values, file picker selections. **If you ever find yourself with a working client-side handler that "just doesn't fire" once it's a server component, the answer is almost always a missing `server_component.include` for the field your decoder reads.**

### `04-multiple-clients` — one runtime, many viewers

[Source](https://github.com/lustre-labs/lustre/tree/main/examples/06-server-components/04-multiple-clients) · [`app.gleam`](https://github.com/lustre-labs/lustre/blob/main/examples/06-server-components/04-multiple-clients/src/app.gleam) · [`whiteboard.gleam`](https://github.com/lustre-labs/lustre/blob/main/examples/06-server-components/04-multiple-clients/src/whiteboard.gleam)

**What it adds:** a collaborative whiteboard where every connected browser sees and edits the *same* model. Open two tabs, draw in one, watch the other update.

**How it adds it (one line!):** the runtime is created **once at startup** and shared across every WebSocket connection.

```gleam
pub fn main() {
  // Hoisted out of the WebSocket init — created once.
  let whiteboard = whiteboard.component()
  let assert Ok(component) = lustre.start_server_component(whiteboard, Nil)

  let assert Ok(_) =
    fn(request: Request(Connection)) -> Response(ResponseData) {
      case request.path_segments(request) {
        ["ws"] -> serve_whiteboard(request, component)  // <-- pass the shared instance
        ...
      }
    }
    |> mist.new |> mist.bind("localhost") |> mist.port(1234) |> mist.start
  ...
}

fn init_whiteboard_socket(_, component) -> WhiteboardSocketInit {
  // No `start_server_component` here — just register this socket as a listener.
  let self = process.new_subject()
  let selector = process.new_selector() |> process.select(self)
  server_component.register_subject(self) |> lustre.send(to: component)
  #(WhiteboardSocket(component:, self:), Some(selector))
}

fn close_whiteboard_socket(state) -> Nil {
  // Critical change: deregister, don't shutdown — other clients still need the runtime.
  server_component.deregister_subject(state.self) |> lustre.send(to: state.component)
}
```

The component itself is a standard `lustre.simple` whiteboard with `mousemove`-driven drawing. Two new event helpers appear:

```gleam
let on_mouse_move =
  event.on("mousemove", { ... decoder reading `buttons`, `clientX`, `clientY` ... })
  |> server_component.include(["buttons", "clientX", "clientY"])
  |> event.throttle(5)  // <-- ship at most one event per 5 ms
```

`event.throttle` matters here — without it, a fast mousemove drowns the WebSocket.

This example also switches `lustre-server-component.mjs` for `lustre-server-component.min.mjs` (~10 kB) — same behaviour, smaller payload.

**When to use it:** anything where the model is intrinsically shared — collaborative editors, dashboards, live status boards, a chat *room* (vs. a per-user chat session as in #3). One BEAM process, N viewers.

### `05-publish-subscribe` — per-client runtimes that gossip

[Source](https://github.com/lustre-labs/lustre/tree/main/examples/06-server-components/05-publish-subscribe) · [`whiteboard.gleam`](https://github.com/lustre-labs/lustre/blob/main/examples/06-server-components/05-publish-subscribe/src/whiteboard.gleam)

**What it adds:** also a collaborative whiteboard, but each client gets its **own** runtime instance. Shared state (the points drawn) propagates via a [`group_registry`](https://hexdocs.pm/group_registry/) topic; per-client state (the user's selected colour) stays local.

**Why you'd want this over #4:** in #4 every client is a viewer of the same Model — they can't have private state. Here, each connection is an independent process that *opts in* to a shared topic, so you get hybrid state: some fields are local, others are broadcast.

The architectural changes ripple through three places.

**1.** `app.gleam` starts a `group_registry` once at boot and passes it to each new socket:

```gleam
let name = process.new_name("whiteboard-registry")
let assert Ok(actor.Started(data: registry, ..)) = group_registry.start(name)
// ... and per connection:
let assert Ok(component) = lustre.start_server_component(whiteboard, registry)
```

**2.** `whiteboard.gleam` is now a `lustre.application` (not `simple`) so `init` returns an `Effect`, and there are **two message types**:

```gleam
/// Crosses the topic — emitted and observed by all client runtimes.
pub opaque type SharedMessage {
  ClientDrewCircle(x: Int, y: Int, color: Color)
  ClientClearedScreen
}

/// Local to one runtime — includes a wrapper for incoming SharedMessage.
pub opaque type Message {
  AppReceivedSharedMessage(message: SharedMessage)
  UserChangedColor(color: Color)        // local; never broadcast
  UserDrewCircle(x: Int, y: Int, color: Color)  // local intent → broadcast
  UserClearedScreen
}
```

**3.** `init` subscribes to the topic via the new `server_component.select` effect, which lets you hand the runtime extra `Selector`s so it processes off-runtime Subjects in the same loop:

```gleam
fn subscribe(registry, on_message handle_message) -> Effect(message) {
  use _, _ <- server_component.select
  let subject = group_registry.join(registry, "whiteboard", process.self())
  process.new_selector() |> process.select_map(subject, handle_message)
}
```

The `update` function then routes the two-way flow: user actions broadcast their intent, then come back as `AppReceivedSharedMessage` to mutate local state:

```gleam
UserDrewCircle(x:, y:, color:) ->
  // Don't update locally — broadcast and wait for the echo.
  #(model, broadcast(model.registry, ClientDrewCircle(x:, y:, color:)))

AppReceivedSharedMessage(ClientDrewCircle(x:, y:, color:)) ->
  // The echo arrived — *now* mutate.
  #(Model(..model, drawn_points: dict.insert(...)), effect.none())
```

**Note from the source comments:** "This still does not make a complete whiteboard app! Try drawing with the first client before connecting the second one." Joining the topic doesn't replay history — late joiners start with an empty board. Building a real shared app means handling state transfer too (out of scope for the example).

**When to use it:** you want collaboration *plus* per-user state (own cursor colour, own selection, own undo stack), or you want to scale beyond what one shared runtime can serve. This is also the example that maps closest to LiveView's PubSub patterns. Compare the `[libero](./web-apps.md#libero)` approach in [Full-stack approaches compared](./web-apps.md#full-stack-approaches-compared-libero-vs-lustre-server-components-vs-glimr) — libero solves the same broadcast problem with BEAM `pg` groups under typed RPC, where this solves it with `group_registry` and Lustre's component message system.

### `06-csrf-protection` — securing the WebSocket handshake

[Source](https://github.com/lustre-labs/lustre/tree/main/examples/06-server-components/06-csrf-protection) · [`app.gleam`](https://github.com/lustre-labs/lustre/blob/main/examples/06-server-components/06-csrf-protection/src/app.gleam)

**What it adds:** rejects any WebSocket upgrade whose origin can't prove it loaded the page first. Counter component is the same as #1; the change is entirely in the routing layer.

**Why this matters:** browsers enforce CORS for `fetch`, but **not** for WebSocket connections. Cookies still ride along on cross-origin WebSocket opens, which is the classic CSRF window. The mitigation is a token tied to the page that the client must echo back when it opens the socket.

**How it adds it:** three small bits of glue.

```gleam
// 1. Generate a token at boot (in real life: tie to the user session).
let csrf_token = uuid.v4_string()

// 2. Embed it in the page as a meta tag — the client runtime auto-detects this.
html.meta([
  attribute.name("csrf-token"),
  attribute.content(csrf_token),
]),
```

The Lustre client runtime detects `<meta name="csrf-token">` and **automatically** appends `?csrf-token=<value>` to the WebSocket URL. Browsers don't allow custom headers on WS opens, so a query parameter is the only place to put it.

```gleam
// 3. Validate before upgrading.
let provided_csrf_token =
  request
  |> request.get_query
  |> result.try(list.key_find(_, "csrf-token"))

case provided_csrf_token {
  Ok(token) if token == expected_csrf_token ->
    mist.websocket(request:, on_init: ..., handler: ..., on_close: ...)
  _ ->
    response.new(403)
    |> response.set_header("content-type", "text/plain")
    |> response.set_body(mist.Bytes(bytes_tree.from_string("Forbidden")))
}
```

The example flips the meta content to `"invalid-token"` in a comment so you can prove the rejection works.

**When to use it:** **always**, in production. The example's globally-shared token is a demo simplification — a real implementation binds the token to a session cookie and stores it server-side. Combine with TLS, an Origin/Host check, and (if cookies authenticate the user) a same-site cookie attribute.

## Comparison cheat sheet

One row per example, columns picked to surface the actual differentiators.

| | `01-basic-setup` | `02-attributes-and-events` | `03-event-include` | `04-multiple-clients` | `05-publish-subscribe` | `06-csrf-protection` |
| --- | --- | --- | --- | --- | --- | --- |
| **Component built with** | `lustre.simple` | `lustre.component` | `lustre.simple` | `lustre.simple` | `lustre.application` | `lustre.simple` |
| **Runtimes per page load** | 1 | 1 | 1 | shared (1 total) | 1 (per client, all join a topic) | 1 |
| **State sharing across clients** | — | — | — | implicit (same model) | explicit (broadcast `SharedMessage`) | — |
| **Per-client local state** | ✅ | ✅ | ✅ | ❌ (everyone shares) | ✅ (`selected_color`) + shared | ✅ |
| **HTML attribute → component** | — | ✅ `on_attribute_change` | — | — | — | — |
| **Component → DOM CustomEvent** | — | ✅ `event.emit` | — | — | — | — |
| **Custom `event.on(...)` decoders** | — | — | ✅ | ✅ (mousemove) | ✅ (mousemove) | — |
| **`server_component.include`** | — | — | ✅ `["key", "target.value"]` | ✅ `["buttons", "clientX", "clientY"]` | ✅ same | — |
| **`event.throttle`** | — | — | — | ✅ (5 ms) | ✅ (5 ms) | — |
| **Off-runtime messaging** | — | — | — | — | ✅ `server_component.select` + `group_registry` | — |
| **Cleanup on close** | `lustre.shutdown` | `lustre.shutdown` | `lustre.shutdown` | `deregister_subject` | `lustre.shutdown` | `lustre.shutdown` |
| **Runtime asset served** | `.mjs` | `.mjs` | `.mjs` | `.min.mjs` | `.min.mjs` | `.mjs` |
| **Transport** | Mist WS | Mist WS | Mist WS | Mist WS | Mist WS | Mist WS |
| **Framework integration** | raw Mist | raw Mist | raw Mist | raw Mist | raw Mist + `group_registry` | raw Mist + `youid` |
| **Suitable for…** | First app; learning the pieces | Embedding inside a non-Lustre page | Form/chat-style input where event payloads matter | Read-mostly collab dashboards | Hybrid private/shared collab apps | Anything user-facing in production |

## Common pitfalls (lifted from the comments in the source)

These are the comments worth re-reading after a `git pull`:

- **Forget `lustre.shutdown` on socket close → memory leak + zombie process.** (`01`'s `close_counter_socket` comments this explicitly.) For shared runtimes (`04`), use `deregister_subject` instead, since other clients still need the process alive.
- **Forget `attribute.type_("module")` on the runtime `<script>` and the custom element won't register.** (Comment in `01`'s `serve_html`.)
- **The `server_component.route(...)` path must match your Mist handler's WebSocket path.** Easy to drift when refactoring.
- **DOM event properties aren't enumerable by default — `server_component.include` is mandatory** for any field your decoder reads beyond the basics. (`03`, `04`, `05`.)
- **Mousemove without `event.throttle` will saturate your WebSocket.** (`04`'s 5 ms throttle is conservative; raise it if your component does cheap work.)
- **A `group_registry` topic doesn't replay history.** Late joiners need explicit state transfer — the `05` README is upfront that the example is incomplete in that regard.
- **The `06` CSRF token is global for demo simplicity only.** In production: per-session, server-stored, rotated.

## Related Work

- **[lustre](./web-apps.md#lustre)** — the framework these components are built on. Same `init`/`update`/`view`; the only difference is where they run.
- **[mist](./web-apps.md#mist)** — the HTTP server every example uses. WebSocket support, file serving, and `mist.send_text_frame` are all referenced above.
- **[wisp](./web-apps.md#wisp)** — Mist-based but higher level; you can adopt server components from a wisp app the same way (just plug your WebSocket route into wisp's handler-and-context pattern).
- **[Full-stack approaches compared](./web-apps.md#full-stack-approaches-compared-libero-vs-lustre-server-components-vs-glimr)** — server components vs `libero` (typed RPC SPA) vs `glimr` (batteries-included MVC). Each owns the state at a different layer.
- **[hot-reloading.md → "Lustre server components are a blind spot"](./hot-reloading.md#summary)** — the dev-loop story for server components is unsolved at snapshot. `radiate` should work in principle (BEAM module reload + WebSocket reconnect on page refresh), but no tool documents it explicitly.
- **[Lustre server components docs](https://hexdocs.pm/lustre/lustre/server_component.html)** — the `lustre/server_component` module reference.
- **[lustre-labs/lustre — examples/06-server-components](https://github.com/lustre-labs/lustre/tree/main/examples/06-server-components)** — the source these examples were lifted from.
