# -*- encoding : utf-8 -*-
class AddColumnDeletedToSubAccounts < ActiveRecord::Migration

  def self.up
    add_column :sub_accounts, "deleted", :integer, :null=>false, :default => 0

    # カラム情報を最新にする
    SubAccount.reset_column_information
    
    # 削除フラグを設定する
    SubAccount.update_all("deleted=0")
  end

  def self.down
    remove_column :sub_accounts, "deleted"
  end
end
