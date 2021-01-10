class TaxReportFinder
  include ActiveModel::Model
  include Pagination
  include CompanyAware
  include BranchAware

  attr_accessor :report_type
  attr_accessor :fiscal_year
  
  def list
    if conditions.first.present?
      Career.where(conditions).order('start_from').paginate(:page => page, :per_page => per_page)
    else
      Career.order('start_from').paginate(:page => page, :per_page => per_page)
    end
  end

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
