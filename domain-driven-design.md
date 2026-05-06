# Domain-Driven Design — an honest map of the territory

> [!NOTE]
> **Status:** DRAFT · **Authoring:** AI-assisted, human-reviewed.

> *"Hard, complicated, difficult to access, Java-heavy — and still worth knowing."* This article is the author's working take on DDD: where it earns its keep, where the cost of admission isn't worth it, and how Ash (Elixir) maps onto it almost for free.

**Snapshot 2026-04-30** — book metadata, framework docs, and reference URLs verified live at snapshot. This is an opinion + orientation article, **not** a scored review. There is no leaderboard, no per-package 7-dim scoring, and no recommendation for *the* DDD library — there isn't one, and that's part of the story.

## Table of Contents

1. [What is DDD?](#what-is-ddd)
2. [The honest critique — DDD is hard](#the-honest-critique--ddd-is-hard)
3. [Where DDD earns its keep — stakeholder alignment](#where-ddd-earns-its-keep--stakeholder-alignment)
4. [Maps well to Ash framework (Elixir)](#maps-well-to-ash-framework-elixir)
5. [Currently considering an adjusted approach](#currently-considering-an-adjusted-approach)
6. [When to use, when NOT to use](#when-to-use-when-not-to-use)
7. [Further reading](#further-reading)

## What is DDD?

**Domain-Driven Design** is a software design philosophy introduced by **Eric Evans** in his 2003 book *Domain-Driven Design: Tackling Complexity in the Heart of Software* (Addison-Wesley, ISBN 978-0321125217 — universally called "the Blue Book"). The thesis, stripped to one line:

> *Software for a complex domain must put the domain model — not the database, not the framework, not the UI — at the centre, and that model must be a shared artefact between developers and the people who actually understand the business.*

The vocabulary that came out of the Blue Book has become the lingua franca of enterprise architecture. The pieces worth knowing on first pass:

| Concept | One-line gloss |
| --- | --- |
| **Ubiquitous Language** | One vocabulary used by everyone — devs, PMs, domain experts — in code, docs, tickets, and meetings. The exact same words. |
| **Bounded Context** | An explicit boundary inside which a single model and language are consistent. The "shipping" context's `Order` is not the "billing" context's `Order`. |
| **Domain** / **Subdomain** | The business space; subdomains are *core* (your competitive edge), *supporting* (necessary but generic), or *generic* (commodity — auth, billing, etc.). |
| **Entity** | An object identified by id, with a lifecycle (a `User`, an `Order`). Identity is what matters, state changes over time. |
| **Value Object** | An object identified by its values, immutable (a `Money(50, EUR)`, a `DateRange`). Two of them with equal fields are the same thing. |
| **Aggregate** | A cluster of entities + value objects with one **aggregate root** as the only entry point. Invariants hold across the whole aggregate; transactions don't cross aggregate boundaries. |
| **Domain Event** | A first-class fact that something happened in the domain — `OrderPlaced`, `PaymentSettled`. Other contexts subscribe and react. |
| **Repository** | The collection-like abstraction over persistence for an aggregate. Hides the ORM. |
| **Domain Service** | A piece of domain logic that doesn't naturally live on any one entity. |
| **Strategic DDD** | The big-picture work: subdomain mapping, bounded-context decomposition, context maps, team topology. |
| **Tactical DDD** | The in-the-code work: entities, value objects, aggregates, repositories, domain events. |

Strategic-vs-tactical is the cut that matters most for what follows. **Strategic DDD pays off almost everywhere it's tried.** **Tactical DDD pays off in some languages and ecosystems much more cheaply than in others** — and that's the wedge this article is interested in.

## The honest critique — DDD is hard

Let's be candid. DDD is hard, complicated, and difficult to access for reasons the community rarely admits in print:

> [!WARNING]
> The following is the author's lived experience trying to operationalise DDD on real teams. Mileage varies; consider it field notes rather than received wisdom.

**1. The canonical text is dense and long.** The Blue Book is **560 pages**, written in a measured 2003-Java-architect register. The vocabulary is introduced gradually across hundreds of pages of worked examples, and you need most of it loaded to read any single chapter productively. There is no 30-page primer that does the whole job.

**2. The ecosystem is Java/.NET-shaped.** The vast majority of authoritative DDD writing assumes you have an enterprise OOP language with rich inheritance, mutable objects, and an ORM. Vernon's *Implementing Domain-Driven Design* (2013, Addison-Wesley, ISBN 978-0321834577) is **612 pages of Java** with C# parallels. Khorikov's Pluralsight courses are C# / EF Core. The pattern catalogue (rich domain models, anemic domain model anti-pattern, repository pattern, factory pattern) maps onto a programming style that the FP and BEAM worlds explicitly reject.

**3. Sources are scattered and uneven.** There's no single canonical site (the way React or Phoenix have docs.). You're triangulating between Evans, Vernon, Wlaschin, Khorikov, Brandolini (Event Storming), the DDD-Crew GitHub org, conference talks of varying vintage, blog posts that contradict each other, and the Domain Language community site. None is wrong; few are operational; they don't cohere into a tutorial path.

**4. The gap between books and practice is wide.** The books describe ideal-state systems built greenfield by teams who already know DDD. The actual job is usually retrofitting onto a legacy CRUD app, with stakeholders who don't have time for a glossary workshop, in a language whose idioms fight the tactical patterns. The books don't say much about that fight.

**5. The terminology has a learning tax.** "Aggregate root", "anti-corruption layer", "shared kernel", "open-host service", "published language", "context map" — all useful, all needing 30 minutes of explanation each before a team uses them in conversation. Until the terms are loaded, half of any DDD discussion is definitional and the other half is signalling.

**6. The Java-heavy bias means examples don't translate.** A lot of DDD pattern advice ("inject a factory", "the aggregate's state is mutated through methods", "the repository returns a tracked entity") makes no sense in a language without classes-with-mutable-state, ORM-tracked entities, or DI containers. Translating it to Elixir / Gleam / Rust / OCaml requires you to re-derive the *intent* of each pattern — which is doable, but means you're effectively reinventing DDD from first principles every time.

> [!NOTE]
> None of this is to say DDD is wrong. The conceptual core (Ubiquitous Language, Bounded Contexts, Aggregates as consistency boundaries) survives translation to any paradigm. It's the *delivery* — the books, the patterns, the worked examples — that's encrusted with OOP-isms which obscure the core for newcomers from other ecosystems.

## Where DDD earns its keep — stakeholder alignment

Strip away the tactical patterns and the OOP scaffolding, and what's left is the part that nothing else in mainstream software engineering replaces: **a discipline for getting developers, product managers, and domain experts to use the same vocabulary across code, conversation, and documentation.**

This is the part the author actively uses. The benefit looks like this in practice:

- A subject-matter expert says "the broker doesn't get notified until the policy is bound" in a meeting.
- The Slack channel discussing the bug uses **`policy_bound`** (the exact event name).
- The ticket title is "PolicyBound notification not delivered to broker" — same words.
- The code emits a `PolicyBound` domain event on a `Phoenix.PubSub` topic literally called `"policy_bound"`.
- The test scenario reads `Given a policy is bound, then the broker is notified`.

Five places, one phrase. **No translation between layers.** The cost is upfront — running a glossary workshop, agreeing names, refusing to ship code that uses a synonym ("policy_completed" instead of "policy_bound"). The payoff is permanent — every future bug report, every onboarding doc, every audit conversation reuses the same vocabulary.

This is **Ubiquitous Language inside one Bounded Context**, and it's the highest-leverage practice in the entire DDD toolkit. Most teams do not need aggregate roots or anti-corruption layers; almost every team would benefit from the glossary discipline.

> [!IMPORTANT]
> If you take only one thing from DDD, take Ubiquitous Language + Bounded Contexts. Everything tactical is downstream and optional. The strategic work is what changes how a team operates day to day.

The Bounded Contexts piece compounds the alignment win across teams: it gives you a defensible answer to "whose `Order` is this?" When the shipping team and the billing team mean different things by the same word, naming the contexts (`Shipping.Order` vs `Billing.Order`) and writing the translation rules at the seam is what stops six-month integration arguments.

There's a natural connection here to the [BDD with Gherkin](bdd-with-gherkin.md) world — `Given/When/Then` scenarios written in the Ubiquitous Language are the executable proof that the language is consistent. DDD gives you the vocabulary; Gherkin gives you the test harness for whether you're actually using it. The two practices reinforce each other.

## Maps well to Ash framework (Elixir)

[Ash](https://hexdocs.pm/ash/) ([ash-hq.org](https://ash-hq.org/), tagline *"Model your domain, derive the rest."*) is a declarative, resource-oriented application framework for Elixir. It is — as far as the author has explored the space — the cleanest mainstream mapping of tactical DDD onto a non-Java/non-.NET ecosystem. The pieces line up almost 1:1:

| DDD concept | Ash construct | Notes |
| --- | --- | --- |
| **Aggregate Root** | `Ash.Resource` | A resource module owns its attributes, relationships, and the actions that mutate it. Other code goes through the resource's actions, not its persistence layer. |
| **Bounded Context** | `Ash.Domain` | A domain module groups related resources. The boundary is explicit — domains list the resources they own, and cross-domain interaction is via the domain's public API. |
| **Command / Query separation** | Action types (`:create`, `:update`, `:destroy`, `:read`) | Actions are first-class and named. Read actions return data; mutate actions return `{:ok, record}` or `{:error, changeset}`. |
| **Domain Service / behaviour-rich method** | Custom action with `change` modules | When logic doesn't fit on a single resource, you compose `change` modules to build the behaviour declaratively. |
| **Invariant / Authorization** | `Ash.Policy.Authorizer` | Policies are declarative rules attached to actions. They run in a defined order, can short-circuit, and read like spec text. |
| **Value Object** | Custom `Ash.Type` | Define a custom type with `cast_input` / `dump_to_native` and Ash treats it as a first-class attribute type. |
| **Domain Event** | Notifications + `Phoenix.PubSub` | Ash emits notifications on action completion; you wire them to PubSub topics or to background jobs (Oban / AshOban) without writing event-bus glue. |
| **Repository** | Implicit (data layer) | `AshPostgres`, `AshSqlite`, `AshCsv`, etc. There is no explicit Repository abstraction because the resource *is* the abstraction. |
| **Aggregates (DDD computed-from-children)** | `aggregate :name, :rel, :count` (and friends) | Ash's *aggregates* construct is a slight name collision: in Ash an "aggregate" is a computed value over related records (sum, count, first, etc.), exposed as a queryable field. The DDD concept of an aggregate-as-consistency-boundary is what `Ash.Resource` itself provides. |

The pitch in one sentence: **Ash gives you tactical DDD without the OOP ceremony, declaratively, on the BEAM**. You don't build rich domain objects with mutable state and protected invariants — you declare the resource, the actions, the policies, and Ash derives the consistency boundary, the API, and the persistence wiring from the spec.

> [!NOTE]
> The collision between "Ash aggregate" (computed over children — `count`, `sum`) and "DDD aggregate" (consistency-boundary cluster) is the only naming snag worth flagging up-front. In Ash docs, "aggregate" almost always means the computed-value sense; the consistency-boundary sense is just `Resource`.

What this buys you over hand-rolling DDD in Elixir-with-`Ecto`:

- The **Ubiquitous Language** lives in the resource module names, action names, and attribute names. There's exactly one place a domain expert and a developer can point at to confirm the model.
- **Bounded Contexts** are first-class via `Ash.Domain` rather than being a convention you have to enforce by hand.
- **Policies** make invariants legible to non-Elixir readers (they read like English spec lines), which is exactly the audience DDD is trying to reach.
- **Notifications + PubSub** mean Domain Events are wired in five lines, not five hundred.

The Elixir world has had DDD-curious teams for a decade (the BEAM's actor model maps neatly onto aggregates-as-consistency-boundaries), but Ash is the first widely-adopted framework that makes the mapping declarative. If you've read the Blue Book and gone *"this would be nice without all the Java"*, Ash is the closest payoff currently on offer.

## Currently considering an adjusted approach

> [!NOTE]
> **This section is the author's evolving working take, not received wisdom.** It is the shape of "what a leaner, FP-first, Ash-flavoured DDD looks like in practice" as the author is currently using it. Disagreement is welcome; treat the bullet points as hypotheses, not rules.

Coming from a functional-data-first perspective and an Ash-shaped toolbox, the parts of DDD that earn their keep look different from the canonical pattern catalogue. The adjusted approach the author is currently testing:

**1. Drop the heavyweight OOP scaffolding; keep Ubiquitous Language + Bounded Contexts.**
The strategic core is the durable part. Run the glossary workshop, write the context map, name the contexts in code. Skip the rich-domain-model gymnastics — they exist to defend invariants in a mutable-OOP setting and are largely redundant when the language is FP and the framework is declarative.

**2. Treat aggregates as data + transition functions, not classes with state.**
An aggregate root is a plain data structure (an `Ash.Resource`, an Elixir struct, a Gleam record) and a small set of pure transition functions (or Ash actions) that take the current state plus a command and return the next state plus emitted events. No "rich behaviour on the entity" — behaviour lives in functions, where it can be tested without reflection.

**3. Use the type system as the place where invariants live.**
In an [F#-typed-DDD](https://fsharpforfunandprofit.com/ddd/) / Gleam / Rust / Elixir-with-typespecs setting, the type system can carry invariants the rich-OOP model carries via runtime guards. *Encode an invariant as an unrepresentable illegal state* is more durable than *enforce an invariant in a setter*. Wlaschin's *Domain Modeling Made Functional* is the reference for this style.

**4. Skip "anti-corruption layers" until proven needed.**
ACLs make sense when you're integrating against a legacy system whose model leaks confusion into yours. Adding one preemptively to a clean integration is overhead. Build the seam straight; introduce the ACL when you can name the specific concept that's leaking.

**5. Strategic DDD first, tactical patterns optional.**
Most "DDD adoptions" that fail were tactical-first: pull in repositories, factories, aggregate roots; lose the team in pattern-chasing; never get to the language and context work that would have justified any of it. Reverse the order. Ship the glossary, the context map, and the Ubiquitous Language vocab in code. Add tactical patterns when a specific code-smell justifies a specific pattern.

**6. Domain Events as `Phoenix.PubSub` messages or BEAM mailboxes, not framework-special objects.**
On the BEAM, the message-passing primitive *is* the domain event. You don't need an event bus framework, an event store, an outbox pattern (until you have a specific durability requirement), or a special `DomainEvent` superclass. Emit a tagged tuple to a `Phoenix.PubSub` topic; let other contexts subscribe. The framework already gives you what Java DDD has to scaffold.

**7. Resist the "one DDD concept per file" reflex.**
The Blue Book has separate files for entity, value object, repository, factory, service. In an Ash module, all of these are co-located in one resource declaration, and the result is *more* readable, not less, because the boundaries are declarative rather than inheritance-encoded. Don't refactor to enforce the canonical layout; let the framework's spec be the layout.

**8. Treat the Ubiquitous Language as a deliverable, not a vibe.**
Write the glossary. Commit it to the repo. Update it in the same PR as the code that introduces a new term. Reject PRs that reuse the term for something else, or invent a synonym. The discipline is the value.

The TL;DR of the adjusted approach: **strategic DDD survives the translation to FP wholesale; tactical DDD survives selectively, replaced in many places by the type system and the framework's declarative spec.** The author's current bet is that this delivers most of the alignment benefit at a fraction of the cognitive cost.

## When to use, when NOT to use

DDD has a natural fit-zone. The mistake worth avoiding hardest is applying it where the domain doesn't justify it.

### Use DDD when…

- **The domain has genuine complexity** that subject-matter experts care about and have opinions on — insurance, healthcare, logistics, finance, regulatory compliance. If the domain expert can't list five vocabulary distinctions that matter, the domain probably isn't complex enough yet.
- **The product is long-lived.** Three years, five teams, multiple rewrites in the same problem space. The Ubiquitous Language pays compound interest over years; greenfield prototype value is small.
- **You have multiple bounded contexts in flight.** The moment two teams are arguing about whose `Customer` is real, you need context maps. Before that, you don't.
- **The codebase is "CRUD plus rules"** — most of it is records-with-validations, but there are real invariants (a policy cannot be activated before its premium is paid; a refund cannot exceed the original payment) that need to be defended in code, in policy, and in conversation. DDD is built for this.
- **You have access to domain experts** and they're willing to participate in the language work. DDD without that access degrades into developers inventing vocabulary that doesn't match the business.

### Don't use DDD when…

- **It's plain CRUD with no real domain logic.** A blog, a CMS for marketing pages, an admin UI over a single table. The ceremony cost outweighs the alignment benefit.
- **You're pre-product-market-fit.** The domain model will change three times in the next six months. Investing in the Ubiquitous Language now means writing it three times. Wait until the model has stopped thrashing.
- **Small team, fast iteration, no stakeholders to align.** The alignment benefit needs more than one person to land. A solo developer or a 3-person team without external domain experts does not need a glossary workshop; they have one already, in the team chat.
- **Data-pipeline / ETL / scientific code.** The domain isn't the bottleneck; the pipeline shape is. DDD vocabulary on a Spark job is overhead with no payoff. (Pick the right pattern for the right shape of work.)
- **You're being told to "do DDD" without management buying the language work.** If the org's plan is "developers will adopt the vocabulary by reading the Blue Book in their evenings and then we'll keep shipping", the project will fail. DDD is partly an organisational practice; it needs the time and access to domain experts that practice requires.
- **Tactical-first.** Every time. If the proposed adoption starts with "introduce repositories and factories", abort. Strategic first or not at all.

A useful diagnostic: ask whether the alignment problem is real. *Have we, in the last three months, shipped a bug whose root cause was that two team members meant different things by the same word?* If yes — DDD is for you. If no — there might be cheaper interventions.

## Further reading

**Books — canonical**

- **Eric Evans**, *Domain-Driven Design: Tackling Complexity in the Heart of Software*, Addison-Wesley, 2003. ISBN 978-0321125217. The Blue Book. Long, dense, foundational. ([publisher entry](https://www.oreilly.com/library/view/domain-driven-design-tackling/0321125215/))
- **Vaughn Vernon**, *Implementing Domain-Driven Design*, Addison-Wesley, 2013. ISBN 978-0321834577. The Red Book. 612 pages of Java/C#-flavoured tactical DDD. ([publisher entry](https://www.pearson.com/en-us/subject-catalog/p/implementing-domain-driven-design/P200000009616/9780133039887))
- **Vaughn Vernon**, *Domain-Driven Design Distilled*, Addison-Wesley, 2016. ISBN 978-0134434421. The shorter introduction — strategic DDD focused, ~256 pages. Read this before the Blue Book. ([publisher entry](https://www.oreilly.com/library/view/domain-driven-design-distilled/9780134434964/))

**Books — functional / FP-flavoured**

- **Scott Wlaschin**, *Domain Modeling Made Functional: Tackle Software Complexity with Domain-Driven Design and F#*, Pragmatic Bookshelf, 2018. ISBN 978-1680502541. The first major book to combine DDD with statically-typed FP. Concrete, well-paced, type-system-first. ([Pragprog](https://pragprog.com/titles/swdddf/domain-modeling-made-functional/))

**Author sites & online material**

- **Domain Language community** — [dddcommunity.org](https://www.dddcommunity.org/) — Eric Evans's site; book reference page at [dddcommunity.org/book/evans_2003](https://www.dddcommunity.org/book/evans_2003/).
- **Scott Wlaschin's DDD page** — [fsharpforfunandprofit.com/ddd/](https://fsharpforfunandprofit.com/ddd/) — free talks, slides, and worked F# code modelling DDD with the type system.
- **Vladimir Khorikov** — [enterprisecraftsmanship.com](https://enterprisecraftsmanship.com/) and [Pluralsight courses](https://www.pluralsight.com/authors/vladimir-khorikov). Pragmatist on DDD-in-C#-with-EF-Core; *Domain-Driven Design in Practice*, *Domain-Driven Design: Working with Legacy Projects*, *CQRS in Practice*. Paid but high-quality.

**Strategic / Context Mapping**

- **DDD Crew** — [github.com/ddd-crew](https://github.com/ddd-crew). Community-curated cheat-sheets and canvases. Notable repos:
  - [ddd-crew/context-mapping](https://github.com/ddd-crew/context-mapping) — context map starter kit and cheat sheet.
  - [ddd-crew/bounded-context-canvas](https://github.com/ddd-crew/bounded-context-canvas) — structured template for documenting each bounded context.
- **Context Mapper** — [contextmapper.org](https://contextmapper.org/) — open-source DSL for context maps and a [graphical generator](https://github.com/ContextMapper/context-map-generator) (Graphviz-based, inspired by Vernon and Brandolini).

**Ash Framework (Elixir mapping)**

- [hexdocs.pm/ash](https://hexdocs.pm/ash/) — official API docs (current at snapshot: v3.24.x).
- [ash-hq.org](https://ash-hq.org/) — landing site, tagline *"Model your domain, derive the rest."*
- [hexdocs.pm/ash/get-started.html](https://hexdocs.pm/ash/get-started.html) — concrete walk-through introducing Resources, Actions, Domains.

**Cross-references in this repo**

- [BDD with Gherkin](bdd-with-gherkin.md) — `Given/When/Then` scenarios are the executable proof of Ubiquitous Language consistency.
- [Programming language popularity & desire](programming-languages-popularity-and-desire.md) — context for why the Java/.NET DDD lineage matters less in 2026 than the FP-flavoured derivatives.
