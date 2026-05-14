# Environment Variables in Gleam

> [!NOTE]
> **Status:** DRAFT · **Authoring:** AI-assisted, human-reviewed. **Snapshot:** 2026-05-13.

So you want to read an env var in Gleam — pull a `DATABASE_URL`, load a `.env` file in dev, type-check a `PORT` integer, or mask an `API_KEY` before it hits your logs.

Gleam's stdlib (`gleam_stdlib`, `gleam_erlang`) does **not** expose env access. The de-facto primitive is [`envoy`](#envoy) by Louis Pilfold — a zero-dep, dual-target `get/set/unset/all` wrapper that almost every other env-related package depends on. On top of `envoy` sit four shapes of API: typed-getter-with-default, required/optional-readers, decoder-pattern, and schema-driven. Orthogonally, four packages load `.env` files (all BEAM-only because they pull `simplifile`/`gleam_erlang`), and one package — [`yodel`](#yodel) — handles config files with `${VAR}` interpolation as a different job.

If you're picking a tool for a specific job, jump to **[When to use what](#when-to-use-what)**.

> [!TIP]
> **Quick recipes — copy-paste starting points for the three most common jobs.**
>
> **1. Read a single env var (dual-target)** → [`envoy`](#envoy).
>
> ```gleam
> import envoy
> import gleam/result
>
> pub fn port() -> String {
>   envoy.get("PORT") |> result.unwrap("8080")
> }
> ```
>
> **2. Load a `.env` file in dev, then read env vars normally** → [`glenvy`](#glenvy) (loads `.env` into the process env, then use `envoy` or `glenvy/env` typed getters).
>
> ```gleam
> import glenvy/dotenv
> import glenvy/env
> import gleam/result
>
> pub fn main() {
>   let _ = dotenv.load()  // best-effort: fine if .env doesn't exist
>   let assert Ok(database_url) = env.string("DATABASE_URL")
>   // ...
> }
> ```
>
> **3. Type-check a whole app config with accumulated errors** → [`envoker`](#envoker) (built on `envoy`, structured errors per field).
>
> ```gleam
> import envoker/config
> import gleam/option.{None, Some}
>
> pub type AppConfig {
>   AppConfig(port: Int, database_url: String, debug: Bool)
> }
>
> pub fn load() -> Result(AppConfig, List(config.ConfigError)) {
>   config.load(AppConfig(port: 8080, database_url: "", debug: False), [
>     config.required_int("PORT", Some(8080)),
>     config.required_string("DATABASE_URL", None),
>     config.optional_bool("DEBUG", Some(False)),
>   ])
> }
> ```
>
> **Wrap any secret you read in [`cowl`](#secret-safety-helpers-cross-link) before passing it further** — the masking type prevents accidental log leaks.

## Table of Contents

1. [Summary](#summary)
2. [Research Method](#research-method)
   - [Scoring Dimensions](#scoring-dimensions)
   - [Discovery](#discovery)
3. [Disregarded](#disregarded)
4. [Categories](#categories)
   - [Env-Var Primitive Readers](#env-var-primitive-readers) — [envoy](#envoy) · [envoker](#envoker) · [envie](#envie) · [glenv](#glenv)
   - [`.env` File Loaders](#env-file-loaders) — [glenvy](#glenvy) · [dot_env](#dot_env) · [dotenv_gleam](#dotenv_gleam) · [dotenv_conf](#dotenv_conf)
   - [Framework-Bundled Env Modules](#framework-bundled-env-modules) — [kata_env](#kata_env) · [fiction_env](#fiction_env) · [dream_config](#dream_config)
   - [Config-as-Data with `${VAR}` Interpolation](#config-as-data-with-var-interpolation) — [yodel](#yodel)
   - [Secret-Safety Helpers (cross-link)](#secret-safety-helpers-cross-link)
5. [When to use what](#when-to-use-what)
6. [What's missing — FFI escape hatches](#whats-missing--ffi-escape-hatches)
7. [Leaderboards](#leaderboards)

## Summary

Gleam's env-var corner is **one foundational primitive (`envoy`) plus competing API shapes on top of it**, with `.env` loading split off into its own BEAM-only sub-corner.

| Category | ☎️ BEAM | 📜 JS |
| --- | --- | --- |
| **[Env-Var Primitive Readers](#env-var-primitive-readers)** | · [🥇](#leaderboards) [envoy](#envoy) ([repo](https://github.com/lpil/envoy), 52★) — *canonical; zero-dep get/set/unset/all*<br>· [envoker](#envoker) ([repo](https://github.com/redhelium/envoker), 0★) — *typed readers + structured errors on top of envoy*<br>· [envie](#envie) ([repo](https://github.com/lupodevelop/envie), 4★) — *typed-getter-with-default, .env loader, schema mode*<br>· [glenv](#glenv) ([repo](https://github.com/custompro98/glenv), 2★) — *decoder-pattern; types + variable names → record* | · [🥇](#leaderboards) [envoy](#envoy) — *dual-target via `@external`*<br>· [envoker](#envoker) — *dual via envoy*<br>· [envie](#envie) — *dual-target, zero non-stdlib deps*<br>· [glenv](#glenv) — *dual via envoy* |
| **[`.env` File Loaders](#env-file-loaders)** | · [glenvy](#glenvy) ([repo](https://github.com/maxdeviant/glenvy), 21★) — *loads `.env` + typed env getters; uses `nibble` parser*<br>· [dot_env](#dot_env) ([repo](https://github.com/aosasona/dotenv), 39★) — *builder-style pipeline; ⚠️ stale stdlib cap*<br>· [dotenv_gleam](#dotenv_gleam) ([repo](https://github.com/Grubba27/dotenv_gleam), 14★) — *straight dotenv port; envoy interop*<br>· [dotenv_conf](#dotenv_conf) ([GitLab](https://gitlab.com/amineco/dotenv_conf), ⬜★) — *`use file <- ...` callback pattern, env-first .env-fallback* | — (all four pull `simplifile`/`gleam_erlang`) |
| **[Framework-Bundled](#framework-bundled-env-modules)** † | · [kata_env](#kata_env) ([repo](https://github.com/Allianaab2m/kata-gleam), 3★) — *kata-schema env adapter; bidirectional encode/decode*<br>· [fiction_env](#fiction_env) ([Codeberg](https://codeberg.org/anactualemerald/fiction), ⬜★) — *fiction provider; layered config*<br>· [dream_config](#dream_config) ([repo](https://github.com/TrustBound/dream), 44★) — *Dream framework's config sub-package* | · [kata_env](#kata_env) — *dual via envoy* |
| **[Config-as-Data](#config-as-data-with-var-interpolation)** | · [yodel](#yodel) ([repo](https://github.com/SnakeDoc/yodel), 11★) — *JSON/YAML/TOML loader with `${VAR}` interpolation* | — |
| **[Secret-Safety (cross-link)](#secret-safety-helpers-cross-link)** | · [cowl](https://github.com/lupodevelop/cowl) — *opaque `Secret(a)` masking type*<br>· [glm_vault](https://github.com/toddg/glm_vault) — *encrypted-TOML secret storage*<br>· [redact](https://gitlab.com/ericcodes/gleam-redact) — *log-redaction wrapper* | — |

> [!IMPORTANT]
> The leaderboard ranks **competing implementations within a category**. It does **not** mean an env-var reader can substitute for a `.env` file loader, or that a config-file loader (yodel) is a worse env-var reader than envoy — they do different jobs. See [When to use what](#when-to-use-what) for job-keyed picks.

> [!NOTE]
> **† Framework-bundled** packages are only consumable inside their parent framework (`kata`, `fiction`, `dream`). They are scored on the same rubric but cannot be picked à la carte for a non-framework project.

## Research Method

### Scoring Dimensions

Same rubric as [databases.md#scoring-dimensions](databases.md#scoring-dimensions). 7 dimensions: stars, license, gleam-compat, maintenance, age, README maturity, idiomaticity. 🟥 = −1, 🟨 = 0, 🟩 = 1, 🟩🟩 = 2. Max possible = 13.

### Discovery

26 packages found across [Gleam packages registry](https://packages.gleam.run/) and GitHub (`language:gleam`) searches — **13 included** (see [Categories](#categories)), **13 disregarded** (see [below](#disregarded)).

- [env](https://packages.gleam.run/?search=env)
- [envoy](https://packages.gleam.run/?search=envoy)
- [dotenv](https://packages.gleam.run/?search=dotenv)
- [dotenvy](https://packages.gleam.run/?search=dotenvy)
- [glenvy](https://packages.gleam.run/?search=glenvy)
- [environment](https://packages.gleam.run/?search=environment)
- [getenv](https://packages.gleam.run/?search=getenv)
- [env_var](https://packages.gleam.run/?search=env_var)
- [secret](https://packages.gleam.run/?search=secret)
- [config](https://packages.gleam.run/?search=config)
- [configuration](https://packages.gleam.run/?search=configuration)
- GitHub: `language:gleam dotenv`, `language:gleam env`, `language:gleam secret`

## Disregarded

13 packages and repos surfaced via the searches above but excluded from the per-category review:

> <details>
> <summary>Stubs / learning repos / never-shipped</summary>
>
> - **[fetsh/necudat_env](https://github.com/fetsh/necudat_env)** — TODO stub. 0★, single-day creation (Sep 2025), no README content, not on Hex.
> - **horacio/env_vars**, **lucsmachado/gleam_env_vars**, **rahul-choudhury/vars**, **Avijitbera/gleamEnv**, **ollie-dot-earth/example_dot_env** — personal learning repos / CLI toys, not reusable libraries.
>
> </details>

> <details>
> <summary>Out of scope (name collision or unrelated)</summary>
>
> - **[acumen](https://packages.gleam.run/?search=acumen)** — ACME (Let's Encrypt protocol) client, not "environment" — surfaced by name collision.
> - **[directories](https://packages.gleam.run/?search=directories)** — XDG-style standard-dir paths, not env vars.
> - **embeds**, **flash**, **gacache**, **midas_node**, **tinman** — incidental "environment" word matches (compile-time embeds, structured logging, BEAM cache, midas/Node task runner, system info). Not in scope.
> - **pcl**, **sorbet** — generic config-format parsers, no env-var handling.
> - **shamir** — Shamir Secret Sharing crypto primitive (AGPL-3.0), not secret-loading.
>
> </details>

## Categories

### Env-Var Primitive Readers

Read individual environment variables at runtime. All four are **dual-target** (BEAM + JS) and all four (except envie) build on [`envoy`](#envoy) as the underlying syscall wrapper.

| Criterion | [envoy](https://github.com/lpil/envoy) [🥇](#leaderboards) | [envoker](https://github.com/redhelium/envoker) | [envie](https://github.com/lupodevelop/envie) | [glenv](https://github.com/custompro98/glenv) |
| --- | --- | --- | --- | --- |
| Stars | 52★ · 🟨 | 0★ · 🟥 | 4★ · 🟥 | 2★ · 🟥 |
| License | Apache-2.0 · 🟩 | Apache-2.0 · 🟩 | MIT · 🟩 | Apache-2.0 · 🟩 |
| Target | ☎️📜 dual | ☎️📜 dual (via envoy) | ☎️📜 dual | ☎️📜 dual (via envoy) |
| Deps | 1 (`gleam_stdlib`) | 2 (+ envoy) | 1 (`gleam_stdlib`) | 2 (+ envoy) |
| Gleam compat | `>= 0.34 and < 2.0` · 🟩 | `>= 0.44 and < 2.0` · 🟩 | `>= 0.44 and < 2.0` · 🟩 | `>= 0.34 and < 2.0` · 🟩 |
| Maintenance | 🟩 (last push 2026-04-18, 0 issues) | 🟩🟩 (last push 2026-04-07, 0 issues) | 🟩🟩 (last push 2026-04-27, 0 issues) | 🟨 (last push 2025-04-25, 0 issues) |
| Age | ~2.4 years (Dec 2023) · 🟩 | ~1.5 months (Mar 2026) · 🟥 | ~2.5 months (Mar 2026) · 🟥 | ~1.9 years (Jul 2024) · 🟩 |
| README maturity | 🟩 (tagline + 4-fn example) | 🟩🟩 (feature list + basic/advanced examples + error type docs) | 🟩🟩 (feature list + strict validators + schema mode + testing helpers) | 🟩 (feature list + prose) |
| Idiomaticity | 🟩 (minimal, untyped, `Result(_, Nil)`) | 🟩 (typed readers, structured errors, decode-many error accumulation) | 🟩 (typed-getter-with-default, composable decoders) | 🟩 (decoder pattern, validated record) |
| | | | | |
| **Features** | | | | |
| Raw `get/set/unset/all` | ✅ | — (delegates) | — (uses own `@external`) | — (delegates) |
| Typed getters (Int/Bool/Float) | — | ✅ required + optional | ✅ getter-with-default | ✅ via decoder |
| Defaults / fallback values | — | ✅ explicit Option | ✅ second arg | — (errors if missing) |
| Required vs optional | — | ✅ separate functions | ✅ via decoder choice | ✅ via decoder shape |
| Structured errors | — | ✅ `Missing`/`Empty`/`Parse` | — (returns default on error) | ✅ generic decode error |
| Multi-field error accumulation | — | ✅ `config.load` | ✅ schema mode | — |
| `.env` file loading | — | — | ✅ multi-file priority | — |
| Bidirectional (encode + decode) | — | — | — | — |

#### envoy
[repo](https://github.com/lpil/envoy) · [🥇](#leaderboards)

The canonical primitive. Zero deps beyond `gleam_stdlib`, dual-target via `@external(erlang, ...)` and `@external(javascript, ...)`. API surface is four functions: `get/1`, `set/2`, `unset/1`, `all/0`. All values are strings; `get` returns `Result(String, Nil)`.

Five of the other packages in this article (`envoker`, `glenv`, `dotenv_gleam`, `kata_env`, `yodel`) depend on it. If you're writing a library that needs env access, depend on `envoy` rather than rolling your own externals — readers expect the canonical path.

```gleam
import envoy
import gleam/result

pub fn database_url() -> String {
  envoy.get("DATABASE_URL")
  |> result.unwrap("postgres://localhost/dev")
}
```

#### envoker
[repo](https://github.com/redhelium/envoker)

Typed wrapper over `envoy` with structured errors. Two layers: per-call readers (`read_required_string`, `read_optional_int`, …) that return `Result(T, ConfigError)`, and a declarative `envoker/config` module that loads many fields at once and accumulates errors across all of them — useful when you want to surface every missing/invalid env var in one error message rather than failing at the first one.

```gleam
import envoker/config
import gleam/option.{None, Some}

pub type AppConfig {
  AppConfig(port: Int, database_url: String, debug: Bool)
}

pub fn load() -> Result(AppConfig, List(config.ConfigError)) {
  config.load(AppConfig(port: 8080, database_url: "", debug: False), [
    config.required_int("PORT", Some(8080)),
    config.required_string("DATABASE_URL", None),
    config.optional_bool("DEBUG", Some(False)),
  ])
}
```

#### envie
[repo](https://github.com/lupodevelop/envie)

Most feature-rich single package in the corner. Zero non-stdlib deps (reimplements env access via `@external` rather than depending on `envoy`). Typed-getter-with-default API, strict validators (`require_port`, `require_url`, `require_range`, `require_allowlist`), composable decoders, multi-file `.env` priority loading, opt-in schema mode, testing helpers that auto-restore env state, and a debug `inspect` mode.

```gleam
import envie

pub fn main() {
  let port = envie.get_int("PORT", 3000)
  let host = envie.get_string("HOST", "localhost")
  // ...
}
```

> [!NOTE]
> **Pairs with [`cowl`](#secret-safety-helpers-cross-link)** — both by the same author (`lupodevelop`), both created March 2026, designed to compose (`envie` reads env safely, `cowl` masks the result before logging). See the [cross-link section](#secret-safety-helpers-cross-link).

#### glenv
[repo](https://github.com/custompro98/glenv)

Decoder-pattern: define variable names + types up front, call `glenv.load()` to get a validated record back. Booleans parse `true/yes/1` (case-insensitive). Mature for the corner (~1.9 years), low star count (2★), maintenance is 🟨 (last push April 2025 — over a year stale).

### `.env` File Loaders

Read `.env` files from disk and populate the process environment. All four are **BEAM-only** (they pull `simplifile` and/or `gleam_erlang` for file I/O and regex). If you're targeting JavaScript and need `.env` support, see [`envie`](#envie) (which loads `.env` via its own dual-target file-reader).

| Criterion | [glenvy](https://github.com/maxdeviant/glenvy) | [dot_env](https://github.com/aosasona/dotenv) | [dotenv_gleam](https://github.com/Grubba27/dotenv_gleam) | [dotenv_conf](https://gitlab.com/amineco/dotenv_conf) |
| --- | --- | --- | --- | --- |
| Stars | 21★ · 🟨 | 39★ · 🟨 | 14★ · 🟨 | ⬜ (GitLab) |
| License | MIT · 🟩 | Apache-2.0 · 🟩 | MIT · 🟩 | ⬜ |
| Target | ☎️ BEAM | ☎️ BEAM | ☎️ BEAM | ☎️ BEAM |
| Deps | 4 | 2 | 4 | — (no GitHub mirror) |
| Gleam compat | `>= 0.62 and < 2.0` · 🟩 | `>= 0.40 and < 1.0.0` · 🟥 | `~> 0.36` · 🟥 | ⬜ |
| Maintenance | 🟨 (last push 2025-07-30, 0 issues) | 🟨 (last push 2025-09-09, 2 issues) | 🟨 (last push 2025-10-13, 1 issue) | 🟥 (last release v0.2.0 ~1 year stale) |
| Age | ~3 years (May 2023) · 🟩🟩 | ~2.5 years (Oct 2023) · 🟩 | ~2.5 years (Oct 2023) · 🟩 | ~1.3 years (Jan 2025) · 🟩 |
| README maturity | 🟩 (tagline + canonical example) | 🟩 (builder-style example) | 🟩 (feature list + envoy interop example) | 🟩 (via hexdocs only — no GitHub README) |
| Idiomaticity | 🟩 (loads + typed getters) | 🟩 (builder/pipe) | 🟩 (loads to process env; users call envoy) | 🟩 (`use` callback pattern) |

> [!CAUTION]
> **`dot_env` has a stale `gleam_stdlib < 1.0.0` cap.** Verified by reproducing: in a fresh project using `gleam_stdlib 1.x` (e.g., one that also depends on `gleam_json`), the resolver silently downgrades `dot_env` to v0.5.1 (from 2024) instead of the latest v1.2.0. The newest features and fixes won't apply. Upstream needs to bump the constraint. Same shape as the `deriv`/`gleam_json` bug noted in [serialization/codegen-json.md#deriv](serialization/codegen-json.md#deriv).

#### glenvy
[repo](https://github.com/maxdeviant/glenvy)

Two modules: `glenvy/dotenv` (loads `.env` files into the process env via `simplifile` + `nibble` parser) and `glenvy/env` (typed getters: `env.string/int/bool/float` returning `Result(T, _)`). Composes naturally — load the file at startup, then read typed values throughout the app.

```gleam
import glenvy/dotenv
import glenvy/env
import gleam/result

pub fn main() {
  let _ = dotenv.load()
  use database_url <- result.try(env.string("DATABASE_URL"))
  use port <- result.try(env.int("PORT"))
  // ...
}
```

#### dot_env
[repo](https://github.com/aosasona/dotenv)

Highest-starred `.env` loader (39★). Builder-style pipeline. Provides its own `env.get_string` rather than delegating to envoy. See the [stale-cap caution above](#env-file-loaders).

```gleam
import dot_env as dot
import dot_env/env

pub fn main() {
  dot.new()
  |> dot.set_path("path/to/.env")
  |> dot.load
  // ...
  let assert Ok(url) = env.get_string("DATABASE_URL")
}
```

#### dotenv_gleam
[repo](https://github.com/Grubba27/dotenv_gleam)

Straight `dotenv` port — loads `.env` into the process env (via `envoy.set`), users retrieve values with `envoy.get` afterwards. `config_with(path)` for custom paths. `gleam_stdlib ~> 0.36` constraint is the legacy non-range style (🟥), and may cause resolver conflicts in modern projects.

#### dotenv_conf
[Hex](https://hex.pm/packages/dotenv_conf) (GitLab-hosted, no GitHub mirror)

Different shape: `use file <- dotenv_conf.read_file(".env")`, then `read_string_or`/`read_int_or` with explicit defaults. Reads from the OS env *first*, falls back to the `.env` file if the var isn't set. Useful when you want `.env` as a default-overrides file rather than the primary source. Stars and license aren't surfaced via WebFetch (GitLab); maintenance is 🟥 (v0.2.0 from Jan 2025, no updates since).

### Framework-Bundled Env Modules

These packages are only consumable inside their parent framework. Scored on the same 7-dim rubric but not picked à la carte. Listed for auditability — readers using these frameworks already have env-var access built in.

#### kata_env
[repo](https://github.com/Allianaab2m/kata-gleam) (monorepo, `kata_env` package)

Schema-driven adapter for the [`kata`](https://hex.pm/packages/kata) bidirectional-schema framework. Define a `kata` schema with `kata.field("PORT", coerce.int(), ...)`, then `kata_env.decode(schema)` reads + validates. Errors as `SchemaError(List(kata.Error))`. The only package in this article that supports **encoding** a typed record back to env-var pairs (via `format()`) — useful if you want to derive the env-var pairs to pass to a child process or container.

| Criterion | [kata_env](https://github.com/Allianaab2m/kata-gleam) |
| --- | --- |
| Stars | 3★ (whole repo) · 🟥 |
| License | MIT · 🟩 |
| Target | ☎️📜 dual (via envoy) |
| Deps | 3 (`gleam_stdlib`, `envoy`, `kata`) |
| Gleam compat | `>= 1.0 and < 2.0` · 🟩 |
| Maintenance | 🟩🟩 (last push 2026-04-25, 1 issue) |
| Age | ~1 year · 🟩 |
| README maturity | 🟥 at package level (TODO), but 🟩🟩 in source docstring |
| Idiomaticity | 🟩 (schema-driven, bidirectional) |

#### fiction_env
[Codeberg](https://codeberg.org/anactualemerald/fiction) (monorepo, `fiction_env` package)

A provider plug for [`fiction`](https://hex.pm/packages/fiction) — a Figment-inspired layered-config orchestrator (TOML + JSON + env, merged in priority order). API: `env.prefixed("APP_")` collects + lowercases prefixed vars; `env.exact(["PORT", "HOST"])` collects named vars. Composes with TOML/JSON providers via `fiction.join`/`fiction.merge`, then `fiction.extract(with: decoder())` materializes to a typed record.

```gleam
import fiction
import fiction_env as env
import fiction_toml as toml

pub fn load_config() {
  fiction.new()
  |> fiction.join(toml.file("./priv/app.toml"))
  |> fiction.merge(env.exact(["PORT", "DATABASE_URL"]))
  |> fiction.extract(with: my_decoder())
}
```

| Criterion | [fiction_env](https://codeberg.org/anactualemerald/fiction) |
| --- | --- |
| Stars | ⬜ (Codeberg) |
| License | ⬜ (multiple per LICENSES dir) |
| Target | ☎️ BEAM (via fiction) |
| Gleam compat | not surfaced |
| Maintenance | 🟩🟩 (last commit 2026-04-01) |
| Age | ~6 months · 🟨 |
| README maturity | 🟩 |
| Idiomaticity | 🟩 (provider pattern) |

#### dream_config
[repo](https://github.com/TrustBound/dream) (`dream`, `modules/config`)

Config sub-package shipped with the [`dream`](web-and-http/web-apps.md#dream) web framework. Typed env/.env reader using stdlib only — `config.load_dotenv()`, `config.get_required("DATABASE_URL")`, `config.get_required_int`, `config.get_bool`. Booleans accept `true/yes/1` case-insensitively.

| Criterion | [dream_config](https://github.com/TrustBound/dream) |
| --- | --- |
| Stars | 44★ (whole dream repo) · 🟨 |
| License | MIT · 🟩 |
| Target | ☎️ BEAM |
| Gleam compat | `>= 0.44 and < 2.0` · 🟩 |
| Maintenance | 🟩🟩 (last push 2026-03-28) |
| Age | ~5 months · 🟨 |
| README maturity | 🟩 (module-level via hexdocs) |
| Idiomaticity | 🟩 (imperative `Result` style) |

### Config-as-Data with `${VAR}` Interpolation

A different job: load a config **file** (JSON/YAML/TOML) and let env vars be interpolated inside it. The env var is a value, not the primary source.

#### yodel
[repo](https://github.com/SnakeDoc/yodel)

JSON/YAML/TOML auto-detection by extension. `${VAR}`, `${VAR:default}`, and nested `${VAR1:${VAR2:fallback}}` interpolation inside the config file. Strict-mode (`with_resolve_strict`) fails if any `${VAR}` is unresolved. Load file → query by dotted path (`yodel.get_string(config, "database.host")`).

```yaml
# config.yaml
database:
  host: ${DATABASE_HOST:localhost}
  port: ${DATABASE_PORT:5432}
```

```gleam
import yodel

pub fn main() {
  let assert Ok(config) = yodel.load("config.yaml")
  let assert Ok(host) = yodel.get_string(config, "database.host")
  // ...
}
```

| Criterion | [yodel](https://github.com/SnakeDoc/yodel) |
| --- | --- |
| Stars | 11★ · 🟨 |
| License | Apache-2.0 · 🟩 |
| Target | ☎️ BEAM (uses `simplifile`, `glaml`, `tom`) |
| Deps | 7 |
| Gleam compat | `>= 1.0 and < 2.0` · 🟩 |
| Maintenance | 🟩🟩 (last push 2026-05-12 — day before snapshot) |
| Age | ~1.5 years (Oct 2024) · 🟩 |
| README maturity | 🟩🟩 (comprehensive: format auto-detect, interpolation modes, strict mode) |
| Idiomaticity | 🟩 (load → query by path) |

### Secret-Safety Helpers (cross-link)

These don't read env vars themselves — they help you **handle secrets safely after you've read them**. Cross-linked here because the typical pattern is:

```gleam
import cowl
import envoy
import gleam/result

pub fn api_key() -> cowl.Secret(String) {
  envoy.get("STRIPE_API_KEY")
  |> result.unwrap("")
  |> cowl.labeled("stripe_api_key")  // mask before passing further
}
```

> [!IMPORTANT]
> **Never `io.println` or pass a raw secret to a logger.** Wrap it in `cowl.Secret` (or `redact`'s equivalent) immediately after reading. The masking type prevents accidental log leaks via `string.inspect`, `io.debug`, structured logging metadata, etc.

- **[lupodevelop/cowl](https://github.com/lupodevelop/cowl)** — opaque `Secret(a)` masking type for logs. 2★ MIT, last push 2026-04-17. Pairs with [`envie`](#envie) by design (same author).
- **[toddg/glm_vault](https://github.com/toddg/glm_vault)** — encrypted-TOML-on-disk secret storage, ansible-vault style. 0★ Apache-2.0, last push 2026-05-04. For *storing* secrets on disk, not *reading env vars*.
- **[ericcodes/redact](https://gitlab.com/ericcodes/gleam-redact)** — log-redaction wrapper. Apache-2.0, v1.0.1, GitLab-hosted. Same role as `cowl`.

## When to use what

Pick by **the job you're doing**, not by the global leaderboard score. The categories aren't substitutable — a `.env` loader cannot type-check a config; a primitive reader cannot interpolate inside a YAML file.

| Job | Recommended | Why |
| --- | --- | --- |
| **Read one env var, dual-target (BEAM + JS)** | [`envoy`](#envoy) | Canonical, zero-deps, four functions. No reason to use anything else for the simple case. |
| **Read one env var, with type coercion + default** | [`envie`](#envie) (dual) or [`envoker`](#envoker) (dual via envoy) | Typed getter with a default in the same call. Envie zero-deps; envoker has structured errors. |
| **Read a full app config; surface all errors at once** | [`envoker/config`](#envoker) | Decode-many error accumulation — every missing/invalid env var reported, not just the first. |
| **Load `.env` in dev, target BEAM, then read normally** | [`glenvy`](#glenvy) | Cleanest split (`dotenv.load` + typed `env.string/int/bool`). 21★, MIT, sane deps. |
| **Load `.env` in dev, target JavaScript** | [`envie`](#envie) | Only dual-target package with `.env` loading. |
| **Type-check + bidirectional encode/decode of env pairs** | [`kata_env`](#kata_env) | Only package with `format()` (typed record → env pairs). Niche — useful for spawning child processes with derived envs. |
| **Layered config: TOML file + env overrides** | [`fiction_env`](#fiction_env) (in a fiction-based app) | Provider chain pattern. |
| **YAML/TOML/JSON config with `${VAR}` interpolation** | [`yodel`](#yodel) | Different job from env-var reading. Use when your config lives in a file and env vars are *values*, not the primary source. |
| **Mask secrets before logging** | [`cowl`](#secret-safety-helpers-cross-link) or [`redact`](#secret-safety-helpers-cross-link) | Opaque type prevents accidental leaks. Wrap *every* secret you read. |
| **Store secrets encrypted on disk** | [`glm_vault`](#secret-safety-helpers-cross-link) | Ansible-vault style. Not env-var related, but the adjacent job. |
| **Read secrets from AWS/GCP/Vault** | FFI to Erlang/Elixir — see [What's missing](#whats-missing--ffi-escape-hatches) | No native Gleam wrapper for cloud secret managers. |

> [!IMPORTANT]
> **`envoy` is foundational, not a competitor to the others.** If you depend on `envoker`, `glenv`, `dotenv_gleam`, `kata_env`, or `yodel`, you already have `envoy` in your dep tree transitively. Direct use of `envoy.get` is fine alongside any of them.

## What's missing — FFI escape hatches

Gleam has solid coverage for the basics (read, parse, type-check). The gaps are mostly **cloud-secret-manager** and **dotenv-vault-style encrypted secret loading**. For each capability gap, the canonical Erlang/Elixir Hex package to FFI to:

| Capability | Gleam? | FFI to (Erlang/Elixir) |
| --- | --- | --- |
| **AWS Secrets Manager** | None | `:ex_aws_secretsmanager`, `:aws_secretsmanager` (aws-beam) — call via `@external(erlang, ...)` |
| **AWS Parameter Store (SSM)** | None | `:ex_aws_ssm` |
| **GCP Secret Manager** | None | `:google_api_secret_manager` + `:goth` for auth |
| **HashiCorp Vault** | None | `:vaultex`, `:libvault` |
| **Azure Key Vault** | None | `:azurex`, `:azure_key_vault` |
| **Encrypted `.env` (dotenv-vault / SOPS style)** | Partial — `glm_vault` does ansible-vault style on-disk, but **no** `.env.vault` reader and **no** SOPS-compatible decryptor | `:sops` via shell-out; no first-class Erlang/Elixir `dotenv-vault` either — true ecosystem-wide gap |
| **OTP `application:get_env/2` (per-app config)** | None directly — Gleam env access is always OS-global via `envoy` | `:application.get_env/2,3`, `:application.set_env/3` — FFI with `@external(erlang, "application", "get_env")` |
| **Schema-doc / `--help`-from-schema generation** | None | Elixir `:vapor` generates docs; closest Gleam adjacency is [`glint`](cli.md#glint)/[`clip`](cli.md#clip) for **CLI flags** (not env vars) |
| **Hot-reload of `.env` in dev** | None | Elixir `:dotenvy` + `:file_system` watcher |
| **Typed schemas with accumulated errors across multiple sources** | Partial — [`envoker/config`](#envoker), [`envie`](#envie)'s schema mode, [`kata_env`](#kata_env), and [`fiction`](#fiction_env)'s provider chain cover most cases; no `:vapor`-equivalent multi-source decoder | `:vapor`, `:nimble_options`, `:specify_config`, `:confex` |
| **Per-process env scopes** | None — OS env is process-tree-global | OTP `:application` env (per-app) or process dictionary (per-process); both via FFI |

## Leaderboards

Per-category leaderboards because the categories are **not substitutable** (see [the IMPORTANT callout](#summary)). 🟥 = −1, 🟨 = 0, 🟩 = 1, 🟩🟩 = 2. Max possible = 13.

### Env-Var Primitive Readers

| Rank | Package | Score | Highlights |
| --- | --- | --- | --- |
| 🥇 | [envoy](#envoy) | **9** | Canonical · zero-dep · dual-target · 52★ · used by 5+ packages in this article |
| 🥈 | [envoker](#envoker) | **8** | Typed readers + structured errors + multi-field error accumulation · 🟩🟩 maintenance · 🟩🟩 README |
| 🥉 | [envie](#envie) | **7** | Most feature-rich (strict validators, .env loading, schema mode, testing helpers) · zero non-stdlib deps · 🟩🟩 maintenance · 🟩🟩 README · young (🟥 age, 🟥 stars) |
| 4 | [glenv](#glenv) | **5** | Decoder-pattern · mature (~1.9 years) · maintenance gone stale (🟨, last push Apr 2025) |

### `.env` File Loaders

| Rank | Package | Score | Highlights |
| --- | --- | --- | --- |
| 🥇 | [glenvy](#glenvy) | **8** | Cleanest API split (`dotenv.load` + typed `env.string/int/bool`) · 🟩🟩 age (~3 years) · 21★ |
| 🥈 | [dot_env](#dot_env) | **3** | Highest stars (39★) · ⚠️ stale `gleam_stdlib < 1.0.0` cap silently downgrades to v0.5.1 in modern projects |
| 🥉 | [dotenv_gleam](#dotenv_gleam) | **3** | Straight dotenv port · envoy interop · 🟥 gleam-compat (`~>` style) |
| 4 | [dotenv_conf](#dotenv_conf) | **n/a** | Env-first / .env-fallback shape · GitLab-hosted (stars/license ⬜) · 🟥 stale (~1 year) |

### Framework-Bundled

Not directly comparable — only usable inside their parent framework. Listed in order of repo activity.

| Package | Parent framework | Highlights |
| --- | --- | --- |
| [kata_env](#kata_env) | [`kata`](serialization/runtime-bidirectional-json.md#kata) | Schema-driven, bidirectional (encode + decode), dual-target |
| [fiction_env](#fiction_env) | [`fiction`](https://hex.pm/packages/fiction) | Layered-config provider; composes with TOML/JSON |
| [dream_config](#dream_config) | [`dream`](web-and-http/web-apps.md#dream) | Stdlib-only, imperative Result style, dotenv loader bundled |

### Config-as-Data

Single entrant.

| Rank | Package | Score | Highlights |
| --- | --- | --- | --- |
| 🥇 | [yodel](#yodel) | **9** | JSON/YAML/TOML auto-detect · `${VAR}` interpolation incl. nested + defaults · 🟩🟩 maintenance · 🟩🟩 README |
