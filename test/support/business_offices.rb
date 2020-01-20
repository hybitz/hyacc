module BusinessOffices
  def business_office_params
    {
      name: '事業所' + time_string,
      prefecture_code: '01',
      business_outline: '事業の内容'
    }
  end
  
  def invalid_business_office_params
    {
      name: '',
      prefecture_code: '02'
    }
  end
  
  def business_office
    @_business_office_cache ||= BusinessOffice.first
  end
end