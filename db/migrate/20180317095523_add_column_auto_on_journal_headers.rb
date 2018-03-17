class AddColumnAutoOnJournalHeaders < ActiveRecord::Migration[5.1]
  def change
    add_column :journal_headers, :auto, :boolean, null: false, default: false
  end
end
