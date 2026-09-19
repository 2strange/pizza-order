class CreateMenu < ActiveRecord::Migration[8.1]
  def change
    create_table :pizzas do |t|
      t.string :name, null: false, index: { unique: true }
      t.integer :base_price_cents, null: false
      t.timestamps
    end

    create_table :ingredients do |t|
      t.string :name, null: false, index: { unique: true }
      t.integer :extra_price_cents # nil: part of a recipe only, not orderable as an extra
      t.timestamps
    end

    # A pizza's standard recipe.
    create_join_table :pizzas, :ingredients do |t|
      t.index [ :pizza_id, :ingredient_id ], unique: true
    end
  end
end
