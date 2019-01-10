class ChangeColumnSubAccountEditableOnAccounts < ActiveRecord::Migration[5.2]
  def up
    change_column :accounts, :sub_account_editable, :boolean, null: false, default: false
    
    Account.find_each do |a|
      a.save!
    end
  end
  
  def down
    change_column :accounts, :sub_account_editable, :boolean, null: false, default: true
  end
end
