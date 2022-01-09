class UpdateAccountTaxAndDues < ActiveRecord::Migration[5.2]
  include HyaccConst

  def up
    a = Account.find_by(code: ACCOUNT_CODE_TAX_AND_DUES)
    a.update_columns(sub_account_type: SUB_ACCOUNT_TYPE_TAX_AND_DUES)
  end

  def down
  end
end
