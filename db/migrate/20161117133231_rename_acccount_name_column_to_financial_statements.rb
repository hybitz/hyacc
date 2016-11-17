class RenameAcccountNameColumnToFinancialStatements < ActiveRecord::Migration
  def change
    rename_column :financial_statements, :acccount_name, :account_name
  end
end
