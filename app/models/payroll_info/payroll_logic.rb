# -*- encoding : utf-8 -*-
module PayrollInfo
  class PayrollLogic
    include HyaccConstants
    
    def initialize(finder=nil)
      @calendar_year = finder.calendar_year
      @employee_id = finder.employee_id
    end
    
    def get_total_base_salary
      HyaccLogger.debug "20140407 Call get_total_base_salary"
      # calendar_year期間に支払われた給与明細を取得
      list = Payroll.where(:employee_id => @employee_id).joins(:pay_journal_headers).where("journal_headers.ym like ?",  @calendar_year.to_s + '%')
      
      list.each do |p|
        p.payroll_journal_headers.journal_details.where(:account_id => Account.get_by_code(ACCOUNT_CODE_DIRECTOR_SALARY).id).each do |d|
          HyaccLogger.debug "20140407 :" + d.amount.to_s
        end
      end
      HyaccLogger.debug "20140407 Call end get_total_base_salary"
      return 100000000000000
    end
  end
end
