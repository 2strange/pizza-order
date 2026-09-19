class AddForeignKeysToJoinTables < ActiveRecord::Migration[8.1]
  def change
    add_foreign_key :ingredients_pizzas, :pizzas
    add_foreign_key :ingredients_pizzas, :ingredients
    add_foreign_key :order_item_extras, :order_items
    add_foreign_key :order_item_extras, :ingredients
    add_foreign_key :order_item_removals, :order_items
    add_foreign_key :order_item_removals, :ingredients
  end
end
