# Decision log

Format: **when (UTC) · decision · rejected alternative · why**.

## 2026-09-19

- **08:47 · Rails 8.1 monolith with Vue 3 islands via Vite.** Rejected: separate Nuxt
  frontend against a Rails API. Why: one app, one deploy, no auth/JWT plumbing — the
  interesting part is the domain, not the transport.
- **08:47 · No CSS framework.** Rejected: Tailwind, Vuetify. Why: a handful of
  components does not justify a framework; design tokens in one stylesheet keep themes
  (light/dark, …) trivial and the markup clean.
- **08:50 · Tests on three levels: RSpec, Vitest, Cypress.** Rejected: RSpec system
  specs with Capybara for everything. Why: each level uses the tool its ecosystem
  expects; Cypress runs against a real test-mode server (`bin/e2e`).
- **08:52 · Propshaft removed.** Rejected: keeping the default asset pipeline next to
  Vite. Why: two asset pipelines for one stylesheet is one too many.
- **08:54 · Ruby 3.4.10.** Rejected: Ruby 3.2.6 (the version the original challenge
  pinned). Why: 3.2 reached end of life in March 2026 — Brakeman flags it, and a fresh
  app should not start on an unsupported runtime.
- **09:02 · `json` gem pinned to 2.x.** Rejected: living with json 3.0.2 from the
  scaffold's lockfile. Why: json 3.0 dropped the positional options hash that
  `ActiveSupport::JSON.decode` in Rails 8.1.3 still passes — JSON columns and
  `response.parsed_body` blow up. Drop the pin once Rails catches up.
- **09:04 · Money is integer cents; a multiplier or percentage is applied as
  BigDecimal and rounded half up to a whole cent at each point where a price is
  born:** the size-scaled base, the size-scaled extras, the discount. Rejected:
  carrying sub-cent precision through to the total and rounding once. Why: a unit
  price on a receipt is a whole-cent amount, and freezing it on the order item
  requires that anyway. Floats never touch money.
- **09:04 · `Size` is a value object in code, not a table or an enum.** Rejected:
  a `sizes` table seeded from `menu.json`; a Rails enum. Why: three fixed sizes with
  a label and a multiplier are a rule of the menu, not customer data; a small
  `ActiveModel::Type` lets records hold a `Size` directly. `menu.json` keeps the
  multipliers for completeness and the seeds refuse to run if they drift from code.
- **09:05 · Order items freeze their prices when the order is placed.** Rejected:
  recomputing from the live menu; snapshotting the inputs (base price, multiplier,
  every extra) instead of the result. Why: a placed order must survive a price
  change; the two frozen numbers (`base_price_cents`, `extras_price_cents`) are
  exactly what promotions and the receipt need. Until the order is saved the same
  methods compute live prices, so the cart quote and the receipt share one code path.
- **09:05 · Recipes and item extras/removals as HABTM join tables.** Rejected:
  explicit join models. Why: the joins carry no data of their own; four extra
  classes would be ceremony.
- **09:07 · Promotions apply in the order the codes were given, and a pizza takes
  part in at most one deal.** Rejected: picking the combination that is cheapest for
  the customer; letting the paid pizzas of one deal count again for the next. Why:
  order-of-codes is predictable and cheap to explain; re-counting paid pizzas would
  let two copies of the same deal free three pizzas out of four. A promotion returns
  one immutable `Adjustment` naming the units it covers, so the next promotion
  knows what is taken without anything being mutated.
- **09:07 · Unknown codes fail loudly.** Rejected: ignoring a code that does not
  exist. Why: silently charging full price is the one thing a customer will notice
  and never forgive; the order is invalid with the code named in the message.
- **09:07 · Promotion codes live on the order as a JSON list, the discount code as
  a string.** Rejected: an `order_promotions` join table. Why: codes are what the
  customer typed; the order resolves them to records when it prices itself, and
  there is nothing to join on but the code.
- **09:24 · Codex review: the receipt is frozen when the order is placed.**
  `Order#place!` stamps `placed_at` and stores the adjustments (label, amount) and
  the total next to the already frozen item prices; `#quote` serves that receipt for
  a placed order and prices live only for a cart. Rejected: recomputing every order
  from the current menu and codes. Why: a discount changed from 5 to 10 % or a
  promotion deleted after the fact must not rewrite what a customer paid — the
  golden order stays 16.29 whatever happens to the menu.
- **09:24 · A placed order and its items are read-only** (`readonly?` keyed on the
  placed_at in the database, so the placing save itself still goes through).
  Rejected: a `status` column with a state machine. Why: there is exactly one
  transition, cart → placed, and ActiveRecord's own `ReadOnlyRecord` says everything.
- **09:24 · Frozen item prices are always computed from pizza, size and extras;
  assigned values are overwritten on save.** Rejected: trusting a pre-filled column
  (`super || live`). Why: the columns are a snapshot, not an input — a request must
  not be able to set its own price.
- **09:24 · `Order#quote` validates first and raises `ActiveRecord::RecordInvalid`.**
  Rejected: documenting "call `valid?` before `quote`" and letting an invalid order
  raise whatever it hits (`UnknownCode`, `NoMethodError`). Why: one exception type
  with the full error list is what a controller wants to map to 422; a placed order
  skips validation, since its codes may be gone. `Order::UnknownCode` stays internal.
- **09:24 · `quantity` is capped at `OrderItem::MAX_QUANTITY` (50) and
  `promotion_codes` must be a list of strings (nil means none).** Rejected: leaving
  both to the UI. Why: a JSON column accepts any shape; the model, not the client,
  decides what an order is.
