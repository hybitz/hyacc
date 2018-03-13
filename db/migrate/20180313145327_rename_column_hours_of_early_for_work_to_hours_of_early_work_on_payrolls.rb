class RenameColumnHoursOfEarlyForWorkToHoursOfEarlyWorkOnPayrolls < ActiveRecord::Migration[5.1]
  def change
    rename_column :payrolls, :hours_of_early_for_work, :hours_of_early_work
  end
end
