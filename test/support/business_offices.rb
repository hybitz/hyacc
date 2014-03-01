# coding: UTF-8

def valid_business_office_params
  {
    :company_id => Company.first.id,
    :name => '事業所' + time_string,
    :prefecture_id => 1
  }
end

def invalid_business_office_params
  {
    :company_id => Company.first.id,
    :name => '',
    :prefecture_id => 1
  }
end

def business_office
  @_business_office_cache ||= BusinessOffice.first
end
