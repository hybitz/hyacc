# coding: UTF-8
#
# $Id: accounts_controller_test.rb 3165 2014-01-01 11:37:37Z ichy $
# Product: hyacc
# Copyright 2009-2014 by Hybitz.co.ltd
# ALL Rights Reserved.
#
require 'test_helper'

class AccountsControllerTest < ActionController::TestCase

  def setup
    @first_id = Account.find(28).id
    @request.session[:user_id] = users(:first).id
  end

  def test_index
    get :index

    assert_response :success
    assert_template 'index'
    assert_nil assigns(:accounts)
  end

  def test_index
    get :index,
      :finder=>{
        :account_type=>ACCOUNT_TYPE_ASSET,
      }

    assert_response :success
    assert_template 'index'
    assert_not_nil assigns(:accounts)
  end
  
  def test_list_tree
    get :list_tree
    assert_response :success
    assert_template :list_tree
    assert_not_nil assigns(:accounts)
  end

  def test_show
    get :show, :id => @first_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:account)
    assert assigns(:account).valid?
  end

  def test_new
    get :new, :parent_id=>@first_id

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:account)
  end

  def test_new_fail_by_missing_parent_id
    assert_raise( ActiveRecord::RecordNotFound ){ get :new }
  end

  def test_create
    num_accounts = Account.count

    post :create, :account => { :code=>'9999', :name=>'test', :dc_type=>1, :account_type=>1, :tax_type=>1 }

    assert_response :redirect
    assert_redirected_to :action=>:show, :id=>Account.maximum(:id)

    assert_equal num_accounts + 1, Account.count
  end

  def test_edit
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'
    assert_not_nil assigns(:account)
    assert assigns(:account).valid?
  end

  test "削除状態（停止状態）でも編集画面に遷移できること" do
    Account.find( @first_id ).update_attribute(:deleted, true)

    get :edit, :id => @first_id
    
    assert_response :success
    assert_template 'edit'
    assert_not_nil assigns(:account)
  end

  def test_update
    post :update, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => @first_id
  end
  
  
  def test_update_fail_duplicate_code
    a = Account.find(@first_id)
    post :update, :id => @first_id, :commit => '更新',
                  :account => {:name=>a.name,:sub_account_type=>a.sub_account_type,
                               :account_type=>a.account_type, :tax_type=>a.tax_type,
                               :dc_type=>a.dc_type,:parent_id=>a.parent_id,
                               :trade_type=>a.trade_type},
                  :sub_accounts => {"1"=>{:id=>'28',:name=>'補助科目１',:code=>'100',:deleted=>'false'},
                                    "2"=>{:id=>'29',:name=>'補助科目２',:code=>'200',:deleted=>'false'},
                                    "3"=>{:id=>'30',:name=>'補助科目３',:code=>'200',:deleted=>'false'}}
    
    assert_response :success
    assert_template 'edit'
    assert_nil assigns(:notice)
  end

  test 'test_補助科目変更不可の勘定科目で、補助科目区分が変更できないこと' do
    id = 65;
    a = Account.find(id)
    assert_equal SUB_ACCOUNT_TYPE_CORPORATE_TAX, a.sub_account_type
    assert ! a.account_control.sub_account_editable
    
    post :update, :id => id, :commit => '更新',
                  :account => {:sub_account_type=>SUB_ACCOUNT_TYPE_NORMAL},
                  :sub_accounts => {"1"=>{:id=>28,:name=>'補助科目１',:code=>'100',:deleted=>'false'},
                                    "2"=>{:id=>29,:name=>'補助科目２',:code=>'200',:deleted=>'false'},
                                    "3"=>{:id=>30,:name=>'補助科目３',:code=>'300',:deleted=>'false'}}
    
    assert_response :success
    assert_template 'edit'
    assert_equal ERR_SUB_ACCOUNT_TYPE_NOT_EDITABLE, flash[:notice]
  end

  def test_destroy
    assert_nothing_raised {
      Account.find(@first_id)
    }

    post :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'index'

    assert  Account.find(@first_id).deleted
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
    assert ! account.account_control.system_required
    assert_raise( HyaccException ){
      post :destroy, :id=>account
    }
  end
  
  # 伝票が存在しない場合、補助科目がすべて削除可能であること
  def test_delete_all_sub_accounts
    # まずは新規作成
    post :create, 
      :commit=>"登録", 
      :account=>{
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
      :sub_accounts=>{
        "1"=>{
          :code=>"100",
          :name=>"テスト補助科目",
          :id=>"",
          :deleted=>"false"
        }
      }
    assert_response :redirect
    assert_redirected_to :action=>:show, :id=>Account.maximum(:id)
    assert_equal 1, Account.find_by_code(6666).sub_accounts_all.size()
    
    # 補助科目なしで更新
    post :update, 
      :commit=>"更新", 
      :id => Account.find_by_code(6666),
      :account=>{
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
      :sub_accounts=>{
      }
    assert_response :redirect
    assert_redirected_to :action=>:show, :id=>Account.find_by_code(6666).id
    assert_equal 0, Account.find_by_code(6666).sub_accounts_all.size()
  end
end
