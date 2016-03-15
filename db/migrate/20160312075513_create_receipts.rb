class CreateReceipts < ActiveRecord::Migration
  def change
    create_table :receipts do |t|
      t.integer :journal_header_id, :null => false
      t.string :file
      t.string :original_filename
      t.boolean :deleted, :null => false, :default => false
      t.timestamps
    end
  end
end
