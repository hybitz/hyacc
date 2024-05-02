class RemoveColumnRemarksOnPayrolls < ActiveRecord::Migration[5.2]
  def change
    remove_column :payrolls, :remarks, :string
  end
end
