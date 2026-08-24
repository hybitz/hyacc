class InhabitantTaxFinder
  include ActiveModel::Model
  include Pagination
  include EmployeeAware

  attr_accessor :year

  def year
    unless @year.present?
      today = Date.today
      yyyy = today.year
      yyyymm = today.strftime("%Y%m").to_i
      @year = yyyy + yyyymm/(yyyy.to_s + '06').to_i - 1
    end

    @year.to_i
  end

  def list
    scope = InhabitantTax.includes(:employee).where(ym: InhabitantTax.ym_range(year))
    scope = scope.where(employee_id: employee_id) if employee_id.present?
    scope = scope.order(:employee_id, :ym)
    return scope if employee_id.present?

    scope.paginate(page: page, per_page: per_page)
  end

end
