class PayrollFinder < Base::Finder

  # 会計年度内の年月を12ヶ月分、yyyymmの配列として取得する。
  def get_ym_range
    start_year_month = HyaccDateUtil.get_start_year_month_of_fiscal_year( fiscal_year, start_month_of_fiscal_year )
    HyaccDateUtil.get_year_months( start_year_month, 12 )
  end

  # 月別給与の配列を取得する
  # 戻り値は、データ構造が12ヶ月分
  #  ym: 年月のyyyymm
  #  pay: 給与
  def list_monthly_pay
    ym_range = get_ym_range

    # データの受け皿の準備
    ret = {}
    ym_range.each do |ym|
      ret[ym] = Payroll.find_by_ym_and_employee_id(ym, @employee_id)
    end
    
    # 賞与を取得
    bonus_list = Payroll.list_bonus(ym_range, @employee_id)
    # 賞与1のセット
    if bonus_list[0].nil?
      ret['b1'] = Payroll.new
    else
      ret['b1'] = Payroll.get_bonus_info(bonus_list[0].id)
    end
    
    # 賞与2のセット
    if bonus_list[1].nil?
      ret['b2'] = Payroll.new
    else
      ret['b2'] = Payroll.get_bonus_info(bonus_list[1].id)
    end
    
    # 年間合計の設定
    sum = Payroll.new
    ret.values.each do |p|
      sum.income_tax += p.income_tax
      sum.health_insurance += p.health_insurance
      sum.welfare_pension += p.welfare_pension
      sum.employment_insurance += p.employment_insurance
      sum.base_salary += p.base_salary
      sum.commuting_allowance += p.commuting_allowance
      sum.inhabitant_tax += p.inhabitant_tax
      sum.accrued_liability += p.accrued_liability
    end
    ret[:sum] = sum

    ret
  end
  
  def get_net_sum(account_code)
    self.sub_account_id = self.employee_id
    self.branch_id = Employee.find(self.employee_id).default_branch.id
    JournalUtil.get_net_sum(company_id, account_code, branch_id, sub_account_id)
  end
  
end
