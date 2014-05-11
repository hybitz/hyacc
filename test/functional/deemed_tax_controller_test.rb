require 'test_helper'

class DeemedTaxControllerTest < ActionController::TestCase

  def test_一覧
    assert freelancer.company.business_type.present?
    assert_equal CONSUMPTION_ENTRY_TYPE_SIMPLIFIED, freelancer.company.current_fiscal_year.consumption_entry_type

    sign_in freelancer
    get :index
    
    assert_response :success
    assert_template :index
  end

end
