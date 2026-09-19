require "rails_helper"

RSpec.describe OrderItem do
  include_context "menu"

  def line(*args, **kwargs) = order(item(*args, **kwargs)).order_items.first

  describe "price" do
    it "is the base price times the size multiplier" do
      expect(line("Tonno", :small).unit_price_cents).to eq 560
      expect(line("Tonno", :medium).unit_price_cents).to eq 800
      expect(line("Tonno", :large).unit_price_cents).to eq 1040
    end

    it "multiplies extras by the size as well" do
      large = line("Margherita", :large, extras: [ "Oliven", "Zwiebeln" ])

      expect(large.base_price_cents).to eq 650
      expect(large.extras_price_cents).to eq 455 # (2.50 + 1.00) × 1.3
      expect(large.unit_price_cents).to eq 1105
    end

    it "does not change when ingredients are left out" do
      expect(line("Tonno", :medium, without: [ "Zwiebeln", "Käse" ]).unit_price_cents).to eq 800
    end

    it "is multiplied by the quantity for the line" do
      expect(line("Salami", :small, quantity: 3).line_price_cents).to eq 1260
    end

    it "rounds half up to a whole cent" do
      Pizza.create!(name: "Testpizza", base_price_cents: 655)

      expect(line("Testpizza", :small).unit_price_cents).to eq 459 # 4.585
    end

    it "is frozen when the order is placed" do
      placed = line("Salami", :small, extras: [ "Oliven" ])
      placed.order.save!
      pizza("Salami").update!(base_price_cents: 900)
      ingredient("Oliven").update!(extra_price_cents: 500)

      expect(placed.reload.unit_price_cents).to eq 420 + 175
      expect(line("Salami", :small, extras: [ "Oliven" ]).unit_price_cents).to eq 630 + 350
    end
  end

  describe "validation" do
    it "allows only priced ingredients as extras" do
      with_basil = line("Salami", :small, extras: [ "Basilikum" ])

      expect(with_basil).not_to be_valid
      expect(with_basil.errors.full_messages).to include "Extras Basilikum is not available as an extra"
    end

    it "allows leaving out only what is on the pizza" do
      without_tuna = line("Margherita", :small, without: [ "Thunfisch" ])

      expect(without_tuna).not_to be_valid
      expect(without_tuna.errors.full_messages).to include "Removed ingredients Thunfisch is not on a Margherita"
    end

    it "needs a quantity of at least one" do
      expect(line("Salami", :small, quantity: 0)).not_to be_valid
    end

    it "needs a known size" do
      expect(line("Salami", :family)).not_to be_valid
    end
  end
end
