class SocialInsuranceFinder
  include ActiveModel::Model
  include CompanyAware
  include FiscalYearAware

  def list_payrolls_by_employee
    Payroll.where("ym >= ? and ym <= ?", ym_range.first, ym_range.last).eager_load(:employee).order('is_bonus, ym').group_by(&:employee)
  end

end
