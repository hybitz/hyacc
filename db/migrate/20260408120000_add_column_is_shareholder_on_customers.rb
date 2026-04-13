class AddColumnIsShareholderOnCustomers < ActiveRecord::Migration[8.1]
  def change
    add_column :customers, :is_shareholder, :boolean, default: false, null: false
  end
end
