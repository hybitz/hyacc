module SimpleSlipTemplates
  include HyaccConstants

  def simple_slip_template
    @_simple_slip_template ||= SimpleSlipTemplate.where(:owner_type => OWNER_TYPE_COMPANY, :owner_id => current_company.id).first
  end
  
  def simple_slip_template_params
    {
      owner_type: OWNER_TYPE_COMPANY,
      owner_id: current_company.id,
      remarks: '接待',
      keywords: 'せったい settai',
      account_id: social_expense_account.id,
      tax_rate_percent: 10
    }
  end
  
  def invalid_simple_slip_template_params
    {
      owner_type: OWNER_TYPE_COMPANY,
      owner_id: current_company.id,
      remarks: '',
      keywords: '',
      account_id: social_expense_account.id,
    }
  end
end