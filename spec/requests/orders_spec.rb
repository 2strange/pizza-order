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
      expect { post_json "/orders", golden_body.merge(discount_code: "NOPE") }.not_to change(Order, :count)

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.parsed_body).to eq("errors" => [ "Unknown discount code: NOPE" ])
    end
  end

  describe "GET /orders/:id" do
    it "shows a placed order with its frozen receipt, whatever the menu does later" do
      post_json "/orders", golden_body.merge(customer_name: "Mia")
      id = response.parsed_body["id"]
      pizza("Salami").update!(base_price_cents: 900)
      DiscountCode.find_by!(code: "5PROZENTAUFALLES").update!(percent: 50)
      Promotion.find_by!(code: "ZWEIKLEINESALAMIFUEREINS").destroy!

      get "/orders/#{id}", headers: json_headers

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to include("number" => format("#%04d", id), "customer_name" => "Mia")
      expect(response.parsed_body["quote"]["adjustments"]).to eq [ { "label" => "ZWEIKLEINESALAMIFUEREINS", "amount_cents" => -840 },
                                                                  { "label" => "5PROZENTAUFALLES", "amount_cents" => -86 } ]
      expect(response.parsed_body["quote"]["total_cents"]).to eq 1629
    end

    it "is 404 for an order that does not exist" do
      get "/orders/0", headers: json_headers

      expect(response).to have_http_status(:not_found)
    end
  end
end
