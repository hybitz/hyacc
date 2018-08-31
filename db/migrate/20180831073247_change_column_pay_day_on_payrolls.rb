class ChangeColumnPayDayOnPayrolls < ActiveRecord::Migration[5.2]
  def up
    change_column :payrolls, :pay_day, :date, null: false
  end
  def down
    change_column :payrolls, :pay_day, :date, null: true
  end
end
