# A pizza on the menu with its standard recipe. The base price is the medium price;
# a Size scales it.
class Pizza < ApplicationRecord
  has_and_belongs_to_many :ingredients

  validates :name, presence: true, uniqueness: true
  validates :base_price_cents, numericality: { only_integer: true, greater_than: 0 }
end
