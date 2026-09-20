# A percentage off the whole order, taken after promotions.
class DiscountCode < ApplicationRecord
  validates :code, presence: true, uniqueness: true
  validates :name, presence: true
  validates :percent, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 100 }

  def apply(subtotal_cents)
    deduction = (subtotal_cents * percent / BigDecimal(100)).round(0, :half_up).to_i
    Adjustment.new(label: name, code: code, amount_cents: -deduction)
  end
end
