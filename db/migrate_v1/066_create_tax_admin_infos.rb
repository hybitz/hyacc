# -*- encoding : utf-8 -*-
class CreateTaxAdminInfos < ActiveRecord::Migration
  def self.up
    create_table :tax_admin_infos do |t|
      t.integer :journal_header_id, :limit => 11, :null=>false
      t.boolean :should_include_tax, :null=>false, :default=>false
      t.boolean :checked, :null=>false, :default=>false

      t.timestamps
    end
    
    # 連続して後続のマイグレーションを実行できるようにカラム情報を最新にしておく
    TaxAdminInfo.reset_column_information
    
    # 2009年度の伝票を更新することで消費税管理情報を生成
    JournalHeader.find(:all, :conditions=>['ym>=200812']).each do |jh|
      jh.save!
    end
  end

  def self.down
    drop_table :tax_admin_infos
  end
end
