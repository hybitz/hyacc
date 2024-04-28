class AddColumnRemarksOnPayrolls < ActiveRecord::Migration[5.2]
  def change
    add_column :payrolls, :remarks, :string
  end
end
