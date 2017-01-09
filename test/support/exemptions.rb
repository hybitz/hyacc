module Exemptions
  def exemption
    @_exemption ||= Exemption.first
  end
  
  def valid_exemption_params(attrs = {})
    {
      :employee_id => attrs[:employee_id] || Employee.not_deleted.first.id,
      :yyyy => Date.today.year,
      :small_scale_mutual_aid => '360000',
      :life_insurance_premium_old => '35000',
      :dependent_family_members_attributes => {"0" => {:exemption_type => '3',
                                                       :name => '山田二郎',
                                                          :kana => 'ヤマダジロウ',
                                                          :live_in => '1',
                                                          :_destroy => '0'}}
    }
  end
  
  def invalid_exemption_params(attrs = {})
    {
      :employee_id => attrs[:employee_id] || Employee.not_deleted.first.id,
      :yyyy => Date.today.year,
      :small_scale_mutual_aid => '360000',
      :life_insurance_premium_old => '35000',
      :dependent_family_members_attributes => {"0" => {:exemption_type => '3',
                                                       :name => '',
                                                          :kana => 'ヤマダジロウ',
                                                          :live_in => '1',
                                                          :_destroy => '0'}}
    }
  end
end