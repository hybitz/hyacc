module Exemptions
  def exemption
    @_exemption ||= Exemption.first
  end
  
  def valid_exemption_params(attrs = {})
    {
      :employee_id => attrs[:employee_id] || Employee.not_deleted.first.id,
      :yyyy => Date.today.year
    }
  end
  
  def invalid_exemption_params(attrs = {})
    {
      :employee_id => attrs[:employee_id] || Employee.not_deleted.first.id
    }
  end
end