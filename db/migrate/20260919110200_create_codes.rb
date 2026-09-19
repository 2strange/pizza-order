class CreateCodes < ActiveRecord::Migration[8.1]
  def change
    # "from" pizzas of the target for the price of "to", e.g. two small Salami for one.
    create_table :promotions do |t|
      t.string :code, null: false, index: { unique: true }
      t.references :pizza, null: false, foreign_key: true
      t.string :size, null: false
      t.integer :from_quantity, null: false
      t.integer :to_quantity, null: false
      t.timestamps
    end

    create_table :discount_codes do |t|
      t.string :code, null: false, index: { unique: true }
      t.integer :percent, null: false
      t.timestamps
    end
  end
end
