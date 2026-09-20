# "from" pizzas of one kind and size for the price of "to" — two small Salami for
# one. The free pizzas' base price is waived; their extras stay payable.
class Promotion < ApplicationRecord
  belongs_to :pizza

  attribute :size, Size::Type.new

  validates :code, presence: true, uniqueness: true
  validates :name, presence: true
  validates :size, presence: { message: "is not a known size" }
  validates :from_quantity, numericality: { only_integer: true, greater_than: 1 }
  validates :to_quantity, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validate { errors.add(:to_quantity, "must be less than from") if to_quantity.to_i >= from_quantity.to_i }

  # The adjustment this promotion earns on the order, or nil. The deal applies as
  # often as the order allows (four pizzas → two groups of two). A pizza takes part
  # in at most one deal: `claimed` maps items to units an earlier promotion already
  # covers, and those are left alone.
  def apply(order, claimed = {})
    units = order.order_items.select { |item| applies_to?(item) }
                 .flat_map { |item| [ item ] * (item.quantity - claimed.fetch(item, 0)) }
    groups = units.size / from_quantity
    return if groups.zero?

    in_deal = units.first(groups * from_quantity)
    free = in_deal.first(groups * (from_quantity - to_quantity))

    Adjustment.new(label: name, code: code, amount_cents: -free.sum(&:base_price_cents), units: in_deal.tally)
  end

  def applies_to?(item)
    item.pizza_id == pizza_id && item.size == size
  end
end
