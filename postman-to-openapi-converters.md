# Postman → OpenAPI converters

> [!NOTE]
> **Status:** DRAFT · **Authoring:** AI-assisted, human-reviewed.

You have a Postman collection.
You want an OpenAPI spec.
None of the tools that promise to do this are actively maintained — but some still produce useful output. This document tests them on a real-world collection and ranks the results.

## TL;DR

| If you want… | Use |
| --- | --- |
| **The cleanest, most spec-valid output** with sensible defaults (tags from folders, bearer auth detected) | **[joolfe/postman-to-openapi](#joolfepostman-to-openapi-best-overall)** |
| **Inferred request/response schemas** for code generation (operationIds + properties, not just examples) | **[kevinswiber/postman2openapi](#kevinswiberpostman2openapi-best-for-codegen-input)** |
| **Reusable components / `$ref`** + JSON-schema-inferred response schemas | **[codeasashu/openman](#codeasashuopenman-best-for-component-extraction)** |
| **Skip these** | levoai/postman-to-openapi, tecfu/postman-to-swagger |

> [!IMPORTANT]
> Every tool tested is unmaintained. Most recent commit across the field: 2024-12 (joolfe). Median: ~3 years stale. Treat output as a starting point, not a finished spec. Plan to hand-edit.

> [!NOTE]
> Postman itself ships a [Transform Collection to OpenAPI](https://www.postman.com/postman/postman-public-workspace/request/vyyh2ga/transform-collection-to-openapi) endpoint that requires a Postman API key. It's the most authoritative converter (Postman owns both formats) but is a SaaS dependency, not a local CLI, and not tested here. Use it if you can.

## Table of Contents

1. [Test Setup](#test-setup)
2. [Discovery](#discovery)
3. [Quantitative Comparison](#quantitative-comparison)
4. [Tool-by-tool Review](#tool-by-tool-review)
   - [joolfe/postman-to-openapi](#joolfepostman-to-openapi-best-overall)
   - [kevinswiber/postman2openapi](#kevinswiberpostman2openapi-best-for-codegen-input)
   - [codeasashu/openman](#codeasashuopenman-best-for-component-extraction)
   - [levoai/postman-to-openapi](#levoaipostman-to-openapi-skip)
   - [tecfu/postman-to-swagger](#tecfupostman-to-swagger-skip)
   - [Browser-only / SaaS](#browser-only--saas)
5. [Recommendation by use case](#recommendation-by-use-case)

## Test Setup

**Input:** [`Notion API.postman_collection.json`](./Notion%20API.postman_collection.json) — Notion's official Postman collection (Postman v2.1 schema, ~853 KB, 25 top-level items, 13 unique paths, 19 operations across 6 folders, bearer auth via `{{NOTION_TOKEN}}`, mix of GET/POST/PATCH/DELETE, JSON request bodies with deeply nested examples).

**Snapshot date:** 2026-04-18.

**Validation:** [`@redocly/cli`](https://redocly.com/docs/cli) lint with default rules.

**Reproduce:**

```sh
mkdir -p /tmp/p2o-test && cd /tmp/p2o-test
cp "<repo>/Notion API.postman_collection.json" notion.json
npm install postman-to-openapi postman-to-swagger @redocly/cli
cargo install postman2openapi-cli
python3 -m pip install --user openman 'flask<2.3'  # openman has a Flask incompatibility on 2.3+

./node_modules/.bin/p2o notion.json -f notion.joolfe.yaml
postman2openapi notion.json -f yaml > notion.kevinswiber.yaml
openman convert notion.json notion.openman.yaml
# levoai requires cloning + an options.json file in cwd; see review below.

for f in notion.*.yaml; do
  ./node_modules/.bin/redocly lint "$f" --max-problems=999
done
```

## Discovery

Tools found via web search and GitHub. Filter: must convert Postman v2.x → OpenAPI v3.x and run as a local CLI or library.

| Tool | Lang | Stars | License | Last commit | Status |
| --- | --- | --- | --- | --- | --- |
| **[joolfe/postman-to-openapi](https://github.com/joolfe/postman-to-openapi)** | Node | 648★ | MIT | 2024-12-27 | Stale (~16 months) |
| **[kevinswiber/postman2openapi](https://github.com/kevinswiber/postman2openapi)** | Rust | 419★ | Apache-2.0 | 2024-07-03 | Stale (~21 months) |
| **[tecfu/postman-to-swagger](https://github.com/tecfu/postman-to-swagger)** | Node | 44★ | MIT | 2023-03-04 | Stale (~3 years); wraps joolfe |
| **[codeasashu/openman](https://github.com/codeasashu/openman)** | Python | 21★ | none | 2023-05-03 | Stale (~3 years) |
| **[levoai/postman-to-openapi](https://github.com/levoai/postman-to-openapi)** | Python | 1★ | Apache-2.0 | 2023-02-21 | Stale (~3 years); wraps joolfe |
| **[rishipurwar1/postman-to-openapi-cli](https://github.com/rishipurwar1/postman-to-openapi-cli)** | Node | — | — | — | Wrapper of joolfe — not separately tested |
| **[Postman official "Transform Collection to OpenAPI"](https://www.postman.com/postman/postman-public-workspace/request/vyyh2ga/transform-collection-to-openapi)** | SaaS | — | — | live | Requires Postman API key |
| **[p2o (defcon007)](https://p2o.defcon007.com/)** | Browser | — | — | live | Browser-only; client-side conversion |

**Disregarded:** `postmanlabs/openapi-to-postman` (wrong direction); `grokify/spectrum` (wrong direction).

## Quantitative Comparison

All four locally-installable converters were run on the same 853 KB Notion collection. Each produced 13 paths / 19 operations — they all see the same surface area. The differences are in *what they put inside each operation*.

| Metric | [joolfe](#joolfepostman-to-openapi-best-overall) | [kevinswiber](#kevinswiberpostman2openapi-best-for-codegen-input) | [openman](#codeasashuopenman-best-for-component-extraction) | [levoai](#levoaipostman-to-openapi-skip) |
| --- | --- | --- | --- | --- |
| **Runtime required** | Node.js (≥14) | precompiled binary, or Rust/Cargo to build | Python 3 + pip | Python 3 + pip **and** Node.js (calls joolfe) |
| **Ease of use** | 🟩🟩 single `npm i -g`, one positional arg | 🟩 download binary or `cargo install` (longer first install) | 🟨 pip install works, but ships broken on Flask ≥2.3 — must pin `'flask<2.3'` | 🟥 not on PyPI; clone repo, copy bundled `options.json` into cwd, run script |
| OpenAPI version emitted | 3.0.0 | 3.0.3 | 3.0.0 | 3.0.0 |
| Output size | 446 KB | 609 KB | 708 KB | 439 KB |
| `info.title` correct | ✅ "Notion API" | ✅ "Notion API" | ✅ "Notion API" | ❌ "Options title" (leak) |
| Server URL detected | ✅ | ✅ | ❌ (empty) | ✅ |
| Tags from folders | ✅ (6) | ✅ (6) | ❌ (0) | ❌ (0; "default") |
| Security scheme detected | ✅ bearer | ✅ bearer | ❌ | ❌ |
| `operationId` per op | ❌ (0) | ✅ (19) | ✅ (19) | ❌ (0) |
| Inline `requestBody` schema | example-only | **inferred properties** | example-only | example-only |
| `components.schemas` (reusable) | 0 | 0 | **25** | 0 |
| `$ref` usage (component reuse) | 0 | 0 | **48** | 0 |
| Redocly lint errors | **2** (cosmetic) | 71 | 22 | 21 |
| Redocly lint warnings | 86 | 139 | 456 | 86 |

**Reading the table:** no single tool wins every column. joolfe is the easiest to install *and* the most spec-correct; kevinswiber is the only one that infers per-operation request properties (instead of dumping the example as `type: object`); openman is the only one that extracts reusable components and links them with `$ref` — but its install is fragile (Flask version pin) and it has no license. levoai contributes nothing the others don't and is the hardest to run. **Pick by which runtime you already have on hand**, then by output need.

## Tool-by-tool Review

### joolfe/postman-to-openapi — best overall

[repo](https://github.com/joolfe/postman-to-openapi) · [docs](https://joolfe.github.io/postman-to-openapi/) · MIT · 648★ · last commit 2024-12-27

The default choice. Cleanest output, fewest spec violations (only 2 errors in the Notion collection — both `no-path-trailing-slash` warnings about `/v1/databases/` and `/v1/pages/`, which the source collection actually has). Detects bearer auth from `{{NOTION_TOKEN}}` headers, lifts Postman folders to OpenAPI tags, preserves Postman-format variables (`{{USER_ID}}`) as path-parameter examples.

**Trade-off:** request/response bodies become `schema: type: object` with the full payload dumped into `example:`. No property inference, no `operationId`. Useful for documentation; not directly usable as a codegen contract.

```yaml
# joolfe sample — POST /v1/pages
post:
  tags: [Pages]
  summary: Create a page with content
  requestBody:
    content:
      application/json:
        schema:
          type: object
          example:           # <-- full nested example, no properties
            parent: {database_id: '{{DATABASE_ID}}'}
            properties: {...}
```

**Install & run:**
```sh
npm install -g postman-to-openapi
p2o ./collection.json -f ./openapi.yaml
# optional: -o options.json to override info.title, server URLs, etc.
```

### kevinswiber/postman2openapi — best for codegen input

[repo](https://github.com/kevinswiber/postman2openapi) · [browser version](https://kevinswiber.github.io/postman2openapi/) · Apache-2.0 · 419★ · last commit 2024-07-03

The only tool that runs the request/response examples through schema inference and emits `properties` inline (not just `example:`). Also emits `operationId`, `summary`, and `description` per operation. Makes the output substantially more useful as a contract for codegen tools (e.g. [oaspec](gleam/parse-and-generate-other-languages.md#oaspec) or openapi-generator).

**Trade-off:** 71 lint errors. The largest cluster is `nullable-type-sibling` — `nullable: true` is emitted without an accompanying `type:`, which OpenAPI 3.0 explicitly forbids and which most validators reject. Generated code from strict generators will refuse this output until you fix it (sed-able). Also: array-item examples occasionally violate the inferred type (`type: integer` with a string example).

```yaml
# kevinswiber sample — POST /v1/pages
post:
  tags: [Pages]
  summary: Create a page
  operationId: createAPage          # <-- bonus
  requestBody:
    content:
      application/json:
        schema:
          type: object
          properties:               # <-- inferred from example payload
            children:
              type: array
              items:
                type: object
                properties:
                  heading_2: { type: object, properties: {...} }
                  object: { type: string, example: block }
```

**Install & run:**
```sh
cargo install postman2openapi-cli   # or download binary from GitHub releases
postman2openapi ./collection.json -f yaml > ./openapi.yaml
```

### codeasashu/openman — best for component extraction

[repo](https://github.com/codeasashu/openman) · [PyPI](https://pypi.org/project/Openman/) · no license · 21★ · last commit 2023-05-03

The only tool that extracts response payloads into reusable `components.schemas` and links them via `$ref` (48 refs in the Notion output). Uses [`genson`](https://pypi.org/project/genson/) to infer JSON schemas from saved responses, including `allOf` merging when an endpoint has multiple response samples. If you care about reuse — same `Page` schema referenced from multiple operations — this is the only converter that does it.

**Trade-offs:**
- **No license file.** Don't ship anything that depends on it without legal review; treat it as a one-shot generator.
- **Empty `servers:`** — you'll need to add the host manually.
- **No security scheme detected** (every operation is unauthenticated in the output).
- **No tags** (everything goes in the unsorted root).
- **Auto-named schemas:** `schemaV1BlocksIdChildrenGet200` — unique but ugly. Plan to rename.
- **Flask compatibility break on install:** the `connexion` dependency uses `flask.json.JSONEncoder`, removed in Flask 2.3. Pin `'flask<2.3'` when installing.

```yaml
# openman sample — POST /v1/pages
post:
  operationId: V1PagesPost
  requestBody:
    content:
      application/json:
        example: { value: {...} }
  responses:
    '200':
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/schemaV1PagesPost200'   # <-- reuse
components:
  schemas:
    schemaV1PagesPost200:
      type: object
      properties: { ... }   # <-- merged from all sample responses via allOf
```

**Install & run:**
```sh
python3 -m pip install --user openman 'flask<2.3'
openman convert ./collection.json ./openapi.yaml
```

### levoai/postman-to-openapi — skip

[repo](https://github.com/levoai/postman-to-openapi) · Apache-2.0 · 1★ · last commit 2023-02-21

A Python wrapper that calls joolfe's `p2o` CLI per Postman item, then merges results. Adds an "enrich" step (split into multiple files, fix missing path params, normalize undefined status codes to 200). In practice on the Notion collection: produces an output with `info.title: "Options title"` (leaks the example metadata from `options.json`), drops tags, drops the security scheme. The enrichment step is the only thing of substance and you can apply equivalent fixes manually to a joolfe-produced spec in less time than installing levoai.

**Why it's broken on real input:** levoai requires an `options.json` file in the working directory. Without one, it errors out. With its bundled example `options.json`, the example metadata (title, description, version) overrides whatever was in the collection.

Skip; use joolfe directly.

### tecfu/postman-to-swagger — skip

[repo](https://github.com/tecfu/postman-to-swagger) · MIT · 44★ · last commit 2023-03-04

Wraps joolfe and adds remote-collection fetching via the Postman API. If your collection is already a local file, this adds no value — output is identical to joolfe's. Use it only if you want to fetch a private cloud collection by ID without leaving the shell.

```sh
npx postman-to-swagger --postmanApiKey="<key>" --collectionId="<id>" --output="./openapi.yaml"
```

### Browser-only / SaaS

- **[p2o.defcon007.com](https://p2o.defcon007.com/)** — runs entirely in the browser (collection never leaves the page). Fine for one-off conversions of private collections you can't pipe through a CLI. Not tested quantitatively.
- **[Postman "Transform Collection to OpenAPI"](https://www.postman.com/postman/postman-public-workspace/request/vyyh2ga/transform-collection-to-openapi)** — official endpoint, requires a Postman API key. Likely the highest-fidelity converter (Postman owns both data models). Worth trying first if you have an account; not tested here because it's not a local tool.
- **[Apidog](https://apidog.com/)**, **[apimatic.io](https://www.apimatic.io/)** — commercial SaaS converters. Cost money; out of scope for this comparison.

## Recommendation by use case

| Use case | Pick | Then expect to manually… |
| --- | --- | --- |
| **Human-readable docs** (Swagger UI, Redoc) | joolfe | Fix the 2 trailing-slash paths. Done. |
| **Codegen client/server stubs** | kevinswiber | Strip or fix `nullable: true` siblings (sed `s/nullable: true$/nullable: true\n              type: object/g` is a starting point); resolve the inevitable codegen errors operation by operation. |
| **Contract-first development** with reusable schemas | openman | Add server URL, add security scheme, rename auto-named schemas, add tags. |
| **You have a Postman API key** | Postman official "Transform Collection to OpenAPI" first; fall back to joolfe. | Whatever Postman gets wrong (varies). |
| **You want to chain conversions in a pipeline** | joolfe (smallest install, most predictable output) | Same as docs case. |

**General advice:** none of these tools produce a finished spec. Budget 30-60 minutes of manual cleanup per ~20-operation collection regardless of which tool you start from. The collection you put in matters more than the tool — well-organized Postman folders + saved example responses + meaningful request descriptions all carry through to a usable OpenAPI output.

## Sources

- [Postman → OpenAPI tool list (search results)](https://www.google.com/search?q=postman+collection+to+openapi+converter)
- [joolfe/postman-to-openapi](https://github.com/joolfe/postman-to-openapi)
- [kevinswiber/postman2openapi](https://github.com/kevinswiber/postman2openapi)
- [codeasashu/openman](https://github.com/codeasashu/openman)
- [levoai/postman-to-openapi](https://github.com/levoai/postman-to-openapi)
- [tecfu/postman-to-swagger](https://github.com/tecfu/postman-to-swagger)
- [Redocly CLI lint rules](https://redocly.com/docs/cli/rules)
- [Postman API: Transform Collection to OpenAPI](https://www.postman.com/postman/postman-public-workspace/request/vyyh2ga/transform-collection-to-openapi)
