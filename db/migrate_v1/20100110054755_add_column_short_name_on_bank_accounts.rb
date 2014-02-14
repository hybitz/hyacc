# -*- encoding : utf-8 -*-
class AddColumnShortNameOnBankAccounts < ActiveRecord::Migration
  def self.up
    add_column :bank_accounts, :holder_name, :string
    
    # カラム情報を最新にする
    BankAccount.reset_column_information
    
    # 略称をセット
    BankAccount.find(:all).each do |ba|
      ba.holder_name = ba.name
      ba.save!
    end
    
    change_column :bank_accounts, :code, :string, :null=>false, :limit=>7
    change_column :bank_accounts, :holder_name, :string, :null=>false
    add_index :bank_accounts, :name, :unique=>true, :name=>:index_bank_accounts_on_name
end

  def self.down
    remove_column :bank_accounts, :holder_name
  end
end
