require 'test_helper'

class JournalsController::DonationRecipientTest < ActionController::TestCase
  def donation_account
    @donation_account ||= Account.find_by(code: ACCOUNT_CODE_DONATION)
  end

  def setup
    sign_in user
  end

  def test_get_sub_account_detail_寄付金勘定で寄付先パーシャルが返る
    get :get_sub_account_detail, xhr: true, params: { account_id: donation_account.id, sub_account_id: donation_account.sub_accounts.first.id, index: 1 }
    assert_response :success
    assert_includes response.body, '寄付先'
    assert_includes response.body, 'donationRecipientSelect'
  end

  def test_get_sub_account_detail_寄付金勘定でsub_account_idなしでも寄付先パーシャルが返る
    get :get_sub_account_detail, xhr: true, params: { account_id: donation_account.id, index: 1 }
    assert_response :success
    assert_includes response.body, '寄付先'
    assert_includes response.body, 'donationRecipientSelect'
  end

  def test_get_sub_account_detail_寄付金勘定で補助科目がその他のときは寄付先フォームを出さない
    others = SubAccount.find_by(code: SUB_ACCOUNT_CODE_DONATION_OTHERS, account_id: donation_account.id)
    get :get_sub_account_detail, xhr: true, params: { account_id: donation_account.id, sub_account_id: others.id, index: 1 }
    assert_response :success
    assert_not_includes response.body, 'donationRecipientSelect'
  end

  def test_get_sub_account_detail_寄付金以外の勘定ではno_contentを返す
    account_id = Account.find_by(code: ACCOUNT_CODE_SOCIAL_EXPENSE).id
    get :get_sub_account_detail, xhr: true, params: { account_id: account_id, index: 1 }
    assert_response :no_content
  end

  def test_編集画面で寄付先パーシャルに紐づけ済みの寄付先名が表示される
    jd = JournalDetail.where(account_id: donation_account.id).where.not(donation_recipient_id: nil).first
    jh = jd.journal
    dr = jd.donation_recipient

    get :edit, xhr: true, params: { id: jh.id }
    assert_response :success
    assert_includes response.body, '寄付先'
    assert_includes response.body, dr.name
  end

  def test_編集画面で未紐付の寄付先パーシャルと寄付先フォームが表示される
    sub_account_ids = SubAccount.where(account_id: donation_account.id, code: DONATION_RECIPIENT_SUB_ACCOUNT_CODES).select(:id)
    jd = JournalDetail.where(account_id: donation_account.id, donation_recipient_id: nil, sub_account_id: sub_account_ids).first
    jh = jd.journal

    get :edit, xhr: true, params: { id: jh.id }
    assert_response :success
    assert_includes response.body, '寄付先'
    assert_includes response.body, 'donationRecipientSelect'
  end

  def test_参照画面で未紐付の寄付先パーシャルと寄付先フォームが表示されない
    sub_account_ids = SubAccount.where(account_id: donation_account.id, code: DONATION_RECIPIENT_SUB_ACCOUNT_CODES).select(:id)
    jd = JournalDetail.where(account_id: donation_account.id, donation_recipient_id: nil, sub_account_id: sub_account_ids).first
    jh = jd.journal

    get :show, xhr: true, params: { id: jh.id }
    assert_response :success
    assert_not_includes response.body, '寄付先'
    assert_not_includes response.body, 'donationRecipientSelect'
  end

  def test_参照画面で寄付先パーシャルに紐づけ済みの寄付先名が表示される
    jd = JournalDetail.where(account_id: donation_account.id).where.not(donation_recipient_id: nil).first
    jh = jd.journal
    dr = jd.donation_recipient

    get :show, xhr: true, params: { id: jh.id }
    assert_response :success
    assert_includes response.body, '寄付先'
    assert_includes response.body, dr.name
  end

  def test_登録_寄付金明細で寄付先を選択できる
    dr = donation_recipients(:one)

    assert_difference 'Journal.count', 1 do
      post :create, xhr: true, params: {
        journal: {
          ym: '200803',
          day: '04',
          remarks: '寄付金明細で寄付先を選択して登録',
          journal_details_attributes: {
            '1' => {
              dc_type: 1,
              account_id: donation_account.id,
              sub_account_id: donation_account.sub_accounts.first.id,
              branch_id: 2,
              input_amount: 1000,
              donation_recipient_id: dr.id
            },
            '2' => {
              dc_type: 2,
              account_id: 2,
              branch_id: 2,
              input_amount: 1000
            }
          }
        }
      }
    end

    assert_response :success
    assert_template 'common/reload'

    assert jh = Journal.find(assigns(:journal).id)
    donation_detail = jh.journal_details.find { |jd| jd.account_id == donation_account.id }
    assert donation_detail
    assert_equal dr.id, donation_detail.donation_recipient_id
  end

  def test_更新_寄付金明細で寄付先を変更できる
    jh = Journal.find(49)
    jd = jh.journal_details.find(49649)
    assert jd.account_id == donation_account.id
    assert jd.donation_recipient_id.present?

    dr = donation_recipients(:for_deletion)
    patch :update, xhr: true, params: {
      id: jh.id,
      journal: {
        ym: jh.ym,
        day: jh.day,
        remarks: jh.remarks,
        lock_version: jh.lock_version,
        journal_details_attributes: journal_details_attributes_for_update(jh, jd, dr.id)
      }
    }

    assert_response :success
    assert_template 'common/reload'

    jd.reload
    assert_equal dr.id, jd.donation_recipient_id
  end

  def test_更新_寄付金明細で寄付先を外せる
    jh = Journal.find(49)
    jd = jh.journal_details.find(49649)
    assert jd.account_id == donation_account.id
    assert jd.donation_recipient_id.present?

    patch :update, xhr: true, params: {
      id: jh.id,
      journal: {
        ym: jh.ym,
        day: jh.day,
        remarks: jh.remarks,
        lock_version: jh.lock_version,
        journal_details_attributes: journal_details_attributes_for_update_with_clear(jh, jd)
      }
    }

    assert_response :success
    assert_template 'common/reload'
    assert_nil jd.reload.donation_recipient_id
  end

  def test_登録_寄付金明細で寄付先なしで登録できる
    assert_difference 'Journal.count', 1 do
      post :create, xhr: true, params: {
        journal: {
          ym: '200803',
          day: '05',
          remarks: '寄付金明細で寄付先未選択で登録',
          journal_details_attributes: {
            '1' => {
              dc_type: 1,
              account_id: donation_account.id,
              sub_account_id: donation_account.sub_accounts.first.id,
              branch_id: 2,
              input_amount: 2000
            },
            '2' => {
              dc_type: 2,
              account_id: 2,
              branch_id: 2,
              input_amount: 2000
            }
          }
        }
      }
    end

    assert_response :success
    assert_template 'common/reload'
    jh = Journal.find(assigns(:journal).id)
    donation_detail = jh.journal_details.find { |jd| jd.account_id == donation_account.id }
    assert donation_detail
    assert_nil donation_detail.donation_recipient_id
  end

  private

  def journal_details_attributes_for_update(jh, donation_detail, new_donation_recipient_id)
    attrs = {}
    jh.journal_details.order(:detail_no).each_with_index do |detail, idx|
      attrs[idx.to_s] = {
        id: detail.id,
        dc_type: detail.dc_type,
        account_id: detail.account_id,
        branch_id: detail.branch_id,
        input_amount: detail.amount,
        tax_type: detail.tax_type || 1
      }
      attrs[idx.to_s][:sub_account_id] = detail.sub_account_id if detail.sub_account_id.present?
      attrs[idx.to_s][:donation_recipient_id] = new_donation_recipient_id if detail.id == donation_detail.id
    end
    attrs
  end

  def journal_details_attributes_for_update_with_clear(jh, donation_detail)
    attrs = {}
    jh.journal_details.order(:detail_no).each_with_index do |detail, idx|
      attrs[idx.to_s] = {
        id: detail.id,
        dc_type: detail.dc_type,
        account_id: detail.account_id,
        branch_id: detail.branch_id,
        input_amount: detail.amount,
        tax_type: detail.tax_type || 1
      }
      attrs[idx.to_s][:sub_account_id] = detail.sub_account_id if detail.sub_account_id.present?
      attrs[idx.to_s][:donation_recipient_id] = nil if detail.id == donation_detail.id
    end
    attrs
  end
end
