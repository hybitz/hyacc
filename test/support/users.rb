module Users
  include HyaccConstants

  def admin
    @_admin ||= User.where(:admin => true).first
  end

  def user
    @_user ||= User.where(:admin => false).first
  end

  def freelancer
    unless @_freelancer
      sql = SqlBuilder.new
      sql.append('exists (')
      sql.append('  select 1 from employees e')
      sql.append('  inner join companies c on(c.id = e.company_id)')
      sql.append('  where e.user_id = users.id and c.type_of = ?', COMPANY_TYPE_PERSONAL)
      sql.append(')')
      assert @_freelancer = User.where(sql.to_a).first
      assert @_freelancer.employee.company.personal?
      assert @_freelancer.employee.company.business_type.present?
      assert @_freelancer.employee.company.tax_simplified?
    end
  
    @_freelancer
  end
  
  def valid_user_params
    {
      :login_id => time_string,
      :password => time_string
    }
  end
end