module Houseworks
  def housework
    unless @_housework
      company = freelancer.employee.company
      assert @_housework = Housework.where(:company_id => company.id, :fiscal_year => company.current_fiscal_year.fiscal_year).first
    end
    @_housework
  end
end