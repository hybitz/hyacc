require 'test_helper'

# 前払費用の計上日振替のテスト
class JournalsController::PrepaidExpenseTest < ActionController::TestCase

  def setup
    user = User.find(4)
    assert user.employee.company.get_fiscal_year(2009).closed?
    assert user.employee.company.get_fiscal_year(2010).open?
    assert user.employee.company.get_fiscal_year(2011).closed?
    sign_in user
  end

  def test_本締の年度への費用振替の登録がエラーになること
    post_jh = Journal.find(18)

    assert_no_difference 'Journal.count' do
      post :create, :xhr => true, :params => {
        :journal => {
          :ym => post_jh.ym,
          :day => post_jh.day,
          :remarks => post_jh.remarks,
          :journal_details_attributes => {
            '1' => {
              :branch_id => post_jh.normal_details[0].branch_id,
              :account_id => post_jh.normal_details[0].account_id,
              :sub_account_id => post_jh.normal_details[0].sub_account_id,
              :tax_amount => post_jh.normal_details[0].tax_amount,
              :input_amount => post_jh.normal_details[0].input_amount,
              :tax_type => post_jh.normal_details[0].tax_type,
              :allocation_type => post_jh.normal_details[0].allocation_type,
              :dc_type => post_jh.normal_details[0].dc_type,
              :auto_journal_type => post_jh.normal_details[0].auto_journal_type,
            },
            '2' => {
              :branch_id => post_jh.normal_details[1].branch_id,
              :account_id => post_jh.normal_details[1].account_id,
              :sub_account_id => post_jh.normal_details[1].sub_account_id,
              :input_amount => post_jh.normal_details[1].input_amount,
              :tax_type => post_jh.normal_details[1].tax_type,
              :dc_type => post_jh.normal_details[1].dc_type,
              :auto_journal_type => post_jh.normal_details[1].auto_journal_type,
            }
          }
        }
      }

      assert_response :success
      assert_template 'new'
      assert_not_nil assigns(:journal)
      assert_equal ERR_CLOSING_STATUS_CLOSED, flash[:notice]
    end
  end

  def test_本締の年度からの費用振替の更新がエラーになること
    post_jh = Journal.find(18)
    assert post_jh.fiscal_year.open?
    assert post_jh.journal_details[0].transfer_journals[0].transfer_journals[0].fiscal_year.closed?

    patch :update, :xhr => true, :params => {:id => post_jh.id,
      :journal => {
        :ym => 201008, # 前月も今期中で締め状態は通常
        :day => 9,
        :remarks => post_jh.remarks,
        :lock_version => post_jh.lock_version,
        :journal_details_attributes => {
          '1' => {
            :id => post_jh.normal_details[0].id,
            :branch_id => post_jh.normal_details[0].branch_id,
            :account_id => post_jh.normal_details[0].account_id,
            :sub_account_id => post_jh.normal_details[0].sub_account_id,
            :tax_amount => post_jh.normal_details[0].tax_amount,
            :input_amount => post_jh.normal_details[0].input_amount,
            :tax_type => post_jh.normal_details[0].tax_type,
            :allocation_type => post_jh.normal_details[0].allocation_type,
            :dc_type => post_jh.normal_details[0].dc_type,
            :auto_journal_type => post_jh.normal_details[0].auto_journal_type,
          },
          '2' => {
            :id => post_jh.normal_details[1].id,
            :branch_id => post_jh.normal_details[1].branch_id,
            :account_id => post_jh.normal_details[1].account_id,
            :sub_account_id => post_jh.normal_details[1].sub_account_id,
            :input_amount => post_jh.normal_details[1].input_amount,
            :tax_type => post_jh.normal_details[1].tax_type,
            :dc_type => post_jh.normal_details[1].dc_type,
            :auto_journal_type => post_jh.normal_details[1].auto_journal_type,
          }
        }
      }
    }

    assert_response :success
    assert_template 'edit'
    assert_not_nil assigns(:journal)
    assert_equal ERR_CLOSING_STATUS_CLOSED, flash[:notice]
  end

  def test_本締の年度への費用振替の更新がエラーになること
    post_jh = Journal.find(21)
    assert post_jh.fiscal_year.open?
    assert post_jh.journal_details[0].transfer_journals[0].fiscal_year.open? # もともとは通常の年度に登録されている自動仕訳

    patch :update, :xhr => true, :params => {:id => post_jh.id,
      :journal => {
        :ym => 201012,
        :day => 9,
        :remarks => post_jh.remarks,
        :lock_version => post_jh.lock_version,
        :journal_details_attributes => {
          '0' => {
            :branch_id => post_jh.normal_details[0].branch_id,
            :account_id => post_jh.normal_details[0].account_id,
            :sub_account_id => post_jh.normal_details[0].sub_account_id,
            :tax_amount => post_jh.normal_details[0].tax_amount,
            :input_amount => post_jh.normal_details[0].input_amount,
            :tax_type => post_jh.normal_details[0].tax_type,
            :allocation_type => post_jh.normal_details[0].allocation_type,
            :dc_type => post_jh.normal_details[0].dc_type,
            :auto_journal_type => post_jh.normal_details[0].auto_journal_type
          },
          '1' => {
            :branch_id => post_jh.normal_details[1].branch_id,
            :account_id => post_jh.normal_details[1].account_id,
            :sub_account_id => post_jh.normal_details[1].sub_account_id,
            :input_amount => post_jh.normal_details[1].input_amount,
            :tax_type => post_jh.normal_details[1].tax_type,
            :dc_type => post_jh.normal_details[1].dc_type,
            :auto_journal_type => post_jh.normal_details[1].auto_journal_type
          }
        }
      }
    }

    assert_response :success
    assert_template 'edit'
    assert_not_nil assigns(:journal)
    assert_equal ERR_CLOSING_STATUS_CLOSED, flash[:notice]
  end

  def test_本締の年度の費用振替の削除がエラーになること
    jh = Journal.find(18)

    assert_no_difference 'Journal.count' do
      delete :destroy, :params => {:id => jh.id, :lock_version => jh.lock_version}
    end

    assert_response :redirect
    assert_redirected_to :action => 'index'
    assert_equal ERR_CLOSING_STATUS_CLOSED, flash[:notice]
  end

  def test_通常の年度への費用振替の登録が正常終了すること
    remarks = "通常の年度への費用振替の登録が正常終了すること#{Time.new}"
    assert_nil Journal.where(:remarks => remarks).first

    post_jh = Journal.find(21)

    post :create, :xhr => true, :params => {
      :journal => {
        :ym => 201009,
        :day => 14,
        :remarks => remarks,
        :journal_details_attributes => {
          '1' => {
            :branch_id => post_jh.normal_details[0].branch_id,
            :account_id => post_jh.normal_details[0].account_id,
            :sub_account_id => post_jh.normal_details[0].sub_account_id,
            :tax_amount => post_jh.normal_details[0].tax_amount,
            :input_amount => 510,
            :tax_type => post_jh.normal_details[0].tax_type,
            :allocation_type => post_jh.normal_details[0].allocation_type,
            :dc_type => post_jh.normal_details[0].dc_type,
            :auto_journal_type => post_jh.normal_details[0].auto_journal_type,
          },
          '2' => {
            :branch_id => post_jh.normal_details[1].branch_id,
            :account_id => post_jh.normal_details[1].account_id,
            :sub_account_id => post_jh.normal_details[1].sub_account_id,
            :input_amount => 550,
            :tax_type => post_jh.normal_details[1].tax_type,
            :dc_type => post_jh.normal_details[1].dc_type,
            :auto_journal_type => post_jh.normal_details[1].auto_journal_type,
          },
          '3' => {
            :branch_id => post_jh.normal_details[0].branch_id,
            :account_id => post_jh.normal_details[0].account_id,
            :sub_account_id => post_jh.normal_details[0].sub_account_id,
            :tax_amount => post_jh.normal_details[0].tax_amount,
            :input_amount => 40,
            :tax_type => post_jh.normal_details[0].tax_type,
            :allocation_type => post_jh.normal_details[0].allocation_type,
            :dc_type => post_jh.normal_details[0].dc_type,
            :auto_journal_type => post_jh.normal_details[0].auto_journal_type,
          },
        }
      }
    }

    assert assigns(:journal)
    assert_response :success
    assert_template 'common/reload'
    assert_equal '伝票を登録しました。', flash[:notice]

    assert jh = Journal.where(:remarks => remarks).first
    assert_equal 201009, jh.ym
    assert_equal 14, jh.day
    assert_equal SLIP_TYPE_TRANSFER, jh.slip_type
    assert_equal remarks, jh.remarks
    assert_equal 550, jh.amount
    assert_nil jh.transfer_from_id
    assert_nil jh.transfer_from_detail_id
    assert_nil jh.depreciation_id
    assert_equal 0, jh.lock_version
    assert_equal 0, jh.transfer_journals.size
    assert_equal 3, jh.journal_details.size
    assert_equal 1, jh.journal_details[0].transfer_journals.size
    assert_equal 0, jh.journal_details[1].transfer_journals.size
    assert_equal 1, jh.journal_details[2].transfer_journals.size

    auto = jh.journal_details[0].transfer_journals[0]
    assert_not_nil auto
    assert_equal 201009, auto.ym
    assert_equal 30, auto.day
    assert_equal SLIP_TYPE_AUTO_TRANSFER_PREPAID_EXPENSE, auto.slip_type
    assert_equal remarks + "【自動】", auto.remarks
    assert_equal 510, auto.amount
    assert_nil auto.transfer_from_id
    assert_equal jh.journal_details[0].id, auto.transfer_from_detail_id
    assert_nil auto.depreciation_id
    assert_equal 0, auto.lock_version
    assert_equal 1, auto.transfer_journals.size
    assert_equal 2, auto.journal_details.size
    assert_equal 0, auto.journal_details[0].transfer_journals.size
    assert_equal 0, auto.journal_details[1].transfer_journals.size

    assert reverse = auto.transfer_journals[0]
    assert_equal 201010, reverse.ym
    assert_equal 1, reverse.day
    assert_equal SLIP_TYPE_AUTO_TRANSFER_PREPAID_EXPENSE, reverse.slip_type
    assert_equal auto.remarks + "【逆】", reverse.remarks
    assert_equal 510, reverse.amount
    assert_equal auto.id, reverse.transfer_from_id
    assert_nil reverse.transfer_from_detail_id
    assert_nil reverse.depreciation_id
    assert_equal 0, reverse.lock_version
    assert_equal 0, reverse.transfer_journals.size
    assert_equal 2, reverse.journal_details.size
    assert_equal 0, reverse.journal_details[0].transfer_journals.size
    assert_equal 0, reverse.journal_details[1].transfer_journals.size

    assert auto2 = jh.journal_details[2].transfer_journals[0]
    assert_equal 201009, auto2.ym
    assert_equal 30, auto2.day
    assert_equal SLIP_TYPE_AUTO_TRANSFER_PREPAID_EXPENSE, auto2.slip_type
    assert_equal remarks + "【自動】", auto2.remarks
    assert_equal 40, auto2.amount
    assert_nil auto2.transfer_from_id
    assert_equal jh.journal_details[2].id, auto2.transfer_from_detail_id
    assert_nil auto2.depreciation_id
    assert_equal 0, auto2.lock_version
    assert_equal 1, auto2.transfer_journals.size
    assert_equal 2, auto2.journal_details.size
    assert_equal 0, auto2.journal_details[0].transfer_journals.size
    assert_equal 0, auto2.journal_details[1].transfer_journals.size

    assert reverse2 = auto2.transfer_journals[0]
    assert_equal 201010, reverse2.ym
    assert_equal 1, reverse2.day
    assert_equal SLIP_TYPE_AUTO_TRANSFER_PREPAID_EXPENSE, reverse2.slip_type
    assert_equal auto2.remarks + "【逆】", reverse2.remarks
    assert_equal 40, reverse2.amount
    assert_equal auto2.id, reverse2.transfer_from_id
    assert_nil reverse2.transfer_from_detail_id
    assert_nil reverse2.depreciation_id
    assert_equal 0, reverse2.lock_version
    assert_equal 0, reverse2.transfer_journals.size
    assert_equal 2, reverse2.journal_details.size
    assert_equal 0, reverse2.journal_details[0].transfer_journals.size
    assert_equal 0, reverse2.journal_details[1].transfer_journals.size
  end

  def test_通常の年度への費用振替の更新が正常終了すること
    remarks = "通常の年度への費用振替の更新が正常終了すること #{Time.new}"
    post_jh = Journal.find(21)
    lock_version = post_jh.lock_version

    patch :update, :xhr => true, :params => {:id => post_jh.id,
      :journal => {
        :ym => 201005,
        :day => 19,
        :remarks => remarks,
        :lock_version => lock_version,
        :journal_details_attributes => {
          '0' => {
            :id => post_jh.normal_details[0].id,
            :branch_id => post_jh.normal_details[0].branch_id,
            :account_id => post_jh.normal_details[0].account_id,
            :sub_account_id => post_jh.normal_details[0].sub_account_id,
            :input_amount => 1000,
            :tax_type => post_jh.normal_details[0].tax_type,
            :tax_amount => post_jh.normal_details[0].tax_amount,
            :allocation_type => post_jh.normal_details[0].allocation_type,
            :dc_type => post_jh.normal_details[0].dc_type,
            :auto_journal_type => post_jh.normal_details[0].auto_journal_type,
          },
          '1' => {
            :id => post_jh.normal_details[1].id,
            :branch_id => post_jh.normal_details[1].branch_id,
            :account_id => post_jh.normal_details[1].account_id,
            :sub_account_id => post_jh.normal_details[1].sub_account_id,
            :input_amount => 1999,
            :tax_type => post_jh.normal_details[1].tax_type,
            :tax_amount => 0,
            :dc_type => post_jh.normal_details[1].dc_type,
            :auto_journal_type => post_jh.normal_details[1].auto_journal_type,
          },
          '2' => {
            :branch_id => post_jh.normal_details[0].branch_id,
            :account_id => post_jh.normal_details[0].account_id,
            :sub_account_id => post_jh.normal_details[0].sub_account_id,
            :input_amount => 999,
            :tax_type => post_jh.normal_details[0].tax_type,
            :tax_amount => post_jh.normal_details[0].tax_amount,
            :allocation_type => post_jh.normal_details[0].allocation_type,
            :dc_type => post_jh.normal_details[0].dc_type,
            :auto_journal_type => post_jh.normal_details[0].auto_journal_type,
          }
        }
      }
    }

    assert_response :success
    assert_template 'common/reload'
    assert_equal '伝票を更新しました。', flash[:notice]

    assert jh = Journal.find_by_remarks(remarks)
    assert_equal 201005, jh.ym
    assert_equal 19, jh.day
    assert_equal SLIP_TYPE_TRANSFER, jh.slip_type
    assert_equal remarks, jh.remarks
    assert_equal 1999, jh.amount
    assert_nil jh.transfer_from_id
    assert_nil jh.transfer_from_detail_id
    assert_nil jh.depreciation_id
    assert_equal lock_version + 1, jh.lock_version
    assert_equal 0, jh.transfer_journals.size
    assert_equal 3, jh.journal_details.size
    assert_equal 1, jh.journal_details[0].transfer_journals.size
    assert_equal 0, jh.journal_details[1].transfer_journals.size
    assert_equal 1, jh.journal_details[2].transfer_journals.size

    assert auto = jh.journal_details[0].transfer_journals[0]
    assert_equal 201005, auto.ym
    assert_equal 31, auto.day
    assert_equal SLIP_TYPE_AUTO_TRANSFER_PREPAID_EXPENSE, auto.slip_type
    assert_equal remarks + "【自動】", auto.remarks
    assert_equal 1000, auto.amount
    assert_nil auto.transfer_from_id
    assert_equal jh.journal_details[0].id, auto.transfer_from_detail_id
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
    assert_equal 1000, reverse.amount
    assert_equal auto.id, reverse.transfer_from_id
    assert_nil reverse.transfer_from_detail_id
    assert_nil reverse.depreciation_id
    assert_equal 0, reverse.lock_version
    assert_equal 0, reverse.transfer_journals.size
    assert_equal 2, reverse.journal_details.size
    assert_equal 0, reverse.journal_details[0].transfer_journals.size
    assert_equal 0, reverse.journal_details[1].transfer_journals.size

    assert auto2 = jh.journal_details[2].transfer_journals[0]
    assert_equal 201005, auto2.ym
    assert_equal 31, auto2.day
    assert_equal SLIP_TYPE_AUTO_TRANSFER_PREPAID_EXPENSE, auto2.slip_type
    assert_equal remarks + "【自動】", auto2.remarks
    assert_equal 999, auto2.amount
    assert_nil auto2.transfer_from_id
    assert_equal jh.journal_details[2].id, auto2.transfer_from_detail_id
    assert_nil auto2.depreciation_id
    assert_equal 0, auto2.lock_version
    assert_equal 1, auto2.transfer_journals.size
    assert_equal 2, auto2.journal_details.size
    assert_equal 0, auto2.journal_details[0].transfer_journals.size
    assert_equal 0, auto2.journal_details[1].transfer_journals.size

    assert reverse2 = auto2.transfer_journals[0]
    assert_equal 201006, reverse2.ym
    assert_equal 1, reverse2.day
    assert_equal SLIP_TYPE_AUTO_TRANSFER_PREPAID_EXPENSE, reverse2.slip_type
    assert_equal auto2.remarks + "【逆】", reverse2.remarks
    assert_equal 999, reverse2.amount
    assert_equal auto2.id, reverse2.transfer_from_id
    assert_nil reverse2.transfer_from_detail_id
    assert_nil reverse2.depreciation_id
    assert_equal 0, reverse2.lock_version
    assert_equal 0, reverse2.transfer_journals.size
    assert_equal 2, reverse2.journal_details.size
    assert_equal 0, reverse2.journal_details[0].transfer_journals.size
    assert_equal 0, reverse2.journal_details[1].transfer_journals.size
  end

  def atest_通常の年度の費用振替の削除が正常終了すること
    jh = Journal.find(21)

    assert_difference 'Journal.count', -3 do
      delete :destroy, :params => {:id => jh.id, :lock_version => jh.lock_version}
    end

    assert_response :redirect
    assert_redirected_to :action => 'index'
    assert_equal '伝票を削除しました。', flash[:notice]
  end
end
