# -*- encoding : utf-8 -*-
class RemoveColumnDeletedFromSubAccounts < ActiveRecord::Migration
  def self.up
    remove_column :sub_accounts, "deleted"
    
    # 連続して後続のマイグレーションを実行できるようにカラム情報を最新にしておく
    SubAccount.reset_column_information
  end

  def self.down
    add_column :sub_accounts, "deleted", :boolean, :null => false, :default => false
  end
end
