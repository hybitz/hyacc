class EmployeeFinder < Daddy::Model

  def list
    Employee.paginate(:page => page, :per_page => slips_per_page)
  end
end
