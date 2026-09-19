class CreateOrders < ActiveRecord::Migration[8.1]
  def change
    create_table :orders do |t|
      t.string :customer_name
      t.json :promotion_codes, null: false, default: []
      t.string :discount_code
      t.timestamps
    end

    create_table :order_items do |t|
      t.references :order, null: false, foreign_key: true
      t.references :pizza, null: false, foreign_key: true
      t.string :size, null: false
      t.integer :quantity, null: false, default: 1
      # Prices are frozen when the order is placed (see OrderItem#freeze_prices).
      t.integer :base_price_cents, null: false
      t.integer :extras_price_cents, null: false
      t.timestamps
    end

    create_join_table :order_items, :ingredients, table_name: :order_item_extras do |t|
      t.index [ :order_item_id, :ingredient_id ], unique: true
    end

    create_join_table :order_items, :ingredients, table_name: :order_item_removals do |t|
      t.index [ :order_item_id, :ingredient_id ], unique: true
    end
  end
end
