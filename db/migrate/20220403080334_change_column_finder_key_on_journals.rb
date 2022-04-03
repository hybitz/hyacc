class ChangeColumnFinderKeyOnJournals < ActiveRecord::Migration[5.2]
  def up
    change_column :journals, :finder_key, :string, limit: 1023
  end

  def down
    change_column :journals, :finder_key, :string
  end
end
