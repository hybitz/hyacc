def user
  @_user ||= User.first
end

def freelancer
  sql = SqlBuilder.new
  sql.append('exists (')
  sql.append('  select 1 from companies c where c.id = users.company_id and c.type_of = ?', COMPANY_TYPE_PERSONAL)
  sql.append(')')
  @_freelancer ||= User.where(sql.to_a).first
end