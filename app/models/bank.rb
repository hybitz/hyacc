class Bank < ApplicationRecord
  validates :code, :presence => true
  validates :name, :presence => true

  has_many :bank_offices
  accepts_nested_attributes_for :bank_offices
end
