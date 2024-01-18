class AddColumnEnterpriseNumberOnCustomers < ActiveRecord::Migration[5.2]
  def change
    add_column :customers, :enterprise_number, :string, after: 'name'
  end
end
