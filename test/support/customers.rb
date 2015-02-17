module Customers
  def customer
    @_customer ||= Customer.not_deleted.first
  end
  
  def valid_customer_params(attrs = {})
    {
      :code => '1234567',
      :disabled => false,
      :customer_names_attributes => {
        '0' => {
          :name => '取引先名' + time_string,
          :formal_name => '正式取引先名' + time_string,
          :start_date => Date.today
        }
      }
    }
  end
  
  def invalid_customer_params(attrs = {})
    {
      :code => '1234567',
      :disabled => false,
      :customer_names_attributes => {
        '0' => {
          :name => '',
        }
      }
    }
  end
end