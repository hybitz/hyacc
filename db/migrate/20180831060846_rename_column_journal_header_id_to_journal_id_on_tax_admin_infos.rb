class RenameColumnJournalHeaderIdToJournalIdOnTaxAdminInfos < ActiveRecord::Migration[5.2]
  def change
    rename_column :tax_admin_infos, :journal_header_id, :journal_id
  end
end
