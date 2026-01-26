class InsertSubAccount600For8741OnSubAccounts < ActiveRecord::Migration[7.2]
  include HyaccConst

  def up
    account = Account.find_by_code(ACCOUNT_CODE_DONATION)
    return unless account

    sa = SubAccount.find_or_initialize_by(
      account_id: account.id,
      code: SUB_ACCOUNT_CODE_DONATION_NON_CERTIFIED_TRUST
    )
    sa.name = '特定公益信託（認定外）'
    sa.deleted = false
    sa.save!
  end

  def down
    account = Account.find_by_code(ACCOUNT_CODE_DONATION)
    return unless account

    sa = SubAccount.find_by(
      account_id: account.id,
      code: SUB_ACCOUNT_CODE_DONATION_NON_CERTIFIED_TRUST
    )
    return unless sa

    sa.deleted = true
    sa.save!
  end
end
