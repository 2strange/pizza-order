# What an order costs and why: the items, every adjustment applied to them, and the
# resulting sums. Built by Order#quote; rendered by the UI, never stored.
Quote = Data.define(:items, :adjustments) do
  def subtotal_cents = items.sum(&:line_price_cents)
  def total_cents = subtotal_cents + adjustments.sum(&:amount_cents)
end
