require "rails_helper"

RSpec.describe "Orders", type: :request do
  include_context "api"

  describe "POST /orders" do
    it "places the order and answers with its number and receipt" do
      expect { post_json "/orders", golden_body.merge(customer_name: "Mia") }.to change(Order, :count).by(1)

      expect(response).to have_http_status(:created)
      order = response.parsed_body
      expect(order).to include("id" => Order.last.id, "number" => format("#%04d", Order.last.id), "customer_name" => "Mia")
      expect(order["quote"]["total_cents"]).to eq 1629
      expect(Order.last).to be_placed
      expect(Order.last.order_items.count).to eq 3
    end

    it "does not place an order with an unknown code" do
      expect { post_json "/orders", golden_body.merge(codes: [ "NOPE" ]) }.not_to change(Order, :count)

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.parsed_body).to eq("errors" => [ "Unknown code: NOPE" ])
    end

    it "needs a name" do
      expect { post_json "/orders", golden_body }.not_to change(Order, :count)

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.parsed_body).to eq("errors" => [ "Customer name can't be blank" ])
    end

    it "refuses a body it does not understand instead of dropping parts of it" do
      post_json "/orders", golden_body.merge(customer_name: "Mia", codes: "5PROZENTAUFALLES")

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.parsed_body["errors"].first).to include("codes")
    end

    it "keeps the receipt as it was placed, whatever the menu does later" do
      post_json "/orders", golden_body.merge(customer_name: "Mia")
      order = Order.find(response.parsed_body["id"])
      pizza("Salami").update!(base_price_cents: 900)
      DiscountCode.find_by!(code: "5PROZENTAUFALLES").update!(percent: 50)
      Promotion.find_by!(code: "ZWEIKLEINESALAMIFUEREINS").destroy!

      receipt = OrderPresenter.new(order.reload).to_h
      expect(receipt[:quote][:adjustments]).to eq [ { label: "2 kleine Salami für 1", code: "ZWEIKLEINESALAMIFUEREINS", kind: :promotion, amount_cents: -840 },
                                                     { label: "5 % auf alles", code: "5PROZENTAUFALLES", kind: :discount, amount_cents: -86 } ]
      expect(receipt[:quote][:total_cents]).to eq 1629
    end
  end
end
