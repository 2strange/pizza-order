class MenuController < ApiController
  def show
    render json: {
      pizzas: Pizza.includes(:ingredients).order(:id).map do |pizza|
        { id: pizza.id, name: pizza.name, base_price_cents: pizza.base_price_cents,
          ingredients: pizza.ingredients.map { |ingredient| { id: ingredient.id, name: ingredient.name } } }
      end,
      extras: Ingredient.extras.order(:id).map do |extra|
        { id: extra.id, name: extra.name, extra_price_cents: extra.extra_price_cents }
      end,
      sizes: Size.all.map { |size| { key: size.key, label: size.label, multiplier: size.multiplier.to_s } },
      max_quantity: OrderItem::MAX_QUANTITY
    }
  end
end
