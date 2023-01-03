class EmployeeFinder
  include ActiveModel::Model
  include Pagination
  include CompanyAware

  def list
    Employee.where(company_id: company_id).paginate(page: page, per_page: per_page)
  end
end
