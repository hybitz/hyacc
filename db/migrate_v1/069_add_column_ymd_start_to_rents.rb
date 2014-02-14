# -*- encoding : utf-8 -*-
class AddColumnYmdStartToRents < ActiveRecord::Migration

  def self.up
    Rent.delete_all
    
    add_column :rents, "ymd_start", :integer, :null=>false, :limit => 8
    add_column :rents, "ymd_end", :integer, :limit => 8

    # カラム情報を最新にする
    Rent.reset_column_information

    # 初期データの投入
    dir = File.join(File.dirname(__FILE__), "fixtures/069")
    Fixtures.create_fixtures(dir, "rents")
  end

  def self.down
    remove_column :rents, "ymd_start"
    remove_column :rents, "ymd_end"
  end
end
