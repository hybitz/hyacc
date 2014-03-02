# coding: UTF-8

def bank_account
  @_bank_account_cache ||= BankAccount.first
end

def valid_bank_account_params
  {
    :bank_id => bank.id,
    :code => '1234567',
    :name => '銀行口座' + time_string,
    :holder_name => '名義' + time_string,
    :financial_account_type => FINANCIAL_ACCOUNT_TYPE_SAVING
  }
end

def invalid_bank_account_params
  {
    :bank_id => bank.id,
    :code => '',
    :name => '',
    :holder_name => '',
    :financial_account_type => FINANCIAL_ACCOUNT_TYPE_SAVING
  }
end
