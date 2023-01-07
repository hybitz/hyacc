class EmployeeFinder
  include ActiveModel::Model
  include Pagination
  include CompanyAware

  attr_accessor :deleted

  def deleted_types
    DELETED_TYPES.invert
  end

  def list
    Employee.where(conditions).paginate(page: page, per_page: per_page)
  end

  private

  def conditions
    sql = SqlBuilder.new
    sql.append('company_id = ?', company_id)
    sql.append('and deleted = ?', BooleanUtils.to_b(deleted)) if deleted.present?
    sql.to_a
  end

end
