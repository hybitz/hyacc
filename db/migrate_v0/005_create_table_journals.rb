# -*- encoding : utf-8 -*-
class CreateTableJournals < ActiveRecord::Migration
  def self.up
    create_table :journal_headers do |t|
      t.column "year_month", :integer, :limit => 6, :null => false
      t.column "day", :integer, :limit => 2, :null => false
      t.column "remarks", :string
      t.column "amount", :integer, :null => false
      t.column "account_finder_key", :string
      t.column "create_user_id", :integer, :null => false
      t.column "update_user_id", :integer, :null => false
      t.column "created_on", :datetime
      t.column "updated_on", :datetime
    end
    
    add_index :journal_headers, :year_month
    add_index :journal_headers, :account_finder_key
    
    create_table :journal_details do |t|
      t.column "journal_header_id", :integer, :null => false
      t.column "detail_no", :integer, :null => false
      t.column "dc_type", :integer, :limit => 1, :null => false
      t.column "account_id", :integer, :null => false
      t.column "amount", :integer, :null => false
      t.column "branch_id", :integer, :null => false
      t.column "bank_account_id", :integer
      t.column "created_on", :datetime
      t.column "updated_on", :datetime
    end

    # ヘッダのIDと明細番号でユニークとする
    add_index( :journal_details, [ :journal_header_id, :detail_no], :unique => true, :name => 'journal_details_journal_header_id_and_detail_no_index' )
  end

  def self.down
    remove_index( :journal_details, :name => 'journal_details_journal_header_id_and_detail_no_index' )
    drop_table :journal_details
  
    remove_index :journal_headers, :account_finder_key
    remove_index :journal_headers, :year_month
    drop_table :journal_headers
  end
end
