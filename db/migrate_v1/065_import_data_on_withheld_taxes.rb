# -*- encoding : utf-8 -*-
class ImportDataOnWithheldTaxes < ActiveRecord::Migration
  def self.up
    WithheldTax.delete_all
    
    # 初期データの投入
    dir = File.join(File.dirname(__FILE__), "fixtures/065")
    Fixtures.create_fixtures(dir, "withheld_taxes")
  end

  def self.down
    WithheldTax.delete_all
  end
end
