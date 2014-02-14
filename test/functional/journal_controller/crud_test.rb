# coding: UTF-8
#
# $Id: crud_test.rb 3367 2014-02-07 15:05:22Z ichy $
# Product: hyacc
# Copyright 2009-2014 by Hybitz.co.ltd
# ALL Rights Reserved.
#
require 'test_helper'

class JournalController::CrudTest < ActionController::TestCase

  def setup
    @request.session[:user_id] = users(:first).id
  end

  def test_index
    get :index
    assert_response :redirect
    assert_redirected_to :action => 'list'
  end

  def test_list
    get :list

    assert_response :success
    assert_template 'list'
    assert_not_nil assigns(:finder)
    assert_not_nil assigns(:journal_headers)
  end


  def test_list_by_ym_like
    get :list, :finder=>{:slip_type_selection=>1, :ym=>2007, :account_id=>'', :branch_id=>'', :remarks=>''},
               :commit=>'検索'

    assert_response :success
    assert_template 'list'
    assert_not_nil assigns(:finder)
    assert_equal 4, assigns(:journal_headers).size
  end

  def test_new
    get :new, :format => 'js'
    assert_response :success
    assert_template 'new'
    assert_not_nil assigns(:journal_header)
    assert_not_nil assigns(:frequencies)
    assert_equal 22, assigns(:frequencies)[0].input_value.to_i
  end

  def test_new_from_copy
    get :new_from_copy, :id => '1', :format => 'js'
    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:journal_header)
    assert_not_nil assigns(:frequencies)
    assert_equal 22, assigns(:frequencies)[0].input_value.to_i

    # システム日を設定していれば、既存伝票の年月と同一なわけがない
    jh = assigns(:journal_header)
    assert_not_equal JournalHeader.find(1).ym, jh.ym, "新規伝票の年月がコピー元伝票の年月と同じなのは不正です。"
  end

  def test_create
    remarks = '振替伝票テスト' + Time.now.to_s

    num_journal_headers = JournalHeader.count

    post :create, :format => 'js',
      :journal_header => {
        :ym => '200803',
        :day => '04',
        :remarks => remarks,
      },
      :journal_details => {
        '1' => {
          :detail_no => '1',
          :dc_type => '1',
          :account_id => '2',
          :branch_id => '2',
          :input_amount => '1030',
        },
        '2' => {
          :detail_no => '2',
          :dc_type => '2',
          :account_id => '28',
          :branch_id => '2',
          :input_amount => '1030',
        }
      }

    assert_response :success
    assert_template 'common/reload'
    assert_equal num_journal_headers + 1, JournalHeader.count

    # 登録された仕訳をチェック
    jh = JournalHeader.find_by_remarks(remarks)
    assert_equal SLIP_TYPE_TRANSFER, jh.slip_type
    assert_equal 200803, jh.ym
    assert_equal 4, jh.day
    assert_equal 1030, jh.amount
    assert_equal 1, jh.journal_details[0].detail_no
    assert_equal 1, jh.journal_details[0].dc_type
    assert_equal 2, jh.journal_details[0].account_id
    assert_equal 2, jh.journal_details[0].branch_id
    assert_equal 1030, jh.journal_details[0].amount
    assert_equal 2, jh.journal_details[1].detail_no
    assert_equal 2, jh.journal_details[1].dc_type
    assert_equal 28, jh.journal_details[1].account_id
    assert_equal 2, jh.journal_details[1].branch_id
    assert_equal 1030, jh.journal_details[1].amount
  end

  # 子を持つ勘定科目が指定できないことを確認
  def test_create_fail_by_node_account
    a = Account.get_by_code(ACCOUNT_CODE_DEBT)
    assert_equal false, a.journalizable
    
    post :create, :format => 'js',
      :journal_header => {
        :ym => '200907',
        :day => '11',
        :remarks => '仕訳登録不可な勘定科目を指定できないこと',
      },
      :journal_details => {
        '1' => {
          :detail_no => '1',
          :dc_type => '1',
          :account_id => a.id,
          :branch_id => '1',
          :input_amount => '1000',
          :tax_type=>1
        },
        '2' => {
          :detail_no => '2',
          :dc_type => '2',
          :account_id => '2',
          :branch_id => '2',
          :input_amount => '1000',
          :tax_type=>1
        }
      }

    assert_response :success
    assert_template :new
    assert_not_nil assigns(:journal_header)
    assert assigns(:journal_header).errors.size == 1
    
    # 不正な科目を検出しているか
    jd = assigns(:journal_header).journal_details[0]
    assert_not_nil jd
    assert_equal ERR_NOT_JOURNALIZABLE_ACCOUNT, jd.errors[:account][0]
  end
  
  def test_接待交際費で交際費人数なしでの登録がエラーになること
    post :create, :format => 'js',
      :journal_header =>{:remarks=>"接待交際費テスト",
                         :lock_version=>"0",
                         :day=>"07",
                         :ym=>"200907"},
      :journal_details=>{'1'=>{:sub_account_id=>"19",
                               :branch_id=>"1",
                               :account_id=>"23",
                               :tax_amount=>"4",
                               :input_amount=>"100",
                               :note=>"",
                               :tax_type => TAX_TYPE_INCLUSIVE,
                               :tax_rate => 5,
                               :dc_type=>"1",
                               :detail_no=>"1"},
                         '2'=>{:branch_id=>"1",
                               :account_id=>"2",
                               :input_amount=>"100",
                               :note=>"",
                               :tax_type=>"1",
                               :dc_type=>"2",
                               :detail_no=>"2"}
                         }
    assert_response :success
    assert_template 'new'
    assert_not_nil assigns(:journal_header)
    assert assigns(:journal_header).errors.size == 1
    
    # 接待交際の人数が未入力を検出しているか
    jd = assigns(:journal_header).journal_details[0]
    assert_not_nil jd
    assert_equal 'を入力してください。', jd.errors[:social_expense_number_of_people][0]
  end

  def test_接待交際費で交際費人数ありでの登録が正常終了すること
    post :create, :format => 'js',
      :journal_header =>{:remarks=>"接待交際費テスト",
                         :lock_version=>"0",
                         :day=>"07",
                         :ym=>"200907"},
      :journal_details=>{'1'=>{:branch_id=>"1",
                               :account_id=>"23",
                               :sub_account_id=>"19",
                               :tax_amount=>"4",
                               :input_amount=>"100",
                               :note=>"",
                               :tax_type => TAX_TYPE_INCLUSIVE,
                               :tax_rate => 5,
                               :dc_type=>DC_TYPE_DEBIT,
                               :detail_no=>1,
                               :social_expense_number_of_people=>2},
                         '2'=>{:branch_id=>"1",
                               :account_id=>"2",
                               :input_amount=>"100",
                               :note=>"",
                               :tax_type=>TAX_TYPE_NONTAXABLE,
                               :dc_type=>DC_TYPE_CREDIT,
                               :detail_no=>2}
                         }
                         
    assert_response :success
    assert_template 'common/reload'
  end

  def test_edit
    get :edit, :id => JournalHeader.first.id, :format => 'js'

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:journal_header)
    assert assigns(:journal_header).valid?
    assert_not_nil assigns(:frequencies)
    assert_equal 22, assigns(:frequencies)[0].input_value.to_i
  end
  
  # 【費用配賦】は編集画面表示不可
  def test_edit_redirect_by_auto_slip_allocated_cost
    get :edit, :id => 6465

    assert_response :redirect
    assert_redirected_to :action => 'list'
  end
  
  # 【資産配賦】は編集画面表示不可
  def test_edit_redirect_by_auto_slip_allocated_assets
    get :edit, :id => 6466

    assert_response :redirect
    assert_redirected_to :action => 'list'
  end
  
  def test_update
    jh = JournalHeader.find(1)
    
    post :update, :format => 'js',
      :id => jh.id,
      :journal_header => {
        :ym=>200703,
        :day=>4,
        :remarks=>'摘要',
        :lock_version=>jh.lock_version
      },
      :journal_details => {
        '1' => {
          :detail_no => '1',
          :dc_type => '1',
          :account_id => '2',
          :branch_id => '1',
          :input_amount => '1000',
        },
        '2' => {
          :detail_no => '2',
          :dc_type => '2',
          :account_id => '2',
          :branch_id => '1',
          :input_amount => '1000',
        }
      }
    assert_response :success
    assert_template 'common/reload'
  end

  def test_Trac_99_バリデーションエラー時に金額が正しいか
    post :update, :format => 'js',
      :id => 11,
      :journal_header => {
        :ym=>200907,
        :day=>nil,
        :remarks=> '日付を未入力にしてバリデーションエラーにする',
      },
      :journal_details => {
        '1' => {
          :detail_no => 1,
          :dc_type=>DC_TYPE_DEBIT,
          :account_id=>27,
          :branch_id => 1,
          :input_amount=>1000,
          :tax_type => TAX_TYPE_INCLUSIVE,
          :tax_rate_percent => 5
        },
        '2' => {
          :detail_no => 2,
          :dc_type=>DC_TYPE_CREDIT,
          :account_id => 2,
          :branch_id => 1,
          :input_amount=>1000,
          :tax_type=>TAX_TYPE_NONTAXABLE
        }
      }
    assert_response :success
    assert_template 'edit'
    assert_not_nil assigns(:journal_header)

    jh = assigns(:journal_header)
    assert_not_nil jh
    assert_equal 1, jh.errors.size
    assert_equal 1000, jh.normal_details[0].input_amount.to_i
    assert_equal 1000, jh.normal_details[1].input_amount.to_i
  end

  # 賃金台帳から登録された仕訳の更新テスト
  def test_update_payroll
    remarks = '賃金台帳から登録された仕訳の更新テスト' + Time.now.to_s
    jh = JournalHeader.find(4453)

    post :update, :format => 'js',
      :id => jh.id,
      :journal_header => {
        :ym => jh.ym,
        :day => jh.day,
        :remarks => remarks,
        :lock_version => jh.lock_version
      },
      :journal_details => {
        '1' => {
          :detail_no => '1',
          :dc_type => '1',
          :account_id => '2',
          :branch_id => '1',
          :input_amount => '1000',
        },
        '2' => {
          :detail_no => '2',
          :dc_type => '2',
          :account_id => '2',
          :branch_id => '1',
          :input_amount => '1000',
        }
      }
    assert_response :success
    assert_template 'common/reload'

    # 伝票区分は台帳登録のまま
    jh = JournalHeader.find_by_remarks(remarks)
    assert_equal SLIP_TYPE_AUTO_TRANSFER_LEDGER_REGISTRATION, jh.slip_type
  end

  # 楽観的ロックによる更新エラー
  def test_update_fail_by_lock
    jh = JournalHeader.find(1)

    post :update, :format => 'js',
      :id => jh.id,
      :journal_header => {
        :ym => 200703,
        :day => 8,
        :remarks => '更新1回目',
        :lock_version => jh.lock_version
      },
      :journal_details => {
        '1' => {
          :detail_no => '1',
          :dc_type => '1',
          :account_id => '2',
          :branch_id => '1',
          :input_amount => '1000',
        },
        '2' => {
          :detail_no => '2',
          :dc_type => '2',
          :account_id => '2',
          :branch_id => '1',
          :input_amount => '1000',
        }
      }

    assert_response :success
    assert_template 'common/reload'

    post :update, :format => 'js',
      :id => jh.id,
      :journal_header => {
        :ym => 200703,
        :day => 10,
        :remarks => '更新2回目',
        :lock_version => jh.lock_version
      },
      :journal_details => {
        '1' => {
          :detail_no => '1',
          :dc_type => '1',
          :account_id => '2',
          :branch_id => '1',
          :input_amount => '1000',
        },
        '2' => {
          :detail_no => '2',
          :dc_type => '2',
          :account_id => '2',
          :branch_id => '1',
          :input_amount => '1000',
        }
      }

    assert_response :success
    assert_template 'edit'
    assert_not_nil assigns(:journal_header).errors
    # バリデーションエラーではないからAR内にはエラーがない
    assert assigns(:journal_header).errors.size == 0
  end

  # 楽観的ロックによる更新エラー
  def test_destroy_fail_by_lock
    jh = JournalHeader.find(6)
    lock_version = jh.lock_version

    # 意図的にロックバージョンを上げる
    assert jh.save

    post :destroy,
      :id => jh,
      :lock_version => lock_version
    assert_redirected_to :action => 'list'
    
    # 伝票が元のままであるか
    jh = JournalHeader.find(6)
    assert_equal 1, jh.transfer_journals.size(), "自動振替仕訳が削除されていないこと"
    assert_equal 1, jh.transfer_journals[0].transfer_journals.size(), "自動振替仕訳が削除されていないこと"
  end

  def test_destroy
    jh = JournalHeader.find(10)

    post :destroy, :id => jh, :lock_version => jh.lock_version
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      JournalHeader.find(jh.id)
    }
  end
  
  # 前払振替の伝票が削除できないことを確認
  def test_destroy_fail_prepaid
    previous_count = JournalHeader.count
    post :destroy, :id => '5695'
    assert_response :redirect
    assert_redirected_to :action => 'list'
    assert_equal previous_count,JournalHeader.count
  end
  
  # 台帳登録の伝票が削除できないことを確認
  def test_destroy_fail_ledger
    previous_count = JournalHeader.count
    post :destroy, :id => '5697'
    assert_response :redirect
    assert_redirected_to :action => 'list'
    assert_equal previous_count,JournalHeader.count
  end
  
  # 不正な伝票区分の場合は編集画面に遷移できないこと
  def test_edit_fail_by_invalid_slip_type
    get :edit, :id=>5
    assert_response :redirect
    assert_redirected_to :action => 'list'
  end

  # 自動仕訳がある簡易入力伝票が編集画面に遷移できること
  def test_edit_fail
    finder = Slips::SlipFinder.new(User.find(@request.session[:user_id]))
    finder.account_code = Account.get(3).code
    slip = finder.find(6)
    assert_not_nil slip
    assert slip.has_auto_transfers

    get :edit, :id=>slip.id, :format => 'js'
    assert_response :success
    assert_template 'edit'
    assert_not_nil assigns(:journal_header)
  end

end
