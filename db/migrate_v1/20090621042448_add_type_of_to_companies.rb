# -*- encoding : utf-8 -*-
class AddTypeOfToCompanies < ActiveRecord::Migration
  def self.up
    add_column :companies, :type_of, :string, :null=>false, :limit => 1

    # カラム情報を最新にする
    Company.reset_column_information
    Company.update_all("type_of='1'")
  end

  def self.down
    remove_column :companies, :type_of
  end
end
