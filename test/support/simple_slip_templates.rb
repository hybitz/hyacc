def simple_slip_template
  @_simple_slip_template ||= SimpleSlipTemplate.where(:owner_type => OWNER_TYPE_COMPANY, :owner_id => current_user.company_id).first
end

def valid_simple_slip_template_params
  {
    :owner_type => OWNER_TYPE_COMPANY,
    :owner_id => current_user.company_id,
    :remarks => '接待',
    :keywords => 'せったい settai',
    :account_id => social_expense_account.id,
  }
end

def invalid_simple_slip_template_params
  {
    :owner_type => OWNER_TYPE_COMPANY,
    :owner_id => current_user.company_id,
    :remarks => '',
    :keywords => '',
    :account_id => social_expense_account.id,
  }
end
