require 'test_helper'

# 未払費用の計上日振替のテスト
class SimpleSlipController::AccruedExpenseTest < ActionController::TestCase

  setup do
    user = User.find(4)
    assert user.company.get_fiscal_year(2009).is_closed
    assert user.company.get_fiscal_year(2010).is_open

    sign_in user
  end

  def test_本締の年度への費用振替の登録がエラーになること
    
    post :create,
      :account_code=>ACCOUNT_CODE_CASH,
      :slip => {
        "ym"=>201001,
        "day"=>20,
        "remarks"=>"タクシー代",
        "branch_id"=>5,
        "account_id"=>21,
        "amount_increase"=>1500,
        :tax_type => TAX_TYPE_NONTAXABLE,
        "auto_journal_type"=>AUTO_JOURNAL_TYPE_ACCRUED_EXPENSE,
      }

    assert_response :success
    assert_template 'list'
    assert_not_nil assigns(:slip)
    assert_equal ERR_CLOSING_STATUS_CLOSED, flash[:notice]
  end

  def test_本締の年度からの費用振替の更新がエラーになること
    finder = Slips::SlipFinder.new(current_user)
    finder.account_code = Account.get(29).code
    slip = finder.find(12)
    
    xhr :post, :update,
      :account_code=>finder.account_code,
      :slip => {
        "id"=>slip.id,
        "ym"=>201002,
        "day"=>7,
        "remarks"=>slip.remarks,
        "branch_id"=>slip.branch_id,
        "account_id"=>slip.account_id,
        "sub_account_id"=>slip.sub_account_id,
        "amount_increase"=>slip.amount_increase,
        "amount_decrease"=>slip.amount_decrease,
        :tax_type => TAX_TYPE_NONTAXABLE,
        "lock_version"=>slip.lock_version,
        "auto_journal_type"=>AUTO_JOURNAL_TYPE_ACCRUED_EXPENSE,
      }

    assert_response :success
    assert_template 'edit'
    assert_not_nil assigns(:slip)
    assert_equal ERR_CLOSING_STATUS_CLOSED, flash[:notice]
  end
  
  def test_本締の年度への費用振替の更新がエラーになること
    finder = Slips::SlipFinder.new(current_user)
    finder.account_code = Account.get(29).code
    slip = finder.find(15)
    
    xhr :post, :update,
      :account_code => finder.account_code,
      :slip => {
        "id"=>slip.id,
        "ym"=>201001,
        "day"=>7,
        "remarks"=>"本締の年度への費用振替の更新がエラーになること",
        "branch_id"=>slip.branch_id,
        "account_id"=>slip.account_id,
        "sub_account_id"=>slip.sub_account_id,
        "amount_increase"=>slip.amount_increase,
        "amount_decrease"=>slip.amount_decrease,
        :tax_type => TAX_TYPE_NONTAXABLE,
        "lock_version"=>slip.lock_version,
        "auto_journal_type"=>AUTO_JOURNAL_TYPE_ACCRUED_EXPENSE,
      }

    assert_response :success
    assert_template 'edit'
    assert_not_nil assigns(:slip)
    assert_equal ERR_CLOSING_STATUS_CLOSED, flash[:notice]
  end

  def test_本締の年度の費用振替の削除がエラーになること
    jh = JournalHeader.find(12)

    assert_no_difference 'JournalHeader.count' do
      post :destroy, :account_code => ACCOUNT_CODE_CASH, :id => jh.id, :lock_version => jh.lock_version
    end

    assert_response :redirect
    assert_redirected_to :action => 'index'
    assert_equal ERR_CLOSING_STATUS_CLOSED, flash[:notice]
  end

  def test_通常の年度への費用振替の登録が正常終了すること
    remarks = "通常の年度への費用振替の登録が正常終了すること#{Time.new}"
    assert_nil JournalHeader.find_by_remarks(remarks)
    
    post :create,
      :account_code=>ACCOUNT_CODE_CASH,
      :slip => {
        "ym"=>201005,
        "day"=>17,
        "remarks"=>remarks,
        "branch_id"=>5,
        "account_id"=>29,
        "amount_increase"=>1500,
        :tax_type => TAX_TYPE_NONTAXABLE,
        "auto_journal_type"=>AUTO_JOURNAL_TYPE_ACCRUED_EXPENSE,
      }

    assert_response :redirect
    assert_redirected_to :action=>:index
    assert_equal '伝票を登録しました。', flash[:notice]
    
    jh = JournalHeader.find_by_remarks(remarks)
    assert_not_nil jh
    assert_equal 201005, jh.ym
    assert_equal 17, jh.day
    assert_equal SLIP_TYPE_SIMPLIFIED, jh.slip_type
    assert_equal remarks, jh.remarks
    assert_equal 1500, jh.amount
    assert_nil jh.transfer_from_id
    assert_nil jh.transfer_from_detail_id
    assert_nil jh.depreciation_id
    assert_equal 0, jh.lock_version
    assert_equal 0, jh.transfer_journals.size
    assert_equal 2, jh.journal_details.size
    assert_equal 0, jh.journal_details[0].transfer_journals.size
    assert_equal 1, jh.journal_details[1].transfer_journals.size
    
    auto = jh.journal_details[1].transfer_journals[0]
    assert_not_nil auto
    assert_equal 201004, auto.ym
    assert_equal 30, auto.day
    assert_equal SLIP_TYPE_AUTO_TRANSFER_ACCRUED_EXPENSE, auto.slip_type
    assert_equal remarks + "【自動】", auto.remarks
    assert_equal 1500, auto.amount
    assert_nil auto.transfer_from_id
    assert_equal jh.journal_details[1].id, auto.transfer_from_detail_id
    assert_nil auto.depreciation_id
    assert_equal 0, auto.lock_version
    assert_equal 1, auto.transfer_journals.size
    assert_equal 2, auto.journal_details.size
    assert_equal 0, auto.journal_details[0].transfer_journals.size
    assert_equal 0, auto.journal_details[1].transfer_journals.size
    
    reverse = auto.transfer_journals[0]
    assert_not_nil reverse
    assert_equal 201005, reverse.ym
    assert_equal 1, reverse.day
    assert_equal SLIP_TYPE_AUTO_TRANSFER_ACCRUED_EXPENSE, reverse.slip_type
    assert_equal auto.remarks + "【逆】", reverse.remarks
    assert_equal 1500, reverse.amount
    assert_equal auto.id, reverse.transfer_from_id
    assert_nil reverse.transfer_from_detail_id
    assert_nil reverse.depreciation_id
    assert_equal 1, reverse.lock_version
    assert_equal 0, reverse.transfer_journals.size
    assert_equal 2, reverse.journal_details.size
    assert_equal 0, reverse.journal_details[0].transfer_journals.size
    assert_equal 0, reverse.journal_details[1].transfer_journals.size
  end

  def test_通常の年度への費用振替の更新が正常終了すること
    remarks = "通常の年度への費用振替の更新が正常終了すること#{Time.new}"
    jh = JournalHeader.find(15)
    lock_version = jh.lock_version
    
    xhr :post, :update,
      :account_code=>ACCOUNT_CODE_CASH,
      :slip => {
        "id"=>jh.id,
        "ym"=>201012,
        "day"=>31,
        "remarks"=>remarks,
        "branch_id"=>5,
        "account_id"=>29,
        "amount_increase"=>1600,
        :tax_type => TAX_TYPE_NONTAXABLE,
        "lock_version"=>lock_version,
        "auto_journal_type"=>AUTO_JOURNAL_TYPE_ACCRUED_EXPENSE,
        "auto_journal_year"=>2007, # ゴミデータ
        "auto_journal_month"=>11, # ゴミデータ
        "auto_journal_day"=>15, # ゴミデータ
      }

    assert_response :success
    assert_template 'common/reload'
    assert_equal '伝票を更新しました。', flash[:notice]
    
    jh = JournalHeader.find_by_remarks(remarks)
    assert_not_nil jh
    assert_equal 201012, jh.ym
    assert_equal 31, jh.day
    assert_equal SLIP_TYPE_SIMPLIFIED, jh.slip_type
    assert_equal remarks, jh.remarks
    assert_equal 1600, jh.amount
    assert_equal 0, jh.transfer_from_id, "更新後にIDが0になるのはなぜ？（DB内はnull）" # TODO
    assert_equal 0, jh.transfer_from_detail_id, "更新後にIDが0になるのはなぜ？（DB内はnull）" # TODO
    assert_equal 0, jh.depreciation_id, "更新後にIDが0になるのはなぜ？（DB内はnull）" # TODO
    assert_equal lock_version + 1, jh.lock_version
    assert_equal 0, jh.transfer_journals.size
    assert_equal 2, jh.journal_details.size
    assert_equal 0, jh.journal_details[0].transfer_journals.size
    assert_equal 1, jh.journal_details[1].transfer_journals.size
    
    auto = jh.journal_details[1].transfer_journals[0]
    assert_not_nil auto
    assert_equal 201011, auto.ym
    assert_equal 30, auto.day
    assert_equal SLIP_TYPE_AUTO_TRANSFER_ACCRUED_EXPENSE, auto.slip_type
    assert_equal remarks + "【自動】", auto.remarks
    assert_equal 1600, auto.amount
    assert_nil auto.transfer_from_id
    assert_equal jh.journal_details[1].id, auto.transfer_from_detail_id
    assert_nil auto.depreciation_id
    assert_equal 0, auto.lock_version
    assert_equal 1, auto.transfer_journals.size
    assert_equal 2, auto.journal_details.size
    assert_equal 0, auto.journal_details[0].transfer_journals.size
    assert_equal 0, auto.journal_details[1].transfer_journals.size
    
    reverse = auto.transfer_journals[0]
    assert_not_nil reverse
    assert_equal 201012, reverse.ym
    assert_equal 1, reverse.day
    assert_equal SLIP_TYPE_AUTO_TRANSFER_ACCRUED_EXPENSE, reverse.slip_type
    assert_equal auto.remarks + "【逆】", reverse.remarks
    assert_equal 1600, reverse.amount
    assert_equal auto.id, reverse.transfer_from_id
    assert_nil reverse.transfer_from_detail_id
    assert_nil reverse.depreciation_id
    assert_equal 1, reverse.lock_version
    assert_equal 0, reverse.transfer_journals.size
    assert_equal 2, reverse.journal_details.size
    assert_equal 0, reverse.journal_details[0].transfer_journals.size
    assert_equal 0, reverse.journal_details[1].transfer_journals.size
  end

  def test_通常の年度の費用振替の削除が正常終了すること
    jh = JournalHeader.find(15)
    
    assert_difference 'JournalHeader.count', -3 do
      post :destroy, :account_code => ACCOUNT_CODE_CASH, :id => jh.id, :lock_version => jh.lock_version
    end

    assert_response :redirect
    assert_redirected_to :action => 'index'
    assert_equal '伝票を削除しました。', flash[:notice]
  end
  
end
