# Turns the body of a quote or order request — menu ids, sizes, quantities and
# codes, nothing priced — into an Order with its items. Ids that point nowhere
# raise UnknownReference; whether the assembled order is valid is the order's
# own business.
class OrderBuilder
  UnknownReference = Class.new(ArgumentError)

  def self.build(attributes) = new(attributes).build

  def initialize(attributes)
    @attributes = attributes.to_h.symbolize_keys
  end

  def build
    order = Order.new(customer_name: @attributes[:customer_name],
                      promotion_codes: Array(@attributes[:promotion_codes]),
                      discount_code: @attributes[:discount_code])
    Array(@attributes[:items]).each { |item| order.order_items.build(item_attributes(item)) }
    order
  end

  private

  def item_attributes(item)
    item = item.to_h.symbolize_keys
    { pizza: Pizza.find(item[:pizza_id]),
      size: item[:size],
      quantity: item.fetch(:quantity, 1),
      extras: Ingredient.find(Array(item[:extra_ids])),
      removed_ingredients: Ingredient.find(Array(item[:removed_ingredient_ids])) }
  rescue ActiveRecord::RecordNotFound => e
    raise UnknownReference, e.message
  end
end
