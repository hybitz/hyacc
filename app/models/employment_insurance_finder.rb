class EmploymentInsuranceFinder
  include ActiveModel::Model
  include CompanyAware

  attr_accessor :calendar_year

  def list
    sql = SqlBuilder.new
    sql.append('ym >= ? and ym <= ?', year.to_s + '06', (year + 1).to_s + '05')
    InhabitantTax.where(sql.to_a).order('employee_id, ym')
  end

end
