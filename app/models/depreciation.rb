class Depreciation < ApplicationRecord
  belongs_to :asset, :inverse_of => :depreciations
  has_many :journals, :inverse_of => :depreciation, :dependent => :destroy
  accepts_nested_attributes_for :journals
  
  def amount_depreciated
    amount_at_start - amount_at_end
  end
end
