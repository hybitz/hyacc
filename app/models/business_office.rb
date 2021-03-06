class BusinessOffice < ApplicationRecord
  belongs_to :company, inverse_of: 'business_offices'
  belongs_to :responsible_person, nostalgic: true, class_name: 'Employee', optional: true

  nostalgic_attr :name
  validates :name, presence: true, uniqueness: {scope: :company_id}

  validates :prefecture_code, presence: true

  before_save :set_prefecture_name

  def address
    [address1, address2].compact.join
  end

  private

  def set_prefecture_name
    p = TaxJp::Prefecture.find_by_code(self.prefecture_code)
    self.prefecture_name = p ? p.name : ''
  end
end
