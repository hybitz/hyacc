require 'test_helper'

class SimpleSlipsController::CorporateTaxTest < ActionController::TestCase

  def test_登録
    sign_in user

    remarks = "法人税の決算区分が正しく登録されていること#{Time.new}"
    assert a = Account.find_by_code(ACCOUNT_CODE_CORPORATE_TAXES)
    assert sa = SubAccount.where(:sub_account_type => SUB_ACCOUNT_TYPE_CORPORATE_TAX, :code => '200').first

    post :create, :params => {
      :account_code => ACCOUNT_CODE_CASH,
      :simple_slip => {
        "ym"=>200911,
        "day"=>25,
        "remarks"=>remarks,
        "branch_id"=>1,
        "account_id"=>a.id,
        "sub_account_id" => sa.id,
        "amount_increase" => 0,
        "amount_decrease" => 25000,
        :tax_type => TAX_TYPE_NONTAXABLE,
        "settlement_type" => SETTLEMENT_TYPE_FULL
      }
    }

    assert_response :redirect
    assert_redirected_to :action => :index
    assert_equal '伝票を登録しました。', flash[:notice]

    assert jh = Journal.find_by_remarks(remarks)

    jd = jh.journal_details[0]
    assert_nil jd.settlement_type

    jd = jh.journal_details[1]
    assert_equal SETTLEMENT_TYPE_FULL, jd.settlement_type
  end

end
