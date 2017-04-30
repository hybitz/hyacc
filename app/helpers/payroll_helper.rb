module PayrollHelper

  # 標準報酬月額の計算
  def get_standard_remuneration(ym = nil, employee = nil, base_salary = nil)
    standard_remuneration = 0
    if ym != nil and base_salary != nil and employee != nil
      prefecture_code = employee.business_office.prefecture_code

      begin
        ym = ym.to_i
        # 1,2,3か月前の給与
        ym_1 = (Date.new(ym/100, ym%100, 1) << 1).strftime("%Y%m")
        ym_2 = (Date.new(ym/100, ym%100, 1) << 2).strftime("%Y%m")
        ym_3 = (Date.new(ym/100, ym%100, 1) << 3).strftime("%Y%m")
        pr_1 = Payroll.find_by_ym_and_employee_id(ym_1, employee.id)
        pr_2 = Payroll.find_by_ym_and_employee_id(ym_2, employee.id)
        pr_3 = Payroll.find_by_ym_and_employee_id(ym_3, employee.id)
        if pr_3.payroll_journal_header.nil?
          unless pr_2.payroll_journal_header.nil?
            return get_remuneration(ym_2, prefecture_code, pr_2.base_salary)
          end
          unless pr_1.payroll_journal_header.nil?
            return get_remuneration(ym_1, prefecture_code, pr_1.base_salary)
          end
          return get_basic_info(ym, prefecture_code, base_salary).monthly_earnings
        end
        # 7月より前は前年の4月を基準とする
        x = (ym.to_s).slice(0, 4) + "04"
        if ym.to_s.slice(4, 2).to_i < 7
          y = ((ym.to_s).slice(0, 4)).to_i - 1
          x = y.to_s + "04"
        end
        pr = Payroll.find_by_ym_and_employee_id(x, employee.id)
        while pr.payroll_journal_header.nil?
          x = (Date.new(x.to_i/100, x.to_i%100, 1) >> 1).strftime("%Y%m")
          pr = Payroll.find_by_ym_and_employee_id(x, employee.id)
        end
        # 基準となる標準報酬月額
        x1 = (Date.new(x.to_i/100, x.to_i%100, 1) >> 1).strftime("%Y%m")
        x2 = (Date.new(x.to_i/100, x.to_i%100, 1) >> 2).strftime("%Y%m")
        pr1 = Payroll.find_by_ym_and_employee_id(x1, employee.id)
        pr2 = Payroll.find_by_ym_and_employee_id(x2, employee.id)
        ave_bs = (pr.base_salary + pr1.base_salary + pr2.base_salary)/3
        insurance_ave_bs = get_basic_info(ym, prefecture_code, ave_bs)
        grade_ave_bs = insurance_ave_bs.grade
        pre_bs = pr.base_salary
        standard_remuneration = insurance_ave_bs.monthly_earnings
        while ((Date.new(x.to_i/100, x.to_i%100, 1) >> 2).strftime("%Y%m")).to_i < ym.to_i
          x = (Date.new(x.to_i/100, x.to_i%100, 1) >> 1).strftime("%Y%m")
          pr = Payroll.find_by_ym_and_employee_id(x, employee.id)
          if pre_bs != pr.base_salary
            if ((Date.new(x.to_i/100, x.to_i%100, 1) >> 2).strftime("%Y%m")).to_i < ym.to_i
              x1 = (Date.new(x.to_i/100, x.to_i%100, 1) >> 1).strftime("%Y%m")
              x2 = (Date.new(x.to_i/100, x.to_i%100, 1) >> 2).strftime("%Y%m")
              pr1 = Payroll.find_by_ym_and_employee_id(x1, employee.id)
              pr2 = Payroll.find_by_ym_and_employee_id(x2, employee.id)
              ave_x = (pr.base_salary + pr1.base_salary + pr2.base_salary)/3
              insurance_x = get_basic_info(ym, prefecture_code, ave_x)
              if (grade_ave_bs - insurance_x.grade).abs >= 2
                standard_remuneration = insurance_x.monthly_earnings
                grade_ave_bs = insurance_x.grade
                pre_bs = pr.base_salary
              end
            end
          end
        end
      rescue => e
        Rails.logger.warn e.message
        Rails.logger.warn e.backtrace.join("\n")
        flash[:notice] = e.message
      end
    end

    standard_remuneration
  end

  # 健康保険料と所得税の取得
  def get_tax(ym, employee_id, base_salary)
    payroll = Payroll.new.init
    return payroll if ym.blank? || employee_id.blank?
    
    e = Employee.find(employee_id)
    care_from = (e.birth + 40.years - 1.day).strftime("%Y%m").to_i   # 40歳の誕生日前日の月から対象
    care_to = (e.birth + 65.years - 1.day).strftime("%Y%m").to_i - 1 # 65歳の誕生日前日の月の前月までが対象

    payroll.ym = ym
    payroll.employee = e
    payroll.base_salary = base_salary.to_i

    # 事業所の都道府県コードを取得
    prefecture_code = e.business_office.prefecture_code

    # 標準報酬月額の取得
    standard_remuneration = get_standard_remuneration(ym, e, base_salary)
    insurance = get_insurance(ym, prefecture_code, standard_remuneration)

    # 保険料の設定
    # 事業主が、給与から被保険者負担分を控除する場合、被保険者負担分の端数が50銭以下の場合は切り捨て、50銭を超える場合は切り上げて1円となる
    # 折半額の端数は個人負担
    if ym.to_i >= care_from && ym.to_i <= care_to
      payroll.insurance =  (insurance.health_insurance_half_care - 0.01).round
      payroll.insurance_all = insurance.health_insurance_all_care.truncate
    else
      payroll.insurance =  (insurance.health_insurance_half - 0.01).round
      payroll.insurance_all = insurance.health_insurance_all.truncate
    end
    payroll.pension = (insurance.welfare_pension_insurance_half - 0.01).round
    payroll.pension_all = insurance.welfare_pension_insurance_all.truncate
    
    # 対象月の末日の扶養家族の人数から源泉徴収税額を取得
    day = Date.new(ym.to_i/100, ym.to_i%100, -1)
    # 扶養親族の算出
    exemption = e.exemptions.order("yyyy desc").first
    num_of_dependent = exemption ? exemption.family_members.size : 0
    payroll.income_tax = WithheldTax.find_by_date_and_pay_and_dependent(day,
                                                                        payroll.after_insurance_deduction,
                                                                        num_of_dependent)

    payroll
  end

  def get_insurance(ym, prefecture_code, base_salary)
    service = HyaccMaster::ServiceFactory.create_service(Rails.env)
    service.get_insurance(ym, prefecture_code, base_salary)
  end

  #標準報酬額を取得
  def get_remuneration(ym, prefecture_code, base_salary)
    remuneration = 0
    #基本給から標準報酬額を取得
    insurance = get_basic_info(ym, prefecture_code, base_salary)
    unless insurance.nil?
      remuneration = insurance.monthly_earnings
    end
    return remuneration
  end

  #標準報酬の基本情報を取得
  def get_basic_info(ym, prefecture_code, base_salary)
    service = HyaccMaster::ServiceFactory.create_service(Rails.env)
    service.get_basic_info(ym, prefecture_code, base_salary)
  end

  def get_pay_day(ym, employee_id = nil)
    company = Employee.find(employee_id).company
    company.get_actual_pay_day_for(ym)
  end

end
