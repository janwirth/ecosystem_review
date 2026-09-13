# Declarative infrastructure — one repo for Hetzner, Cloudflare, Headscale and Caddy

> [!NOTE]
> **Status:** DRAFT · **Authoring:** AI-assisted, human-reviewed. This is a **research concept article**, not a package leaderboard. It describes a target architecture and the evidence for and against it. There is a scored tool comparison in [The IaC landscape](#the-iac-and-config-management-landscape), but the article's output is a *design*, not a ranking.

**Snapshot 2026-09-13.** Prices, licences, versions and star counts were captured on this date from the sources listed in [Discovery & sources](#discovery--sources). Where a number could not be fetched from a primary source it is marked ⬜ and the secondary is named.

> *You've decided what you're building and [how much machinery it needs](../application-types/choosing-a-web-presence-stack.md). This article is about the layer underneath: **the machine that makes the machines**, and whether you can describe all of it in one git repository that a stranger — or a future you — can read.*

## Table of contents

1. [What this article is, and the assumptions it makes](#what-this-article-is-and-the-assumptions-it-makes)
2. [The constraint — "everything open source"](#the-constraint--everything-open-source)
3. [Architecture — how the services interact](#architecture--how-the-services-interact)
4. [The IaC and config-management landscape](#the-iac-and-config-management-landscape)
5. [What "declarative" can and cannot reach](#what-declarative-can-and-cannot-reach)
6. [Repo layout — one baseline, two guides](#repo-layout--one-baseline-two-guides)
7. [Guide A — development environments](#guide-a--development-environments)
8. [Guide B — production for clients](#guide-b--production-for-clients)
9. [SSH key management](#ssh-key-management)
10. [Secrets checked into the repo](#secrets-checked-into-the-repo)
11. [Blast radius, and making encryption convenient](#blast-radius-and-making-encryption-convenient)
12. [The turn-key concept — bootstrap and 2FA on apply](#the-turn-key-concept--bootstrap-and-2fa-on-apply)
13. [Cost — auction dedicated vs cloud VPS](#cost--auction-dedicated-vs-cloud-vps)
14. [Managed vs unmanaged for client production](#managed-vs-unmanaged-for-client-production)
15. [What's missing / honest gaps](#whats-missing--honest-gaps)
16. [Discovery & sources](#discovery--sources)
17. [Cross-links](#cross-links)

## What this article is, and the assumptions it makes

The goal, stated plainly: **one git repository that describes every machine, every DNS record, every firewall rule, every user account and every secret across personal, shared-dev, collaborator and client-production environments** — and does so declaratively enough that a rebuild from bare metal is a command, not a memory exercise.

That goal is achievable for roughly 85% of the surface area. The remaining 15% is where this article spends most of its words, because that is where real deployments rot.

> [!IMPORTANT]
> **Two assumptions are being made on the reader's behalf. Both come from an ambiguous source sentence and both are stated here so they can be corrected.**
>
> 1. **"Prod should not…"** — the originating requirement note ends mid-sentence: *"I want to manage as much as possible declaratively up to installation of tools like tmux, kakoune, claude for dev, punching holes into the infra with caddy. Prod should not"*. This article reads that as **"production should not carry the developer toolchain, and should not have ad-hoc holes punched into it."** Everything in [Guide B](#guide-b--production-for-clients) follows from that reading: prod gets a strictly smaller package set, no interactive editors, no agent CLIs, no drift tolerance, and no hand-added Caddy routes.
> 2. **"Token separation checked into codebase"** is read as *"encrypted secrets live in the repo, and the keys that decrypt them are separated per environment"* — not *"plaintext tokens in git"*. See [Secrets checked into the repo](#secrets-checked-into-the-repo).
>
> If either reading is wrong, the sections built on it need revisiting rather than patching.

Three further scope decisions:

- **Kubernetes is out of scope.** Nothing here needs a scheduler. A cluster would add a control plane that must itself be declared, backed up and upgraded, in exchange for bin-packing benefits that do not apply at one-to-ten machines per environment.
- **The article is opinionated about the destination but honest about the route.** Several pieces of the "turn-key" endpoint ([§12](#the-turn-key-concept--bootstrap-and-2fa-on-apply)) do not exist as products today and are labelled as concept.
- **Nothing here is a substitute for backups.** Declarative infrastructure recreates *machines*. It does not recreate *data*. See [What's missing](#whats-missing--honest-gaps).

## The constraint — "everything open source"

The stated constraint is that the stack should be open source, with isolation provided by VPS boundaries and Cloudflare's network protection. Those two halves of the sentence are in tension, and it is worth naming the tension before designing around it.

**Cloudflare is not open source.** The edge — the WAF, the anycast network, the bot classifier, the Access identity gate — is proprietary SaaS running on someone else's hardware, terminating your TLS. What *is* open source is the client-side piece: `cloudflared`, the tunnel daemon, is Apache-2.0 (15,594★, latest `2026.9.1`, 2026-09-11). The daemon being open does not make the service open; it makes the *connector* replaceable only in the sense that you could write another client for the same proprietary protocol.

So the honest framing is: **this is a mostly-open-source stack with one deliberate proprietary dependency, chosen because the thing it provides — absorbing volumetric attacks at a global anycast edge — cannot be self-hosted at any price a small shop can pay.** That is a defensible trade. It should be a *conscious* one.

### What you give up, concretely

| Concern | Reality at snapshot date |
|---|---|
| **TLS termination** | Cloudflare sees plaintext of every proxied request unless you use Keyless SSL (Enterprise). This is the actual cost of the orange cloud. |
| **Availability coupling** | A Cloudflare control-plane incident takes your sites down even though your origins are healthy. You inherit their blast radius. |
| **Content-type terms** | Cloudflare's [service-specific terms](https://www.cloudflare.com/service-specific-terms-application-services/) reserve the right "to disable or limit your access to or use of the CDN … if you use or are suspected of using the CDN without such Paid Services to serve video or a disproportionate percentage of pictures, audio files, or other large files." Media-heavy client sites need Images/Stream or a different CDN. |
| **Exit cost** | Low for DNS and proxying (move nameservers). High for Access policies, Workers, and anything that grew into Zero Trust. |

### The open-source alternatives, and why they are not drop-in

| Tool | Licence | Stars | What it replaces | Why it is not a drop-in |
|---|---|---:|---|---|
| [**Pangolin**](https://github.com/fosrl/pangolin) | ⚠️ **open-core** — repo `LICENSE` is a mix of "Fossorial Commercial License" and AGPL-3.0 portions | 22,731 | Cloudflare Tunnel + Access (self-hosted tunnelled reverse proxy with identity) | It is not a drop-in for the *edge*: your VPS is still the thing absorbing the traffic. Also not fully OSS — verify which components you need are under the AGPL half before committing. |
| [**Caddy**](https://github.com/caddyserver/caddy) + [**CrowdSec**](https://github.com/crowdsecurity/crowdsec) | Apache-2.0 / MIT | 75,703 / 14,829 | WAF-ish behavioural blocking at the origin | Blocks at the origin, which means the traffic already arrived. Excellent against credential stuffing and scrapers; useless against a volumetric L3/4 flood. |
| [**BunkerWeb**](https://github.com/bunkerity/bunkerweb) | AGPL-3.0 | 10,935 | A genuine self-hosted WAF (ModSecurity + CRS, hardened nginx) | AGPL-3.0 matters if you resell hosting. Same origin-side limitation. Heavier to operate than Caddy. |

> [!IMPORTANT]
> **The open-source substitutes replace the WAF, not the anycast.** If you drop Cloudflare, you keep every capability *except* the one you cannot build: hundreds of points of presence that absorb a DDoS before it reaches your €57/month box. Choose Cloudflare for the anycast and accept the proprietary edge, or choose an origin-side OSS WAF and accept that a determined flood takes you offline. There is no third option at this budget.

A pragmatic middle: **keep Cloudflare for DNS and proxying, but keep the origin independently functional.** Caddy terminates TLS with its own certificates (via DNS-01, which works behind the orange cloud), the app never depends on `CF-*` headers for correctness, and Access is used only for admin surfaces that have a non-Cloudflare fallback path over the [Headscale mesh](#architecture--how-the-services-interact). Then "drop Cloudflare" is a DNS change, not a rewrite.

## Architecture — how the services interact

Four systems, four jobs, and — this is the part that is usually left implicit — **two entirely separate traffic paths**. Public traffic and administrative traffic never share a door.

```
                            ┌──────────────────────────────────────────┐
                            │             PUBLIC INTERNET              │
                            └────────────────────┬─────────────────────┘
                                                 │ (1) DNS lookup: app.client.tld
                                                 ▼
        ┌──────────────────────────────────────────────────────────────────────────┐
        │  CLOUDFLARE  ·  proprietary edge (see §2)                                │
        │  • authoritative DNS  • orange-cloud proxy  • WAF / rate limit / bots    │
        │  • edge TLS           • Access (identity gate)  • Tunnel (cloudflared)   │
        └───────────┬──────────────────────────────────────────┬───────────────────┘
                    │ (2a) proxied HTTPS → origin IP           │ (2b) outbound-only
                    │      origin firewall: CF ranges ONLY     │      tunnel; origin
                    ▼                                          ▼      has no open port
 ┌────────────────────────────────────────────────────────────────────────────────────┐
 │  HETZNER  ·  one project per environment  ( = one API token per environment )       │
 │  ┌──────────────────────────────────────────────────────────────────────────────┐  │
 │  │  Cloud VPS (CPX/CCX)  ·  or  ·  auction / -LTD dedicated                      │  │
 │  │                                                                              │  │
 │  │   ┌──────────────┐    listens :80/:443 — reachable only from CF ranges        │  │
 │  │   │    CADDY     │──► reverse proxy + automatic TLS (DNS-01 via CF API token) │  │
 │  │   └──────┬───────┘                                                            │  │
 │  │          │ loopback / private container network — never published to 0.0.0.0  │  │
 │  │   ┌──────▼─────┐  ┌────────────┐  ┌────────────┐                              │  │
 │  │   │    app     │  │  postgres  │  │   worker   │                              │  │
 │  │   └────────────┘  └────────────┘  └────────────┘                              │  │
 │  │                                                                              │  │
 │  │   ┌──────────────────────────────────────────────────────────────────────┐   │  │
 │  │   │  tailscaled ──── WireGuard (UDP 41641, outbound) ────► HEADSCALE      │   │  │
 │  │   │  sshd bound to the tailnet address only — NO public :22               │   │  │
 │  │   └──────────────────────────────────────────────────────────────────────┘   │  │
 │  └──────────────────────────────────────────────────────────────────────────────┘  │
 └────────────────────────────────────────────────────────────────────────────────────┘
                    ▲                                          ▲
                    │ (3) admin plane: encrypted mesh,          │
                    │     no listening port on the public IP    │
        ┌───────────┴────────────┐                  ┌───────────┴────────────┐
        │  your laptop           │                  │  collaborator laptop   │
        │  tailscale up --login- │                  │  (ACL-scoped to the    │
        │  server=hs.example.net │                  │   dev tag only)        │
        └────────────────────────┘                  └────────────────────────┘

        HEADSCALE itself runs on its own small VPS, behind Caddy, proxied by
        Cloudflare — it is the one service that must be publicly reachable,
        because clients need to reach the control plane to join the mesh.
```

### The two traffic paths

| | **Public ingress** | **Admin / private** |
|---|---|---|
| Entry point | Cloudflare edge (anycast) | Headscale-coordinated WireGuard mesh |
| Transport | HTTPS, terminated at CF, re-encrypted to origin | WireGuard (noise protocol), end-to-end between peers |
| Origin ports open to the world | `443` (and `80` for redirect), restricted by `hcloud_firewall` to Cloudflare's published ranges — or **zero** ports if using Tunnel | **none** |
| SSH | not available | `ssh user@100.x.y.z` over the tailnet, or `tailscale ssh` |
| Who can reach it | everyone | only devices enrolled in the tailnet, filtered by Headscale ACLs |
| Failure mode | Cloudflare incident = site down | Headscale down = **existing** WireGuard sessions keep working; *new* nodes cannot join and key rotation stalls |

The last row is the important one and it is frequently misunderstood: **Headscale is a control plane, not a data plane.** Peers exchange keys and endpoints through it, then talk directly. A Headscale outage is a management outage, not a connectivity outage — as long as node keys have not expired. Set a long key-expiry (or disable expiry for server nodes) and a Headscale outage becomes a nuisance rather than a lockout.

### Why no public SSH

Removing public `:22` removes the entire category of SSH credential-stuffing, and it removes the "I'll just add my key to `authorized_keys` temporarily" habit that silently defeats declarative user management. With the mesh in place:

- `sshd` binds only the tailnet interface (`ListenAddress 100.64.x.y`), enforced by the same template that installs it.
- The Hetzner firewall (declared as `hcloud_firewall`, not clicked in a console) has **no** rule for `22/tcp` at all — so a misconfigured `sshd` fails closed.
- Emergency access is the provider's out-of-band console (Hetzner Cloud's noVNC console, or a KVM on dedicated), which is a deliberately awkward path you use twice a year.

> [!CAUTION]
> **Headscale's own documentation scopes it to one tailnet.** From [headscale.net](https://headscale.net/stable/): *"It implements a narrow scope, a **single** Tailscale network (tailnet), suitable for a personal use, or a small open-source organisation."* It is BSD-3-Clause, 43,803★, and still pre-1.0 (`v0.29.3`, 2026-07-29).
>
> That is fine for *your* devices reaching *your* servers across all environments. It is **not** a multi-tenant product, and putting several unrelated clients' production machines into one tailnet means one compromised collaborator device has a route to all of them. The mitigations, in increasing order of cost:
> 1. **Headscale ACLs** partition the single tailnet by tag (`tag:dev`, `tag:prod-acme`). Real isolation, one config file, but it is a policy boundary — a Headscale compromise collapses it.
> 2. **One Headscale instance per blast-radius group** (e.g. one for dev, one per production client). More instances to run, genuine separation.
> 3. **Tailscale's hosted control plane** for client production, Headscale for your own. Abandons the open-source constraint for the highest-consequence tier.
>
> This article recommends **(1) for dev and (2) for client production** — see [Guide B](#guide-b--production-for-clients).

### Where Caddy fits

Caddy (Apache-2.0, 75,703★, `v2.11.4` 2026-06-03) is the only thing on the box that owns port 443. Its job list is short and it is *the* place where "punching a hole into the infra" is expressed:

- Reverse proxy to app containers on loopback.
- Automatic TLS. Behind Cloudflare's proxy you want the **DNS-01** challenge (via the `caddy-dns/cloudflare` module and a scoped `Zone:DNS:Edit` token) rather than HTTP-01, because the orange cloud intercepts the HTTP challenge path and because DNS-01 keeps working with zero public ports.
- Basic auth / forward-auth for surfaces that need a gate but do not justify Access.

Every route is a block in a Caddyfile that is generated from the environment's declared service list. In dev, developers may add blocks freely ([§7](#guide-a--development-environments)). In prod, a route that is not in the repo does not exist ([§8](#guide-b--production-for-clients)).

## The IaC and config-management landscape

Two different jobs get conflated under "infrastructure as code":

- **Provisioning** — *make the resources exist*: servers, networks, firewalls, DNS records, SSH keys, API tokens. The resource either exists with the declared attributes or it does not. This is a job for a tool with **state**.
- **Configuration** — *make the inside of the machine correct*: packages, users, service units, config files, container deployments. This is a job for a tool that **converges** a machine toward a description, repeatedly.

Almost every failed "we'll do it all in Terraform" story is a provisioning tool being asked to do configuration, or vice versa.

### Comparison

All metrics fetched via `gh api repos/OWNER/REPO` on **2026-09-13**. "Last release" is the latest GitHub *release*, which for some projects is not the shipping channel — flagged where that is true.

| Tool | Licence | Language / DSL | Job | State model | Agentless? | Stars | Last release |
|---|---|---|---|---|---|---:|---|
| [**OpenTofu**](https://github.com/opentofu/opentofu) | **MPL-2.0** | HCL | Provision | Explicit state file; **encryption built in since 1.7** | yes (API calls) | 30,169 | `v1.12.6` · 2026-08-19 |
| [**Terraform**](https://github.com/hashicorp/terraform) | ⚠️ **BUSL-1.1** (Licensor: *International Business Machines Corporation*) | HCL | Provision | Explicit state file; encryption via backend/third-party only | yes | 49,648 | `v1.16.2` · 2026-09-09 |
| [**Pulumi**](https://github.com/pulumi/pulumi) | Apache-2.0 | TypeScript / Python / Go / C# / Java / YAML | Provision | Explicit state; hosted or self-managed backend | yes | 25,679 | `v3.262.0` · 2026-09-10 |
| [**Terragrunt**](https://github.com/gruntwork-io/terragrunt) | MIT | HCL wrapper | Provision orchestration | delegates | yes | 9,831 | ⬜ *(rolling; see repo)* |
| [**Ansible**](https://github.com/ansible/ansible) | GPL-3.0 | YAML playbooks + Jinja2 | Configure | **Stateless** — converges by running | **yes** (SSH push) | 70,667 | `v2.21.4` · 2026-09-08 |
| [**Chef**](https://github.com/chef/chef) | Apache-2.0 *(source)* — ⚠️ binaries under the **Chef EULA** | Ruby DSL | Configure | Server-held node objects | no (agent) | 8,236 | ⬜ GitHub releases stale since 2020 — ships via Progress channels |
| [**Puppet**](https://github.com/puppetlabs/puppet) | Apache-2.0 *(source)* — ⚠️ **packages moved to a private repo**, EULA, 25-node limit | Puppet DSL | Configure | Server-compiled catalogues | no (agent) | 7,927 | `7.34.0` · 2024-10-22 |
| [**OpenVox**](https://github.com/OpenVoxProject/puppet) | Apache-2.0 | Puppet DSL | Configure | as Puppet | no (agent) | 189 | ⬜ *(active; pushed 2026-09-11)* |
| [**Salt**](https://github.com/saltstack/salt) | Apache-2.0 | YAML + Jinja2 | Configure | Master/minion pillar | optional (`salt-ssh`) | 15,653 | `v3008.1-2` · 2026-07-26 |
| [**NixOS**](https://github.com/NixOS/nixpkgs) | MIT | Nix expressions | Configure (**whole-system**) | **Immutable generations** — the closure *is* the state | yes (push via SSH) | 26,110 | rolling channels |
| [**nixos-anywhere**](https://github.com/nix-community/nixos-anywhere) | MIT | Nix + shell | Bootstrap NixOS onto any Linux via SSH | n/a | yes | 3,440 | `1.13.0` · 2025-11-13 |
| [**Colmena**](https://github.com/nix-community/colmena) | MIT | Nix | Multi-host NixOS deploy | n/a | yes | 2,342 | `v0.4.0` · 2023-05-15 ⚠️ stale releases |
| [**cloud-init**](https://github.com/canonical/cloud-init) | GPL-3.0 | YAML (`#cloud-config`) | **First-boot only** | none | yes (runs on the box) | 3,810 | `26.2` · 2026-07-29 |
| [**Kamal**](https://github.com/basecamp/kamal) | MIT | YAML | Deploy containers to bare servers | none (Docker is the state) | yes (SSH) | 14,579 | `v2.12.0` · 2026-06-18 |
| [**Docker Compose**](https://github.com/docker/compose) | Apache-2.0 | YAML | Describe a service set on one host | container runtime | n/a | 38,144 | `v5.5.1` · 2026-09-03 |

**Providers you will actually use:**

| Provider | Licence | Stars | Latest | Note |
|---|---|---:|---|---|
| [`hetznercloud/hcloud`](https://github.com/hetznercloud/terraform-provider-hcloud) | MPL-2.0 | 738 | `v1.69.0` · 2026-09-11 | Official. Resources include `hcloud_server`, `hcloud_ssh_key`, `hcloud_firewall`, `hcloud_network`, `hcloud_primary_ip`, `hcloud_volume`, `hcloud_storage_box`, and — since `v1.54.0` (2025-10-07) — `hcloud_zone` / `hcloud_zone_rrset` for DNS. |
| [`cloudflare/cloudflare`](https://github.com/cloudflare/terraform-provider-cloudflare) | Apache-2.0 | 1,321 | `v5.25.0` · 2026-09-11 | ⚠️ v5 is *"a ground-up rewrite of the provider, using code generation from our OpenAPI spec"*. Breaking against v4; 4.x now receives only critical security fixes. Budget real time for the migration. |
| ~~`germanbrew/hetznerdns`~~ | MPL-2.0 | 48 | `v3.5.0` · 2025-10-24 | 🪦 **Archived and deprecated as of 2025-11-10.** Its README `[!CAUTION]` redirects to the hcloud provider. If you find a tutorial using it, the tutorial is stale. |

> [!CAUTION]
> **Three of the four classical config-management tools have exited open source in some direction. This is the single most important fact for a stack with an "everything open source" constraint.**
>
> - **Terraform** — relicensed to the Business Source License 1.1. The repo's `LICENSE` today names the Licensor as *International Business Machines Corporation (IBM)* and the Licensed Work as *"Terraform Version 1.6.0 or later"*. Fine for most internal use; a lawyer's question if you ever resell infrastructure tooling.
> - **Chef** — the *source* remains Apache-2.0 on GitHub, but [Chef's own documentation](https://docs.chef.io/licensing/) states that binaries, modules, containers and executables released outside GitHub "are governed by the Chef EULA … [and] aren't considered open source." The Apache-2.0 rebuild is [Cinc](https://cinc.sh/).
> - **Puppet** — in November 2024 Perforce announced that from early 2025 new binaries and packages ship to a private repository, with contributor access under a EULA and a commercial licence required beyond 25 nodes. Vox Pupuli [declined to sign](https://voxpupuli.org/blog/2025/05/19/perforce-eula/) — *"The restrictions placed on usage prevent effective testing and distribution of modules"* — and the community fork is [**OpenVox**](https://github.com/OpenVoxProject/puppet) (Apache-2.0, active, 189★ at snapshot).
>
> **Ansible (GPL-3.0), Salt (Apache-2.0), NixOS (MIT) and OpenTofu (MPL-2.0) are the tools that have not had a licensing event.** If the open-source constraint is real rather than aspirational, pick from that list.

### The recommendation, and why

**OpenTofu for provisioning + Ansible for configuration, with cloud-init doing exactly one thing at first boot.**

| Layer | Tool | Rationale |
|---|---|---|
| Resources (servers, DNS, firewalls, SSH keys, tokens) | **OpenTofu** | MPL-2.0 with no licensing cliff ahead. Drop-in for existing HCL. The decisive feature for this design is **state encryption**, shipped in `v1.7.0` (2024-04-30) — see [§10](#secrets-checked-into-the-repo). Terraform's HCL skills and provider ecosystem transfer unchanged. |
| First boot | **cloud-init** | Passed to `hcloud_server.user_data`. Its *only* job: create the admin user, install the declared SSH keys, install `tailscale`, join the Headscale mesh with a pre-authorised key, install Python. Then stop. cloud-init is not a config-management tool and treating it as one produces machines whose configuration exists only in a string inside a `.tf` file. |
| Everything inside the machine | **Ansible** | Agentless over the SSH-on-tailnet path you already built, so no extra daemon and no extra port. GPL-3.0, no licensing event, and the one tool in this category whose knowledge is genuinely portable to any client's existing setup. |
| Applications | **Docker Compose**, driven by an Ansible role | The service set for a host is one YAML file that a human can read. **Kamal** is a strong alternative if every environment is a single-app-plus-database deployment and you want zero-downtime deploys without writing them. |

**Why not Pulumi?** Real languages give you real abstractions and real bugs. For a stack whose entire resource graph is "a handful of servers, DNS records and firewall rules per environment", HCL's constrained expressiveness is a feature: every reviewer can read it, and there is no dependency tree to audit. Pulumi wins when resource graphs are generated programmatically at a scale HCL cannot express.

**Why not NixOS?** This is the strongest technical alternative and it deserves an honest hearing, because it is the only option that makes the whole machine — not just the resources — reproducible from the repo. `nixos-anywhere` (MIT, 3,440★) installs NixOS onto any Linux box reachable by SSH, including a Hetzner rescue system, which is exactly the awkward step in the dedicated-server workflow. Two reasons it is not the default recommendation here:

1. **Collaborator cost.** The design has to accommodate *"collaborators"* who get a dev environment. Ansible is legible to anyone who has seen YAML; Nix is a language, a package manager and a system model that must be learned before the first useful change.
2. **Colmena's last tagged release is `v0.4.0` (2023-05-15)**, which is a genuine maintenance signal for the multi-host deployment layer even though the repo itself is active (pushed 2026-09-10).

If the stack is only ever operated by people fluent in Nix, invert the recommendation: OpenTofu for the Hetzner/Cloudflare resources, NixOS for everything above the kernel, and skip Ansible entirely. The repo layout in [§6](#repo-layout--one-baseline-two-guides) accommodates either by swapping one directory.

## What "declarative" can and cannot reach

The ambition is to declare everything "up to installation of tools like tmux, kakoune, Claude for dev". That ambition is mostly reachable, and the places where it is not are predictable.

### The four tiers of declarability

| Tier | Example | Declarable? | Tool |
|---|---|---|---|
| **1. Resources** | server exists, DNS record points at it, firewall allows CF ranges, SSH key registered | ✅ fully | OpenTofu |
| **2. System state** | packages installed, users exist, `sshd` bound to the tailnet, systemd units enabled, Caddyfile content | ✅ fully | Ansible / NixOS |
| **3. User environment** | `tmux.conf`, Kakoune config + plugins, shell, `direnv`, an agent CLI and its MCP config | 🟨 mostly — see below | Ansible role over a dotfiles repo, or Nix home-manager |
| **4. Ephemeral state** | database rows, uploaded files, an LLM session, a running `tmux` pane | ❌ never | backups, not IaC |

Tier 3 is where the honest caveats live:

- **Package availability lags.** `tmux` is in every distro. **Kakoune** is in Debian/Ubuntu but often several minor versions behind; if you want current, the declarative form is "build from a pinned git tag", which is a role, not a package line.
- **Agent CLIs are installed by curl-to-shell.** Vendor install scripts for coding agents are the least declarative thing in the stack: unpinned, network-dependent, and self-updating after install. The honest declarative form is to **pin a version and record it**, accept that the tool may self-update out from under the declaration, and put the config (not the binary) under management. Treat the installed version as a fact to be re-asserted, not a fact to be trusted.
- **Credentials for those tools are per-human, not per-machine.** An API key for a coding agent belongs to a person. It should arrive through the same [`sops exec-env`](#blast-radius-and-making-encryption-convenient) path as everything else and must never be baked into a machine image shared by collaborators.

### Punching holes with Caddy

"Punching a hole" means exposing something that was internal — a dev server, a preview build, a database admin UI — on a real hostname with real TLS. Declaratively, a hole is three facts:

1. A DNS record (`cloudflare_dns_record`, OpenTofu).
2. A Caddy site block routing that hostname to a local port (Ansible template).
3. An access decision: public, Cloudflare Access policy, Caddy basic-auth, or **tailnet-only** (bind the listener to the mesh address, and it is invisible to the internet with no gate to misconfigure).

The fourth option is the right default for anything internal. A service that only listens on `100.64.0.0/10` does not need a WAF, a password, or a rate limit.

### The prod exclusion

> [!IMPORTANT]
> **Interpreting the truncated requirement.** The source sentence — *"…punching holes into the infra with caddy. Prod should not"* — is read here as **production carries neither the developer toolchain nor ad-hoc holes.** Concretely:

| | Dev environments | Client production |
|---|---|---|
| `tmux`, editors, agent CLIs, compilers, language toolchains | ✅ installed by the dev role | ❌ **not installed** — smaller attack surface, smaller patch surface, and nothing to tempt a live edit |
| New Caddy routes | ✅ any developer, any time, committed later or not at all | ❌ only via a merged PR to `envs/prod-<client>/` |
| Interactive shell access | ✅ normal | 🟨 break-glass: possible over the tailnet, logged, expected to be rare, and any change made this way is a bug in the repo |
| Drift from the declared state | ✅ tolerated by design | ❌ **drift is an incident**, not a preference |
| Package set | baseline + whatever you want | baseline + exactly the app's runtime dependencies |

The second-order benefit is diagnostic: if production has no editor, nobody can "just fix it on the box", so every fix goes through the repo and the repo stays true. The cost is real — debugging a production incident without your tools is genuinely worse — and the mitigation is that observability (logs shipped off-box, metrics, a way to get a shell *with* tools in a disposable container) has to be good enough that you do not need to edit files on a live machine.

## Repo layout — one baseline, two guides

The requirement is *"two different guides with a common OpenTofu baseline … personal, shared dev, dev for collaborators, prod for clients"*, in **one** repository. One repo is the right call: the alternative — a repo per environment — duplicates the baseline four ways and guarantees that three copies drift.

```
infra/
├── README.md                     ← the two guides live here (or in docs/)
├── .sops.yaml                    ← which age key encrypts which path (see §10)
├── .gitattributes                ← optional: transparent decrypt filters (see §12)
│
├── tofu/
│   ├── modules/
│   │   ├── baseline/             ← THE shared module. Everything below reuses it.
│   │   │   ├── server.tf         ·  hcloud_server + cloud-init user_data
│   │   │   ├── firewall.tf       ·  hcloud_firewall: 443 from CF ranges, NOTHING on 22
│   │   │   ├── dns.tf            ·  cloudflare_dns_record / hcloud_zone_rrset
│   │   │   ├── ssh_keys.tf       ·  hcloud_ssh_key from a committed public-key set
│   │   │   ├── variables.tf      ·  env name, server_type, location, tags, hole list
│   │   │   └── outputs.tf        ·  ipv4, tailnet name, ansible inventory fragment
│   │   ├── headscale/            ← the control-plane host itself
│   │   └── caddy_site/           ← one "hole": DNS record + route + access policy
│   │
│   └── envs/
│       ├── dev-personal/         ← 1 machine, your key only
│       ├── dev-shared/           ← n machines, your team's keys
│       ├── dev-collab-<name>/    ← 1 machine per collaborator, ACL-scoped
│       ├── prod-acme/            ← client A
│       └── prod-globex/          ← client B
│           ├── main.tf           ·  module "baseline" { source = "../../modules/baseline" … }
│           ├── backend.tf        ·  state location + encryption block
│           ├── terraform.tfvars  ·  the ~20 lines that differ between environments
│           └── secrets.enc.yaml  ·  SOPS-encrypted, per-env age recipients
│
├── ansible/
│   ├── inventory/                ← generated from tofu output, not hand-maintained
│   ├── roles/
│   │   ├── baseline/             ·  users, sshd-on-tailnet, tailscale, caddy, unattended-upgrades
│   │   ├── dev_tools/            ·  tmux, kakoune, shell, dotfiles, agent CLIs   ← dev only
│   │   └── app/                  ·  docker compose + the service's compose file
│   ├── dev.yml                   ·  hosts: dev  → roles: baseline, dev_tools
│   └── prod.yml                  ·  hosts: prod → roles: baseline, app
│
└── keys/
    ├── ssh/*.pub                 ← public keys, committed in the clear
    └── age/*.pub.txt             ← age recipients (public halves), committed in the clear
```

*(Swap `ansible/` for `nix/` wholesale if you take the NixOS route from [§4](#the-iac-and-config-management-landscape); nothing above the directory boundary changes.)*

### How the baseline is actually reused

The baseline is a **module**, not a copied directory. Every environment is a thin call:

```hcl
# tofu/envs/prod-acme/main.tf
module "baseline" {
  source = "../../modules/baseline"

  env          = "prod-acme"
  tier         = "prod"                    # drives the prod exclusions from §5
  server_type  = "ccx13"
  location     = "fsn1"
  zone         = "acme.example"
  ssh_key_ids  = [for k in var.operator_keys : k.id]   # public keys from keys/ssh/
  headscale_url = "https://hs-acme.example.net"        # per-client control plane, see §3
}
```

The `tier` variable is the load-bearing one. It is what makes a single module produce a permissive dev box and a locked-down prod box without two codebases:

| `tier` | Firewall | cloud-init installs | Ansible play | Caddy routes |
|---|---|---|---|---|
| `dev` | 443 from CF; 41641/udp out | admin user, tailscale, python | `dev.yml` (baseline + dev_tools) | declared routes **plus** whatever is added locally |
| `prod` | 443 from CF only | admin user, tailscale, python | `prod.yml` (baseline + app) | exactly the declared routes |

> [!NOTE]
> **Why one module with a `tier` flag rather than `modules/dev-baseline` + `modules/prod-baseline`.** Two modules drift: a firewall fix lands in one and not the other, and the difference between dev and prod becomes accidental rather than designed. One module with an explicit tier makes every dev/prod divergence a visible conditional that a reviewer can enumerate — which is exactly the list you want to be able to recite when a client asks what is different about their environment.

### State, one file per environment

Each environment has its **own** state file and its **own** credentials. That is the primary blast-radius boundary in the whole design ([§11](#blast-radius-and-making-encryption-convenient)): `tofu apply` in `dev-shared` holds a token that cannot see `prod-acme`, and a state file that does not contain its secrets.

Where the state lives is the one genuinely awkward choice in an all-open-source stack, because there is no Hetzner-native object store binding in the provider's backend list:

| Option | Trade-off |
|---|---|
| **S3-compatible object storage** (Hetzner Object Storage, MinIO, Garage) via the `s3` backend | Works today, supports locking, and is the pragmatic default. Needs one more credential. |
| **Committed to the repo** (`local` backend + OpenTofu state encryption) | Genuinely viable for this scale, and it makes the "one repo holds everything" claim literally true. No locking — safe for one operator, hazardous for a team. |
| **HTTP backend on your own box** | Another service to run and back up. |

With OpenTofu's state encryption enabled (below), the committed-state option is not the security hole it would be with Terraform. It remains a *concurrency* hole.

## Guide A — development environments

**Audience:** you, your team, and collaborators you have invited. **Promise:** *a managed baseline, and above the baseline you can do whatever you want.*

### Outline

1. **Prerequisites.** `tofu`, `ansible`, `sops`, `age`, `tailscale` installed locally. One age private key, obtained once ([§12](#the-turn-key-concept--bootstrap-and-2fa-on-apply)). A Hetzner API token for the **dev** project only. A Cloudflare token scoped to the dev zone only.
2. **Pick your environment directory.** `dev-personal` for a machine only you touch, `dev-shared` for the team, `dev-collab-<name>` for an outside collaborator.
3. **Add your public keys.** Drop your SSH public key into `keys/ssh/` and your age *recipient* into `keys/age/`. Both are public halves; both are committed in the clear ([§9](#ssh-key-management)).
4. **`tofu init && tofu plan && tofu apply`.** Creates the server, DNS record, firewall, and registers the SSH keys.
5. **`ansible-playbook dev.yml`.** Applies `baseline` (users, `sshd` on the tailnet, Tailscale joined to Headscale, Caddy, unattended upgrades) and `dev_tools` (tmux, Kakoune, shell, dotfiles, agent CLIs).
6. **`tailscale up --login-server=https://hs.example.net`** on your laptop, then `ssh admin@<node>` over the mesh. There is no public SSH to fall back to; if this step fails, fix the mesh rather than opening a port.
7. **Punch a hole when you need one.** `caddy_site` module for something that needs a real hostname and TLS; a tailnet-bound listener for anything internal, which needs no hole at all.

### The drift policy

This is the part that makes dev pleasant and keeps it honest:

| Change | Policy |
|---|---|
| Install a package, edit your dotfiles, run a container, add a local Caddy route | **Free.** No PR, no review, no ticket. |
| A change you want to *survive a rebuild* | Put it in `roles/dev_tools/` — the rebuild is the enforcement mechanism, not a policy document. |
| A change to `roles/baseline/`, the firewall, the tailnet ACLs, or anything in `modules/baseline` | **PR.** These are shared with production. |

> [!IMPORTANT]
> **Drift tolerance only works if rebuilds are routine.** The rule that makes "do what you want" safe is: **a dev box may be destroyed and recreated at any time, and the only thing guaranteed to come back is what is in the repo.** Rebuild on a schedule — monthly is enough — so that the guarantee is tested rather than asserted. A dev environment that has not been rebuilt in a year is a production environment with worse security and no backups.

Give every dev box `/srv/` (or a Hetzner Volume) as the one explicitly non-ephemeral path, so "rebuild whenever" does not mean "lose your scratch work".

### Collaborators specifically

A collaborator gets: their own machine, their own SSH key, their own age recipient on *dev* secrets only, and a Headscale ACL tag (`tag:collab-<name>`) that can reach their box and nothing else. They do **not** get: the prod age keys, the prod Hetzner token, the prod Cloudflare token, or a route to any `prod-*` node. Offboarding is three deletions and one `tofu apply` — and, because they held decryptable dev secrets, a **rotation** of the dev secrets they could read. Removing a recipient from `.sops.yaml` stops them decrypting *future* versions; it does not un-read what they already cloned.

## Guide B — production for clients

**Audience:** a client's production environment, one directory per client. **Promise:** *the repository is the truth; the machine is a cache of it.*

### Outline

1. **Prerequisites.** A **separate Hetzner project** for the client — this is what makes the API token a real boundary. A Cloudflare API token scoped to that client's zone only. A distinct age key pair whose private half is not on any collaborator's laptop.
2. **`tofu/envs/prod-<client>/`** — call the same `modules/baseline` with `tier = "prod"`.
3. **State encryption on** ([§10](#secrets-checked-into-the-repo)) before the first `apply`, not after. Retrofitting encryption onto a state file that already leaked is theatre.
4. **`tofu apply`** from a clean checkout, ideally from CI rather than a laptop.
5. **`ansible-playbook prod.yml`** — `baseline` + `app` only. No `dev_tools`.
6. **Verify the exclusions**: no editor on the box, no shell history worth reading, `nmap` from outside shows 443 and nothing else, and `ss -ltn` on the box shows `sshd` bound to the tailnet address only.
7. **Hand the client a one-page runbook**: what is declared where, who holds which key, what the restore procedure is, and what the [SLA actually is](#managed-vs-unmanaged-for-client-production).

### What makes prod "completely declarative"

| Property | Mechanism |
|---|---|
| Every resource exists because a file says so | `tofu plan` on a clean checkout produces **no diff**. Run it in CI on a schedule — a nightly `plan` that is not empty is an alert, and it is the cheapest drift detector that exists. |
| Every package and unit exists because a role says so | `ansible-playbook --check --diff prod.yml` on a schedule, same alerting rule. |
| Every secret is in the repo, encrypted | SOPS-encrypted files per environment, decrypted at apply time only ([§10](#secrets-checked-into-the-repo)). |
| Every token is scoped to one environment | One Hetzner project per client → one token. One Cloudflare token per zone. |
| Nobody edits the box | No editor installed; access is break-glass and logged. |

> [!CAUTION]
> **"Completely declarative" never includes the data.** OpenTofu will happily replace a server and Ansible will happily reinstall it; neither will restore the database. Production needs a backup story that is independent of the IaC — Hetzner Storage Box or object storage, `restic`/`borg`, encrypted with a key held *outside* the environment being backed up — plus a **restore rehearsal** on a schedule. An untested restore is not a backup. This is the single most common gap in otherwise-excellent declarative setups.

## SSH key management

SSH keys are the easy case and a good rehearsal for the hard one: **the public half is not a secret, so it goes in the repo in the clear, and the private half never touches the repo at all.**

```hcl
# tofu/modules/baseline/ssh_keys.tf
locals {
  operator_keys = {
    for f in fileset("${path.module}/../../../keys/ssh", "*.pub") :
    trimsuffix(basename(f), ".pub") => trimspace(file("${path.module}/../../../keys/ssh/${f}"))
  }
}

resource "hcloud_ssh_key" "operator" {
  for_each   = var.tier == "prod" ? var.prod_operators : local.operator_keys
  name       = "${var.env}-${each.key}"
  public_key = each.value
  labels     = { env = var.env, tier = var.tier }
}
```

Four consequences worth stating:

- **Adding a person is a PR containing one `.pub` file.** Removing them is a PR deleting it, plus an `apply`. The audit trail is `git log` and it is free.
- **`hcloud_ssh_key` only seeds the first boot.** Hetzner injects the registered keys into `root`'s `authorized_keys` at server creation. After that, the authoritative source is the Ansible `baseline` role, which writes `authorized_keys` from the same `keys/ssh/` directory. **Both must read the same directory**, or you get a machine that still admits a departed collaborator because only the OpenTofu side was updated.
- **Dev and prod get different key sets.** `var.prod_operators` is an explicit allow-list, not "everyone in `keys/ssh/`". Defaulting prod to the whole directory is how a collaborator silently gains production access.
- **Key type:** Ed25519. Which brings us to the interesting variant.

### Hardware-backed SSH keys

OpenSSH 8.2 (2020) added FIDO-backed key types: *"In OpenSSH FIDO devices are supported by new public key types `ecdsa-sk` and `ed25519-sk`"*, and *"FIDO tokens also generally require the user explicitly authorise operations by touching or tapping them."* The private key material cannot be exfiltrated from the token, and every authentication requires a physical touch.

```
ssh-keygen -t ed25519-sk -O resident -O verify-required -C "operator@laptop"
```

The public half is an ordinary `.pub` file, so it drops into `keys/ssh/` and the rest of the design is unchanged. `-O verify-required` additionally demands the token's PIN, making the key two-factor by itself.

> [!NOTE]
> **This is the cheapest real 2FA in the whole stack and it is available today.** It gates *access to machines*. It does **not** gate `tofu apply`, which talks to the Hetzner and Cloudflare APIs and never touches SSH — see [§12](#the-turn-key-concept--bootstrap-and-2fa-on-apply) for that harder problem.

### SSH certificate authorities — the scaling answer

At ~10 operators and ~50 machines, distributing `authorized_keys` starts to hurt: revocation means re-running configuration management everywhere. The standard answer is an SSH CA — machines trust one CA public key, humans get short-lived certificates (minutes to hours), and revocation is simply not issuing another one. Open-source implementations: **Smallstep `step-ca`**, **HashiCorp Vault**'s SSH secrets engine or its **OpenBao** fork (the MPL-licensed community fork, relevant given the licensing history in [§4](#the-iac-and-config-management-landscape)).

For this design it is **deliberately deferred**: it adds a service that must itself be declared, run and backed up, and whose outage blocks all access. At a handful of operators, `authorized_keys` from a git directory is simpler and fails in more comprehensible ways. Revisit when revocation-by-PR stops feeling fast enough.

## Secrets checked into the repo

The requirement — *"prod is managed completely declaratively, incl. token separation checked into codebase"* — is read as: **encrypted secrets live in git; the keys that decrypt them are separated per environment; no plaintext ever enters a commit.**

### SOPS + age

[**SOPS**](https://github.com/getsops/sops) (MPL-2.0, 23,102★, `v3.13.3` 2026-07-23) encrypts the *values* in a YAML/JSON/ENV/INI file while leaving the *keys* readable, so a diff still shows which secret changed even though nobody can read it. It was donated to the **CNCF as a Sandbox project in 2023** — a meaningful governance signal for a tool this load-bearing. [**age**](https://github.com/FiloSottile/age) (BSD-3-Clause, 23,562★, `v1.3.2` 2026-08-29) is the key half: one-line public keys, no keyring daemon, no web of trust, no GnuPG.

The whole configuration is one file:

```yaml
# .sops.yaml — which key encrypts which path
creation_rules:
  - path_regex: tofu/envs/dev-.*/secrets\.enc\.yaml$
    age: age1dev0000000000000000000000000000000000000000000000000000
  - path_regex: tofu/envs/prod-acme/secrets\.enc\.yaml$
    age: age1acme000000000000000000000000000000000000000000000000000
  - path_regex: tofu/envs/prod-globex/secrets\.enc\.yaml$
    age: age1globex00000000000000000000000000000000000000000000000000
```

`sops edit tofu/envs/prod-acme/secrets.enc.yaml` opens plaintext in `$EDITOR` and writes ciphertext back. The encrypted file is committed. There is no separate secret store to run, back up, or lose.

**Why age rather than GPG:** age keys are a single line, have no expiry or subkey model to misconfigure, and the tool has one job. Every hour not spent explaining GPG to a collaborator is an hour of actual work. **Why not Vault/OpenBao:** a service you must run, back up and keep available — justified when secrets are dynamic and short-lived, over-engineered when they are a dozen static API tokens.

### Token separation, concretely

| Token | Scope | Blast radius if leaked |
|---|---|---|
| Hetzner API token, project `dev` | one Hetzner project | dev servers destroyable; **no path to any client** |
| Hetzner API token, project `prod-acme` | one Hetzner project | that client only |
| Cloudflare token — `Zone:DNS:Edit` on `acme.example` | one zone, one permission | DNS for that zone only. **Never use a Global API Key**; it is account-wide and cannot be scoped. |
| Cloudflare token — `Zone:Zone:Read` + `Zone:Cache Purge` | one zone | negligible |
| Headscale pre-auth key | one node join, ephemeral, single-use | one node joins a tailnet — and with ACLs, a tagged node reaching only its own tier |
| age private key, `dev` | every dev secret | dev only |
| age private key, `prod-acme` | one client's secrets | one client |

The rule that makes this work: **one Hetzner project per environment.** Hetzner API tokens are project-scoped, so the project boundary *is* the token boundary. Putting all environments in one project makes every token a master key regardless of how carefully everything above it is designed.

### OpenTofu state encryption

The classic hole in Terraform-style workflows is that **the state file contains secrets in plaintext** — every `sensitive` value, every generated password, every API response field. Encrypting `secrets.enc.yaml` and then writing an unencrypted state file next to it protects nothing.

OpenTofu closed this in **`v1.7.0` (2024-04-30)**, whose release notes lead with *"State Encryption — Protect your precious state files with end-to-end encryption."* It is the single strongest reason to prefer OpenTofu over Terraform for this design.

```hcl
terraform {
  encryption {
    key_provider "pbkdf2" "env" {
      passphrase = var.state_passphrase   # from sops exec-env, never on disk
    }
    method "aes_gcm" "primary" {
      keys = key_provider.pbkdf2.env
    }
    state { method = method.aes_gcm.primary }
    plan  { method = method.aes_gcm.primary }
  }
}
```

Facts from [the OpenTofu docs](https://opentofu.org/docs/language/state/encryption/), verified at snapshot: the method is **AES-GCM**; key providers are **PBKDF2** (minimum 16-character passphrase, minimum 200,000 iterations, default 600,000), **AWS KMS**, **GCP KMS**, **Azure Key Vault**, **OpenBao**, and an experimental **external** provider. A `fallback` block lets you roll keys — reads try the fallback, and *"when OpenTofu saves your state or plan file, it will always use the new method and not the fallback"*, so a rotation completes itself as environments are applied.

> [!IMPORTANT]
> **Plans are encrypted too, and that matters more than it sounds.** A saved plan file contains the same sensitive values as state. Any CI pipeline that runs `tofu plan -out=tfplan` and stores the artefact for a human to approve is publishing your secrets to the artefact store unless plan encryption is on. Turn on both blocks, always.

## Blast radius, and making encryption convenient

Encryption reduces blast radius only if the key boundaries match the consequence boundaries — and only if people actually use it. Both halves need design.

### What each key can and cannot reach

| Key holder | Can decrypt | Can reach | Cannot reach |
|---|---|---|---|
| **Collaborator** (age `dev`, SSH key, `tag:collab-x`) | dev secrets | their own dev box over the tailnet | any `prod-*` secret, token, host, or zone |
| **You** (age `dev` + all `prod-*`) | everything | everything | — you are the single point of failure; see below |
| **CI** (age `prod-acme` only, injected at runtime) | one client's secrets | one client's Hetzner project + zone | every other client, and all dev |
| **A leaked dev age key** | dev secrets | nothing by itself — it decrypts files, it does not grant network access | production, entirely |
| **A leaked prod Hetzner token** | nothing (it is not a decryption key) | destroy/create servers in **one** project | other clients; DNS; secrets |

The design goal is that **no single leaked credential produces a cross-environment incident**, and that is achieved — with one honest exception.

> [!CAUTION]
> **You are the cross-environment blast radius.** One laptop holds every age private key and can `tofu apply` to every client. Nothing in this design fixes that; it is the structural cost of one operator holding all the keys. Partial mitigations, cheapest first:
> 1. **Keep prod age keys on a hardware token** rather than on disk ([§12](#the-turn-key-concept--bootstrap-and-2fa-on-apply)) — an attacker with your filesystem still cannot decrypt production.
> 2. **Full-disk encryption plus a short screen-lock timeout.** Unglamorous and the highest ratio of protection to effort.
> 3. **Move prod applies to CI**, where the key is injected per-run and your laptop never holds it. This is the real fix, and it costs you the ability to fix production from a train.
> 4. **Per-client key escrow** — a sealed copy of each prod age key somewhere a bus-factor event can reach it. Required if a client's business depends on the environment.

### Rotation is the thing people skip

Removing a recipient from `.sops.yaml` and re-encrypting (`sops updatekeys`) stops them decrypting *future* commits. **It does not revoke what they already cloned** — git history contains the old ciphertext, and they had the key. Any departure therefore implies **rotating the secret values themselves**, not just the recipient list. Budget for it: an offboarding is "revoke the recipient, then roll every token that recipient could read." Keeping the per-environment secret file small makes this cheap, which is another argument for narrow token scopes.

### Making it convenient — the part that determines whether it is used

An encryption workflow that costs five extra steps gets bypassed within a month. Four mechanisms, in the order you should adopt them:

**1. `sops exec-env` — secrets exist only inside one process.**

```
sops exec-env tofu/envs/prod-acme/secrets.enc.yaml 'tofu apply'
```

Decrypted values become environment variables for exactly that command and are never written to disk. `TF_VAR_*`-named keys arrive as OpenTofu variables with no glue code. There is also `sops exec-file` for tools that demand a real file path — it materialises a temporary FIFO rather than a plaintext file. (Both subcommands verified present in `cmd/sops/main.go` at snapshot.)

**2. `direnv` — the secrets load when you `cd` into the environment.**

```bash
# tofu/envs/prod-acme/.envrc
export TF_VAR_state_passphrase="$(sops -d --extract '["state_passphrase"]' secrets.enc.yaml)"
```

Now `cd prod-acme` is the whole ceremony. Pair it with a shell prompt segment showing the active environment, because the failure mode this design cannot prevent is applying the right change to the wrong environment.

**3. Readable diffs of encrypted files.** SOPS leaves keys in plaintext, so a diff already shows *which* secret changed. For a genuinely decrypted diff, a `.gitattributes` textconv entry running `sops -d` makes `git diff` transparent for anyone holding the key, and opaque for anyone who does not.

**4. Transparent decrypt at checkout — the git-crypt model.** [**git-crypt**](https://github.com/AGWA/git-crypt) (GPL-3.0, 9,906★) installs git clean/smudge filters so that **working-tree files are plaintext and committed blobs are ciphertext**, with no command to remember at all. `0.8.0` landed 2025-09-24 after a long quiet period.

| | **SOPS + age** | **git-crypt** |
|---|---|---|
| Granularity | per-value | per-file |
| Diff readability | key names visible, values encrypted | binary blob without the key |
| Key model | age / KMS / Vault, multiple recipients per path | GPG or a symmetric key |
| Ceremony | explicit `sops -d` / `exec-env` / `direnv` | **none** — transparent on checkout |
| Partial access | yes, path-scoped recipients in one file | per-file only |
| Recommended here | ✅ for infrastructure secrets | 🟨 for the "paste one key and it just works" experience — see [§12](#the-turn-key-concept--bootstrap-and-2fa-on-apply) |

> [!NOTE]
> **The transparency git-crypt gives you is also its risk.** When the working tree is always plaintext, every tool with filesystem access — an editor plugin, a backup agent, a coding agent — reads your production tokens without asking. SOPS's explicitness is a feature precisely because decryption is an act. The recommendation here is SOPS for infrastructure secrets, with git-crypt considered only for low-sensitivity config that benefits from zero ceremony.

## The turn-key concept — bootstrap and 2FA on apply

The stated endpoint: *"ideally I just need to paste some credentials and when I am in the computer session it's transparently decrypted by git. Or even better, infrastructure changes require a 2FA code."*

These are two different asks with very different maturity, and it is worth separating them sharply.

### Part 1 — paste-once bootstrap · **real today**

```
# on a new machine, once:
$ git clone git@github.com:you/infra.git && cd infra
$ mkdir -p ~/.config/sops/age && $EDITOR ~/.config/sops/age/keys.txt   # paste the age key
$ direnv allow
# from here on, `cd` into an env directory and everything is decrypted in-session
```

Everything needed for this exists and is stable: SOPS (CNCF Sandbox), age, `direnv`, and the `SOPS_AGE_KEY_FILE` convention. The *only* out-of-band secret is one age private key per environment you are entitled to. Everything else — tokens, passphrases, join keys — is in the repo, encrypted.

If you want the literal "transparently decrypted by git" behaviour, that is git-crypt's clean/smudge filters, at the cost described above. A defensible hybrid: **git-crypt for the handful of files that make a fresh clone immediately usable, SOPS for everything with production consequences.**

### Part 2 — 2FA on `tofu apply` · **partly real, partly concept**

There is no `--require-2fa` flag in OpenTofu, and there is no Hetzner or Cloudflare API mode that demands a second factor per call. What exists are mechanisms that make the *key material* require a human touch. Rated honestly:

| Approach | Status | What it actually gates | Notes |
|---|---|---|---|
| **`age-plugin-yubikey`** — age identity lives on a YubiKey | ✅ **real** (Apache-2.0, 972★, `v0.5.1` 2026-04-08) | decryption of the secrets file, therefore any apply that needs a token | Supports `--touch-policy` and `--pin-policy` at generation. `--touch-policy always` = a physical touch per decryption. **No agent**: PIN policy `once` caches within a session, and **not on YubiKey 4 series**. |
| **FIDO2 SSH keys** (`ed25519-sk`, `-O verify-required`) | ✅ **real** (OpenSSH 8.2+, 2020) | SSH access to machines, and a git push if you sign/authenticate with it | Does **not** gate API-driven applies. |
| **Cloudflare Access in front of a self-hosted CI** | ✅ real | *who may trigger* an apply | Gates the pipeline, not the credential. Someone with the raw token still bypasses it. |
| **SOPS + cloud KMS with MFA-conditioned IAM** | 🟨 real but off-stack | decryption, enforced server-side by the cloud provider | Requires AWS/GCP/Azure — abandons "everything open source" and adds a hyperscaler dependency to a Hetzner stack. |
| **Hardware-backed state passphrase** (PBKDF2 passphrase stored in a YubiKey-encrypted SOPS file) | ✅ real, composes with the above | reading *and writing* state, so effectively every apply | The cleanest fit: touch the key or the apply cannot read state. |
| **TOTP prompt in a wrapper script** | ⚠️ **theatre** | nothing | A local script verifying a TOTP it can also skip is a speed bump, not a control. Only meaningful if verification happens somewhere the operator cannot reach — i.e. server-side. |
| **True per-API-call 2FA at Hetzner/Cloudflare** | ❌ **does not exist** | — | Would require provider support. Not available at snapshot date. |

> [!IMPORTANT]
> **The achievable design — and it is genuinely good.** Put the **production** age identity on a YubiKey generated with `--touch-policy always`. Then:
> - `tofu apply` on production needs the state passphrase → needs a SOPS decrypt → needs a physical touch. **No touch, no apply.**
> - Malware with full filesystem access still cannot apply, because the key material never leaves the token.
> - Dev environments keep a file-based age key, so day-to-day work has zero friction.
>
> What this is **not**: it is not per-change approval, and it is not a second *person*. A single touch authorises whatever the already-running `tofu` process does next. If you need "two humans agree before production changes", the mechanism is a protected branch with required reviews plus applies that only run from CI — an organisational control, not a cryptographic one.

### Bootstrapping a brand-new client, end to end

1. Create a Hetzner project for the client; mint a project-scoped API token.
2. Create a Cloudflare API token scoped to the client's zone (`Zone:DNS:Edit` + `Zone:Zone:Read`).
3. `age-keygen` (or generate on a YubiKey) → add the **recipient** to `.sops.yaml`, commit.
4. `sops edit tofu/envs/prod-<client>/secrets.enc.yaml` → paste both tokens → commit ciphertext.
5. `cp -r tofu/envs/_template tofu/envs/prod-<client>` → set ~20 lines in `terraform.tfvars`.
6. `sops exec-env … 'tofu apply'` → servers, DNS, firewall, SSH keys exist.
7. `ansible-playbook prod.yml` → the machines become themselves.
8. Commit. **The client now exists entirely in git**, and the only thing outside it is one private key.

Steps 1–2 are the residual manual work: mint-a-token is a chicken-and-egg that no amount of IaC removes, because the first credential cannot be created by a tool that needs a credential.

## Cost — auction dedicated vs cloud VPS

> [!IMPORTANT]
> **This section's conclusion changed in June 2026, and any advice written before then is stale.** On **2026-06-15** Hetzner raised cloud server prices — in some lines by more than 100% — while [explicitly leaving the Server Auction out of scope](https://www.hetzner.com/pressroom/standardization-and-price-adjustment-of-our-server-products/). The break-even between "rent several VPS" and "rent one dedicated box" moved decisively toward dedicated, and it moved in one step.

### What actually happened to the prices

From Hetzner's own [price-adjustment page](https://docs.hetzner.com/general/infrastructure-and-availability/price-adjustment/) (Germany FSN/NBG and Finland HEL, effective 2026-06-15). Percentage column is **derived** (`new/old − 1`):

| Plan | Spec (verified from Hetzner product pages) | Old €/mo | New €/mo | Change *(derived)* |
|---|---|---:|---:|---:|
| CX23 | 2 shared vCPU, 4 GB, 40 GB NVMe | 3.99 | 5.49 | +37.6% |
| CX53 | 16 shared vCPU ⬜ RAM | 22.49 | 29.49 | +31.1% |
| CAX11 | Arm, 2 vCPU ⬜ RAM | 4.49 | 5.99 | +33.4% |
| CAX41 | Arm ⬜ | 31.49 | 40.99 | +30.2% |
| **CPX22** | 2 shared vCPU (AMD), 4 GB, 80 GB NVMe | 7.99 | **19.49** | **+143.9%** |
| CPX42 | ⬜ | 25.49 | 69.49 | +172.6% |
| **CCX13** | **2 dedicated vCPU (AMD), 8 GB, 80 GB NVMe** | 15.99 | **42.99** | **+168.9%** |
| CCX23 | 4 dedicated vCPU, 16 GB, 160 GB NVMe | 31.49 | 85.99 | +173.0% |
| CCX63 | ⬜ | 374.49 | 853.49 | +127.9% |

All EU cloud servers include at least 20 TB of traffic (verified on the product pages).

> [!CAUTION]
> **The cheap shared-vCPU line is not orderable at snapshot date.** On **2026-09-13**, [hetzner.com/cloud/cost-optimized/](https://www.hetzner.com/cloud/cost-optimized/) renders the badge **"not available"** against all eight cost-optimized plans — `CX23`, `CX33`, `CX43`, `CX53`, `CAX11`, `CAX21`, `CAX31`, `CAX41`. The general-purpose (`CCX`) and regular-performance (`CPX`) pages carry no such badge.
>
> *Method: the string `not available` occurs 8 times in the cost-optimized page's rendered text and 0 times on the other two.* Whether this is a temporary capacity constraint or a quiet retirement of the line is **not stated by Hetzner** ⬜. Either way: **do not design a cost model around CX/CAX pricing you cannot currently buy.** The realistic cheapest new cloud server for this stack is a **CPX22 at €19.49/month**, not a €5.49 CX23.

### The dedicated side

Also from the price-adjustment page (Falkenstein/Helsinki, effective 2026-06-15). The `-LTD` line is limited-quantity hardware sourced at lower cost:

| Model | €/mo | One-time setup | Note |
|---|---:|---:|---|
| **AX41-1-LTD** | **57.30** | **0.00** | AMD Ryzen 5 3600 (Zen 2, 6c/12t with SMT), **64 GB DDR4**, 2× 512 GB NVMe, 1 Gbit/s — spec verified on [hetzner.com/dedicated-rootserver/ax41/](https://www.hetzner.com/dedicated-rootserver/ax41/) |
| EX44-1-LTD | 57.30 | 0.00 | |
| EX63-1-LTD | 97.30 | 39.00 | |
| AX102-1-LTD | 157.30 | 39.00 | |
| AX42-1 | 97.30 | 49.00 | standard line, for comparison |
| AX102-1 | 257.30 | 129.00 | standard line |
| SX65-2 | 82.30 | 39.00 | storage line |

**Server Auction** — refurbished hardware, no setup fee, and **explicitly excluded from the June 2026 increase**. ⬜ **Live auction prices could not be captured**: [hetzner.com/sb/](https://www.hetzner.com/sb/) is a client-rendered application with no reachable JSON endpoint, and the community tracker [radar.iodev.org](https://radar.iodev.org/) returns 403 to automated requests. Secondary, *community-reported*: entry-level auction machines commonly start around **€30–40/month**. Treat that as an order of magnitude, not a quote — auction inventory changes hourly, which is the entire point of it.

### The break-even — derived arithmetic

> [!NOTE]
> **Everything in this subsection is derived** from the verified prices and specs above. It compares *capacity you can buy*, not *performance you will get*: a shared or dedicated cloud vCPU and a bare-metal SMT thread are not the same unit, and no benchmark was run here ⬜. Treat these as procurement arithmetic.

Anchor: **AX41-1-LTD at €57.30/month, €0 setup** — 12 threads, 64 GB RAM, 1 TB of NVMe (2× 512 GB).

| Comparison | Arithmetic *(derived)* | Result |
|---|---|---|
| Break-even vs **CCX13** (€42.99) | 57.30 ÷ 42.99 | **1.33** — the dedicated box costs less than **two** CCX13 |
| Break-even vs **CPX22** (€19.49) | 57.30 ÷ 19.49 | **2.94** — less than **three** CPX22 |
| RAM parity vs CCX13 (8 GB each) | 64 ÷ 8 = 8 servers × €42.99 | **€343.92/mo** for the same RAM — **6.0× the dedicated price** |
| RAM parity vs CPX22 (4 GB each) | 64 ÷ 4 = 16 servers × €19.49 | **€311.84/mo** — **5.4×** |
| vCPU parity vs CCX13 (2 each, ignoring SMT) | 12 ÷ 2 = 6 servers × €42.99 | **€257.94/mo** — **4.5×** |

**The break-even is now below two mid-range cloud servers.** Before June 2026 the same arithmetic against a €15.99 CCX13 gave 57.30 ÷ 15.99 ≈ **3.6** servers *(derived from the "old" column)* — so the crossover roughly halved in one pricing event.

### The costs that are not on the price list

Arithmetic this lopsided should make you suspicious, and it should: the dedicated column is buying you capacity, not operations.

| Hidden cost | Cloud VPS | Dedicated / auction |
|---|---|---|
| **Setup fee** | none | €0 on auction and some `-LTD`; up to €1,149 on large standard models |
| **Provisioning time** | seconds, API-driven | ⬜ minutes to hours depending on stock; auction machines are hand-picked from live inventory, which is inherently **not declarative** |
| **Failure recovery** | the hypervisor host fails → you rebuild from IaC in minutes on new hardware | a disk or PSU fails → a support ticket, a hardware swap window, and a rebuild. Hetzner does **not** live-migrate dedicated servers. |
| **RAID** | not your problem | **your problem.** Two NVMe drives are two drives until you configure `mdadm` — and that configuration must be in the repo, or your "declarative" rebuild silently loses redundancy |
| **Snapshots / backups** | snapshot + Backups add-on, API-driven | no snapshot API; you build backups yourself (Storage Box + `restic`/`borg`) |
| **Resize** | change `server_type`, reboot | order a different machine and migrate |
| **Blast radius** | one VPS per environment = physical isolation between clients | **all environments on one box share a kernel, a disk, a NIC and a maintenance window** |
| **Billing granularity** | hourly, destroy to stop paying | monthly minimum; a torn-down environment is still billed |
| **Traffic** | 20 TB included (EU) | unlimited on a 1 Gbit/s port |

> [!IMPORTANT]
> **The decisive argument is not price, it is the last two rows.** Consolidating three clients onto one €57 box saves roughly €70/month against three CCX13 *(derived: 3 × 42.99 − 57.30 = €71.67)* and creates a **shared failure domain and a shared security domain across clients who have no relationship with each other**. One kernel exploit, one disk failure, one runaway container is now a three-client incident, and a three-client conversation.
>
> The break-even maths therefore answers the wrong question for client production. It answers the right question for **your own** environments, where you *are* the only affected party.

### The recommendation

| Workload | Pick | Why |
|---|---|---|
| Personal dev, shared dev, collaborator boxes, CI runners, build cache | **One auction / `-LTD` dedicated box**, carved into VMs or containers | The break-even is under two cloud servers and the failure domain is entirely yours. This is where the 5–6× saving is real money. |
| Headscale control plane | **Smallest available cloud server** | It must be reachable to be useful, and it must not share a failure domain with the things it manages. Cheap and separate. |
| Client production, small | **Cloud VPS (CPX22 / CCX13)**, one per client, in **its own Hetzner project** | Per-client isolation, per-client token boundary, seconds-to-rebuild, snapshot API. Worth the premium. |
| Client production, large or steady-state heavy | **Dedicated per client** | One client per box preserves isolation. At sustained load the arithmetic above is decisive. |
| Anything where an hour of downtime has a price tag | **Two machines, not one big one** | Redundancy beats capacity. See below. |

## Managed vs unmanaged for client production

*"Does it even make sense not to use a managed VPS for client projects, for max uptime?"* — the honest answer has two halves, and the first one surprises people.

### Half one: the SLA you are buying is not insurance

Hetzner's [Cloud SLA](https://docs.hetzner.com/general/company-and-policy/slas-cloud/) (page last updated 2026-03-16) commits to **99.9% monthly availability** for Cloud Servers and vServers. Compensation is **Cloud Credit**, calculated as downtime hours × the instance's hourly rate. Explicitly outside the SLA: licences, managed services, snapshots, backups, third-party services, firewalls and load balancers. **Dedicated servers are not covered by this SLA at all.**

Work through what that pays out. A CCX13 bills at **€0.0689/hour** (verified, same source as the monthly price). 99.9% of a 30-day month allows ~43 minutes of downtime; a **four-hour** outage — far past the threshold, a genuinely bad day — yields *(derived)* 4 × €0.0689 ≈ **€0.28** in credit.

> [!IMPORTANT]
> **An SLA is a statement of intent with a token penalty attached, not a transfer of risk.** Twenty-eight cents does not compensate a client for a four-hour outage, and no provider at this price point offers one that would. **If uptime has a real price tag for a client, it must be bought with architecture — two machines, health checks, a failover path — not with a contract clause.** Choosing a provider "for the SLA" at this tier is choosing a number that will never pay out.

### Half two: what "managed" actually buys

Strip the marketing and a managed offering is four operational responsibilities transferred:

| What is transferred | What it means in practice | Can you replace it? |
|---|---|---|
| **Patching** | someone applies security updates and reboots when the kernel demands it | ✅ largely — `unattended-upgrades` in the baseline role, plus a reboot window. This is the cheapest to self-manage. |
| **Backups** | scheduled, offsite, and *tested* | 🟨 you can automate `restic` to a Storage Box in an afternoon. **Testing the restore** is the part nobody automates, and it is the part that matters. |
| **Monitoring** | something watches, and a human is told | 🟨 Uptime Kuma or a hosted checker is trivial. "A human is told **and responds**" is not a tool. |
| **On-call** | a person is contractually obliged to be awake at 03:00 | ❌ **This is the one you cannot replicate, and it is what you are actually paying for.** |

For a solo operator or a small studio, three of four are a weekend of automation that then lives in the same repo as everything else — a genuinely better outcome than a managed plan, because it is declarative and portable. The fourth is not automatable, and pretending otherwise is how "we host it for you" becomes an unpriced liability.

> [!CAUTION]
> **The failure mode is commercial, not technical.** An unmanaged VPS you run for a client makes *you* their on-call, permanently, for free, with no defined response time. That obligation does not appear in the project quote, does not end when the project ends, and is the most common way small studios acquire an unpaid operations department. Decide explicitly whether you are selling hosting or giving it away.

### Recommendation by client tier

| Client tier | Hosting | Rationale |
|---|---|---|
| **Brochure site, no revenue impact from a few hours down** | Unmanaged VPS, fully declarative, backups automated | An outage costs goodwill. Rebuild-from-repo is fast enough. Cheapest honest option. |
| **Site is a sales channel; downtime costs money but not the business** | Unmanaged VPS **plus a written support agreement** with stated hours and response time, **plus** a second machine or a tested fast-restore path | The contract is the product here. Redundancy at this tier is a €43/month second server, not an architecture project. |
| **Revenue-critical, or regulated, or 24/7** | **Not this stack alone.** Managed hosting with a real on-call, or a platform (managed database + managed app runtime), or a retainer that funds genuine on-call | You cannot sell 24/7 availability that depends on one person's phone. Being straight about this wins more trust than it loses work. |
| **The client has their own ops team** | Unmanaged, and **hand them the repo** | This design's real payoff: the handover artefact is a repository that describes the entire environment, not a wiki page and a password manager export. |

> [!NOTE]
> **A fifth option that is often correct: don't host it.** For a client whose site is genuinely a brochure, the lowest-total-cost answer is frequently a platform with no servers at all — see [Choosing a web-presence stack](../application-types/choosing-a-web-presence-stack.md). A declarative Hetzner stack is the right answer when the client needs something a builder cannot do, not merely because you are able to build one.

### If you do self-manage: the minimum bar

1. **Backups offsite, encrypted, with a key held outside the environment** — and a restore rehearsed on a calendar, not on an incident.
2. **External monitoring** — from outside the environment being monitored, with escalation to a human who has agreed to be escalated to.
3. **Unattended security upgrades on** in the baseline role, with a declared reboot window.
4. **A rebuild you have actually performed.** "I could rebuild this from the repo" is a hypothesis until it is an experiment. Rebuild one non-critical production environment from scratch, on a schedule, and time it — that number is your real RTO.
5. **A written statement to the client** of what is and is not covered, including the fact that the underlying SLA compensates in cents.

## What's missing / honest gaps

The design above is buildable today. These are the places where it is held together by convention rather than by tooling, plus the things this article could not verify.

### Gaps in the tooling

| Gap | Detail | Workaround |
|---|---|---|
| **Dedicated / auction servers are not declarable** | The official [hcloud provider](https://github.com/hetznercloud/terraform-provider-hcloud) covers Hetzner **Cloud** only. The Robot (dedicated) side has no first-party provider; community options are [`awlsring/terraform-provider-headscale`](https://github.com/awlsring/terraform-provider-headscale)-scale projects — `sophotechlabs/terraform-provider-hetzner-robot` is **1★, MIT, pushed 2026-08-14** and covers rescue boot, resets, switch firewall, rDNS and the SSH key store, **not ordering**. | Buy the machine by hand, then bring it under management with cloud-init/`nixos-anywhere` + Ansible. Record the purchase in the repo as a comment, because the resource block cannot exist. **This is the concrete reason the cost section's winner is not the architecture section's default.** |
| **Headscale is pre-1.0 and single-tailnet** | `v0.29.3`, BSD-3-Clause, and its docs scope it to *"a single Tailscale network (tailnet), suitable for a personal use, or a small open-source organisation."* | ACL tags for dev; a separate instance per client for prod ([§3](#architecture--how-the-services-interact)). |
| **Headscale is not first-party declarable either** | [`awlsring/terraform-provider-headscale`](https://github.com/awlsring/terraform-provider-headscale) — 46★, Apache-2.0, `v0.5.1` (2026-03-20) — is the only meaningful option and is not maintained by the Headscale project. | Manage Headscale's ACL policy as a config file via Ansible; treat users/pre-auth keys as a bootstrap step. |
| **No per-API-call 2FA at Hetzner or Cloudflare** | Neither provider offers an API mode requiring a second factor. | Gate the **key material** with a YubiKey-backed age identity ([§12](#the-turn-key-concept--bootstrap-and-2fa-on-apply)). |
| **No state backend blessed for this stack** | OpenTofu has no Hetzner-native backend. | S3-compatible object storage, or committed encrypted state with no locking. |
| **Cloudflare provider v5 churn** | v5 is a generated ground-up rewrite; v4 receives only critical security fixes. | Budget migration time; pin the major version explicitly. |
| **Secret rotation has no tooling here** | `sops updatekeys` rotates *recipients*, not *values*. Rotating an actual token is manual at every provider. | A documented offboarding checklist. Nothing better exists at this scale. |
| **Colmena's releases are stale** | `v0.4.0` (2023-05-15), though the repo is active. | Relevant only on the NixOS path; pin to a commit. |
| **Backups are outside the IaC** | Nothing in OpenTofu or Ansible restores a database. | An independent, tested backup system ([§8](#guide-b--production-for-clients)). |

### Things this article could not verify ⬜

- **Live Hetzner Server Auction prices.** `hetzner.com/sb/` is client-rendered with no reachable JSON endpoint; `radar.iodev.org` returns 403 to automated requests. The €30–40/month entry figure is *community-reported* and should be checked against live inventory before any decision.
- **Why the cost-optimized cloud line shows "not available".** The badge is verified; the reason is not stated by Hetzner.
- **Cloudflare Zero Trust free-tier seat count.** Not present in the HTML of `cloudflare.com/plans/zero-trust-services/`, `developers.cloudflare.com/cloudflare-one/setup/`, or `/cloudflare-one/plans/` (404). The widely-cited *"50 users free, then $7/user/month"* is **community-reported only** and was not confirmed against a Cloudflare-published page at snapshot date. *(The same "pricing renders in JS, not in HTML" pattern documented in [the website-builders article](../application-types/website-builders.md#a-warning-about-the-prices-in-this-article).)*
- **Performance equivalence.** The break-even is priced in RAM and core counts. No benchmark was run; a bare-metal SMT thread and a cloud vCPU are not interchangeable units.
- **Chef's and Puppet's current shipping versions.** Both projects' GitHub releases are stale relative to their real distribution channels, so "last release" is ⬜ for them.

### Deliberately out of scope

Kubernetes and its operators; multi-region and anycast origins; PCI/HIPAA-grade compliance; CI/CD pipeline design beyond "prod applies should run there"; and observability tooling, which deserves its own article and is assumed present in [§14](#managed-vs-unmanaged-for-client-production).

## Discovery & sources

Every URL below was fetched on **2026-09-13**. Repository metrics come from `gh api repos/OWNER/REPO` and `gh api repos/OWNER/REPO/releases/latest` on the same date.

**Primary — Hetzner**

- <https://docs.hetzner.com/general/infrastructure-and-availability/price-adjustment/> — full old/new cloud price table and current dedicated price + setup-fee tables, effective 2026-06-15.
- <https://www.hetzner.com/pressroom/standardization-and-price-adjustment-of-our-server-products/> — `-1/-2/-3` standardization; **Server Auction explicitly excluded** from the increase.
- <https://docs.hetzner.com/general/company-and-policy/slas-cloud/> — 99.9% monthly Cloud SLA, Cloud Credit compensation, exclusions (page last updated 2026-03-16).
- <https://www.hetzner.com/cloud/cost-optimized/>, <https://www.hetzner.com/cloud/regular-performance/>, <https://www.hetzner.com/cloud/general-purpose/> — plan specs and the "not available" badges (extracted from page HTML text, since the pricing widgets do not render server-side).
- <https://www.hetzner.com/dedicated-rootserver/ax41/> — AX41 specification.
- <https://www.hetzner.com/sb/> — Server Auction landing page (listings not machine-readable ⬜).

**Primary — Cloudflare**

- <https://www.cloudflare.com/service-specific-terms-application-services/> — CDN content-type restriction.
- <https://developers.cloudflare.com/cloudflare-one/account-limits/> — Cloudflare One limits (1,000 tunnels, 1,000 routes, 50 mesh nodes, 500 Access applications, 500 Gateway policies per type, 50 service tokens, 50 IdPs).
- <https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/> — Tunnel as outbound-only connections.

**Primary — tools**

- <https://opentofu.org/docs/language/state/encryption/> — key providers, AES-GCM, fallback/rollover semantics.
- `gh api repos/opentofu/opentofu/releases/tags/v1.7.0` — State Encryption shipped in 1.7.0 (2024-04-30).
- `repos/hashicorp/terraform/contents/LICENSE` — BUSL-1.1, Licensor *International Business Machines Corporation (IBM)*, Licensed Work *Terraform Version 1.6.0 or later*.
- `repos/fosrl/pangolin/contents/LICENSE` — mixed Fossorial Commercial License + AGPL-3.0 (open-core).
- <https://headscale.net/stable/> — single-tailnet scope statement.
- <https://docs.chef.io/licensing/> — Apache-2.0 source vs Chef EULA binaries; <https://cinc.sh/> for the Apache-2.0 rebuild.
- <https://voxpupuli.org/blog/2025/05/19/perforce-eula/> — the Puppet EULA change and Vox Pupuli's response.
- `repos/getsops/sops/contents/README.rst` — CNCF Sandbox donation (2023), supported formats and key backends; `cmd/sops/main.go` — `exec-env` / `exec-file` subcommands verified present.
- `repos/str4d/age-plugin-yubikey/contents/README.md` — `--touch-policy` / `--pin-policy`, no decryption agent, YubiKey 4 caveat.
- <https://www.openssh.org/txt/release-8.2> — `ecdsa-sk` / `ed25519-sk` and the touch requirement.
- `repos/germanbrew/terraform-provider-hetznerdns/contents/README.md` — deprecation notice (2025-11-10) pointing at the hcloud provider; `repos/hetznercloud/terraform-provider-hcloud/releases/tags/v1.54.0` — DNS API support.
- `repos/cloudflare/terraform-provider-cloudflare/contents/docs/guides/version-5-upgrade.md` — the generated-from-OpenAPI rewrite.

**Secondary / community-reported (labelled as such in the text)**

- Server Auction entry price range (~€30–40/month) and the Cloudflare Zero Trust free-seat count — both ⬜, see [What's missing](#whats-missing--honest-gaps).

## Cross-links

- [**Choosing a web-presence stack**](../application-types/choosing-a-web-presence-stack.md) — the tier decision *above* this article. Most of what people plan to self-host on Hetzner belongs on Tier 1 or Tier 3 and never needs a server. Read it first; this article is Tier 4/5 machinery.
- [**Website builders**](../application-types/website-builders.md) — the hosted alternatives, and the [pricing-verification warning](../application-types/website-builders.md#a-warning-about-the-prices-in-this-article) whose method this article reuses for Hetzner's and Cloudflare's JS-rendered price pages.
- [**Authentication — high-level primer**](../authentication.md) — background for the Cloudflare Access / SSH-CA / FIDO2 material in [§9](#ssh-key-management) and [§12](#the-turn-key-concept--bootstrap-and-2fa-on-apply).
- [**Recent incidents in major technologies**](../industry-watch/recent-incidents.md) — why "no public SSH" and "no dev toolchain in prod" are cheap insurance.
- [**Formalization**](formalization.md) — the scoring rubric this repo uses. The tables here report raw metrics rather than rubric scores, because the tools compared are not substitutable.
