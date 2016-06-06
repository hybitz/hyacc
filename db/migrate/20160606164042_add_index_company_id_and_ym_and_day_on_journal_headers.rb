class AddIndexCompanyIdAndYmAndDayOnJournalHeaders < ActiveRecord::Migration
  def change
    add_index :journal_headers, [:company_id, :ym, :day], :name => 'index_journal_headers_on_company_id_and_date'
  end
end
