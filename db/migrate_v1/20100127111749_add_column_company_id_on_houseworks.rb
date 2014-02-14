# -*- encoding : utf-8 -*-
#
# $Id: 20100127111749_add_column_company_id_on_houseworks.rb 2484 2011-03-23 15:51:29Z ichy $
# Product: hyacc
# Copyright 2009 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class AddColumnCompanyIdOnHouseworks < ActiveRecord::Migration
  def self.up
    remove_index :houseworks, :name=>:index_houseworks_on_fiscal_year
    add_column :houseworks, :company_id, :integer
    
    # カラム情報を最新にする
    Housework.reset_column_information
    
    Housework.update_all("company_id=#{Company.find(:first).id}")
    
    change_column :houseworks, :company_id, :integer, :null=>false
  end

  def self.down
    remove_column :houseworks, :company_id
    add_index :houseworks, :fiscal_year, :unique=>true, :name=>:index_houseworks_on_fiscal_year
  end
end
