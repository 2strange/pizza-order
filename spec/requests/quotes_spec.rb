require "rails_helper"

RSpec.describe "Quotes", type: :request do
  include_context "api"

  describe "POST /quotes" do
    it "prices the golden order at 16.29 and explains every line" do
      post_json "/quotes", golden_body

      expect(response).to have_http_status(:ok)
      quote = response.parsed_body

      expect(quote["items"].first).to eq(
        "pizza" => "Salami", "size" => "Mittel", "quantity" => 1,
        "extras" => [ "Zwiebeln" ], "removed" => [ "Käse" ],
        "base_price_cents" => 600, "extras_price_cents" => 100, "unit_price_cents" => 700, "line_price_cents" => 700
      )
      expect(quote["items"].map { |i| i["line_price_cents"] }).to eq [ 700, 1260, 595 ]
      expect(quote["adjustments"]).to eq [ { "label" => "2 kleine Salami für 1", "code" => "ZWEIKLEINESALAMIFUEREINS", "kind" => "promotion", "amount_cents" => -840 },
                                           { "label" => "5 % auf alles", "code" => "5PROZENTAUFALLES", "kind" => "discount", "amount_cents" => -86 } ]
      expect(quote["subtotal_cents"]).to eq 2555
      expect(quote["total_cents"]).to eq 1629
    end

    it "stores nothing" do
      expect { post_json "/quotes", golden_body }.not_to change(Order, :count)
    end

    it "rejects an unknown code" do
      post_json "/quotes", golden_body.merge(codes: [ "GIBTSNICHT" ])

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.parsed_body).to eq("errors" => [ "Unknown code: GIBTSNICHT" ])
    end

    it "accepts one discount code only" do
      DiscountCode.create!(code: "ZEHN", name: "10 % auf alles", percent: 10)
      post_json "/quotes", golden_body.merge(codes: [ "5PROZENTAUFALLES", "ZEHN" ])

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.parsed_body).to eq("errors" => [ "Only one discount code per order: ZEHN" ])
    end

    it "rejects an invalid item" do
      post_json "/quotes", { items: [ item_body("Salami", "gigantic") ] }

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.parsed_body["errors"]).to include(a_string_matching(/not a known size/))
    end

    it "rejects an impossible quantity" do
      post_json "/quotes", { items: [ item_body("Salami", "small", quantity: 51) ] }

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.parsed_body["errors"]).to include(a_string_matching(/quantity/i))
    end

    it "rejects an item that points to nothing on the menu" do
      post_json "/quotes", { items: [ { pizza_id: 0, size: "small" } ] }

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.parsed_body["errors"]).to include(a_string_matching(/Pizza/))
    end
  end
end
