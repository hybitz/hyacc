class Bank < ApplicationRecord
  belongs_to :company

  validates :code, :presence => true
  validates :name, :presence => true

  has_many :bank_offices
  accepts_nested_attributes_for :bank_offices
end
