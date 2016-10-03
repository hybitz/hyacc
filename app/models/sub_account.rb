class SubAccount < ActiveRecord::Base
  belongs_to :account

  validates :code, :presence => true
  validates :name, :presence => true
end
