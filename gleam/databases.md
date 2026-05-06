# Tools for talking to databases in Gleam

> [!NOTE]
> **Status:** DRAFT · **Authoring:** AI-assisted, human-reviewed.

Need to query a database, run migrations, or pool connections from Gleam?
This article maps out what's available.

## Table of Contents

1. [Summary](#summary)
2. [Research Method](#research-method)
   - [Scoring Dimensions](#scoring-dimensions)
   - [Discovery](#discovery)
3. [Disregarded](#disregarded)
4. [Categories](#categories)
   - [PostgreSQL Drivers](#postgresql-drivers) — [pog](#pog-)
   - [SQLite Bindings](#sqlite-bindings) — [sqlight](#sqlight-)
   - [MySQL Drivers](#mysql-drivers) — [shork](#shork-)
   - [SQL Query Builders](#sql-query-builders) — [cake](#cake-)
   - [SQL Code Generators](#sql-code-generators) — [squirrel](#squirrel-), [parrot](#parrot-), [sqlode](#sqlode-), [marmot](#marmot-)
   - [Migration Tools](#migration-tools) — [cigogne](#cigogne-), [gorrion](#gorrion-)
   - [ORMs & Higher-Level Abstractions](#orms--higher-level-abstractions) — [glimr db](#glimr-db-)
   - [Related Work](#related-work)
5. [Leaderboard](#leaderboard)

Dialect legend: 🐘 PostgreSQL · 🪶 SQLite · 🐬 MySQL.

## Summary

Gleam database tools span drivers, bindings, query builders, code generators, migrations, and (newly) framework-bundled abstractions. **pog** 🐘 (PostgreSQL driver), **sqlight** 🪶 (SQLite bindings), **shork** 🐬 (MySQL/MariaDB driver), **cake** 🐘🪶🐬 (multi-dialect SQL builder), and four SQL→Gleam code generators — **squirrel** 🐘, **parrot** 🐘🪶🐬, **sqlode** 🐘🪶🐬, **marmot** 🪶 — cover query construction and execution. PostgreSQL migration tooling has two standalone options (**cigogne**, **gorrion**); SQLite migration remains a gap — every standalone candidate is either superseded, stale, or has an outdated `gleam_stdlib` cap (see [Disregarded](#disregarded)). The first batteries-included approximation of an ORM ships inside the **glimr** framework's [db module](#glimr-db-) — schema-diff migrations + typed query repositories — but it's not a standalone library.

Snapshot: **2026-04-27**.

| Layer | BEAM | Status |
| --- | --- | --- |
| **[PostgreSQL Drivers](#postgresql-drivers)** | [pog](#pog-) 🐘 (driver with pooling) | 🟩🟩 active |
| **[SQLite Bindings](#sqlite-bindings)** | [sqlight](#sqlight-) 🪶 (low-level bindings) | 🟩🟩 active |
| **[MySQL Drivers](#mysql-drivers)** | [shork](#shork-) 🐬 (mysql-otp wrapper, pog-style API) | 🟨 stale, GitHub mirror archived ([moved](#shork-) to Codeberg) |
| **[SQL Query Builders](#sql-query-builders)** | [cake](#cake-) 🐘🪶🐬 (multi-dialect composer) | 🟩🟩 active |
| **[SQL Code Generators](#sql-code-generators)** | [squirrel](#squirrel-) 🐘, [parrot](#parrot-) 🐘🪶🐬, [sqlode](#sqlode-) 🐘🪶🐬, [marmot](#marmot-) 🪶 | 🟩🟩 active |
| **[Migrations](#migration-tools)** | [cigogne](#cigogne-) 🐘, [gorrion](#gorrion-) 🐘 (ecto-like) | 🟩 active (PG only) |
| **SQLite migrations (standalone)** | None recommended ([disregarded](#disregarded)) | 🟥 Gap |
| **[Framework-bundled DB](#orms--higher-level-abstractions)** | [glimr db](#glimr-db-) 🐘🪶 (schema-diff migrations + typed query repos) | 🟩🟩 active (framework-only) |
| **Standalone ORM** | ⬜ None found | Gap |

> [!IMPORTANT]
> All database tools here target **BEAM only**. No cross-target (JS) database libraries exist yet.

## Research Method

### Scoring Dimensions

Same rubric as [web-apps.md](./web-and-http/web-apps.md#scoring-dimensions). Recap:

- **Stars:** 🟩🟩 ≥200★, 🟩 ≥100★, 🟨 ≥10★, 🟥 <10★.
- **License:** 🟩 permissive (MIT/Apache/BSD), 🟥 viral or missing.
- **Gleam compat:** `gleam_stdlib` constraint format. 🟩 range (`>= X and < Y`), 🟥 `~>` pin.
- **Maintenance:** max(recency, responsiveness). 🟩🟩 <1 mo / <2 days / clean tracker, 🟩 <6 mo / <1 wk, 🟨 <1 yr / <1 mo, 🟥 older / ignored.
- **Age:** 🟩🟩 ≥3 yrs, 🟩 ≥1 yr, 🟨 ≥3 mo, 🟥 <3 mo.
- **README maturity:** 🟩🟩 full guide + examples, 🟩 clear tagline + usage, 🟥 minimal.
- **Idiomaticity:** 🟩 typed/explicit, 🟥 magic directives or template extraction.

**Leaderboard:** 🟥 = −1, 🟨 = 0, 🟩 = 1, 🟩🟩 = 2. Sum of 7 dims, max 13.

### Discovery

Repos identified via [packages.gleam.run](https://packages.gleam.run/) searches:
- [database](https://packages.gleam.run/?search=database)
- [db](https://packages.gleam.run/?search=db)
- [sql](https://packages.gleam.run/?search=sql)
- [postgres](https://packages.gleam.run/?search=postgres)
- [sqlite](https://packages.gleam.run/?search=sqlite)
- [mysql](https://packages.gleam.run/?search=mysql)
- [migration](https://packages.gleam.run/?search=migration)
- [orm](https://packages.gleam.run/?search=orm)
- [ecto](https://packages.gleam.run/?search=ecto)
- [marmot](https://packages.gleam.run/?search=marmot) (re-checked 2026-04-27 — surfaced [`marmot`](#marmot-), the SQLite codegen)
- [parrot](https://packages.gleam.run/?search=parrot) (re-checked 2026-04-27 — confirmed [`parrot`](#parrot-) under SQL Code Generators, not a driver)

Framework-bundled DB modules were surfaced from the [Web apps review](./web-and-http/web-apps.md) — currently only [glimr](#glimr-db-) ships a substantive DB layer.

## Disregarded

These packages turned up in the searches but are **not recommended**. Listed up-front so future reviewers know the corner has been considered and why each entry was skipped — keeping the per-category pages free of dead-end clutter.

| Package | Dialect | Reason disregarded |
| --- | --- | --- |
| [migrant](https://github.com/aosasona/migrant) | 🪶 SQLite (migrations) | `gleam_stdlib` constraint capped at `< 1.0.0` — incompatible with current stdlib. Last commit 2025-11-30 (~5 months stale). License inconsistency (repo MIT, gleam.toml Apache-2.0). |
| [storch](https://github.com/VioletBuse/storch) | 🪶 SQLite (migrations) | Repo README states it is **superseded by `feather`**. Last commit 2024-06-28 (~22 months stale). |
| [feather](https://hex.pm/packages/feather) | 🪶 SQLite (migrations) | Storch's named successor — but itself stale: last release 2024-08-14 (~20 months), no commits since. Same author as storch. |
| [akaridb](https://hex.pm/packages/akaridb) | ❓ unspecified (migrations) | **No public source repository.** Hex package has no repo link in metadata, hexdocs, or footer. Cannot audit, fork, or contribute. Last release 2024-08-11. |
| [gmysql](https://github.com/VioletBuse/gmysql) | 🐬 MySQL (driver) | Last release ~1 year before snapshot; superseded in active use by [shork](#shork-) (which is what cake/sqlode wire to). |

> [!WARNING]
> **SQLite migration is currently a gap in the Gleam ecosystem.** Every published SQLite migration package above is either superseded, stale, or has an outdated `gleam_stdlib` cap. For new SQLite projects today, run migrations from outside Gleam (sqlite shell scripts, Make targets) or roll your own thin runner on top of [sqlight](#sqlight-) — or adopt the [glimr](#glimr-db-) framework, which ships schema-diff SQLite migrations.

> [!NOTE]
> **parrot** previously appeared in a disregard-style note under MySQL Drivers (it isn't a driver). It has now been reviewed as a [SQL Code Generator](#parrot-) — see that section.

## Categories

### PostgreSQL Drivers

#### pog 🐘
[repo](https://github.com/lpil/pog) · [🥇](#leaderboard)

PostgreSQL driver for Gleam. Provides connection pooling, parameterized queries, and type-safe result decoding. No ORM — write SQL directly and decode results with custom decoders.

| Criterion | [pog](https://github.com/lpil/pog) |
| --- | --- |
| Stars | 248★ · 🟩🟩 |
| License | Apache-2.0 · 🟩 |
| Target | ☎️ BEAM |
| Deps | 5 |
| Gleam compat | `>= 0.44 and < 2.0` · 🟩 |
| Maintenance | 🟩 (last commit 2026-03-09, ~7 weeks vs 2026-04-27) |
| Age | ~6 years (Nov 2019) · 🟩🟩 |
| README maturity | 🟩🟩 (comprehensive guide with pooling example, SQL API, error handling) |
| Idiomaticity | 🟩 (typed queries, explicit decoders) |

**Key features:**
- Connection pooling via `pog.Postgrex`
- Parameterized queries (prevents SQL injection)
- Custom decoders for result rows
- Supports transactions
- Async-safe (works with Gleam processes)

```gleam
import pog
import gleam/dynamic/decode

pub fn get_user(db: pog.Connection, id: Int) -> Result(pog.Returned(User), pog.QueryError) {
  let decoder = {
    use id <- decode.field(0, decode.int)
    use name <- decode.field(1, decode.string)
    use email <- decode.field(2, decode.string)
    decode.success(User(id:, name:, email:))
  }
  
  "SELECT id, name, email FROM users WHERE id = $1"
  |> pog.query()
  |> pog.parameter(pog.int(id))
  |> pog.returning(decoder)
  |> pog.execute(db)
}
```

### SQLite Bindings

#### sqlight 🪶
[repo](https://github.com/lpil/sqlight) · [🥉](#leaderboard)

SQLite bindings for Gleam. Lower-level than pog — you manage connections directly and decode results. Good for embedding SQLite in Gleam applications or when PostgreSQL isn't needed.

| Criterion | [sqlight](https://github.com/lpil/sqlight) |
| --- | --- |
| Stars | 147★ · 🟩 |
| License | Apache-2.0 · 🟩 |
| Target | ☎️ BEAM |
| Deps | 2 |
| Gleam compat | `>= 0.32 and < 2.0` · 🟩 |
| Maintenance | 🟩🟩 (last commit 2026-04-18, ~9 days vs 2026-04-27) |
| Age | ~3.5 years (Dec 2022) · 🟩🟩 |
| README maturity | 🟩 (tagline + basic example + list of functions) |
| Idiomaticity | 🟩 (typed, explicit) |

**Key features:**
- Direct SQLite C bindings
- No connection pooling (manage connections yourself)
- Parameterized queries
- Synchronous API (blocks until query completes)

```gleam
import sqlight
import gleam/list

pub fn insert_user(db: sqlight.Connection, name: String, email: String) -> Result(Nil, sqlight.Error) {
  sqlight.exec(
    db,
    "INSERT INTO users (name, email) VALUES (?, ?)",
    [sqlight.text(name), sqlight.text(email)],
  )
}

pub fn list_users(db: sqlight.Connection) -> Result(List(User), sqlight.Error) {
  sqlight.query(
    db,
    "SELECT id, name, email FROM users",
    [],
    decode_user,
  )
}

fn decode_user(row: sqlight.Row) -> Result(User, Nil) {
  User(
    id: sqlight.column(row, 0),
    name: sqlight.column(row, 1),
    email: sqlight.column(row, 2),
  )
  |> Ok
}
```

### MySQL Drivers

#### shork 🐬
[repo](https://github.com/ninanomenon/shork) · [leaderboard ↓](#leaderboard)

MySQL / MariaDB driver for Gleam, built on top of Erlang's [mysql-otp](https://github.com/mysql-otp/mysql-otp). API is heavily inspired by [pog](#pog-) — same builder pattern (`shork.query` → `shork.parameter` → `shork.returning` → `shork.execute`), same row-decoder style. Used as the MySQL execution backend by [cake](#cake-) and [sqlode](#sqlode-).

> [!CAUTION]
> The README announces the project has **moved to Codeberg** ([codeberg.org/ninanonemon/shork](https://codeberg.org/ninanonemon/shork)); the GitHub repo is now a frozen mirror. Last GitHub commit was 2025-10-12, ~6.5 months before snapshot. Hex is still publishing as `shork` (latest 1.4.0), but future releases will originate from Codeberg.

| Criterion | [shork](https://github.com/ninanomenon/shork) |
| --- | --- |
| Stars | 9★ · 🟥 |
| License | LGPL-3.0 · 🟥 (weak copyleft — flag for permissive-only shops) |
| Target | ☎️ BEAM (via mysql-otp NIF) |
| Deps | 4 (`gleam_erlang`, `gleam_otp`, `gleam_time`, `mysql`) |
| Gleam compat | `>= 0.65.0 and < 1.0.0` · 🟥 (capped below current stdlib — risky) |
| Maintenance | 🟨 (last GitHub commit 2025-10-12, ~6.5 months vs 2026-04-27; mirror frozen) |
| Age | ~16 months (Dec 2024) · 🟩 |
| README maturity | 🟩 (clear tagline + worked example + dev/docker setup; relegates further docs to hexdocs) |
| Idiomaticity | 🟩 (pog-style typed builder + decoder) |
| Latest version | **1.4.0** (Hex) |
| Issues | ⬜ (Issues tab disabled on GitHub mirror; see Codeberg) |

**Key features:**
- MySQL & MariaDB support via Erlang's `mysql-otp`
- Builder API mirrors `pog`: parameterized queries, typed `returning` decoders
- Connection lifecycle: `default_config → user → password → database → connect`
- Synchronous execute path; pooling delegated to OTP supervisor design

```gleam
import shork
import gleam/dynamic/decode

pub fn main() {
  let connection =
    shork.default_config()
    |> shork.user("root")
    |> shork.password("strong_password")
    |> shork.database("poke")
    |> shork.connect

  let row_decoder = {
    use name <- decode.field(0, decode.string)
    use hp   <- decode.field(1, decode.int)
    decode.success(#(name, hp))
  }

  let assert Ok(response) =
    shork.query("select name, hp from pokemon where id = ?")
    |> shork.parameter(shork.int(1))
    |> shork.returning(row_decoder)
    |> shork.execute(connection)
}
```

> [!NOTE]
> Two other packages surfaced in the [`mysql`](https://packages.gleam.run/?search=mysql) search but live elsewhere:
> - **[gmysql](https://github.com/VioletBuse/gmysql)** — driver, but stale and superseded by shork. See [Disregarded](#disregarded).
> - **[parrot](https://github.com/daniellionel01/parrot)** — typed SQL codegen across SQLite/PG/MySQL, not a driver. Reviewed under [SQL Code Generators → parrot](#parrot-).

### SQL Query Builders

#### cake 🐘🪶🐬
[repo](https://github.com/inoas/gleam-cake) · [🥇](#leaderboard)

Multi-dialect SQL composer. Builds prepared-statement-safe SQL fragments for PostgreSQL, SQLite, MariaDB, and MySQL. Composes queries — does **not** execute. Pairs with execution adapters (`pog`, `sqlight`, `shork`, `gmysql`).

| Criterion | [cake](https://github.com/inoas/gleam-cake) |
| --- | --- |
| Stars | 124★ · 🟩 |
| License | MPL-2.0 · 🟥 (weak copyleft, file-level — flag for MIT/Apache shops) |
| Target | ☎️ BEAM + JS · 🐘🪶🐬 (PG / SQLite / MariaDB & MySQL via shork) |
| Gleam compat | unknown (gleam.toml fetch failed) · 🟨 |
| Maintenance | 🟩🟩 (last commit 2026-04-25, 2 days before snapshot) |
| Age | ~2 years (Apr 2024) · 🟩🟩 |
| README maturity | 🟩🟩 (full guide: install, worked examples, design goals/non-goals, dialect adapter list) |
| Idiomaticity | 🟩 (typed fragment composition, prepared-statement-safe) |
| Issues | 2 open |

**Key features:**
- Four SQL dialects from one API: PostgreSQL, SQLite, MariaDB, MySQL
- Erlang + JavaScript targets
- Read + write query construction (SELECT / INSERT / UPDATE / DELETE)
- Composition-only — execute via separate adapter (pog/sqlight/shork/gmysql)
- Prepared-statement-safe parameter binding

### SQL Code Generators

#### Comparison

| Tool | Dialects | Style | Driver coupling | Output modes | Stars | Latest | Maint |
| --- | --- | --- | --- | --- | --- | --- | --- |
| [squirrel](#squirrel-) | 🐘 PostgreSQL 16+ | `.sql` files → typed Gleam decoders | tight (pog) | single (typed decoders) | 630★ | — | 🟩 (5 wk) |
| [parrot](#parrot-) | 🐘 PostgreSQL · 🪶 SQLite · 🐬 MySQL | sqlc plugin → typed Gleam (auto-downloads sqlc binary) | driver-agnostic, ships utility wrappers for pog/sqlight | typed functions + decoders | 207★ | 2.2.1 | 🟩 (~12 wk on `main`; ~2 wk on `version3` branch) |
| [sqlode](#sqlode-) | 🐘 PostgreSQL · 🪶 SQLite · 🐬 MySQL 8 | sqlc-style schema + queries → typed Gleam | driver-agnostic at codegen (pog/sqlight/shork) | raw (SQL+params) + native (full binding) | 3★ | 0.9.0 | 🟩🟩 (1 day) |
| [marmot](#marmot-) | 🪶 SQLite | `.sql` files → typed Gleam (squirrel-style introspection) | tight (sqlight) | typed functions + decoders | 2★ | 1.1.1 | 🟩🟩 (4 days) |

**Pick:**
- **squirrel** for PostgreSQL — established (FOSDEM-talked, 630★), proven, tight pog integration.
- **parrot** if you want a single typed codegen across PostgreSQL/SQLite/MySQL on a battle-tested foundation (sqlc) — the largest community of any Gleam SQL codegen (207★), Apache-2.0, listed as a sqlc community plugin upstream. Trade-off: depends on the external `sqlc` binary (auto-downloaded), and recent activity has shifted to a `version3` branch.
- **sqlode** if you need SQLite or MySQL codegen and prefer raw-mode output for custom adapters; brand new (Apr 2026), unproven but comprehensive, no external binary.
- **marmot** for SQLite-only projects that want squirrel's exact ergonomics. SQLite-specific, brand new (Apr 2026).

#### squirrel 🐘
[repo](https://github.com/giacomocavalieri/squirrel) · [🥇](#leaderboard)

SQL-first code generator: write `.sql` files, squirrel generates type-safe Gleam functions with decoders. Embraces SQL + editor support (syntax highlighting, formatting) without ORM magic. Requires PostgreSQL 16+.

| Criterion | [squirrel](https://github.com/giacomocavalieri/squirrel) |
| --- | --- |
| Stars | 630★ · 🟩🟩 |
| License | Apache-2.0 · 🟩 |
| Target | ☎️ BEAM (Postgres 16+ required) |
| Deps | 2 |
| Gleam compat | `>= 0.44 and < 2.0` · 🟩 |
| Maintenance | 🟩 (last commit 2026-03-19, ~5.5 weeks vs 2026-04-27) |
| Age | ~1.5 years (Aug 2024) · 🟩 |
| README maturity | 🟩🟩 (FOSDEM talk, detailed guides, real examples) |
| Idiomaticity | 🟩 (generated code matches hand-written idiomatic Gleam) |

**Key features:**
- Write queries in `.sql` files (syntax highlighting, formatting, `explain`)
- Auto-generate type-safe decoders from SQL result types
- Convention-based: `src/**/sql/` → `src/**/sql.gleam`
- Works with `pog` driver for execution
- Prevent decoder/query drift automatically

```sql
-- src/app/sql/find_user.sql
-- Find user by name with owned items count.
select
  u.id,
  u.name,
  count(i.id) as items_count
from
  users u
left join items i on u.id = i.user_id
where
  u.name = $1
group by u.id, u.name
```

Generated Gleam (automatic):
```gleam
import pog
import app/sql

pub fn main(db: pog.Connection) {
  let assert Ok(pog.Returned(_count, rows)) = 
    sql.find_user(db, "alice")
  
  let assert [sql.FindUserRow(id: 1, name: "alice", items_count: 5)] = rows
}
```

#### parrot 🐘🪶🐬
[repo](https://github.com/daniellionel01/parrot) · [🥈](#leaderboard) · *(renamed from `sqlc-gen-gleam`)*

Multi-dialect SQL→Gleam code generator built as an [sqlc](https://sqlc.dev/) plugin. Reads SQL schema + queries, leverages sqlc's mature parser/codegen pipeline, and emits typed Gleam functions, parameter encoders, and decoders. Supports PostgreSQL, SQLite, and MySQL. Auto-downloads the sqlc binary on first run; ships utility wrappers for [`lpil/sqlight`](#sqlight-) and [`lpil/pog`](#pog-) so generated code drops cleanly into either driver. Listed as a community plugin on the [sqlc website](https://docs.sqlc.dev/en/latest/reference/language-support.html). README explicitly credits sqlc: *"Most of the heavy lifting features are provided by / built into sqlc, I do not aim to take credit for them."*

| Criterion | [parrot](https://github.com/daniellionel01/parrot) |
| --- | --- |
| Stars | 207★ · 🟩🟩 |
| License | Apache-2.0 · 🟩 |
| Target | ☎️ BEAM (codegen + generated code) |
| Deps | 11 |
| Gleam compat | `>= 0.34.0 and < 2.0.0` · 🟩 |
| Maintenance | 🟩 (last `main` commit 2026-02-03, ~12 weeks before snapshot; `version3` branch active 2026-04-13) |
| Age | ~16 months (Dec 2024) · 🟩 |
| README maturity | 🟩🟩 (features, code showcase, usage guide, dev/quirks/FAQ/future-work sections) |
| Idiomaticity | 🟩 (typed function signatures, named parameters inferred from SQL, explicit decoders) |
| Latest version | **2.2.1** (Hex) |
| Issues | 3 open (issues), 6 open (PRs) |

**Key features:**
- Three dialects from one codegen: PostgreSQL, SQLite, MySQL
- Multiple queries per `.sql` file, sqlc-style annotations (`-- name: GetUser :one`)
- Named parameters: function arg names inferred from SQL columns
- Auto-downloads sqlc binary; auto-pulls schema from your DB
- Driver-agnostic at the type layer; utility wrappers for `sqlight` and `pog`
- Database client agnostic — generated `(SQL, [params])` tuples plug into any driver

```sql
-- src/sql/users.sql
-- name: GetUserByUsername :one
select id, username, created_at, role
from users
where username = $1
limit 1;
```

Generated Gleam (abridged):
```gleam
pub type GetUserByUsername {
  GetUserByUsername(id: Int, username: String, created_at: Timestamp, role: UserRole)
}

pub fn get_user_by_username(username username: String) {
  let sql = "select id, username, created_at, role from users where username = $1 limit 1"
  #(sql, [dev.ParamString(username)])
}

pub fn get_user_by_username_decoder() -> decode.Decoder(GetUserByUsername) {
  // ...
}
```

> [!NOTE]
> Parrot is also reviewed in [parsers-and-generators/generate.md → parrot](./parsers-and-generators/generate.md#parrot) under the broader codegen rubric. The score here is computed against this article's database-context rubric and matches the cross-article entry.

#### sqlode 🐘🪶🐬
[repo](https://github.com/nao1215/sqlode) · [leaderboard ↓](#leaderboard)

Multi-dialect sqlc-style code generator. Reads SQL schema + query files, emits typed Gleam code. Supports PostgreSQL (via pog), MySQL 8 (via shork), and SQLite (via sqlight). Two output modes: **raw** (returns SQL string + params) and **native** (full adapter binding/decoding). Brand new — created 2026-04-12.

| Criterion | [sqlode](https://github.com/nao1215/sqlode) |
| --- | --- |
| Stars | 3★ · 🟥 |
| License | MIT · 🟩 |
| Target | ☎️ BEAM (driver-agnostic at codegen time) |
| Gleam compat | `>= 0.44 and < 2.0` · 🟩 |
| Maintenance | 🟩🟩 (last commit 2026-04-26, 1 day before snapshot) |
| Age | ~2 weeks (Apr 2026) · 🟥 |
| README maturity | 🟩🟩 (comprehensive: tutorials, examples, migration instructions, Docker notes) |
| Idiomaticity | 🟩 (generated code uses standard adapter APIs) |
| Issues | 0 open (positive — but very new) |

**Key features:**
- sqlc-style typed code generation from SQL schema + query files
- Three dialects: PostgreSQL, MySQL 8, SQLite
- Two runtime modes: raw (`SQL + params`) and native (full driver binding + decoding)
- Query macros: `sqlode.arg`, `sqlode.narg`, `sqlode.slice`, `sqlode.embed`
- `sqlode verify` static-check command
- Latest version: **0.9.0**

#### marmot 🪶
[repo](https://github.com/pairshaped/marmot) · [leaderboard ↓](#leaderboard)

SQLite-only SQL→Gleam code generator. Heavily inspired by [squirrel](#squirrel-) — same idea, different dialect: write `.sql` files, point marmot at a SQLite database, and it generates type-safe Gleam functions, row types, and decoders by introspecting the live schema. Pairs with [sqlight](#sqlight-) at runtime. Fills the SQLite-codegen gap that squirrel (PostgreSQL-only) leaves open.

| Criterion | [marmot](https://github.com/pairshaped/marmot) |
| --- | --- |
| Stars | 2★ · 🟥 |
| License | MIT · 🟩 |
| Target | ☎️ BEAM (SQLite via [`sqlight`](#sqlight-)) |
| Deps | 6 (`gleam_stdlib`, `sqlight`, `simplifile`, `tom`, `argv`, `gleam_time`) |
| Gleam compat | `>= 0.34.0 and < 2.0.0` · 🟩 |
| Maintenance | 🟩🟩 (last commit 2026-04-23, 4 days before snapshot) |
| Age | ~8 days (created 2026-04-19) · 🟥 |
| README maturity | 🟩🟩 (squirrel-style guide: motivation, install, usage, type mapping, limitations, comparison) |
| Idiomaticity | 🟩 (typed functions, labelled args, explicit decoders — matches squirrel ergonomics) |
| Latest version | **1.1.1** (Hex) |
| Issues | 0 open |

**Key features:**
- Reads `src/**/sql/*.sql`, generates typed Gleam functions in `generated/sql/`
- Schema introspection via a real SQLite database — types inferred from live schema
- Labelled arguments on generated call sites (`users_sql.find_user(db: db, username: "alice")`)
- Named parameter support (`@name`, `:name`, `$name`)
- Shared return types across queries via annotations
- Configurable query wrapper for logging/instrumentation
- SQLite type map: `INTEGER → Int`, `TEXT → String`, `BLOB → BitArray`, etc.
- Configurable via `gleam.toml`, env var, or CLI flag

```sql
-- src/users/sql/find_user.sql
select name, email
from users
where username = ?
```

```gleam
import sqlight
import generated/sql/users_sql

pub fn main() {
  use db <- sqlight.with_connection("app.sqlite")
  let assert Ok([user]) = users_sql.find_user(db: db, username: "alice")
  // user.name, user.email are fully typed
}
```

**Field report (parrot → marmot migration).** Posted by the marmot author on the Gleam Discord ([source](https://discord.com/channels/768594524158427167/1495928534240071760/1495928534240071760)):

> Marmot is a code generator for Gleam that turns plain `.sql` files into type-safe functions for SQLite. Write your queries in SQL, point Marmot at your database, and it generates the Gleam functions, row types, and decoders you need. No ORM, no query builder, no manual decoder boilerplate. HEAVILY inspired by Squirrel (which does the same for Postgres).
>
> We were using Parrot, which served us well and is a solid choice, but it wraps `sqlc` (an external Go binary) and generates one monolithic `sql.gleam` file that hit ~25k lines in our codebase. Marmot is pure Gleam, generates per-entity modules, has first-class named parameters, and lets queries share row types via a simple `-- returns: EntityRow` annotation. Dropped ~500 lines of adapter boilerplate in the migration.

Concrete trade-offs surfaced by this report:

- **Module granularity** — parrot's single-file output (`sql.gleam`) reaches ~25k lines on a real codebase; marmot emits per-entity modules.
- **Build dependency** — parrot wraps `sqlc` (Go binary, auto-downloaded); marmot is pure Gleam, no external toolchain.
- **Shared row types** — marmot's `-- returns: EntityRow` annotation lets multiple queries reuse a typed row, removing the per-query decoder duplication that motivated the ~500-line adapter cut.

> [!NOTE]
> Marmot is also reviewed in [parsers-and-generators/generate.md → marmot](./parsers-and-generators/generate.md#marmot) under the broader codegen rubric. The score here uses this article's database-context rubric.

### Migration Tools

Two PostgreSQL migration tools are recommendable. SQLite migrations are a current gap — see [Disregarded](#disregarded) at the top of this article for the disregarded SQLite-migration packages and their reasons.

#### Comparison

| Tool | Dialect | Style | Hash check | Library-bundled | Down migrations | CLI | Stars | Latest | Maint |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| [cigogne](#cigogne-) | 🐘 PostgreSQL | SQL up/down | ✅ | ✅ | ✅ | ✅ | 43★ | 5.0.6 | 🟩🟩 (3 days) |
| [gorrion](#gorrion-) | 🐘 PostgreSQL | Ecto-style API | ❌ | ❌ | optional | ❌ | 1★ | 0.2.0-rc1 | 🟩🟩 (1 wk) |

**Pick:** **cigogne** for production PostgreSQL — mature, hash-verified, library-bundled migrations, real CLI. **gorrion** if you want an Ecto-style programmatic API and don't need a CLI; brand new (Mar 2026), one-month-old project, RC release.

#### cigogne 🐘
[repo](https://github.com/Billuc/cigogne) · [leaderboard ↓](#leaderboard)

PostgreSQL migration tool (via pog). SQL up/down migrations with hash verification (tamper detection), CLI for apply/rollback/status, and library-bundled migration support (deps can ship their own migrations).

| Criterion | [cigogne](https://github.com/Billuc/cigogne) |
| --- | --- |
| Stars | 43★ · 🟨 |
| License | MIT · 🟩 |
| Target | ☎️ BEAM (PostgreSQL via pog) |
| Gleam compat | `>= 0.60.0 and < 2.0.0` · 🟩 |
| Maintenance | 🟩🟩 (last commit 2026-04-23, 4 days before snapshot) |
| Age | ~17 months (Nov 2024) · 🟩 |
| README maturity | 🟩🟩 (full guide: install, usage, `cigogne.toml` config, advanced options) |
| Idiomaticity | 🟩 |
| Latest version | **5.0.6** (Hex) |
| Issues | 4 open |

**Key features:**
- SQL up/down migrations with hash verification
- CLI: apply / rollback / status
- Library-bundled migrations (deps can ship migrations)
- Configurable transaction control via `cigogne.toml`

#### gorrion 🐘
[repo](https://github.com/davecaos/gorrion) · [leaderboard ↓](#leaderboard)

Ecto-inspired PostgreSQL migration library. Reads `.sql` migration files from a directory, tracks state in `_schema_migrations` table, supports `migrate()`, `rollback()`, `rollback_to()`, `status()`. Brand new (Mar 2026), comprehensive README, but only 1 star.

| Criterion | [gorrion](https://github.com/davecaos/gorrion) |
| --- | --- |
| Stars | 1★ · 🟥 |
| License | MIT · 🟩 |
| Target | ☎️ BEAM (PostgreSQL via pog) |
| Gleam compat | `>= 0.51.0` (no upper bound — risky) · 🟨 |
| Maintenance | 🟩🟩 (last commit 2026-04-19, 8 days before snapshot) |
| Age | ~1 month (Mar 2026) · 🟥 |
| README maturity | 🟩🟩 (full guide: conventions, examples, API docs, implementation details) |
| Idiomaticity | 🟩 (Ecto-style API: `migrate`/`rollback`/`status`) |
| Latest version | **0.2.0-rc1** |
| Issues | 0 open |

**Key features:**
- Ecto-style API: `migrate()`, `rollback()`, `rollback_to()`, `status()`
- File-based `.sql` migrations in a directory
- State table: `_schema_migrations`
- Optional down migrations

### ORMs & Higher-Level Abstractions

No **standalone** ORM exists for Gleam. The standalone library philosophy is:
- **Minimal** — Gleam prefers explicit SQL + decoders to auto-magic ORMs.
- **Control** — Manage queries and result mapping yourself.
- **Performance** — No hidden N+1 queries or implicit joinloading.

For feature-rich abstractions, consider:
- **Nested decoders** — Build reusable decoder functions to map rows to typed structures.
- **SQL codegen + drivers** — Use `squirrel` 🐘 (PostgreSQL) or `sqlode` 🐘🪶🐬 (multi-dialect) to generate type-safe decoders from SQL files + `pog`/`sqlight`/`shork` for execution.
- **Query builders** — Use `cake` 🐘🪶🐬 to compose dialect-portable SQL fragments at runtime, then execute via your driver of choice.
- **Framework-bundled DB layer** — Use [glimr db](#glimr-db-) 🐘🪶 if you're already building on the [glimr](#glimr-db-) framework — closest thing to an ORM in the ecosystem (schema-diff migrations + typed query repository codegen). Not consumable as a standalone library.

#### glimr db 🐘🪶
[code](https://github.com/glimr-org/framework/tree/main/src/glimr/db) · [migrations docs](https://github.com/glimr-org/glimr#migrations) · [leaderboard ↓](#leaderboard)

The database module shipped inside the [glimr](https://github.com/glimr-org/glimr) batteries-included web framework. Provides a unified `db.DbPool` type backed by either PostgreSQL (via [`pog`](#pog-) through `glimr_postgres`) or SQLite (via [`sqlight`](#sqlight-) through `glimr_sqlite`), schema-diff migrations, and a CLI-driven typed query repository generator. The closest thing to an "ORM" the Gleam ecosystem currently has — but only consumable inside a glimr application, not as an à la carte library.

> [!IMPORTANT]
> **Framework-only, not a standalone library.** Code lives at `glimr-org/framework/src/glimr/db` and is published on Hex as part of `glimr`, but the schemas/migrations/queries pipeline (`./glimr make_model`, `./glimr db_gen`, `./glimr setup_database`) is wired through the framework's CLI and project layout. You can't `gleam add glimr` from a non-glimr project and use just the db module. The leaderboard scores it as a framework component, not a drop-in library.

| Criterion | [glimr db](https://github.com/glimr-org/framework/tree/main/src/glimr/db) |
| --- | --- |
| Stars | 84★ (framework repo) · 🟨 (template repo `glimr-org/glimr` has 169★) |
| License | MIT (framework repo) · 🟩 |
| Target | ☎️ BEAM (PG via pog, SQLite via sqlight) · 🐘🪶 |
| Gleam compat | `>= 0.44.0 and < 2.0.0` (framework `gleam.toml`) · 🟩 |
| Maintenance | 🟩🟩 (framework last commit 2026-04-23, 4 days vs 2026-04-27; template same day) |
| Age | ~5 months (Dec 2025) · 🟨 |
| README maturity | 🟩🟩 (full guide: schema DSL, column-type table, modifiers, migrations diffing, query naming convention, repository codegen, connection pooling, multi-database setup) |
| Idiomaticity | 🟩 (typed `DbPool`, generated typed query functions, `_or_fail` continuation variants for HTTP handlers) |
| Latest version | **1.3.3** (framework on Hex), **1.0.0** (template) |
| Issues | 1 open (framework), 1 open (template) |

**Key features:**
- **Schema DSL** — `glimr/db/schema` defines tables, columns (with PG/SQLite-aware types), modifiers (`nullable`, `default_*`, `array`, `on_delete`/`on_update`), enums (generates a Gleam custom type with `*_to_string`/`*_from_string`), indexes.
- **Automatic migrations** — diffs current schema definitions against a stored snapshot and emits driver-specific SQL. No hand-written `up`/`down` files.
- **Query repository codegen** — `./glimr make_model user` generates `create.sql` / `find.sql` / `list.sql` / `update.sql` / `delete.sql` from the schema; `./glimr db_gen` compiles all `.sql` files into typed Gleam functions. Each query yields **four** variants: `find` (returns `Result`), `find_wc` (in-transaction, takes `Connection`), `find_or_fail` (continuation-style for HTTP handlers), `find_or_fail_wc` (in-transaction continuation).
- **Naming convention** — file prefix `list` / `list_*` returns `List(T)`; everything else returns a single row.
- **Multi-database support** — multiple named connections in `config/database.toml`, can mix PG and SQLite in one app.
- **Driver-agnostic API** — application code uses `DbPool`; swap `glimr_postgres` ↔ `glimr_sqlite` without changing query call sites.
- **Connection pooling, transactions** with automatic deadlock retry.

```gleam
// src/database/main/models/user/user_schema.gleam
import glimr/db/schema

pub const table_name = "users"

pub fn definition() {
  schema.table(table_name, [
    schema.id(),
    schema.foreign("organization_id", "organizations")
      |> schema.nullable()
      |> schema.on_delete(schema.Cascade),
    schema.string("email"),
    schema.enum("role", ["admin", "editor", "viewer"]),
    schema.unix_timestamps(),
  ])
  |> schema.indexes([
    schema.unique(["email"]),
  ])
}
```

```gleam
// In a controller — _or_fail short-circuits to a 404/503/500 Response on error
import database/models/user/gen/user
import glimr/http/response.{type Response}

pub fn show(ctx: Context(App), id: Int) -> Response {
  use user <- user.find_or_fail(ctx.app.db, id)

  user_show.render(user: user)
  |> response.string_tree(200)
}
```

### Related Work

- **[gleam/http](./web-and-http/web-apps.md#http)** — Core HTTP types, often paired with database tools for REST APIs.
- **[lustre](./web-and-http/web-apps.md#lustre)** — Web framework; Lustre Server Components often interact with databases on the BEAM side.

## Leaderboard

Disregarded packages (akaridb, storch, migrant, feather, gmysql) are excluded — see [Disregarded](#disregarded) at the top of the article for reasons. **glimr db** is included for reference but flagged as framework-bundled (not a standalone library).

| Position | Award | Repo | Dialect | ★ | Lic | Compat | Maint | Age | README | Idiom | Score |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 🥇 | [lpil/pog](https://github.com/lpil/pog) | 🐘 | 🟩🟩 | 🟩 | 🟩 | 🟩 | 🟩🟩 | 🟩🟩 | 🟩 | **10** |
| 2 | 🥈 | [giacomocavalieri/squirrel](https://github.com/giacomocavalieri/squirrel) | 🐘 | 🟩🟩 | 🟩 | 🟩 | 🟩 | 🟩 | 🟩🟩 | 🟩 | **9** |
| 2 | 🥈 | [lpil/sqlight](https://github.com/lpil/sqlight) | 🪶 | 🟩 | 🟩 | 🟩 | 🟩🟩 | 🟩🟩 | 🟩 | 🟩 | **9** |
| 2 | 🥈 | [daniellionel01/parrot](https://github.com/daniellionel01/parrot) | 🐘🪶🐬 | 🟩🟩 | 🟩 | 🟩 | 🟩 | 🟩 | 🟩🟩 | 🟩 | **9** |
| 5 | 🥉 | [Billuc/cigogne](https://github.com/Billuc/cigogne) | 🐘 | 🟨 | 🟩 | 🟩 | 🟩🟩 | 🟩 | 🟩🟩 | 🟩 | **8** |
| 6 | — | [glimr-org/framework (db)](https://github.com/glimr-org/framework/tree/main/src/glimr/db) † | 🐘🪶 | 🟨 | 🟩 | 🟩 | 🟩🟩 | 🟨 | 🟩🟩 | 🟩 | **7** |
| 6 | — | [inoas/gleam-cake](https://github.com/inoas/gleam-cake) | 🐘🪶🐬 | 🟩 | 🟥 | 🟨 | 🟩🟩 | 🟩🟩 | 🟩🟩 | 🟩 | **7** |
| 8 | — | [nao1215/sqlode](https://github.com/nao1215/sqlode) | 🐘🪶🐬 | 🟥 | 🟩 | 🟩 | 🟩🟩 | 🟥 | 🟩🟩 | 🟩 | **5** |
| 8 | — | [pairshaped/marmot](https://github.com/pairshaped/marmot) | 🪶 | 🟥 | 🟩 | 🟩 | 🟩🟩 | 🟥 | 🟩🟩 | 🟩 | **5** |
| 10 | — | [davecaos/gorrion](https://github.com/davecaos/gorrion) | 🐘 | 🟥 | 🟩 | 🟨 | 🟩🟩 | 🟥 | 🟩🟩 | 🟩 | **4** |
| 11 | — | [ninanomenon/shork](https://github.com/ninanomenon/shork) ‡ | 🐬 | 🟥 | 🟥 | 🟥 | 🟨 | 🟩 | 🟩 | 🟩 | **0** |

† **glimr db** is bundled inside the glimr web framework, not consumable as a standalone library. Score is informational; treat it as a framework feature, not a library to compare with the others. See the [glimr db](#glimr-db-) entry.

‡ **shork** GitHub mirror is frozen — repo has [moved to Codeberg](https://codeberg.org/ninanonemon/shork). Hex package (`shork`, 1.4.0) is still the recommended MySQL/MariaDB driver in practice (used by cake and sqlode), but the GitHub-visible activity score does not reflect ongoing Codeberg development.

**Summary:**
- **Drivers & bindings:** **pog** 🐘 leads overall — active maintenance, mature pooling, comprehensive docs. **sqlight** 🪶 is the SQLite low-level binding of choice and received a same-day commit at snapshot time. **shork** 🐬 fills the MySQL/MariaDB slot but the GitHub mirror has been frozen since Oct 2025 in favour of Codeberg, the gleam_stdlib cap is `< 1.0.0`, and the LGPL-3.0 license is a caveat for permissive-only shops — usable today (cake and sqlode wire to it) but watch for releases on Codeberg, not GitHub.
- **Codegen:** Four SQL→Gleam codegens now sit in this corner. **squirrel** 🐘 is the established choice (PostgreSQL only, 630★, FOSDEM-talked). **parrot** 🐘🪶🐬 is the largest multi-dialect entrant (207★, Apache-2.0, sqlc-backed, listed as a sqlc community plugin) — pick this when you need a battle-tested foundation across PG/SQLite/MySQL and don't mind the auto-downloaded `sqlc` binary. **sqlode** 🐘🪶🐬 is a brand-new (Apr 2026) multi-dialect challenger with a comprehensive README and no external binary — promising but unproven. **marmot** 🪶 is squirrel's SQLite analogue (Apr 2026) — same ergonomics, fills the SQLite-codegen gap.
- **Query builder:** **cake** 🐘🪶🐬 is the only standalone multi-dialect composer (PG/SQLite/MariaDB/MySQL, BEAM + JS) with active development. MPL-2.0 license is the main caveat for shops standardising on permissive licenses.
- **Migrations:** **cigogne** 🐘 leads PostgreSQL migrations (mature, 5.0.6, hash-verified, library-bundled). **gorrion** 🐘 is an Ecto-style alternative — well-documented but one month old. **SQLite migration is a standalone gap**: every standalone candidate (migrant, storch, feather, akaridb) is disregarded — see the [Disregarded](#disregarded) table. **glimr db** 🐘🪶 covers SQLite migrations *if* you adopt the glimr framework.
- **Framework-bundled:** **glimr db** 🐘🪶 ships the Gleam ecosystem's first batteries-included DB layer (schema-diff migrations + typed query repository codegen) — the closest thing to an ORM, but framework-only.
- **Notable patterns:** Five of eleven leaderboard entries (cigogne, sqlode, cake, glimr, marmot) had a commit within ~4 days of snapshot — heavy churn in the Gleam DB space right now. Zero open issues on **gorrion**, **sqlode**, and **marmot** is a positive signal balanced by their newness; **shork** disables the GitHub Issues tab entirely (issue tracking is on Codeberg). **parrot** is the only multi-dialect codegen with a real community-size signal (207★) versus 2–3★ for the brand-new entrants.

[How scores are calculated →](#scoring-dimensions)
