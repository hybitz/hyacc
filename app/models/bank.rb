class Bank < ActiveRecord::Base
  include HyaccConstants

  validates :code, :presence => true
  validates :name, :presence => true

  has_many :bank_offices
  accepts_nested_attributes_for :bank_offices

end
