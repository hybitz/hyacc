module Profiles
  include HyaccConst

  def profile_params
    {
      :email => "test@#{SecureRandom.uuid}.example.com",
      :slips_per_page => '20',
      :account_count_of_frequencies => '10',
      :show_details => true,
      :simple_slip_settings_attributes => {
        '0' => {
          :account_id => Account.where(:code => ACCOUNT_CODE_CASH).first.id,
          :shortcut_key => 'Ctrl+1'
        }
      }
    }
  end

end