class BusinessOffice < ActiveRecord::Base
  belongs_to :company

  validates :name, :presence => true
  validates :prefecture_code, :presence => true
  
  def address
    [address1, address2].join
  end

end
