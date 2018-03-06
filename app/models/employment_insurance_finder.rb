class EmploymentInsuranceFinder
  include ActiveModel::Model

  def list
    TaxUtils.get_employment_insurances
  end

end
