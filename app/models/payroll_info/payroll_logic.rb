# -*- encoding : utf-8 -*-
module PayrollInfo
  class PayrollLogic
    include HyaccConstants
    
    def initialize(finder=nil)
      @calendar_year = finder.calendar_year
      @employee_id = finder.employee_id
      @total_base_salary = get_total_base_salary
    end
    
    # 支払金額
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
    
    
    # 給与所得控除額
    def get_deduction
      total_base_salary = get_total_base_salary
      deduction = 650000
      case total_base_salary
      when 0 .. 1625000
        deduction = 650000
      when 1625001 .. 1800000
        deduction = total_base_salary * 0.4
      when 1800001 .. 3600000
        deduction = total_base_salary * 0.3 + 180000
      when 3600001 .. 6600000
        deduction = total_base_salary * 0.2 + 540000
      when 6600001 .. 10000000
        deduction = total_base_salary * 0.1 + 1200000
      when 10000001 .. 
        deduction = total_base_salary * 0.05 + 1700000
      end
      
      deduction = 2450000 if total_base_salary > 15000000 && @calendar_year >= 2013
      
      return deduction
    end
    
    # 給与所得控除後
    def get_after_deduction
      get_total_base_salary - get_deduction
    end
    
    # 控除額（基礎控除、扶養控除等）
    def get_exemption
      # 社会保険料等の控除額＋基礎控除等
      total = get_health_insurance + get_employee_pention + 790000
      return total
    end
    
    # 源泉所得税
    def get_withholding_tax
      total_tax = 0
      # 給与所得控除後 - 基礎控除等
      b = get_after_deduction - get_exemption

      # 1,000円未満切り捨て
      b = (b/1000).to_i * 1000
      
      if b <= 1950000
        total_tax = b * 0.05
      elsif b <= 3300000
        total_tax = b * 0.1 - 97500
      end
      
      # 復興特別税（H25以降）
      b = b * 1.021 if @calendar_year >= 2013
      b = (b/100).to_i * 100
      
      return total_tax
    end
    
    
    # 健康保険料
    def get_health_insurance
      total_expense = 0
      # calendar_year期間に支払われた給与明細を取得
      list = Payroll.where(:employee_id => @employee_id).joins(:pay_journal_headers).where("journal_headers.ym like ?",  @calendar_year.to_s + '%')
      
      list.each do |p|
        # 健康保険料(預り金)
        p.payroll_journal_headers.journal_details.where(:account_id => Account.get_by_code(ACCOUNT_CODE_DEPOSITS_RECEIVED).id,
                                                        :sub_account_id => SubAccount.where(:code => SUB_ACCOUNT_CODE_HEALTH_INSURANCE_OF_DEPOSITS_RECEIVED)).each do |d|
          total_expense = total_expense + d.amount
        end
        # 健康保険料(立替金)
        p.payroll_journal_headers.journal_details.where(:account_id => Account.get_by_code(ACCOUNT_CODE_ADVANCE_MONEY).id,
                                                        :sub_account_id => SubAccount.where(:code => SUB_ACCOUNT_CODE_HEALTH_INSURANCE_OF_ADVANCE_MONEY)).each do |d|
          total_expense = total_expense + d.amount
        end
        
      end
      return total_expense
    end
    
    # 厚生年金保険料
    def get_employee_pention
      total_expense = 0
      # calendar_year期間に支払われた給与明細を取得
      list = Payroll.where(:employee_id => @employee_id).joins(:pay_journal_headers).where("journal_headers.ym like ?",  @calendar_year.to_s + '%')
      
      list.each do |p|
        # 厚生年金保険料(預り金)
        p.payroll_journal_headers.journal_details.where(:account_id => Account.get_by_code(ACCOUNT_CODE_DEPOSITS_RECEIVED).id,
                                                        :sub_account_id => SubAccount.where(:code => SUB_ACCOUNT_CODE_EMPLOYEES_PENSION_OF_DEPOSITS_RECEIVED)).each do |d|
          total_expense = total_expense + d.amount
        end
        # 厚生年金保険料(立替金)
        p.payroll_journal_headers.journal_details.where(:account_id => Account.get_by_code(ACCOUNT_CODE_ADVANCE_MONEY).id,
                                                        :sub_account_id => SubAccount.where(:code => SUB_ACCOUNT_CODE_EMPLOYEES_PENSION_OF_ADVANCE_MONEY)).each do |d|
          total_expense = total_expense + d.amount
        end
        
      end
      return total_expense
    end
  end
end
