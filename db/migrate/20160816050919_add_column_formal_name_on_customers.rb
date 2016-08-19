class AddColumnFormalNameOnCustomers < ActiveRecord::Migration
  def change
    add_column :customers, :formal_name, :string
  end
end
