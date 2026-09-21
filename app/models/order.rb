# A customer's order: pizzas, the promotion codes redeemed on them and at most one
# discount code. While the cart is composed, Order#quote prices it live from the
# menu. Order#place! freezes that quote into the order (placed_at, adjustments,
# total_cents); from then on the order is read-only and #quote serves the receipt,
# whatever happens to the menu or the codes later.
#
# #quote validates first: an invalid order (unknown code, bad item) raises
# ActiveRecord::RecordInvalid instead of pricing nonsense.
class Order < ApplicationRecord
  UnknownCode = Class.new(StandardError)

  has_many :order_items, -> { order(:id) }, dependent: :destroy, autosave: true # autosave: item errors surface on the order

  validates :order_items, presence: true
  validates :customer_name, presence: true, on: :place
  validate :promotion_codes_are_a_list, :codes_are_known

  def promotion_codes=(codes)
    @promotions = nil
    super(codes.nil? ? [] : codes)
  end

  def discount_code=(code)
    @discount = nil
    super
  end

  def reload(...)
    @promotions = @discount = nil
    super
  end

  # Pricing order: line prices → promotions, in the order the codes were given,
  # each pizza in at most one deal → discount on what is left.
  def quote
    return receipt if placed?

    validate!
    promotion_adjustments = promotions.each_with_object([]) do |promotion, applied|
      adjustment = promotion.apply(self, claimed_units(applied))
      applied << adjustment if adjustment
    end

    remaining = order_items.sum(&:line_price_cents) + promotion_adjustments.sum(&:amount_cents)
    discount_adjustment = discount&.apply(remaining)

    Quote.new(items: order_items.to_a, adjustments: [ *promotion_adjustments, *discount_adjustment ])
  end

  def total_cents
    placed? ? super : quote.total_cents
  end

  # Turns the cart into a receipt: prices and adjustments are frozen as they are
  # right now, and the order can no longer change.
  def place!
    raise ActiveRecord::ReadOnlyRecord, "Order is already placed" if placed?

    final = quote
    transaction do
      save!(context: :place) # freezes the item prices first; the stamp below must not touch the items
      update!(placed_at: Time.current,
              adjustments: final.adjustments.map { |a| { label: a.label, code: a.code, kind: a.kind, amount_cents: a.amount_cents } },
              total_cents: final.total_cents)
    end
  end

  def placed? = placed_at.present?

  def readonly?
    super || placed_at_in_database.present?
  end

  # The records behind the codes, looked up once per order: validation and
  # pricing both ask, and an order's codes do not change between the two.
  def promotions
    @promotions ||= promotion_codes.map do |code|
      Promotion.find_by(code: code) or raise UnknownCode, "Unknown promotion code: #{code}"
    end
  end

  def discount
    return if discount_code.blank?

    @discount ||= DiscountCode.find_by(code: discount_code) or raise UnknownCode, "Unknown discount code: #{discount_code}"
  end

  private

  def receipt
    frozen = adjustments.map { |a| Adjustment.new(label: a["label"], code: a["code"], kind: a["kind"]&.to_sym, amount_cents: a["amount_cents"]) }
    Quote.new(items: order_items.to_a, adjustments: frozen)
  end

  def claimed_units(adjustments)
    adjustments.map(&:units).reduce({}) { |all, units| all.merge(units) { |_item, a, b| a + b } }
  end

  def promotion_codes_are_a_list
    return if promotion_codes.is_a?(Array) && promotion_codes.all?(String)

    errors.add(:promotion_codes, "must be a list of codes")
  end

  def codes_are_known
    return if errors.include?(:promotion_codes)

    promotions
    discount
  rescue UnknownCode => e
    errors.add(:base, e.message)
  end
end
