require 'test_helper'

class JournalsController::CrudTest < ActionController::TestCase

  setup do
    sign_in user
  end

  def test_一覧
    get :index

    assert_response :success
    assert_template 'index'
    assert_not_nil assigns(:finder)
    assert_not_nil assigns(:journal_headers)
  end

  def test_list_by_ym_like
    get :index, :commit => '検索',
        :finder => {:slip_type_selection=>1, :ym=>2007, :account_id=>'', :branch_id=>'', :remarks=>''}

    assert_response :success
    assert_template 'index'
    assert_not_nil assigns(:finder)
    assert_equal 4, assigns(:journal_headers).size
  end

  def test_追加
    xhr :get, :new
    assert_response :success
    assert_template 'new'
    assert_not_nil assigns(:journal)
    assert_not_nil assigns(:frequencies)
    assert_equal 22, assigns(:frequencies)[0].input_value.to_i
  end

  def test_コピーを追加
    xhr :get, :new, :copy_id => 1
    assert_response :success
    assert_template 'new'

    assert @journal = assigns(:journal)
    assert @frequencies = assigns(:frequencies)
    assert_equal 22, @frequencies.first.input_value.to_i

    # システム日を設定していれば、既存伝票の年月と同一なわけがない
    assert_not_equal JournalHeader.find(1).ym, @journal.ym
  end

  def test_登録
    remarks = '振替伝票テスト' + Time.now.to_s

    assert_difference 'JournalHeader.count', 1 do
      xhr :post, :create,
        :journal => {
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
    end

    # 登録された仕訳をチェック
    assert jh = JournalHeader.where(:remarks => remarks).first
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

    assert_no_difference 'JournalHeader.count' do
      xhr :post, :create,
        :journal => {
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
      assert @journal = assigns(:journal)
      assert @journal.errors.size == 1
    end
    
    # 不正な科目を検出しているか
    assert jd = @journal.journal_details.first
    assert_equal ERR_NOT_JOURNALIZABLE_ACCOUNT, jd.errors[:account][0]
  end
  
  def test_接待交際費で交際費人数なしでの登録がエラーになること
    assert_no_difference 'JournalHeader.count' do
      xhr :post, :create,
        :journal => {
          :remarks => "接待交際費テスト",
          :lock_version => "0",
          :day => "07",
          :ym => "200907"
        },
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
    end

    assert @journal = assigns(:journal)
    assert @journal.errors.size == 1
    assert jd = @journal.journal_details.first
    assert_equal 'を入力してください。', jd.errors[:social_expense_number_of_people][0], '接待交際の人数が未入力を検出していること'
  end

  def test_接待交際費で交際費人数ありでの登録が正常終了すること
    xhr :post, :create,
      :journal =>{:remarks=>"接待交際費テスト",
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
    xhr :get, :edit, :id => JournalHeader.first

    assert_response :success
    assert_template 'edit'

    assert @journal = assigns(:journal)
    assert @journal.valid?
    assert @frequencies = assigns(:frequencies)
    assert_equal 22, @frequencies.first.input_value.to_i
  end
  
  # 【費用配賦】は編集画面表示不可
  def test_edit_redirect_by_auto_slip_allocated_cost
    xhr :get, :edit, :id => 6465

    assert_response :redirect
    assert_redirected_to :action => 'index'
  end
  
  # 【資産配賦】は編集画面表示不可
  def test_edit_redirect_by_auto_slip_allocated_assets
    xhr :get, :edit, :id => 6466

    assert_response :redirect
    assert_redirected_to :action => 'index'
  end
  
  def test_update
    jh = JournalHeader.find(1)
    
    xhr :patch, :update, :id => jh,
      :journal => {
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
    xhr :patch, :update, :id => 11,
      :journal => {
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

    assert @journal = assigns(:journal)
    assert_equal 1, @journal.errors.size
    assert_equal 1000, @journal.normal_details[0].input_amount.to_i
    assert_equal 1000, @journal.normal_details[1].input_amount.to_i
  end

  # 賃金台帳から登録された仕訳の更新テスト
  def test_update_payroll
    remarks = '賃金台帳から登録された仕訳の更新テスト' + Time.now.to_s
    jh = JournalHeader.find(4453)

    xhr :patch, :update, :id => jh.id,
      :journal => {
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

    xhr :patch, :update, :id => jh.id,
      :journal => {
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

    xhr :patch, :update, :id => jh.id,
      :journal => {
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
    assert_not_nil assigns(:journal).errors
    # バリデーションエラーではないからAR内にはエラーがない
    assert assigns(:journal).errors.empty?
  end

  # 楽観的ロックによる更新エラー
  def test_destroy_fail_by_lock
    jh = JournalHeader.find(6)
    lock_version = jh.lock_version

    # 意図的にロックバージョンを上げる
    assert jh.save

    delete :destroy, :id => jh, :lock_version => lock_version
    assert_redirected_to :action => 'index'
    
    # 伝票が元のままであるか
    jh = JournalHeader.find(6)
    assert_equal 1, jh.transfer_journals.size(), "自動振替仕訳が削除されていないこと"
    assert_equal 1, jh.transfer_journals[0].transfer_journals.size(), "自動振替仕訳が削除されていないこと"
  end

  def test_destroy
    jh = JournalHeader.find(10)

    delete :destroy, :id => jh, :lock_version => jh.lock_version
    assert_response :redirect
    assert_redirected_to :action => 'index'

    assert_raise(ActiveRecord::RecordNotFound) {
      JournalHeader.find(jh.id)
    }
  end
  
  def test_前払振替の伝票は削除できない
    assert_no_difference 'JournalHeader.count' do
      delete :destroy, :id => '5695'
      assert_response :redirect
      assert_redirected_to :action => 'index'
    end
  end
  
  def test_台帳登録の伝票は削除できない
    assert_no_difference 'JournalHeader.count' do
      delete :destroy, :id => '5697'
      assert_response :redirect
      assert_redirected_to :action => 'index'
    end
  end
  
  # 不正な伝票区分の場合は編集画面に遷移できないこと
  def test_edit_fail_by_invalid_slip_type
    xhr :get, :edit, :id => 5
    assert_response :redirect
    assert_redirected_to :action => 'index'
  end

  # 自動仕訳がある簡易入力伝票が編集画面に遷移できること
  def test_edit_fail
    finder = Slips::SlipFinder.new(current_user)
    finder.account_code = Account.get(3).code
    slip = finder.find(6)
    assert_not_nil slip
    assert slip.has_auto_transfers

    xhr :get, :edit, :id => slip.id
    assert_response :success
    assert_template 'edit'
    assert_not_nil assigns(:journal)
  end

end
