class UpdateConsumptionTaxOnAccounts < ActiveRecord::Migration[5.2]
  include HyaccConstants

  def up
    a = Account.find_by(code: ACCOUNT_CODE_CONSUMPTION_TAX_PAYABLE)
    if a
      a.update_columns(sub_account_type: SUB_ACCOUNT_TYPE_CONSUMPTION_TAX, system_required: true, sub_account_editable: false)
    end
  end

  def down
  end
end
