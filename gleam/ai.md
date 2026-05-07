# AI / LLM clients in Gleam

> [!NOTE]
> **Status:** DRAFT · **Authoring:** AI-assisted, human-reviewed.

So you want to call an LLM, run a tool-using agent, transcribe audio, or expose your Gleam app to Claude/Cursor over MCP — written in Gleam?

The Gleam side of AI is **young, fragmented, and provider-shaped**: most packages target one vendor (Mistral, Claude, OpenAI, Ollama, AssemblyAI), a handful target many through a unified abstraction, and a small but credible MCP-server cluster has appeared in the last six months. There is no Gleam equivalent of LangChain or pydantic-ai with serious adoption — but two new entrants ([starlet](#starlet), [glean](#glean)) are aiming there, and a token-format helper ([toon_codec](#toon_codec)) is the polished outlier of the lot.

This article surveys what exists, what's idiomatic, and what to avoid.

## Table of Contents

1. [Summary](#summary)
2. [State of the ecosystem](#state-of-the-ecosystem)
3. [Research Method](#research-method)
   - [Scoring Dimensions](#scoring-dimensions)
   - [Discovery](#discovery)
4. [Disregarded](#disregarded)
5. [Categories](#categories)
   - [Multi-provider abstractions](#multi-provider-abstractions) — [starlet](#starlet) · [glean](#glean) · [gai](#gai)
   - [Anthropic / Claude](#anthropic--claude) — [claude_gleam](#claude_gleam) · [anthropic_gleam](#anthropic_gleam) · [starflow](#starflow)
   - [OpenAI & OpenAI-compatible](#openai--openai-compatible) — [glopenai](#glopenai) · [gllm](#gllm) · [gopenai](#gopenai)
   - [Mistral](#mistral) — [gleamstral](#gleamstral)
   - [Ollama (local)](#ollama-local) — [ollama_gleam](#ollama_gleam)
   - [Speech / transcription](#speech--transcription) — [assemblyai](#assemblyai)
   - [LLM input encoding](#llm-input-encoding) — [toon_codec](#toon_codec)
   - [Model Context Protocol (MCP)](#model-context-protocol-mcp) — [aide](#aide) · [mcp_toolkit](#mcp_toolkit) · [mcp_client](#mcp_client) · [aide_generator](#aide_generator)
   - [What's missing](#whats-missing)
6. [Picking a library — practical guidance](#picking-a-library--practical-guidance)
7. [Leaderboard](#leaderboard)

## Summary

Snapshot: **2026-05-06**.

| Category | ☎️ BEAM | 📜 JS |
| --- | --- | --- |
| **[Multi-provider](#multi-provider-abstractions)** | · [🥇](#leaderboard) [starlet](#starlet) ([repo](https://github.com/jtdowney/starlet), 1★) — *unified API for OpenAI / Anthropic / Gemini / Ollama; tool calls, structured output, reasoning*<br>· [🥇](#leaderboard) [glean](#glean) ([repo](https://github.com/uncle-samm/glean), 2★) — *10 providers / 78+ models, real SSE streaming, simulation-testable agents*<br>· [gai](#gai) ([repo](https://github.com/chtushar/gai), 0★) — *placeholder; OpenAI provider scaffold only* | — |
| **[Anthropic / Claude](#anthropic--claude)** | · [claude_gleam](#claude_gleam) ([repo](https://github.com/pothos-dev/claude-sdk-gleam), 0★) — *agent loop, concurrent tool exec on BEAM, OTP actor streaming*<br>· [🥈](#leaderboard) [anthropic_gleam](#anthropic_gleam) ([repo](https://github.com/justin4957/anthropic-gleam), 0★) — *sans-IO, streaming, tool use, exp-backoff retries*<br>· [starflow](#starflow) ([repo](https://github.com/ethanthoma/starflow), 7★) — *stateful conversation chains; 16 months idle* | — |
| **[OpenAI & compatible](#openai--openai-compatible)** | · [🥉](#leaderboard) [glopenai](#glopenai) ([repo](https://github.com/nilp0inter/glopenai), 0★) — *sans-IO; chat, embeddings, moderation, images, audio, fine-tuning, batch, vector stores*<br>· [🥈](#leaderboard) [gllm](#gllm) ([repo](https://github.com/Forwall100/gllm), 1★) — *basic chat completion against any OpenAI-compatible endpoint (incl. OpenRouter)*<br>· [gopenai](#gopenai) ([hex](https://hex.pm/packages/gopenai)) — *no source repo link; 19 months stale* | — |
| **[Mistral](#mistral)** | · [🥈](#leaderboard) [gleamstral](#gleamstral) ([repo](https://github.com/Neofox/gleamstral), 6★) — *chat, vision (Pixtral), embeddings, agents, tools, structured output* | — |
| **[Ollama (local)](#ollama-local)** | · [ollama_gleam](#ollama_gleam) ([repo](https://github.com/ddanielsantos/ollama_gleam), 2★) — *thin client; 20 months idle, README is template stub* | — |
| **[Speech / transcription](#speech--transcription)** | — | · [assemblyai](#assemblyai) ([repo](https://github.com/iindyverse/assemblyai), 1★) — *AssemblyAI API client; capped stdlib `<= 0.67.1`* |
| **[LLM input encoding](#llm-input-encoding)** | · [🥇](#leaderboard) [toon_codec](#toon_codec) ([repo](https://github.com/axelbellec/toon_codec), 9★) — *TOON encoder/decoder; 30–50% token savings vs JSON for LLM context* | · [toon_codec](#toon_codec) — *also pure Gleam, single-target Erlang code but no FFI* |
| **[MCP servers / clients](#model-context-protocol-mcp)** | · [🥇](#leaderboard) [aide](#aide) ([repo](https://github.com/CrowdHailer/aide), 4★) — *MCP server framework, CPS-style, BYO web server*<br>· [🥈](#leaderboard) [mcp_toolkit](#mcp_toolkit) ([repo](https://github.com/mikan-laboratory/mcp_toolkit), 1★) — *MCP server with bundled stdio/HTTP/WS/SSE transports*<br>· [🥈](#leaderboard) [mcp_client](#mcp_client) ([repo](https://github.com/manelsen/mcp_client), 2★) — *MCP client over JSON-RPC/STDIO; OTP-supervised actors*<br>· [aide_generator](#aide_generator) ([repo](https://github.com/CrowdHailer/aide_generator), 2★) — *codegen for MCP tool encoders/decoders* | — |

> [!IMPORTANT]
> **Three providers have no Gleam-native client at snapshot:** Google Gemini, Cohere, and Groq. Reach them via [starlet](#starlet) or [glean](#glean) (both abstract Gemini), via OpenAI-compat endpoints with [gllm](#gllm) / [glopenai](#glopenai), or by hand-rolling HTTP requests with `gleam_http` + `gleam_json`. There is no SDK for **DeepSeek**, **Qwen**, **Moonshot**, **MiniMax**, or **OpenRouter** as standalone libraries — but [glean](#glean) exposes all of them through its multi-provider façade.

## State of the ecosystem

AI tooling in Gleam is **early but covers the production happy-path for 2026**: you can call Mistral / Claude / OpenAI / Ollama from typed Gleam today, run a tool-using agent loop, expose your application as an MCP server for Claude Code or Cursor, and emit token-efficient context with [toon_codec](#toon_codec).

What's there:
- **Two** active multi-provider abstractions ([starlet](#starlet), [glean](#glean)) — both shipped 2026, both well-documented.
- **Three** Claude-specific clients ([claude_gleam](#claude_gleam), [anthropic_gleam](#anthropic_gleam), [starflow](#starflow)) — Claude is the most-targeted vendor.
- **Three** OpenAI clients ([glopenai](#glopenai), [gllm](#gllm), [gopenai](#gopenai)) — but only [glopenai](#glopenai) covers more than basic chat.
- One **Mistral** client ([gleamstral](#gleamstral)) with the broadest single-vendor feature surface (vision, embeddings, tools, agents).
- One **Ollama** client ([ollama_gleam](#ollama_gleam)) — but it's been 20 months idle.
- One **AssemblyAI** transcription client ([assemblyai](#assemblyai)) — JS-only and stdlib-capped.
- A polished **token-efficient encoder** for LLM input ([toon_codec](#toon_codec)).
- **Four** Model Context Protocol packages ([aide](#aide), [mcp_toolkit](#mcp_toolkit), [mcp_client](#mcp_client), [aide_generator](#aide_generator)) — all Apache-2.0, all under a year old.

What's missing entirely:
- No **Gemini-only**, **Cohere**, **Groq**, **OpenRouter**, **DeepSeek**, **Qwen** standalone clients.
- No **vector database** clients (Pinecone, Weaviate, Qdrant, Chroma).
- No **embeddings storage / retrieval** (RAG framework). [glean](#glean) and the OpenAI / Mistral clients let you *call* embeddings APIs, but you store and query them yourself.
- No **prompt-management / prompt-template** library beyond ad-hoc string interpolation.
- No **LangChain / LlamaIndex / DSPy** equivalent (`glean` is the closest thing, but it's an SDK, not a chaining/RAG framework).
- No **HuggingFace Inference / HF Hub** clients.
- No **observability layer** for LLM calls (Langfuse / Helicone wrappers).
- No **fine-tuning workflow tooling** beyond the raw OpenAI fine-tuning endpoints in [glopenai](#glopenai).

Star counts are tiny — the highest in the AI category is [toon_codec](#toon_codec) at **9★**, with [starflow](#starflow) (7★) and [gleamstral](#gleamstral) (6★) trailing. Treat these as **thin, replaceable layers** and keep your prompt logic and tool definitions outside the SDK so you can swap clients (or fork) when one stalls.

## Research Method

### Scoring Dimensions

- **Stars:** Community adoption signal. 🟩🟩 = ≥200★, 🟩 = ≥100★, 🟨 = ≥10★, 🟥 = <10★. ⬜ = not shown by host. *AI packages skew very small — most are 🟥; the ceiling at snapshot is 9★.*
- **License:** 🟩 = permissive OSS (MIT, Apache-2.0, BSD). 🟥 = viral or missing. 🟨 = ambiguous (e.g. declared in `gleam.toml` but no `LICENSE` file).
- **Gleam compat:** `gleam_stdlib` constraint format in `gleam.toml`. 🟩 = range (`>= X and < Y`). 🟥 = non-range (`~>` style, or capped at a specific version that locks you out of newer stdlib).
- **Maintenance:** `max(recency, responsiveness)`. **Recency:** last commit vs snapshot. 🟩🟩 <1mo, 🟩 <6mo, 🟨 <1y, 🟥 >1y. **Responsiveness:** time for owner to reply to issues / update PRs. 🟩🟩 <2 days or clean tracker (0 issues), 🟩 <1 week, 🟨 <1 month, 🟥 >1 month or ignored.
- **Age:** Time from first commit to snapshot. 🟩🟩 ≥3 years, 🟩 ≥1 year, 🟨 ≥3 months, 🟥 <3 months. *Most AI packages here are 🟨 or 🟥 — only one is over a year old.*
- **README maturity:** 🟩🟩 = guide-style with examples + feature docs. 🟩 = clear tagline + working usage. 🟥 = template stub (just `gleam add x` + a `TODO`).
- **Idiomaticity:** 🟩 = typed, explicit, no magic. 🟥 = magic directives or implicit behavior.

**Leaderboard scoring:** 🟥 = −1, 🟨/⬜ = 0, 🟩 = 1, 🟩🟩 = 2. Sum of all 7 dimensions. Max = 13.

### Discovery

15 search terms run against the [Gleam packages registry](https://packages.gleam.run/). Cross-checked against direct Hex queries and GitHub topic searches.

- [ai](https://packages.gleam.run/?search=ai) — 6 results: gleamstral, assemblyai, passwd_gen, staff_ai, gai, glean
- [openai](https://packages.gleam.run/?search=openai) — 3 results: gllm, gopenai, glopenai
- [anthropic](https://packages.gleam.run/?search=anthropic) — 2 results: claude_gleam, anthropic_gleam
- [claude](https://packages.gleam.run/?search=claude) — 2 results (same as above)
- [mistral](https://packages.gleam.run/?search=mistral) — 1 result: gleamstral
- [llm](https://packages.gleam.run/?search=llm) — 5 results: toon_codec, starlet, starflow, gai, shcribe
- [gemini](https://packages.gleam.run/?search=gemini) — 2 results: glemini, glemtext (both for the **Gemini protocol**, not Google Gemini AI — out of scope)
- [ollama](https://packages.gleam.run/?search=ollama) — 1 result: ollama_gleam
- [agent](https://packages.gleam.run/?search=agent) — 5 results: claude_gleam, uaparser_gleam, staff_ai, genserver, glean
- [agentic](https://packages.gleam.run/?search=agentic) — 5 results (same as `agent`)
- [chat](https://packages.gleam.run/?search=chat) — 1 result: glome (Home Assistant — out of scope)
- [assistant](https://packages.gleam.run/?search=assistant) — 0 results
- [gpt](https://packages.gleam.run/?search=gpt) — 0 results
- [embedding](https://packages.gleam.run/?search=embedding) — 6 results, none AI-related (database / Lua / lisp)
- [mcp](https://packages.gleam.run/?search=mcp) — 5 results: oas_generator_utils, aide, aide_generator, mcp_toolkit, mcp_client
- [tokenizer](https://packages.gleam.run/?search=tokenizer) — 7 results, none AI-tokenizer-related (auth tokens, Lustre UI tokens)

**Naming-collision note:** the bare package name `ai` on Hex is **`cbh123/elixir_ai`**, an Elixir package — not Gleam. (Hex is shared between Erlang/Elixir/Gleam; this is why [`gai`](#gai) issue [#1](https://github.com/chtushar/gai/issues/1) records Louis Pilfold asking the author to vacate the squatted `gai` namespace.)

## Disregarded

Skipped from per-provider review — listed for auditability.

> <details>
> <summary>3 disregarded — out of scope, abandoned placeholder, name-squat artifact</summary>
>
> **Out of scope (not an AI library):**
> - **[passwd_gen](https://hex.pm/packages/passwd_gen)** — Password generator. Hex description: *"!!TESTING/EDUCATIONAL ONLY!! - No security guarantees. AI-generated code."* The "AI" tag is about *who wrote the code*, not what the package does. No repository link.
> - **[glemini](https://hex.pm/packages/glemini)** + **[glemtext](https://hex.pm/packages/glemtext)** — Servers and parsers for the **[Gemini protocol](https://geminiprotocol.net/)** (the small-web text protocol), not Google Gemini AI. Surfaced by the `gemini` search but unrelated to LLMs.
> - **[glome](https://hex.pm/packages/glome)** — Home Assistant automations. Surfaced by the `chat` search; not AI-related.
> - **[shcribe](https://hex.pm/packages/shcribe)** — Generates "human and LLM-readable API examples from your tests." A test-output formatter that happens to be LLM-ergonomic, not an LLM client. Closer to documentation generation than AI integration.
>
> **Abandoned placeholder:**
> - **[staff_ai](https://github.com/chainyo/staff-ai)** — 6★, last commit **2024-03-21** (~25 months idle). The README pitches "Be the CEO of your own AI workforce, efficiently managing countless intelligent agents with minimal resources" but the actual code creates an `Agent` record with name + role + bio fields and `io.debug()`s it. **No AI calls, no provider integration, no execution model.** `gleam.toml` uses the legacy `~> 0.34 or ~> 1.0` constraint. Disregarded as never-implemented vision.
>
> </details>

## Categories

### Multi-provider abstractions

The "one SDK, many vendors" path. Useful when you want to swap models without rewriting code, A/B-test providers, or compose tool-using agents that don't care about the underlying API shape.

| Criterion | [starlet](https://github.com/jtdowney/starlet) [🥇](#leaderboard) | [glean](https://github.com/uncle-samm/glean) [🥇](#leaderboard) | [gai](https://github.com/chtushar/gai) |
| --- | --- | --- | --- |
| Stars | 1★ · 🟥 | 2★ · 🟥 | 0★ · 🟥 |
| License | MIT · 🟩 | MIT · 🟩 | MIT · 🟩 |
| Target | ☎️ BEAM | ☎️ BEAM | ☎️ BEAM |
| Providers | OpenAI, Anthropic, Gemini, Ollama (4) | OpenAI, Anthropic, Gemini, Mistral, DeepSeek, Qwen, Moonshot, MiniMax, OpenRouter, OpenAI-compat (10) | OpenAI scaffold only (1) |
| Gleam compat | `>= 0.44 and < 2.0` · 🟩 | `>= 0.44 and < 2.0` · 🟩 | `>= 0.44 and < 2.0` · 🟩 |
| Maintenance | 🟩🟩 (last commit 2026-05-03, 2 open issues both with maintainer reply) | 🟩🟩 (last commit 2026-03-09, 0 open issues) | 🟩 (last commit 2026-03-01; **1 open issue: name-squat removal request, no reply**) |
| Age | ~4.1 months (Jan 2026) · 🟨 | ~2 months (Mar 2026) · 🟨 | ~2.4 months (Feb 2026) · 🟨 |
| README maturity | 🟩🟩 (full guide: tool calls, JSON output, reasoning, multi-turn) | 🟩🟩 (architecture, simulation testing, middleware, retry config) | 🟥 (template stub + TODO) |
| Idiomaticity | 🟩 (chained builder, `chat / system / user / send / step`) | 🟩 (typed model builders, dependency injection) | 🟩 (typed providers, but unimplemented) |
| | | | |
| **Features** | | | |
| Tool calling | ✅ | ✅ (with retry + DI) | ⬜ (stub) |
| Streaming (SSE) | ❌ (explicitly listed as missing) | ✅ (start/delta/end events) | ⬜ |
| Structured JSON output | ✅ | ✅ | ⬜ |
| Reasoning models | ✅ (budget/effort) | ✅ (reasoning deltas) | ⬜ |
| Simulation / mock testing | — | ✅ (deterministic scripted responses) | — |

#### starlet
[repo](https://github.com/jtdowney/starlet) · [🥇](#leaderboard) · [hexdocs](https://hexdocs.pm/starlet/)

"A unified, provider-agnostic interface for LLM APIs in Gleam." Same author as the auth article's [gose](authentication.md#gose) and [amaro](authentication.md#amaro) — and the patterns rhyme: small, typed, explicit. Released 2026-01-01, actively maintained (last commit 3 days before snapshot), 0–2 open issues per snapshot with clean reply history.

The notable miss is **streaming** (explicitly listed as not yet supported). For everything else — tool calls, structured output, reasoning model budget/effort, multi-turn — the API is uniform across Ollama / OpenAI / Anthropic / Gemini.

```gleam
import starlet
import starlet/ollama

pub fn main() {
  let assert Ok(reply) =
    starlet.chat(ollama.model("llama3.2"))
    |> starlet.system("You are a helpful assistant.")
    |> starlet.user("What is the capital of France?")
    |> starlet.send()

  let assert Ok(text) = starlet.text(reply)
  // text == "The capital of France is Paris."
}
```

#### glean
[repo](https://github.com/uncle-samm/glean) · [🥇](#leaderboard) · [hexdocs](https://hexdocs.pm/glean/)

The most ambitious single package in the category — and brand-new (first commit 2026-03-08, snapshot two months later). Self-positioned as "Vercel AI SDK / pydantic-ai for Gleam." **10 providers, 78+ enumerated models** with type-safe model builders that catch deprecated models at compile time. Real SSE streaming with start/delta/end events for text, reasoning, and tool deltas. Tool calling with **dependency injection**, JSON-schema validation, and retry logic. Middleware for request/response transformation. **Simulation testing** for deterministic multi-step agent verification without API calls.

The README is the most polished in the category (architecture diagram, publishing checklist, sponsor link). Internal modules are explicitly marked (`internal_modules = ["glean/providers/*", "glean/json_value"]`) so the public surface stays clean. BEAM-only.

The only reason it doesn't run away with the leaderboard is **age**: 2 months old, 2★. Bet on it for greenfield code; verify provider coverage for your specific model before depending.

```gleam
import glean
import glean/providers/anthropic

pub fn main() {
  let model = anthropic.claude_sonnet_4_5()
  let assert Ok(result) =
    glean.generate_text(model)
    |> glean.with_system("You are a haiku poet.")
    |> glean.with_prompt("Write a haiku about Gleam.")
    |> glean.run()
  // result.text → the haiku
  // result.usage.input_tokens, result.usage.output_tokens
}
```

#### gai
[repo](https://github.com/chtushar/gai) · [hexdocs](https://hexdocs.pm/gai/)

Listed for completeness. Hex description: *"The AI SDK for Gleam. Unified interface for LLM providers."* The aspiration is the same as glean's, but at snapshot the repo has 6 commits, a placeholder README, and an OpenAI provider scaffold without working examples. The single open issue ([#1](https://github.com/chtushar/gai/issues/1)) is **Louis Pilfold asking the author to vacate the package name** under Hex's anti-squatting terms — a strong negative signal.

Use [glean](#glean) or [starlet](#starlet) instead.

### Anthropic / Claude

Three independent Claude clients — the most-served single vendor in Gleam.

| Criterion | [claude_gleam](https://github.com/pothos-dev/claude-sdk-gleam) | [anthropic_gleam](https://github.com/justin4957/anthropic-gleam) [🥈](#leaderboard) | [starflow](https://github.com/ethanthoma/starflow) |
| --- | --- | --- | --- |
| Stars | 0★ · 🟥 | 0★ · 🟥 | 7★ · 🟥 |
| License | MIT in `gleam.toml`, **no LICENSE file** · 🟥 (issue [#1](https://github.com/pothos-dev/claude-sdk-gleam/issues/1) is "License?") | MIT (declared, file present) · 🟩 | Apache-2.0 in `gleam.toml`, **no LICENSE file** · 🟩 (declared) |
| Target | ☎️ BEAM (`target = "erlang"`) | ☎️ BEAM | ☎️ BEAM (`target = "erlang"`) |
| Gleam compat | `>= 0.44 and < 2.0` · 🟩 | `>= 0.44 and < 2.0` · 🟩 | `>= 0.44 and < 1.0` · 🟩 |
| Maintenance | 🟩 (last commit 2026-02-05, 1 open issue ~3 months no reply) | 🟩 (last commit 2026-01-25; 11 self-filed roadmap issues, no replies — counts as 🟥 responsiveness, 🟩 recency → max=🟩) | 🟥 (last commit 2025-01-11, ~16 months idle) |
| Age | ~3 months (Feb 2026) · 🟨 | ~3.7 months (Jan 2026) · 🟨 | ~17.7 months (Nov 2024) · 🟩 |
| README maturity | 🟩🟩 (10 sections: agent loop, OTP architecture, BEAM concurrency, advanced usage) | 🟩🟩 (features, quickstart, sans-IO, streaming, tool use, retry, observability, module reference) | 🟩 (quick start, key features, examples, common patterns, "coming soon") |
| Idiomaticity | 🟩 (typed events, OTP actor or callback streaming) | 🟩 (sans-IO, builder pattern) | 🟩 (typed state with custom user data) |
| | | | |
| **Features** | | | |
| Streaming (SSE) | ✅ (synchronous callbacks **and** OTP `Subject` messages — but `gleam_httpc` buffers the full response, so not true streaming yet) | ✅ (typed events) | ❌ ("coming soon") |
| Tool calling | ✅ (concurrent execution, one BEAM process per tool) | ✅ | ❌ ("coming soon") |
| Agent loop | ✅ (built-in with configurable iteration limits) | ⬜ (manual loop) | ⬜ (manual chains) |
| Multi-turn | ✅ | ✅ | ✅ (state carries history) |
| Retry / backoff | ⬜ | ✅ (exponential) | ⬜ |
| Other providers | — | — | — (Claude only) |

#### claude_gleam
[repo](https://github.com/pothos-dev/claude-sdk-gleam) · [hexdocs](https://hexdocs.pm/claude_gleam/)

Hex description: *"Gleam SDK for the Anthropic Claude API with agentic tool-use loop and BEAM concurrency."* The headline feature is the **agent loop**: send a prompt, let Claude call tools, execute those tools concurrently across BEAM processes, feed the results back, repeat until Claude stops calling tools or the iteration cap is hit.

Two streaming flavors: synchronous callbacks via `actor.run_with_events`, or OTP `Subject` message passing via `actor.start`. The README notes the `gleam_httpc` caveat — the underlying HTTP client buffers the full response, so streaming-as-events works but the bytes don't arrive in real time. Worth knowing if latency matters.

> [!CAUTION]
> The repo declares `licences = ["MIT"]` in `gleam.toml` but ships **no `LICENSE` file**, and the only open issue ([#1, "License?"](https://github.com/pothos-dev/claude-sdk-gleam/issues/1)) reflects exactly that ambiguity. Treat the license as undefined until upstream adds the file.

```gleam
import claude
import claude/messages
import claude/tools
import gleam/json
import gleam/dict
import gleam/option.{None, Some}

pub fn main() {
  let assert Ok(client) = claude.client_from_env()
  let weather_tool =
    tools.new(
      "get_weather",
      "Get current weather for a city",
      json.object([
        #("type", json.string("object")),
        #("properties", json.object([
          #("city", json.object([#("type", json.string("string"))])),
        ])),
      ]),
    )

  let handler = fn(name, input) {
    case name {
      "get_weather" -> Ok(json.object([#("temp_c", json.int(18))]))
      _ -> Error("unknown tool")
    }
  }

  let assert Ok(result) =
    messages.create(client, "claude-sonnet-4-5")
    |> messages.with_system("Use the weather tool when asked.")
    |> messages.with_user("What's the weather in Berlin?")
    |> messages.with_tools([weather_tool])
    |> messages.with_max_iterations(5)
    |> messages.run(handler)
}
```

#### anthropic_gleam
[repo](https://github.com/justin4957/anthropic-gleam) · [🥈](#leaderboard) · [hexdocs](https://hexdocs.pm/anthropic_gleam/)

The other Claude SDK. Hex description: *"A well-typed, idiomatic Gleam client for Anthropic's Claude API with streaming support and tool use."* Sans-IO architecture (you bring your own HTTP client), full Messages API with typed events, exponential-backoff retry, observability hooks for logging/telemetry, and request validation before send.

The README is excellent (13 sections including a module reference table). The repo, however, has **11 open issues** — all filed by the author themselves on 2026-01-26, none with comments, all roadmap stubs (JS target, FFI implementations, HTTP client abstraction, doc fixes). They count as a tracker stuck open more than a feature backlog. Score-wise: recency 🟩, responsiveness 🟥, max=🟩.

Pick this over [claude_gleam](#claude_gleam) if you want sans-IO + retries; pick claude_gleam if you want the built-in agent loop.

```gleam
import anthropic_gleam/client
import anthropic_gleam/messages
import gleam/erlang/os
import gleam/result

pub fn main() {
  let assert Ok(api_key) = os.get_env("ANTHROPIC_API_KEY")
  let c = client.new(api_key)

  let req =
    messages.new(model: "claude-sonnet-4-5")
    |> messages.add_user("Explain monads in one sentence.")
    |> messages.with_max_tokens(256)

  let assert Ok(resp) = client.send(c, req)
  // resp.content holds typed message blocks
}
```

#### starflow
[repo](https://github.com/ethanthoma/starflow) · [hexdocs](https://hexdocs.pm/starflow/)

"A library for building stateful chains of LLM interactions." The interesting idea: state composition. You define a custom state type (e.g. `GameState`), and prompts/responses thread that state through a chain. Token usage tracking is built in.

The catch: **only Anthropic's `send_message`**, no streaming, no tool use, no chain composition — all listed in the "Coming Soon" section. Last commit **2025-01-11**, ~16 months before snapshot. The 1 open issue ("Please add ollama as a provider", from the same era) has 1 comment from the author saying "good idea" and no follow-up. Maintenance 🟥.

Highest-starred Claude package (7★) but functionally surpassed by [claude_gleam](#claude_gleam) and [anthropic_gleam](#anthropic_gleam). Useful as a *pattern reference* for state-threaded LLM chains; don't depend on it for new projects.

```gleam
import starflow.{ask}
import starflow/state.{State}

pub fn main() {
  let initial = State("What is the meaning of life?", [])
  let assert Ok(updated) = ask(initial)
  // updated.history holds the conversation; updated.tokens has usage
}
```

### OpenAI & OpenAI-compatible

Three OpenAI clients with very different completeness.

| Criterion | [glopenai](https://github.com/nilp0inter/glopenai) [🥉](#leaderboard) | [gllm](https://github.com/Forwall100/gllm) [🥈](#leaderboard) | [gopenai](https://hex.pm/packages/gopenai) |
| --- | --- | --- | --- |
| Stars | 0★ · 🟥 | 1★ · 🟥 | ⬜ (no repo link) |
| License | MIT · 🟩 | Apache-2.0 OR MIT (`gleam.toml`) · 🟩 | Apache-2.0 (Hex metadata) · 🟩 |
| Target | ☎️ BEAM (`target = "erlang"`) | ☎️ BEAM | ☎️ BEAM (presumed) |
| Gleam compat | `>= 0.44 and < 2.0` · 🟩 | `>= 0.44 and < 2.0` · 🟩 | ⬜ (no repo) |
| Maintenance | 🟩🟩 (last commit 2026-04-18, 0 open issues) | 🟩🟩 (last commit 2025-10-10 — ~6.9mo recency 🟨, but 0 issues → resp 🟩🟩 → max=🟩🟩) | 🟥 (last Hex publish 2024-09-28, ~19.5mo) |
| Age | ~3 weeks (Apr 2026) · 🟥 | ~6.9 months (Oct 2025) · 🟨 | ~2.1 years (Apr 2024) · 🟩 |
| README maturity | 🟩 (quick start + API coverage table + roadmap) | 🟩 (clear; explicit "this is not a complete library" caveat) | 🟥 (no source repo, hexdocs only) |
| Idiomaticity | 🟩 (sans-IO, BYO HTTP, ported from Rust async-openai) | 🟩 (typed `Client`, `Message`, `completion`) | 🟩 (modules `chat`, `embeddings`, `tool` per hexdocs) |
| | | | |
| **Coverage** | | | |
| Chat completions | ✅ | ✅ (basic only) | ✅ |
| Streaming | ⬜ | ❌ | ⬜ |
| Embeddings | ✅ | ❌ | ✅ |
| Images / DALL·E | ✅ | ❌ | ⬜ |
| Audio (TTS) | ✅ | ❌ | ⬜ |
| Moderation | ✅ | ❌ | ⬜ |
| Fine-tuning | ✅ | ❌ | ⬜ |
| Batch | ✅ | ❌ | ⬜ |
| Vector stores | ✅ | ❌ | ⬜ |
| Tool use | ⬜ (via Chat Completions raw) | ❌ | ✅ (per hexdocs module list) |
| OpenAI-compat endpoints | ✅ (custom base, e.g. Ollama, Azure) | ✅ (any compatible) | ⬜ |

#### glopenai
[repo](https://github.com/nilp0inter/glopenai) · [🥉](#leaderboard) · [hexdocs](https://hexdocs.pm/glopenai/)

Hex description: *"Sans-IO OpenAI API client for Gleam, ported from async-openai."* Released **2026-04-15** — three weeks before snapshot — but already shipping the broadest OpenAI surface in Gleam: chat completions, the new Responses API, models, embeddings, moderation, image generation, audio TTS, files, legacy completions, fine-tuning, batch, vector stores, ChatKit, uploads, webhooks. The roadmap calls out what's not yet ported: assistants, video (Sora), containers, skills, evals, admin, realtime, audio transcription, image editing.

Sans-IO means you wire it to whatever HTTP client you already have (`gleam_httpc`, `gleam_hackney`, `fetch` on JS via FFI). The package itself only depends on `gleam_stdlib`, `gleam_json`, `gleam_http` — no HTTP client baked in.

The repo is a fork (`nilp0inter/glopenai` from `64bit/async-openai`) but the work is original Gleam — the Rust source informed the type design and field naming, not the implementation. **361 commits** at snapshot.

```gleam
import glopenai/config
import glopenai/chat
import gleam/httpc

pub fn main() {
  let cfg = config.openai("sk-...")
  let req =
    chat.create()
    |> chat.with_model("gpt-5")
    |> chat.with_message(chat.user("Hello, world!"))
    |> chat.build(cfg)

  let assert Ok(http_resp) = httpc.send(req)
  let assert Ok(resp) = chat.decode_response(http_resp.body)
}
```

#### gllm
[repo](https://github.com/Forwall100/gllm) · [🥈](#leaderboard) · [hexdocs](https://hexdocs.pm/gllm/)

"Gleam library for interacting with OpenAI-compatible APIs." The README is honest: *"This is **not** a complete library. Currently supports only basic chat completion requests, no streaming, no comprehensive error handling, no embeddings/images/etc., synchronous only."* What's there works against any OpenAI-compatible endpoint — OpenAI itself, OpenRouter, or any local server (Ollama in OpenAI-compat mode, llama.cpp, vLLM).

Useful when you want a 5-line chat-completion call against OpenRouter without pulling in [glopenai](#glopenai)'s broader surface. Otherwise upgrade.

```gleam
import gllm
import gleam/list

pub fn main() {
  let client = gllm.Client(
    api_key: "sk-or-...",
    base_url: "https://openrouter.ai/api/v1",
  )
  let messages = [
    gllm.new_message("system", "You are concise."),
    gllm.new_message("user", "Define WASM in 10 words."),
  ]
  let assert Ok(reply) =
    gllm.completion(client, "openai/gpt-5", messages, 0.7)
}
```

#### gopenai
[hex](https://hex.pm/packages/gopenai) · [hexdocs](https://hexdocs.pm/gopenai/)

Listed for completeness. Hex package version 1.0.4, published **2024-09-28**, **no repository link** in the package metadata. Per hexdocs the modules are `gopenai`, `gopenai/chat`, `gopenai/client`, `gopenai/embeddings`, `gopenai/model`, `gopenai/tool` — and the docs page describes itself as *"a Claude agent, built on Anthropic's Claude Agent SDK"* (clearly an autogenerated mismatch). **715 all-time downloads** at snapshot.

With no source repo, no recent activity, and an inconsistent doc page, treat as effectively orphaned. Use [glopenai](#glopenai) or [gllm](#gllm).

### Mistral

#### gleamstral
[repo](https://github.com/Neofox/gleamstral) · [🥈](#leaderboard) · [hexdocs](https://hexdocs.pm/gleamstral/)

The most feature-complete *single-vendor* SDK in the Gleam AI ecosystem.

| Criterion | [gleamstral](https://github.com/Neofox/gleamstral) [🥈](#leaderboard) |
| --- | --- |
| Stars | 6★ · 🟥 |
| License | MIT (`gleam.toml`, no LICENSE file in repo) · 🟩 (declared) |
| Target | ☎️ BEAM |
| Deps | 3 (`gleam_stdlib`, `gleam_http`, `gleam_json`) |
| Gleam compat | `>= 0.44 and < 2.0` · 🟩 |
| Maintenance | 🟨 (last commit 2025-05-27, ~11.4 months idle; 1 open issue from Sep 2025 with 3 owner replies — recency 🟨, responsiveness 🟩, max=🟩 by responsiveness, but issue still open and quiet → 🟨 net) |
| Age | ~14.3 months (Feb 2025) · 🟩 |
| README maturity | 🟩🟩 (overview, install, API key, quick example, key features, examples, roadmap, contributing) |
| Idiomaticity | 🟩 (typed clients, builder pattern) |

Covers the full Mistral surface: chat completions across all model variants (Large, Small, Ministral), **vision via Pixtral** for image analysis, **embeddings**, **function/tool calling**, **structured JSON output via JSON schema**, and the **Agent API**.

The wrinkle is freshness: ~11 months since the last commit. The single open issue (#7, "Convert to the json schema type that is part of OAS") has **3 maintainer comments** spread across late 2025, so the author is responsive when pinged. Nothing in the API is broken — Mistral hasn't made breaking changes — but expect to fork or send PRs for new model IDs.

```gleam
import gleam/io
import gleamstral/client
import gleamstral/chat_completion
import gleamstral/message

pub fn main() {
  let c = client.new("MISTRAL_API_KEY")

  let assert Ok(result) =
    chat_completion.new(c)
    |> chat_completion.with_temperature(0.5)
    |> chat_completion.with_max_tokens(1000)
    |> chat_completion.complete(
      chat_completion.MistralLarge,
      [
        message.SystemMessage("You are a helpful assistant"),
        message.UserMessage(message.TextContent("Hello!")),
      ],
    )

  io.debug(result.choices)
}
```

### Ollama (local)

#### ollama_gleam
[repo](https://github.com/ddanielsantos/ollama_gleam) · [hexdocs](https://hexdocs.pm/ollama_gleam/)

| Criterion | [ollama_gleam](https://github.com/ddanielsantos/ollama_gleam) |
| --- | --- |
| Stars | 2★ · 🟥 |
| License | Apache-2.0 (Hex metadata) · 🟩 |
| Target | ☎️ BEAM |
| Gleam compat | `>= 0.34 and < 2.0` · 🟩 |
| Maintenance | 🟥 (last commit **2024-09-01**, ~20.2 months idle; 1 open issue from same week, no reply) |
| Age | ~1.7 years (Aug 2024) · 🟩 |
| README maturity | 🟥 (template stub: "TODO: An example of the project in use") |
| Idiomaticity | 🟩 (typed args per the embedding endpoint commit) |

The only Gleam-native Ollama client. Per the latest commit message, supports `/embeddings` with the full argument set; the open issue ([#6](https://github.com/ddanielsantos/ollama_gleam/issues/6)) requests `/generate` and was never answered. **20 months idle.**

If you want Ollama from Gleam in 2026, prefer **[starlet](#starlet)** (which has Ollama as a first-class provider with tools and structured output) or hit Ollama via its **OpenAI-compatible endpoint** with [gllm](#gllm) or [glopenai](#glopenai).

### Speech / transcription

#### assemblyai
[repo](https://github.com/iindyverse/assemblyai) · [hexdocs](https://hexdocs.pm/assemblyai/)

| Criterion | [assemblyai](https://github.com/iindyverse/assemblyai) |
| --- | --- |
| Stars | 1★ · 🟥 |
| License | Apache-2.0 (Hex metadata) · 🟩 |
| Target | 📜 JS only (`target = "javascript"`) |
| Gleam compat | **`>= 0.44 and <= 0.67.1`** · 🟥 (capped — locks you out of newer stdlib) |
| Maintenance | 🟩 (last commit 2026-03-11, ~1.9 months; 1 open issue "Compiler warning" from Mar 2026, no reply) |
| Age | ~2.7 months (Feb 2026) · 🟥 |
| README maturity | 🟥 (template stub) |
| Idiomaticity | 🟩 (typed; built on `oas_generator` codegen output) |

The only **non-LLM** AI provider in Gleam: AssemblyAI for **speech-to-text**. JS-only target — designed to run inside [midas](https://github.com/midas-framework/midas) browser/CLI environments via `fetch`.

The headline gotcha: **`gleam_stdlib <= 0.67.1`** is a hard cap. If your project depends on a stdlib >= 0.68, this won't resolve. The cap mirrors the [`migrant`](databases.md) and [`shork`](databases.md#shork-) patterns — likely autogenerated by `oas_generator` from a fixed snapshot. Pin or fork.

> [!NOTE]
> No other speech / TTS / image-generation / vision-model client exists as a Gleam package at snapshot. **Whisper, Deepgram, Eleven Labs, Replicate, Stability AI, Hume — all absent.**

### LLM input encoding

#### toon_codec
[repo](https://github.com/axelbellec/toon_codec) · [🥇](#leaderboard) · [hexdocs](https://hexdocs.pm/toon_codec/)

| Criterion | [toon_codec](https://github.com/axelbellec/toon_codec) |
| --- | --- |
| Stars | 9★ · 🟥 (**highest in this article**) |
| License | MIT · 🟩 |
| Target | ☎️ BEAM (single dep: `gleam_stdlib`) |
| Gleam compat | `>= 0.44 and < 2.0` · 🟩 |
| Maintenance | 🟩🟩 (last commit 2025-10-30, 0 open issues; 113 passing tests) |
| Age | ~6.2 months (Oct 2025) · 🟨 |
| README maturity | 🟩🟩 (install, quick start, full data-type examples, JSON-vs-TOON comparison, API reference) |
| Idiomaticity | 🟩 (encoder + decoder, customizable delimiters, strict mode) |

Not an LLM client — a **format library for LLM input**. TOON ([Token-Oriented Object Notation](https://github.com/johannschopplich/toon)) is a YAML-like alternative to JSON optimized for LLM token consumption. The README's headline claim: **30–50% token reduction** vs JSON for the same data, by stripping JSON's brace/comma overhead and using indentation + tabular array forms.

When this matters: large structured-data prompts (database rows, tool-call results, RAG context). When it doesn't: small prompts where the savings are dwarfed by output tokens.

```gleam
import toon_codec

pub fn main() {
  let payload = "{\"name\": \"Ada\", \"age\": 36, \"langs\": [\"Erlang\", \"Gleam\"]}"
  let assert Ok(encoded) = toon_codec.encode_json(payload)
  // encoded:
  //   name: Ada
  //   age: 36
  //   langs[2]: Erlang, Gleam
  let assert Ok(json_back) = toon_codec.decode_to_json(encoded)
}
```

The polished outlier of the article: 9★, clean tracker, real test suite, single dependency, comprehensive docs. Only the age (~6mo) keeps it from a higher score.

### Model Context Protocol (MCP)

[Model Context Protocol](https://modelcontextprotocol.io/) is Anthropic's spec for letting LLM clients (Claude Code, Cursor, Claude Desktop) call tools, read resources, and use prompts hosted by a remote process over JSON-RPC. Four Gleam packages cover the space — three for **building MCP servers** (so Claude/Cursor can call your Gleam code), one for **consuming MCP servers** (so a Gleam app can use Claude Desktop's tool ecosystem).

| Criterion | [aide](https://github.com/CrowdHailer/aide) [🥇](#leaderboard) | [mcp_toolkit](https://github.com/mikan-laboratory/mcp_toolkit) [🥈](#leaderboard) | [mcp_client](https://github.com/manelsen/mcp_client) [🥈](#leaderboard) | [aide_generator](https://github.com/CrowdHailer/aide_generator) |
| --- | --- | --- | --- | --- |
| Role | Server framework | Server framework | **Client** | Codegen for `aide` |
| Stars | 4★ · 🟥 | 1★ · 🟥 | 2★ · 🟥 | 2★ · 🟥 |
| License | Apache-2.0 (Hex; no LICENSE file) · 🟩 | NOASSERTION (GitHub) / Apache-2.0 (Hex) · 🟨 | Apache-2.0 · 🟩 | Apache-2.0 (Hex) · 🟩 |
| Target | ☎️📜 Both (CPS-style for portability) | ☎️ BEAM | ☎️ BEAM | ☎️ BEAM |
| Gleam compat | `>= 0.44 and < 2.0` · 🟩 | `>= 0.44 and < 2.0` · 🟩 | `>= 0.44 and < 2.0` · 🟩 | `>= 0.44 and < 2.0` · 🟩 |
| Maintenance | 🟩🟩 (last commit 2026-02-23, 0 issues) | 🟩🟩 (last commit 2025-10-17, 0 issues — recency 🟨, resp 🟩🟩 → max=🟩🟩) | 🟩🟩 (last commit 2026-04-23, 0 issues) | 🟩🟩 (last commit 2026-02-23, 0 issues) |
| Age | ~8.7 months (Aug 2025) · 🟨 | ~7.1 months (Oct 2025) · 🟨 | ~14 days (Apr 2026) · 🟥 | ~6.3 months (Oct 2025) · 🟨 |
| README maturity | 🟩🟩 (math-server walkthrough; 4 sections of code) | 🟩🟩 (quick start + transports) | 🟩🟩 (architecture + retry docs) | 🟥 (template stub) |
| Idiomaticity | 🟩 (CPS for portability, BYO web framework) | 🟩 (typed builders, multi-transport) | 🟩 (OTP-supervised, three-layer architecture) | 🟩 (typed codegen output) |
| | | | | |
| **Capabilities** | | | | |
| Server (tools, resources, prompts) | ✅ tools (resources/prompts on roadmap) | ✅ tools, resources, prompts | — | — |
| Client | "coming soon" | — | ✅ | — |
| stdio transport | ⬜ | ✅ | ✅ | — |
| HTTP transport | ✅ (BYO server, e.g. Wisp) | ✅ | — | — |
| WebSocket / SSE | — | ✅ | — | — |
| Codegen for tool encoders | — | — | — | ✅ (consumes OAS specs) |

#### aide
[repo](https://github.com/CrowdHailer/aide) · [🥇](#leaderboard) · [hexdocs](https://hexdocs.pm/aide/)

By [CrowdHailer](https://github.com/CrowdHailer) (the same author behind [supa](authentication.md#supa), [spotless](authentication.md#spotless), [felix](authentication.md#felix), [eyg](https://eyg.run/), and [`oas_generator`](parse-and-generate-other-languages.md#oas_generator)). The design choice: **continuation-passing style** so the same code targets BEAM and JavaScript without per-runtime forking. JSON-RPC encoding handled internally; you bring your own web server (Wisp or otherwise) and route the MCP endpoint to `aide`'s handler.

The README walks through a complete math-server example: install, mount, define a tool with spec + decoder, return a result. Tools support OpenAPI-style schemas. Resources and prompts are on the roadmap (the package description says "clients coming soon" — referring to MCP-client functionality, not HTTP clients).

```gleam
// Sketch — see the README for the full math server
import aide
import aide/tool
import gleam/dynamic/decode
import gleam/json

pub fn main() {
  let add_tool =
    tool.new(
      name: "add",
      description: "Add two integers",
      input: decode.field("a", decode.int, fn(a) {
        decode.field("b", decode.int, fn(b) { decode.success(#(a, b)) })
      }),
      handler: fn(input) {
        let #(a, b) = input
        Ok(json.int(a + b))
      },
    )
  // mount aide.handler with [add_tool] inside your wisp router
}
```

#### mcp_toolkit
[repo](https://github.com/mikan-laboratory/mcp_toolkit) · [🥈](#leaderboard) · [hexdocs](https://hexdocs.pm/mcp_toolkit/)

A **fork** of [`mikkihugo/mcp_toolkit_gleam`](https://github.com/mikkihugo/mcp_toolkit_gleam) updated to track newer Gleam releases. BEAM-only, but ships **bundled transports** that `aide` doesn't: stdio (for Claude Desktop's native MCP integration), WebSocket, SSE, plus HTTP JSON-RPC over `mist`. The fork adds 95 commits since divergence — active maintenance rather than a stale mirror.

License is the one wrinkle: GitHub reports `NOASSERTION` (no machine-readable LICENSE file matching SPDX), while `gleam.toml` declares `Apache-2.0`. Treat as Apache-2.0 with a note to upstream.

#### mcp_client
[repo](https://github.com/manelsen/mcp_client) · [🥈](#leaderboard) · [hexdocs](https://hexdocs.pm/mcp_client/)

The **only MCP client** in Gleam at snapshot. Lets your Gleam app act as the LLM-facing side: connect to GitHub's MCP server, the filesystem MCP server, Brave Search MCP, etc., over JSON-RPC 2.0/STDIO. Three-layer architecture (transport / manager / facade), exponential-backoff reconnect, **1 MB line buffering** for large JSON-RPC responses, MCP `2024-11-05` protocol compliance.

Brand new (~2 weeks at snapshot, 0 issues, clean tracker) and the README is unusually thorough for a fresh package — architecture diagrams, retry-policy explanation, design rationale. Released `0.1.0`; expect API churn.

#### aide_generator
[repo](https://github.com/CrowdHailer/aide_generator) · [hexdocs](https://hexdocs.pm/aide_generator/)

Companion codegen for [aide](#aide): consumes an OpenAPI/JSON-Schema spec and emits encoders + decoders for MCP tools. Same author. Useful when you're exposing an existing API surface as MCP tools and want to avoid hand-rolling codecs. README is a stub — see [aide](#aide)'s walkthrough for the consuming side and [`serialize-and-deserialize.md → codegen for ser/deser`](serialize-and-deserialize.md#codegen-for-serdeser) for the broader ser/deser-codegen landscape, or [`parse-and-generate-other-languages.md`](parse-and-generate-other-languages.md) for X→Gleam codegen overall.

### What's missing

Categories with **zero** Gleam packages at snapshot:

- **Vector databases** — no Pinecone, Weaviate, Qdrant, Chroma, pgvector helper, or in-memory vector store.
- **RAG framework** — no chunkers, retrievers, or pipeline tooling. Build it yourself on top of [glopenai](#glopenai)'s embeddings + your own DB ([databases.md](databases.md)).
- **Prompt management** — no template engine designed for LLM prompts (Jinja-style, with versioning). Use string interpolation or [trick](parse-and-generate-gleam.md#trick) for typed templates.
- **LLM observability** — no Langfuse, Helicone, LangSmith wrappers.
- **HuggingFace / Replicate / Stability AI** — no SDKs.
- **Other speech / vision providers** — no Whisper / Deepgram / Eleven Labs / Hume / OpenAI Whisper API client. [assemblyai](#assemblyai) is the only speech-related package.
- **Image generation as a dedicated client** — covered only by [glopenai](#glopenai)'s generic image surface; no Midjourney, Stable Diffusion, or Replicate-specific clients.
- **Standalone Gemini, Cohere, Groq, OpenRouter, DeepSeek, Qwen, Moonshot, MiniMax** clients — only reachable via [glean](#glean) or [starlet](#starlet).
- **Realtime / voice-mode** APIs (OpenAI Realtime, Anthropic Computer Use streaming).
- **Local model inference** — no `llama.cpp` bindings, no `mlx` bindings; reach local models via [ollama_gleam](#ollama_gleam) (stale) or via Ollama's OpenAI-compat endpoint.

## Picking a library — practical guidance

**You need to call one specific provider:**

| Provider | Recommended | Notes |
| --- | --- | --- |
| OpenAI / OpenAI-compat | [glopenai](#glopenai) | Broadest API coverage. |
| Anthropic / Claude | [claude_gleam](#claude_gleam) for built-in agent loop · [anthropic_gleam](#anthropic_gleam) for sans-IO + retries | Both are 3-month-old and both have light-but-clear maintenance signals. |
| Mistral | [gleamstral](#gleamstral) | Most complete single-vendor SDK in Gleam (vision, embeddings, agents, tools). |
| Ollama | [starlet](#starlet) (preferred) or Ollama's OpenAI-compat endpoint via [gllm](#gllm) | [ollama_gleam](#ollama_gleam) is stale. |
| Gemini / DeepSeek / Qwen / Moonshot / MiniMax / OpenRouter | [glean](#glean) (only option) | No standalone SDK exists. |
| AssemblyAI (transcription) | [assemblyai](#assemblyai) | Mind the stdlib cap. |

**You want to switch providers without rewriting:** [glean](#glean) for the broadest coverage and streaming/tool support; [starlet](#starlet) if you want a smaller surface and better maintenance signal but can live without streaming.

**You're building an MCP server** (Claude Code / Cursor calls into your Gleam app): [aide](#aide) if you target both BEAM and JS or run inside Wisp; [mcp_toolkit](#mcp_toolkit) if you want stdio + bundled transports for direct Claude Desktop integration.

**You're consuming an MCP server** (your Gleam app uses Claude Desktop's tools): [mcp_client](#mcp_client) is the only choice — and it's brand new.

**You're sending large structured data to an LLM:** Wrap it with [toon_codec](#toon_codec) before stuffing into the prompt. Easy 30–50% input-token reduction.

**You're doing RAG / embeddings:** Get embeddings from [glopenai](#glopenai) or [gleamstral](#gleamstral); store vectors in **your own database** (see [databases.md](databases.md)) — no Gleam vector-store helpers exist yet.

## Leaderboard

Every contribution is invaluable and appreciated.

This ranking
- helps authors check if the metrics are sane at a glance
- uncovers gems unique to the Gleam ecosystem
- cherishes key contributors

**🥇 Gold (tied at 6)**
- **starlet** ([jtdowney](https://github.com/jtdowney)) — Most-actively-maintained multi-provider SDK; clean issue tracker; same author as [gose](authentication.md#gose) and [amaro](authentication.md#amaro).
- **glean** ([uncle-samm](https://github.com/uncle-samm)) — Broadest provider coverage in the ecosystem; SSE streaming + simulation testing — but only 2 months old.
- **toon_codec** ([axelbellec](https://github.com/axelbellec)) — Polished, single-dep, 113 tests, highest star count in the article.
- **aide** ([CrowdHailer](https://github.com/CrowdHailer)) — Cleanest MCP-server design; CPS for dual-target portability.

| Position | Award | Repo | ★ | Lic | Compat | Maint | Age | README | Idiom | Score |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 🥇 | · [jtdowney/starlet](https://github.com/jtdowney/starlet)<br>· [uncle-samm/glean](https://github.com/uncle-samm/glean)<br>· [axelbellec/toon_codec](https://github.com/axelbellec/toon_codec)<br>· [CrowdHailer/aide](https://github.com/CrowdHailer/aide) | 🟥<br>🟥<br>🟥<br>🟥 | 🟩<br>🟩<br>🟩<br>🟩 | 🟩<br>🟩<br>🟩<br>🟩 | 🟩🟩<br>🟩🟩<br>🟩🟩<br>🟩🟩 | 🟨<br>🟨<br>🟨<br>🟨 | 🟩🟩<br>🟩🟩<br>🟩🟩<br>🟩🟩 | 🟩<br>🟩<br>🟩<br>🟩 | **6** |
| 5 | 🥈 | · [Neofox/gleamstral](https://github.com/Neofox/gleamstral)<br>· [Forwall100/gllm](https://github.com/Forwall100/gllm)<br>· [mikan-laboratory/mcp_toolkit](https://github.com/mikan-laboratory/mcp_toolkit)<br>· [manelsen/mcp_client](https://github.com/manelsen/mcp_client)<br>· [justin4957/anthropic-gleam](https://github.com/justin4957/anthropic-gleam) | 🟥<br>🟥<br>🟥<br>🟥<br>🟥 | 🟩<br>🟩<br>🟨<br>🟩<br>🟩 | 🟩<br>🟩<br>🟩<br>🟩<br>🟩 | 🟨<br>🟩🟩<br>🟩🟩<br>🟩🟩<br>🟩 | 🟩<br>🟨<br>🟨<br>🟥<br>🟨 | 🟩🟩<br>🟩<br>🟩🟩<br>🟩🟩<br>🟩🟩 | 🟩<br>🟩<br>🟩<br>🟩<br>🟩 | **5** |
| 10 | 🥉 | [nilp0inter/glopenai](https://github.com/nilp0inter/glopenai) | 🟥 | 🟩 | 🟩 | 🟩🟩 | 🟥 | 🟩 | 🟩 | **4** |
| 11 | | · [pothos-dev/claude-sdk-gleam](https://github.com/pothos-dev/claude-sdk-gleam)<br>· [ethanthoma/starflow](https://github.com/ethanthoma/starflow)<br>· [CrowdHailer/aide_generator](https://github.com/CrowdHailer/aide_generator) | 🟥<br>🟥<br>🟥 | 🟥<br>🟩<br>🟩 | 🟩<br>🟩<br>🟩 | 🟩<br>🟥<br>🟩🟩 | 🟨<br>🟩<br>🟨 | 🟩🟩<br>🟩<br>🟥 | 🟩<br>🟩<br>🟩 | **3** |
| 14 | | [chtushar/gai](https://github.com/chtushar/gai) | 🟥 | 🟩 | 🟩 | 🟩 | 🟨 | 🟥 | 🟩 | **2** |
| 15 | | · [ddanielsantos/ollama_gleam](https://github.com/ddanielsantos/ollama_gleam)<br>· [gopenai (hex)](https://hex.pm/packages/gopenai) | 🟥<br>⬜ | 🟩<br>🟩 | 🟩<br>⬜ | 🟥<br>🟥 | 🟩<br>🟩 | 🟥<br>🟥 | 🟩<br>🟩 | **1** |
| 17 | | [iindyverse/assemblyai](https://github.com/iindyverse/assemblyai) | 🟥 | 🟩 | 🟥 | 🟩 | 🟥 | 🟥 | 🟩 | **−1** |

**By target:** ☎️ BEAM **15 repos** · 📜 JS **3 repos** ([toon_codec](#toon_codec), [aide](#aide), [assemblyai](#assemblyai); the first two dual-target).

[How scores are calculated →](#scoring-dimensions)

## Notes

- **Highest star count in the article: 9★ ([toon_codec](#toon_codec)).** Every other AI package is below 10★. The category is wide-open — even a single well-targeted contribution moves the leaderboard.
- **Two providers dominate Gleam-native attention:** Anthropic (3 packages) and OpenAI (3 packages). Together they account for 6/16 of the in-scope packages.
- **Three packages have license ambiguity** ([claude_gleam](#claude_gleam), [gleamstral](#gleamstral), [starflow](#starflow), [aide](#aide)) — they declare a permissive license in `gleam.toml` or Hex metadata but ship no `LICENSE` file in the repo. Verify before commercial use.
- **One stdlib cap** ([assemblyai](#assemblyai), `gleam_stdlib <= 0.67.1`). Same pattern as [migrant](databases.md#disregarded) and [shork](databases.md#shork-) — `oas_generator`-style autogenerated repos tend to ship over-strict caps.
- **Name-squatting note:** The bare `ai` package on Hex is `cbh123/elixir_ai`, an Elixir package; the namespace is unavailable to a Gleam library. The `gai` package's only open issue is a name-squatting takedown request from Louis Pilfold ([chtushar/gai#1](https://github.com/chtushar/gai/issues/1)).
- **No serialization / generator overlap with [serialize-and-deserialize.md](serialize-and-deserialize.md) / [parse-and-generate-other-languages.md](parse-and-generate-other-languages.md):** [toon_codec](#toon_codec) is technically a serialization format, but its purpose (LLM input optimization) and category land it squarely here.
- **MCP cluster all under one year:** All four MCP packages were first committed between **August 2025 and April 2026** — the entire category is younger than this article's predecessor articles ([databases.md](databases.md), [authentication.md](authentication.md)).
- **Cross-link to [authentication.md](authentication.md):** Several authors recur — [CrowdHailer](https://github.com/CrowdHailer) ([aide](#aide), [aide_generator](#aide_generator), [supa](authentication.md#supa), [spotless](authentication.md#spotless), [felix](authentication.md#felix)) and [jtdowney](https://github.com/jtdowney) ([starlet](#starlet), [gose](authentication.md#gose), [amaro](authentication.md#amaro)). Same opinionated, sans-IO, BYO-HTTP shape across both domains.
