class Bank < ApplicationRecord
  belongs_to :company

  TO_SAME_OFFICE = 1
  TO_OTHER_OFFICE = 2
  TO_OTHER_BANK = 3
  
  validates :code, presence: true
  validates :name, presence: true

  has_many :bank_offices
  accepts_nested_attributes_for :bank_offices
  
  def get_commission(amount, to)
    case to
    when TO_SAME_OFFICE then
      return amount < 30000 ? lt_30k_same_office : ge_30k_same_office
    when TO_OTHER_OFFICE then
      return amount < 30000 ? lt_30k_other_office : ge_30k_other_office
    when TO_OTHER_BANK then
      return  amount < 30000 ? lt_30k_other_bank : ge_30k_other_bank
    else
      raise HyaccException.new("無効な振込先です")
    end
  end
end
