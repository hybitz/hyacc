module PayrollInfo
  class PayrollLogic
    include HyaccConst

    def initialize(calendar_year, employee_id)
      @calendar_year = calendar_year.to_i
      @employee_id = employee_id.to_i
      @total_base_salary = get_total_base_salary
    end

    # 支払金額
    def get_total_base_salary
      ret = 0

      # calendar_year期間に支払われた給与
      Payroll.where(employee_id: @employee_id).where('pay_day >= ? and pay_day <= ?', "#{@calendar_year}-01-01", "#{@calendar_year}-12-31").each do |p|
        # 役員給与、役員賞与、給与手当
        p.payroll_journal.journal_details.where(account_id: salary_account_ids).each do |d|
          ret += d.amount
        end
      end

      ret
    end

    # 支払金額(前職を含む)
    def get_total_base_salary_include_previous
      base_salary = get_total_base_salary
      e = get_exemptions
      base_salary + e.previous_salary.to_i
    end

    # 支払金額(給与)
    def get_base_salaries
      ret = {}

      # calendar_year期間に支払われた給与
      Payroll.where('pay_day >= ? and pay_day <= ?', "#{@calendar_year}-01-01", "#{@calendar_year}-12-31").order('pay_day').each do |p|
        # 役員給与、役員賞与、給与手当
        p.payroll_journal.journal_details.where(account_id: salary_account_ids).each do |d|
          yyyymmdd = p.pay_day.strftime('%Y%m%d')
          ret[yyyymmdd] ||= 0
          ret[yyyymmdd] += d.amount
        end
      end

      ret
    end

    # みなし給与
    def get_total_deemed_salary
      deemed_salary = get_total_base_salary_include_previous

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
      deduction = 0

      case @calendar_year
      when .. 2012
        case deemed_salary
        when 0 .. 1_800_000
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

        deduction = 650_000 if deduction < 650_000
      when 2013 .. 2015
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
        when 10_000_001 .. 15_000_000
          deduction = deemed_salary * 0.05 + 1_700_000
        when 15_000_001 ..
          deduction = 2_450_000
        end
      when 2016
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
        when 10_000_001 .. 12_000_000
          deduction = deemed_salary * 0.05 + 1_700_000
        when 12_000_001 ..
          deduction = 2_300_000
        end
      when 2017..2019
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
          deduction = 2_200_000
        end
      when 2020 ..
        case deemed_salary
        when 0 .. 1_625_000
          deduction = 550_000
        when 1_625_001 .. 1_800_000
          deduction = deemed_salary * 0.4 - 100_000
        when 1_800_001 .. 3_600_000
          deduction = deemed_salary * 0.3 + 80_000
        when 3_600_001 .. 6_600_000
          deduction = deemed_salary * 0.2 + 440_000
        when 6_600_001 .. 8_500_000
          deduction = deemed_salary * 0.1 + 1_100_000
        when 8_500_001 ..
          deduction = 1_950_000
        end
      end

      deduction
    end

    # 給与所得控除後
    def get_after_deduction
      # みなし給与で計算
      [0, get_total_deemed_salary - get_deduction].max
    end

    def get_exemptions
     # 控除額の取得
      e = Exemption.find_by(yyyy: @calendar_year, employee_id: @employee_id)
      unless e
        HyaccLogger.error "源泉徴収情報が登録されていません。"
        raise HyaccException.new("源泉徴収情報が登録されていません。雇用ID：" + @employee_id.to_s)
      end
      e
    end

    # 所得控除の額の合計
    def get_total_exemption
      e = get_exemptions

      get_health_insurance + get_employee_pention + get_employment_insurance + 
          e.small_scale_mutual_aid.to_i + e.life_insurance_deduction.to_i +
          e.earthquake_insurance_premium.to_i + e.social_insurance_selfpay.to_i + e.special_tax_for_spouse.to_i + e.spouse.to_i + e.dependents.to_i +
          e.disabled_persons.to_i + e.basic.to_i + e.previous_social_insurance.to_i
    end

    # 源泉所得税
    def get_withholding_tax
      total_tax = get_withholding_tax_before_mortgage_deduction
      e = get_exemptions
      
      # 住宅借入金控除
      total_tax = total_tax - e.max_mortgage_deduction.to_i - e.fixed_tax_deduction_amount.to_i < 0 ? 0 : total_tax - e.max_mortgage_deduction.to_i - e.fixed_tax_deduction_amount.to_i

      # 復興特別税（H25以降）
      total_tax = total_tax * 1.021 if @calendar_year >= 2013
      total_tax = (total_tax/100).to_i * 100

      total_tax
    end

    # 源泉所得税（住宅ローン控除前）
    def get_withholding_tax_before_mortgage_deduction
      total_tax = 0
      # 給与所得控除後 - 基礎控除等
      b = get_after_deduction - get_total_exemption
      b = b < 0 ? 0 : b

      # 1,000円未満切り捨て
      b = (b/1000).to_i * 1000

      case @calendar_year
      when 0..2019
        if b <= 1_950_000
          total_tax = b * 0.05
        elsif b <= 3_300_000
          total_tax = b * 0.1 - 97_500
        elsif b <= 6_950_000
          total_tax = b * 0.2 - 427_500
        elsif b <= 9_000_000
          total_tax = b * 0.23 - 636_000
        elsif b <= 17_420_000
          total_tax = b * 0.33 - 1_536_000
        end
      else
        # https://www.nta.go.jp/publication/pamph/gensen/nencho2020/pdf/nencho_all.pdf
        # P93
        if b <= 1_950_000
          total_tax = b * 0.05
        elsif b <= 3_300_000
          total_tax = b * 0.1 - 97_500
        elsif b <= 6_950_000
          total_tax = b * 0.2 - 427_500
        elsif b <= 9_000_000
          total_tax = b * 0.23 - 636_000
        elsif b <= 18_000_000
          total_tax = b * 0.33 - 1_536_000
        elsif b <= 18_050_000
          total_tax = b * 0.40 - 2_796_000
        end
      end
      
      total_tax
    end

    # 健康保険料
    def get_health_insurance
      total_expense = 0
      # calendar_year期間に支払われた給与明細を取得
      list = Payroll.where(employee_id: @employee_id).joins(:pay_journal).where("journals.ym like ?",  @calendar_year.to_s + '%')

      list.each do |p|
        # 健康保険料(預り金)
        p.payroll_journal.journal_details.where(account_id: Account.find_by_code(ACCOUNT_CODE_DEPOSITS_RECEIVED),
                                                sub_account_id: SubAccount.where(code: TAX_DEDUCTION_TYPE_HEALTH_INSURANCE)).each do |d|
          total_expense = total_expense + d.amount
        end
        # 健康保険料(立替金)
        p.payroll_journal.journal_details.where(account_id: Account.find_by_code(ACCOUNT_CODE_ADVANCE_MONEY).id,
                                                sub_account_id: SubAccount.where(code: TAX_DEDUCTION_TYPE_HEALTH_INSURANCE)).each do |d|
          total_expense = total_expense + d.amount
        end

      end

      total_expense
    end

    # 厚生年金保険料
    def get_employee_pention
      total_expense = 0
      # calendar_year期間に支払われた給与明細を取得
      list = Payroll.where(:employee_id => @employee_id).joins(:pay_journal).where("journals.ym like ?",  @calendar_year.to_s + '%')

      list.each do |p|
        # 厚生年金保険料(預り金)
        p.payroll_journal.journal_details.where(account_id: Account.find_by_code(ACCOUNT_CODE_DEPOSITS_RECEIVED),
                                                sub_account_id: SubAccount.where(code: TAX_DEDUCTION_TYPE_WELFARE_PENSION)).each do |d|
          total_expense = total_expense + d.amount
        end
        # 厚生年金保険料(立替金)
        p.payroll_journal.journal_details.where(account_id: Account.find_by_code(ACCOUNT_CODE_ADVANCE_MONEY).id,
                                                sub_account_id: SubAccount.where(code: TAX_DEDUCTION_TYPE_WELFARE_PENSION)).each do |d|
          total_expense = total_expense + d.amount
        end

      end

      total_expense
    end

    # 雇用保険料
    def get_employment_insurance
      total_expense = 0
      # calendar_year期間に支払われた給与明細を取得
      list = Payroll.where(:employee_id => @employee_id).joins(:pay_journal).where("journals.ym like ?",  @calendar_year.to_s + '%')

      list.each do |p|
        # 雇用保険料(預り金)
        p.payroll_journal.journal_details.where(account_id: Account.find_by_code(ACCOUNT_CODE_DEPOSITS_RECEIVED).id,
                                                sub_account_id: SubAccount.where(code: TAX_DEDUCTION_TYPE_EMPLOYMENT_INSURANCE)).each do |d|
          total_expense = total_expense + d.amount
        end
        # 雇用保険料(立替金)
        p.payroll_journal.journal_details.where(account_id: Account.find_by_code(ACCOUNT_CODE_ADVANCE_MONEY).id,
                                                sub_account_id: SubAccount.where(code: TAX_DEDUCTION_TYPE_EMPLOYMENT_INSURANCE)).each do |d|
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
      list = Payroll.joins(:pay_journal).where("journals.ym like ?" + conditions,  @calendar_year.to_s + '%').order("journals.ym, journals.day")
      list.each do |p|
        # 賞与
        p.payroll_journal.journal_details.where(account_id: Account.find_by_code(ACCOUNT_CODE_DEPOSITS_RECEIVED),
                                                sub_account_id: SubAccount.where(code: TAX_DEDUCTION_TYPE_INCOME_TAX),
                                                dc_type: DC_TYPE_CREDIT).each do |d|
          yyyymmdd = p.pay_journal.ym.to_s + format("%02d", p.pay_journal.day)
          withholding_taxes[yyyymmdd] = withholding_taxes.has_key?(yyyymmdd) ? withholding_taxes[yyyymmdd] + d.amount : d.amount
        end
      end

      withholding_taxes
    end

    # 上期分の源泉所得税
   def get_all_withholding_taxes_1H
      amount = 0
      # calendar_year期間に支払われた給与明細を取得
      list = Payroll.joins(:pay_journal).where("journals.ym >= ? and journals.ym <= ?", @calendar_year.to_s + '01', @calendar_year.to_s + '06')
      list.each do |p|
        # 賞与
        p.payroll_journal.journal_details.where(account_id: Account.find_by_code(ACCOUNT_CODE_DEPOSITS_RECEIVED),
                                                sub_account_id: SubAccount.where(code: TAX_DEDUCTION_TYPE_INCOME_TAX),
                                                dc_type: DC_TYPE_CREDIT).each do |d|
          yyyymmdd = p.pay_journal.ym.to_s + format("%02d", p.pay_journal.day)
          amount += d.amount
        end
      end
      amount
    end
    
    # 下期分の源泉所得税
    def get_all_withholding_taxes_2H
      amount = 0
      # calendar_year期間に支払われた給与明細を取得
      list = Payroll.joins(:pay_journal).where("journals.ym >= ? and journals.ym <= ?", @calendar_year.to_s + '07', @calendar_year.to_s + '12')
      list.each do |p|
        # 賞与
        p.payroll_journal.journal_details.where(account_id: Account.find_by_code(ACCOUNT_CODE_DEPOSITS_RECEIVED),
                                                sub_account_id: SubAccount.where(code: TAX_DEDUCTION_TYPE_INCOME_TAX),
                                                dc_type: DC_TYPE_CREDIT).each do |d|
          yyyymmdd = p.pay_journal.ym.to_s + format("%02d", p.pay_journal.day)
          amount += d.amount
        end
      end
      amount
    end

    private

    def salary_account_ids
      @_salary_account_ids ||= Account.where(code: [ACCOUNT_CODE_EXECUTIVE_SALARY, ACCOUNT_CODE_EXECUTIVE_BONUS, ACCOUNT_CODE_SALARY]).pluck(:id)
    end

  end
end
