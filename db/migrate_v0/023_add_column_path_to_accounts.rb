# -*- encoding : utf-8 -*-
class AddColumnPathToAccounts < ActiveRecord::Migration
  def self.up
    add_column :accounts, "path", :string, :null => false, :default => ""
    
    # カラム情報を最新にする
    Account.reset_column_information
    
    # 既存レコードを更新してpathを設定する
    Account.find(:all).each do |a|
      a.save!
    end
  end

  def self.down
    remove_column :accounts, "path"
  end
end
