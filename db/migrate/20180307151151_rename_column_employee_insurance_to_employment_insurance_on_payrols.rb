class RenameColumnEmployeeInsuranceToEmploymentInsuranceOnPayrols < ActiveRecord::Migration[5.1]
  def change
    rename_column :payrolls, :credit_account_type_of_employee_insurance, :credit_account_type_of_employment_insurance
  end
end
