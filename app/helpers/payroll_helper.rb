module PayrollHelper
  require 'hyacc_master/service_factory'
  include HyaccConstants
  
  # 標準報酬月額の計算
  def get_standard_remuneration(ym = nil, employee_id = nil, base_salary = nil)
    standard_remuneration = 0
    if ym != nil and base_salary != nil and employee_id != nil
      begin
        ym = ym.to_i
        # 1,2,3か月前の給与
        ym_1 = (Date.new(ym/100, ym%100, 1) << 1).strftime("%Y%m")
        ym_2 = (Date.new(ym/100, ym%100, 1) << 2).strftime("%Y%m")
        ym_3 = (Date.new(ym/100, ym%100, 1) << 3).strftime("%Y%m")
        pr_1 = Payroll.find_by_ym_and_employee_id(ym_1, employee_id)
        pr_2 = Payroll.find_by_ym_and_employee_id(ym_2, employee_id)
        pr_3 = Payroll.find_by_ym_and_employee_id(ym_3, employee_id)
        if pr_3.payroll_journal_headers.nil?
          unless pr_2.payroll_journal_headers.nil?
            return get_remuneration(ym_2, pr_2.base_salary)
          end
          unless pr_1.payroll_journal_headers.nil?
            return get_remuneration(ym_1, pr_1.base_salary)
          end
          return get_basic_info(ym, base_salary).monthly_earnings
        end
        # 7月より前は前年の4月を基準とする
        x = (ym.to_s).slice(0, 4) + "04"
        if ym.to_s.slice(4, 2).to_i < 7
          y = ((ym.to_s).slice(0, 4)).to_i - 1
          x = y.to_s + "04"
        end
        pr = Payroll.find_by_ym_and_employee_id(x, employee_id)
        while pr.payroll_journal_headers.nil?
          x = (Date.new(x/100, x%100, 1) >> 1).strftime("%Y%m")
          pr = Payroll.find_by_ym_and_employee_id(x, employee_id)
        end
        # 基準となる標準報酬月額
        x1 = (Date.new(x.to_i/100, x.to_i%100, 1) >> 1).strftime("%Y%m")
        x2 = (Date.new(x.to_i/100, x.to_i%100, 1) >> 2).strftime("%Y%m")
        pr1 = Payroll.find_by_ym_and_employee_id(x1, employee_id)
        pr2 = Payroll.find_by_ym_and_employee_id(x2, employee_id)
        ave_bs = (pr.base_salary + pr1.base_salary + pr2.base_salary)/3
        insurance_ave_bs = get_basic_info(ym, ave_bs)
        grade_ave_bs = insurance_ave_bs.grade
        pre_bs = pr.base_salary
        standard_remuneration = insurance_ave_bs.monthly_earnings
        while ((Date.new(x.to_i/100, x.to_i%100, 1) >> 2).strftime("%Y%m")).to_i < ym.to_i
          x = (Date.new(x.to_i/100, x.to_i%100, 1) >> 1).strftime("%Y%m")
          pr = Payroll.find_by_ym_and_employee_id(x, employee_id)
          if pre_bs != pr.base_salary
            if ((Date.new(x.to_i/100, x.to_i%100, 1) >> 2).strftime("%Y%m")).to_i < ym.to_i
              x1 = (Date.new(x.to_i/100, x.to_i%100, 1) >> 1).strftime("%Y%m")
              x2 = (Date.new(x.to_i/100, x.to_i%100, 1) >> 2).strftime("%Y%m")
              pr1 = Payroll.find_by_ym_and_employee_id(x1, employee_id)
              pr2 = Payroll.find_by_ym_and_employee_id(x2, employee_id)
              ave_x = (pr.base_salary + pr1.base_salary + pr2.base_salary)/3
              insurance_x = get_basic_info(ym, ave_x)
              if (grade_ave_bs - insurance_x.grade).abs >= 2
                standard_remuneration = insurance_x.monthly_earnings
                grade_ave_bs = insurance_x.grade
                pre_bs = pr.base_salary
              end
            end
          end
        end
      rescue Exception => e
        flash[:notice] = e.message
      end
    end
    return standard_remuneration
  end
  
  # 健康保険料と所得税の取得
  def get_tax(ym = nil, employee_id = nil, base_salary = 0)
    payroll = Payroll.new.init
    if ym != nil && employee_id != nil
      # 従業員IDから事業所の都道府県IDを取得
      e = Employee.find(employee_id)
      prefecture_id = e.business_office.prefecture_id
      payroll.base_salary = base_salary.to_i
      # 標準報酬月額の取得
      standard_remuneration = get_standard_remuneration(ym, employee_id, base_salary)
      insurance = get_insurance(ym, prefecture_id, standard_remuneration)
      pension = get_pension(ym, standard_remuneration)
      
      # 保険料の設定
      # 事業主が、給与から被保険者負担分を控除する場合、被保険者負担分の端数が50銭以下の場合は切り捨て、50銭を超える場合は切り上げて1円となる
      payroll.insurance =  (insurance.health_insurance_half - 0.01).round
      payroll.insurance_all = insurance.health_insurance_all.truncate
      payroll.pension_all = pension.welfare_pension_insurance_all.truncate
      # 端数対応（折半額の端数は個人負担）
      payroll.pension = (pension.welfare_pension_insurance_half - 0.01).round
      
      withheld_tax = WithheldTax.find_by_ym_and_pay(ym, payroll.after_insurance_deduction)
      # 従業員マスタより取得する TODO
      # 対象月の末日を取得
      day = Date.new(ym.to_i/100, ym.to_i%100,-1)
      e = Employee.find(employee_id)
      income_tax = 0
      case e.num_of_dependent(day)
      when 0
        income_tax = withheld_tax.no_dependent
      when 1
        income_tax = withheld_tax.one_dependent
      when 2
        income_tax = withheld_tax.two_dependent
      when 3
        income_tax = withheld_tax.three_dependent
      when 4
        income_tax = withheld_tax.four_dependent
      when 5
        income_tax = withheld_tax.five_dependent
      when 6
        income_tax = withheld_tax.six_dependent
      when 7
        income_tax = withheld_tax.seven_dependent
      else
        # TODO 7人以上は1人を超えるごとに¥1,580＋
      end
      payroll.income_tax = income_tax
    end
    
    return payroll
  end

  def get_pension(ym = nil, base_salary = 0)
    service = HyaccMaster::ServiceFactory.create_service(Rails.env)
    service.get_pension(ym, base_salary)
  end
  
  def get_insurance(ym = nil, prefecture_id = nil, base_salary = 0)
    service = HyaccMaster::ServiceFactory.create_service(Rails.env)
    service.get_insurance(ym, prefecture_id, base_salary)
  end
  
  #標準報酬額を取得
  def get_remuneration(ym = nil, base_salary = 0)
    remuneration = 0
    #基本給から標準報酬額を取得
    insurance = get_basic_info(ym, base_salary)
    unless insurance.nil?
      remuneration = insurance.monthly_earnings
    end
    return remuneration
  end
  
  #標準報酬の基本情報を取得
  def get_basic_info(ym = nil, base_salary = 0)
    service = HyaccMaster::ServiceFactory.create_service(Rails.env)
    service.get_basic_info(ym, base_salary)
  end
  
end
