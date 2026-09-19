# Prices a cart without keeping it. Nothing is written; an invalid cart is
# answered with the order's errors (see ApiController).
class QuotesController < ApiController
  def create
    render json: QuotePresenter.new(build_order.quote).to_h
  end
end
