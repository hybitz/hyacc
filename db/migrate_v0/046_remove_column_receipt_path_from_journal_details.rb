# -*- encoding : utf-8 -*-
class RemoveColumnReceiptPathFromJournalDetails < ActiveRecord::Migration
  def self.up
    remove_column :journal_details, "receipt_path"
    
    # 連続して後続のマイグレーションを実行できるようにカラム情報を最新にしておく
    JournalDetail.reset_column_information
  end

  def self.down
    add_column :journal_details, "receipt_path", :string
  end
end
