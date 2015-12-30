require 'test_helper'

class SimpleSlipController::AssetTest < ActionController::TestCase

  def setup
    sign_in user
  end

  # 償却待ち資産が存在する場合は削除不可
  def test_destroy_fail_by_depreciation_waiting
    jh = JournalHeader.find(6300)
    
    assert users(:first).company.get_fiscal_year(200610).closed?
    
    post :destroy, :id => jh.id,
      :lock_version => 0,
      :account_code => ACCOUNT_CODE_CASH

    assert_response :redirect
    assert_redirected_to :action=>:index
    assert_nil assigns(:slip)
    assert_not_nil JournalHeader.find(6300)
  end
  
end
