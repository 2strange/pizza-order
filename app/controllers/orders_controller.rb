class OrdersController < ApiController
  # A public page with no login: one address places at most ten orders a minute.
  rate_limit to: 10, within: 1.minute,
             with: -> { render_errors [ "Too many orders from this address, try again in a minute" ], status: :too_many_requests }

  def create
    order = build_order
    order.place!
    render json: OrderPresenter.new(order).to_h, status: :created
  end
end
