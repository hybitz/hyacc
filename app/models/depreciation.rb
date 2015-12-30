class Depreciation < ActiveRecord::Base
  belongs_to :asset
  has_many :journal_headers, -> {order(:fiscal_year)}, :dependent => :destroy
  accepts_nested_attributes_for :journal_headers
  
  def amount_depreciated
    amount_at_start - amount_at_end
  end
end
