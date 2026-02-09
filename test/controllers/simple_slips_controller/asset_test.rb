require 'test_helper'

class SimpleSlipsController::AssetTest < ActionController::TestCase

  # 償却待ち資産が存在する場合は削除不可
  def test_destroy_fail_by_depreciation_waiting
    sign_in user
    assert current_company.get_fiscal_year(200610).closed?
    jh = Journal.find(6300)
    assert_equal current_company.id, jh.company_id

    delete :destroy, :params => {:id => jh.id,
      :lock_version => 0,
      :account_code => ACCOUNT_CODE_CASH
    }

    assert_response :redirect
    assert_redirected_to action: :index
    assert_nil assigns(:slip)
    assert_not_nil Journal.find(6300)
  end

end
