# -*- encoding : utf-8 -*-
class AddColumnSubAccountIdToBranches < ActiveRecord::Migration
  include HyaccConstants

  def self.up
    add_column :branches, "sub_account_id", :integer
    
    # カラム情報を最新にする
    Branch.reset_column_information

    # 各部門の補助科目を設定
    a = Account.find_by_code(ACCOUNT_CODE_BRANCH_OFFICE)

    ichy = Branch.find_by_name('ICHY')
    ichy.sub_account_id = a.sub_accounts.find_by_name('ICHY').id
    ichy.save!
    
    hiro = Branch.find_by_name('HIRO')
    hiro.sub_account_id = a.sub_accounts.find_by_name('HIRO').id
    hiro.save!
  end

  def self.down
    remove_column :branches, "sub_account_id"
  end
end
