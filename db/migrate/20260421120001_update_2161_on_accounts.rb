class Update2161OnAccounts < ActiveRecord::Migration[8.1]
  include HyaccConst

  def up
    a = Account.find_by_code(ACCOUNT_CODE_TOOLS_AND_EQUIPMENT)
    parent_2110 = Account.find_by_code(ACCOUNT_CODE_TANGIBLE_FIXED_ASSETS)
    return unless a && parent_2110

    return if a.parent_id == parent_2110.id

    a.parent_id = parent_2110.id
    a.save!
  end

  def down
    a = Account.find_by_code(ACCOUNT_CODE_TOOLS_AND_EQUIPMENT)
    p2100 = Account.find_by_code(ACCOUNT_CODE_FIXED_ASSET)
    p2110 = Account.find_by_code(ACCOUNT_CODE_TANGIBLE_FIXED_ASSETS)
    return unless a && p2100

    return unless p2110 && a.parent_id == p2110.id

    a.parent_id = p2100.id
    a.save!
  end
end
