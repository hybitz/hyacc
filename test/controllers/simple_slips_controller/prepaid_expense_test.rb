require 'test_helper'

# 未払費用の計上日振替のテスト
class SimpleSlipsController::PrepaidExpenseTest < ActionDispatch::IntegrationTest

  def setup
    assert freelancer.employee.company.get_fiscal_year(2010).open?
    assert freelancer.employee.company.get_fiscal_year(2011).closed?

    sign_in freelancer
  end

  def test_本締の年度への費用振替の登録がエラーになること

    post simple_slips_path, :params => {
      :account_code => ACCOUNT_CODE_CASH,
      :simple_slip => {
        "ym"=>201012,
        "day"=>01,
        "remarks"=>"本締の年度への費用振替の登録がエラーになること",
        "branch_id"=>5,
        "account_id"=>28, # 燃料費
        "amount_increase"=>4255,
        :tax_type => TAX_TYPE_NONTAXABLE,
        "auto_journal_type"=>AUTO_JOURNAL_TYPE_PREPAID_EXPENSE,
      }
    }

    assert_response :success
    assert_template :index
    assert assigns(:simple_slip)
    assert_equal ERR_CLOSING_STATUS_CLOSED, flash[:notice]
  end

  def test_本締の年度に費用振替が存在する伝票の更新がエラーになること
    jh = Journal.find(18)
    assert_equal 201012, jh.ym
    jd = jh.normal_details[0]
    assert_equal 201101, jd.transfer_journals[0].transfer_journals[0].ym

    patch simple_slip_path(jh), :params => {
      :account_code => ACCOUNT_CODE_ORDINARY_DIPOSIT,
      :simple_slip => {
        "ym" => 201011,
        "day" => 21,
        "remarks" => jh.remarks,
        "branch_id" => jd.branch_id,
        "account_id" => jd.account_id,
        "sub_account_id" => jd.sub_account_id,
        "amount_increase" => jd.input_amount,
        "amount_decrease" => jd.input_amount,
        :tax_type => TAX_TYPE_NONTAXABLE,
        :lock_version => jh.lock_version,
        :auto_journal_type => AUTO_JOURNAL_TYPE_PREPAID_EXPENSE,
      }
    },
    :xhr => true

    assert_response :success
    assert_template :edit
    assert assigns(:simple_slip)
    assert_equal ERR_CLOSING_STATUS_CLOSED, flash[:notice]
  end

  def test_本締の年度への費用振替の更新がエラーになること
    account = Account.find(5)
    jh = Journal.find(21)
    slip = SimpleSlip.build_from_journal(account.id, jh.id)

    patch simple_slip_path(jh), :params => {
      :account_code => account.code,
      :simple_slip => {
        "ym" => 201012,
        "day" => 7,
        "remarks" => '本締の年度への費用振替の更新がエラーになること',
        "branch_id" => slip.branch_id,
        "account_id" => slip.account_id,
        "sub_account_id" => slip.sub_account_id,
        "amount_increase" => slip.amount_increase,
        "amount_decrease" => slip.amount_decrease,
        :tax_type => TAX_TYPE_NONTAXABLE,
        :lock_version => slip.lock_version,
        :auto_journal_type  => AUTO_JOURNAL_TYPE_PREPAID_EXPENSE,
      }
    },
    :xhr => true

    assert_response :success
    assert_template 'edit'
    assert assigns(:simple_slip)
    assert_equal ERR_CLOSING_STATUS_CLOSED, flash[:notice]
  end

  def test_本締の年度の費用振替の削除がエラーになること
    jh = Journal.find(18)

    assert_no_difference 'Journal.count' do
      delete simple_slip_path(jh), :params => {:account_code => ACCOUNT_CODE_ORDINARY_DIPOSIT, :lock_version => jh.lock_version}
    end

    assert_response :redirect
    assert_redirected_to :action => 'index'
    assert_equal ERR_CLOSING_STATUS_CLOSED, flash[:notice]
  end

  def test_通常の年度への費用振替の登録が正常終了すること
    remarks = "通常の年度への費用振替の登録が正常終了すること #{Time.new}"
    assert_nil Journal.find_by_remarks(remarks)

    post simple_slips_path, :params => {
      :account_code => ACCOUNT_CODE_CASH,
      :simple_slip => {
        "ym" => 201005,
        "day" => 10,
        "remarks" => remarks,
        "branch_id" => 5,
        "account_id" => 28,
        "amount_increase" => 1500,
        :tax_type => TAX_TYPE_NONTAXABLE,
        "auto_journal_type" => AUTO_JOURNAL_TYPE_PREPAID_EXPENSE,
      }
    }

    assert_response :redirect
    assert_redirected_to :action => :index
    assert_equal '伝票を登録しました。', flash[:notice]

    assert jh = Journal.find_by_remarks(remarks)
    assert_equal 201005, jh.ym
    assert_equal 10, jh.day
    assert_equal SLIP_TYPE_SIMPLIFIED, jh.slip_type
    assert_equal 1500, jh.amount
    assert_nil jh.transfer_from_id
    assert_nil jh.transfer_from_detail_id
    assert_nil jh.depreciation_id
    assert_equal 0, jh.lock_version
    assert_equal 0, jh.transfer_journals.size
    assert_equal 2, jh.journal_details.size
    assert_equal 0, jh.journal_details[0].transfer_journals.size
    assert_equal 1, jh.journal_details[1].transfer_journals.size

    assert auto = jh.journal_details[1].transfer_journals[0]
    assert_equal 201005, auto.ym
    assert_equal 31, auto.day
    assert_equal SLIP_TYPE_AUTO_TRANSFER_PREPAID_EXPENSE, auto.slip_type
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

    assert reverse = auto.transfer_journals[0]
    assert_equal 201006, reverse.ym
    assert_equal 1, reverse.day
    assert_equal SLIP_TYPE_AUTO_TRANSFER_PREPAID_EXPENSE, reverse.slip_type
    assert_equal auto.remarks + "【逆】", reverse.remarks
    assert_equal 1500, reverse.amount
    assert_equal auto.id, reverse.transfer_from_id
    assert_nil reverse.transfer_from_detail_id
    assert_nil reverse.depreciation_id
    assert_equal 0, reverse.lock_version
    assert_equal 0, reverse.transfer_journals.size
    assert_equal 2, reverse.journal_details.size
    assert_equal 0, reverse.journal_details[0].transfer_journals.size
    assert_equal 0, reverse.journal_details[1].transfer_journals.size
  end

  def test_通常の年度への費用振替の更新が正常終了すること
    remarks = "通常の年度への費用振替の更新が正常終了すること #{Time.new}"
    jh = Journal.find(21)
    lock_version = jh.lock_version

    patch simple_slip_path(jh), :params => {
      :account_code => ACCOUNT_CODE_ORDINARY_DIPOSIT,
      :simple_slip => {
        "ym" => 201011,
        "day" => 30,
        "remarks" => remarks,
        "branch_id" => 5,
        "account_id" => 29,
        "amount_increase" => 1600,
        :tax_type => TAX_TYPE_NONTAXABLE,
        "lock_version" => lock_version,
        "auto_journal_type" => AUTO_JOURNAL_TYPE_PREPAID_EXPENSE,
        "auto_journal_year" => 2007, # ゴミデータ
        "auto_journal_month" => 11, # ゴミデータ
        "auto_journal_day" => 15, # ゴミデータ
      }
    },
    :xhr => true

    assert_response :success
    assert_template 'common/reload'
    assert_equal '伝票を更新しました。', flash[:notice]

    assert jh = Journal.find_by_remarks(remarks)
    assert_equal 201011, jh.ym
    assert_equal 30, jh.day
    assert_equal SLIP_TYPE_SIMPLIFIED, jh.slip_type
    assert_equal remarks, jh.remarks
    assert_equal 1600, jh.amount
    assert_nil jh.transfer_from_id
    assert_nil jh.transfer_from_detail_id
    assert_nil jh.depreciation_id
    assert_equal lock_version + 1, jh.lock_version
    assert_equal 0, jh.transfer_journals.size
    assert_equal 2, jh.journal_details.size
    assert_equal 1, jh.journal_details[0].transfer_journals.size
    assert_equal 0, jh.journal_details[1].transfer_journals.size

    assert auto = jh.journal_details[0].transfer_journals[0]
    assert_equal 201011, auto.ym
    assert_equal 30, auto.day
    assert_equal SLIP_TYPE_AUTO_TRANSFER_PREPAID_EXPENSE, auto.slip_type
    assert_equal remarks + "【自動】", auto.remarks
    assert_equal 1600, auto.amount
    assert_nil auto.transfer_from_id
    assert_equal jh.journal_details[0].id, auto.transfer_from_detail_id
    assert_nil auto.depreciation_id
    assert_equal 0, auto.lock_version
    assert_equal 1, auto.transfer_journals.size
    assert_equal 2, auto.journal_details.size
    assert_equal 0, auto.journal_details[0].transfer_journals.size
    assert_equal 0, auto.journal_details[1].transfer_journals.size

    assert reverse = auto.transfer_journals[0]
    assert_equal 201012, reverse.ym
    assert_equal 1, reverse.day
    assert_equal SLIP_TYPE_AUTO_TRANSFER_PREPAID_EXPENSE, reverse.slip_type
    assert_equal auto.remarks + "【逆】", reverse.remarks
    assert_equal 1600, reverse.amount
    assert_equal auto.id, reverse.transfer_from_id
    assert_nil reverse.transfer_from_detail_id
    assert_nil reverse.depreciation_id
    assert_equal 0, reverse.lock_version
    assert_equal 0, reverse.transfer_journals.size
    assert_equal 2, reverse.journal_details.size
    assert_equal 0, reverse.journal_details[0].transfer_journals.size
    assert_equal 0, reverse.journal_details[1].transfer_journals.size
  end

  def test_通常の年度の費用振替の削除が正常終了すること
    jh = Journal.find(21)

    assert_difference 'Journal.count', -3 do
      delete simple_slip_path(jh), :params => {:account_code => ACCOUNT_CODE_ORDINARY_DIPOSIT, :lock_version => jh.lock_version}
    end

    assert_response :redirect
    assert_redirected_to :action => 'index'
    assert_equal '伝票を削除しました。', flash[:notice]
  end

end
