class Bank < ApplicationRecord
  belongs_to :company
  nostalgic_attr :name

  TO_SAME_OFFICE = 1
  TO_OTHER_OFFICE = 2
  TO_OTHER_BANK = 3
  
  validates :code, presence: true
  validates :name, presence: true
  validates_with Validators::ReferencedOnDeletionValidator
  validates_with Validators::ReferencedOnDisableValidator

  has_many :bank_offices, -> { where(deleted: false) }, inverse_of: 'bank'
  accepts_nested_attributes_for :bank_offices

  def get_commission(amount, to)
    case to
    when TO_SAME_OFFICE
      return amount < 30000 ? lt_30k_same_office : ge_30k_same_office
    when TO_OTHER_OFFICE
      return amount < 30000 ? lt_30k_other_office : ge_30k_other_office
    when TO_OTHER_BANK
      return  amount < 30000 ? lt_30k_other_bank : ge_30k_other_bank
    else
      raise HyaccException.new("無効な振込先です")
    end
  end
end
