# SupportFlow Technical Decisions

This document records the architectural decisions made for SupportFlow. Each
decision is written as an Architecture Decision Record (ADR) so the team can
explain the trade-offs during the technical defense.

## ADR-001: Use SQLite for Development and Test, with PostgreSQL Readiness

### Context

SupportFlow needs a relational database for its Rails API, including model
associations, validations, enums, indexes, and migrations. The challenge
recommends PostgreSQL, while also allowing SQLite when the choice is clearly
documented.

### Decision

Use SQLite for the development and test environments. Keep the production
configuration PostgreSQL-ready through `backend/config/database.yml` and the
`DATABASE_URL` environment variable.

### Alternatives

- Use PostgreSQL in every environment.
- Use a non-relational database.
- Use SQLite without documenting a production migration path.

### Rationale

SQLite provides a zero-configuration relational database that is portable for a
short team challenge and works well with the current Rails data model. It keeps
local setup and automated test execution simple while preserving Rails
migrations and Active Record behavior. PostgreSQL remains the intended
production option and is already represented in the production database
configuration.

### Trade-offs

- SQLite is easier to install and reset locally, but it does not reproduce all
  PostgreSQL behavior or concurrency characteristics.
- Keeping PostgreSQL readiness requires environment-specific configuration and
  a production deployment validation step.
- The team must avoid SQLite-specific SQL if the application is later moved to
  PostgreSQL.

### Consequences

Developers can run the application and test suite without a database service.
The database choice is explicit and defensible against the challenge
requirements. A future deployment can use PostgreSQL by supplying the
production connection configuration and validating any database-specific
queries.

## ADR-002: Use RSpec for Backend Testing

### Context

The Rails API needs automated coverage for model validations, business rules,
request behavior, controller responses, and error handling. Rails supports
Minitest by default, while the challenge accepts either RSpec or Minitest.

### Decision

Use RSpec as the backend testing framework, supplemented by FactoryBot,
Shoulda Matchers, and Faker for test data and readable assertions.

### Alternatives

- Use Rails' default Minitest framework.
- Use hand-built test records without a factory library.
- Rely primarily on manual API verification.

### Rationale

RSpec's `describe` and `it` structure makes domain behavior and API contracts
easy to read during development and review. The repository already contains
RSpec configuration, model specs, request specs, controller specs, factories,
and supporting test gems, so this decision matches the implemented test suite.

### Trade-offs

- RSpec adds development and test dependencies compared with the Rails
  default.
- Factories and expressive matchers require team familiarity and can make
  setup more verbose than a very small Minitest example.
- A broad suite can take longer to run than only testing a few happy paths.

### Consequences

Backend behavior is verified with repeatable tests run through
`bundle exec rspec`. Factories provide consistent, readable records, while
request and model specs provide regression protection for the API and business
rules.

## ADR-003: Use Pinia for Vue State Management

### Context

The frontend shares support requests, team members, dashboard metrics, filter
state, loading state, error state, and toast notifications across views and
components. Those values should not be passed through long chains of props.

### Decision

Use Pinia as the centralized state management library for the Vue 3 frontend.
Organize shared state into focused stores under `frontend/src/stores`.

### Alternatives

- Use Vuex.
- Keep all state local to components and pass it through props and events.
- Use a custom event bus or ad hoc module-level state.

### Rationale

Pinia is the official state management approach for Vue 3 and provides a small,
direct API without mandatory mutations. It supports focused stores and fits the
Composition API used by the application. The repository already implements
stores for support requests, team members, dashboard data, and toast messages.

### Trade-offs

- Pinia introduces a frontend dependency and store conventions the team must
  maintain.
- Shared state can become difficult to reason about if stores contain too much
  view-specific behavior.
- Developers familiar with Vuex must learn Pinia's direct state and action API.

### Consequences

Views can share API data and UI state consistently across navigation. API calls,
loading indicators, errors, filters, and notifications have a clear home,
while components remain focused on presentation and user interaction.

## ADR-004: Use a Monorepo with Separate Backend and Frontend Applications

### Context

SupportFlow consists of a Rails JSON API and a Vue/Vite client that evolve
together and must be demonstrated as one product. The challenge recommends a
monorepo and expects the repository to contain the application files,
documentation, tests, and setup configuration.

### Decision

Keep both applications in one repository with this top-level structure:

```text
support-flow/
├── backend/     # Rails API, models, migrations, seeds, and RSpec suite
├── frontend/    # Vue 3/Vite client, views, components, and Pinia stores
├── docs/        # API and UI documentation
├── README.md
└── DECISIONS.md
```

The backend and frontend retain independent dependency manifests and local
commands while sharing Git history, issue scope, documentation, and review
workflow.

### Alternatives

- Maintain separate repositories for the Rails API and Vue application.
- Put both applications into one framework-specific directory structure.
- Use a monorepo with a shared workspace and unified dependency tooling.

### Rationale

A monorepo makes the API/frontend contract, coordinated changes, and complete
challenge submission easy to inspect. Separate `backend/` and `frontend/`
directories preserve the native Rails and Vite workflows without introducing
additional workspace tooling for a small application.

### Trade-offs

- The repository contains two dependency trees and requires developers to run
  commands from the appropriate directory.
- Backend and frontend changes can be coupled in one commit even when they are
  independently deployable.
- A larger future team may need additional ownership or CI boundaries.

### Consequences

The full application, tests, documentation, and configuration can be cloned
and reviewed together. API and UI changes can be coordinated through one pull
request, while each application remains independently runnable and testable.

