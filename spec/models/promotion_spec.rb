require "rails_helper"

RSpec.describe Promotion do
  include_context "menu"

  def promotion(**overrides)
    Promotion.new({ code: "DREIFUERZWEI", name: "3 für 2", pizza: pizza("Salami"), size: :small,
                    from_quantity: 3, to_quantity: 2 }.merge(overrides))
  end

  describe "validation" do
    it "accepts a deal that gives something away" do
      expect(promotion).to be_valid
    end

    it "needs at least two pizzas to make a deal" do
      expect(promotion(from_quantity: 1, to_quantity: 0)).not_to be_valid
    end

    it "must charge for fewer pizzas than it takes" do
      expect(promotion(from_quantity: 3, to_quantity: 3)).not_to be_valid
      expect(promotion(from_quantity: 3, to_quantity: 4)).not_to be_valid
      expect(promotion(from_quantity: 3, to_quantity: -1)).not_to be_valid
    end

    it "needs a known size" do
      family = promotion(size: :family)

      expect(family).not_to be_valid
      expect(family.errors.full_messages).to include "Size is not a known size"
    end

    it "needs a name for the receipt" do
      expect(promotion(name: "")).not_to be_valid
    end

    it "stores the code upcased and trimmed" do
      expect(promotion(code: " dreifuerzwei ").code).to eq "DREIFUERZWEI"
    end

    it "does not share a code with another promotion, however it is typed" do
      expect(promotion(code: "zweikleinesalamifuereins")).not_to be_valid
    end

    it "does not share a code with a discount" do
      taken = promotion(code: "5PROZENTAUFALLES")

      expect(taken).not_to be_valid
      expect(taken.errors.full_messages).to include "Code is already a discount code"
    end
  end

  describe "#apply" do
    let(:two_for_one) { Promotion.find_by!(code: "ZWEIKLEINESALAMIFUEREINS") }

    it "waives the base price of the free pizzas and names the units it covers" do
      cart = order(item("Salami", :small, quantity: 3, extras: [ "Oliven" ]))
      adjustment = two_for_one.apply(cart)

      expect(adjustment.amount_cents).to eq(-420)
      expect(adjustment.kind).to eq :promotion
      expect(adjustment.label).to eq "2 kleine Salami für 1"
      expect(adjustment.units).to eq(cart.order_items.first => 2)
    end

    it "leaves units alone that an earlier deal already covers" do
      cart = order(item("Salami", :small, quantity: 4))
      first = cart.order_items.first

      expect(two_for_one.apply(cart, { first => 2 }).amount_cents).to eq(-420)
      expect(two_for_one.apply(cart, { first => 3 })).to be_nil
    end

    it "returns nothing when the deal cannot be made" do
      expect(two_for_one.apply(order(item("Salami", :small)))).to be_nil
      expect(two_for_one.apply(order(item("Salami", :large, quantity: 2)))).to be_nil
      expect(two_for_one.apply(order(item("Tonno", :small, quantity: 2)))).to be_nil
    end
  end
end
