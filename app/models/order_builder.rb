# Turns the body of a quote or order request — menu ids, sizes, quantities and
# codes, nothing priced — into an Order with its items. Ids that point nowhere
# raise UnknownReference; codes are sorted into promotions and the one discount
# (the customer has "a code", the domain has two kinds — telling them apart is
# the server's job), and a code that is neither, or a second discount, raises
# CodeRejected. Whether the assembled order is valid is the order's own business.
class OrderBuilder
  UnknownReference = Class.new(ArgumentError)
  CodeRejected = Class.new(ArgumentError)

  def self.build(attributes) = new(attributes).build

  def initialize(attributes)
    @attributes = attributes.to_h.symbolize_keys
  end

  def build
    promotion_codes, discount_code = sort_codes(Array(@attributes[:codes]))
    order = Order.new(customer_name: @attributes[:customer_name],
                      promotion_codes: promotion_codes, discount_code: discount_code)
    Array(@attributes[:items]).each { |item| order.order_items.build(item_attributes(item)) }
    order
  end

  private

  def sort_codes(codes)
    promotions = []
    discount = nil
    codes.map(&:to_s).each do |code|
      if Promotion.exists?(code: code)
        promotions << code
      elsif DiscountCode.exists?(code: code)
        raise CodeRejected, "Only one discount code per order: #{code}" if discount

        discount = code
      else
        raise CodeRejected, "Unknown code: #{code}"
      end
    end
    [ promotions, discount ]
  end

  def item_attributes(item)
    item = item.to_h.symbolize_keys
    { pizza: Pizza.find(item[:pizza_id]),
      size: item[:size],
      quantity: item.fetch(:quantity, 1),
      extras: Ingredient.find(Array(item[:extra_ids])),
      removed_ingredients: Ingredient.find(Array(item[:removed_ingredient_ids])) }
  rescue ActiveRecord::RecordNotFound => e
    raise UnknownReference, e.message
  end
end
