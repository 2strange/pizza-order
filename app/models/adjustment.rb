# A change to an order's price, always explained by a label: a promotion waiving
# pizzas or a discount on the sum. `units` records how many units of which item
# the adjustment covers (empty for a discount). Immutable — an adjustment
# describes, it never changes the order.
Adjustment = Data.define(:label, :amount_cents, :units) do
  def initialize(label:, amount_cents:, units: {}) = super
end
