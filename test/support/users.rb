module Users
  include HyaccConstants

  def user
    @_user ||= User.first
  end

  def freelancer
    unless @_freelancer
      sql = SqlBuilder.new
      sql.append('exists (')
      sql.append('  select 1 from companies c where c.id = users.company_id and c.type_of = ?', COMPANY_TYPE_PERSONAL)
      sql.append(')')
      assert @_freelancer = User.where(sql.to_a).first
      assert @_freelancer.company.personal?
      assert @_freelancer.company.business_type.present?
      assert @_freelancer.company.tax_simplified?
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