require "rails_helper"

RSpec.describe Order do
  include_context "menu"

  describe "the golden order" do
    # 1 × Salami medium + onions − cheese          7.00
    # 3 × Salami small                          3 × 4.20
    # 1 × Salami small + olives             4.20 + 1.75
    # two small Salami for one: 4 → 2 free    − 2 × 4.20
    #                                            = 17.15
    # 5 % off                                    − 0.8575
    #                                            = 16.2925 → 16.29
    let(:golden) do
      order(item("Salami", :medium, extras: [ "Zwiebeln" ], without: [ "Käse" ]),
            item("Salami", :small, quantity: 3),
            item("Salami", :small, extras: [ "Oliven" ]),
            promotions: [ "ZWEIKLEINESALAMIFUEREINS" ], discount: "5PROZENTAUFALLES")
    end

    it "totals 16.29" do
      expect(golden.total_cents).to eq 1629
    end

    it "explains itself" do
      quote = golden.quote

      expect(quote.subtotal_cents).to eq 2555
      expect(quote.adjustments.map { |a| [ a.label, a.amount_cents ] })
        .to eq [ [ "ZWEIKLEINESALAMIFUEREINS", -840 ], [ "5PROZENTAUFALLES", -86 ] ]
      expect(quote.total_cents).to eq 1629
    end

    it "is the same after the order is placed" do
      golden.save!

      expect(Order.find(golden.id).total_cents).to eq 1629
    end
  end

  describe "promotions" do
    it "apply as often as the order allows: four small Salami → two free" do
      expect(order(item("Salami", :small, quantity: 4), promotions: [ "ZWEIKLEINESALAMIFUEREINS" ]).total_cents)
        .to eq 2 * 420
    end

    it "leave the remainder at full price: three small Salami → one free" do
      expect(order(item("Salami", :small, quantity: 3), promotions: [ "ZWEIKLEINESALAMIFUEREINS" ]).total_cents)
        .to eq 2 * 420
    end

    it "do nothing below the threshold" do
      expect(order(item("Salami", :small), promotions: [ "ZWEIKLEINESALAMIFUEREINS" ]).total_cents).to eq 420
    end

    it "count the target across items" do
      two_lines = order(item("Salami", :small), item("Salami", :small, extras: [ "Zwiebeln" ]),
                        promotions: [ "ZWEIKLEINESALAMIFUEREINS" ])

      expect(two_lines.total_cents).to eq 420 + 70
    end

    it "still charge the extras of a free pizza" do
      with_olives = order(item("Salami", :small, quantity: 2, extras: [ "Oliven" ]), promotions: [ "ZWEIKLEINESALAMIFUEREINS" ])

      expect(with_olives.total_cents).to eq 420 + 2 * 175
    end

    it "only match the target pizza in the target size" do
      expect(order(item("Salami", :medium, quantity: 2), promotions: [ "ZWEIKLEINESALAMIFUEREINS" ]).total_cents).to eq 1200
      expect(order(item("Tonno", :small, quantity: 2), promotions: [ "ZWEIKLEINESALAMIFUEREINS" ]).total_cents).to eq 1120
    end

    context "when two promotions target the same pizzas" do
      before do
        Promotion.create!(code: "DREIKLEINESALAMIFUERZWEI", pizza: pizza("Salami"), size: :small, from_quantity: 3, to_quantity: 2)
      end

      it "let each pizza take part in one deal only, in the order the codes were given" do
        four = item("Salami", :small, quantity: 4)

        # 2-for-1 first: two groups of two cover all four, nothing left for 3-for-2.
        expect(order(four, promotions: %w[ZWEIKLEINESALAMIFUEREINS DREIKLEINESALAMIFUERZWEI]).total_cents).to eq 2 * 420
        # 3-for-2 first: one group of three, the fourth alone is no pair.
        expect(order(four, promotions: %w[DREIKLEINESALAMIFUERZWEI ZWEIKLEINESALAMIFUEREINS]).total_cents).to eq 3 * 420
      end
    end
  end

  describe "discount codes" do
    it "take a percentage off the sum" do
      expect(order(item("Margherita", :medium, quantity: 2), discount: "5PROZENTAUFALLES").total_cents).to eq 950
    end

    it "apply after promotions" do
      promoted = order(item("Salami", :small, quantity: 2), promotions: [ "ZWEIKLEINESALAMIFUEREINS" ], discount: "5PROZENTAUFALLES")

      expect(promoted.total_cents).to eq 399 # 5 % of 4.20, not of 8.40
    end
  end

  describe "rounding" do
    it "rounds the discount half up to a whole cent" do
      # 2 × 4.55 = 9.10; 5 % = 0.455 → 0.46 (truncating or banker's rounding would give 0.45)
      expect(order(item("Funghi", :small, quantity: 2), discount: "5PROZENTAUFALLES").total_cents).to eq 864
    end
  end

  describe "codes" do
    it "reject an unknown promotion code by name" do
      unknown = order(item("Salami", :small), promotions: [ "GRATISPIZZA" ])

      expect(unknown).not_to be_valid
      expect(unknown.errors.full_messages).to include "Unknown promotion code: GRATISPIZZA"
      expect { unknown.quote }.to raise_error Order::UnknownCode, "Unknown promotion code: GRATISPIZZA"
    end

    it "reject an unknown discount code by name" do
      unknown = order(item("Salami", :small), discount: "MINUS100")

      expect(unknown).not_to be_valid
      expect(unknown.errors.full_messages).to include "Unknown discount code: MINUS100"
    end
  end

  it "needs at least one pizza" do
    expect(order).not_to be_valid
  end
end
