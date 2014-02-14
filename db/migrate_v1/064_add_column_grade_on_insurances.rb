# -*- encoding : utf-8 -*-
class AddColumnGradeOnInsurances < ActiveRecord::Migration
  def self.up
    Insurance.delete_all
    add_column :insurances, "grade", :integer, :limit=>2, :null=>false, :default=>0
    
    # 初期データの投入
    dir = File.join(File.dirname(__FILE__), "fixtures/064")
    Fixtures.create_fixtures(dir, "insurances")
  end

  def self.down
    remove_column :insurances, "grade"
  end
end
