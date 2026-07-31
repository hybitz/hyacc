class Update2702OnAccounts < ActiveRecord::Migration[8.1]
  def up
    a = Account.find_by_code('2702')
    return unless a

    a.update_column(:deleted, true)
  end

  def down
  end
end
