# Authentication on the web — a high-level guide

> [!NOTE]
> **Status:** DRAFT · **Authoring:** AI-assisted, human-reviewed.

> *"Who are you, and how do I know?"* — every login form, in nine words.

**Snapshot 2026-04-30** — links to standards, OWASP cheat sheets, and MDN references verified at snapshot. Standards do drift; the version that matters is the one you read on the day you ship.

This is the **conceptual reference** for authentication on the web — what it is, how it works, how to make it secure, and the failure modes that recur every year on OWASP's Top 10. It is intentionally **language-agnostic**. For Gleam-specific package picks (Argon2, JOSE, OAuth2 clients, sessions, TOTP, WebAuthn, etc.), see the sister article: **[Authentication in Gleam](gleam/authentication.md)**.

If you want a one-line summary: *don't roll your own, use HTTPS, hash with Argon2id, set `HttpOnly; Secure; SameSite`, validate every JWT claim, prefer passkeys to passwords, and have a way to revoke a session you wish you hadn't issued.*

## Table of Contents

1. [AuthN vs AuthZ vs identity](#authn-vs-authz-vs-identity)
2. [How auth works on the web](#how-auth-works-on-the-web)
   - [The moving parts](#the-moving-parts)
   - [Paradigm 1 — Cookie-based session auth](#paradigm-1--cookie-based-session-auth)
   - [Paradigm 2 — Token-based stateless auth (JWT, opaque bearer)](#paradigm-2--token-based-stateless-auth-jwt-opaque-bearer)
   - [Paradigm 3 — OAuth 2.0 / OIDC delegation](#paradigm-3--oauth-20--oidc-delegation)
3. [How to make it secure — the practical floor](#how-to-make-it-secure--the-practical-floor)
4. [Common pitfalls](#common-pitfalls)
5. [When to escalate to a service](#when-to-escalate-to-a-service)
6. [Glossary](#glossary)
7. [Further reading](#further-reading)

## AuthN vs AuthZ vs identity

Three words that get used interchangeably and shouldn't be:

| Term | Question it answers | Example |
| --- | --- | --- |
| **Identification** | *"Who do you claim to be?"* | "I'm `alice@example.com`." |
| **Authentication (AuthN)** | *"Can you prove it?"* | A password, a passkey, a one-time code, a signed token. |
| **Authorization (AuthZ)** | *"What are you allowed to do?"* | "Alice can read her own orders, but not Bob's." |

The slogan: **identification claims, authentication proves, authorization gates**. They are independent layers — you can authenticate without authorizing (a logged-in user with no roles), or authorize without authenticating (an anonymous public endpoint). Conflating them is the root cause of a [surprising number of CVEs](recent-incidents-in-major-technologies.md) — *e.g.* CVE-2025-29927 in Next.js, where authorization checks were placed in middleware that could be skipped via a header, and the underlying mistake was treating "the request reached this code" as proof of authentication.

**OAuth 2.0 is an authorization framework, not an authentication protocol.** [RFC 6749](https://datatracker.ietf.org/doc/html/rfc6749) is explicit on this — it concerns *what a token bearer is allowed to access*, not *who they are*. Authentication-by-OAuth is what **OpenID Connect (OIDC)** adds on top: an `id_token` (a signed JWT carrying user identity claims) layered over the OAuth2 grant. If your "Sign in with Google" flow only consumes the access token and never validates the `id_token`, you've authorized an API call but not authenticated a user.

> [!IMPORTANT]
> **OAuth2 alone does not log a user in.** OAuth2 + OIDC's `id_token` does. If you find yourself decoding the access token to extract a user ID, stop — that's an [OIDC](#paradigm-3--oauth-20--oidc-delegation) job and access tokens are not contractually decodable in OAuth2.

## How auth works on the web

### The moving parts

A working web auth flow involves five players, even when some are collapsed into one process:

| Role | What it does |
| --- | --- |
| **User agent** (browser, mobile app) | Holds the session cookie or token, sends it with each request. |
| **Relying Party (RP)** | The application gating its resources. Your app. |
| **Identity Provider (IdP)** | The system holding the user's credentials and issuing proof of authentication. Can be the RP itself (first-party login), or external (Google, Auth0, Keycloak). |
| **Authorization Server (AS)** | Issues access tokens authorizing what the bearer can do. In OAuth2/OIDC, often co-located with the IdP. |
| **Resource Server (RS)** | The API consuming and validating tokens. Often the same process as the RP. |

HTTP is stateless. Each request is independent and the server, by default, has no memory of the last one. **Authentication is the trick of pasting state onto a stateless protocol** — every request after login carries something (a cookie, a token) that says *"I'm the same user from a moment ago, here is the proof."*

The three dominant ways to attach that state:

### Paradigm 1 — Cookie-based session auth

The oldest pattern. The server holds a **session record** keyed by an opaque session ID; the client carries the ID in a cookie. State lives on the server.

```
1. POST /login {user, pass}
2. server validates → creates session row → SET-COOKIE: sid=opaque-random-id;
                                            HttpOnly; Secure; SameSite=Lax
3. GET /dashboard
   Cookie: sid=opaque-random-id
4. server looks up sid → loads session → handles request
5. POST /logout → server deletes session row → cookie becomes useless
```

Properties:
- **Server-side state** — easy revocation (delete the row), easy logout-everywhere, easy "force logout this user."
- **Cookie-bound** — browser handles transport for you. CSRF becomes a concern; [SameSite cookies](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Set-Cookie#samesite) substantially defuse it.
- **Scaling cost** — every request hits the session store. Redis / Postgres / Memcached typically used.
- **Best for** — server-rendered apps with a single-domain UI. The "boring, works, has worked since 1996" answer.

[OWASP's Session Management Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Session_Management_Cheat_Sheet.html) is the canonical reference for getting this right; see [How to make it secure](#how-to-make-it-secure--the-practical-floor).

### Paradigm 2 — Token-based stateless auth (JWT, opaque bearer)

The server signs a token containing the user's identity; the client carries the token; the server validates the signature on each request without looking anything up.

```
1. POST /login {user, pass}
2. server validates → signs JWT with claims {sub, exp, iss, aud, …}
                   → returns { access_token, refresh_token }
3. GET /api/things
   Authorization: Bearer eyJhbGciOiJIUzI1NiIs…
4. server verifies signature, checks exp/iss/aud → handles request
5. access_token expires in 15min → client uses refresh_token to get a new one
```

Properties:
- **Stateless on the read path** — no session store lookup, only signature verification. Scales horizontally; nodes do not share state.
- **Stateful problem on logout** — there is no "delete the row." A signed token is valid until it expires, full stop. Forcing logout means maintaining a **revocation list** (defeats the whole "stateless" pitch) or making access tokens short-lived (15min) and refresh tokens revocable (the standard compromise).
- **JWT pitfalls galore** — see [Common pitfalls](#common-pitfalls). The biggest: **JWT is a signed envelope, not encryption**. The payload is base64url-encoded JSON ([RFC 7519](https://datatracker.ietf.org/doc/html/rfc7519)) — anyone holding the token can read it. Don't put PII or secrets in there.
- **Opaque bearer tokens** — an alternative: random unguessable string, server looks up the corresponding session record. This is functionally cookie-based session auth with a different transport (`Authorization` header instead of `Cookie`). Loses the "stateless" benefit but regains revocation.
- **Best for** — APIs, mobile apps, microservices, anywhere the cookie machinery is unavailable or undesirable.

> [!CAUTION]
> "We use JWT" is not a security architecture. JWT validation is checked claims (`exp`, `iss`, `aud`, `nbf`), pinned algorithms (reject `alg: none` and downgrade to `HS256` when you expected `RS256`), and verified signatures. Pick a library that does these by default — see the [Gleam JOSE picks](gleam/authentication.md#jose--jwt-jws-jwe) for an example of the package landscape.

### Paradigm 3 — OAuth 2.0 / OIDC delegation

Both of the above assume *you* hold the user's credentials. OAuth2 + OIDC says: don't. Delegate to a specialist.

```
RP (your app)               User Agent              IdP (Google/Auth0/Keycloak)
        │                       │                            │
        │ ─ redirect (auth req, PKCE challenge) ─────────────▶│
        │                       │                            │
        │                       │      user logs in          │
        │                       │ ◀──────────────────────────│
        │                       │                            │
        │ ◀── redirect_uri?code=…&state=… ───────────────────│
        │                       │                            │
        │ ─ POST /token (code + PKCE verifier) ──────────────▶│
        │                       │                            │
        │ ◀── { access_token, id_token, refresh_token } ─────│
```

Key terms:
- **Authorization Code grant with PKCE** ([RFC 7636](https://datatracker.ietf.org/doc/html/rfc7636)) — the recommended flow for almost everyone in 2026. PKCE (Proof Key for Code Exchange) makes the flow safe for **public clients** (mobile apps, SPAs) by adding a one-time `code_verifier` only the legitimate client knows. Use it even for confidential clients — it's defence-in-depth.
- **`access_token`** — what your API consumes. Short-lived (5–60 min). Opaque or JWT depending on IdP.
- **`refresh_token`** — long-lived (days/weeks). Lives in confidential storage, used to mint new access tokens. Should be **rotated on use** so a stolen refresh token has a narrow window.
- **`id_token`** (OIDC only) — JWT proving who the user is. **This** is what authenticates the user; the access token authorizes API calls.
- **`state` parameter** — anti-CSRF for the redirect flow. Generate per request, verify on callback. Skipping this is a recurrent CVE pattern.
- **Scopes** — the permissions the access token grants. *"This token can read profile, write calendar, but not delete drive files."*

> [!WARNING]
> **The Implicit grant and Resource Owner Password Credentials grant in [RFC 6749](https://datatracker.ietf.org/doc/html/rfc6749) are deprecated** by [OAuth 2.0 Security BCP](https://datatracker.ietf.org/doc/html/draft-ietf-oauth-security-topics) and [OAuth 2.1](https://datatracker.ietf.org/doc/html/draft-ietf-oauth-v2-1). Use Authorization Code + PKCE. If a tutorial tells you to use Implicit "for SPAs," it's out of date.

## How to make it secure — the practical floor

Twelve practices that should be invariant. None is exotic; missing any is the lazy CVE.

### 1. Hash passwords with a memory-hard, slow algorithm

Per the [OWASP Password Storage Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Password_Storage_Cheat_Sheet.html), in priority order:

1. **Argon2id** (preferred) — minimum config: 19 MiB memory, 2 iterations, 1 lane.
2. **scrypt** (alternative) — N=2¹⁷, r=8, p=1.
3. **bcrypt** — work factor ≥ 10. Caveat: 72-byte input cap.
4. **PBKDF2** (FIPS-compliance only) — 600,000 iterations with HMAC-SHA-256.

> [!WARNING]
> **Never** use SHA-256, MD5, or any unsalted/un-stretched hash for passwords. They are designed to be fast; password hashes need to be slow on purpose. *"We hash with SHA-256 + salt"* is the most common wrong answer in incident reports.

### 2. Use real password hashing libraries — do not roll your own crypto

Bruce Schneier's law: anyone can invent a cipher they themselves cannot break. The libraries linked in the [Gleam authentication article](gleam/authentication.md#password-hashing) wrap reference C / Rust implementations of Argon2 — that's the level you want. Same applies in every language.

### 3. Constant-time comparison for secrets

Comparing a stored hash, MAC, or token with `==` leaks timing information — early-exit string compare lets an attacker brute-force one byte at a time. Every language has a constant-time compare:

| Language | Function |
| --- | --- |
| Python | `hmac.compare_digest` |
| Go | `subtle.ConstantTimeCompare` |
| Node | `crypto.timingSafeEqual` |
| Rust | `subtle::ConstantTimeEq` |
| Erlang/Gleam | `crypto:hash_equals` / package wrappers |

### 4. Always serve over HTTPS, and tell the browser

`Secure` cookies refuse to travel over HTTP. [`Strict-Transport-Security`](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Strict-Transport-Security) tells the browser "always use HTTPS for this domain." Set both. Add the domain to the [HSTS preload list](https://hstspreload.org/) for high-stakes properties.

### 5. Cookie attributes — the invariants

Per [RFC 6265](https://datatracker.ietf.org/doc/html/rfc6265) and [MDN's Set-Cookie reference](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Set-Cookie), session cookies must carry:

- **`HttpOnly`** — JavaScript cannot read it. Defeats most XSS-based session theft.
- **`Secure`** — HTTPS only.
- **`SameSite=Lax`** (default) or **`Strict`** — CSRF defence. Use `Lax` unless you have a specific reason to be stricter.
- **`Max-Age` / `Expires`** — bounded lifetime. "Remember me" cookies should still expire eventually (30–90 days, with re-authentication for sensitive actions).
- **`__Host-` prefix** — for high-stakes session cookies, use `__Host-Session=…` which forces `Secure`, `Path=/`, no `Domain` attribute (host-only).

```
Set-Cookie: __Host-sid=8f2b…; Max-Age=2592000; Path=/; Secure; HttpOnly; SameSite=Lax
```

### 6. Generate session IDs from a CSPRNG, with sufficient entropy

[OWASP](https://cheatsheetseries.owasp.org/cheatsheets/Session_Management_Cheat_Sheet.html) recommends ≥ 64 bits of entropy from a cryptographically secure RNG. In practice, **128+ bits** (16 random bytes hex/base64-encoded) is the modern default. Never derive session IDs from sequence counters, timestamps, or hashes of user data.

### 7. Rotate the session ID on privilege change

After successful login (and after MFA promotion, role change, password reset), generate a *new* session ID and invalidate the old one. This blocks **session fixation** — where an attacker plants a known session ID on a victim's browser before login and reads from it after. CWE-384.

### 8. Generic error messages — don't leak account existence

> ❌ "No account with that email." → "Wrong password." → enumeration attack.
> ✅ "Email or password incorrect." (regardless of which was wrong)
> ✅ "If that email matches an account, we'll send a reset link." (password reset)

Same applies to response timing — verify password against a dummy hash if the user doesn't exist, so the response time doesn't reveal account presence.

### 9. Rate-limit login, password reset, and MFA verification

Per-account (not per-IP, since botnets distribute) and per-IP (since a single account can absorb only so much). Exponential backoff after consecutive failures (1s → 2s → 4s …) is friendlier than hard lockout; CAPTCHA after N failures is friendlier still. Log all failures and alert on bursts.

### 10. Multi-factor authentication

[Microsoft's research](https://www.microsoft.com/en-us/security/blog/2019/08/20/one-simple-action-you-can-take-to-prevent-99-9-percent-of-account-attacks/) puts MFA's blocking rate around 99.9% of automated account-compromise attacks. Per OWASP, with MFA enabled the password-length floor can drop to 8 characters; without MFA, push to 15.

Strength order (best to worst):

| Factor | Strength | Notes |
| --- | --- | --- |
| **Passkey / WebAuthn / FIDO2** | Strongest | Phishing-resistant; private key never leaves device. See [MDN WebAuthn](https://developer.mozilla.org/en-US/docs/Web/API/Web_Authentication_API). |
| **Hardware OTP** (YubiKey OTP, smartcard) | Strong | Physical token. |
| **TOTP** (Authy/Authenticator app, [RFC 6238](https://datatracker.ietf.org/doc/html/rfc6238)) | Good | 6-digit codes refreshed every 30s. Phishable. |
| **Push notification** (Duo, Microsoft Authenticator) | Good-ish | "Number matching" required to defuse MFA-fatigue attacks. |
| **SMS / voice OTP** | Weak | SIM-swap attacks. Better than nothing, worse than anything else listed. |
| **Email OTP** | Weak-but-baseline | Only as strong as the email account. |
| **Knowledge questions** | Don't | "Mother's maiden name" is in your LinkedIn. OWASP says the same. |

### 11. Make every session revocable

If you cannot answer *"how do I log this user out from the server, even if their device is gone?"*, you have a problem. For session-cookie auth: delete the row. For JWT: maintain a revocation list keyed by `jti`, or rotate the signing key (nuclear option). For OAuth refresh tokens: revoke at the IdP via [RFC 7009](https://datatracker.ietf.org/doc/html/rfc7009).

### 12. Don't put secrets in JWTs and validate every claim

JWT bodies are **public** ([RFC 7519](https://datatracker.ietf.org/doc/html/rfc7519)). On every receipt:

- Verify signature with the **expected algorithm**, not the algorithm the token claims (`alg: none` and `alg: HS256`-instead-of-`RS256` are classic confused-deputy attacks).
- Validate `exp` (expiry), `nbf` (not-before), `iss` (issuer matches), `aud` (audience is your app), `iat` (issued-at sane).
- Reject tokens older than your maximum acceptable age regardless of `exp`.

When in doubt, prefer **opaque bearer tokens** with server-side lookup (or [Fernet](https://github.com/fernet/spec)/[Branca](https://github.com/tuupola/branca-spec) for symmetric authenticated encryption). Same author who wrote the comprehensive Gleam JOSE package [recommends Fernet over JWT for greenfield](gleam/authentication.md#token-encryption--fernet--branca) — that advice generalises.

## Common pitfalls

The same handful of mistakes have powered most of the last decade's [authentication CVEs](recent-incidents-in-major-technologies.md). The OWASP top items in [A07:2021 Identification and Authentication Failures](https://owasp.org/Top10/2021/A07_2021-Identification_and_Authentication_Failures/) list them; here they are in concrete form.

### Storing passwords in plaintext, or with a fast hash

PlainText, MD5, SHA-1, SHA-256 — all wrong for password storage. Database leaks become offline cracking parties. Tools like `hashcat` chew unsalted SHA-256 at billions per second on commodity GPUs.

**Fix:** Argon2id. Migrate gradually — verify on login with the old hash, then re-hash and store with Argon2id.

### Comparing secrets with `==`

```py
# ❌ leaks timing — early-exit on first mismatch
if user_provided_token == stored_token: …
# ✅ constant time
if hmac.compare_digest(user_provided_token, stored_token): …
```

### Treating JWT as encryption

```js
// ❌ token contains "is_admin": true. User base64-decodes the payload, edits to false,
//    re-signs… or just notices what's in there.
const claims = { sub: userId, is_admin: true, ssn: "…", api_key: "…" };
// ✅ payload assumes a hostile reader. Sensitive data → server-side session, or JWE-encrypted.
```

The token's *integrity* is signed; its *confidentiality* is not. JWE ([RFC 7516](https://datatracker.ietf.org/doc/html/rfc7516)) provides encryption but is rarely used in practice — most teams who need encrypted tokens reach for opaque session IDs or Fernet/Branca.

### Not validating `aud`, `iss`, `exp`

Without `aud` validation, a JWT issued for service A can be accepted by service B. Without `iss` validation, an attacker who controls *any* JWT issuer your library trusts can mint tokens for your app. Without `exp`, tokens live forever.

### Session IDs in URLs

`https://app.example.com/dashboard?sid=abc123` leaks the session ID via `Referer`, browser history, server logs, copy-paste in chat. Cookies only.

### CSRF when not using SameSite

`SameSite=Lax` (the modern browser default since 2020 in Chrome) blocks most CSRF automatically. If you intentionally need cross-site cookie carriage (`SameSite=None; Secure`), add explicit CSRF tokens — synchroniser tokens or double-submit cookies, per the [OWASP CSRF Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Cross-Site_Request_Forgery_Prevention_Cheat_Sheet.html).

### OAuth2 without PKCE for public clients

Mobile app or SPA flows using bare Authorization Code (without PKCE) can be intercepted via a registered URI scheme (mobile) or page navigation timing (browser). PKCE eliminates this. Per [RFC 7636](https://datatracker.ietf.org/doc/html/rfc7636) and the OAuth 2.0 Security BCP, **always use PKCE for public clients**.

### Skipping the `state` parameter on the OAuth redirect

Without `state`, an attacker can stuff an authorization code from their own session into your callback URL, causing your app to bind their account to your victim's session. Always generate `state` per request and verify on callback.

### Auth-via-localStorage for tokens

Tokens stored in `localStorage` are accessible by every script that runs on the page — and one XSS ([reflected, stored, or DOM-based](https://owasp.org/www-community/attacks/xss/)) exfils them. `HttpOnly` cookies are JavaScript-invisible. For SPAs that *must* call cross-origin APIs, the [BFF pattern](https://datatracker.ietf.org/doc/html/draft-ietf-oauth-browser-based-apps) (proxy through your own backend, which holds the tokens server-side) is the current recommendation.

### "Remember me" cookies that never expire

A device-bound session cookie with no expiry is a permanent credential. Cap at 30–90 days; require a fresh password (or step-up MFA) for sensitive operations regardless of remember-me state.

### Confused-deputy in OAuth scopes

Apps that request scopes far broader than they need (`drive.readwrite` when they only need `drive.file`) become tempting compromise targets. Request the minimum, document why each scope is needed, re-request on access (not at first install). The 2025 [GitHub OAuth app review patterns](https://github.blog/security/) reflect this.

### HTTPS → HTTP downgrade

If your login form is reachable over HTTP, an attacker on the path can MitM the credentials before HSTS engages. Redirect HTTP→HTTPS at the edge, set HSTS with `includeSubDomains; preload`, and submit the domain to the [browser preload list](https://hstspreload.org/).

### Trusting "internal" headers from the network

[CVE-2025-29927 in Next.js](recent-incidents-in-major-technologies.md#nextjs) is the textbook example: a header (`x-middleware-subrequest`) meant for internal use, when sent from the network, was honoured. Ingress/proxy must strip any internal-only header before traffic enters your app, and your app should never trust a header *as proof of internal-source* unless it is signed.

### Auth-by-IP-allowlist as the only check

Internal services on a "trusted" network often skip auth entirely. The first compromised internal host turns the entire network into one big attacker. **Zero-trust** is the modern correction: every service authenticates every request, regardless of source.

## When to escalate to a service

Self-hosting authentication is a category of work, not a feature. The honest signal that you should outsource:

- **You're a 1–10 person team** building a non-auth product. Auth is a side-quest that bleeds engineering hours indefinitely (rotation, password resets, magic links, MFA enrolment, account recovery, audit logs, GDPR delete flows, abuse handling, support tickets…).
- **You need SSO/SAML** for enterprise customers. The bid is "enterprise-ready in two weeks" and writing a SAML provider from scratch is months. SCIM provisioning is another months-long project.
- **You need compliance** (SOC2, ISO27001, HIPAA). Inheriting controls from a SOC2-certified IdP is faster than building yours.
- **You need fraud / abuse / bot detection** at scale. Specialists invest in this; you can't.

Options span a spectrum:

| Tier | Examples | Trade-off |
| --- | --- | --- |
| **Hosted IDaaS** | Auth0, Clerk, Stytch, WorkOS, Frontegg, Descope | Fastest. Vendor lock-in. Per-MAU pricing scales with success. |
| **Hosted backend with auth** | Supabase, Firebase Auth, AWS Cognito | Auth bundled with broader BaaS. Cheaper at scale; coupling to the platform. |
| **Self-hosted IdP** | [Keycloak](https://www.keycloak.org/), [Authentik](https://goauthentik.io/), [Ory Kratos+Hydra](https://www.ory.sh/), [Zitadel](https://zitadel.com/) | You run the database. Full control, no MAU bill, but you operate it. |
| **Library-level** | Hand-assembled (per-language packages) | Maximum flexibility, maximum responsibility. The default for very small or very specialised apps. |

A reasonable rule: **start with a hosted IdP if any of "we sell to enterprises", "we'll add SSO", or "compliance is on the roadmap" is true.** Migrating *off* a hosted IdP later is annoying but tractable; building one yourself at month six because the requirements ballooned is much worse.

For ecosystem-specific notes on what's available in Gleam (and what isn't, including the still-empty SAML / LDAP / native OIDC-server slot), see [Authentication in Gleam](gleam/authentication.md#whats-missing).

## Glossary

A short reference for the acronym soup.

| Term | Meaning |
| --- | --- |
| **AuthN** | Authentication — proving who you are. |
| **AuthZ** | Authorization — what you're allowed to do. |
| **IdP** | Identity Provider — the system that holds credentials and asserts identity (Google, Okta, Keycloak, your own login service). |
| **RP** | Relying Party — the app consuming an IdP's identity assertion. *Your app*, in delegated flows. |
| **AS** | Authorization Server — issues access tokens. Often co-located with the IdP in OAuth2/OIDC. |
| **RS** | Resource Server — the API consuming and validating tokens. |
| **SSO** | Single Sign-On — log in once with the IdP, access many RPs without re-authenticating. |
| **MFA / 2FA** | Multi-Factor / Two-Factor Authentication — combining "something you know" + "something you have" + "something you are". |
| **OIDC** | OpenID Connect — authentication layer on top of OAuth2. Adds the `id_token`. |
| **OAuth2** | Authorization framework ([RFC 6749](https://datatracker.ietf.org/doc/html/rfc6749)). Delegates *access* to a token-bearer. |
| **SAML** | Security Assertion Markup Language — XML-based federated SSO, dominant in enterprise. Older than OIDC, still common in B2B. |
| **PKCE** | Proof Key for Code Exchange ([RFC 7636](https://datatracker.ietf.org/doc/html/rfc7636)) — extension making OAuth2 Authorization Code safe for public clients. Pronounce "pixie". |
| **JOSE** | JavaScript Object Signing and Encryption — the umbrella for JWT / JWS / JWE / JWK. |
| **JWT** | JSON Web Token ([RFC 7519](https://datatracker.ietf.org/doc/html/rfc7519)). Signed (or encrypted) JSON envelope. Pronounce "jot". |
| **JWS** | JSON Web Signature ([RFC 7515](https://datatracker.ietf.org/doc/html/rfc7515)) — the signed-but-readable form of a JWT. |
| **JWE** | JSON Web Encryption ([RFC 7516](https://datatracker.ietf.org/doc/html/rfc7516)) — the encrypted form. Rarely used in practice. |
| **JWK** | JSON Web Key — JSON-encoded public/private keys. Identity providers publish their public keys via a `jwks_uri`. |
| **HOTP** | HMAC-based One-Time Password ([RFC 4226](https://datatracker.ietf.org/doc/html/rfc4226)) — counter-based OTP. Largely superseded by TOTP. |
| **TOTP** | Time-based One-Time Password ([RFC 6238](https://datatracker.ietf.org/doc/html/rfc6238)) — what Google Authenticator / Authy / 1Password generate. |
| **FIDO2** | Industry-standard authentication framework. Combines [WebAuthn](https://www.w3.org/TR/webauthn-2/) (browser API) + CTAP (authenticator protocol). |
| **WebAuthn** | [Web Authentication API](https://developer.mozilla.org/en-US/docs/Web/API/Web_Authentication_API) — browser-side passkey API. |
| **Passkey** | A discoverable, syncable WebAuthn credential — increasingly the replacement for passwords. |
| **CSPRNG** | Cryptographically Secure Pseudo-Random Number Generator. Use this to generate session IDs, tokens, salts. |
| **CSRF** | Cross-Site Request Forgery — a malicious site triggers actions on a target site using the victim's authenticated cookies. Defused by `SameSite` and CSRF tokens. |
| **XSS** | Cross-Site Scripting — script injection. Defused by output encoding, `Content-Security-Policy`, and `HttpOnly` cookies. |
| **HSTS** | HTTP Strict Transport Security — header telling the browser "always HTTPS for this domain." |

A note on hardware tokens, scope decision: this article covers them under MFA but does not deep-dive YubiKey / smartcard provisioning; that's its own corpus. The MDN [WebAuthn page](https://developer.mozilla.org/en-US/docs/Web/API/Web_Authentication_API) is the right next read.

## Further reading

Standards bodies and OWASP cheat sheets, all verified at snapshot.

**OWASP**

- [Authentication Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Authentication_Cheat_Sheet.html) — the canonical "what to do" list.
- [Session Management Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Session_Management_Cheat_Sheet.html) — cookie attributes, ID entropy, expiry, fixation.
- [Password Storage Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Password_Storage_Cheat_Sheet.html) — Argon2id parameters, scrypt/bcrypt/PBKDF2 settings.
- [Cross-Site Request Forgery Prevention Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Cross-Site_Request_Forgery_Prevention_Cheat_Sheet.html).
- [OWASP Top 10:2021 — A07 Identification and Authentication Failures](https://owasp.org/Top10/2021/A07_2021-Identification_and_Authentication_Failures/).
- [OWASP Top 10:2025 — A07 Authentication Failures](https://owasp.org/Top10/2025/A07_2025-Authentication_Failures/) (latest revision).

**IETF RFCs**

- [RFC 6265 — HTTP State Management Mechanism (Cookies)](https://datatracker.ietf.org/doc/html/rfc6265).
- [RFC 6749 — The OAuth 2.0 Authorization Framework](https://datatracker.ietf.org/doc/html/rfc6749).
- [RFC 7009 — OAuth 2.0 Token Revocation](https://datatracker.ietf.org/doc/html/rfc7009).
- [RFC 7515 — JSON Web Signature (JWS)](https://datatracker.ietf.org/doc/html/rfc7515).
- [RFC 7516 — JSON Web Encryption (JWE)](https://datatracker.ietf.org/doc/html/rfc7516).
- [RFC 7519 — JSON Web Token (JWT)](https://datatracker.ietf.org/doc/html/rfc7519).
- [RFC 7636 — Proof Key for Code Exchange (PKCE)](https://datatracker.ietf.org/doc/html/rfc7636).
- [RFC 6238 — TOTP: Time-Based One-Time Password](https://datatracker.ietf.org/doc/html/rfc6238).
- [RFC 4226 — HOTP: HMAC-Based One-Time Password](https://datatracker.ietf.org/doc/html/rfc4226).
- [OAuth 2.0 Security Best Current Practice (draft)](https://datatracker.ietf.org/doc/html/draft-ietf-oauth-security-topics).
- [OAuth 2.1 (draft)](https://datatracker.ietf.org/doc/html/draft-ietf-oauth-v2-1).

**MDN**

- [Authentication — MDN](https://developer.mozilla.org/en-US/docs/Web/Security/Authentication).
- [`Set-Cookie` — MDN](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Set-Cookie).
- [`Strict-Transport-Security` — MDN](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Strict-Transport-Security).
- [Web Authentication API — MDN](https://developer.mozilla.org/en-US/docs/Web/API/Web_Authentication_API).
- [Passkeys — MDN](https://developer.mozilla.org/en-US/docs/Web/Security/Authentication/Passkeys).

**W3C**

- [Web Authentication: An API for accessing Public Key Credentials Level 2](https://www.w3.org/TR/webauthn-2/) — the WebAuthn spec proper.

**FIDO Alliance**

- [Passkeys overview](https://fidoalliance.org/passkeys/) — the consumer-facing FIDO2 narrative.

**Cross-references in this repo**

- [Authentication in Gleam](gleam/authentication.md) — Gleam-specific implementation review (Argon2 / JOSE / OAuth2 / TOTP / WebAuthn / IDaaS clients).
- [Recent security incidents in major technologies](recent-incidents-in-major-technologies.md) — concrete CVEs across Next.js, WordPress, npm, PyPI, etc., many of them authentication or session-management failures.
- [Navigating software ecosystems](navigating-ecosystems.md) — meta-review of how to evaluate libraries (relevant when picking an auth library).
