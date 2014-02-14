# -*- encoding : utf-8 -*-
class AddColumnJournalizableToAccounts < ActiveRecord::Migration
  def self.up
    add_column :accounts, :journalizable, :boolean, :null=>false, :default=>true

    # カラム情報を最新にする
    Account.reset_column_information
    
    # マイグレーション時点でノードの勘定科目は仕訳登録不可とする
    Account.find(:all).each do |a|
      next if a.is_leaf
      a.journalizable = false
      a.save!
    end
  end

  def self.down
    remove_column :accounts, :journalizable
  end
end
