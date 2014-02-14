class AddIsBonusToPayrolls < ActiveRecord::Migration
  def self.up
    add_column :payrolls, :is_bonus, :boolean, :default=>false
  end

  def self.down
    remove_column :payrolls, :is_bonus
  end
end
