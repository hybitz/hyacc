class UpdateIncomeTaxesReceivable < ActiveRecord::Migration[5.2]
  include HyaccConstants

  def up
    a = Account.find_by_code(ACCOUNT_CODE_INCOME_TAXES_RECEIVABLE)
    a.update_column(:sub_account_type, SUB_ACCOUNT_TYPE_CORPORATE_TAX)
  end
  
  def down
  end
end
