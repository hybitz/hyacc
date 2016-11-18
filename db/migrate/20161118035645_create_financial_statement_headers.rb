class CreateFinancialStatementHeaders < ActiveRecord::Migration
  def change
    create_table :financial_statement_headers do |t|
      t.integer :company_id, :null => false
      t.integer :branch_id, :null => false
      t.integer :report_type, :null => false
      t.integer :fiscal_year, :null => false
      t.integer :max_node_level, :null => false
      t.timestamps null: false
    end
  end
end
