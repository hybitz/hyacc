class AddColumnTypeOnJournals < ActiveRecord::Migration[5.2]
  def change
    add_column :journals, :type, :string
  end
end
