# -*- encoding : utf-8 -*-
class CreateWithheldTaxes < ActiveRecord::Migration
  def self.up
    create_table :withheld_taxes do |t|
      t.integer :apply_start_ym, :limit => 6, :null => false, :default => 999912
      t.integer :apply_end_ym, :limit => 6, :null => false, :default => 999912
      t.integer :pay_range_above, :limit => 10
      t.integer :pay_range_under, :limit => 10
      t.integer :no_dependent, :limit => 10
      t.integer :one_dependent, :limit => 10
      t.integer :two_dependent, :limit => 10
      t.integer :three_dependent, :limit => 10
      t.integer :four_dependent, :limit => 10
      t.integer :five_dependent, :limit => 10
      t.integer :six_dependent, :limit => 10
      t.integer :seven_dependent, :limit => 10

      t.timestamps
    end
  end

  def self.down
    drop_table :withheld_taxes
  end
end
