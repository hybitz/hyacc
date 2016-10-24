class AddIndexCodeOnCustomers < ActiveRecord::Migration
  def change
    add_index :customers, :code, :unique => true
  end
end
