module PayrollInfo
  class PayrollLogic
    include HyaccConstants

    def initialize(calendar_year, employee_id)
      @calendar_year = calendar_year.to_i
      @employee_id = employee_id.to_i
      @total_base_salary = get_total_base_salary
    end

    # 支払金額
    def get_total_base_salary
      total_base_salary = 0

      # calendar_year期間に支払われた給与明細を取得
      list = Payroll.where(:employee_id => @employee_id).joins(:pay_journal_header).where("journal_headers.ym like ?",  @calendar_year.to_s + '%')

      list.each do |p|
        # 役員給与
        p.payroll_journal_header.journal_details.where(:account_id => Account.find_by_code(ACCOUNT_CODE_DIRECTOR_SALARY).id).each do |d|
          total_base_salary += d.amount
        end
        # 給与手当
        p.payroll_journal_header.journal_details.where(:account_id => Account.find_by_code(ACCOUNT_CODE_SALARY).id).each do |d|
          total_base_salary += d.amount
        end
        # 賞与
        p.payroll_journal_header.journal_details.where(:account_id => Account.find_by_code(ACCOUNT_CODE_ACCRUED_DIRECTOR_BONUS).id).each do |d|
          total_base_salary += d.amount
        end
      end

      total_base_salary
    end

    # 支払金額(給与)
    def get_base_salaries
      salarys = {}

      # calendar_year期間に支払われた給与明細を取得
      list = Payroll.joins(:pay_journal_header).where("journal_headers.ym like ?",  @calendar_year.to_s + '%').order("journal_headers.ym, journal_headers.day")

      list.each do |p|
        # 役員給与
        p.payroll_journal_header.journal_details.where(:account_id => Account.find_by_code(ACCOUNT_CODE_DIRECTOR_SALARY).id).each do |d|
          yyyymmdd = p.pay_journal_header.ym.to_s + format("%02d", p.pay_journal_header.day)
          salarys[yyyymmdd] = salarys.has_key?(yyyymmdd) ? salarys[yyyymmdd] + d.amount : d.amount
        end
        # 給与手当
        p.payroll_journal_header.journal_details.where(:account_id => Account.find_by_code(ACCOUNT_CODE_SALARY).id).each do |d|
          yyyymmdd = p.pay_journal_header.ym.to_s + format("%02d", p.pay_journal_header.day)
          salarys[yyyymmdd] = salarys.has_key?(yyyymmdd) ? salarys[yyyymmdd] + d.amount : d.amount
        end
      end
      return salarys
    end

    # 支払金額(賞与)
    def get_base_bonuses
      bonuses = {}

      # calendar_year期間に支払われた給与明細を取得
      list = Payroll.joins(:pay_journal_header).where("journal_headers.ym like ?",  @calendar_year.to_s + '%')

      list.each do |p|
        # 賞与
        p.payroll_journal_header.journal_details.where(:account_id => Account.find_by_code(ACCOUNT_CODE_ACCRUED_DIRECTOR_BONUS).id).each do |d|
          yyyymmdd = p.pay_journal_header.ym.to_s + format("%02d", p.pay_journal_header.day)
          bonuses[yyyymmdd] = bonuses.has_key?(yyyymmdd) ? bonuses[yyyymmdd] + d.amount : d.amount
        end
      end
      return bonuses
    end

    # みなし給与
    def get_total_deemed_salary
      deemed_salary = get_total_base_salary
      deemed_salary = 0 if deemed_salary.blank?
      # 年末調整のしかたの「Ⅵ　電子計算機等による年末調整」を参照
      deemed_salary = (deemed_salary/1000).to_i * 1000 if deemed_salary >= 1_619_000 && deemed_salary <= 1_619_999
      deemed_salary = (deemed_salary/2000).to_i * 2000 if deemed_salary >= 1_620_000 && deemed_salary <= 1_623_999
      deemed_salary = (deemed_salary/4000).to_i * 4000 if deemed_salary >= 1_624_000 && deemed_salary <= 6_599_999
      deemed_salary
    end

    # 給与所得控除額
    def get_deduction
      # みなし給与で計算
      deemed_salary = get_total_deemed_salary
      deduction = 650_000
      case deemed_salary
      when 0 .. 1_625_000
        deduction = 650_000
      when 1_625_001 .. 1_800_000
        deduction = deemed_salary * 0.4
      when 1_800_001 .. 3_600_000
        deduction = deemed_salary * 0.3 + 180_000
      when 3_600_001 .. 6_600_000
        deduction = deemed_salary * 0.2 + 540_000
      when 6_600_001 .. 10_000_000
        deduction = deemed_salary * 0.1 + 1_200_000
      when 10_000_001 ..
        deduction = deemed_salary * 0.05 + 1_700_000
      end

      deduction = 2_450_000 if deemed_salary > 15_000_000 && @calendar_year >= 2013
      return deduction
    end

    # 給与所得控除後
    def get_after_deduction
      # みなし給与で計算
      (get_total_deemed_salary - get_deduction) < 0 ? 0 : (get_total_deemed_salary - get_deduction)
    end

    def get_exemptions
     # 控除額の取得
      e = Exemption.where(:employee_id => @employee_id, :yyyy => @calendar_year).first
      unless e
        HyaccLogger.error "源泉徴収情報が登録されていません。"
        raise HyaccException.new("源泉徴収情報が登録されていません。")
      end
      e
    end


    # 控除額（基礎控除、扶養控除等）
    def get_exemption
      # 控除額の取得
      e = get_exemptions
      # 社会保険料等の控除額＋基礎控除等
      total = get_health_insurance + get_employee_pention +
                e.small_scale_mutual_aid.to_i + e.life_insurance_premium.to_i + e.earthquake_insurance_premium.to_i +
                e.special_tax_for_spouse.to_i + e.spouse.to_i + e.dependents.to_i + e.disabled_persons.to_i + e.basic.to_i
      return total
    end

    # 源泉所得税
    def get_withholding_tax
      total_tax = 0
      # 給与所得控除後 - 基礎控除等
      b = get_after_deduction - get_exemption
      b = b < 0 ? 0 : b

      # 1,000円未満切り捨て
      b = (b/1000).to_i * 1000

      if b <= 1_950_000
        total_tax = b * 0.05
      elsif b <= 3_300_000
        total_tax = b * 0.1 - 97500
      end
      
      # 住宅借入金控除
      e = get_exemptions
      total_tax = total_tax - e.mortgage_deduction.to_i < 0 ? 0 : total_tax - e.mortgage_deduction.to_i

      # 復興特別税（H25以降）
      total_tax = total_tax * 1.021 if @calendar_year >= 2013
      total_tax = (total_tax/100).to_i * 100

      total_tax
    end

    # 健康保険料
    def get_health_insurance
      total_expense = 0
      # calendar_year期間に支払われた給与明細を取得
      list = Payroll.where(:employee_id => @employee_id).joins(:pay_journal_header).where("journal_headers.ym like ?",  @calendar_year.to_s + '%')

      list.each do |p|
        # 健康保険料(預り金)
        p.payroll_journal_header.journal_details.where(:account_id => Account.find_by_code(ACCOUNT_CODE_DEPOSITS_RECEIVED).id,
                                                        :sub_account_id => SubAccount.where(:code => SUB_ACCOUNT_CODE_HEALTH_INSURANCE)).each do |d|
          total_expense = total_expense + d.amount
        end
        # 健康保険料(立替金)
        p.payroll_journal_header.journal_details.where(:account_id => Account.find_by_code(ACCOUNT_CODE_ADVANCE_MONEY).id,
                                                        :sub_account_id => SubAccount.where(:code => SUB_ACCOUNT_CODE_HEALTH_INSURANCE)).each do |d|
          total_expense = total_expense + d.amount
        end

      end

      total_expense
    end

    # 厚生年金保険料
    def get_employee_pention
      total_expense = 0
      # calendar_year期間に支払われた給与明細を取得
      list = Payroll.where(:employee_id => @employee_id).joins(:pay_journal_header).where("journal_headers.ym like ?",  @calendar_year.to_s + '%')

      list.each do |p|
        # 厚生年金保険料(預り金)
        p.payroll_journal_header.journal_details.where(:account_id => Account.find_by_code(ACCOUNT_CODE_DEPOSITS_RECEIVED).id,
                                                        :sub_account_id => SubAccount.where(:code => SUB_ACCOUNT_CODE_EMPLOYEES_PENSION_OF_DEPOSITS_RECEIVED)).each do |d|
          total_expense = total_expense + d.amount
        end
        # 厚生年金保険料(立替金)
        p.payroll_journal_header.journal_details.where(:account_id => Account.find_by_code(ACCOUNT_CODE_ADVANCE_MONEY).id,
                                                        :sub_account_id => SubAccount.where(:code => SUB_ACCOUNT_CODE_EMPLOYEES_PENSION_OF_ADVANCE_MONEY)).each do |d|
          total_expense = total_expense + d.amount
        end

      end

      total_expense
    end

    # 源泉所得税(給与)
    def get_withholding_taxes_salary
      return get_withholding_taxes(false)
    end

    # 源泉所得税(賞与)
    def get_withholding_taxes_of_bonus
      return get_withholding_taxes(true)
    end

    # 源泉所得税
    def get_withholding_taxes(is_bonus = nil)
      conditions = ""
      unless is_bonus.nil?
        if is_bonus
          conditions = " and is_bonus = true"
        else
          conditions = " and is_bonus = false"
        end
      end

      withholding_taxes = {}
      # calendar_year期間に支払われた給与明細を取得
      list = Payroll.joins(:pay_journal_header).where("journal_headers.ym like ?" + conditions,  @calendar_year.to_s + '%').order("journal_headers.ym, journal_headers.day")
      list.each do |p|
        # 賞与
        p.payroll_journal_header.journal_details.where(:account_id => Account.find_by_code(ACCOUNT_CODE_DEPOSITS_RECEIVED),
                                                        :sub_account_id => SubAccount.where(:code => SUB_ACCOUNT_CODE_INCOME_TAX_OF_DEPOSITS_RECEIVED),
                                                        :dc_type => DC_TYPE_CREDIT).each do |d|
          yyyymmdd = p.pay_journal_header.ym.to_s + format("%02d", p.pay_journal_header.day)
          withholding_taxes[yyyymmdd] = withholding_taxes.has_key?(yyyymmdd) ? withholding_taxes[yyyymmdd] + d.amount : d.amount
        end
      end

      withholding_taxes
    end

  end
end
