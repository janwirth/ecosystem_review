# Sending email from Gleam

> [!NOTE]
> **Status:** DRAFT · **Authoring:** AI-assisted, human-reviewed.

So you want to ship a "Welcome", a password reset, or a receipt — written in Gleam?

Don't reach for IMAP and a custom MIME parser yet. The Gleam side of email is small, and almost all of it is **outbound only**: SMTP clients and thin wrappers around transactional email vendor APIs.

This article surveys what exists, what's idiomatic, and what to avoid.

## Table of Contents

1. [Summary](#summary)
2. [State of the ecosystem](#state-of-the-ecosystem)
3. [Research Method](#research-method)
   - [Scoring Dimensions](#scoring-dimensions)
   - [Discovery](#discovery)
4. [Categories](#categories)
   - [SMTP clients](#smtp-clients) — [lumenmail](#lumenmail) · [gcourier](#gcourier)
   - [Transactional email APIs](#transactional-email-apis) — [sendgriddle](#sendgriddle) · [zeptomail](#zeptomail) · [plunk](#plunk) · [gleesend](#gleesend)
   - [HTML email composition](#html-email-composition) — [smail](#smail)
   - [Inbound, IMAP, POP3, parsing](#inbound-imap-pop3-parsing)
5. [SMTP vs transactional API — which to pick](#smtp-vs-transactional-api--which-to-pick)
6. [Leaderboard](#leaderboard)

## Summary

Snapshot: **2026-04-26**.

| Category | ☎️ BEAM | 📜 JS |
| --- | --- | --- |
| **[SMTP clients](#smtp-clients)** | · [lumenmail](#lumenmail) ([repo](https://github.com/davecaos/lumenmail), 2★) — *full SMTP: TLS/STARTTLS, PLAIN/LOGIN/CRAM-MD5/XOAUTH2, attachments, RFC 5322*<br>· [gcourier](#gcourier) ([repo](https://github.com/gideongrinberg/gcourier), 16★) — *SMTP send + bundled mailpit dev server; SES/Gmail provider docs* | — |
| **[Transactional email APIs](#transactional-email-apis)** | · [🥇](#leaderboard) [sendgriddle](#sendgriddle) ([repo](https://github.com/lpil/gleam_sendgrid), 15★) — *SendGrid; bring-your-own HTTP client*<br>· [zeptomail](#zeptomail) ([repo](https://github.com/lpil/zeptomail), 7★) — *ZeptoMail; bring-your-own HTTP client*<br>· [plunk](#plunk) ([repo](https://github.com/aosasona/plunk.gleam), 12★) — *Plunk; events + transactional + contacts*<br>· [gleesend](#gleesend) ([repo](https://github.com/dinkelspiel/gleesend), 1★) — *Resend* | · [sendgriddle](#sendgriddle) — *also targets JS*<br>· [zeptomail](#zeptomail) — *also targets JS*<br>· [plunk](#plunk) — *also targets JS*<br>· [gleesend](#gleesend) — *also targets JS* |
| **[HTML email composition](#html-email-composition)** | · [smail](#smail) ([repo](https://github.com/gungun974/smail), 8★) — *Lustre-style typed builder for HTML emails (renders to HTML + plain text)* | · [smail](#smail) — *also targets JS* |
| **Inbound (IMAP / POP3 / parsing)** | — | — |

> [!NOTE]
> Outbound only. There is no Gleam-native IMAP, POP3, or MIME parser. If you need those, see the [inbound section](#inbound-imap-pop3-parsing) — you'll have to drop down to Erlang/Elixir libraries.

## State of the ecosystem

Email tooling in Gleam is **early but functional for the common case** — sending transactional mail.

What's there:
- Two SMTP clients (one full-featured, one bundled with a dev server).
- Wrappers for four transactional email vendors (SendGrid, ZeptoMail, Plunk, Resend).
- One Lustre-style HTML email builder.

What's missing entirely:
- IMAP, POP3, JMAP clients.
- MIME parsing libraries (no native way to read an `.eml` file in Gleam).
- Mailbox-format readers (mbox, Maildir).
- DKIM/DMARC/SPF helpers.
- Mailgun, Postmark, AWS SES, Brevo, Mailtrap-specific SDKs (you can hit SES through gcourier's docs, but as raw SMTP).

Star counts are tiny across the board (largest = 16★). Several packages have 1–2★. Use the established tools as **thin, replaceable layers** — they're a few hundred lines each, and you can fork or replace them quickly if needed.

## Research Method

### Scoring Dimensions

- **Stars:** Community adoption signal based on star count. 🟩🟩 = ≥200★, 🟩 = ≥100★, 🟨 = ≥10★, 🟥 = <10★. *Example: 16★ → 🟨; 2★ → 🟥.*
- **License:** Whether the license allows unrestricted commercial use. 🟩 = permissive OSS (MIT, Apache-2.0, BSD). 🟥 = viral (GPL, AGPL) or no license. Only one tier — permissive or not.
- **Gleam compat:** Checks `gleam_stdlib` version constraint format in `gleam.toml` `[dependencies]`. 🟩 = range constraint (`>= X and < Y`), 🟥 = non-range constraint (`~>` style) which can cause resolver conflicts during install. *Example: `"~> 0.34 or ~> 1.0"` → 🟥; `">= 0.44.0 and < 2.0.0"` → 🟩.*
- **Maintenance:** Two-level scoring that prioritizes proactive development. Final score = **max(recency, responsiveness)**. **Level 1 — Recency:** last commit relative to snapshot. 🟩🟩 = <1 month, 🟩 = <6 months, 🟨 = <1 year, 🟥 = >1 year. **Level 2 — Responsiveness:** time for repo owner to reply to issues or update PRs (owner comment = ball in opener's court, counts as handled). 🟩🟩 = <2 days, 🟩 = <1 week, 🟨 = <1 month, 🟥 = >1 month or ignored. Clean tracker (0 open PRs/issues) = 🟩🟩. The better of the two wins.
- **Age:** Time from first visible commit to snapshot date. Older projects have more time to stabilize. 🟩🟩 = ≥3 years, 🟩 = ≥1 year, 🟨 = ≥3 months, 🟥 = <3 months. *Example: history starts Apr 2026, snapshot Apr 2026 → ~6 days → 🟥.*
- **README maturity:** Quality of documentation in the repo README. 🟩🟩 = guide-style with examples, full feature docs, and getting-started instructions. 🟩 = clear description and basic usage. 🟥 = minimal, broken, or missing.
- **Idiomaticity:** Whether the project follows Gleam's principles: typed, sound, explicit, no magic. 🟩 = idiomatic (explicit APIs, builder patterns). 🟥 = magic directives, implicit behavior.

**Leaderboard scoring:** 🟥 = −1, 🟨 = 0, 🟩 = 1, 🟩🟩 = 2. Sum of all 7 dimensions. Max possible = 13.

### Discovery

11 distinct repos found via [Gleam packages registry](https://packages.gleam.run/) searches — **7 included** (see [Categories](#categories)), **4 disregarded** (below).

- [mail](https://packages.gleam.run/?search=mail)
- [email](https://packages.gleam.run/?search=email)
- [smtp](https://packages.gleam.run/?search=smtp)
- [imap](https://packages.gleam.run/?search=imap) — *no results*
- [pop3](https://packages.gleam.run/?search=pop3) — *no results*
- [mailgun](https://packages.gleam.run/?search=mailgun) — *no results*
- [sendgrid](https://packages.gleam.run/?search=sendgrid)
- [postmark](https://packages.gleam.run/?search=postmark) — *no results*
- [ses](https://packages.gleam.run/?search=ses) — *no results*
- [resend](https://packages.gleam.run/?search=resend)
- [plunk](https://packages.gleam.run/?search=plunk)
- [zeptomail](https://packages.gleam.run/?search=zeptomail)
- [brevo](https://packages.gleam.run/?search=brevo) — *no results*
- [mailtrap](https://packages.gleam.run/?search=mailtrap) — *no results*
- [mailbox](https://packages.gleam.run/?search=mailbox) — *no results*
- [mailer](https://packages.gleam.run/?search=mailer) — *no results*
- [courier](https://packages.gleam.run/?search=courier) — *suggested gcourier*
- [mime](https://packages.gleam.run/?search=mime) — *only content-type lookup tools, not email MIME parsers*

> <details>
> <summary>4 disregarded — abandoned, incomplete, or out of scope</summary>
>
> **Abandoned / incomplete:**
> - **[andre-dasilva/gsmtp](https://github.com/andre-dasilva/gsmtp)** — SMTP client. 2★, 16 commits, MIT (declared in gleam.toml; no LICENSE file). Last commit 2025-01-05 (~16 months dormant at snapshot). README's own "TODO" list states **TLS, tests, error handling, better docs, API cleanup** are all unimplemented. Maintenance 🟥. Use lumenmail instead.
>
> **Out of scope:**
> - **[brittonhayes/defangle](https://github.com/brittonhayes/defangle)** — "Defang URLs, Emails, and IP addresses making them safe to share." 3★, last commit 2024-03-19 (~2 years dormant). Security/IR utility, not an email-sending or parsing library.
> - **[lpil/marceau](https://github.com/lpil/marceau)** — MIME *types* (Content-Type lookup by extension). Not an email-MIME parser/composer.
> - **[nao1215/mimetype](https://github.com/nao1215/mimetype)** — MIME type lookup + magic-number detection. Same: not for email.
>
> </details>

## Categories

### SMTP clients

Talk SMTP directly to a mail server (your own, an ISP relay, Postfix, mailpit, smtp4dev, etc.). The "no vendor lock-in" path.

| Criterion | [lumenmail](https://github.com/davecaos/lumenmail) | [gcourier](https://github.com/gideongrinberg/gcourier) |
| --- | --- | --- |
| Stars | 2★ · 🟥 | 16★ · 🟨 |
| License | Apache-2.0 OR MIT (gleam.toml) · 🟩 | MIT · 🟩 |
| Target | ☎️ BEAM | ☎️ BEAM |
| Deps | 2 | 8 |
| Gleam compat | `>= 0.62 and < 1.0` · 🟩 | `>= 0.59 and < 1.0` · 🟩 |
| Maintenance | 🟩🟩 (last commit 2026-03-13, 0 open issues) | 🟩🟩 (last commit 2026-04-19, 8 open issues) |
| Age | ~4 months (Dec 2025) · 🟨 | ~12 months (May 2025) · 🟩 |
| README maturity | 🟩🟩 (full guide: features, quickstart, multiple examples, full API tables) | 🟩🟩 (quickstart + dedicated provider pages for SES & Gmail) |
| Idiomaticity | 🟩 (builder pattern, explicit pipelines) | 🟩 (builder pattern, explicit pipelines) |
| | | |
| **Features** | | |
| Implicit TLS (port 465) | ✅ | ✅ |
| STARTTLS | ✅ | ✅ |
| Auth: PLAIN | ✅ | ✅ |
| Auth: LOGIN | ✅ | ⬜ (not documented) |
| Auth: CRAM-MD5 | ✅ | ⬜ (not documented) |
| Auth: XOAUTH2 | ✅ | ⬜ (not documented) |
| HTML + plain text | ✅ | ✅ |
| Attachments | ✅ | ✅ (since v1.2.0, May 2025) |
| Inline images | ✅ | ⬜ |
| Custom headers | ✅ | ⬜ |
| Connection reuse | ✅ (`smtp.reset` + persistent client) | — (single send) |
| Bundled dev server | — | ✅ (`gcourier.dev_server` starts mailpit on `:1025` / web UI on `:8025`) |

#### lumenmail
[repo](https://github.com/davecaos/lumenmail) · [hexdocs](https://hexdocs.pm/lumenmail/)

A full-featured SMTP client modeled on the Rust [`mail-send`](https://docs.rs/mail-send/latest/mail_send/) crate. Direct SMTP with TLS/STARTTLS, four auth mechanisms (PLAIN, LOGIN, CRAM-MD5, XOAUTH2), HTML + plain text bodies, file attachments, inline images, custom headers, email threading (`In-Reply-To` / `References`), RFC 5322 formatting, and connection reuse for batch sending.

Two-dependency footprint (`gleam_stdlib`, `gleam_crypto`). Erlang target only. 0 open issues.

```gleam
import lumenmail/message
import lumenmail/smtp

pub fn main() {
  let email =
    message.new()
    |> message.from_name_email("John Doe", "john@example.com")
    |> message.to_email("recipient@example.com")
    |> message.subject("Hello from Gleam!")
    |> message.text_body("This is a test email sent with lumenmail.")

  let assert Ok(client) =
    smtp.builder("smtp.example.com", 587)
    |> smtp.auth("username", "password")
    |> smtp.connect()

  let assert Ok(_) = smtp.send(client, email)
  let assert Ok(_) = smtp.close(client)
}
```

#### gcourier
[repo](https://github.com/gideongrinberg/gcourier) · [hexdocs](https://hexdocs.pm/gcourier/)

"A simple and easy-to-use interface for sending emails from Gleam." SMTP send with the standard builder pattern. The headline trick: **`gcourier.dev_server()` starts a bundled [mailpit](https://github.com/axllent/mailpit) instance** that captures messages and serves a web UI on `localhost:8025`, so you can test send paths without a real mail server. Erlang target only.

8 open issues — the most active issue tracker among the email packages — including feature requests, follow-ups on attachments, and provider integrations. The hexdocs ship with [provider guides for Amazon SES](https://hexdocs.pm/gcourier/providers/ses.html) and [Gmail](https://hexdocs.pm/gcourier/providers/gmail.html), both via SMTP.

```gleam
import gcourier
import gcourier/message
import gcourier/smtp
import gleam/erlang/process
import gleam/option.{Some}

pub fn main() {
  gcourier.dev_server()  // starts mailpit; visit http://localhost:8025
  let m =
    message.build()
    |> message.set_from("party@funclub.org", Some("The Fun Club"))
    |> message.add_recipient("jane.doe@example.com", message.To)
    |> message.add_recipient("john.doe@example.net", message.CC)
    |> message.set_subject("You're Invited: Pizza & Ping Pong Night!")
    |> message.set_html("<h1>You're Invited!</h1><p>Friday at 7 PM.</p>")

  smtp.send("localhost", 1025, Some(#("user1", "password1")), m)
  process.sleep_forever()
}
```


### Transactional email APIs

HTTP wrappers around vendor APIs. Same shape across all four: build a typed `Email` record, get back an `http.Request`, send it with whatever HTTP client you like (`gleam_httpc`, `gleam_hackney`, `fetch` on JS).

| Criterion | [sendgriddle](https://github.com/lpil/gleam_sendgrid) [🥇](#leaderboard) | [zeptomail](https://github.com/lpil/zeptomail) | [plunk](https://github.com/aosasona/plunk.gleam) | [gleesend](https://github.com/dinkelspiel/gleesend) |
| --- | --- | --- | --- | --- |
| Vendor | SendGrid | ZeptoMail (Zoho) | Plunk | Resend |
| Stars | 15★ · 🟨 | 7★ · 🟥 | 12★ · 🟨 | 1★ · 🟥 |
| License | Apache-2.0 · 🟩 | Apache-2.0 · 🟩 | MIT · 🟩 | MIT · 🟩 |
| Target | ☎️📜 Both | ☎️📜 Both | ☎️📜 Both | ☎️📜 Both |
| Deps | 3 | 3 | 3 | 3 |
| Gleam compat | `>= 0.62 and < 2.0` · 🟩 | `>= 0.39 and < 2.0` · 🟩 | `>= 0.60 and < 1.0` · 🟩 | `>= 0.34 and < 2.0` · 🟩 |
| Maintenance | 🟩🟩 (last commit 2026-04-19, 0 open issues) | 🟩🟩 (last commit 2025-12-28, 0 open issues) | 🟨 (last commit 2025-06-04; 1 open issue, no maintainer reply ~6 weeks) | 🟩🟩 (last commit 2025-06-25, 0 open issues) |
| Age | ~4.2 years (Feb 2022) · 🟩🟩 | ~3.8 years (Jun 2022) · 🟩🟩 | ~2.5 years (Oct 2023) · 🟩 | ~1.7 years (Aug 2024) · 🟩 |
| README maturity | 🟩 (tagline + working quickstart) | 🟩 (tagline + working quickstart) | 🟩 (clear quickstart + module list) | 🟩 (clear quickstart) |
| Idiomaticity | 🟩 (explicit `Email` record, `mail_send_request` returns `http.Request`) | 🟩 (explicit `Email` record, `email_request` returns `http.Request`) | 🟩 (typed events, builder, but bundles its own send via `hackney.send`) | 🟩 (builder + `to_request` / `to_response`) |
| | | | | |
| **Features** | | | | |
| Plain text body | ✅ | ✅ | ✅ | ✅ |
| HTML body | ✅ | ✅ | ✅ | ✅ |
| Multiple recipients | ✅ | ✅ | ✅ | ✅ |
| CC / BCC | ⬜ | ✅ | ⬜ | ⬜ |
| Reply-To | ⬜ | ✅ | ⬜ | ⬜ |
| Attachments | ⬜ | ⬜ | ⬜ | ⬜ |
| Templates / variables | ⬜ | ⬜ | ⬜ | ⬜ |
| Event tracking (analytics) | — | — | ✅ (Plunk events) | — |
| Contacts API | — | — | ✅ | — |

> [!NOTE]
> "⬜" means **not surfaced in the typed Gleam API** at snapshot. Some of these features may be reachable by hand-rolling the JSON body, but they're not first-class in the wrapper.

#### sendgriddle
[repo](https://github.com/lpil/gleam_sendgrid) · [🥇](#leaderboard) · [hexdocs](https://hexdocs.pm/sendgriddle/)

"Send emails from Gleam with SendGrid." Authored by [Louis Pilfold](https://github.com/lpil) (Gleam's creator). Tiny, focused: build an `Email`, get a `http.Request`, send with any HTTP client. Latest release v1.1.0 on 2026-04-19. 0 open issues. Both targets.

```gleam
import sendgriddle
import gleam/httpc

pub fn main() {
  let email =
    sendgriddle.Email(
      to: ["joe@example.com"],
      sender_email: "mike@example.com",
      sender_name: "Mike",
      subject: "Hello, Joe!",
      content: sendgriddle.TextContent("System still working?"),
    )

  let request = sendgriddle.mail_send_request(email, api_key: "...")
  let assert Ok(response) = httpc.send(request)
  assert sendgriddle.mail_send_response(response) == Ok(Nil)
}
```

#### zeptomail
[repo](https://github.com/lpil/zeptomail) · [hexdocs](https://hexdocs.pm/zeptomail/)

Same author and shape as sendgriddle, targeting [Zoho's ZeptoMail](https://www.zoho.com/zeptomail/). Slightly richer surface: explicit `cc`, `bcc`, `reply_to` fields on the `Email` record. 0 open issues. v2.1.0 released 2025-12-28. Both targets.

```gleam
import gleam/httpc
import zeptomail.{Addressee}

pub fn main() {
  let email = zeptomail.Email(
    from: Addressee("Mike", "mike@example.com"),
    to: [Addressee("Joe", "joe@example.com")],
    reply_to: [],
    cc: [Addressee("Robert", "robert@example.com")],
    bcc: [],
    body: zeptomail.TextBody("Hello, Mike!"),
    subject: "Hello, Joe!",
  )

  let request = zeptomail.email_request(email, key: "...")
  let assert Ok(response) = httpc.send(request)
  let assert Ok(_) = zeptomail.decode_email_response(response)
}
```

#### plunk
[repo](https://github.com/aosasona/plunk.gleam) · [hexdocs](https://hexdocs.pm/plunk/)

The broadest API surface in this category — wraps not just transactional sending but also Plunk's **events** (analytics) and **contacts** APIs. Modules: `plunk.transactional`, `plunk.event`, `plunk.contacts`, `plunk.instance`, `plunk.types`.

The catch: 1 open issue ([#17, 2026-03-16](https://github.com/aosasona/plunk.gleam/issues/17), no maintainer reply at snapshot) reports that **the transactional email module points at Plunk's old API host and fails**. Last commit 2025-06-04 (~10.5 months idle). Use the events/contacts modules with confidence; verify the transactional path before depending on it.

```gleam
import gleam/erlang/os
import gleam/json
import gleam/result
import gleam/hackney
import plunk
import plunk/event.{Event}

pub fn main() {
  let key = os.get_env("PLUNK_API_KEY") |> result.unwrap("")
  let assert Ok(resp) =
    plunk.new(key)
    |> event.track(Event(
      event: "your-event",
      email: "someone@example.com",
      data: [#("name", json.string("John"))],
    ))
    |> hackney.send
}
```

#### gleesend
[repo](https://github.com/dinkelspiel/gleesend) · [hexdocs](https://hexdocs.pm/gleesend/)

"A resend library for the Gleam programming language." Smallest of the four (1★, 20 commits). Builder pattern: `create_email(...) |> with_html(...) |> to_request()`. 0 open issues. Last commit 2025-06-25 (~10 months ago) — quiet but the API hasn't broken.

```gleam
import gleesend.{Resend}
import gleesend/emails.{
  create_email, to_response, to_request, with_html, BadRequestError,
}
import gleam/hackney
import gleam/result.{try}

pub fn main() {
  let client = Resend(api_key: "...")
  let request =
    create_email(
      client:,
      from: "from@example.com",
      to: ["to@example.com"],
      subject: ":)",
    )
    |> with_html("<p>Successful response</p>")
    |> to_request()

  use response <- try(
    hackney.send(request) |> result.replace_error(BadRequestError),
  )
  let _ = emails.to_response(response.body, response.status)
}
```


### HTML email composition

Building cross-client HTML email is famously a tar pit (table layouts, inlined CSS, restricted selectors). Lustre's typed `html` API is ergonomic but uses elements/CSS that most email clients reject. This category is the email-safe analogue.

| Criterion | [smail](https://github.com/gungun974/smail) |
| --- | --- |
| Stars | 8★ · 🟥 |
| License | Apache-2.0 · 🟩 |
| Target | ☎️📜 Both (BEAM + JS) |
| Deps | 2 (`gleam_stdlib`, `houdini` for HTML escaping) |
| Gleam compat | `>= 0.44 and < 2.0` · 🟩 |
| Maintenance | 🟩🟩 (last commit 2026-04-23, 0 open issues) |
| Age | ~6 days (Apr 2026) · 🟥 |
| README maturity | 🟩🟩 (substantial example showing the full builder + visual styling) |
| Idiomaticity | 🟩 (typed builder, explicit attribute and style modules) |

#### smail
[repo](https://github.com/gungun974/smail) · [hexdocs](https://hexdocs.pm/smail/)

> **Note on naming:** previously published as `lustremail`; renamed to **`smail`** in v2.0.0 (April 2026). Hex still surfaces the old name in package search; the GitHub repo and current package are at `gungun974/smail` and `hex.pm/packages/smail`.

"Write HTML compliant email with peace of mind like Lustre." A typed builder for email-safe HTML — produces both `to_html` and `to_plain_text` outputs from the same value. Modules: `smail/email`, `smail/html`, `smail/attribute`, `smail/style`. Pairs naturally with any of the SMTP clients or transactional API wrappers above (build with smail, hand the rendered HTML to lumenmail/sendgriddle/etc.).

Brand new (~6 days old at snapshot, v2.0.0 published 2026-04-23). 0 open issues, very active. Both targets.

```gleam
import gleam/option.{Some}
import smail/attribute
import smail/email
import smail/html
import smail/style

pub fn main() {
  let mail =
    email.html([attribute.lang("en")], [
      email.head([], [
        email.font(
          family: "Josefin Sans",
          fallback_family: [email.Verdana],
          web_font: Some(email.WebFont(
            url: "https://fonts.gstatic.com/...",
            format: email.Woff2,
          )),
          weight: Some(email.Weight400),
          style: Some(email.StyleNormal),
        ),
      ]),
      email.body([style.background_color("#fffbe8")], [
        email.preview("No more tables by hand. Just write your email."),
        email.container([], [
          email.section([style.padding("0.75rem 1.5rem")], [
            email.paragraph([], [html.text("Write emails with peace of mind.")]),
          ]),
        ]),
      ]),
    ])

  let html_body = email.to_html(mail)
  let text_body = email.to_plain_text(mail)
  // hand both to your SMTP client or transactional API wrapper
}
```


### Inbound, IMAP, POP3, parsing

**Empty.** No Gleam-native packages exist at snapshot for:

- **IMAP** — `imap`, `mailbox`, `inbox` searches all return zero results.
- **POP3** — `pop3` search returns zero results.
- **JMAP** — no results.
- **MIME parsing** — `marceau` and `mimetype` cover Content-Type *lookup*, not multipart-MIME parsing of an `.eml`.
- **mbox / Maildir readers** — none.
- **DKIM / DMARC / SPF helpers** — none.

If you need any of this on BEAM today, your options are:

- Call into the Erlang ecosystem from Gleam (`:gen_smtp` from Elixir/Erlang has IMAP and full MIME parsing; the [gen_smtp Hex page](https://hex.pm/packages/gen_smtp) is callable from Gleam via FFI).
- Run a sidecar in another language and integrate via HTTP or a message queue.
- Receive email via a webhook from a vendor (SendGrid Inbound Parse, Mailgun Routes, etc.) — your Gleam app then handles already-parsed JSON instead of raw MIME.

This gap is the most obvious area where Gleam email tooling is missing today.


## SMTP vs transactional API — which to pick

Both ship the same email; the difference is operational.

| | **SMTP** ([lumenmail](#lumenmail), [gcourier](#gcourier)) | **Transactional API** ([sendgriddle](#sendgriddle), [zeptomail](#zeptomail), [plunk](#plunk), [gleesend](#gleesend)) |
| --- | --- | --- |
| **Wire** | Raw SMTP commands over TCP/TLS | HTTPS POST with JSON body |
| **Auth** | Username + password (or OAuth2 for lumenmail) | API key |
| **Vendor lock-in** | None — same code talks to any SMTP server (your own, ISP, SendGrid SMTP relay, mailpit) | Switch SDK if you switch vendor |
| **Deliverability features** | You configure SPF/DKIM/DMARC on your sending domain yourself | Vendor handles signing, IP warmup, bounce handling, suppression lists |
| **Template / merge variables** | Roll your own (smail or just string interpolation) | Often vendor-managed dynamic templates (not exposed in any of the Gleam wrappers at snapshot) |
| **Webhooks (bounces, opens, clicks)** | — | Vendor-side; you'd write a Gleam HTTP handler to receive them |
| **Throughput** | Per-server; you manage rate limits | Vendor handles rate limits and queuing |
| **Best when** | Self-hosted infra, internal mail relays, mailpit-driven dev/test | Production transactional mail at scale; deliverability matters |

Practical pattern: **smail for HTML composition + lumenmail for SMTP in dev/test (against mailpit) + a transactional vendor wrapper in production**. The `Email` records aren't wire-compatible across libraries, but the rendered HTML is — keep your view code in smail, swap the transport.


## Leaderboard
Every contribution is invaluable and appreciated.

This ranking
- helps authors check if the metrics are sane at a glance
- uncovers gems unique to the Gleam ecosystem
- cherishes key contributors

**🥇 Gold**
- **sendgriddle** ([lpil](https://github.com/lpil)) — Tiny, focused, idiomatic, 4+ years old, still being released. The shape ("build email → get `http.Request` → send with any client") is the model the rest of the category should follow.

| Position | Award | Repo | ★ | Lic | Compat | Maint | Age | README | Idiom | Score |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 🥇 | [lpil/gleam_sendgrid](https://github.com/lpil/gleam_sendgrid) (sendgriddle) | 🟨 | 🟩 | 🟩 | 🟩🟩 | 🟩🟩 | 🟩 | 🟩 | **8** |
| 1 | | [gideongrinberg/gcourier](https://github.com/gideongrinberg/gcourier) | 🟨 | 🟩 | 🟩 | 🟩🟩 | 🟩 | 🟩🟩 | 🟩 | **8** |
| 3 | | [lpil/zeptomail](https://github.com/lpil/zeptomail) | 🟥 | 🟩 | 🟩 | 🟩🟩 | 🟩🟩 | 🟩 | 🟩 | **7** |
| 4 | | · [davecaos/lumenmail](https://github.com/davecaos/lumenmail)<br>· [dinkelspiel/gleesend](https://github.com/dinkelspiel/gleesend) | 🟥<br>🟥 | 🟩<br>🟩 | 🟩<br>🟩 | 🟩🟩<br>🟩🟩 | 🟨<br>🟩 | 🟩🟩<br>🟩 | 🟩<br>🟩 | **6** |
| 6 | | [aosasona/plunk.gleam](https://github.com/aosasona/plunk.gleam) | 🟨 | 🟩 | 🟩 | 🟨 | 🟩 | 🟩 | 🟩 | **5** |
| 6 | | [gungun974/smail](https://github.com/gungun974/smail) | 🟥 | 🟩 | 🟩 | 🟩🟩 | 🟥 | 🟩🟩 | 🟩 | **5** |

**By target:** ☎️ BEAM **41** (7 repos) · 📜 JS **24** (5 repos). Dual-target repos (sendgriddle, zeptomail, plunk, gleesend, smail) count toward both.

[How scores are calculated →](#scoring-dimensions)
