require 'test_helper'

class AccountsControllerTest < ActionController::TestCase

  def setup
    @first_id = Account.find(28).id
    sign_in user
  end

  def test_一覧
    get :index

    assert_response :success
    assert_template 'index'
    assert_nil assigns(:accounts)
  end

  def test_一覧_検索
    get :index,
      :finder => {
        :account_type => ACCOUNT_TYPE_ASSET,
      }

    assert_response :success
    assert_template 'index'
    assert assigns(:accounts).present?
  end
  
  def test_list_tree
    get :list_tree
    assert_response :success
    assert_template :list_tree
    assert assigns(:accounts).present?
  end

  def test_参照
    xhr :get, :show, :id => @first_id

    assert_response :success
    assert_template 'show'

    assert @account = assigns(:account)
    assert @account.valid?
  end

  def test_追加
    xhr :get, :new, :parent_id => @first_id

    assert_response :success
    assert_template 'new'
    assert assigns(:account)
  end

  def test_new_fail_by_missing_parent_id
    assert_raise( ActiveRecord::RecordNotFound ){ xhr :get, :new }
  end

  def test_登録
    assert_difference 'Account.count', 1 do
      xhr :post, :create, :account => valid_account_params
      assert_response :success
      assert_template 'common/reload'
    end
  end

  def test_登録_入力エラー
    assert_no_difference 'Account.count' do
      xhr :post, :create, :account => invalid_account_params

      assert_response :success
      assert_template 'new'
    end
  end

  def test_編集
    xhr :get, :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'
    assert @account = assigns(:account)
    assert @account.valid?
  end

  def test_削除状態_停止状態_でも編集画面に遷移できること
    Account.find( @first_id ).update_attribute(:deleted, true)

    xhr :get, :edit, :id => @first_id
    
    assert_response :success
    assert_template 'edit'
    assert_not_nil assigns(:account)
  end

  def test_更新
    xhr :patch, :update, :id => expense_account.id,
        :account => valid_account_params.except(:code, :account_type)

    assert @account = assigns(:account)
    assert_equal expense_account.id, @account.id
    assert @account.valid?, @account.errors.full_messages 
    assert_response :success
    assert_template 'common/reload'
  end

  def test_補助科目が重複
    a = Account.find(@first_id)
    xhr :patch, :update, :id => @first_id, :commit => '更新',
                  :account => {:name => a.name, :sub_account_type => a.sub_account_type,
                               :account_type => a.account_type, :tax_type => a.tax_type,
                               :dc_type => a.dc_type, :trade_type => a.trade_type},
                  :sub_accounts => {"1"=>{:id=>'28',:name=>'補助科目１',:code=>'100',:deleted=>'false'},
                                    "2"=>{:id=>'29',:name=>'補助科目２',:code=>'200',:deleted=>'false'},
                                    "3"=>{:id=>'30',:name=>'補助科目３',:code=>'200',:deleted=>'false'}}
    
    assert_response :success
    assert_template 'edit'
    assert_nil assigns(:notice)
  end

  def test_補助科目変更不可の勘定科目で_補助科目区分が変更できないこと
    id = 65
    a = Account.find(id)
    assert_equal SUB_ACCOUNT_TYPE_CORPORATE_TAX, a.sub_account_type
    assert ! a.sub_account_editable?
    
    xhr :post, :update, :id => id, :commit => '更新',
                  :account => {:sub_account_type=>SUB_ACCOUNT_TYPE_NORMAL},
                  :sub_accounts => {"1"=>{:id=>28,:name=>'補助科目１',:code=>'100',:deleted=>'false'},
                                    "2"=>{:id=>29,:name=>'補助科目２',:code=>'200',:deleted=>'false'},
                                    "3"=>{:id=>30,:name=>'補助科目３',:code=>'300',:deleted=>'false'}}
    
    assert_response :success
    assert_template 'edit'
    assert_equal ERR_SUB_ACCOUNT_TYPE_NOT_EDITABLE, flash[:notice]
  end

  def test_削除
    assert_nothing_raised {
      xhr :delete, :destroy, :id => @first_id
      assert_response :success
      assert_template 'common/reload'
    }

    assert Account.find(@first_id).deleted?
  end
  
  # システム必須の勘定科目は削除できないこと
  def test_destroy_fail
    assert_raise( HyaccException ){
      post :destroy, :id=>Account.find_by_code(ACCOUNT_CODE_CASH)
    }
  end
  
  # 伝票で使用されている勘定科目は削除できないこと
  def test_destroy_fail2
    account = Account.find(6) # 売掛金
    assert ! account.system_required?
    assert JournalDetail.where(:account_id => account.id).present?

    assert_raise HyaccException do
      delete :destroy, :id => account.id
    end
  end
  
  def test_伝票が存在しない場合_補助科目がすべて削除可能であること
    # まずは新規作成
    xhr :post, :create, 
      :account => {
        :sub_account_type=>SUB_ACCOUNT_TYPE_NORMAL,
        :code=>"6666",
        :name=>"テスト科目",
        :is_settlement_report_account=>"true",
        :account_type=>"2",
        :tax_type=>"1",
        :dc_type=>"2",
        :parent_id=>"45",
        :trade_type=>"1"
      },
      :sub_accounts => {
        "1" => {
          :code=>"100",
          :name=>"テスト補助科目",
          :id=>"",
          :deleted=>"false"
        }
      }
    assert_response :success
    assert_template 'common/reload'
    assert_equal 1, Account.find_by_code(6666).sub_accounts_all.size
    
    # 補助科目なしで更新
    xhr :patch, :update, :id => Account.find_by_code(6666),
      :account=>{
        :sub_account_type=>SUB_ACCOUNT_TYPE_NORMAL,
        :name=>"テスト科目",
        :is_settlement_report_account=>"true",
        :account_type=>"2",
        :tax_type=>"1",
        :dc_type=>"2",
        :trade_type=>"1"
      },
      :sub_accounts=>{
      }
    assert_response :success
    assert_template 'common/reload'
    assert_equal 0, Account.find_by_code(6666).sub_accounts_all.size
  end

  def test_科目を別の科目の後ろに移動
    assert parent = Account.find_by_code(ACCOUNT_CODE_SALES_AND_GENERAL_ADMINISTRATIVE_EXPENSE)
    assert moved = Account.where(:parent_id => parent.id).not_deleted.first
    assert target = Account.where(:parent_id => parent.id).not_deleted.last
    assert moved.display_order < target.display_order
    
    post :update_tree, :moved => moved.id, :target => target.id, :position => 'after'

    assert_response :success
    assert moved.reload.display_order > target.reload.display_order
  end

  def test_科目を別の科目の中に移動
    assert parent = Account.find_by_code(ACCOUNT_CODE_SALES_AND_GENERAL_ADMINISTRATIVE_EXPENSE)
    assert moved = Account.where(:parent_id => parent.id).not_deleted.last
    assert target = Account.where(:parent_id => parent.id).not_deleted.first
    
    post :update_tree, :moved => moved.id, :target => target.id, :position => 'inside'

    assert_response :success
    assert_equal target.id, moved.reload.parent_id
  end

  def test_補助科目を追加
    get :add_sub_account
    
    assert_response :success
    assert_template '_sub_account_fields'
  end

end
