# -*- encoding : utf-8 -*-
module PayrollInfo
  class PayrollLogic
    include HyaccConstants
    
    def initialize(finder=nil)
      @calendar_year = finder.calendar_year
      @employee_id = finder.employee_idx
    end
    
    def get_total_base_salary
      total_base_salary = 0
      # calendar_year期間に支払われた給与明細を取得
      list = Payroll.where(:employee_id => @employee_id).joins(:pay_journal_headers).where("journal_headers.ym like ?",  @calendar_year.to_s + '%')
      
      list.each do |p|
        # 給与
        p.payroll_journal_headers.journal_details.where(:account_id => Account.get_by_code(ACCOUNT_CODE_DIRECTOR_SALARY).id).each do |d|
          total_base_salary = total_base_salary + d.amount
        end
        # 賞与
        p.payroll_journal_headers.journal_details.where(:account_id => Account.get_by_code(ACCOUNT_CODE_ACCRUED_DIRECTOR_BONUS).id).each do |d|
          total_base_salary = total_base_salary + d.amount
        end
      end
      return total_base_salary
    end
  end
end
