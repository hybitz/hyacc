class TaxReportFinder
  include ActiveModel::Model
  include Pagination
  include CompanyAware
  include FiscalYearAware
  include BranchAware

  attr_accessor :report_type
  
  def report_types
    CONSUMPTION_TAX_REPORT_TYPES.invert
  end

  private

  def conditions
    sql = SqlBuilder.new
    sql.append('employee_id = ?', employee_id) if employee_id.present?
    sql.to_a
  end
end
