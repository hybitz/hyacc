class Update8491OnAccounts < ActiveRecord::Migration[8.1]
  include HyaccConst

  def up
    a = Account.find_by_code(ACCOUNT_CODE_SOCIAL_EXPENSE)
    return unless a
    return unless a.sub_account_editable?

    a.update_column(:sub_account_editable, false)
  end

  def down
  end
end
