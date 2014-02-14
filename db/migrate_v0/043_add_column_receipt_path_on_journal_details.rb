# -*- encoding : utf-8 -*-
class AddColumnReceiptPathOnJournalDetails < ActiveRecord::Migration
  def self.up
    add_column :journal_details, "receipt_path", :string

    # カラム情報を最新にする
    JournalDetail.reset_column_information
  end

  def self.down
    remove_column :journal_details, "receipt_path"
  end
end
