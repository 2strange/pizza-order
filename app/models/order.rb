# A customer's order: pizzas, the promotion codes redeemed on them and at most one
# discount code. The price is never stored; Order#quote derives it from the items
# and codes, so the quote for a cart in progress and the receipt of a placed order
# come from the same place.
class Order < ApplicationRecord
  UnknownCode = Class.new(StandardError)

  has_many :order_items, dependent: :destroy

  validates :order_items, presence: true
  validate :codes_are_known

  # Pricing order: line prices → promotions, in the order the codes were given,
  # each pizza in at most one deal → discount on what is left.
  def quote
    promotion_adjustments = promotions.each_with_object([]) do |promotion, applied|
      adjustment = promotion.apply(self, claimed_units(applied))
      applied << adjustment if adjustment
    end

    remaining = order_items.sum(&:line_price_cents) + promotion_adjustments.sum(&:amount_cents)
    discount_adjustment = discount&.apply(remaining)

    Quote.new(items: order_items.to_a, adjustments: [ *promotion_adjustments, *discount_adjustment ])
  end

  def total_cents = quote.total_cents

  def promotions
    promotion_codes.map do |code|
      Promotion.find_by(code: code) or raise UnknownCode, "Unknown promotion code: #{code}"
    end
  end

  def discount
    return if discount_code.blank?

    DiscountCode.find_by(code: discount_code) or raise UnknownCode, "Unknown discount code: #{discount_code}"
  end

  private

  def claimed_units(adjustments)
    adjustments.map(&:units).reduce({}) { |all, units| all.merge(units) { |_item, a, b| a + b } }
  end

  def codes_are_known
    promotions
    discount
  rescue UnknownCode => e
    errors.add(:base, e.message)
  end
end
