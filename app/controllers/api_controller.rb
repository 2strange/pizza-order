# Base for the JSON endpoints. Requests arrive as flat JSON bodies (no wrapper
# key); an order is assembled from them by OrderBuilder and either priced or
# rejected with the model's own messages.
class ApiController < ApplicationController
  wrap_parameters false

  # a wrongly shaped body (a string where a list belongs) is an error, not something to drop quietly
  rescue_from ActionController::UnpermittedParameters do |error|
    render_errors [ error.message ]
  end

  rescue_from OrderBuilder::UnknownReference, OrderBuilder::CodeRejected do |error|
    render_errors [ error.message ]
  end

  rescue_from ActiveRecord::RecordInvalid do |error|
    render_errors error.record.errors.full_messages
  end

  private

  def build_order
    OrderBuilder.build(order_params)
  end

  def order_params
    params.permit(:customer_name, codes: [],
                  items: [ :pizza_id, :size, :quantity, { extra_ids: [], removed_ingredient_ids: [] } ])
  end

  def render_errors(messages)
    render json: { errors: messages }, status: :unprocessable_content
  end
end
