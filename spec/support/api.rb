# Request bodies for the JSON API, built from the seeded menu by name so a spec
# reads like the order it sends.
RSpec.shared_context "api" do
  include_context "menu"

  def json_headers = { "CONTENT_TYPE" => "application/json", "ACCEPT" => "application/json" }

  def post_json(path, body)
    post path, params: body.to_json, headers: json_headers
  end

  def item_body(name, size, quantity: 1, extras: [], without: [])
    { pizza_id: pizza(name).id, size: size, quantity: quantity,
      extra_ids: extras.map { |extra| ingredient(extra).id },
      removed_ingredient_ids: without.map { |removed| ingredient(removed).id } }
  end

  # The golden order of spec/models/order_spec.rb: 16.29 after promotion and discount.
  def golden_body
    { items: [ item_body("Salami", "medium", extras: [ "Zwiebeln" ], without: [ "Käse" ]),
               item_body("Salami", "small", quantity: 3),
               item_body("Salami", "small", extras: [ "Oliven" ]) ],
      promotion_codes: [ "ZWEIKLEINESALAMIFUEREINS" ],
      discount_code: "5PROZENTAUFALLES" }
  end
end
