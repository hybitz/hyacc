require 'test_helper'

# 振替伝票登録時に費用配賦の自動仕訳が正しく作成されているか
class JournalsController::CorporateTaxTest < ActionController::TestCase

  def setup
    sign_in users(:user2)
  end
  
  def test_create_allocated_tax_cost
    assert a = Account.find_by_code(ACCOUNT_CODE_CORPORATE_TAXES)
    assert sa = a.get_sub_account_by_code(CORPORATE_TAX_TYPE_MUNICIPAL_INHABITANTS_TAX)

    post_jh = Journal.new
    post_jh.remarks = SecureRandom.uuid
    post_jh.ym = 200911
    post_jh.day = 25
    post_jh.journal_details << JournalDetail.new
    post_jh.journal_details[0].branch_id = 1
    post_jh.journal_details[0].account_id = a.id
    post_jh.journal_details[0].sub_account_id = sa.id
    post_jh.journal_details[0].settlement_type = SETTLEMENT_TYPE_FULL
    post_jh.journal_details[0].input_amount = 100000
    post_jh.journal_details[0].tax_type = 1
    post_jh.journal_details[0].allocation_type = ALLOCATION_TYPE_EVEN_BY_CHILDREN
    post_jh.journal_details[0].dc_type = DC_TYPE_DEBIT # 借方
    post_jh.journal_details[0].detail_no = 1
    post_jh.journal_details << JournalDetail.new
    post_jh.journal_details[1].branch_id = 1
    post_jh.journal_details[1].account_id = 2 # 現金
    post_jh.journal_details[1].input_amount = 100000
    post_jh.journal_details[1].tax_type = 1
    post_jh.journal_details[1].allocation_type = ALLOCATION_TYPE_EVEN_BY_CHILDREN
    post_jh.journal_details[1].dc_type = DC_TYPE_CREDIT # 貸方
    post_jh.journal_details[1].detail_no = 2

    assert_difference 'Journal.count', 7 do
      post :create, xhr: true, params: {
        :journal => {
          :ym => post_jh.ym,
          :day => post_jh.day,
          :remarks => post_jh.remarks,
          :journal_details_attributes => {
            '1' => {
              :branch_id => post_jh.journal_details[0].branch_id,
              :account_id => post_jh.journal_details[0].account_id,
              :sub_account_id => post_jh.journal_details[0].sub_account_id,
              :settlement_type => post_jh.journal_details[0].settlement_type,
              :input_amount => post_jh.journal_details[0].input_amount,
              :tax_type => post_jh.journal_details[0].tax_type,
              :allocation_type => post_jh.journal_details[0].allocation_type,
              :dc_type => post_jh.journal_details[0].dc_type,
            },
            '2' => {
              :branch_id => post_jh.journal_details[1].branch_id,
              :account_id => post_jh.journal_details[1].account_id,
              :input_amount => post_jh.journal_details[1].input_amount,
              :tax_type => post_jh.journal_details[1].tax_type,
              :allocation_type => post_jh.journal_details[1].allocation_type,
              :dc_type => post_jh.journal_details[1].dc_type,
            }
          }
        }
      }

      assert_response :success
      assert_template 'common/reload'
    end
    
    # 仕訳内容の確認
    list = Journal.where(ym: post_jh.ym, day: post_jh.day)
    
    assert_equal 7, list.length, "自動仕訳が6つ作成されるので合計7仕訳"
    jh = list[0]
    assert_equal post_jh.remarks, jh.remarks
    assert_equal post_jh.journal_details[0].input_amount, jh.amount
    assert_equal 2, jh.journal_details.length, "２明細作成"
    assert_equal 1, jh.journal_details[0].transfer_journals.length
    
    # 自動仕訳（配賦）
    auto1 = jh.journal_details[0].transfer_journals[0]
    assert_equal jh.journal_details[0].id, auto1.transfer_from_detail_id
    assert_equal 4, auto1.journal_details.length, "２部門で４明細"
    assert_equal SLIP_TYPE_AUTO_TRANSFER_ALLOCATED_COST, auto1.slip_type
    assert_not_nil auto1.journal_details.find_by_account_id(86), "法人税配賦の明細がある"
    assert_not_nil auto1.journal_details.find_by_account_id(87), "法人税負担の明細がある"
    
    jd = auto1.journal_details[0]
    assert_nil jd.settlement_type
    
    jd = auto1.journal_details[1]
    assert_nil jd.settlement_type
  end  
end
