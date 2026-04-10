class AddColumnChildAndChildcareSupportOnPayrolls < ActiveRecord::Migration[8.1]
  def change
    add_column :payrolls, :child_and_childcare_support, :integer, null: false, default: 0
  end
end
