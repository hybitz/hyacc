class Update4221OnAccounts < ActiveRecord::Migration[8.1]
  include HyaccConst

  def up
    a = Account.find_by_code(ACCOUNT_CODE_INTEREST_RECEIVED)
    return unless a
    return if a.account_type == ACCOUNT_TYPE_PROFIT

    a.account_type = ACCOUNT_TYPE_PROFIT
    a.save!
  end

  def down
  end
end
