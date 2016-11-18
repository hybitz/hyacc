class AddColumnFinancialStatementHeaderIdOnFinancialStatements < ActiveRecord::Migration
  def change
    add_column :financial_statements, :financial_statement_header_id, :integer
  end
end
