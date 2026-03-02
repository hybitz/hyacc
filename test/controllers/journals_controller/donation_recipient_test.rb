require 'test_helper'

class JournalsController::DonationRecipientTest < ActionController::TestCase
  DONATION_ACCOUNT_ID = 104
  DONATION_SUB_ACCOUNT_ID = 42

  def setup
    sign_in user
  end

  def test_get_account_detail_寄付金勘定で寄付先パーシャルが返る
    get :get_account_detail, xhr: true, params: { account_id: DONATION_ACCOUNT_ID, sub_account_id: DONATION_SUB_ACCOUNT_ID, index: 1 }
    assert_response :success
    assert_includes response.body, '寄付先'
    assert_includes response.body, 'donationRecipientSelect'
  end

  def test_登録_寄付金明細で寄付先を選択できる
    dr = donation_recipients(:one)

    assert_difference 'Journal.count', 1 do
      assert_difference 'JournalDetailDonationRecipient.count', 1 do
        post :create, xhr: true, params: {
          journal: {
            ym: '200803',
            day: '04',
            remarks: '寄付金明細で寄付先を選択して登録',
            journal_details_attributes: {
              '1' => {
                dc_type: 1,
                account_id: DONATION_ACCOUNT_ID,
                sub_account_id: DONATION_SUB_ACCOUNT_ID,
                branch_id: 2,
                input_amount: 1000,
                journal_detail_donation_recipient_attributes: { donation_recipient_id: dr.id }
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
    end

    assert_response :success
    assert_template 'common/reload'

    assert jh = Journal.find(assigns(:journal).id)
    donation_detail = jh.journal_details.find { |jd| jd.account_id == DONATION_ACCOUNT_ID }
    assert donation_detail
    assert donation_detail.journal_detail_donation_recipient
    assert_equal dr.id, donation_detail.journal_detail_donation_recipient.donation_recipient_id
  end

  def test_更新_寄付金明細で寄付先を変更できる
    jh = Journal.find(49)
    jd = jh.journal_details.find(49649)
    assert jd.account_id == DONATION_ACCOUNT_ID
    assert jd.journal_detail_donation_recipient.present?

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
    assert_equal dr.id, jd.journal_detail_donation_recipient.donation_recipient_id
  end

  def test_更新_寄付金明細で寄付先を外せる
    jh = Journal.find(49)
    jd = jh.journal_details.find(49649)
    assert jd.account_id == DONATION_ACCOUNT_ID
    assert jd.journal_detail_donation_recipient.present?

    assert_difference 'JournalDetailDonationRecipient.count', -1 do
      patch :update, xhr: true, params: {
        id: jh.id,
        journal: {
          ym: jh.ym,
          day: jh.day,
          remarks: jh.remarks,
          lock_version: jh.lock_version,
          journal_details_attributes: journal_details_attributes_for_update_with_destroy(jh, jd)
        }
      }
    end

    assert_response :success
    assert_template 'common/reload'
    assert_nil jd.reload.journal_detail_donation_recipient
  end

  def test_登録_寄付金明細で寄付先なしで登録できる
    assert_difference 'Journal.count', 1 do
      assert_no_difference 'JournalDetailDonationRecipient.count' do
        post :create, xhr: true, params: {
          journal: {
            ym: '200803',
            day: '05',
            remarks: '寄付金明細で寄付先未選択で登録',
            journal_details_attributes: {
              '1' => {
                dc_type: 1,
                account_id: DONATION_ACCOUNT_ID,
                sub_account_id: DONATION_SUB_ACCOUNT_ID,
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
    end

    assert_response :success
    assert_template 'common/reload'
    jh = Journal.find(assigns(:journal).id)
    donation_detail = jh.journal_details.find { |jd| jd.account_id == DONATION_ACCOUNT_ID }
    assert donation_detail
    assert_nil donation_detail.journal_detail_donation_recipient
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
      if detail.id == donation_detail.id
        jdr = detail.journal_detail_donation_recipient
        attrs[idx.to_s][:journal_detail_donation_recipient_attributes] = {
          id: jdr.id,
          donation_recipient_id: new_donation_recipient_id
        }
      end
    end
    attrs
  end

  def journal_details_attributes_for_update_with_destroy(jh, donation_detail)
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
      if detail.id == donation_detail.id
        jdr = detail.journal_detail_donation_recipient
        attrs[idx.to_s][:journal_detail_donation_recipient_attributes] = { id: jdr.id, _destroy: '1' }
      end
    end
    attrs
  end
end
