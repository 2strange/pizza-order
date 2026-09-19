# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_09_19_120100) do
  create_table "discount_codes", force: :cascade do |t|
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.integer "percent", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_discount_codes_on_code", unique: true
  end

  create_table "ingredients", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "extra_price_cents"
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_ingredients_on_name", unique: true
  end

  create_table "ingredients_pizzas", id: false, force: :cascade do |t|
    t.integer "ingredient_id", null: false
    t.integer "pizza_id", null: false
    t.index ["pizza_id", "ingredient_id"], name: "index_ingredients_pizzas_on_pizza_id_and_ingredient_id", unique: true
  end

  create_table "order_item_extras", id: false, force: :cascade do |t|
    t.integer "ingredient_id", null: false
    t.integer "order_item_id", null: false
    t.index ["order_item_id", "ingredient_id"], name: "index_order_item_extras_on_order_item_id_and_ingredient_id", unique: true
  end

  create_table "order_item_removals", id: false, force: :cascade do |t|
    t.integer "ingredient_id", null: false
    t.integer "order_item_id", null: false
    t.index ["order_item_id", "ingredient_id"], name: "index_order_item_removals_on_order_item_id_and_ingredient_id", unique: true
  end

  create_table "order_items", force: :cascade do |t|
    t.integer "base_price_cents", null: false
    t.datetime "created_at", null: false
    t.integer "extras_price_cents", null: false
    t.integer "order_id", null: false
    t.integer "pizza_id", null: false
    t.integer "quantity", default: 1, null: false
    t.string "size", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_order_items_on_order_id"
    t.index ["pizza_id"], name: "index_order_items_on_pizza_id"
  end

  create_table "orders", force: :cascade do |t|
    t.json "adjustments"
    t.datetime "created_at", null: false
    t.string "customer_name"
    t.string "discount_code"
    t.datetime "placed_at"
    t.json "promotion_codes", default: [], null: false
    t.integer "total_cents"
    t.datetime "updated_at", null: false
  end

  create_table "pizzas", force: :cascade do |t|
    t.integer "base_price_cents", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_pizzas_on_name", unique: true
  end

  create_table "promotions", force: :cascade do |t|
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.integer "from_quantity", null: false
    t.integer "pizza_id", null: false
    t.string "size", null: false
    t.integer "to_quantity", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_promotions_on_code", unique: true
    t.index ["pizza_id"], name: "index_promotions_on_pizza_id"
  end

  add_foreign_key "ingredients_pizzas", "ingredients"
  add_foreign_key "ingredients_pizzas", "pizzas"
  add_foreign_key "order_item_extras", "ingredients"
  add_foreign_key "order_item_extras", "order_items"
  add_foreign_key "order_item_removals", "ingredients"
  add_foreign_key "order_item_removals", "order_items"
  add_foreign_key "order_items", "orders"
  add_foreign_key "order_items", "pizzas"
  add_foreign_key "promotions", "pizzas"
end
