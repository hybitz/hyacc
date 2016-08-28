class BusinessOffice < ActiveRecord::Base
  belongs_to :company, :inverse_of => 'business_offices'

  validates :name, :presence => true
  validates :prefecture_code, :presence => true

  before_save :set_prefecture_name
  
  def address
    [address1, address2].join
  end

  private

  def set_prefecture_name
    p = TaxJp::Prefecture.find_by_code(self.prefecture_code)
    self.prefecture_name = p.name if p
  end
end
