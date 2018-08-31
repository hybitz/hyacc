class ChangeColumnRemarksOnJournals < ActiveRecord::Migration[5.2]
  def up
    change_column :journals, :remarks, :string, null: false
  end
  def down
    change_column :journals, :remarks, :string, null: true
  end
end
