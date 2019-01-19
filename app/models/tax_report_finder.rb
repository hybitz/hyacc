class TaxReportFinder
  include ActiveModel::Model
  include Pagination
  include CompanyAware
  include BranchAware

  attr_accessor :fiscal_year
  
  def list
    if conditions.first.present?
      Career.where(conditions).order('start_from').paginate(:page => page, :per_page => per_page)
    else
      Career.order('start_from').paginate(:page => page, :per_page => per_page)
    end
  end

  def report_types
    types = [
      REPORT_TYPE_CONSUMPTION_TAX_CACL
    ]
    
    ret = []
    types.each do |type|
      ret << [REPORT_TYPES[type], type]
    end
    ret
  end

  private

  def conditions
    sql = SqlBuilder.new
    sql.append('employee_id = ?', employee_id) if employee_id.present?
    sql.to_a
  end
end
