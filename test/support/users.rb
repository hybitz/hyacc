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
    assert @_freelancer.company.business_type.present?
    assert_equal CONSUMPTION_ENTRY_TYPE_SIMPLIFIED, @_freelancer.company.current_fiscal_year.consumption_entry_type
  end

  @_freelancer
end