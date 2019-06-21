class AddColumnEndToOnRents < ActiveRecord::Migration[5.2]
  def change
    add_column :rents, :end_to, :date
  end
end
