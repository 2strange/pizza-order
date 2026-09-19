# One line of an order: a pizza in a size, with extras added and standard
# ingredients left out, times a quantity.
#
# Prices are live while the order is being composed and frozen when it is
# placed, so a later menu change never alters what a customer was charged.
class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :pizza
  has_and_belongs_to_many :extras, class_name: "Ingredient", join_table: :order_item_extras
  has_and_belongs_to_many :removed_ingredients, class_name: "Ingredient", join_table: :order_item_removals

  attribute :size, Size::Type.new

  validates :size, presence: { message: "is not a known size" }
  validates :quantity, numericality: { only_integer: true, greater_than_or_equal_to: 1 }
  validate :extras_are_priced, :removed_ingredients_are_standard

  before_create :freeze_prices

  # Base price of one pizza in this size.
  def base_price_cents
    super || size.scale(pizza.base_price_cents)
  end

  # Extras of one pizza, scaled by the size like the pizza itself.
  def extras_price_cents
    super || size.scale(extras.sum(&:extra_price_cents))
  end

  def unit_price_cents = base_price_cents + extras_price_cents
  def line_price_cents = unit_price_cents * quantity

  private

  def freeze_prices
    self.base_price_cents = base_price_cents
    self.extras_price_cents = extras_price_cents
  end

  def extras_are_priced
    extras.reject(&:extra?).each do |ingredient|
      errors.add(:extras, "#{ingredient.name} is not available as an extra")
    end
  end

  def removed_ingredients_are_standard
    return if pizza.nil?

    (removed_ingredients - pizza.ingredients).each do |ingredient|
      errors.add(:removed_ingredients, "#{ingredient.name} is not on a #{pizza.name}")
    end
  end
end
