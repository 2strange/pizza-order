class OrdersController < ApiController
  def create
    order = build_order
    order.place!
    render json: OrderPresenter.new(order).to_h, status: :created
  end

  def show
    render json: OrderPresenter.new(Order.find(params[:id])).to_h
  end
end
