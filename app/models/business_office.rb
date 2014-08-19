class BusinessOffice < ActiveRecord::Base
  belongs_to :company

  validates :name, :presence => true
  validates :prefecture_id, :presence => true
end
