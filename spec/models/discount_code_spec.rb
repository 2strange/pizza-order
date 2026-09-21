require "rails_helper"

RSpec.describe DiscountCode do
  include_context "menu"

  def discount(**overrides)
    DiscountCode.new({ code: "ZEHN", name: "10 % auf alles", percent: 10 }.merge(overrides))
  end

  describe "validation" do
    it "accepts a percentage between one and a hundred" do
      expect(discount(percent: 1)).to be_valid
      expect(discount(percent: 100)).to be_valid
    end

    it "rejects nothing off, more than everything off and fractions" do
      expect(discount(percent: 0)).not_to be_valid
      expect(discount(percent: 101)).not_to be_valid
      expect(discount(percent: 2.5)).not_to be_valid
    end

    it "needs a name for the receipt" do
      expect(discount(name: "")).not_to be_valid
    end

    it "stores the code upcased and trimmed" do
      expect(discount(code: " zehn ").code).to eq "ZEHN"
    end

    it "does not share a code with a promotion" do
      taken = discount(code: "ZWEIKLEINESALAMIFUEREINS")

      expect(taken).not_to be_valid
      expect(taken.errors.full_messages).to include "Code is already a promotion code"
    end
  end

  describe "#apply" do
    it "takes the percentage off the amount it is given, as a negative adjustment" do
      adjustment = discount.apply(2000)

      expect(adjustment).to have_attributes(label: "10 % auf alles", code: "ZEHN", kind: :discount, amount_cents: -200, units: {})
    end

    it "rounds half up to a whole cent" do
      expect(discount(percent: 5).apply(910).amount_cents).to eq(-46) # 45.5
      expect(discount(percent: 5).apply(909).amount_cents).to eq(-45) # 45.45
    end
  end
end
