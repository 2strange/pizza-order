# The menu lives in db/seeds/menu.json (the data format of the original challenge,
# extended with recipes). Seeding is idempotent: rerunning updates prices in place.
menu = JSON.parse(Rails.root.join("db/seeds/menu.json").read)

cents = ->(euros) { (BigDecimal(euros.to_s) * 100).to_i }

# Sizes are code (see Size); the file keeps them so it stays a complete menu.
menu["size_multipliers"].each do |label, multiplier|
  size = Size.all.find { |s| s.label == label }
  unless size && size.multiplier == BigDecimal(multiplier.to_s)
    raise "Size #{label} (#{multiplier}) in menu.json does not match Size::ALL"
  end
end

ingredients = Hash.new do |cache, name|
  cache[name] = Ingredient.find_or_create_by!(name: name)
end

menu["ingredients"].each do |name, price|
  ingredients[name].update!(extra_price_cents: cents[price])
end

menu["pizzas"].each do |name, recipe|
  pizza = Pizza.find_or_initialize_by(name: name)
  pizza.update!(base_price_cents: cents[recipe["price"]])
  pizza.ingredients = recipe["ingredients"].map { |ingredient| ingredients[ingredient] }
end
