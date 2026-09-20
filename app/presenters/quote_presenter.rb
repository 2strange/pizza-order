# The JSON shape of a Quote: names instead of records, every amount in cents,
# each line with the parts the receipt shows (base + extras = unit × quantity).
class QuotePresenter
  def initialize(quote)
    @quote = quote
  end

  def to_h
    { items: @quote.items.map { |item| item_hash(item) },
      adjustments: @quote.adjustments.map { |a| { label: a.label, code: a.code, amount_cents: a.amount_cents } },
      subtotal_cents: @quote.subtotal_cents,
      total_cents: @quote.total_cents }
  end

  private

  def item_hash(item)
    { pizza: item.pizza.name,
      size: item.size.label,
      quantity: item.quantity,
      extras: item.extras.map(&:name),
      removed: item.removed_ingredients.map(&:name),
      base_price_cents: item.base_price_cents,
      extras_price_cents: item.extras_price_cents,
      unit_price_cents: item.unit_price_cents,
      line_price_cents: item.line_price_cents }
  end
end
