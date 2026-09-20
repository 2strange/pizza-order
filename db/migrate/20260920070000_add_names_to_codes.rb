class AddNamesToCodes < ActiveRecord::Migration[8.1]
  # A readable name for the receipt; the code stays what the customer types.
  # Rows that exist before this migration get their code as a stand-in name so the
  # NOT NULL constraint can be added; db:seed replaces it with the real name.
  def up
    %i[promotions discount_codes].each do |table|
      add_column table, :name, :string
      execute "UPDATE #{table} SET name = code"
      change_column_null table, :name, false
    end
  end

  def down
    remove_column :promotions, :name
    remove_column :discount_codes, :name
  end
end
