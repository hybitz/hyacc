module AstToModel

  def to_user(ast_table)
    table = normalize_table(ast_table)
    
    ret = User.new
    ret.login_id = table[0][1]
    ret.password = table[1][1]
    ret.email = table[2][1]
    
    e = ret.build_employee
    e.last_name = table[3][1]
    e.first_name = table[4][1]
    e.sex = SEX_TYPES.invert[table[5][1]]
    e.birth = table[6][1]
    e.employment_date = table[7][1]
    
    ret
  end
end

World(AstToModel)
