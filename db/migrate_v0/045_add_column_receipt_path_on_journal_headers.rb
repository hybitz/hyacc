# -*- encoding : utf-8 -*-
class AddColumnReceiptPathOnJournalHeaders < ActiveRecord::Migration
  def self.up
    add_column :journal_headers, "receipt_path", :string

    # カラム情報を最新にする
    JournalDetail.reset_column_information
  end

  def self.down
    remove_column :journal_headers, "receipt_path"
  end
end
