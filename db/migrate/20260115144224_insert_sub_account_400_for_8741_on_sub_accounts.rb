class InsertSubAccount400For8741OnSubAccounts < ActiveRecord::Migration[7.2]
  include HyaccConst

  def up
    account = Account.find_by_code(ACCOUNT_CODE_DONATION)
    return unless account

    sa = SubAccount.find_or_initialize_by(
      account_id: account.id,
      code: SUB_ACCOUNT_CODE_DONATION_FULLY_CONTROLLED
    )
    sa.name = '完全支配関係法人'
    sa.sub_account_type = SUB_ACCOUNT_TYPE_DONATION
    sa.social_expense_number_of_people_required = false
    sa.deleted = false
    sa.save!
  end

  def down
    account = Account.find_by_code(ACCOUNT_CODE_DONATION)
    return unless account

    sa = SubAccount.find_by(
      account_id: account.id,
      code: SUB_ACCOUNT_CODE_DONATION_FULLY_CONTROLLED
    )
    return unless sa

    sa.deleted = true
    sa.save!
  end
end
