# -*- encoding : utf-8 -*-
class AddColumnLogoPathToCompanies < ActiveRecord::Migration
  def self.up
    add_column :companies, "logo_path", :string, :default=>""
  end

  def self.down
    remove_column :companies, "logo_path"
  end
end
