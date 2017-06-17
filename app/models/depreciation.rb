class Depreciation < ApplicationRecord
  belongs_to :asset, :inverse_of => :depreciations
  has_many :journal_headers, :inverse_of => :depreciation, :dependent => :destroy
  accepts_nested_attributes_for :journal_headers
  
  def amount_depreciated
    amount_at_start - amount_at_end
  end
end
