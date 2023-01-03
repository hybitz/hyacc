module Employees
  include HyaccConst

  def employee
    @_employee ||= Employee.where(executive: false).first
  end
  
  def executive
    @_executive ||= Employee.where(executive: true).first
  end

  def employee_params(options = {})
    {
      last_name: options[:last_name] || '山田',
      last_name_kana: options[:last_name_kana] || 'ヤマダ',
      first_name: '花子',
      first_name_kana: 'ハナコ',
      sex: SEX_TYPE_F,
      birth: 30.years.ago,
      employment_date: '1990-01-01',
      retirement_date: '9999-12-31',
      my_number: '123456789012',
      social_insurance_reference_number: '1',
      executive: false,
      zip_code: '0600042',
      zip_code_effective_at: Date.today - 3.years,
      address: '北海道札幌市',
      address_effective_at: Date.today - 3.years,
      position: '代表取締役'
    }
  end
  
  def invalid_employee_params
    employee_params.merge(last_name: '')
  end

  def new_employee(options = {})
    ret = Employee.new(employee_params(options))
    ret.company = options.fetch(:company, company)
    ret.user = options[:user]
    ret
  end
  
  def create_employee(options = {})
    options[:user] ||= create_user

    ret = new_employee(options)
    assert ret.save, ret.errors.full_messages.join("\n")
    ret
  end

end