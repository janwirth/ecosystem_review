# Authentication in Gleam

> [!NOTE]
> **Status:** DRAFT · **Authoring:** AI-assisted, human-reviewed.

So you want to log users in, hash their passwords, gate routes, and not get woken up at 3am because someone shipped `==` against a stored password — written in Gleam?

The Gleam side of authentication is **a strong floor of primitives, a thin middle, and a near-empty top**. Password hashing, JWT/JOSE, OAuth2 clients, TOTP, and Fernet/Branca tokens are all covered — sometimes with three independent implementations. Sessions, magic links, identity providers, SAML, LDAP, and OIDC servers are largely absent. You assemble auth from parts; you don't install a "framework" (with one fresh exception).

This article surveys what exists, what's idiomatic, and what to avoid.

## Table of Contents

1. [Summary](#summary)
2. [State of the ecosystem](#state-of-the-ecosystem)
3. [Research Method](#research-method)
   - [Scoring Dimensions](#scoring-dimensions)
   - [Discovery](#discovery)
4. [Categories](#categories)
   - [Password hashing](#password-hashing) — [argus](#argus) · [antigone](#antigone) · [aragorn2](#aragorn2) · [beecrypt](#beecrypt) · [pinkdf2](#pinkdf2) · [gzxcvbn](#gzxcvbn)
   - [JOSE — JWT, JWS, JWE](#jose--jwt-jws-jwe) — [gose](#gose) · [ywt](#ywt) · [gwt](#gwt)
   - [Token encryption — Fernet & Branca](#token-encryption--fernet--branca) — [amaro](#amaro)
   - [OAuth2 / OIDC clients](#oauth2--oidc-clients) — [glow_auth](#glow_auth) · [vestibule](#vestibule) · [flwr_oauth2](#flwr_oauth2) · [glebs](#glebs) · [spotless](#spotless)
   - [TOTP & 2FA](#totp--2fa) — [totally](#totally) · [twillio_verify](#twillio_verify)
   - [WebAuthn / Passkeys](#webauthn--passkeys) — [felix](#felix)
   - [Identity-as-a-Service (magic links, passwordless)](#identity-as-a-service-magic-links-passwordless) — [supa](#supa) · [stytch](#stytch)
   - [HTTP basic auth & request signing](#http-basic-auth--request-signing) — [wisp_basic_auth](#wisp_basic_auth) · [aws4_request](#aws4_request)
   - [Sessions](#sessions) — [kv_sessions](#kv_sessions)
   - [Batteries-included](#batteries-included) — [glimr_auth](#glimr_auth)
   - [What's missing](#whats-missing)
5. [Composing the pieces — practical recipes](#composing-the-pieces--practical-recipes)
6. [Cookbook](#cookbook)
   - [Single hard-coded password + cookie session (Wisp)](#recipe--single-hard-coded-password--cookie-session-wisp)
   - [Limitations & when NOT to use this](#limitations--when-not-to-use-this)
   - [Verification — sources consulted](#verification--sources-consulted)
7. [Leaderboard](#leaderboard)

## Summary

Snapshot: **2026-04-26**.

| Category | ☎️ BEAM | 📜 JS |
| --- | --- | --- |
| **[Password hashing](#password-hashing)** | · [🥇](#leaderboard) [argus](#argus) ([repo](https://github.com/Pevensie/argus), 24★) — *Argon2 via reference C NIF*<br>· [antigone](#antigone) ([repo](https://github.com/lpil/antigone), 22★) — *Argon2 via Elixir's `argon2_elixir`*<br>· [aragorn2](#aragorn2) ([repo](https://github.com/maxdeviant/aragorn2), 5★) — *Argon2 via precompiled Rust NIF*<br>· [beecrypt](#beecrypt) ([repo](https://github.com/lpil/beecrypt), 10★) — *bcrypt NIF; the README itself recommends argus*<br>· [pinkdf2](#pinkdf2) ([repo](https://github.com/yazatamorph/pinkdf2), 1★) — *PBKDF2 via `fast_pbkdf2`*<br>· [gzxcvbn](#gzxcvbn) ([repo](https://github.com/Pevensie/gzxcvbn), 10★) — *zxcvbn-style strength scoring* | — |
| **[JOSE — JWT/JWS/JWE](#jose--jwt-jws-jwe)** | · [gose](#gose) ([repo](https://github.com/jtdowney/gose), 5★) — *full JOSE + COSE; the only single-package option that supports asymmetric algorithms*<br>· [ywt](#ywt) ([gitlab](https://gitlab.com/arkandos/ywt)) — *JWT only, BSD-3, split into `ywt_core` + `ywt_erlang`*<br>· [gwt](#gwt) ([repo](https://github.com/brettkolodny/gwt), 30★) — *JWT, **HS256/384/512 only*** | · [gose](#gose) — *also targets JS (Node.js 22+)*<br>· [ywt](#ywt) — *JS via `ywt_webcrypto` (SubtleCrypto)* |
| **[Token encryption](#token-encryption--fernet--branca)** | · [amaro](#amaro) ([repo](https://github.com/jtdowney/amaro), 0★) — *Fernet + Branca, TTL-aware. Same author as gose, who recommends Fernet over JWT for new systems* | — |
| **[OAuth2 / OIDC clients](#oauth2--oidc-clients)** | · [🥇](#leaderboard) [glow_auth](#glow_auth) ([repo](https://github.com/adz/glow_auth), 23★) — *grants, refresh, `Authorization` headers; the foundation*<br>· [vestibule](#vestibule) ([repo](https://github.com/tylerbutler/vestibule)) — *strategy-based, ships GitHub/Google/Microsoft/Apple — **GitHub-only, not on Hex***<br>· [flwr_oauth2](#flwr_oauth2) ([repo](https://github.com/fweingartshofer/oauth), 2★) — *RFC 6749 + PKCE + revocation, BYO HTTP client* | · [spotless](#spotless) ([repo](https://github.com/CrowdHailer/spotless), 17★) — *PKCE/DPoP/PAR via a hosted broker; personal-project niche*<br>· [glebs](#glebs) ([repo](https://github.com/andho/glebs), 4★) — *PKCE in the browser, pairs with Lustre*<br>· [flwr_oauth2](#flwr_oauth2) — *also targets JS via BYO HTTP* |
| **[TOTP / 2FA](#totp--2fa)** | · [totally](#totally) ([repo](https://github.com/okkdev/totally), 8★) — *RFC 6238 TOTP; configurable digits/algorithm, otpauth URI*<br>· [twillio_verify](#twillio_verify) ([repo](https://github.com/davecaos/twillio_verify), 2★) — *Twilio Verify SMS/voice/WhatsApp/email codes* | · [totally](#totally) — *also targets JS* |
| **[WebAuthn / Passkeys](#webauthn--passkeys)** | — | · [felix](#felix) ([repo](https://github.com/CrowdHailer/felix), 15★) — *Passkey auth via `@simplewebauthn/server`* |
| **[Identity-as-a-Service](#identity-as-a-service-magic-links-passwordless)** | · [stytch](#stytch) ([repo](https://github.com/dusty-phillips/stytch_in_gleam), 1★) — *codecs + client + UI model; magic link + OTP* | · [supa](#supa) ([repo](https://github.com/CrowdHailer/supa), 8★) — *Supabase auth (magic links), no `supabase.js` needed*<br>· [stytch](#stytch) — *codecs and UI model are isomorphic* |
| **[HTTP basic / signing](#http-basic-auth--request-signing)** | · [wisp_basic_auth](#wisp_basic_auth) ([repo](https://github.com/iindyverse/wisp_basic_auth), 5★) — *Basic Auth middleware for Wisp*<br>· [aws4_request](#aws4_request) ([repo](https://github.com/lpil/aws4_request), 7★) — *AWS SigV4 request signer* | · [aws4_request](#aws4_request) — *also targets JS* |
| **[Sessions](#sessions)** | · [kv_sessions](#kv_sessions) ([repo](https://github.com/MaxHill/kv_sessions), 3★) — *Wisp KV sessions + Postgres adapter; ~16 months idle* | — |
| **[Batteries-included](#batteries-included)** | · [glimr_auth](#glimr_auth) ([repo](https://github.com/glimr-org/auth)) — *Argon2id login/logout/sessions wired into the [glimr](web-and-http/web-apps.md#glimr) framework* | — |

> [!NOTE]
> No native Gleam package exists for an OAuth2/OIDC **provider**, SAML, LDAP, or BEAM-target WebAuthn. See [What's missing](#whats-missing).

## State of the ecosystem

Auth in Gleam is **dense at the bottom, sparse at the top.**

What's there:
- **Three** independent Argon2 implementations (Elixir-NIF, C-NIF, Rust-NIF), plus bcrypt and PBKDF2.
- **Three** JOSE/JWT libraries — including a comprehensive JOSE+COSE implementation that compiles to both BEAM and JavaScript.
- **Five** OAuth2 client libraries spanning server-side BEAM, in-browser PKCE, and a hosted-broker option for personal projects.
- A working **TOTP** library, a **WebAuthn** wrapper (JS only), **Fernet/Branca** token encryption, and Wisp-flavored **HTTP Basic** middleware.
- One **batteries-included framework component** ([glimr_auth](#glimr_auth)) that wires Argon2 + sessions + login/logout into the glimr web framework.

What's missing entirely:
- No OAuth2 / OIDC **provider** (authorization server) library.
- No **SAML** or **LDAP** clients.
- No **OIDC client** with discovery + `id_token` verification as a first-class feature (you assemble it from `gose` or `ywt` + `glow_auth`).
- No **BEAM-target WebAuthn** ([felix](#felix) is JS-only).
- No native **magic-link primitive** — only IDaaS clients (`supa`, `stytch`).
- No **PASETO**.
- No vendor SDKs for Auth0, Keycloak, Ory/Kratos, Clerk.
- The leading sessions package (`kv_sessions`) is **~16 months idle** and has an open request to bump stdlib.

Star counts are small — biggest auth-specific package tops out around 30★. Use these as **thin, replaceable layers** and lean on Erlang/Elixir libraries via FFI for anything BEAM-native that Gleam itself doesn't yet have (e.g. `:gen_smtp`-style bridges for SAML or LDAP).

## Research Method

### Scoring Dimensions

- **Stars:** Community adoption signal based on star count. 🟩🟩 = ≥200★, 🟩 = ≥100★, 🟨 = ≥10★, 🟥 = <10★. *Auth packages skew small — most land in 🟨 or 🟥.*
- **License:** Whether the license allows unrestricted commercial use. 🟩 = permissive OSS (MIT, Apache-2.0, BSD). 🟥 = viral (GPL, AGPL) or no license.
- **Gleam compat:** Checks `gleam_stdlib` version constraint format in `gleam.toml` `[dependencies]`. 🟩 = range constraint (`>= X and < Y`), 🟥 = non-range (`~>` style) which can cause resolver conflicts. *Example: `~> 0.60` → 🟥; `>= 0.44.0 and < 2.0.0` → 🟩.*
- **Maintenance:** Two-level scoring. Final = **max(recency, responsiveness)**. **Recency:** last commit relative to snapshot. 🟩🟩 = <1 month, 🟩 = <6 months, 🟨 = <1 year, 🟥 = >1 year. **Responsiveness:** time for the maintainer to reply to issues / update PRs (owner comment = ball in opener's court). 🟩🟩 = <2 days, 🟩 = <1 week, 🟨 = <1 month, 🟥 = >1 month or ignored. Clean tracker (0 open issues/PRs) = 🟩🟩.
- **Age:** Time from first visible commit to snapshot. 🟩🟩 = ≥3 years, 🟩 = ≥1 year, 🟨 = ≥3 months, 🟥 = <3 months.
- **README maturity:** 🟩🟩 = guide-style with examples, full feature docs, getting-started. 🟩 = clear description and basic usage. 🟥 = minimal or missing.
- **Idiomaticity:** Whether the project follows Gleam principles — typed, sound, explicit, no magic. 🟩 = idiomatic. 🟥 = magic / implicit behavior.

**Leaderboard scoring:** 🟥 = −1, 🟨 = 0, 🟩 = 1, 🟩🟩 = 2. Sum of all 7 dimensions. Max = 13.

### Discovery

~30 search terms run against the [Gleam packages registry](https://packages.gleam.run/). Cross-checked against GitHub topic tags and direct repo searches.

- [auth](https://packages.gleam.run/?search=auth)
- [authentication](https://packages.gleam.run/?search=authentication)
- [jwt](https://packages.gleam.run/?search=jwt) · [jws](https://packages.gleam.run/?search=jws) · [jwe](https://packages.gleam.run/?search=jwe) · [jose](https://packages.gleam.run/?search=jose)
- [oauth](https://packages.gleam.run/?search=oauth) · [oauth2](https://packages.gleam.run/?search=oauth2) · [oidc](https://packages.gleam.run/?search=oidc) · [openid](https://packages.gleam.run/?search=openid)
- [session](https://packages.gleam.run/?search=session) · [sessions](https://packages.gleam.run/?search=sessions) · [cookie](https://packages.gleam.run/?search=cookie)
- [password](https://packages.gleam.run/?search=password) · [bcrypt](https://packages.gleam.run/?search=bcrypt) · [argon2](https://packages.gleam.run/?search=argon2) · [scrypt](https://packages.gleam.run/?search=scrypt) — *no results* · [pbkdf2](https://packages.gleam.run/?search=pbkdf2)
- [totp](https://packages.gleam.run/?search=totp) · [hotp](https://packages.gleam.run/?search=hotp) — *no results* · [otp](https://packages.gleam.run/?search=otp) · [2fa](https://packages.gleam.run/?search=2fa) · [mfa](https://packages.gleam.run/?search=mfa) — *no results*
- [webauthn](https://packages.gleam.run/?search=webauthn) · [passkey](https://packages.gleam.run/?search=passkey)
- [magic](https://packages.gleam.run/?search=magic) — *no auth-specific results*
- [saml](https://packages.gleam.run/?search=saml) — *no results* · [ldap](https://packages.gleam.run/?search=ldap) — *no results*
- [paseto](https://packages.gleam.run/?search=paseto) — *no results* · [fernet](https://packages.gleam.run/?search=fernet) · [branca](https://packages.gleam.run/?search=branca)
- [keycloak](https://packages.gleam.run/?search=keycloak) — *no results* · [auth0](https://packages.gleam.run/?search=auth0) — *no results* · [clerk](https://packages.gleam.run/?search=clerk) — *no results* · [supabase](https://packages.gleam.run/?search=supabase) · [stytch](https://packages.gleam.run/?search=stytch)
- [identity](https://packages.gleam.run/?search=identity) · [login](https://packages.gleam.run/?search=login)
- [signature](https://packages.gleam.run/?search=signature) · [hmac](https://packages.gleam.run/?search=hmac)

> <details>
> <summary>Disregarded — abandoned, retired, or out of scope</summary>
>
> **Retired / superseded:**
> - **[swen_jwt](https://hex.pm/packages/swen_jwt)** — minimal JWT lib. Marked **retired** on Hex; ~0 downloads / 30 days. Use [gose](#gose) or [gwt](#gwt) instead.
> - **[wisp_kv_sessions](https://github.com/MaxHill/wisp_kv_sessions)** — explicit deprecation notice in README pointing to [kv_sessions](#kv_sessions).
> - **[howdy_authentication_cookies](https://hex.pm/packages/howdy_authentication_cookies)** — last release 2022-06; the parent `howdy` framework is itself ~3 years dormant.
>
> **Long-dormant:**
> - **[biscotto](https://github.com/peonii/biscotto)** — HTTP-client cookie jar (outbound, not session storage). Last commit 2024-05-15, ~24 months idle.
> - **[plex_pin_auth](https://github.com/harrisonhoward/plex_pin_auth)** — Plex-only PIN flow. Niche, ~20 months idle.
>
> **Reference / not a library:**
> - **[donnaloia/authentication-service](https://github.com/donnaloia/authentication-service)** — standalone Docker+Postgres microservice, **not** a Gleam library. Last commit 2024-12-24. The closest thing to a Gleam-built auth server.
> - **[skinkade/wisp_auth_example](https://github.com/skinkade/wisp_auth_example)** — example/demo for Wisp, last commit 2024-07-06.
>
> **Out of scope:**
> - **[cowl](https://github.com/lupodevelop/cowl)** / **redact** — secret-masking helpers (prevent password/API-key log leakage). Useful adjacent, but not auth themselves; mentioned in [recipes](#composing-the-pieces--practical-recipes).
>
> </details>

## Categories

### Password hashing

The lowest-level slot is also the most-served: **three** independent Argon2 NIF backings, plus bcrypt and PBKDF2. Pick by NIF strategy and tolerance for build-time toolchain — all three Argon2 libs expose effectively the same interface.

> [!NOTE]
> For non-password hashing (file integrity, HMAC, content-addressing, hash-map keying, fast non-crypto), see [hashing.md](hashing.md). **Never** use a general-purpose hash like SHA-256 (`gleam_crypto.hash`) for password storage — SHA-256 is fast, which is the wrong property here.

| Criterion | [argus](https://github.com/Pevensie/argus) | [antigone](https://github.com/lpil/antigone) | [aragorn2](https://github.com/maxdeviant/aragorn2) | [beecrypt](https://github.com/lpil/beecrypt) | [pinkdf2](https://github.com/yazatamorph/pinkdf2) |
| --- | --- | --- | --- | --- | --- |
| Algorithm | Argon2id | Argon2id | Argon2id | bcrypt | PBKDF2 |
| NIF source | C reference impl (via `jargon`) | Elixir's `argon2_elixir` | Precompiled Rust | Erlang `bcrypt` | `fast_pbkdf2` |
| Stars | 24★ · 🟨 | 22★ · 🟨 | 5★ · 🟥 | 10★ · 🟨 | 1★ · 🟥 |
| License | MIT · 🟩 | Apache-2.0 · 🟩 | MIT · 🟩 | Apache-2.0 · 🟩 | Apache-2.0 · 🟩 |
| Target | ☎️ BEAM | ☎️ BEAM (requires Elixir in build) | ☎️ BEAM | ☎️ BEAM (no Windows) | ☎️ BEAM |
| Gleam compat | (stdlib in dev-deps; runtime constraint via `jargon >= 1.0.1 and < 2.0.0`) · 🟩 | (no `gleam_stdlib` constraint declared) · ⬜ | `>= 0.34.0 and < 2.0.0` · 🟩 | `>= 0.28.0 and < 2.0.0` · 🟩 | `>= 0.44.0 and < 2.0.0` · 🟩 |
| Maintenance | 🟨 (last commit 2025-06-18; 1 open issue 2026-04-06) | 🟥 (last commit 2024-06-01; 0 open) | 🟥 (last commit 2025-01-30; 1 open issue 2026-03-01 unanswered: "could a release be cut?") | 🟨 (last commit 2025-05-14; 1 open issue 2025-05-10) | 🟩 (last commit 2025-02-21; 0 open) |
| README | 🟩🟩 (guide + cost-param doc + Docker notes) | 🟩 (clear quickstart) | 🟩🟩 (OWASP defaults documented) | 🟩 (quickstart + explicit recommendation to use argus instead) | 🟩 (quickstart) |
| Idiomaticity | 🟩 | 🟩 | 🟩 | 🟩 | 🟩 |

> [!IMPORTANT]
> **Argon2id is the current default recommendation** (OWASP 2023+). bcrypt and PBKDF2 are listed because some compliance regimes still mandate them — for greenfield, prefer Argon2id via [argus](#argus).

#### argus
[repo](https://github.com/Pevensie/argus) · [hexdocs](https://hexdocs.pm/argus/)

Argon2 password hashing built on the Argon2 reference C implementation through the `jargon` NIF wrapper. Configurable cost parameters with sane defaults. The most-recommended Argon2 library at snapshot — `glimr_auth`'s Argon2id integration is a wrapper around argus.

```gleam
import argus

pub fn hash_and_verify() {
  let assert Ok(hashed) = argus.hash("hunter2")
  let assert Ok(True) = argus.verify("hunter2", hashed)
  let assert Ok(False) = argus.verify("wrong", hashed)
}
```

Note: 1 open issue at snapshot ([#6](https://github.com/Pevensie/argus/issues/6), 2026-04-06) raised by the author of [gose](#gose) about variable salt-length parameterization — discussion-style, not a bug blocker.

#### antigone
[repo](https://github.com/lpil/antigone) · [hexdocs](https://hexdocs.pm/antigone/)

"Argon2 password hashing for Gleam." Single-dependency wrapper around Elixir's `argon2_elixir`. The shape mirrors argus, but you need **Elixir + mix in your build environment** — fine for most BEAM stacks, awkward for slim Erlang-only builds. Last commit ~22 months pre-snapshot; the API surface is small enough that this is mostly a non-issue, but the `jargon`-based [argus](#argus) is the more actively maintained path today.

#### aragorn2
[repo](https://github.com/maxdeviant/aragorn2) · [hexdocs](https://hexdocs.pm/aragorn2/)

Argon2id via a precompiled Rust NIF (Linux/macOS/Windows wheels). README documents OWASP-recommended defaults (m=19456, t=2, p=1). Open issue [#8](https://github.com/maxdeviant/aragorn2/issues/8) (2026-03-01, no maintainer reply at snapshot) requests a release for the 2025-01-30 fix — caveat for production use.

#### beecrypt
[repo](https://github.com/lpil/beecrypt) · [hexdocs](https://hexdocs.pm/beecrypt/)

Gleam bindings to the Erlang `bcrypt` NIF. The README itself **explicitly recommends [argus](#argus) instead** unless your environment requires bcrypt specifically. No Windows support (NIF limitation).

#### pinkdf2
[repo](https://github.com/yazatamorph/pinkdf2) · [hexdocs](https://hexdocs.pm/pinkdf2/)

PBKDF2 via the `fast_pbkdf2` NIF. Used where compliance frameworks (FIPS, some banking regs) demand PBKDF2 over Argon2/bcrypt. Otherwise prefer Argon2.

#### gzxcvbn
[repo](https://github.com/Pevensie/gzxcvbn)

Not hashing — a pure-Gleam port of [zxcvbn](https://github.com/dropbox/zxcvbn) for **password strength scoring**. Useful at signup time to surface a 0–4 score and human-readable feedback before the password ever reaches the hash. Pairs naturally with [argus](#argus). Companion package: `gzxcvbn_common` (shared dictionaries).


### JOSE — JWT, JWS, JWE

Three options, three different shapes. Pick by what you need to sign and where it runs.

| Criterion | [gose](https://github.com/jtdowney/gose) | [ywt](https://gitlab.com/arkandos/ywt) | [gwt](https://github.com/brettkolodny/gwt) |
| --- | --- | --- | --- |
| Standards | JWS · JWE · JWK · JWT · COSE | JWT (HS/RS/ES/PS at 256/384/512) | JWT |
| Signing algos | HS256/384/512, RS256/384/512, ES256/384/512, PS256/384/512, EdDSA | HS, RS, ES, PS at 256/384/512 | **HS256/384/512 only** |
| Stars | 5★ · 🟥 | (gitlab) · ⬜ | 30★ · 🟨 |
| License | Apache-2.0 · 🟩 | BSD-3-Clause · 🟩 | Apache-2.0 · 🟩 |
| Target | ☎️📜 Both (OTP 27+, Node 22+) | ☎️ BEAM via `ywt_erlang` (uses `:public_key`); 📜 JS via `ywt_webcrypto` (SubtleCrypto) | ☎️ BEAM (uses `gleam_crypto`, `birl`) |
| Gleam compat | `>= 0.44.0 and < 2.0.0` · 🟩 | range (per Hex) · 🟩 | `>= 0.51.0 and < 2.0.0` · 🟩 |
| Maintenance | 🟩🟩 (last commit 2026-04-24, 0 open) | 🟩 (last release 2026-02-01) | 🟩 (last commit 2025-09-18; 1 open issue: "Adding RS256", 2024-06-26 — **the open RS256 issue is exactly why this category needs gose or ywt**) |
| README | 🟩🟩 (security philosophy, algorithm pinning, explicit "prefer Fernet" disclaimer) | 🟩🟩 (HexDocs guide, security caveats) | 🟩 (tagline + quickstart) |
| Idiomaticity | 🟩 | 🟩 | 🟩 |

#### gose
[repo](https://github.com/jtdowney/gose) · [hexdocs](https://hexdocs.pm/gose/)

The most comprehensive JOSE/COSE implementation in Gleam. Full JWS, JWE, JWK, JWT, plus COSE for IoT/CBOR worlds. Compiles to **both BEAM and JavaScript** out of one package — distinguishing it from [ywt](#ywt), which splits the targets across separate packages.

The README explicitly takes a stance: it lists algorithms you "should basically never use in greenfield" and points readers to **Fernet/Branca** ([amaro](#amaro), same author) for opaque tokens. Treat gose as the choice when you actually need JOSE interop (third-party identity provider, signed claims for an external audience).

```gleam
import gose/jwt
import gose/jws

pub fn sign_and_verify(secret: BitArray) {
  let claims = jwt.new()
    |> jwt.set_subject("user-123")
    |> jwt.set_expiration_relative(3600)

  let assert Ok(token) = jwt.sign_hs256(claims, secret)
  let assert Ok(verified) = jwt.verify_hs256(token, secret)
  verified
}
```

#### ywt
[gitlab](https://gitlab.com/arkandos/ywt) · [hexdocs](https://hexdocs.pm/ywt_core/)

Three-package layout: `ywt_core` (algorithm-agnostic types), `ywt_erlang` (uses Erlang `:public_key` for asymmetric algos), `ywt_webcrypto` (uses browser/Node SubtleCrypto). You depend only on the target you actually run — useful for keeping JS bundles slim or BEAM artifacts free of WebCrypto stubs. BSD-3 licensed.

#### gwt
[repo](https://github.com/brettkolodny/gwt) · [hexdocs](https://hexdocs.pm/gwt/)

The most-starred JWT library — but **HMAC only**. RS256 is tracked at [issue #X](https://github.com/brettkolodny/gwt/issues) (open since 2024-06-26). Fine for first-party tokens between your own services where you control both ends. **Not** suitable for verifying tokens issued by Google/Auth0/Keycloak/etc., which sign with RS256 / ES256.

```gleam
import gwt

pub fn issue() {
  let token = gwt.new()
    |> gwt.set_subject("user-123")
    |> gwt.set_expiration(unix_ts: 1893456000)
    |> gwt.to_signed_string(gwt.HS256, "secret")
  token
}
```


### Token encryption — Fernet & Branca

JWTs are **signed**, not encrypted — payload is base64url, anyone can decode it. When you need a token whose contents the holder shouldn't read (session token, CSRF, short-lived credential), reach for symmetric authenticated encryption.

#### amaro
[repo](https://github.com/jtdowney/amaro) · [hexdocs](https://hexdocs.pm/amaro/)

Implements **Fernet** (URL-safe AES-128-CBC + HMAC-SHA256, with a built-in TTL) and **Branca** (XChaCha20-Poly1305 with timestamp). Same author as [gose](#gose), and gose's README explicitly recommends Fernet for greenfield session-style tokens over JWT. Amaro is small, recent (last commit 2026-04-24), no open issues.

```gleam
import amaro/fernet

pub fn round_trip(key: BitArray) {
  let assert Ok(token) = fernet.encrypt(key, <<"user-123":utf8>>)
  // later, with a max-age window:
  let assert Ok(payload) = fernet.decrypt(key, token, ttl_seconds: 3600)
  payload
}
```

| Stars | License | Target | Compat | Maintenance | Age | README | Idiom |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 0★ · 🟥 | Apache-2.0 · 🟩 | ☎️ BEAM (others not declared) | `>= 0.44.0 and < 2.0.0` · 🟩 | 🟩🟩 (last commit 2026-04-24, 0 open) | (recent) · 🟨 | 🟩🟩 | 🟩 |


### OAuth2 / OIDC clients

"Sign in with Google/GitHub/etc." Five packages, three different shapes:

- **Server-side, BEAM-target:** [glow_auth](#glow_auth), [vestibule](#vestibule), [flwr_oauth2](#flwr_oauth2)
- **Browser-side, JS-target:** [glebs](#glebs), [spotless](#spotless)
- **Hosted broker (skip vendor app registration):** [spotless](#spotless)

| Criterion | [glow_auth](https://github.com/adz/glow_auth) | [vestibule](https://github.com/tylerbutler/vestibule) | [flwr_oauth2](https://github.com/fweingartshofer/oauth) | [glebs](https://github.com/andho/glebs) | [spotless](https://github.com/CrowdHailer/spotless) |
| --- | --- | --- | --- | --- | --- |
| Niche | OAuth2 helpers (grants, refresh, headers) | Strategy-based; ships GitHub/Google/Microsoft/Apple | RFC 6749 + PKCE + revocation, BYO HTTP | In-browser PKCE for Lustre apps | Personal-project broker (PKCE/DPoP/PAR) |
| Stars | 23★ · 🟨 | 0★ · 🟥 (**not yet on Hex**) | 2★ · 🟥 | 4★ · 🟥 | 17★ · 🟨 |
| License | Apache-2.0 · 🟩 | MIT · 🟩 | MIT · 🟩 | Apache-2.0 · 🟩 | Apache-2.0 · 🟩 |
| Target | ☎️ BEAM | ☎️ BEAM (uses `gleam_httpc`) | ☎️📜 Both (BYO HTTP) | 📜 JS (browser) | 📜 JS |
| Gleam compat | `~> 0.60` · 🟥 | `>= 0.48.0 and < 2.0.0` · 🟩 | `>= 0.44.0 and < 2.0.0` · 🟩 | `>= 0.34.0 and < 2.0.0` · 🟩 | `>= 0.44.0 and < 2.0.0` · 🟩 |
| Maintenance | 🟩 (last commit 2025-08-23, 0 open) | 🟩🟩 (last commit 2026-04-07, 2 open enhancement requests 2026-04-05) | 🟩🟩 (last commit 2026-04-14, 0 open) | 🟨 (last commit 2025-05-29, 0 open) | 🟩🟩 (last commit 2026-03-20, 0 open) |
| README | 🟩🟩 (grant-by-grant guide, refresh, header helper) | 🟩🟩 (Ueberauth-inspired strategy doc + provider list) | 🟩🟩 (install/usage/dev guide) | 🟩 (PKCE walkthrough) | 🟩🟩 (value prop, why-spotless, integration matrix) |
| Idiomaticity | 🟩 | 🟩 (strategy pattern is explicit & typed) | 🟩 (returns `http.Request`) | 🟩 | 🟩 |

> [!WARNING]
> No package implements **OIDC discovery + `id_token` verification end-to-end** as a first-class feature. To verify an `id_token` from Google/Auth0/Microsoft, you fetch the JWKS yourself and verify with [gose](#gose) or [ywt](#ywt). [vestibule](#vestibule) does this for the strategies it ships, but each provider is hand-coded — there's no generic OIDC RP library.

#### glow_auth
[repo](https://github.com/adz/glow_auth) · [hexdocs](https://hexdocs.pm/glow_auth/)

The longest-running OAuth2 helper. Covers authorization-code grant, client-credentials grant, refresh tokens, and `Authorization: Bearer …` header construction. Bring your own HTTP client. The 🟥 on Gleam compat is from `~> 0.60` in `gleam.toml` — a non-range constraint that can occasionally cause resolver surprises.

```gleam
import glow_auth
import glow_auth/authorize_uri.{type AuthUriSpec}
import glow_auth/access_token_request

pub fn build_request() {
  let client = glow_auth.Client(
    id: "my-client-id",
    secret: "my-client-secret",
    site: "https://example.com",
  )

  let auth_uri = authorize_uri.build(
    AuthUriSpec(
      client: client,
      redirect_uri: "https://app.test/callback",
      authorize_path: "/oauth/authorize",
      scopes: ["read", "write"],
      state: option.Some("anti-csrf-state"),
    ),
  )
  auth_uri
}
```

#### vestibule
[repo](https://github.com/tylerbutler/vestibule)

Strategy-based OAuth2 in the spirit of Elixir's [Ueberauth](https://github.com/ueberauth/ueberauth). Ships ready-made strategies for GitHub, Google, Microsoft, Apple Sign In; build new ones by implementing a small protocol. Built on top of [glow_auth](#glow_auth). **GitHub-only at snapshot — not yet published to Hex / packages.gleam.run** — pin via git dependency until release.

#### flwr_oauth2
[repo](https://github.com/fweingartshofer/oauth)

Smaller surface, very current. Implements RFC 6749 grants, PKCE, and token revocation. Returns `http.Request` values so you bring whatever HTTP client suits your target (`gleam_httpc`, `gleam_hackney`, `fetch` on JS).

#### glebs
[repo](https://github.com/andho/glebs)

PKCE flow living **in the browser**. Pairs with Lustre SPAs that need to authenticate against a public OAuth2 endpoint. JS target only.

#### spotless
[repo](https://github.com/CrowdHailer/spotless) · [hexdocs](https://hexdocs.pm/spotless/)

A different niche. Spotless is **opinionated** for personal projects — instead of you registering an OAuth client with each vendor, spotless ships with a hosted broker (`spotless.run`) so authentication "just works" with a small fixed set of integrations (DNSimple, GitHub, LinkedIn, Netlify, Twitter, Vimeo). Skip if you need a generic OAuth2 client; reach for it if you want to avoid the OAuth-app registration ceremony for side projects.


### TOTP & 2FA

#### totally
[repo](https://github.com/okkdev/totally) · [hexdocs](https://hexdocs.pm/totally/)

RFC 6238 TOTP — the algorithm Authy / Google Authenticator / 1Password use. Configurable digits/algorithm/period, generates `otpauth://` URIs (so you can QR-code the secret into authenticator apps), runs on both BEAM and JS. The only TOTP library in the ecosystem.

```gleam
import totally

pub fn enroll() {
  let secret = totally.generate_secret()
  let uri = totally.otpauth_uri(
    secret:,
    issuer: "ExampleApp",
    account: "user@example.com",
  )
  // QR-encode `uri`, store `secret` server-side
  uri
}

pub fn verify(secret: String, code: String) {
  totally.verify(secret, code)  // accepts current ± 1 step by default
}
```

| Stars | License | Target | Compat | Maintenance | Age | README | Idiom |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 8★ · 🟥 | Apache-2.0 · 🟩 | ☎️📜 Both | `>= 0.34.0 and < 2.0.0` · 🟩 | 🟩🟩 (last commit 2026-02-27, 0 open) | (>1yr) · 🟩 | 🟩🟩 | 🟩 |

> [!NOTE]
> No standalone HOTP library — `totally` is TOTP-only. HOTP is rare in modern apps; TOTP has effectively replaced it.

#### twillio_verify
[repo](https://github.com/davecaos/twillio_verify) · [hexdocs](https://hexdocs.pm/twillio_verify/)

Wraps Twilio's **Verify API** — sends and checks SMS / voice-call / WhatsApp / email codes. Useful when you need 2FA-without-an-app, account verification, or transactional MFA. Twilio carries deliverability and rate-limit problems for you; you carry the bill.

The `gleam_stdlib` constraint here is **`>= 0.67.0 and < 1.0.0`** — note the **upper bound `< 1.0.0`**, not `< 2.0.0`. Will need a version bump to install alongside packages built against stdlib 1.x.


### WebAuthn / Passkeys

#### felix
[repo](https://github.com/CrowdHailer/felix) · [hexdocs](https://hexdocs.pm/felix/)

The only WebAuthn implementation in Gleam. Thin wrapper around [`@simplewebauthn/server`](https://simplewebauthn.dev/) — **JavaScript target only**. If you're running on BEAM, you currently have no native passkey option; either run a JS sidecar for the WebAuthn challenge/response, or call into the Erlang `:webauthn` library by FFI.

```gleam
import felix

pub fn start_registration(user_id: String, user_name: String) {
  felix.generate_registration_options(
    rp_name: "ExampleApp",
    rp_id: "example.com",
    user_id:,
    user_name:,
  )
}
```

| Stars | License | Target | Compat | Maintenance | Age | README | Idiom |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 15★ · 🟨 | Apache-2.0 · 🟩 | 📜 JS | `>= 0.34.0 and < 2.0.0` · 🟩 | 🟥 (last commit 2024-12-04, 1 open issue 2025-12-18 unanswered) | (~1.4yr) · 🟩 | 🟩 | 🟩 |


### Identity-as-a-Service (magic links, passwordless)

For "I don't want to run hashing, sessions, magic-link tokens, or an SMS provider," outsource to a vendor. Two thin Gleam SDKs exist:

#### supa
[repo](https://github.com/CrowdHailer/supa) · [hexdocs](https://hexdocs.pm/supa/)

"Isomorphic Gleam library for Supabase (auth only so far)." Pure Gleam — no `supabase.js` dependency. Browser-safe with the anon key. Supports magic-link sign-in and standard Supabase auth flows.

#### stytch
[repos: codecs](https://github.com/dusty-phillips/stytch_in_gleam) · [hexdocs (codecs)](https://hexdocs.pm/stytch_codecs/)

Three packages: `stytch_codecs` (shared types, isomorphic), `stytch_client` (BEAM via `gleam_httpc`), `stytch_ui_model` (frontend state shape). Currently covers **Magic Link** and **OTP / Passcode** flows. The split lets you share types between Lustre frontend and Wisp backend without dragging the HTTP client into the browser bundle.


### HTTP basic auth & request signing

#### wisp_basic_auth
[repo](https://github.com/iindyverse/wisp_basic_auth) · [hexdocs](https://hexdocs.pm/wisp_basic_auth/)

HTTP Basic Auth middleware for [Wisp](web-and-http/web-apps.md#wisp). Drop-in: `wisp_basic_auth.middleware(req, expected_user, expected_pass, handler)`. README has a useful security note: comparison is timing-safe, but you should still prefer OAuth2 / token auth for anything user-facing.

#### aws4_request
[repo](https://github.com/lpil/aws4_request) · [hexdocs](https://hexdocs.pm/aws4_request/)

AWS Signature Version 4 signer — what S3, DynamoDB, IAM, and most other AWS services authenticate with. Also useful as a model for any service that uses SigV4-style HMAC request signing (some non-AWS services adopt it). Both targets.


### Sessions

#### kv_sessions
[repo](https://github.com/MaxHill/kv_sessions)

Wisp-shaped session middleware over a key-value store. Companion package: `kv_sessions_postgres_adapter`. Supersedes `wisp_kv_sessions` (deprecated by the same author).

| Stars | License | Target | Compat | Maintenance | Age | README | Idiom |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 3★ · 🟥 | (LICENSE not extracted) · ⬜ | ☎️ BEAM | (not extracted) · ⬜ | 🟨 (last commit 2025-01-06; 1 open issue 2025-10-14: "Update for more recent versions of Gleam stdlib") | (>1yr) · 🟩 | 🟩 | 🟩 |

> [!WARNING]
> ~16 months idle at snapshot, with an open issue requesting a stdlib bump (no maintainer reply). The shape is sound and the API is small, but **read the open issue before adopting** — if you need stdlib 1.x compatibility you may have to fork.


### Batteries-included

#### glimr_auth
[repo](https://github.com/glimr-org/auth)

The first — and only — auth component bundled with a full-stack Gleam framework. Part of the [glimr](web-and-http/web-apps.md#glimr) stack. Wires together:

- **Argon2id** password hashing (defaults follow OWASP) via [argus](#argus).
- **Session-based** login/logout backed by glimr's session storage.
- **Timing-attack** protection on password comparison.
- **Session-fixation** protection (rotate session id on login).

| Stars | License | Target | Compat | Maintenance | Age | README | Idiom |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 0★ · 🟥 | MIT · 🟩 | ☎️ BEAM (glimr) | `>= 0.44.0 and < 2.0.0` · 🟩 | 🟩🟩 (last commit 2026-04-21, 0 open) | (~weeks) · 🟥 | 🟩 (features, install, deps) | 🟩 |

This is the closest the ecosystem gets to "drop in `mix.exs`/`Gemfile` line and have login working" — but only if you're already on glimr.


### What's missing

**Empty.** No Gleam-native packages exist at snapshot for:

- **OAuth2 / OIDC providers** — no authorization-server library. The only Gleam-built example is [donnaloia/authentication-service](https://github.com/donnaloia/authentication-service), a standalone microservice (~16 months idle).
- **OIDC client (full)** — no first-class discovery + JWKS + `id_token` verification library. You assemble it from [vestibule](#vestibule) / [glow_auth](#glow_auth) + [gose](#gose).
- **SAML** — zero results.
- **LDAP** — zero results.
- **PASETO** — zero results. Closest alternative: Fernet/Branca via [amaro](#amaro).
- **WebAuthn on BEAM** — [felix](#felix) is JavaScript-only.
- **Magic links (self-hosted)** — only via SaaS clients ([supa](#supa), [stytch](#stytch)).
- **Vendor SDKs** — no Auth0, Keycloak, Ory/Kratos, Clerk, Cognito.
- **Passwordless email/SMS native** — only via SaaS ([twillio_verify](#twillio_verify), Stytch).

If you need any of this on BEAM today, your options are:
- **Erlang/Elixir FFI**: `:samerl` for SAML, `:eldap` (built-in OTP) for LDAP, `:oidcc` for OIDC RP — all callable from Gleam through `@external(erlang, ...)` shims.
- **Sidecar service** in another language, integrated via HTTP or message queue.
- **IDaaS**: outsource the whole stack to Auth0 / Stytch / Supabase / Clerk and wrap their HTTP API.


## Composing the pieces — practical recipes

Auth in Gleam is a build-your-own-stack proposition. The four most common stacks, end-to-end:

### Recipe 1 — Wisp + email/password + sessions (self-hosted)

| Layer | Pick |
| --- | --- |
| HTTP framework | [wisp](web-and-http/web-apps.md#wisp) |
| Password strength (signup-time UX) | [gzxcvbn](#gzxcvbn) |
| Hashing | [argus](#argus) |
| Sessions | [kv_sessions](#kv_sessions) (verify the stdlib-bump issue first) |
| Optional 2FA | [totally](#totally) |
| Secret masking in logs | [cowl](https://github.com/lupodevelop/cowl) |

### Recipe 2 — "Sign in with Google/GitHub" (server-side BEAM)

| Layer | Pick |
| --- | --- |
| HTTP framework | [wisp](web-and-http/web-apps.md#wisp) |
| OAuth2 client + provider strategies | [vestibule](#vestibule) (or [glow_auth](#glow_auth) + hand-rolled per provider) |
| `id_token` verification | [gose](#gose) (RS256/ES256) |
| Session storage | [kv_sessions](#kv_sessions) |

### Recipe 3 — Lustre SPA + OAuth (no backend)

| Layer | Pick |
| --- | --- |
| Frontend | [lustre](web-and-http/web-apps.md#lustre) |
| OAuth (PKCE) | [glebs](#glebs), or [spotless](#spotless) for personal projects |
| Token decoding | [gose](#gose) (JS target) or [ywt_webcrypto](#ywt) |

### Recipe 4 — Skip the whole problem

| Layer | Pick |
| --- | --- |
| Identity provider | Supabase ([supa](#supa)) or Stytch ([stytch](#stytch)) |
| Wire to your app | direct HTTP via [gleam_httpc](https://hexdocs.pm/gleam_httpc/) / [gleam_fetch](https://hexdocs.pm/gleam_fetch/) |

### Glimr shortcut

If you're starting greenfield and don't have framework constraints, **[glimr](web-and-http/web-apps.md#glimr) + [glimr_auth](#glimr_auth)** is the only point in the ecosystem where login-out-of-the-box exists today. New, single-vendor, but the most consolidated story.


## Cookbook

Concrete copy-pasteable recipes. The [recipes above](#composing-the-pieces--practical-recipes) pick a stack; this section shows the wiring.

### Recipe — Single hard-coded password + cookie session (Wisp)

> [!CAUTION]
> **Read [Limitations & when NOT to use this](#limitations--when-not-to-use-this) first.** A single shared password has no per-user audit trail, no per-account rate-limit, and no revocation short of a redeploy. It is correct for **internal admin tools, side-project gates, and "shut the door" deployments** — and only those. For anything user-facing, escalate to [Recipe 1](#recipe-1--wisp--emailpassword--sessions-self-hosted).

The shape:

1. **At startup**, read the password from `ADMIN_PASSWORD` env var, hash it once with [argus](#argus), throw the plaintext away. Stash the hash in app state.
2. **On `POST /login`**, verify the submitted password against the hash with `argus.verify` (constant-time). On success, generate a 32-byte random session ID with `gleam/crypto.strong_random_bytes`, store it server-side, and set a `__Host-`-prefixed cookie with `HttpOnly`, `Secure`, `SameSite=Strict`, `Path=/`.
3. **On every protected request**, read the cookie, look up the session ID server-side, deny if missing or expired.
4. **On `POST /logout`**, delete the server-side entry and overwrite the cookie with `Max-Age=0`.

**Why these choices** (verified against [the sources](#verification--sources-consulted)):

- `HttpOnly` blocks JS access — XSS can't read the session cookie. (OWASP, MDN)
- `Secure` blocks transmission over plain HTTP — MITM can't sniff it. (OWASP, MDN)
- `SameSite=Strict` blocks the cookie from being sent on any cross-site request, including top-level GET navigations from external sites — this is the right default for a session that authorises destructive actions on an internal tool. Use `Lax` only if you genuinely need cross-site GET nav (e.g. external email links into the app). (OWASP, MDN)
- `__Host-` prefix forces `Secure`, forbids `Domain`, and requires `Path=/`. The browser refuses to set the cookie if any of those are violated, so a misconfiguration fails loudly instead of silently widening scope to subdomains. (MDN, RFC 6265bis)
- **Random opaque session ID, not a JWT and not the password.** OWASP requires ≥ 64 bits of entropy from a CSPRNG; we use 32 bytes (256 bits) from `gleam/crypto.strong_random_bytes` (OpenSSL `RAND_bytes` on BEAM, WebCrypto on JS). (OWASP)
- **Server-side session table.** The cookie carries only an opaque ID; the "is logged in" fact lives in app state. Logout invalidates the entry instantly — a stateless JWT can't do that without a separate denylist.
- **`argus.verify` is constant-time** — it delegates to the Argon2 reference C implementation, which compares the derived key in constant time. Don't roll your own `==` against a stored hash.

**Caveat on `__Host-` and Wisp.** Wisp's [`wisp.set_cookie`](https://hexdocs.pm/wisp/wisp.html#set_cookie) uses `gleam_http`'s [`cookie.defaults`](https://github.com/gleam-lang/http/blob/main/src/gleam/http/cookie.gleam) — which sets `Secure` (off HTTPS), `HttpOnly`, `Path=/`, and `SameSite=Lax` — and does **not** expose `SameSite=Strict` or the `__Host-` name as parameters. To get those, either (a) drop to `gleam_http`'s `response.set_cookie` with a hand-built `cookie.Attributes` record, or (b) accept the Wisp default of `SameSite=Lax` and skip the `__Host-` prefix. The recipe below shows the explicit-attributes path because the security delta matters.

```gleam
// app/state.gleam — built once at startup, threaded through Wisp's context.

import argus
import gleam/dict.{type Dict}
import gleam/erlang/os
import gleam/erlang/process.{type Subject}
import gleam/option.{type Option}

/// In-memory session table. For multi-node deploys, swap for `kv_sessions` or
/// any KV with TTL (Redis/Postgres). The shape stays identical.
pub type SessionStore =
  Subject(StoreMsg)

pub type StoreMsg {
  Insert(id: String, expires_unix: Int)
  Lookup(id: String, reply_to: Subject(Bool))
  Remove(id: String)
}

pub type AppState {
  AppState(password_hash: String, sessions: SessionStore)
}

pub fn boot() -> Result(AppState, String) {
  use plaintext <- result.try(
    os.get_env("ADMIN_PASSWORD")
    |> result.replace_error("ADMIN_PASSWORD not set"),
  )

  // Hash ONCE at startup with OWASP-recommended Argon2id parameters
  // (m=19456 KiB, t=2, p=1 — the lower-RAM profile from the Password
  // Storage Cheat Sheet). Drop the plaintext.
  let assert Ok(hashes) =
    argus.hasher()
    |> argus.algorithm(argus.Argon2id)
    |> argus.memory_cost(19_456)
    |> argus.time_cost(2)
    |> argus.parallelism(1)
    |> argus.hash_length(32)
    |> argus.hash(plaintext, argus.gen_salt())

  let sessions = start_session_actor()
  Ok(AppState(password_hash: hashes.encoded_hash, sessions:))
}
```

```gleam
// app/auth.gleam — login, logout, middleware.

import app/state.{type AppState}
import argus
import gleam/bit_array
import gleam/crypto
import gleam/erlang/process
import gleam/http/cookie
import gleam/http/response
import gleam/int
import gleam/option
import gleam/result
import gleam/string
import wisp.{type Request, type Response}

const cookie_name = "__Host-session"

const session_ttl_seconds = 28_800
// 8 hours

/// POST /login — body is form-encoded with a single `password` field.
pub fn login(req: Request, state: AppState) -> Response {
  use form <- wisp.require_form(req)
  let submitted =
    form.values
    |> list.key_find("password")
    |> result.unwrap("")

  // Constant-time verify against the startup-computed Argon2id hash.
  case argus.verify(state.password_hash, submitted) {
    Ok(True) -> grant_session(state)
    _ -> wisp.response(401) |> wisp.string_body("Invalid credentials")
  }
}

fn grant_session(state: AppState) -> Response {
  // 32 bytes = 256 bits of entropy from a CSPRNG.
  // OWASP requires ≥ 64 bits; we exceed that comfortably.
  let session_id =
    crypto.strong_random_bytes(32)
    |> bit_array.base64_url_encode(False)

  let now = system_time_seconds()
  process.send(state.sessions, state.Insert(session_id, now + session_ttl_seconds))

  wisp.redirect(to: "/")
  |> set_session_cookie(session_id, max_age: session_ttl_seconds)
}

/// POST /logout
pub fn logout(state: AppState, session_id: String) -> Response {
  process.send(state.sessions, state.Remove(session_id))
  wisp.redirect(to: "/login")
  // Overwrite the cookie with an immediate-expiry empty value.
  |> set_session_cookie("", max_age: 0)
}

/// Middleware: gate `inner` behind a valid session cookie.
pub fn require_session(
  req: Request,
  state: AppState,
  inner: fn(String) -> Response,
) -> Response {
  case read_cookie(req) {
    Ok(session_id) -> {
      let reply = process.new_subject()
      process.send(state.sessions, state.Lookup(session_id, reply))
      case process.receive(reply, 50) {
        Ok(True) -> inner(session_id)
        _ -> wisp.redirect(to: "/login")
      }
    }
    Error(_) -> wisp.redirect(to: "/login")
  }
}

// --- Cookie helpers (hand-rolled because Wisp's set_cookie hard-codes
// SameSite=Lax via gleam_http's cookie.defaults). ---

fn set_session_cookie(
  resp: Response,
  value: String,
  max_age max_age: Int,
) -> Response {
  let attrs =
    cookie.Attributes(
      max_age: option.Some(max_age),
      // __Host- prefix REQUIRES no Domain attribute and Path="/"
      domain: option.None,
      path: option.Some("/"),
      secure: True,
      http_only: True,
      same_site: option.Some(cookie.Strict),
    )
  response.set_cookie(resp, cookie_name, value, attrs)
}

fn read_cookie(req: Request) -> Result(String, Nil) {
  // Wisp's get_cookie expects a Wisp-set cookie (base64 / signed).
  // We rolled our own set above, so parse the raw header instead.
  use header <- result.try(wisp.get_header(req, "cookie"))
  cookie.parse(header)
  |> list.key_find(cookie_name)
}

@external(erlang, "erlang", "system_time")
fn system_time_seconds() -> Int
```

```gleam
// app/router.gleam — wiring it together.

import app/auth
import app/state.{type AppState}
import wisp.{type Request, type Response}

pub fn handle(req: Request, st: AppState) -> Response {
  case wisp.path_segments(req), req.method {
    ["login"], http.Post -> auth.login(req, st)
    ["logout"], http.Post -> {
      use session_id <- auth.require_session(req, st)
      auth.logout(st, session_id)
    }
    // Everything else requires a session.
    _, _ -> {
      use _session_id <- auth.require_session(req, st)
      protected_handler(req)
    }
  }
}
```

**On CSRF.** `SameSite=Strict` blocks the browser from including the session cookie on requests originating from another site, which is the typical CSRF attack vector. That removes the need for an explicit CSRF token for the **specific case** of an internal tool whose session cookie is `Strict` and whose state-changing endpoints accept only `POST`/`PUT`/`DELETE`. If you ever need `SameSite=Lax` (e.g. you want users to follow an emailed link into a logged-in page), CSRF tokens come back into scope — issue a per-session token on login, embed it in forms as a hidden field, verify on every state-changing request. There is no first-class CSRF token library in the Gleam ecosystem at snapshot; roll one with `gleam/crypto.strong_random_bytes` + `gleam/crypto.secure_compare`.

**On rotating the session ID.** OWASP requires session-ID renewal on privilege change. With a single hard-coded password there is only one privilege level (in/out), so the natural moment is **on every successful login** — the snippet above already issues a fresh 256-bit ID per login. Don't reuse a logged-out session's ID.

### Limitations & when NOT to use this

A single shared password is a deliberately small hammer. Honest list of what it does **not** give you:

- **No per-user identity.** Audit logs say "someone with the password did X" — you can't attribute actions to individuals, can't kick one user out without rotating the password for everyone, can't disable an account on offboarding.
- **No password reset, no rotation flow.** Rotating means: change the env var → redeploy → all existing sessions still work (because they only store an opaque ID, not the password). That's actually fine for the common case, but it means you can't *force* a logout fleet-wide without also flushing the session table. Add a "kill all sessions" admin action if you need it.
- **Brute-force exposure scales linearly with password strength.** With a single password and an attacker who can guess at network speed, the only thing standing between them and the door is the password's entropy and your rate-limiter. **Add a rate-limit on `/login`** — IP-based + global, with exponential back-off, per [OWASP's authentication guidance](https://cheatsheetseries.owasp.org/cheatsheets/Authentication_Cheat_Sheet.html#protect-against-automated-attacks). The Gleam ecosystem has no first-class rate-limiter at snapshot; bolt one on with a `dict` or `ets` table keyed by IP, or terminate at a reverse proxy (`nginx`'s `limit_req`, Caddy's `rate_limit`).
- **No MFA.** Pair with [totally](#totally) for TOTP if the deployment is sensitive enough — but at that point you're closer to per-user accounts than this recipe pretends to be.
- **Password leak = total compromise.** If the env var is exfiltrated (logs, CI, screen-share, phishing the operator), every session is forfeit until you rotate. Use [cowl](https://github.com/lupodevelop/cowl) to mask it in logs.
- **In-memory session table = sessions die on restart and don't span nodes.** Acceptable for a single-instance internal tool; for anything multi-node or restart-sensitive, swap in [kv_sessions](#kv_sessions) (verify the open stdlib-bump issue first) or a Redis/Postgres-backed store with the same `Insert`/`Lookup`/`Remove` shape.

**Suitable for:** internal admin dashboards, staging-environment gates, on-call runbook UIs, hobby-project shut-the-door auth, ops dashboards behind a VPN.

**NOT suitable for:** anything user-facing, multi-tenant, regulated (SOC2/HIPAA/PCI), public on the open internet without IP allowlisting, or anywhere "who did this" is a compliance question. Escalate to [Recipe 1](#recipe-1--wisp--emailpassword--sessions-self-hosted).

### Verification — sources consulted

The cookie attributes, session-ID entropy, hashing parameters, and CSRF reasoning above were verified against:

- **OWASP Session Management Cheat Sheet** — [`Set-Cookie` attribute requirements (Secure, HttpOnly, SameSite, Domain, Path), session-ID entropy ≥ 64 bits, CSPRNG requirement, session fixation / renewal on privilege change](https://cheatsheetseries.owasp.org/cheatsheets/Session_Management_Cheat_Sheet.html).
- **OWASP Authentication Cheat Sheet** — [constant-time password comparison, rate-limiting / brute-force protection, MFA guidance](https://cheatsheetseries.owasp.org/cheatsheets/Authentication_Cheat_Sheet.html).
- **OWASP Password Storage Cheat Sheet** — [Argon2id recommended parameters: m=19456 KiB / t=2 / p=1 (low-RAM) or m=47104 KiB / t=1 / p=1 (standard)](https://cheatsheetseries.owasp.org/cheatsheets/Password_Storage_Cheat_Sheet.html).
- **MDN — `Set-Cookie` header** — [attribute syntax and semantics; `__Host-` and `__Secure-` prefix rules; `SameSite=Strict` vs `Lax` vs `None` behaviour](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Set-Cookie).
- **IETF RFC 6265bis** — *Cookies: HTTP State Management Mechanism (bis)* — [the `__Host-` prefix definition, `SameSite` semantics, and the cookie model the modern browsers actually implement](https://datatracker.ietf.org/doc/draft-ietf-httpbis-rfc6265bis/).
- **Wisp source** — [`set_cookie` in `wisp.gleam`](https://github.com/gleam-wisp/wisp/blob/main/src/wisp.gleam) and [`gleam_http`'s `cookie.defaults`](https://github.com/gleam-lang/http/blob/main/src/gleam/http/cookie.gleam) — verified that Wisp's helper sets `HttpOnly`, `Secure` (off HTTPS), `Path=/`, `SameSite=Lax` and that overriding to `SameSite=Strict` requires dropping to `gleam_http`'s `response.set_cookie`.
- **argus README** — [`argus.hasher()` builder, `argus.hash`, `argus.verify` (Argon2 reference C impl via `jargon` NIF — comparison is constant-time)](https://github.com/Pevensie/argus).
- **`gleam/crypto`** — [`strong_random_bytes` (CSPRNG: OpenSSL `RAND_bytes` on BEAM, WebCrypto on JS) and `secure_compare` (constant-time)](https://hexdocs.pm/gleam_crypto/gleam/crypto.html).


## Leaderboard
Every contribution is invaluable and appreciated.

This ranking
- helps authors check if the metrics are sane at a glance
- uncovers gems unique to the Gleam ecosystem
- cherishes key contributors

Auth is **multi-slot** — there is no single "best auth library." This leaderboard ranks each package against the seven dimensions; treat it as a sanity check on individual libs, not a "pick the top one" recommendation. See [Composing the pieces](#composing-the-pieces--practical-recipes) for stack-level guidance.

**🥇 Gold (per slot)**
- **[argus](#argus)** — password hashing. Most active, OWASP defaults, basis for [glimr_auth](#glimr_auth).
- **[gose](#gose)** — JOSE. Comprehensive, both targets, principled README.
- **[glow_auth](#glow_auth)** — OAuth2 client foundation. Longest-running, most-used.
- **[totally](#totally)** — TOTP. Sole option, well-documented.

| Position | Award | Repo | ★ | Lic | Compat | Maint | Age | README | Idiom | Score |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 🥇 | [okkdev/totally](https://github.com/okkdev/totally) (TOTP) | 🟥 | 🟩 | 🟩 | 🟩🟩 | 🟩 | 🟩🟩 | 🟩 | **8** |
| 1 | 🥇 | [Pevensie/argus](https://github.com/Pevensie/argus) (Argon2) | 🟨 | 🟩 | 🟩 | 🟨 | 🟩 | 🟩🟩 | 🟩 | **7** |
| 3 | 🥇 | [adz/glow_auth](https://github.com/adz/glow_auth) (OAuth2) | 🟨 | 🟩 | 🟥 | 🟩 | 🟩 | 🟩🟩 | 🟩 | **6** |
| 3 | 🥇 | [jtdowney/gose](https://github.com/jtdowney/gose) (JOSE) | 🟥 | 🟩 | 🟩 | 🟩🟩 | 🟨 | 🟩🟩 | 🟩 | **6** |
| 3 |  | [tylerbutler/vestibule](https://github.com/tylerbutler/vestibule) (OAuth2 strategies) | 🟥 | 🟩 | 🟩 | 🟩🟩 | 🟨 | 🟩🟩 | 🟩 | **6** |
| 3 |  | [fweingartshofer/oauth](https://github.com/fweingartshofer/oauth) (flwr_oauth2) | 🟥 | 🟩 | 🟩 | 🟩🟩 | 🟨 | 🟩🟩 | 🟩 | **6** |
| 3 |  | [CrowdHailer/spotless](https://github.com/CrowdHailer/spotless) (broker OAuth) | 🟨 | 🟩 | 🟩 | 🟩🟩 | 🟨 | 🟩🟩 | 🟩 | **7** |
| 8 |  | [brettkolodny/gwt](https://github.com/brettkolodny/gwt) (JWT, HMAC-only) | 🟨 | 🟩 | 🟩 | 🟩 | 🟩 | 🟩 | 🟩 | **6** |
| 8 |  | [CrowdHailer/felix](https://github.com/CrowdHailer/felix) (WebAuthn) | 🟨 | 🟩 | 🟩 | 🟥 | 🟩 | 🟩 | 🟩 | **4** |
| 10 |  | [lpil/antigone](https://github.com/lpil/antigone) (Argon2 / Elixir-NIF) | 🟨 | 🟩 | ⬜ | 🟥 | 🟩 | 🟩 | 🟩 | **3** |
| 10 |  | [lpil/beecrypt](https://github.com/lpil/beecrypt) (bcrypt) | 🟨 | 🟩 | 🟩 | 🟨 | 🟩 | 🟩 | 🟩 | **5** |
| 10 |  | [maxdeviant/aragorn2](https://github.com/maxdeviant/aragorn2) (Argon2 / Rust-NIF) | 🟥 | 🟩 | 🟩 | 🟥 | 🟩 | 🟩🟩 | 🟩 | **4** |
| 10 |  | [iindyverse/wisp_basic_auth](https://github.com/iindyverse/wisp_basic_auth) | 🟥 | 🟩 | 🟩 | 🟩🟩 | 🟩 | 🟩 | 🟩 | **6** |
| 10 |  | [davecaos/twillio_verify](https://github.com/davecaos/twillio_verify) (Twilio Verify) | 🟥 | 🟩 | 🟩 | 🟩🟩 | 🟨 | 🟩🟩 | 🟩 | **6** |
| 10 |  | [CrowdHailer/supa](https://github.com/CrowdHailer/supa) (Supabase auth) | 🟥 | 🟩 | 🟩 | 🟩 | 🟩 | 🟩 | 🟩 | **5** |
| 10 |  | [jtdowney/amaro](https://github.com/jtdowney/amaro) (Fernet/Branca) | 🟥 | 🟩 | 🟩 | 🟩🟩 | 🟨 | 🟩🟩 | 🟩 | **6** |
| 10 |  | [glimr-org/auth](https://github.com/glimr-org/auth) (glimr_auth) | 🟥 | 🟩 | 🟩 | 🟩🟩 | 🟥 | 🟩 | 🟩 | **4** |
| 18 |  | [yazatamorph/pinkdf2](https://github.com/yazatamorph/pinkdf2) (PBKDF2) | 🟥 | 🟩 | 🟩 | 🟩 | 🟩 | 🟩 | 🟩 | **5** |
| 18 |  | [andho/glebs](https://github.com/andho/glebs) (browser PKCE) | 🟥 | 🟩 | 🟩 | 🟨 | 🟩 | 🟩 | 🟩 | **4** |
| 18 |  | [MaxHill/kv_sessions](https://github.com/MaxHill/kv_sessions) (sessions) | 🟥 | ⬜ | ⬜ | 🟨 | 🟩 | 🟩 | 🟩 | **2** |

> [!NOTE]
> Several packages have **age** and **first-commit-date** marked from external metadata; if you maintain one of these libraries and the date is wrong, please open an issue. Scoring uses the seven dimensions in [Scoring Dimensions](#scoring-dimensions). Max possible = 13.

**By target:** ☎️ BEAM **majority** — 17+ repos · 📜 JS **8 repos** (gose, ywt_webcrypto, totally, felix, supa, glebs, spotless, flwr_oauth2 dual). Auth on the BEAM side is markedly more populated than on the JS side.

[How scores are calculated →](#scoring-dimensions)
