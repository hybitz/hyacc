class InsertSubAccount600For3301OnSubAccounts < ActiveRecord::Migration[8.1]
  include HyaccConst

  def up
    account = Account.find_by_code(ACCOUNT_CODE_DEPOSITS_RECEIVED)
    return unless account

    sa = SubAccount.find_or_initialize_by(
      account_id: account.id,
      code: TAX_DEDUCTION_TYPE_CHILD_AND_CHILDCARE_SUPPORT
    )
    sa.name = TAX_DEDUCTION_TYPES[TAX_DEDUCTION_TYPE_CHILD_AND_CHILDCARE_SUPPORT]
    sa.deleted = false
    sa.save!
  end

  def down
    account = Account.find_by_code(ACCOUNT_CODE_DEPOSITS_RECEIVED)
    return unless account

    sa = SubAccount.find_by(
      account_id: account.id,
      code: TAX_DEDUCTION_TYPE_CHILD_AND_CHILDCARE_SUPPORT
    )
    return unless sa

    sa.deleted = true
    sa.save!
  end
end
