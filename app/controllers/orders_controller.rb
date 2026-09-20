class OrdersController < ApiController
  def create
    order = build_order
    order.place!
    render json: OrderPresenter.new(order).to_h, status: :created
  end
end
