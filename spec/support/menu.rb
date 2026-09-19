# The seeded menu (db/seeds/menu.json) as test data, plus small builders so a
# spec reads like the order it describes.
RSpec.shared_context "menu" do
  before { Rails.application.load_seed }

  def pizza(name) = Pizza.find_by!(name: name)
  def ingredient(name) = Ingredient.find_by!(name: name)

  def order(*items, promotions: [], discount: nil)
    Order.new(customer_name: "Test", promotion_codes: promotions, discount_code: discount).tap do |order|
      items.each { |item| order.order_items.build(item) }
    end
  end

  def item(name, size, quantity: 1, extras: [], without: [])
    { pizza: pizza(name), size: size, quantity: quantity,
      extras: extras.map { |extra| ingredient(extra) }, removed_ingredients: without.map { |removed| ingredient(removed) } }
  end
end
