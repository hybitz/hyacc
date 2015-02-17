class ChangeColumnIsBonusOnPayrolls < ActiveRecord::Migration
  def up
    change_column :payrolls, :is_bonus, :boolean, :null => false, :default => false
  end

  def down
    change_column :payrolls, :is_bonus, :boolean, :null => true, :default => false
  end

end
