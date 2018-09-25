module PayrollHelper

  # 標準報酬月額の計算
  def get_standard_remuneration(ym, employee, salary)
    standard_remuneration = 0

    prefecture_code = employee.business_office.prefecture_code

    ym = ym.to_i
    # 1,2,3か月前の給与
    ym_1 = (Date.new(ym/100, ym%100, 1) << 1).strftime("%Y%m")
    ym_2 = (Date.new(ym/100, ym%100, 1) << 2).strftime("%Y%m")
    ym_3 = (Date.new(ym/100, ym%100, 1) << 3).strftime("%Y%m")
    pr_1 = Payroll.find_by_ym_and_employee_id(ym_1, employee.id)
    pr_2 = Payroll.find_by_ym_and_employee_id(ym_2, employee.id)
    pr_3 = Payroll.find_by_ym_and_employee_id(ym_3, employee.id)
    if pr_3.nil?
      if pr_2.present?
        return pr_2.monthly_standard
      end
      if pr_1.present?
        return pr_1.monthly_standard
      end

      return TaxUtils.get_basic_info(ym, prefecture_code, salary).monthly_standard
    end

    # 7月より前は前年の4月を基準とする
    x = (ym.to_s).slice(0, 4) + "04"
    if ym.to_s.slice(4, 2).to_i < 7
      y = ((ym.to_s).slice(0, 4)).to_i - 1
      x = y.to_s + "04"
    end
    pr = Payroll.find_by_ym_and_employee_id(x, employee.id)
    while pr.payroll_journal.nil?
      x = (Date.new(x.to_i/100, x.to_i%100, 1) >> 1).strftime("%Y%m")
      pr = Payroll.find_by_ym_and_employee_id(x, employee.id)
    end
    # 基準となる標準報酬月額
    x1 = (Date.new(x.to_i/100, x.to_i%100, 1) >> 1).strftime("%Y%m")
    x2 = (Date.new(x.to_i/100, x.to_i%100, 1) >> 2).strftime("%Y%m")
    pr1 = Payroll.find_by_ym_and_employee_id(x1, employee.id)
    pr2 = Payroll.find_by_ym_and_employee_id(x2, employee.id)
    ave_bs = (pr.salary_total + pr1.salary_total + pr2.salary_total)/3
    insurance_ave_bs = TaxUtils.get_basic_info(ym, prefecture_code, ave_bs)
    grade_ave_bs = insurance_ave_bs.grade
    pre_bs = pr.salary_total
    standard_remuneration = insurance_ave_bs.monthly_standard
    while ((Date.new(x.to_i/100, x.to_i%100, 1) >> 2).strftime("%Y%m")).to_i < ym.to_i
      x = (Date.new(x.to_i/100, x.to_i%100, 1) >> 1).strftime("%Y%m")
      pr = Payroll.find_by_ym_and_employee_id(x, employee.id)
      if pre_bs != pr.salary_total
        if ((Date.new(x.to_i/100, x.to_i%100, 1) >> 2).strftime("%Y%m")).to_i < ym.to_i
          x1 = (Date.new(x.to_i/100, x.to_i%100, 1) >> 1).strftime("%Y%m")
          x2 = (Date.new(x.to_i/100, x.to_i%100, 1) >> 2).strftime("%Y%m")
          pr1 = Payroll.find_by_ym_and_employee_id(x1, employee.id)
          pr2 = Payroll.find_by_ym_and_employee_id(x2, employee.id)
          ave_x = (pr.salary_total + pr1.salary_total + pr2.salary_total)/3
          insurance_x = TaxUtils.get_basic_info(ym, prefecture_code, ave_x)
          if (grade_ave_bs - insurance_x.grade).abs >= 2
            standard_remuneration = insurance_x.monthly_standard
            grade_ave_bs = insurance_x.grade
            pre_bs = pr.salary_total
          end
        end
      end
    end

    standard_remuneration
  end

  # 健康保険料と所得税の取得
  def get_tax(ym, employee_id, base_salary, commuting_allowance, monthly_standard)
    payroll = Payroll.new
    
    e = Employee.find(employee_id)
    care_from = (e.birth + 40.years - 1.day).strftime("%Y%m").to_i   # 40歳の誕生日前日の月から対象
    care_to = (e.birth + 65.years - 1.day).strftime("%Y%m").to_i - 1 # 65歳の誕生日前日の月の前月までが対象

    payroll.ym = ym
    payroll.employee = e
    payroll.base_salary = base_salary.to_i
    payroll.commuting_allowance = commuting_allowance.to_i

    # 雇用保険
    payroll.calc_employment_insurance

    # 標準報酬月額の取得
    payroll.monthly_standard = monthly_standard.presence || get_standard_remuneration(ym, e, payroll.salary_total)

    # 社会保険料
    prefecture_code = e.business_office.prefecture_code # 事業所の都道府県コード
    insurance = TaxUtils.get_social_insurance(ym, prefecture_code, payroll.monthly_standard)

    # 事業主が、給与から被保険者負担分を控除する場合、被保険者負担分の端数が50銭以下の場合は切り捨て、50銭を超える場合は切り上げて1円となる
    # 折半額の端数は個人負担
    if ym.to_i >= care_from && ym.to_i <= care_to
      payroll.health_insurance = (insurance.health_insurance_half_care - 0.01).round
      payroll.insurance_all = insurance.health_insurance_all_care.truncate
    else
      payroll.health_insurance = (insurance.health_insurance_half - 0.01).round
      payroll.insurance_all = insurance.health_insurance_all.truncate
    end
    payroll.welfare_pension = (insurance.welfare_pension_insurance_half - 0.01).round
    payroll.pension_all = insurance.welfare_pension_insurance_all.truncate
    
    # 源泉徴収税
    payroll.calc_income_tax

    payroll
  end

  def get_pay_day(ym, employee_id = nil)
    company = Employee.find(employee_id).company
    company.get_actual_pay_day_for(ym)
  end

end
