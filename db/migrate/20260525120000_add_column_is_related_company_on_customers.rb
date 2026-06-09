class AddColumnIsRelatedCompanyOnCustomers < ActiveRecord::Migration[8.1]
  def change
    add_column :customers, :is_related_company, :boolean, default: false, null: false
  end
end
