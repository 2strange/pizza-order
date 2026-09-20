# A change to an order's price, always explained: a promotion waiving pizzas or a
# discount on the sum. `label` is the readable name for the receipt, `code` what
# the customer typed, `kind` which of the two it turned out to be. `units` records
# how many units of which item the adjustment covers (empty for a discount).
# Immutable — an adjustment describes, it never changes the order.
Adjustment = Data.define(:label, :code, :kind, :amount_cents, :units) do
  def initialize(label:, code:, kind:, amount_cents:, units: {}) = super
end
