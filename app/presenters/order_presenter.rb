# A placed order as the confirmation page shows it: a number to quote at the
# counter, the name, and the receipt.
class OrderPresenter
  def initialize(order)
    @order = order
  end

  def to_h
    { id: @order.id,
      number: format("#%04d", @order.id),
      customer_name: @order.customer_name,
      quote: QuotePresenter.new(@order.quote).to_h }
  end
end
