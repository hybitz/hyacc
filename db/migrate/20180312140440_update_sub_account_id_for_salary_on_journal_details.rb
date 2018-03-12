class UpdateSubAccountIdForSalaryOnJournalDetails < ActiveRecord::Migration[5.1]
  include HyaccConstants
  
  def up
    [ACCOUNT_CODE_DIRECTOR_SALARY, ACCOUNT_CODE_SALARY, ACCOUNT_CODE_ACCRUED_EXPENSE_EMPLOYEE, ACCOUNT_CODE_UNPAID_EMPLOYEE].each do |code|
      a = Account.find_by_code(code)
      JournalDetail.where(account_id: a.id).find_each do |jd|
        employee = Employee.where(user_id: jd.sub_account_id).first
        puts "#{jd.id}: #{jd.account.name} #{jd.sub_account_id} => #{employee.id}"
        jd.update_column(:sub_account_id, employee.id)
      end
    end
  end
  
  def down
  end
end
