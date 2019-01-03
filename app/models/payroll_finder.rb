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
    ret = {}
    ym_range = get_ym_range

    payrolls = Hash[*Payroll.where('employee_id = ? and ym >= ? and ym <= ? and is_bonus = ?', @employee_id, ym_range.first, ym_range.last, false).map{|p| [p.ym, p] }.flatten]
    ym_range.each do |ym|
      ret[ym] = payrolls[ym] || Payroll.new(ym: ym, employee_id: @employee_id)
    end
    
    # 賞与を取得
    bonus_list = Payroll.list_bonus(ym_range, @employee_id)
    first_half, second_half = ym_range.each_slice(6).to_a
    bonus_list.each do |b|
      ret['b1'] = b if first_half.include?(b.ym)
      ret['b2'] = b if second_half.include?(b.ym)
    end
    ret['b1'] ||= Payroll.new
    ret['b2'] ||= Payroll.new
    
    # 年間合計の設定
    sum = Payroll.new
    ret.values.each do |p|
      sum.base_salary += p.base_salary
      sum.commuting_allowance += p.commuting_allowance
      sum.housing_allowance += p.housing_allowance
      sum.extra_pay += p.extra_pay
      sum.temporary_salary += p.temporary_salary
      sum.health_insurance += p.health_insurance
      sum.welfare_pension += p.welfare_pension
      sum.employment_insurance += p.employment_insurance
      sum.income_tax += p.income_tax
      sum.inhabitant_tax += p.inhabitant_tax
      sum.annual_adjustment += p.annual_adjustment
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
