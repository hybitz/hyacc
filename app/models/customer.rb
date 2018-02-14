class Customer < ApplicationRecord
  nostalgic_for :name, :formal_name, :address

  validates :code, :uniqueness => true
  validates :name, :presence => true
  validates :formal_name, :presence => true

end
