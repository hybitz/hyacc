# -*- encoding : utf-8 -*-
class AddColumnTransferFromIdAndTransferToIdToJournalHeaders < ActiveRecord::Migration
  include HyaccConstants
  
  def self.up
    add_column :journal_headers, "transfer_from_id", :integer
    
    # 前払費用の科目を登録
    prepaid_expense = Account.new
    prepaid_expense.code = ACCOUNT_CODE_PREPAID_EXPENSE
    prepaid_expense.name = '前払費用'
    prepaid_expense.dc_type = DC_TYPE_DEBIT
    prepaid_expense.account_type = ACCOUNT_TYPE_ASSET
    prepaid_expense.display_order = Account.find_by_code('1821').display_order
    prepaid_expense.parent_id = Account.find_by_code('1100').id
    prepaid_expense.system_required = true
    prepaid_expense.save!
  end

  def self.down
    Account.find_by_code( ACCOUNT_CODE_PREPAID_EXPENSE ).destroy
  
    remove_column :journal_headers, "transfer_from_id"
  end
end
