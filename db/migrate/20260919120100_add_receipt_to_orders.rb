class AddReceiptToOrders < ActiveRecord::Migration[8.1]
  def change
    # Set by Order#place!: from then on the order is read-only and the quote is
    # served from these columns instead of being recomputed from the menu.
    add_column :orders, :placed_at, :datetime
    add_column :orders, :total_cents, :integer
    add_column :orders, :adjustments, :json
  end
end
