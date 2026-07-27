# Browser-based SSH terminals (for iframe / Notion embed)

> [!NOTE]
> **Status:** DRAFT · **Authoring:** AI-assisted, human-reviewed.

You want a live SSH shell inside a web page — an iframe you can drop into Notion, a docs page, or an internal dashboard. The browser can't speak SSH directly (no raw TCP), so every option here pairs an [xterm.js](https://xtermjs.org/) frontend with a server-side WebSocket → SSH proxy. This document ranks the open-source tools in that category by maintenance, fitness for iframe embedding, and deployment weight.

No live benchmarking was run — evaluation is based on repo metadata, documentation, and architecture review. Stats snapshot: **2026-04-18**.

## TL;DR

| If you want… | Use |
| --- | --- |
| **The single-purpose, actively-maintained default** — small Node.js server, Docker image, SFTP, all auth modes | **[WebSSH2](#webssh2-best-overall)** |
| **A full server-management dashboard** with SSH + tunnels + RDP/VNC + file manager (overkill for a single iframe, but batteries included) | **[Termix](#termix-best-for-full-platform)** |
| **A lighter iframe embed** that wraps the system `ssh` binary instead of a Node SSH library | **[WeTTY](#wetty-lighter-alternative)** |
| **Skip** [Shell In A Box](#shell-in-a-box-skip) | C daemon, commits dead since 2019, 202 open issues, PAM auth model doesn't fit web-form credentials |
| **Skip** [SSHy](#sshy-skip) | Pure-JS SSHv2 client abandoned 2018 (~7.5 years) — assume CVE backlog and deprecated KEX algorithms |
| **Skip** [GoTTY](#gotty-skip-not-ssh) | Not an SSH client — shares a local command; no per-user auth. Abandoned since 2017 |

> [!IMPORTANT]
> Every option requires you to run an **HTTPS-terminated, publicly reachable WebSocket proxy**. Notion's iframe embed (via Iframely) won't load `http://localhost` or self-signed certs — mixed-content and WSS rules apply. Plan for a VPS + reverse proxy (Caddy / nginx / Traefik) with a real TLS cert before you paste a URL into an `/embed` block.

> [!NOTE]
> Notion embeds are resolved through [Iframely](https://iframely.com/) and support ~1,900 domains out of the box. An arbitrary `https://ssh.example.com` URL is allowed, but the iframe is sandboxed — scripts and WebSocket connections work, but some browser features (clipboard, popups) may need `sandbox`/`allow` attributes the host page controls. For private/internal embeds, [super.so](https://super.so) or a self-hosted Notion-style renderer give more control over iframe attributes than Notion itself.

## Table of Contents

1. [Architecture shared by all options](#architecture-shared-by-all-options)
2. [Discovery](#discovery)
3. [Comparison](#comparison)
4. [Tool-by-tool](#tool-by-tool)
   - [WebSSH2](#webssh2-best-overall)
   - [Termix](#termix-best-for-full-platform)
   - [WeTTY](#wetty-lighter-alternative)
   - [Shell In A Box](#shell-in-a-box-skip)
   - [SSHy](#sshy-skip)
   - [GoTTY](#gotty-skip-not-ssh)
5. [Notion embedding notes](#notion-embedding-notes)
6. [Recommendation by use case](#recommendation-by-use-case)

## Architecture shared by all options

The browser cannot open a raw TCP socket to port 22. Every tool here follows the same split:

```
┌──────────────┐    WSS     ┌──────────────────┐    SSH/TCP   ┌──────────────┐
│ browser      │ ─────────▶ │ proxy (Node/Go/C)│ ───────────▶ │ remote host  │
│ xterm.js UI  │ ◀───────── │ ssh2 / OpenSSH   │ ◀─────────── │ sshd         │
└──────────────┘            └──────────────────┘              └──────────────┘
```

Implications:

- **The proxy holds the credentials.** Either the end-user types them into the web UI each session (WebSSH2, WeTTY, SSHy), or the proxy is preconfigured with a service account (Shell In A Box via PAM, Termix RBAC). For a public iframe you almost certainly want per-session user-entered credentials.
- **WSS (TLS) is mandatory for Notion.** Notion's embed page is HTTPS; a `ws://` or mixed-content URL is blocked by the browser before the proxy ever sees the request.
- **Pure client-side SSH doesn't exist in browsers.** "Client-side" tools (SSHy) still require a WebSocket proxy — it's just the SSH protocol parsing that moves to JS.

## Discovery

Search: GitHub + web for "browser SSH client", "web SSH terminal", "xterm.js SSH", "Notion embed terminal". Filter: must produce an embeddable HTTP(S) URL that speaks SSH; must be open source.

| Tool | Lang | Stars | License | Last commit / release | Status |
| --- | --- | --- | --- | --- | --- |
| **[billchurch/webssh2](https://github.com/billchurch/webssh2)** | Node | 2.7k★ | MIT | 2026-04-07 (v4.2.1) | 🟩🟩 Active |
| **[LukeGus/Termix](https://github.com/LukeGus/Termix)** | TS / Docker | 12.3k★ | Apache-2.0 | 2026-03-15 (v2.0.0) | 🟩🟩 Active |
| **[butlerx/wetty](https://github.com/butlerx/wetty)** | TS | 5.2k★ | MIT | 2023-09-16 (v2.7.0) | 🟩 Stale (~31 months since release) |
| **[shellinabox/shellinabox](https://github.com/shellinabox/shellinabox)** | C | 3.1k★ | GPL-2 | 2019-01-28 commit; 2025-09-06 release tag (v2.21) | 🟥 Commits stale ~7 years; release is version-bump only |
| **[stuicey/SSHy](https://github.com/stuicey/SSHy)** | JS | 577★ | MIT | 2018-10-29 | 🟥 Abandoned (~7.5 years) |
| **[yudai/GoTTY](https://github.com/yudai/gotty)** | Go | 19.5k★ | MIT | 2017-08 (v1.0.1) | 🟥 Abandoned; not SSH (local shell only) |

**Disregarded:**
- **GoTTY** — not an SSH tool. Shares whatever local command you start it with; no native remote SSH. Included only to clarify the scope mismatch.
- **Commercial/SaaS** (Apache Guacamole web UI, Tailscale SSH console, Teleport) — out of scope.

## Comparison

| Dimension | [WebSSH2](#webssh2-best-overall) | [Termix](#termix-best-for-full-platform) | [WeTTY](#wetty-lighter-alternative) | [Shell In A Box](#shell-in-a-box-skip) | [SSHy](#sshy-skip) |
| --- | --- | --- | --- | --- | --- |
| **Maintenance** | 🟩🟩 2026-04 | 🟩🟩 2026-03 | 🟩 2023-09 | 🟥 commits 2019 | 🟥 2018 |
| **Stars** | 2.7k | 12.3k | 5.2k | 3.1k | 577 |
| **License** | MIT | Apache-2.0 | MIT | GPL-2 | MIT |
| **Scope** | Single-purpose web SSH | Full server mgmt platform | Single-purpose web SSH | Arbitrary CLI → web | Single-purpose web SSH |
| **SSH backend** | [ssh2](https://github.com/mscdex/ssh2) (Node lib) | ssh2 + platform | system `ssh` binary | runs arbitrary cmd (can be `ssh`) | pure-JS SSHv2 over WS proxy |
| **Auth modes** | password, key, keyboard-interactive, SSO docs | per-user credentials, RBAC | password, pubkey | PAM / system auth | password, key (client-side) |
| **SFTP / file transfer** | ✅ | ✅ (file manager) | ❌ | ❌ | ❌ |
| **Docker image** | ✅ official, multi-arch | ✅ Compose w/ guacd | ✅ community | via distro pkg | — |
| **Iframe-friendly** | ✅ single URL path | ✅ but UI is a full dashboard | ✅ "same-origin by default" — configure CSP/`X-Frame-Options` | ⚠️ self-signed cert issues historically | ✅ static HTML + proxy |
| **Open issues** | 6 | 0 | 10 | 202 | 22 |
| **Weight** | 🟩🟩 one Node process | 🟥 multi-service Compose | 🟩🟩 one Node process | 🟩 one C daemon | 🟩 static files + wsproxy |

**Reading the table:** WebSSH2 and Termix are the only two actively maintained. Termix is heavier — it's a full dashboard, not a single iframe widget. WebSSH2 is a single URL that renders one SSH session and nothing else, which is exactly what an iframe wants. WeTTY sits behind both on age but is the smallest option that still works in 2026. Shell In A Box and SSHy are museum pieces.

## Tool-by-tool

### WebSSH2: best overall

[repo](https://github.com/billchurch/webssh2) · MIT · 2.7k★ · last commit 2026-04-07 (v4.2.1) · 6 open issues

A Node.js server that accepts WebSocket connections, parses SSH protocol via [mscdex/ssh2](https://github.com/mscdex/ssh2), and renders xterm.js on the browser side. Single responsibility: "give me one SSH session at a URL." Exactly the shape an iframe wants.

**Why it wins:**
- **Only option with commits in 2026.** Active release cadence (v4.2.1 in April 2026), Playwright test suite, SonarQube quality gate, multi-arch Docker images from GHCR.
- **All three auth modes** — password, private key, keyboard-interactive — plus SSO documentation. The user types credentials in a web form; the server never needs a config file with secrets.
- **SFTP built in.** File upload/download in the same UI, same session.
- **CIDR subnet ACL.** Optional allow-list for which remote hosts the proxy will forward to — important if you're exposing this on the open web.

**Trade-offs:**
- Still your job to front it with a reverse proxy that terminates TLS. Notion won't load a `ws://` or self-signed `wss://` URL.
- The web UI is WebSSH2-branded; restyling is a manual CSS override.
- **Install gotcha (2026-04-19):** the published Docker image is not a turnkey run. Repo clone required, and the build expects a TypeScript toolchain in the environment — `npm install && npm run build` before the server starts. Plan a multi-stage Dockerfile if you want a clean deploy artifact.

**Setup sketch:**
```sh
docker run -p 2222:2222 ghcr.io/billchurch/webssh2:latest
# behind Caddy (automatic TLS):
# ssh.example.com {
#   reverse_proxy localhost:2222
# }
# Then iframe: <iframe src="https://ssh.example.com/ssh"></iframe>
```

### Termix: best for full platform

[repo](https://github.com/LukeGus/Termix) · Apache-2.0 · 12.3k★ · last release 2026-03-15 (v2.0.0) · 0 open issues

Not really a comparable to WebSSH2 — this is an **all-in-one server management dashboard**. SSH terminal (up to 4 split panels), SSH tunneling with auto-reconnect, remote file manager, Docker container control, RDP/VNC via bundled `guacd`, RBAC, stats dashboards. Also ships as desktop app, PWA, and mobile app.

**When it's the right pick:**
- You want a single self-hosted tool for your whole team's fleet, not just one iframe.
- You care about tunneling, file ops, and non-SSH protocols (RDP/VNC).
- You accept running a Docker Compose stack with guacd + DB + web tier.

**When it's the wrong pick:**
- You just want one `<iframe>` that opens one SSH session. Termix's UI is a whole app — multiple panes, navigation, settings. Dropping it in an iframe puts an entire dashboard on your Notion page. Overkill.
- 0 open issues is a clean-maintenance signal, but also means a small-team project — file a bug and you're likely talking to the same maintainer who wrote every feature.

**Setup sketch:** [docker-compose.yml](https://github.com/LukeGus/Termix#installation) from the repo; expects a DB and guacd sidecar.

### WeTTY: lighter alternative

[repo](https://github.com/butlerx/wetty) · MIT · 5.2k★ · last release 2023-09-16 (v2.7.0) · 10 open issues

TypeScript Node server that execs the system `ssh` binary and pipes it over WebSocket to xterm.js. Simpler than WebSSH2 because it doesn't parse SSH itself — it delegates to OpenSSH. Inherits OpenSSH's full auth surface (config file, known_hosts, agents) for free.

**Trade-offs:**
- **~31 months since last release.** Not dead — 41 contributors, recent small commits — but the pace is low. 🟩 not 🟩🟩.
- **Same-origin iframe by default.** You'll set CSP / `X-Frame-Options` headers on the reverse proxy to allow Notion's embed domain.
- Docs mention iframe embedding explicitly, unlike most alternatives.
- No SFTP; shell only.
- **Install gotcha (2026-04-19):** fresh Docker install of the `:latest` tag renders a **black screen** in the browser — xterm.js loads but the terminal never initializes. Workaround is to pin an older image tag (downgrade from latest). Stale-release symptom: client/server version drift with a dependency that moved on.

Pick it over WebSSH2 if you want to reuse the host's `~/.ssh/config` and agent instead of entering credentials in the browser every time.

### Shell In A Box: skip

[repo](https://github.com/shellinabox/shellinabox) · GPL-2 · 3.1k★ · last commit 2019-01-28 · 202 open issues

Classic C daemon that exposes arbitrary CLI tools (including `ssh`) at `https://host:6175`. Community fork of an older dead project. A v2.21 release tag was cut in 2025-09, but the commit history still ends in 2019 — the "release" is a metadata bump, not new code. 202 open issues.

**Why not:**
- **7 years of commit silence.** Security-sensitive surface (SSL, PAM) left on a pre-2020 C codebase.
- **Historical Chrome self-signed-cert friction** in iframes. Solvable but adds steps.
- **GPL-2** vs. MIT/Apache of every other option here — the others are easier to fork and embed.
- **PAM auth model** is a poor fit for "user types credentials into a web form" — it wants a system account.

If you're already running Shell In A Box, fine. Don't adopt it new.

### SSHy: skip

[repo](https://github.com/stuicey/SSHy) · MIT · 577★ · last commit 2018-10-29 · 22 open issues

Advertised as "pure client-side" — the SSH protocol is implemented in browser JS, with a bundled `wsproxy` submodule that does only the TCP-over-WebSocket tunneling. Clever architecture, but **abandoned for ~7.5 years**. A SSHv2 client implementation that hasn't been touched since 2018 is a security posture you should assume the worst about (KEX algorithm deprecations, CVE backlog).

Skip for any production use.

### GoTTY: skip (not SSH)

[repo](https://github.com/yudai/gotty) · MIT · 19.5k★ · last release 2017-08 · 113 open issues

Commonly surfaced by web searches for "browser terminal," but it is **not a browser SSH client**. It shares whatever local command you run it against (`gotty bash`, `gotty ssh user@host`) — so getting SSH requires you to run `ssh` on the proxy machine, with the proxy's credentials, and forward the PTY. No per-user auth. Also: abandoned since 2017.

Listed here only so you don't waste an afternoon discovering the scope mismatch yourself.

## Notion embedding notes

- Notion `/embed` blocks resolve through [Iframely](https://iframely.com/). Any public HTTPS URL works; the 1,900-domain "supported services" list is for rich-card rendering, not iframe gating.
- **Mixed content is blocked.** Your proxy must be reachable at `https://` with a real (Let's Encrypt / ZeroSSL) certificate. `http://localhost:2222` will not render.
- **WebSocket URL must be `wss://`.** Configure your reverse proxy to upgrade WebSocket and terminate TLS in front of the Node/C process.
- **Sandbox attributes:** Notion controls the outer iframe; you cannot set `sandbox` or `allow` attributes on it. Features like clipboard access, fullscreen, and keyboard capture may be constrained. Xterm.js's keyboard handling works; clipboard integration (Ctrl+Shift+C) may be flaky.
- **Authentication model for a Notion-embedded terminal:** prefer per-session user-entered credentials (WebSSH2) over pre-provisioned accounts (Shell In A Box). A public Notion page is not a privileged boundary.
- **Alternative host pages:** if you control the surrounding page ([super.so](https://super.so), a static site wrapping Notion content, or your own docs portal), you get iframe `sandbox`/`allow` control back and can loosen or tighten permissions appropriately.

## Recommendation by use case

| Use case | Pick | Then… |
| --- | --- | --- |
| **Single iframe, one SSH session, Notion embed** | **WebSSH2** | Docker run → Caddy reverse proxy → paste `https://ssh.example.com/ssh` into a Notion `/embed` block. |
| **Internal server dashboard for your team** (many hosts, tunnels, files) | **Termix** | Compose stack on an internal VPS; gate with OAuth or VPN; iframe the terminal route only if you need Notion visibility, else link out to the full UI. |
| **Reuse host's `~/.ssh/config` and agent** (no web-form credential entry) | **WeTTY** | Same reverse-proxy pattern as WebSSH2; accept 🟩 maintenance staleness. |
| **Existing Shell In A Box deployment** | Keep it if it works | Plan migration to WebSSH2 at your next refresh. |
| **Fully hosted SaaS alternative** | Commercial (Teleport, Tailscale SSH, Apache Guacamole SaaS) | Out of scope here, but worth evaluating if self-hosting the TLS + WSS + SSH-proxy stack isn't a good use of your time. |

**General advice:** the proxy is a **credential-handling web service exposed to the open internet**. Put it behind a reverse proxy with TLS, a strong rate limit, and — if the embedding host allows — a CIDR allow-list of source IPs or an auth layer (basic auth, OAuth proxy, Tailscale Funnel). Don't expose port 2222 naked because a tutorial said so.

## Sources

- [billchurch/webssh2](https://github.com/billchurch/webssh2)
- [LukeGus/Termix](https://github.com/LukeGus/Termix)
- [butlerx/wetty](https://github.com/butlerx/wetty)
- [shellinabox/shellinabox](https://github.com/shellinabox/shellinabox)
- [stuicey/SSHy](https://github.com/stuicey/SSHy)
- [yudai/gotty](https://github.com/yudai/gotty)
- [xterm.js](https://xtermjs.org/)
- [mscdex/ssh2](https://github.com/mscdex/ssh2)
- [Notion — Embeds, bookmarks & link mentions](https://www.notion.com/help/embed-and-connect-other-apps)
- [Iframely](https://iframely.com/)
