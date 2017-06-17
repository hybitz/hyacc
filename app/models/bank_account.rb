class BankAccount < ApplicationRecord
  belongs_to :bank
  belongs_to :bank_office

  validates :code, :presence => true
  validates :name, :presence => true, :uniqueness => true
  validates :holder_name, :presence => true

  after_save :reset_account_cache

  def bank_name
    return nil unless bank
    bank.name
  end
  
  def bank_office_name
    return nil unless bank_office
    bank_office.name
  end

  def financial_account_type_name
    FINANCIAL_ACCOUNT_TYPES[financial_account_type]
  end

  def reset_account_cache
    Account.expire_caches_by_sub_account_type(SUB_ACCOUNT_TYPE_SAVING_ACCOUNT)
  end
  
end
