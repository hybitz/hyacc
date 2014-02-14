# -*- encoding : utf-8 -*-
class CreateInsurances < ActiveRecord::Migration
  def self.up
    create_table :insurances do |t|
      t.integer :apply_start_ym, :limit => 6, :null => false, :default => 999912
      t.integer :apply_end_ym, :limit => 6, :null => false, :default => 999912
      t.integer :pay_range_above, :limit => 10
      t.integer :pay_range_under, :limit => 10
      t.integer :monthly_earnings, :limit => 10
      t.integer :daily_earnings, :limit => 10
      t.integer :health_insurance_all, :limit => 10
      t.integer :health_insurance_half, :limit => 10
      t.float :health_insurance_all_care, :limit => 10
      t.float :health_insurance_half_care, :limit => 10
      t.float :welfare_pension_insurance_all, :limit => 10
      t.float :welfare_pension_insurance_half, :limit => 10

      t.timestamps
    end
  end

  def self.down
    Insurance.delete_all
    drop_table :insurances
  end
end
