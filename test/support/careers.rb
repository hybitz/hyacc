module Careers
  def career
    @_career ||= Career.first
  end
  
  def valid_career_params(attrs = {})
    {
      :employee_id => attrs[:employee_id] || User.not_deleted.first.id,
      :start_from => Date.today - 4.months,
      :end_to => Date.today - 1.month,
      :customer_id => Customer.not_deleted.first.id,
      :project_name => 'テストプロジェクト' + SecureRandom.uuid
    }
  end
  
  def invalid_career_params(attrs = {})
    {
      :employee_id => attrs[:employee_id] || User.not_deleted.first.id,
      :start_from => Date.today - 4.months,
      :end_to => Date.today - 1.month,
      :customer_id => Customer.not_deleted.first.id,
      :project_name => ''
    }
  end
end