# Pizza Order

A small, complete pizza ordering app: browse the menu, configure a pizza (size, extras,
leave out ingredients), watch the price update live, redeem promotion and discount codes,
place the order. No payment, no login — the point is the **domain model** behind the price.

Built as a weekend iteration after feedback on a coding challenge that asked for the
same pricing rules as a plain Ruby library. This time the rules live in real domain
objects (`Pizza`, `Order`, `OrderItem`, `Promotion`, …) inside a Rails + Vue app.

## Stack

- **Ruby on Rails 8.1** — monolith, SQLite
- **Vue 3** islands inside Rails views, bundled by **Vite** (`vite_rails`)
- Plain CSS with design tokens in one stylesheet — no CSS framework
- Tests on three levels: **RSpec** (domain + requests), **Vitest** (components), **Cypress** (end-to-end)

## Getting started

```bash
bundle install && npm install
bin/rails db:prepare
bin/dev            # Rails + Vite dev server → http://localhost:3000
```

## Tests

```bash
bundle exec rspec  # domain + request specs
npx vitest run     # component specs
bin/e2e            # Cypress against a test-mode server
```

CI runs all three plus RuboCop and Brakeman on every push and pull request.

## Timeline

Every step is stamped by GitHub, not by hand. Times are UTC.

| When | What | Proof |
|---|---|---|
| 2026-09-19 08:44 | Repository created | repository metadata |
| 2026-09-19 08:45 | Kickoff | [issue #1](../../issues/1) |
| 2026-09-19 08:55 | First commit: scaffold with three-level tests; first CI run, red (the RSpec job had no Node for the Vite build) | [run](../../actions/runs/35433306081) |
| 2026-09-19 09:11 | Domain model on `main`; first green CI run | [run](../../actions/runs/35434025871) |
| 2026-09-19 09:30 | JSON API and ordering UI on `main` | [run](../../actions/runs/35434853784) |
| 2026-09-19 13:44 – 15:10 | Pizzeria look: tokens, three themes, one cartoon pizza per menu item | commits |
| 2026-09-20 07:19 | Readable names for promotions and discount codes; feature complete | [run](../../actions/runs/35496548369) |
| 2026-09-20 | Release | [releases](../../releases) |

Wall-clock, the app took one Saturday session and a short Sunday morning, including the
waits for human review between steps. The [decision log](docs/decisions.md) carries the
finer-grained times per decision.

## Decision log

See [`docs/decisions.md`](docs/decisions.md) — every non-obvious choice with the
alternative that was rejected and why.

## How this was built

Solo project, built with an agent team (Claude + Codex) doing the typing under my
direction. Every design decision, every review and every merge is mine; the decision
log records what was discussed. See [`docs/workflow.md`](docs/workflow.md).
