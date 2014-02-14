# -*- encoding : utf-8 -*-
class AddColumnNoteOnJournalDetails < ActiveRecord::Migration
  def self.up
    add_column :journal_details, "note", :string

    # カラム情報を最新にする
    JournalDetail.reset_column_information
  end

  def self.down
    remove_column :journal_details, "note"
  end
end
