class UpdateDirectorSalaryOnAccounts < ActiveRecord::Migration
  include HyaccConstants

  def up
    a = Account.find_by_code(ACCOUNT_CODE_DIRECTOR_SALARY)
    a.update_columns(:sub_account_type => SUB_ACCOUNT_TYPE_EMPLOYEE)
  end

  def down
  end
end
