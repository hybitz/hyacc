module PayrollHelper

  # 標準報酬月額の計算
  def get_standard_remuneration(ym, employee, salary)
    ret = 0

    prefecture_code = employee.business_office.prefecture_code

    ym = ym.to_i
    # 1,2,3か月前の給与
    ym_1 = (Date.new(ym/100, ym%100, 1) << 1).strftime("%Y%m")
    ym_2 = (Date.new(ym/100, ym%100, 1) << 2).strftime("%Y%m")
    ym_3 = (Date.new(ym/100, ym%100, 1) << 3).strftime("%Y%m")
    pr_1 = Payroll.find_by_ym_and_employee_id(ym_1, employee.id)
    pr_2 = Payroll.find_by_ym_and_employee_id(ym_2, employee.id)
    pr_3 = Payroll.find_by_ym_and_employee_id(ym_3, employee.id)
    if pr_3.new_record?
      if pr_2.persisted?
        return pr_2.monthly_standard
      end
      if pr_1.persisted?
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
    while pr.new_record?
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
    ret = insurance_ave_bs.monthly_standard
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
            ret = insurance_x.monthly_standard
            grade_ave_bs = insurance_x.grade
            pre_bs = pr.salary_total
          end
        end
      end
    end

    ret
  end

  # 健康保険料と所得税の取得
  def get_tax(ym, employee_id, monthly_standard, salary, extra_pay, commuting_allowance, housing_allowance, qualification_allowance, options = {})
    payroll = Payroll.new
    
    e = Employee.find(employee_id)

    payroll.ym = ym
    payroll.employee = e
    payroll.is_bonus = options.fetch(:is_bonus, false)
    if payroll.is_bonus?
      payroll.temporary_salary = salary.to_i
    else
      payroll.base_salary = salary.to_i
      payroll.extra_pay = extra_pay.to_i
      payroll.commuting_allowance = commuting_allowance.to_i
      payroll.housing_allowance = housing_allowance.to_i
      payroll.qualification_allowance = qualification_allowance.to_i

      payroll.monthly_standard = monthly_standard.presence || get_standard_remuneration(ym, e, payroll.salary_total)
    end

    # 社会保険
    payroll.calc_social_insurance

    # 雇用保険
    payroll.calc_employment_insurance

    # 源泉徴収税
    payroll.calc_income_tax

    payroll
  end

  def get_pay_day(ym, employee_id)
    company = Employee.find(employee_id).company
    company.get_actual_pay_day_for(ym)
  end

end
