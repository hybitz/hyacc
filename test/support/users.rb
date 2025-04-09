module Users
  include HyaccConst

  def admin
    @_admin ||= User.where(admin: true).first
  end

  def user
    @_user ||= User.where(admin: false).first
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
  
  def user_params
    login_id = time_string

    {
      :login_id => login_id,
      :email => "#{login_id}@test.example.com",
      :password => time_string
    }
  end
  
  def new_user(options = {})
    ret = User.new(user_params)
    ret
  end
  
  def create_user(options = {})
    ret = new_user
    assert ret.save, ret.errors.full_messages.join("\n")
    ret
  end

  def user_params_with_valid_branch_employees
    { user: {
        login_id: 'zero',
        password: 'zerozero',
        email: 'test@example.com',
        employee_attributes: {
        last_name: 'test_create', 
        first_name: 'a', 
        employment_date: '2009-01-01',
        sex: 'M',
        birth: '2000-01-01',
        my_number: '123456789012'
       }
      },
      employee: {
        branch_employees_attributes: {
          "0": {
            id: "",
            branch_id: "1",
            deleted: "0",
            default_branch: "0"
          }, 
          "1": {
            id: "",
            branch_id: "2",
            deleted: "0",
            default_branch: "1"
          }
        }
      }
    }
  end

  def user_params_with_invalid_branch_employees
    { user: {
        login_id: 'zero',
        password: 'zerozero',
        email: 'test@example.com',
        employee_attributes: {
        last_name: 'test_create', 
        first_name: 'a', 
        employment_date: '2009-01-01',
        sex: 'M',
        birth: '2000-01-01',
        my_number: '123456789012'
        }
      },
      employee: {
        branch_employees_attributes: {
          "0": {
            id: "",
            branch_id: "1",
            deleted: "0",
            default_branch: "0"
          }, 
          "1": {
            id: "",
            branch_id: "1",
            deleted: "0",
            default_branch: "1"
          }
        }
      }
    }
  end
end