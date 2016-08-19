class AddColomnNameOnCustomers < ActiveRecord::Migration
  def change
    add_column :customers, :name, :string
  end
end
