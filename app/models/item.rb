class Item < ApplicationRecord
  validates :description, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :stockQty, presence: true, numericality: { greater_than_or_equal_to: 0, only_integer: true }
end
