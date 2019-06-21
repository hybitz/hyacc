class AddColumnStartFromOnRents < ActiveRecord::Migration[5.2]
  def change
    add_column :rents, :start_from, :date, null: false
  end
end
