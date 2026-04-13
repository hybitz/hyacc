require 'test_helper'

class SimpleSlipsController::DonationRecipientTest < ActionController::TestCase
  def donation_account
    @donation_account ||= Account.find_by(code: ACCOUNT_CODE_DONATION)
  end

  def setup
    sign_in user
  end

  def test_get_sub_account_details_寄付金勘定で寄付先パーシャルが返る
    get :get_sub_account_details,
        xhr: true,
        params: {
          account_code: donation_account.code,
          account_id: donation_account.id,
          sub_account_id: donation_account.sub_accounts.first.id
        }

    assert_response :success
    assert_includes response.body, '寄付先'
    assert_includes response.body, 'donationRecipientSelect'
  end

  def test_get_sub_account_details_寄付金以外の勘定ではno_contentを返す
    account_id = Account.find_by(code: ACCOUNT_CODE_SOCIAL_EXPENSE).id

    get :get_sub_account_details,
        xhr: true,
        params: {
          account_code: ACCOUNT_CODE_SOCIAL_EXPENSE,
          account_id: account_id
        }

    assert_response :no_content
  end

  def test_copy_簡易伝票で寄付先IDと補助科目詳細がjsonに含まれる
    get :copy, xhr: true, params: { id: 17136, account_code: ACCOUNT_CODE_RECEIVABLE }
    assert_response :success

    json = JSON.parse(response.body)
    assert_equal 1, json['donation_recipient_id']
    assert_includes json['sub_account_detail'], 'donationRecipientSelect'
  end

  def test_get_templates_寄付金テンプレートでも候補と補助科目詳細が返る
    donation_sub_account = donation_account.sub_accounts.first
    SimpleSlipTemplate.create!(
      remarks: '寄付金テスト',
      keywords: '寄付金',
      account_id: donation_account.id,
      sub_account_id: donation_sub_account.id,
      dc_type: 1,
      owner_type: 1,
      owner_id: user.id,
      deleted: false
    )

    get :get_templates,
        xhr: true,
        params: {
          account_code: ACCOUNT_CODE_RECEIVABLE,
          query: '寄付金'
        }

    assert_response :success
    json = JSON.parse(response.body)

    donation_template = json.find { |t| t['remarks'] == '寄付金テスト' }
    assert_not_nil donation_template
    assert_includes donation_template['sub_account_detail'], 'donationRecipientSelect'
  end

end

