# Decision log

Format: **when (UTC) · decision · rejected alternative · why**.

## 2026-09-19

- **09:00 · Rails 8.1 monolith with Vue 3 islands via Vite.** Rejected: separate Nuxt
  frontend against a Rails API. Why: one app, one deploy, no auth/JWT plumbing — the
  interesting part is the domain, not the transport.
- **09:00 · No CSS framework.** Rejected: Tailwind, Vuetify. Why: a handful of
  components does not justify a framework; design tokens in one stylesheet keep themes
  (light/dark, …) trivial and the markup clean.
- **09:10 · Tests on three levels: RSpec, Vitest, Cypress.** Rejected: RSpec system
  specs with Capybara for everything. Why: each level uses the tool its ecosystem
  expects; Cypress runs against a real test-mode server (`bin/e2e`).
- **09:20 · Propshaft removed.** Rejected: keeping the default asset pipeline next to
  Vite. Why: two asset pipelines for one stylesheet is one too many.
- **09:40 · Ruby 3.4.10.** Rejected: Ruby 3.2.6 (the version the original challenge
  pinned). Why: 3.2 reached end of life in March 2026 — Brakeman flags it, and a fresh
  app should not start on an unsupported runtime.
