module Profiles

  def valid_profile_params
    {
      :email => "test@#{time_string}.example.com",
      :slips_per_page => '20',
      :account_count_of_frequencies => '10',
      :show_details => true,
      :employee_attributes => {
        :id => user.id,
        :last_name => 'a',
        :first_name => 'a',
        :sex => 'M',
        :employment_date => '2015-12-19',
        :zip_code => '1112222',
        :address => 'テスト住所'
      }
    }
  end

end