class DropTableEmployeeHistories < ActiveRecord::Migration
  def change
    drop_table :employee_histories
  end
end
