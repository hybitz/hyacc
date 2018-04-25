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
    sum = Payroll.new.init
    ym_range.each do |ym|
      ret[ym] = {:payroll => Payroll.find_by_ym_and_employee_id(ym, @employee_id)}
      # 年間合計の設定
      sum.income_tax += ret[ym][:payroll].income_tax
      sum.health_insurance += ret[ym][:payroll].health_insurance
      sum.welfare_pension += ret[ym][:payroll].welfare_pension
      sum.employment_insurance += ret[ym][:payroll].employment_insurance
      sum.base_salary += ret[ym][:payroll].base_salary
      sum.commuting_allowance += ret[ym][:payroll].commuting_allowance
      sum.inhabitant_tax += ret[ym][:payroll].inhabitant_tax
    end
    
    # 賞与を取得
    bonus_list = Payroll.list_bonus(ym_range, @employee_id)
    # 賞与1のセット
    if bonus_list[0].nil?
      ret['b1'] = {:payroll => Payroll.new.init}
    else
      ret['b1'] = {:payroll => Payroll.get_bonus_info(bonus_list[0].id)}
      # 年間合計の設定
      sum.income_tax += ret["b1"][:payroll].income_tax
      sum.health_insurance += ret["b1"][:payroll].health_insurance
      sum.welfare_pension += ret["b1"][:payroll].welfare_pension
      sum.employment_insurance += ret[ym][:payroll].employment_insurance
      sum.base_salary += ret["b1"][:payroll].base_salary
      sum.commuting_allowance += ret['b1'][:payroll].commuting_allowance
    end
    
    # 賞与2のセット
    if bonus_list[1].nil?
      ret['b2'] = {:payroll => Payroll.new.init}
    else
      ret['b2'] = {:payroll => Payroll.get_bonus_info(bonus_list[1].id)}
      # 年間合計の設定
      sum.income_tax += ret["b2"][:payroll].income_tax
      sum.health_insurance += ret["b2"][:payroll].health_insurance
      sum.welfare_pension += ret["b2"][:payroll].welfare_pension
      sum.employment_insurance += ret[ym][:payroll].employment_insurance
      sum.base_salary += ret["b2"][:payroll].base_salary
      sum.commuting_allowance += ret["b2"][:payroll].commuting_allowance
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
