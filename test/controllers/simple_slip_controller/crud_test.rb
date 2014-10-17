require 'test_helper'

class SimpleSlipController::CrudTest < ActionController::TestCase
  include HyaccUtil

  setup do
    sign_in user
  end

  def test_Trac_144_売上高の補助科目が受注先である場合に正しく伝票登録できること
    num_journal_headers = JournalHeader.count
    remarks = '売掛金と売上高の伝票' + Time.now.to_s
    
    a = Account.find_by_code(6121)
    assert_equal SUB_ACCOUNT_TYPE_ORDER_ENTRY, a.sub_account_type
    
    sa = Customer.find(3)

    post :create,
      :account_code=>1551,
      :slip => {
        "my_sub_account_id"=>sa.id,
        "ym"=>200909,
        "day"=>29,
        "remarks"=>remarks,
        "branch_id"=>2,
        "account_id"=>a.id,
        "sub_account_id"=>sa.id,
        "amount_increase" => 1000000,
        :tax_type => TAX_TYPE_NONTAXABLE}

    assert_response :redirect
    assert_redirected_to :action=>:index
    assert_equal num_journal_headers + 1, JournalHeader.count
    
    jh = JournalHeader.find_by_remarks(remarks)
    assert_equal 2, jh.journal_details.size
    
    jd = jh.journal_details[0]
    assert_equal 6, jd.account_id
    assert_equal Account.find_by_code(1551).name, jd.account_name
    assert_equal sa.id, jd.sub_account_id
    assert_equal sa.name, jd.sub_account_name
    
    jd = jh.journal_details[1]
    assert_equal a.id, jd.account_id
    assert_equal a.name, jd.account_name
    assert_equal sa.id, jd.sub_account_id
    assert_equal sa.name, jd.sub_account_name
  end
  
  # コピー元伝票のJSONフォーマットが正常に取得できること
  def test_new_from_copy_success
    base_id = 6471
    xhr :get, :new_from_copy, :account_code => 1121, :id => base_id
    assert_response :success
    assert_not_nil assigns[:json]
    
    result = JSON.parse(assigns[:json])
    jd = JournalDetail.find(19597)
    assert_equal JournalHeader.find(jd.journal_header_id).remarks, result['remarks']
    assert_equal jd.account_id.to_s, result['account_id']
    assert_equal jd.sub_account_id.to_s, result['sub_account_id']
    assert_equal jd.tax_type.to_s, result['tax_type']
  end
  
  def test_更新時に登録ユーザが更新されていないこと
    user = User.find(2)
    sign_in user

    finder = Slips::SlipFinder.new(user)
    finder.account_code = Account.get(2).code # 現金
    slip = finder.find(11)
    assert_equal 1, slip.journal_header.create_user_id
    assert_equal 1, slip.asset_id
    assert_equal '100', slip.asset_code
    assert_equal 0, slip.asset_lock_version
    
    xhr :patch, :update, :account_code => finder.account_code,
      :slip => {
        "id"=>slip.id,
        "ym"=>slip.ym,
        "day"=>slip.day,
        "remarks"=>"更新時に登録ユーザが更新されていないこと",
        "branch_id"=>slip.branch_id,
        "account_id"=>slip.account_id,
        "sub_account_id"=>slip.sub_account_id,
        "amount_increase"=>slip.amount_increase,
        "amount_decrease"=>slip.amount_decrease,
        :tax_type => TAX_TYPE_NONTAXABLE,
        "lock_version"=>slip.lock_version,
        "auto_journal_type"=>0,
        "asset_id"=>slip.asset_id,
        "asset_code"=>slip.asset_code,
        "asset_lock_version"=>slip.asset_lock_version,
      }
    
    assert_response :success
    assert_template 'common/reload'
    assert_equal '伝票を更新しました。', flash[:notice]
    
    jh = JournalHeader.find(11)
    assert_equal 1, jh.create_user_id
    assert_equal 2, jh.update_user_id
  end
  
  def test_new
    get :index, :account_code=>1121
    assert_response :success
    assert_template :list
    assert_not_nil assigns(:slip)
    assert_not_nil assigns(:frequencies)
    assert_equal 32, assigns(:frequencies)[0].input_value.to_i
  end
  
  def test_edit
    get :edit, :account_code => 1121, :id => 10, :format => 'js'
    assert_response :success
    assert_template :edit
    assert_not_nil assigns(:slip)
    assert_not_nil assigns(:frequencies)
    assert_equal 32, assigns(:frequencies)[0].input_value.to_i
  end
end
