# -*- encoding : utf-8 -*-
class ChangeColumnUserIdToEmployeeIdOnInhabitantTaxes < ActiveRecord::Migration
  def self.up
    add_column :inhabitant_taxes, :employee_id, :integer
    
    # カラム情報を最新にする
    InhabitantTax.reset_column_information
    
    # データ移行
    InhabitantTax.find(:all).each do |it|
      it.employee_id = User.find(it.user_id).employee_id
      it.save!
    end
    
    remove_column :inhabitant_taxes, :user_id
    change_column :inhabitant_taxes, :employee_id, :integer, :null=>false
  end

  def self.down
    add_column :inhabitant_taxes, :user_id, :integer
    
    # カラム情報を最新にする
    InhabitantTax.reset_column_information
    
    # データ移行
    InhabitantTax.find(:all).each do |it|
      it.user_id = Employee.find(it.employee_id).users[0].id
      it.save!
    end
    
    remove_column :inhabitant_taxes, :employee_id
    change_column :inhabitant_taxes, :user_id, :integer, :null=>false
  end
end
