# The domain's invariants, stated in the database as well: the model validations
# keep a bad row out of the app, these keep one out of the table.
class AddCheckConstraints < ActiveRecord::Migration[8.1]
  def change
    add_check_constraint :pizzas, "base_price_cents > 0", name: "pizzas_base_price_positive"
    add_check_constraint :ingredients, "extra_price_cents IS NULL OR extra_price_cents > 0", name: "ingredients_extra_price_positive"
    add_check_constraint :order_items, "quantity BETWEEN 1 AND 50", name: "order_items_quantity_in_range" # OrderItem::MAX_QUANTITY
    add_check_constraint :order_items, "base_price_cents >= 0 AND extras_price_cents >= 0", name: "order_items_prices_not_negative"
    add_check_constraint :discount_codes, "percent BETWEEN 1 AND 100", name: "discount_codes_percent_in_range"
    add_check_constraint :promotions, "from_quantity > 1 AND to_quantity >= 0 AND to_quantity < from_quantity", name: "promotions_quantities_consistent"
  end
end
