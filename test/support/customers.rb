module Customers
  def customer
    @_customer ||= Customer.not_deleted.first
  end
  
  def valid_customer_params(attrs = {})
    {
      code: attrs.fetch(:code, '1234567'),
      name: '取引先名',
      formal_name: '正式取引先名',
      enterprise_number: '12345678i90123',
      invoice_issuer_number: 'T12345678i90123',
      address: '東京都新宿区テスト1-3-5',
      address_effective_at: Date.today,
      disabled: false
    }
  end
  
  def invalid_customer_params(attrs = {})
    {
      code: '1234567',
      name: '',
      disabled: false,
    }
  end
end