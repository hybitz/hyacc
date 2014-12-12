module BusinessOffices
  def valid_business_office_params
    {
      :company_id => Company.first.id,
      :name => '事業所' + time_string,
      :prefecture_code => '01'
    }
  end
  
  def invalid_business_office_params
    {
      :company_id => Company.first.id,
      :name => '',
      :prefecture_code => '02'
    }
  end
  
  def business_office
    @_business_office_cache ||= BusinessOffice.first
  end
end