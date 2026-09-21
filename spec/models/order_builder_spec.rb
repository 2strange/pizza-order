require "rails_helper"

RSpec.describe OrderBuilder do
  include_context "api"

  def build(**attributes)
    OrderBuilder.build({ items: [ item_body("Salami", "small") ] }.merge(attributes))
  end

  it "assembles an unsaved order with its items from menu ids" do
    order = build(customer_name: "Mia", items: [ item_body("Salami", "medium", quantity: 2, extras: [ "Oliven" ], without: [ "Käse" ]) ])
    item = order.order_items.first

    expect(order).not_to be_persisted
    expect(order.customer_name).to eq "Mia"
    expect(item).to have_attributes(pizza: pizza("Salami"), size: Size.find(:medium), quantity: 2)
    expect(item.extras).to eq [ ingredient("Oliven") ]
    expect(item.removed_ingredients).to eq [ ingredient("Käse") ]
  end

  it "defaults the quantity to one" do
    expect(build(items: [ { pizza_id: pizza("Salami").id, size: "small" } ]).order_items.first.quantity).to eq 1
  end

  it "sorts the codes into promotions and the discount" do
    order = build(codes: [ "5PROZENTAUFALLES", "ZWEIKLEINESALAMIFUEREINS" ])

    expect(order.promotion_codes).to eq [ "ZWEIKLEINESALAMIFUEREINS" ]
    expect(order.discount_code).to eq "5PROZENTAUFALLES"
  end

  it "takes a code however it was typed" do
    order = build(codes: [ " zweikleinesalamifuereins ", "5prozentaufalles" ])

    expect(order.promotion_codes).to eq [ "ZWEIKLEINESALAMIFUEREINS" ]
    expect(order.discount_code).to eq "5PROZENTAUFALLES"
  end

  it "builds without codes or items" do
    order = OrderBuilder.build({})

    expect(order.promotion_codes).to eq []
    expect(order.discount_code).to be_nil
    expect(order.order_items).to be_empty
  end

  it "rejects a code it cannot place" do
    expect { build(codes: [ "GIBTSNICHT" ]) }.to raise_error OrderBuilder::CodeRejected, "Unknown code: GIBTSNICHT"
  end

  it "rejects a second discount" do
    DiscountCode.create!(code: "ZEHN", name: "10 % auf alles", percent: 10)

    expect { build(codes: [ "5PROZENTAUFALLES", "ZEHN" ]) }.to raise_error OrderBuilder::CodeRejected, "Only one discount code per order: ZEHN"
  end

  it "rejects ids that point nowhere on the menu" do
    expect { build(items: [ { pizza_id: 0, size: "small" } ]) }.to raise_error OrderBuilder::UnknownReference, /Pizza/
    expect { build(items: [ { pizza_id: pizza("Salami").id, size: "small", extra_ids: [ 0 ] } ]) }
      .to raise_error OrderBuilder::UnknownReference, /Ingredient/
  end

  it "leaves validity to the order" do
    order = build(items: [ item_body("Salami", "gigantic") ])

    expect(order).not_to be_valid
  end
end
