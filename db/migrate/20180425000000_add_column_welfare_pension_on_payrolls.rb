class AddColumnWelfarePensionOnPayrolls < ActiveRecord::Migration[5.1]
  def change
    add_column :payrolls, :welfare_pension, :integer, null: false, default: 0
  end
end
