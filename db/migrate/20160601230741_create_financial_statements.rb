class CreateFinancialStatements < ActiveRecord::Migration
  def change
    create_table :financial_statements do |t|
      t.integer :company_id, :null => false
      t.integer :branch_id, :null => false
      t.integer :report_type, :null => false
      t.integer :ym, :null => false
      t.integer :account_id, :null => false
      t.string :acccount_name, :null => false
      t.integer :amount, :null => false
      t.timestamps
    end
  end
end
