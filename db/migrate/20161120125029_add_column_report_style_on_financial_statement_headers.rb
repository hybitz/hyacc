class AddColumnReportStyleOnFinancialStatementHeaders < ActiveRecord::Migration
  def change
    add_column :financial_statement_headers, :report_style, :integer
  end
end
