class RemoveColumnCompanyIdOnFinancialStatements < ActiveRecord::Migration
  def change
    remove_column :financial_statements, :company_id, :integer, :null => false
    remove_column :financial_statements, :branch_id, :integer, :null => false
    remove_column :financial_statements, :report_type, :integer, :null => false
  end
end
