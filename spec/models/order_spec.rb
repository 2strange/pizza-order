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
      golden.place!

      expect(Order.find(golden.id).total_cents).to eq 1629
    end
  end

  describe "placing" do
    let!(:placed) do
      order(item("Salami", :small, quantity: 2), promotions: [ "ZWEIKLEINESALAMIFUEREINS" ], discount: "5PROZENTAUFALLES")
        .tap(&:place!)
    end

    it "stamps the order and freezes the receipt" do
      expect(placed.placed_at).to be_present
      expect(placed.total_cents).to eq 399
      expect(placed.adjustments).to eq [ { "label" => "ZWEIKLEINESALAMIFUEREINS", "amount_cents" => -420 },
                                         { "label" => "5PROZENTAUFALLES", "amount_cents" => -21 } ]
    end

    it "keeps the receipt when the discount changes" do
      DiscountCode.find_by!(code: "5PROZENTAUFALLES").update!(percent: 10)

      expect(Order.find(placed.id).total_cents).to eq 399
    end

    it "keeps the receipt when the promotion is gone" do
      Promotion.find_by!(code: "ZWEIKLEINESALAMIFUEREINS").destroy!
      receipt = Order.find(placed.id).quote

      expect(receipt.adjustments.map(&:label)).to eq %w[ZWEIKLEINESALAMIFUEREINS 5PROZENTAUFALLES]
      expect(receipt.total_cents).to eq 399
    end

    it "makes the order read-only" do
      expect { placed.update!(customer_name: "Someone else") }.to raise_error ActiveRecord::ReadOnlyRecord
      expect { Order.find(placed.id).destroy! }.to raise_error ActiveRecord::ReadOnlyRecord
    end

    it "makes the items read-only" do
      expect { placed.order_items.first.update!(quantity: 9) }.to raise_error ActiveRecord::ReadOnlyRecord
    end

    it "cannot happen twice" do
      expect { placed.place! }.to raise_error ActiveRecord::ReadOnlyRecord
    end

    it "refuses an invalid order" do
      invalid = order(item("Salami", :small), promotions: [ "GRATISPIZZA" ])

      expect { invalid.place! }.to raise_error ActiveRecord::RecordInvalid
      expect(invalid).not_to be_persisted
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
    end

    it "refuse to quote an invalid order" do
      unknown = order(item("Salami", :small), promotions: [ "GRATISPIZZA" ])

      expect { unknown.quote }.to raise_error ActiveRecord::RecordInvalid, /Unknown promotion code: GRATISPIZZA/
    end

    it "take promotion codes as a list of strings, nil meaning none" do
      expect(order(item("Salami", :small), promotions: nil)).to be_valid
      expect(order(item("Salami", :small), promotions: "ZWEIKLEINESALAMIFUEREINS")).not_to be_valid
      expect(order(item("Salami", :small), promotions: [ 1 ])).not_to be_valid
    end

    it "name the problem with a promotion code list" do
      bad = order(item("Salami", :small), promotions: { code: "X" })

      expect(bad).not_to be_valid
      expect(bad.errors.full_messages).to eq [ "Promotion codes must be a list of codes" ]
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
