# An ingredient is either part of a recipe only (no extra price) or can also be
# added to any pizza as a paid extra.
class Ingredient < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates :extra_price_cents, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true

  scope :extras, -> { where.not(extra_price_cents: nil) }

  def extra?
    extra_price_cents.present?
  end
end
