# -*- encoding : utf-8 -*-
class CreateTableCompany < ActiveRecord::Migration
  def self.up
    create_table :companies do |t|
      t.column "name", :string, :null => false
      t.column "fiscal_year", :integer, :limit => 4, :null => false
      t.column "start_month_of_fiscal_year", :integer, :limit => 2, :null => false
      t.column "deleted", :boolean, :null => false, :default => false
      t.column "created_on", :datetime
      t.column "updated_on", :datetime
    end
    
    # 初期データの投入
    dir = File.join(File.dirname(__FILE__), "fixtures/011")
    Fixtures.create_fixtures(dir, "companies")
    now = Time.now
    Company.update_all(["created_on=?, updated_on=?", now, now ])
  end

  def self.down
    drop_table :companies
  end
end
