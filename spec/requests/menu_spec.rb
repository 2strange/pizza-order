require "rails_helper"

RSpec.describe "Menu", type: :request do
  include_context "api"

  describe "GET /menu" do
    it "lists pizzas with recipes, priced extras and the sizes" do
      get "/menu", headers: json_headers

      expect(response).to have_http_status(:ok)
      menu = response.parsed_body

      salami = menu["pizzas"].find { |p| p["name"] == "Salami" }
      expect(salami).to include("id" => pizza("Salami").id, "base_price_cents" => 600)
      expect(salami["ingredients"].map { |i| i["name"] }).to contain_exactly("Tomatensauce", "Käse", "Salami")

      expect(menu["extras"].map { |e| e.values_at("name", "extra_price_cents") })
        .to contain_exactly([ "Zwiebeln", 100 ], [ "Käse", 200 ], [ "Oliven", 250 ])
      expect(menu["sizes"]).to eq [ { "key" => "small", "label" => "Klein", "multiplier" => "0.7" },
                                    { "key" => "medium", "label" => "Mittel", "multiplier" => "1.0" },
                                    { "key" => "large", "label" => "Groß", "multiplier" => "1.3" } ]
    end
  end
end
