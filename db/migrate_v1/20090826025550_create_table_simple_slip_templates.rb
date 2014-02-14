# -*- encoding : utf-8 -*-
class CreateTableSimpleSlipTemplates < ActiveRecord::Migration
  include HyaccConstants
  
  def self.up
    create_table :simple_slip_templates do |t|
      t.string :remarks, :null=>false
      t.integer :owner_type, :null=>false
      t.integer :owner_id, :null=>false
      t.string :description
      t.string :keywords
      t.integer :account_id
      t.integer :branch_id
      t.integer :sub_account_id
      t.integer :dc_type, :limit=>1
      t.integer :amount
      t.integer :tax_type, :limit=>1
      t.integer :tax_amount
      t.string :focus_on_complete
      t.boolean :deleted, :null => false, :default=>false
      t.timestamps
    end
    
    add_index :simple_slip_templates, :remarks, :unique=>false

    # カラム情報を最新にする
    SimpleSlipTemplate.reset_column_information
    
    # 初期データを投入
    a = Account.find(20) # 福利厚生費
    sst = SimpleSlipTemplate.new
    sst.remarks = 'お茶代'
    sst.owner_type = OWNER_TYPE_COMPANY
    sst.owner_id = 1
    sst.keywords = "#{a.code} ocha おちゃだい オチャダイ"
    sst.account_id = a.id
    sst.dc_type = a.dc_type
    sst.tax_type = a.tax_type
    sst.focus_on_complete = 'amount'
    sst.save!
    
    a = Account.find(21) # 旅費交通費
    sst = SimpleSlipTemplate.new
    sst.remarks = 'タクシー代'
    sst.owner_type = OWNER_TYPE_COMPANY
    sst.owner_id = 1
    sst.keywords = "#{a.code} takushidai たくしーだい タクシーダイ"
    sst.account_id = a.id
    sst.dc_type = a.dc_type
    sst.tax_type = a.tax_type
    sst.focus_on_complete = 'amount'
    sst.save!
  end

  def self.down
    remove_index :simple_slip_templates, :remarks
    drop_table :simple_slip_templates
  end
end
