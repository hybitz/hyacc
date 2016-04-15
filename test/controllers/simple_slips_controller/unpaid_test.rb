require 'test_helper'

class SimpleSlipsController::UnpaidTest < ActionController::TestCase

  def setup
    sign_in users(:first)
  end

  def test_前月自動振替
    remarks = "前月の費用に自動振替" + Time.now.to_i.to_s

    post :create,
      :account_code => ACCOUNT_CODE_UNPAID_EMPLOYEE,
      :slip => {
        "ym"=>200801,
        "day"=>15,
        "remarks"=>remarks,
        "my_sub_account_id"=>1,
        "branch_id"=>2,
        "account_id"=>22, # 通信費
        "amount_increase" => 3600,
        :tax_type => TAX_TYPE_NONTAXABLE,
        "auto_journal_type"=>AUTO_JOURNAL_TYPE_ACCRUED_EXPENSE
      }

    assert_response :redirect
    assert_redirected_to :action => 'index'

    # 登録した伝票のチェック
    jh = JournalHeader.find_by_remarks(remarks)
    assert_equal( 200801, jh.ym )
    assert_equal( 15, jh.day )
    assert_equal( SLIP_TYPE_SIMPLIFIED, jh.slip_type )
    assert_equal( remarks, jh.remarks )
    assert_equal( 3600, jh.amount )
    assert_equal( 0, jh.transfer_journals.size )
    assert_equal( 2, jh.journal_details.size )
    assert_equal( DC_TYPE_CREDIT, jh.journal_details[0].dc_type )
    assert_equal( 3600, jh.journal_details[0].amount )
    assert_equal( 2, jh.journal_details[0].branch_id )
    assert_equal( 13, jh.journal_details[0].account_id )
    assert_equal( 1, jh.journal_details[0].sub_account_id )
    assert_equal( 3600, jh.journal_details[1].amount )
    assert_equal( DC_TYPE_DEBIT, jh.journal_details[1].dc_type )
    assert_equal( 2, jh.journal_details[1].branch_id )
    assert_equal( 22, jh.journal_details[1].account_id )
    assert_equal( nil, jh.journal_details[1].sub_account_id )

    # 自動振替伝票のチェック（前月の伝票）
    auto1 = jh.journal_details[1].transfer_journals.first
    assert_not_nil( auto1 )
    assert_equal( 200712, auto1.ym )
    assert_equal( 31, auto1.day )
    assert_equal( SLIP_TYPE_AUTO_TRANSFER_ACCRUED_EXPENSE, auto1.slip_type )
    assert_equal( remarks + "【自動】", auto1.remarks )
    assert_equal( 3600, auto1.amount )
    assert_nil( auto1.transfer_from_id )
    assert_equal( jh.journal_details[1].id, auto1.transfer_from_detail_id )
    assert_equal( 2, auto1.journal_details.length )
    assert_equal( DC_TYPE_DEBIT, auto1.journal_details[0].dc_type )
    assert_equal( 3600, auto1.journal_details[0].amount )
    assert_equal( 2, auto1.journal_details[0].branch_id )
    assert_equal( 22, auto1.journal_details[0].account_id )
    assert_nil( auto1.journal_details[0].sub_account_id )
    assert_equal( DC_TYPE_CREDIT, auto1.journal_details[1].dc_type )
    assert_equal( 3600, auto1.journal_details[1].amount )
    assert_equal( 2, auto1.journal_details[1].branch_id )
    assert_equal( Account.find_by_code(ACCOUNT_CODE_ACCRUED_EXPENSE).id, auto1.journal_details[1].account_id )
    assert_nil( auto1.journal_details[1].sub_account_id )

    # 自動振替伝票のチェック（今月の伝票）
    auto2 = auto1.transfer_journals.first
    assert_equal( 200801, auto2.ym )
    assert_equal( 1, auto2.day )
    assert_equal( SLIP_TYPE_AUTO_TRANSFER_ACCRUED_EXPENSE, auto2.slip_type )
    assert_equal( remarks + "【自動】【逆】", auto2.remarks )
    assert_equal( 3600, auto2.amount )
    assert_equal( auto1.id, auto2.transfer_from_id )
    assert_nil( auto2.transfer_from_detail_id )
    assert_equal( 2, auto2.journal_details.size )
    assert_equal( DC_TYPE_CREDIT, auto2.journal_details[0].dc_type )
    assert_equal( 3600, auto2.journal_details[0].amount )
    assert_equal( 2, auto2.journal_details[0].branch_id )
    assert_equal( 22, auto2.journal_details[0].account_id )
    assert_nil( auto2.journal_details[0].sub_account_id )
    assert_equal( DC_TYPE_DEBIT, auto2.journal_details[1].dc_type )
    assert_equal( 3600, auto2.journal_details[1].amount )
    assert_equal( 2, auto2.journal_details[1].branch_id )
    assert_equal( Account.find_by_code(ACCOUNT_CODE_ACCRUED_EXPENSE).id, auto2.journal_details[1].account_id )
    assert_nil( jh.journal_details[1].sub_account_id )
  end

  def test_翌月自動振替
    remarks = "翌月の費用に自動振替" + Time.now.to_i.to_s

    post :create,
      :account_code=>ACCOUNT_CODE_UNPAID_EMPLOYEE,
      :slip => {
        "ym"=>200801,
        "day"=>7,
        "remarks"=>remarks,
        "my_sub_account_id"=>2,
        "branch_id" => 2,
        "account_id" => 21, # 旅費交通費
        "amount_increase" => 15000,
        :tax_type => TAX_TYPE_NONTAXABLE,
        "auto_journal_type"=>AUTO_JOURNAL_TYPE_PREPAID_EXPENSE
      }

    assert_response :redirect
    assert_redirected_to :action=>:index

    # 登録した伝票のチェック
    assert jh = JournalHeader.where(:remarks => remarks).first
    assert_equal( 200801, jh.ym )
    assert_equal( 7, jh.day )
    assert_equal( SLIP_TYPE_SIMPLIFIED, jh.slip_type )
    assert_equal( remarks, jh.remarks )
    assert_equal( 15000, jh.amount )
    assert_nil( jh.transfer_journals.first )
    assert_equal( 2, jh.journal_details.length )
    assert_equal( DC_TYPE_CREDIT, jh.journal_details[0].dc_type )
    assert_equal( 15000, jh.journal_details[0].amount )
    assert_equal( 2, jh.journal_details[0].branch_id )
    assert_equal( 13, jh.journal_details[0].account_id )
    assert_equal( 2, jh.journal_details[0].sub_account_id )
    assert_equal( 15000, jh.journal_details[1].amount )
    assert_equal( DC_TYPE_DEBIT, jh.journal_details[1].dc_type )
    assert_equal( 2, jh.journal_details[1].branch_id )
    assert_equal( 21, jh.journal_details[1].account_id )
    assert_equal( nil, jh.journal_details[1].sub_account_id )

    # 自動振替伝票のチェック（今月の伝票）
    jh = jh.journal_details[1].transfer_journals.first
    assert_not_nil( jh )
    assert_equal( 200801, jh.ym )
    assert_equal( 31, jh.day )
    assert_equal( SLIP_TYPE_AUTO_TRANSFER_PREPAID_EXPENSE, jh.slip_type )
    assert_equal( remarks + "【自動】", jh.remarks )
    assert_equal( 15000, jh.amount )
    assert_not_nil( jh.transfer_journals.first )
    assert_equal( 2, jh.journal_details.length )
    assert_equal( DC_TYPE_CREDIT, jh.journal_details[0].dc_type )
    assert_equal( 15000, jh.journal_details[0].amount )
    assert_equal( 2, jh.journal_details[0].branch_id )
    assert_equal( 21, jh.journal_details[0].account_id )
    assert_equal( nil, jh.journal_details[0].sub_account_id )
    assert_equal( DC_TYPE_DEBIT, jh.journal_details[1].dc_type )
    assert_equal( 15000, jh.journal_details[1].amount )
    assert_equal( 2, jh.journal_details[1].branch_id )
    assert_equal( Account.find_by_code(ACCOUNT_CODE_PREPAID_EXPENSE).id, jh.journal_details[1].account_id )
    assert_equal( nil, jh.journal_details[1].sub_account_id )

    # 自動振替伝票のチェック（翌月の伝票）
    jh = jh.transfer_journals.first
    assert_equal( 200802, jh.ym )
    assert_equal( 1, jh.day )
    assert_equal( SLIP_TYPE_AUTO_TRANSFER_PREPAID_EXPENSE, jh.slip_type )
    assert_equal( remarks + "【自動】【逆】", jh.remarks )
    assert_equal( 15000, jh.amount )
    assert_nil( jh.transfer_journals.first )
    assert_equal( 2, jh.journal_details.length )
    assert_equal( DC_TYPE_DEBIT, jh.journal_details[0].dc_type )
    assert_equal( 15000, jh.journal_details[0].amount )
    assert_equal( 2, jh.journal_details[0].branch_id )
    assert_equal( 21, jh.journal_details[0].account_id )
    assert_equal( nil, jh.journal_details[0].sub_account_id )
    assert_equal( DC_TYPE_CREDIT, jh.journal_details[1].dc_type )
    assert_equal( 15000, jh.journal_details[1].amount )
    assert_equal( 2, jh.journal_details[1].branch_id )
    assert_equal( Account.find_by_code(ACCOUNT_CODE_PREPAID_EXPENSE).id, jh.journal_details[1].account_id )
    assert_equal( nil, jh.journal_details[1].sub_account_id )
  end

  def test_一覧
    get :index,
      :account_code => ACCOUNT_CODE_UNPAID_EMPLOYEE,
      :finder=> {
        "ym" => "",
        "remarks" => "",
        "sub_account_id" => 1,
        "branch_id" => 2
      }
    assert_response :success
    assert_template :index
  end
end
