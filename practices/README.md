# Practices

Methodologies and "how to think" articles. Not "which library", but "which mental model" — the upstream choices that determine whether the library reviews even matter.

## Articles

- [**BDD with Gherkin**](bdd-with-gherkin.md) — cross-ecosystem Cucumber-family survey across Ruby, JS, JVM, Python, .NET, Go, Rust, PHP, Elixir, Gleam, Haskell. Gherkin as the executable encoding of "what the system should do" — the bridge between Domain-Driven Design's Ubiquitous Language and a CI green-tick.
- [**Domain-Driven Design**](domain-driven-design.md) — opinionated orientation: why DDD is hard, where it earns its keep (Ubiquitous Language + Bounded Contexts), how it maps onto Ash (Elixir), and the author's evolving "adjusted approach." A practice that pairs with [BDD](bdd-with-gherkin.md) for the language-to-tests round trip.
- [**Formalization**](formalization.md) — the **scoring rubric** (stars, license, language-compat, maintenance, age, README maturity, idiomaticity, feature completeness, ease of use, output quality) and discovery pipeline used by every article in this repo. The canonical source for the rubric every other review cites.

## Related

- [`workflows/`](../workflows/) — the agent-facing review process that *uses* the formalization rubric.
- The [Gleam](../gleam/README.md) folder is the largest worked example of DDD-adjacent thinking applied to library selection.
