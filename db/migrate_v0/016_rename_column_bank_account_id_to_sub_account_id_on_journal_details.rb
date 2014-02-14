# -*- encoding : utf-8 -*-
class RenameColumnBankAccountIdToSubAccountIdOnJournalDetails < ActiveRecord::Migration
  def self.up
    rename_column :journal_details, "bank_account_id", "sub_account_id"
  end

  def self.down
    rename_column :journal_details, "sub_account_id", "bank_account_id"
  end
end
