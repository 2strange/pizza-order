require "rails_helper"

# The invariants the validations enforce, enforced once more by the database.
# `insert!` skips validations, so only the constraint stands in the way.
RSpec.describe "Check constraints" do
  include_context "menu"

  def insert!(model, **attributes)
    model.insert!(attributes.merge(created_at: Time.current, updated_at: Time.current))
  end

  it "keep a pizza from being free" do
    expect { insert!(Pizza, name: "Gratis", base_price_cents: 0) }.to raise_error ActiveRecord::StatementInvalid, /pizzas_base_price_positive/
  end

  it "keep an extra from being free, but let an ingredient be no extra at all" do
    expect { insert!(Ingredient, name: "Nichts", extra_price_cents: 0) }.to raise_error ActiveRecord::StatementInvalid, /ingredients_extra_price_positive/
    expect { insert!(Ingredient, name: "Nichts", extra_price_cents: nil) }.to change(Ingredient, :count).by(1)
  end

  it "keep an order item within the quantity range and out of negative prices" do
    placed = order(item("Salami", :small)).tap(&:place!)
    item = { order_id: placed.id, pizza_id: pizza("Salami").id, size: "small", base_price_cents: 420, extras_price_cents: 0 }

    expect { insert!(OrderItem, **item, quantity: 0) }.to raise_error ActiveRecord::StatementInvalid, /order_items_quantity_in_range/
    expect { insert!(OrderItem, **item, quantity: OrderItem::MAX_QUANTITY + 1) }.to raise_error ActiveRecord::StatementInvalid, /order_items_quantity_in_range/
    expect { insert!(OrderItem, **item, quantity: 1, base_price_cents: -1) }.to raise_error ActiveRecord::StatementInvalid, /order_items_prices_not_negative/
  end

  it "keep a discount between one and a hundred percent" do
    expect { insert!(DiscountCode, code: "NULL", name: "0 %", percent: 0) }.to raise_error ActiveRecord::StatementInvalid, /discount_codes_percent_in_range/
    expect { insert!(DiscountCode, code: "ALLES", name: "101 %", percent: 101) }.to raise_error ActiveRecord::StatementInvalid, /discount_codes_percent_in_range/
  end

  it "keep a promotion from charging for as many pizzas as it takes" do
    deal = { code: "NIX", name: "Nix", pizza_id: pizza("Salami").id, size: "small" }

    expect { insert!(Promotion, **deal, from_quantity: 2, to_quantity: 2) }.to raise_error ActiveRecord::StatementInvalid, /promotions_quantities_consistent/
    expect { insert!(Promotion, **deal, from_quantity: 1, to_quantity: 0) }.to raise_error ActiveRecord::StatementInvalid, /promotions_quantities_consistent/
  end
end
