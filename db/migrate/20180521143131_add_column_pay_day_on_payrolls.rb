class AddColumnPayDayOnPayrolls < ActiveRecord::Migration[5.2]
  def change
    add_column :payrolls, :pay_day, :date
  end
end
