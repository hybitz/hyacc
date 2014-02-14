# -*- encoding : utf-8 -*-
class UpdateAccounts < ActiveRecord::Migration
  include HyaccConstants

  # 未払金のコードを訂正
  def self.up
    add_column :accounts, "is_settlement_report_account", :boolean, :null => false, :default => true
    add_column :accounts, "sub_account_type", :integer, :limit => 1, :null => false, :default => 1
    
    # カラム情報を最新にする
    Account.reset_column_information
    
    various = Account.find_by_code(ACCOUNT_CODE_VARIOUS)
    various.dc_type = 0
    various.account_type = 0
    various.display_order = 99 # 適当に後ろにくるように
    various.parent_id = 0
    various.system_required = true
    various.trade_type = 0
    various.is_settlement_report_account = false
    various.save!
    
    debt = Account.find_by_code(ACCOUNT_CODE_DEBT)
    unpaid_e = Account.find_by_code('3181')
    unpaid_e.name = '未払金（従業員）'
    unpaid_e.save!
  
    unpaid = Account.new
    unpaid.code = '3170'
    unpaid.name = '未払金'
    unpaid.dc_type = debt.dc_type
    unpaid.account_type = debt.account_type
    unpaid.display_order = unpaid_e.display_order
    unpaid.parent_id = debt.id
    unpaid.system_required = true
    unpaid.trade_type = unpaid_e.trade_type
    unpaid.is_settlement_report_account = true
    unpaid.save!
    unpaid = Account.find_by_code('3170')
  
    unpaid_e = Account.find_by_code('3181')
    unpaid_e.code = ACCOUNT_CODE_UNPAID_EMPLOYEE
    unpaid_e.name = '未払金（従業員）'
    unpaid_e.display_order = 1
    unpaid_e.parent_id = unpaid.id
    unpaid_e.system_required = true
    unpaid_e.is_settlement_report_account = false
    unpaid_e.sub_account_type = SUB_ACCOUNT_TYPE_EMPLOYEE
    unpaid_e.save!
    
    unpaid_t = Account.new
    unpaid_t.code = '3172'
    unpaid_t.name = '未払金（取引先）'
    unpaid_t.dc_type = debt.dc_type
    unpaid_t.account_type = debt.account_type
    unpaid_t.display_order = 2
    unpaid_t.parent_id = unpaid.id
    unpaid_t.system_required = true
    unpaid_t.trade_type = unpaid.trade_type
    unpaid_t.is_settlement_report_account = false
    unpaid_t.save!
    
    JournalDetail.find(:all).each do |jd|
      if jd.account.code == ACCOUNT_CODE_UNPAID_EMPLOYEE
        print("updating journal_detail [" + jd.id.to_s + "]\n")
        jd.sub_account_id = jd.branch.branches_users[0].user_id
        jd.save!
      end
    end
    
    journals = JournalHeader.find(:all).each do |j|
      print("updating journal [" + j.id.to_s + "]\n")
      j.save!
    end
  end

  def self.down
  end
end
