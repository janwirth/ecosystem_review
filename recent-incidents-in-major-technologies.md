# Recent security incidents in major technologies

> [!NOTE]
> **Status:** DRAFT · **Authoring:** AI-assisted, human-reviewed.

**Snapshot 2026-04-23** — data from public advisories, CVE records, and vendor post-mortems.

This is not a comprehensive audit. It is a sampled look at what has actually gone wrong in popular ecosystems over the last ~28 months (2024-01-01 through today), aimed at one question tech-pickers keep asking:

> *"What risk shape does this stack carry?"*

Every mainstream ecosystem has incidents. The point is not to rank languages by body count — it is to see the **pattern** each one leaks through (middleware mistakes, plugin sprawl, registry hijacks, long-con maintainer takeovers) so you can plan your defences where they actually matter.

Incidents here are restricted to items that have a public advisory, CVE record, or vendor post-mortem we could verify. Where a detail could not be independently confirmed, it is marked "reportedly" or omitted.

## Table of Contents

1. [Next.js](#nextjs)
2. [WordPress](#wordpress)
3. [Python / PyPI](#python--pypi)
4. [npm / JavaScript](#npm--javascript)
5. [Linux / system libraries — XZ Utils](#linux--system-libraries--xz-utils)
6. [Elixir / BEAM (Erlang VM)](#elixir--beam-erlang-vm)
7. [Java / JVM](#java--jvm)
8. [GitHub Actions / CI](#github-actions--ci)
9. [RubyGems](#rubygems)
10. [Docker Hub](#docker-hub)
11. [Cross-cutting patterns](#cross-cutting-patterns)
12. [Security ranking](#security-ranking)
13. [Takeaways for tech selection](#takeaways-for-tech-selection)


## Next.js

React framework by Vercel. Widely used for server-rendered and edge-deployed apps. The 2024-2026 window has two standout incidents plus smaller cache/SSRF bugs.

| Date | CVE / ID | Severity | What happened | Impact | Patched |
| --- | --- | --- | --- | --- | --- |
| 2024-02 | [CVE-2024-34351](https://github.com/advisories/GHSA-fr5h-rqp8-mj6g) | High | SSRF via Server Actions — a crafted `Host` header caused the Next.js server to make outbound requests that looked like they originated from itself. | Access to internal services reachable from the app server. | `14.1.1` |
| 2024-09 | [CVE-2024-46982](https://github.com/advisories/GHSA-gp8f-8m3g-qvj9) | High | Cache poisoning of non-dynamic SSR routes in the `pages` router via crafted HTTP requests. | Poisoned responses served to other users (XSS / data disclosure depending on content). App Router unaffected. | Patched in `13.5.7` / `14.2.10` |
| 2025-03 | [CVE-2025-29927](https://nvd.nist.gov/vuln/detail/CVE-2025-29927) | Critical (CVSS 9.1) | Middleware authorization bypass. Sending the internal `x-middleware-subrequest` header with a specific value caused Next.js to **skip middleware entirely** and forward the request to its destination. Designed to prevent middleware recursion; weaponised to bypass auth checks implemented in middleware. Affected versions 11.1.4 through 15.2.2. | Auth / authz bypass anywhere middleware was the enforcement point. Trivially exploitable — set one header. | `14.2.25`, `15.2.3` |
| 2025-12-03 | [CVE-2025-55182](https://react.dev/blog/2025/12/03/critical-security-vulnerability-in-react-server-components) ("React2Shell") + [CVE-2025-66478](https://vercel.com/kb/bulletin/security-bulletin-cve-2025-55184-and-cve-2025-55183) | Critical (CVSS 10.0) | Unauthenticated RCE via insecure deserialization in React Server Components / Server Functions. Default framework configurations are vulnerable — no special setup or developer mistake required. Affects React 19.0–19.2.1 and Next.js 13.x–16.x that use RSC. | Full server RCE. Added to CISA KEV; exploited in the wild within days, including cryptomining (XMRig) and cloud credential theft. AWS reported China-nexus groups exploiting rapidly. | React `19.0.1` / `19.1.2` / `19.2.1`; corresponding Next.js releases |

Also landed in the same December 2025 disclosure: [CVE-2025-55184](https://vercel.com/kb/bulletin/security-bulletin-cve-2025-55184-and-cve-2025-55183) (high-severity DoS) and [CVE-2025-55183](https://vercel.com/kb/bulletin/security-bulletin-cve-2025-55184-and-cve-2025-55183) (medium-severity source-code exposure), both in React Server Components.

**Shape of Next.js risk:** framework-internal headers and deserialization boundaries. Middleware and RSC are relatively new surfaces, and both have now had design-level bugs (not just implementation bugs) — 29927 was "the header meant for internal use was trusted when it came from outside"; 55182 was "serialized payloads from the network were deserialized without validation."


## WordPress

Core CMS is broadly patched; the risk surface is the **plugin ecosystem** — tens of thousands of plugins, uneven maintenance, and mass exploitation that starts within hours of disclosure.

| Date | CVE / ID | Severity | What happened | Impact | Patched |
| --- | --- | --- | --- | --- | --- |
| 2024-11 | [CVE-2024-10924](https://www.wordfence.com/blog/2024/11/really-simple-security-vulnerability/) | Critical (CVSS 9.8) | Auth bypass in **Really Simple Security** plugin (Free, Pro, Pro Multisite) versions 9.0.0–9.1.1.1. Improper error handling in the 2FA REST API let unauthenticated attackers log in as any user, including admin, when 2FA was enabled. | ~4 million sites affected. Exploitable to RCE via plugin/theme upload after login. | `9.1.2` (force-updated by WordPress.org) |
| 2024-08+ | [CVE-2025-23921](https://www.txone.com/blog/wordpress-multi-uploader-plugin-exploitation/) | Critical | **Multi Uploader for Gravity Forms** — unrestricted file upload. Persistent in-the-wild exploitation since August 2024 with spikes in October, January, and April. | Arbitrary file upload → webshell / RCE. | Plugin patched; many sites remain unpatched |
| 2025-08 | [CVE-2025-5947](https://securityaffairs.com/183162/hacking/cve-2025-5947-wordpress-plugin-flaw-lets-hackers-access-admin-accounts.html) | Critical (CVSS 9.8) | **Service Finder Bookings** plugin — improper cookie validation let attackers log in as any user. Exploitation began the day after the patch; Wordfence blocked 13,800+ attempts. | Account takeover → full admin. | Plugin update (August 2025) |
| 2025-11 | [CVE-2025-6389](https://thehackernews.com/2025/12/sneeit-wordpress-rce-exploited-in-wild.html) | Critical (CVSS 9.8) | **Sneeit** plugin — unauthenticated RCE. Patch released August 2025; mass exploitation began 2025-11-24 with 131,000+ attempts blocked by Wordfence. | Unauth RCE on any site running a vulnerable version. | `8.4` |
| 2025-11 | [CVE-2025-8489](https://thehackernews.com/2025/12/wordpress-king-addons-flaw-under-active.html) | Critical (CVSS 9.8) | **King Addons for Elementor** — privilege escalation lets unauthenticated attackers self-register as admin. Mass exploitation from 2025-11-09; 48,400+ attempts blocked. | Instant admin account creation on vulnerable installs. | Plugin update |
| 2026-04 | [Essential Plugin portfolio hijack](https://www.opensourceforu.com/2026/04/second-open-source-plugin-hijack-raises-alarm-across-wordpress-ecosystem/) | High (supply chain) | Plugin portfolio originally by WP Online Support / Essential Plugin was **sold in 2024**. A backdoor was planted under new ownership and remained dormant until activating in early April 2026, distributing malicious payloads at scale. | ~400,000 installs, ~20,000 active sites reportedly affected. | Plugins pulled; users need to audit and replace |

**Shape of WordPress risk:** **plugin sprawl**, not core. The core CMS's security has been steadily improving; the attack surface is the long tail of third-party plugins — abandoned ones, sold ones, and freshly-patched ones where mass scanning starts in hours. The "plugin sold to new maintainer who planted a backdoor" pattern is now recurring.


## Python / PyPI

Python's core language and stdlib have had no catastrophic events in this window — the action is on **PyPI supply-chain attacks**. A handful of patterns: maintainer account takeover, CI/build-environment compromise, typosquatting, and AI-themed lure packages.

| Date | Package / ID | Severity | What happened | Impact | Resolution |
| --- | --- | --- | --- | --- | --- |
| 2024-12-04 | [`ultralytics`](https://blog.pypi.org/posts/2024-12-11-ultralytics-attack-analysis/) (versions 8.3.41, 8.3.42, 8.3.45, 8.3.46) | High (supply chain) | Build environment compromised via a known GitHub Actions `pull_request_target` script injection (flagged by researcher Adnan Khan in August 2024). The PyPI-published code diverged from GitHub, and the package shipped an **XMRig cryptominer downloader**. Package had ~60M downloads historically; 30k+ GitHub stars. | Cryptomining on installing systems. v8.3.41 was live for ~12 hours. | Malicious versions yanked from PyPI |
| 2024 | [JarkaStealer via AI-themed lures](https://www.kaspersky.com/about/press-releases/kaspersky-uncovers-year-long-pypi-supply-chain-attack-using-ai-chatbot-tools-as-lure) | High | Year-long campaign of malicious PyPI packages disguised as AI chatbot tools, delivering a modified JarkaStealer (browser data, Telegram/Discord/Steam session tokens, screenshots). | Credential and session-token theft on developer machines. | Packages removed; no central CVE |
| 2025-06 | Malicious PyPI / npm / gem packages with dependency-confusion payloads | Varies | [Reported by Socket / Sonatype](https://thehackernews.com/2025/06/malicious-pypi-npm-and-ruby-packages.html) — ongoing cluster of typosquat + dependency-confusion packages across three ecosystems. | Developer machine compromise. | Ongoing takedowns |
| 2026-02 | Compromised **dYdX** npm + PyPI packages | High (supply chain) | [Wallet stealers and RAT malware](https://thehackernews.com/2026/02/compromised-dydx-npm-and-pypi-packages.html) shipped via compromised dYdX-related packages on both registries. | Crypto wallet theft + remote access. | Packages pulled |
| 2026-03-21 | [`litellm`](https://docs.litellm.ai/blog/security-update-march-2026) (versions `1.77.7.dev5`, `1.77.7.dev6`, `1.77.7.dev7`, `1.77.7.post1`) | Critical (supply chain) | Compromised PyPI versions delivered a multi-stage credential stealer. Package has reported ~3M daily downloads. Compromised versions available for at least 2 hours. Activity reportedly attributed to threat group **TeamPCP**, speculated to be related to LAPSUS$. | AI-pipeline and cloud credential theft on installing systems. | Versions yanked; investigation ongoing |

**Shape of Python risk:** PyPI is the attack surface. Pinning, hash verification, and separating "install" from "run" matter more in the Python stack than in almost any other ecosystem because install-time code (`setup.py`, `pyproject.toml` build hooks) runs unsandboxed by default. The `ultralytics` incident is the textbook "compromised CI, not compromised maintainer" variant — the author's code review was fine; the build pipeline was the weak link.


## npm / JavaScript

The loudest attacks in this window landed here. Two categories: **maintainer account takeovers** (phishing) and **self-replicating worms** that use stolen npm tokens to spread.

| Date | Incident / ID | Severity | What happened | Impact | Resolution |
| --- | --- | --- | --- | --- | --- |
| 2025-09-08 | [Qix account takeover](https://socket.dev/blog/npm-author-qix-compromised-in-major-supply-chain-attack) — `chalk`, `debug`, `strip-ansi`, `color-convert`, `wrap-ansi`, and ~15 others | Critical (supply chain) | Maintainer Josh Junon ("Qix") phished via a fake `npmjs.help` 2FA reset email. Attacker captured credentials + a live TOTP code, took over the account, and published malicious versions of utilities with **billions of weekly downloads combined**. Payload was browser-only: hijacked crypto-wallet API calls and web3 transactions. | Community caught it in ~2 hours. Despite the scale, [reported cryptocurrency stolen was negligible](https://www.securityalliance.org/news/2025-09-npm-supply-chain) — the browser-only scope limited impact. | Clean versions republished within hours |
| 2025-09 + 2025-11-24 | [Shai-Hulud / Shai-Hulud 2.0 worm](https://unit42.paloaltonetworks.com/npm-supply-chain-attack/) | Critical (supply chain) | **Self-replicating npm worm.** Malicious `preinstall` script harvests credentials from filesystem + cloud (AWS, GCP, Azure), exfiltrates to a public GitHub repo (named "Sha1-Hulud: The Second Coming"), installs Bun to evade Node.js monitoring, and **uses the victim's npm token to backdoor up to 100 of their own packages** — propagating without a C2 server. 2.0 wave (Nov 21-23) backdoored 796 unique packages totaling 20M+ weekly downloads. Trojanized releases from Zapier, ENS Domains, PostHog, Postman briefly appeared. Also registered infected systems as GitHub self-hosted runners for persistence, and carried a "dead man's switch" destructive payload. | First wave: ~$50M crypto theft reported. Combined: data of 500+ unique GitHub users across 150+ orgs exfiltrated. | CISA advisory [AA25-266A](https://www.cisa.gov/news-events/alerts/2025/09/23/widespread-supply-chain-compromise-impacting-npm-ecosystem); ongoing cleanup |

**Shape of npm risk:** registry-wide worm-class attacks are now real. The combination of install-time scripts, flat dependency trees, and npm tokens being usable for publishing from any machine makes credential theft directly transmissible into package ownership. `preinstall`/`postinstall` hooks are the load-bearing vulnerability class.


## Linux / system libraries — XZ Utils

Not an "ecosystem" per se, but worth calling out because it reframed how the industry thinks about supply-chain risk.

| Date | CVE | Severity | What happened | Impact | Patched |
| --- | --- | --- | --- | --- | --- |
| 2024-03-29 (discovered) | [CVE-2024-3094](https://nvd.nist.gov/vuln/detail/CVE-2024-3094) | Critical (CVSS 10.0) | XZ Utils versions 5.6.0 and 5.6.1 shipped a backdoor that hooked into liblzma and, on systemd-linked sshd builds, allowed authentication bypass + pre-auth RCE for an attacker holding a private key. Planted by a co-maintainer ("Jia Tan" / JiaT75) in a **~2.5-year social engineering campaign** (Nov 2021 – Feb 2024) — building a reputation, pressuring the original maintainer into handing over co-maintainer status, then signing off on the backdoored releases. Discovered by Microsoft engineer Andres Freund who noticed a 500ms delay in SSH logins. | Reached Debian unstable/testing/experimental, Fedora 40 beta and Rawhide, Kali, and Arch. Caught **before** landing in stable releases of major distros. Widely assessed as state-sponsored. | Downgrade to `5.4.6` |
| 2025-08 | [Docker Hub follow-on](https://thehackernews.com/2025/08/researchers-spot-xz-utils-backdoor-in.html) | Critical (residual exposure) | Binarly found **dozens of official Debian-based Docker Hub images still containing the XZ backdoor** over a year after disclosure — images built before the patch had not been rebuilt. | Organizations pulling old tagged images still shipping the backdoor. | Image rebuilds; consumer-side: pin + rebuild |

**Shape of risk:** long-con maintainer takeover on critical infrastructure. Unlike npm-style "phish and go," this was a years-long credibility-building operation. The discovery was essentially luck — a performance anomaly noticed by one engineer. The follow-on in Docker Hub shows that even after disclosure, **stale container images carry the risk forward**.


## Elixir / BEAM (Erlang VM)

The Elixir / Erlang world is small, and its core ecosystem is relatively quiet — but 2025 delivered the most severe Erlang/OTP advisory on record, plus an audit-driven hex_core finding that landed in early 2026. Nothing on the Phoenix or Plug level in this window.

| Date | CVE / ID | Severity | What happened | Impact | Patched |
| --- | --- | --- | --- | --- | --- |
| 2025-04-16 | [CVE-2025-32433](https://nvd.nist.gov/vuln/detail/CVE-2025-32433) ([GHSA-37cp-fgq5-7wc2](https://github.com/erlang/otp/security/advisories/GHSA-37cp-fgq5-7wc2)) | Critical (CVSS 10.0) | **Pre-auth RCE in Erlang/OTP SSH server.** The SSH daemon accepted `SSH_MSG_CHANNEL_REQUEST` packets *before* authentication completed, letting an unauthenticated attacker execute arbitrary shell commands. In many deployments the SSH daemon runs as root, so the attacker lands as root. Exploit code was public within days of disclosure. | Added to CISA KEV on [2025-06-09](https://unit42.paloaltonetworks.com/erlang-otp-cve-2025-32433/) with active exploitation observed. Affected Cisco products (ConfD, NSO) and any Erlang-embedded device exposing SSH. | OTP-27.3.3, OTP-26.2.5.11, OTP-25.3.2.20 |
| 2025-11 | [CVE-2025-46712](https://github.com/erlang/otp/security/advisories/GHSA-37cp-fgq5-7wc2) | Medium | Erlang/OTP SSH failed to enforce strict KEX handshake hardening, allowing optional messages during the handshake. A MitM attacker could inject messages into the connection during key exchange. Found by the Ruhr-University Bochum team behind the original Terrapin attack. | MitM / downgrade against Erlang SSH connections. | OTP-27.3.4, OTP-26.2.5.12, OTP-25.3.2.21 |
| 2026-02 (disclosed) | [CVE-2026-21619](https://cna.erlef.org/cves/CVE-2026-21619.html) ([GHSA-hx9w-f2w9-9g96](https://github.com/hexpm/hex_core/security/advisories/GHSA-hx9w-f2w9-9g96)) | High | **Unsafe deserialization in `hex_core`.** The reference client library for the Hex package registry used `binary_to_term/1` on HTTP response bodies, so a spoofed Hex API response (compromised mirror, MitM, malicious proxy) could trigger atom-table exhaustion DoS or object-injection RCE in any build using `rebar3` or `mix`. Found by the Paraxial.io audit of Hex funded under the EEF Ægis Initiative. | Any Elixir / Erlang build reaching a compromised mirror would execute attacker-chosen Erlang terms at build time. No in-the-wild exploitation reported. | hex_core 0.12.1, hex 2.3.2, rebar3 3.27.0 |

**Shape of Elixir / BEAM risk:** small ecosystem, concentrated blast radius in the **runtime and package-manager client**. Hex.pm itself has not had a headline supply-chain incident in this window — the Paraxial audit explicitly rated it robust — but the `hex_core` issue shows that "robust registry" does not help if the client library silently deserializes untrusted responses. CVE-2025-32433 is a reminder that running a language's *own* SSH daemon exposes an attack surface most teams never audit (compare OpenSSH, which gets adversarial review continuously). For most Elixir apps, risk is well below npm/PyPI levels — the catch is that when Erlang/OTP itself breaks, it breaks deep.


## Java / JVM

Java's risk profile in this window is the **enterprise-framework** pattern: big, long-lived codebases (Struts, Tomcat, Spring) with decades of accumulated features where a single parser quirk or deserialization path turns into an unauth RCE across a huge installed base. Shai-Hulud 2.0 also crossed the ecosystem boundary into Maven Central for the first time.

| Date | CVE / ID | Severity | What happened | Impact | Patched |
| --- | --- | --- | --- | --- | --- |
| 2024-01-24 | [CVE-2024-23897](https://nvd.nist.gov/vuln/detail/CVE-2024-23897) | Critical (CVSS 9.8) | **Jenkins args4j CLI arbitrary file read / RCE.** The Jenkins CLI parser treated `@filepath` arguments as "substitute file contents here" (args4j's `expandAtFiles`), unauthenticated by default. Attackers with `Overall/Read` could read full files; without it, they could still read the first few lines — enough to grab secrets, SSH keys, or config that chains to RCE. Exploited in the wild within days. | Any internet-exposed Jenkins 2.441 / LTS 2.426.2 or earlier. Used in ransomware campaigns through 2024. | Jenkins 2.442 / LTS 2.426.3 |
| 2024-10-17 | [CVE-2024-38819](https://spring.io/security/cve-2024-38819/) / [CVE-2024-38820](https://spring.io/security/cve-2024-38820/) | High | Spring Framework path-traversal + DataBinder case-sensitivity bypass. 38819 let WebMvc/WebFlux apps serving static resources via `RouterFunctions` be path-traversed; 38820 extended CVE-2022-22968's `disallowedFields` bypass via locale-dependent `toLowerCase()`. | Static-resource disclosure and mass-assignment protection bypass in Spring-based apps. | 5.3.41, 6.0.25, 6.1.14 |
| 2024-12-11 | [CVE-2024-53677](https://nvd.nist.gov/vuln/detail/CVE-2024-53677) | Critical (CVSS 9.5) | **Apache Struts 2 file-upload path traversal → RCE.** Crafted upload parameters escaped the upload directory; writing to an arbitrary web-servable path gave RCE. Affects Struts 2.0.0-2.3.37 (EOL), 2.5.0-2.5.33, 6.0.0-6.3.0.2. [Sonatype reported](https://www.sonatype.com/blog/cve-2024-53677-a-critical-file-upload-vulnerability-in-apache-struts2) that 90%+ of weekly Struts 2 downloads were vulnerable versions weeks after patch release. | Full server RCE on legacy enterprise Struts deployments — which are plentiful, and often un-upgradable because Struts 6.4+ requires migrating off the legacy `FileUploadInterceptor`. | Struts 6.4.0 |
| 2025-03-10 | [CVE-2025-24813](https://nvd.nist.gov/vuln/detail/CVE-2025-24813) | Critical (CVSS 9.8) | **Apache Tomcat partial-PUT RCE.** Path-equivalence bug combined with the default partial-PUT behavior let an attacker upload a serialized session file to a writable directory and then trigger deserialization on a later request. Requires non-default settings (writes enabled for default servlet + file-based session persistence + a deserialization-gadget library on classpath), but those conditions exist in many real deployments. PoCs public within days. | Under-classloader RCE on affected Tomcat deployments. Active in-the-wild exploitation reported by Zscaler and SonicWall. | 11.0.3, 10.1.35, 9.0.99 |
| 2025-04-05 | [CVE-2025-30065](https://nvd.nist.gov/vuln/detail/CVE-2025-30065) | Critical (CVSS 10.0) | **Apache Parquet (Java) unsafe deserialization via Avro schema.** The `parquet-avro` module abused the `getDefaultValue()` mechanism to instantiate arbitrary Java record types during schema parsing, so a crafted Parquet file triggered RCE in any Java process reading it. Affects Parquet ≤ 1.15.0 (bug introduced in 1.8.0). | Data-pipeline RCE — anywhere untrusted Parquet files get parsed (ingestion services, lakehouse jobs, analytics notebooks). | parquet-java 1.15.1 |
| 2025-04-28 | [CVE-2025-31650](https://nvd.nist.gov/vuln/detail/CVE-2025-31650) / [CVE-2025-31651](https://nvd.nist.gov/vuln/detail/cve-2025-31651) | High / Low | Tomcat DoS via invalid HTTP priority header (memory leak → OOM) and rewrite-rule bypass for a subset of rewrite configs that enforced security constraints. | DoS on current Tomcat 11.0; auth / rewrite-based constraint bypass where applicable. | 11.0.6, 10.1.40, 9.0.104 |
| 2025-09-15 | [CVE-2025-41248](https://spring.io/security/cve-2025-41248/) / [CVE-2025-41249](https://spring.io/security/cve-2025-41249/) | Medium | Spring Security / Spring Framework annotation-detection bug — method-level security annotations on generic superclasses or interfaces were not always detected, so `@PreAuthorize` etc. could silently not apply. | Authorization bypass anywhere the affected annotation-inheritance pattern is used. Not exploitable remotely without the right class hierarchy, but silent when it hits. | Spring Security 6.4.11 / 6.5.5, Spring Framework 5.3.45 / 6.1.23 / 6.2.11 |
| 2025-11 | [Shai-Hulud 2.0 into Maven Central](https://thehackernews.com/2025/11/shai-hulud-v2-campaign-spreads-from-npm.html) | High (supply chain) | Maven Central caught the spillover of the npm Shai-Hulud worm — compromised npm components were being rebundled and pushed as Java artifacts. Maven Central purged the mirrored copies and added rebundle-detection rules. | First Maven Central supply-chain incident of this class. Limited user impact because it was caught during mirroring, not at publish-time. | Sonatype tooling update + artifact purge |
| 2025-12 | [Jackson-typosquat `org.fasterxml` → Cobalt Strike](https://www.aikido.dev/blog/maven-central-jackson-typosquatting-malware) | High (supply chain) | Malicious package published on Maven Central under `org.fasterxml.jackson.core/jackson-databind` (note: real coords are `com.fasterxml...`). Multi-stage loader with encrypted config, platform-specific executables, and a Cobalt Strike beacon payload on Linux/macOS. Described as the first sophisticated malware detected on Maven Central. | CI pipelines pulling the lookalike coordinate received a C2-enabled beacon. | Package removed |

**Shape of Java / JVM risk:** the dominant pattern is **deserialization + legacy framework surface**. Struts, Tomcat, Parquet, Spring — all 2024-2025 advisories here are either "parse attacker input via a permissive parser" or "deserialize a Java object from the network." The installed base is huge, long-lived, and often not on the current major version, so patch uptake lags even after public advisories. Maven Central was the last mainstream registry to see a sophisticated typosquat campaign; Shai-Hulud showed that npm-origin worms can now cross into JVM builds. Log4Shell (2021) is out of this window but the shape — network-reachable deserialization — keeps recurring (CVE-2025-30065, CVE-2025-24813, CVE-2025-55182 in React).


## GitHub Actions / CI

Not a language — but every ecosystem depends on it, and 2025 made clear that compromised Actions are a cross-ecosystem multiplier.

| Date | CVE / ID | Severity | What happened | Impact | Patched |
| --- | --- | --- | --- | --- | --- |
| 2025-03-14/15 | [CVE-2025-30066](https://github.com/advisories/ghsa-mrrh-fwg8-r2c3) — `tj-actions/changed-files` | High (supply chain) | A compromised GitHub PAT was used to **retroactively rewrite multiple version tags** to point to a malicious commit. The injected Python script extracted secrets from the Runner Worker process memory and printed them to GitHub Actions logs — public in open-source repos. | [Over 23,000 repositories affected](https://unit42.paloaltonetworks.com/github-actions-supply-chain-attack/). Secrets leaked: GitHub PATs, npm tokens, RSA keys, cloud keys. Originally targeted at Coinbase; scope expanded inadvertently. | `v46.0.1`; malicious commits reverted; [companion compromise](https://www.cisa.gov/news-events/alerts/2025/03/18/supply-chain-compromise-third-party-tj-actionschanged-files-cve-2025-30066-and-reviewdogaction) of `reviewdog/action-setup` as `CVE-2025-30154` |

**Shape of risk:** mutable tags. GitHub Actions by convention are referenced by tag (`@v4`), and tags can be force-moved. Pinning to a full commit SHA is the only durable defence. This is a structural issue, not a specific bug — the Actions ecosystem is built on a trust model that silently allows retroactive rewrites.


## RubyGems

Smaller blast radius than npm/PyPI in this window, but the same playbook.

| Date | Incident | Severity | What happened | Impact | Resolution |
| --- | --- | --- | --- | --- | --- |
| 2025-05-24 | [Fastlane plugin impersonation](https://thehackernews.com/2025/06/malicious-pypi-npm-and-ruby-packages.html) | High (supply chain) | Multiple accounts ("Bùi nam", "buidanhnam", "si_mobile") published gems posing as Fastlane plugins. Gems silently redirected all Telegram API traffic through an attacker-controlled C2, exfiltrating bot tokens, chat IDs, messages, and attachments. Timing correlated with Vietnam's nationwide Telegram ban 3 days earlier. | CI/CD pipelines using Telegram for notifications were exfiltrating their chat contents. | Gems yanked |
| 2025-08 | [60+ malicious gems, 275k downloads](https://www.bleepingcomputer.com/news/security/60-malicious-ruby-gems-downloaded-275-000-times-steal-credentials/) | High (supply chain) | Long-running campaign against South Korean grey-hat marketers — gems posed as automation tools for Instagram, X/Twitter, TikTok, and WordPress. Delivered the advertised functionality **and** sent credentials to attacker infrastructure. | Credential theft from users of social-media automation tools. | Gems yanked |

**Shape of risk:** same as npm/PyPI, lower volume. Install-time scripts exist (`gem install` runs extension builds); credential theft via lookalike package names is the dominant pattern.


## Docker Hub

Less a "vulnerability" story than a **hygiene and trust** story.

| Date | Incident | Severity | What happened | Impact | Resolution |
| --- | --- | --- | --- | --- | --- |
| 2024-04 | [Millions of "imageless" malicious containers](https://thehackernews.com/2024/04/millions-of-malicious-imageless.html) | Medium (ecosystem hygiene) | JFrog found 4M+ "imageless" repositories on Docker Hub — no content, just repository descriptions used as SEO / phishing vectors pointing at malware sites. Campaigns running 5+ years. | Users arriving from search engines were directed to malware. | Docker removed; ongoing moderation |
| 2025-08 | [XZ backdoor in Docker Hub images](https://thehackernews.com/2025/08/researchers-spot-xz-utils-backdoor-in.html) | Critical (residual) | See XZ section — dozens of official Debian-based images still contained CVE-2024-3094. | Stale images shipping known backdoor over a year after disclosure. | Image rebuilds |
| 2026-04 | [Checkmarx KICS image compromise](https://thehackernews.com/2026/04/malicious-kics-docker-images-and-vs.html) | High (supply chain) | Attackers pushed malicious images to the official `checkmarx/kics` Docker Hub repo, overwriting `v2.1.20` and `alpine` tags and adding a fake `v2.1.21`. Modified KICS binary included data-collection / exfiltration. | Any CI pipeline re-pulling `checkmarx/kics:alpine` got the trojaned binary. | Tags cleaned; compromise being investigated |

**Shape of risk:** mutable image tags (same problem as mutable Actions tags) + stale images in registries. Digest pinning (`image@sha256:...`) is the only robust defence.


## Cross-cutting patterns

Across all of the above, a small number of themes keep recurring:

1. **Package registries are the new perimeter.** Every major ecosystem (npm, PyPI, RubyGems, Docker Hub) had at least one high-severity compromise in 2024-2026. The incident distribution is roughly proportional to ecosystem size and install-time-code power, not proportional to "how good the language is." npm leads in volume because of scale + `preinstall` hooks.

2. **Install-time code is the primary detonation point.** `preinstall`/`postinstall` (npm), `setup.py` / build hooks (PyPI), gem extension builds, Docker `RUN` — whenever installing a package runs code, the package is executing with whatever privileges the install session has. The Qix, Shai-Hulud, and litellm incidents all used install-time hooks.

3. **Mutable references are load-bearing.** GitHub Actions tags, Docker Hub tags, even some npm `latest` dist-tags can all be silently repointed. The `tj-actions` compromise and the Checkmarx KICS compromise are the same bug in two different registries. **Pin to an immutable digest / SHA, not a tag.**

4. **Framework middleware is not a security boundary on its own.** CVE-2025-29927 (Next.js) is the headline, but the broader lesson is that any "edge" layer that runs attacker-controlled headers and makes auth decisions on them is one header-trust bug away from a bypass. Defence in depth at the route/handler level still matters.

5. **Maintainer account = publishing right.** A single phishable TOTP gets you `chalk`, `debug`, and a few billion weekly downloads. Hardware-key-required publishing (now available on npm and optionally on PyPI via trusted publishing) is the only structural fix — individual maintainer diligence has a ceiling.

6. **Long-con maintainer takeover is a real operation mode.** XZ was not a hot phish, it was a 2.5-year investment. This is expensive and rare, but it happened, and it targeted a library almost every Linux system depends on. Treat "small single-maintainer utility that a lot of things transitively depend on" as a **structural** risk, not a trust-the-maintainer risk.

7. **Plugin sprawl + secondhand plugins is the WordPress shape.** The unique WordPress pattern is that plugins get **sold**, and new owners inherit the user base but not the scrutiny. Essential Plugin (2026-04) is the most recent example, but it is not the first.

8. **Deserialization comes back every cycle.** CVE-2025-55182 (React Server Components) is, structurally, the same class of bug as Log4Shell, Spring4Shell, and countless Java RMI / .NET BinaryFormatter issues: trusting a serialized payload from the network. New frameworks using serialization as a transport mechanism keep rediscovering this. CVE-2025-30065 (Parquet) and CVE-2025-24813 (Tomcat) are both in-window examples in the Java ecosystem alone.


## Security ranking

Ranking every ecosystem covered above on three axes, restricted to the **2024-01-01 → 2026-04-23** window. The axes:

- **Incident frequency** — how often this ecosystem produced a notable advisory or supply-chain incident in the window. Many small ones count.
- **Gravity** — worst-case impact observed (CVSS, exploit-in-the-wild, blast radius, whether CISA KEV picked it up).
- **Churn / maintenance heaviness** — how much ongoing work a well-run team has to do to stay out of trouble (patch cadence, mass-exploitation pressure, pinning discipline, supply-chain hygiene).

Scale: 🟩🟩 = low risk / well-contained, 🟩 = okay / manageable with discipline, 🟥 = concerning / high ongoing effort required.

| Ecosystem | Incident frequency | Gravity | Churn / maintenance | Overall | One-line take |
| --- | --- | --- | --- | --- | --- |
| **Elixir / BEAM** | 🟩🟩 (3 notable: 32433, 46712, hex_core) | 🟥 (32433 was CVSS 10, CISA KEV, pre-auth RCE, in-the-wild) | 🟩🟩 (small ecosystem, low patch pressure) | 🟩🟩 | Rare events, but the events that do hit hit the runtime or the registry client — deep, not wide. |
| **RubyGems** | 🟩 (2 campaigns in window) | 🟩 (credential theft, not RCE-class) | 🟩🟩 (slow-moving ecosystem, manageable) | 🟩🟩 | Same playbook as npm / PyPI, fraction of the volume. |
| **Docker Hub** | 🟩 (imageless spam, XZ residual, KICS) | 🟩 (supply chain, scoped to pull) | 🟩 (pin by digest + rebuild schedule and you're fine) | 🟩 | Mutable tags are the core issue; digest-pinning solves most of it. |
| **GitHub Actions** | 🟩 (tj-actions + reviewdog in one event) | 🟩 (23k repos, secret exfiltration) | 🟥 (every workflow needs SHA pinning, review of transitive actions) | 🟩 | Structural: mutable tags + broad secret access. Not going away. |
| **Next.js** | 🟩 (29927, 55182, plus smaller ones) | 🟥 (29927 + 55182 both in-the-wild, 55182 CVSS 10 added to CISA KEV) | 🟥 (aggressive patch cadence — two critical advisories in 2025 alone) | 🟩 | Framework-internal trust boundaries keep leaking; patch-or-bleed. |
| **Python / PyPI** | 🟥 (ultralytics, JarkaStealer campaign, dYdX, litellm, ongoing typosquats) | 🟥 (litellm: ~3M daily downloads, credential stealer; ultralytics: crypto-miner) | 🟥 (hash pinning, trusted publishing, AI-stack extra scrutiny, install-hook awareness) | 🟥 | Install-time code + huge registry + AI-stack targeting = continuous pressure. |
| **Java / JVM** | 🟥 (Struts, Tomcat ×3, Parquet, Spring ×2, Jenkins, Maven ×2) | 🟥 (Struts 53677 + Tomcat 24813 + Parquet 30065 all CVSS 9.5–10 with real exploitation) | 🟥 (long-lived enterprise deployments, legacy Struts / Tomcat chains, slow patch uptake) | 🟥 | Enterprise patch-lag is the story. Many CVSS-10 issues, large installed base, slow rollout. |
| **Linux / XZ** | 🟩🟩 (one event — but the event) | 🟥 (CVSS 10, nation-state-grade, years-in-the-making) | 🟩 (for consumers: rebuild bases + watch for stale images) | 🟩 | One-off in raw frequency, but reshaped the entire industry's trust model for upstream maintainers. |
| **npm / JavaScript** | 🟥 (Qix, Shai-Hulud, Shai-Hulud 2.0, dYdX, others) | 🟥 (worm-class: ~$50M crypto theft, 796 packages trojanized in v2, CISA AA25-266A) | 🟥 (lockfiles, `--ignore-scripts`, hardware-key publishing, provenance, constant vigilance) | 🟥 | The current worst offender — self-replicating worms are now a real class of attack. |
| **WordPress** | 🟥 (Really Simple Security, Multi Uploader, Service Finder, Sneeit, King Addons, Essential Plugin hijack — 6+ in window) | 🟥 (multiple CVSS 9.8 unauth RCE / priv-esc, mass exploitation within hours of patch) | 🟥 (plugin policy + auto-update + ownership-change monitoring + perimeter scanning all needed) | 🟥 | Plugin sprawl + sold-and-backdoored plugins + hours-from-patch-to-exploit. Highest ongoing operational cost. |

A word on the "🟥🟥🟥" bucket: WordPress, npm, Java, and Python all earned a full red overall, but for different reasons — WordPress for **operational load** (patch windows measured in hours), npm for **novel attack classes** (worms), Java for **installed-base lag** (everyone is running something unpatched), Python for **install-time code + AI-stack targeting**. "🟩🟩 overall" means something genuinely different for Elixir/BEAM (low volume, but serious when it hits) versus RubyGems (same shape as npm, lower scale).

This ranking is a snapshot. The npm row could flip green for a year if Shai-Hulud-class worms stop appearing. The Elixir row could flip red overnight if a second OTP-level runtime bug lands. Pick-time security is a risk distribution, not a verdict.


## Takeaways for tech selection

Concrete, tech-pick-level advice based on the above:

**If you're picking Next.js:**
- Assume middleware is *one* enforcement layer, not the enforcement layer. Re-check authz in handlers / server actions.
- Keep Next.js patch versions aggressively current — 2025 had two critical advisories, and both saw in-the-wild exploitation fast.
- If you're on App Router + RSC, the December 2025 advisories (React2Shell) are structural — audit server actions for any attacker-influenced deserialized payloads.

**If you're picking WordPress:**
- The real question is *plugin policy*, not core. Restrict plugins to a vetted short list, track ownership changes (`wp-online-support` → Essential Plugin → new owner is the canonical warning story), and automate patch windows to hours, not weeks. Mass exploitation often starts within **a day** of patch release.
- Budget for force-update infrastructure. Being on the latest plugin version is worth more than perimeter scanning.

**If you're picking Python:**
- Pin everything with hashes (`pip install --require-hashes`). Use `uv` or `pip-tools` to generate lockfiles with SHA-256s.
- Prefer **trusted publishing** (OIDC) for your own packages. It removes the "PyPI token on a laptop" failure mode that caused ultralytics-adjacent attacks.
- AI/ML stacks (ultralytics, litellm, transformers, etc.) are the current most-targeted subset of PyPI. Extra scrutiny warranted.

**If you're picking npm / Node.js:**
- Pin to exact versions + hashes (`package-lock.json` + `npm ci`, or pnpm / yarn equivalent).
- Disable install scripts for dependencies unless explicitly needed (`npm ci --ignore-scripts`, or a managed allowlist). This alone would have blocked Shai-Hulud.
- Use publishing 2FA with hardware keys and consider [provenance-attested publishing](https://docs.npmjs.com/generating-provenance-statements) for your own packages.

**If you're using GitHub Actions (you are):**
- Pin Actions by **full commit SHA**, not tag. `@v4` is not immutable. The `tj-actions` compromise is the proof.
- Treat workflow logs in public repos as public output; review what gets echoed.

**If you're using Docker images from a registry:**
- Pin by digest (`image@sha256:...`), not tag, for production workloads.
- Rebuild base images on a schedule — stale images carry stale CVEs (XZ-in-Docker-Hub is the textbook case).

**Cross-cutting:**
- **SBOM + dependency monitoring is no longer optional.** Something like Dependabot / Renovate / Snyk / Socket catches most of the above within hours of disclosure.
- **Restrict CI secrets to the minimum blast radius.** The `tj-actions` incident converted "secrets visible in public logs" into account takeover because those secrets were long-lived. Short-lived, scoped tokens (OIDC to cloud providers) change the incident response curve dramatically.

None of these ecosystems is safe; none is hopeless. Pick the stack that fits your product, then budget explicitly for the **specific** risk shape it carries.
