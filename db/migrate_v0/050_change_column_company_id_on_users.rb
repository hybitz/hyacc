# -*- encoding : utf-8 -*-
class ChangeColumnCompanyIdOnUsers < ActiveRecord::Migration
  def self.up
    change_column :users, :company_id, :integer, :null=>false
  end

  def self.down
    change_column :users, :company_id, :integer, :null=>true
  end
end
