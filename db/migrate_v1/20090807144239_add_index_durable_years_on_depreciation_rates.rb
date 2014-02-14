# -*- encoding : utf-8 -*-
class AddIndexDurableYearsOnDepreciationRates < ActiveRecord::Migration
  def self.up
    add_index :depreciation_rates, :durable_years, :unique => true
  end

  def self.down
    remove_index :depreciation_rates, :durable_years
  end
end
