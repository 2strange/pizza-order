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
- **08:54 · Ruby 3.4.** Rejected: Ruby 3.2.6 (the version the original challenge
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
- **09:19 · The JSON API renders through two small presenter classes
  (`QuotePresenter`, `OrderPresenter`) and plain `render json:`.** Rejected: jbuilder
  views; a serializer gem; `Quote#as_json` on the domain object. Why: the wire shape
  (names instead of records, receipt parts per line) is a concern of the interface,
  not of the value object that prices the order; two 30-line classes need no gem.
- **09:19 · `OrderBuilder` assembles an `Order` from a request body; quotes and orders
  share it.** Rejected: `Order.from_params` on the model; building in each controller.
  Why: the model should not know what a request looks like, and a quote is just an
  order that is priced but not saved — the same builder guarantees that both endpoints
  price exactly the same thing. Ids that point nowhere are rejected with 422, never
  silently dropped: an extra the customer asked for must not vanish from the price.
- **09:19 · Item errors surface on the order (`has_many …, autosave: true`).** Rejected:
  collecting item errors by hand in the controller. Why: Rails already copies nested
  errors onto the parent for autosaved associations — "Order items size is not a known
  size" instead of "Order items is invalid" — and nothing else changes for a new order.
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
- **11:30 · The cart shows only what the server quoted.** Rejected: rendering cart
  lines from the client's own item list with names looked up in the menu. Why: one
  source of truth for the receipt — the quote carries names, parts and sums, so the
  cart in progress and the confirmation are the same `PriceBreakdown` over the same
  JSON, and no price or label is ever assembled in the browser.
- **11:30 · A code the server refuses is dropped again right away.** Rejected: keeping
  the bad code and marking the quote stale. Why: the quote on screen must always be
  one the server stands behind; the message stays visible at the field, the cart
  keeps the last valid price, nothing has to be recomputed.
- **11:30 · Themes are token overrides on `html[data-theme]`, chosen at start from the
  system preference and remembered in `localStorage`.** Rejected: a
  `prefers-color-scheme` media query in CSS as well. Why: the dark palette would
  have to be written twice; one attribute set by three lines of script covers both
  the system default and the toggle.
- **11:30 · `bin/e2e` seeds explicitly.** Rejected: relying on `db:prepare`. Why:
  `db:prepare` seeds only a database it has just created; a test database left by
  RSpec is empty (transactional fixtures roll the seeds back), and Cypress needs
  the menu. `db:seed` is idempotent, so running it twice costs nothing.
- **11:30 · Amounts are formatted by `Intl.NumberFormat("de-DE")` — "16,29 €".**
  Rejected: hand-rolled formatting; "€ 16,29". Why: the platform knows the German
  convention (symbol after the number, non-breaking space); the division by 100
  happens after every price has been decided by the server.
- **09:40 · `main` was rewritten once.** A `fixup!` commit reached `main` by mistake and
  was force-pushed away minutes later, squashed into the commit it belonged to. Rejected:
  leaving it. Why: the tree is byte-identical either way; the history should read as it
  was meant. Lesson: merge the SHAs an agent reports, never the branch it is still on.
- **13:44 · Themes stay pure token overrides; where a theme needs a different
  shape, the shape is a token too** (`--radius-pill`, `--prompt`, `--pizza-stroke`,
  `--bg-pattern`). Rejected: theme-scoped component selectors
  (`html[data-theme="nerd"] .cart { … }`). Why: one place per theme, no theme
  knowledge below the token block; the nerd look (square corners, a `> ` before
  headings, wireframe pizzas) is a block of values, not a second stylesheet.
- **13:44 · One SVG per pizza, drawn from its recipe, every ingredient its own
  token.** Rejected: photos; one generic pizza tinted per name; an icon font.
  Why: the menu has six pizzas and the art is the product's face — the mushrooms
  on the Funghi are the mushrooms on the plate. No olives on any pizza because no
  recipe has them (olives are an extra). Nerd draws the same shapes as wireframes
  by setting the fills to the surface colour and `--pizza-stroke` to the text
  colour, so a new pizza needs no theme work.
- **13:44 · The theme switch is a segmented group of buttons, not a
  dropdown.** Rejected: `<select>`; a popover menu. Why: three options fit one row,
  every option is visible and one tap away, `aria-pressed` says which is on, and
  the e2e test's `cy.contains('button', 'Dunkel')` keeps working. Shift-click on
  any option turns on the Commodore easter egg (`c64`); it is not listed, so it
  cannot be chosen by accident and is left by choosing any listed theme.
- **13:44 · System font stacks only.** Rejected: a hosted display font for the
  trattoria feel. Why: no third-party request for a menu that is a list, and
  `ui-rounded` / the platform's rounded face carries the cartoon tone where it
  exists while falling back to `system-ui` without a layout shift.
- **13:44 · The oven on the confirmation page is inline SVG in
  `OrderConfirmation.vue`, coloured by `--oven-*` tokens.** Rejected: a component
  of its own; a raster image. Why: it is used once, has no props, and the same
  token rules let every theme keep its own oven.
- **15:10 · Three themes: light, dark, nerd — the "human" theme (rounded sans,
  borderless cards on a shadow) is dropped.** Rejected: keeping it as a fourth
  option. Why: next to the trattoria light theme it was a second warm light look
  with no job of its own; a soft variant earns its place beside a terminal look,
  not beside a pizzeria. A remembered `human` falls back to the system
  preference. The `c64` easter egg stays.

## 2026-09-20

- **07:15 · Promotions and discount codes carry a readable `name`; the receipt
  shows it, the code travels alongside.** `Adjustment.label` is now the name,
  `Adjustment.code` the code the customer typed; the JSON adjustment is
  `{label, code, amount_cents}` and the frozen receipt stores both. Rejected:
  deriving a name from the code in the seeds; keeping the code as the label. Why:
  `ZWEIKLEINESALAMIFUEREINS` is what you type, not what a receipt should say, and a
  name cannot be guessed from a code — `menu.json` requires it per code.
- **08:30 · Ruby 3.4.2, the version the target hosts run.** Rejected: 3.4.10 (the
  newest patch release, used until now). Why: one Ruby everywhere — CI, the developer's
  machine and the servers — beats being three patch releases ahead of production; 3.4 is
  supported either way.
- **11:55 · One code field.** The customer has "a code"; the domain has two kinds
  (promotions, several; one discount on the sum). Rejected: two fields, one per
  kind — correct to the rules, but it asks the customer to know what the code is.
  Why: the server sorts each code (`OrderBuilder`), refuses an unknown one or a
  second discount with a message the field shows at once, and the chips say what
  the code turned out to be. The domain did not change, only the doorway.
- **12:10 · Link preview and language.** Open Graph and Twitter tags with an absolute
  `og:image` (1200×630, the Margherita on the parchment), `lang="de"` (the UI is
  German), the Margherita as favicon. Rejected: leaving it to the messenger's
  fallback. Why: a link gets forwarded; the first thing anyone sees is the card.
- **13:05 · Second review round (Codex), fixed before the repo goes out.** The configurator
  showed extras at menu price while small and large pizzas are charged scaled — now every
  price in the configurator is the chosen size's price, rounded the way `Size#scale` rounds;
  the cart still trusts only the server's quote. A cart change marks the quote stale at once
  (no ordering on a stale total during the debounce). `GET /orders/:id` is gone: sequential
  ids would have handed out any receipt; nothing used it. A name is required to place
  (`on: :place`), quotes carry none. A body with the wrong shape is refused with 422 instead
  of having keys dropped. The Rails generator leftovers (PWA, mailer, job skeletons,
  `allow_browser`) are removed; `bin/dev` now does what the README says.

## 2026-09-21

- **08:51 · Third review round (Claude Fable 5.1), read-only against `main`, then the
  findings applied in one branch.** The domain was found sound; what follows is the tuning.
- **08:55 · Codes are case-insensitive: trimmed and upcased at the door (`OrderBuilder`) and
  `normalizes :code` on both code models.** Rejected: leaving it to the customer to type
  `ZWEIKLEINESALAMIFUEREINS` in capitals; matching case-insensitively in the query. Why: a
  code is what it says, however it was typed, and a canonical spelling lets the order
  store, the receipt show and the chip echo the same string. The field upcases as well, so
  the chip never disagrees with the receipt.
- **08:55 · A code is unique across both kinds.** Each model refuses a code the other
  already has. Rejected: one `codes` table with a type column. Why: the builder decides the
  kind by which table knows the code; the same code in both would have made a promotion win
  silently. Two validations close that, a table merge would not have paid for itself.
- **08:58 · `Order#promotions` and `#discount` look their records up once.** Rejected: leaving
  the lookups as they were. Why: the validation and the pricing both ask; with nine queries
  for a quote of one line and two codes, every code was fetched three times. The memo is
  reset when the codes are assigned and on `reload`.
- **09:00 · The domain's invariants are CHECK constraints as well:** positive prices, the
  quantity range, the percent range, `to < from` on a promotion. Rejected: trusting the
  validations alone; NOT NULL on the receipt columns. Why: SQLite and Rails support CHECK,
  and a row that no model would accept should not exist however it got there. NOT NULL on
  `placed_at`, `total_cents`, `adjustments` was tried and rejected: `place!` has to save in
  two steps (the items turn read-only the moment the order row carries `placed_at`), so the
  columns are empty for one statement. It stays a model invariant, documented on `place!`.
- **09:02 · `POST /orders` is rate-limited, ten per address and minute, with a 429 and a
  message in the JSON shape the client knows.** Rejected: no limit. Why: a public page with
  no login and sequential order numbers; the test environment now caches in memory so the
  limiter can be tested.
- **09:05 · Unit specs for `Promotion`, `DiscountCode`, `OrderBuilder`, the seeds and the
  constraints; a second Cypress flow (remove a line, remove a code).** Rejected: relying on
  the request specs, which covered all of it indirectly. Why: the models are the point of
  the project and should state their rules themselves; the seeds' drift guard and
  idempotence were untested; the browser only knew the happy path.
- **09:05 · The last Vitest spec on `main` referenced an undefined `api` and failed locally
  on both worktrees; it now builds its fake like the others.** Kept as a note: the merge
  went through on a green badge that did not cover it.
