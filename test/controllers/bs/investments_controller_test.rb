require 'test_helper'

class Bs::InvestmentsControllerTest < ActionController::TestCase
  
  def setup
    sign_in user
  end

  def test_削除で3階層が連鎖して物理削除される
    post :create, xhr: true, params: {
      investment: { yyyymmdd: '2016-03-27', bank_account_id: bank_account.id, customer_id: '1', buying_or_selling: SECURITIES_TRANSACTION_TYPE_BUYING, for_what: '1', shares: '20', trading_value: '100000', charges: '0' }
    }
    assert_response :success
    investment = Investment.order(:id).last
    journal_id = investment.journal.id
    journal_detail_ids = investment.journal.journal_details.pluck(:id)
    delete :destroy, params: { id: investment.id }
    assert_redirected_to action: :index
    assert_nil Investment.find_by(id: investment.id)
    assert_nil Journal.find_by(id: journal_id)
    journal_detail_ids.each { |id| assert_nil JournalDetail.find_by(id: id) }
  end

  def test_新規一括登録で3階層が一度に保存される
    assert_difference(['Investment.count', 'Journal.count']) do
      post :create, xhr: true, params: {
        investment: { yyyymmdd: '2016-03-27', bank_account_id: bank_account.id, customer_id: '1', buying_or_selling: SECURITIES_TRANSACTION_TYPE_BUYING, for_what: '1', shares: '20', trading_value: '100000', charges: '0' }
      }
    end
    assert_response :success
    investment = Investment.order(:id).last
    jh = investment.journal
    assert_equal investment.id, jh.investment_id
    assert_equal SLIP_TYPE_INVESTMENT, jh.slip_type
    assert jh.journal_details.size >= 2
  end

  def test_売却でも自動仕訳を作成できること
    assert_difference(['Investment.count', 'Journal.count']) do
      post :create, xhr: true, params: {
        investment: { yyyymmdd: '2016-03-27', bank_account_id: bank_account.id, customer_id: '1', buying_or_selling: SECURITIES_TRANSACTION_TYPE_SELLING, for_what: '1', shares: '20', trading_value: '100000', charges: '0', gains: '0' }
      }
    end
    assert_response :success
    investment = Investment.order(:id).last
    jh = investment.journal
    assert jh.present?
    assert_equal SLIP_TYPE_INVESTMENT, jh.slip_type

    # 金額は常に正の値（貸借で表現）であること
    assert jh.journal_details.all? { |jd| jd.amount.to_i >= 0 }

    trading_securities_id = Account.find_by_code(ACCOUNT_CODE_TRADING_SECURITIES).id
    deposits_paid_id = Account.find_by_code(ACCOUNT_CODE_DEPOSITS_PAID).id

    securities_detail = jh.journal_details.find { |jd| jd.account_id == trading_securities_id }
    deposits_detail = jh.journal_details.find { |jd| jd.account_id == deposits_paid_id }
    assert securities_detail.present?
    assert deposits_detail.present?

    assert_equal DC_TYPE_CREDIT, securities_detail.dc_type
    assert_equal 100_000, securities_detail.amount

    assert_equal DC_TYPE_DEBIT, deposits_detail.dc_type
    assert_equal 100_000, deposits_detail.amount
  end

  def test_一覧
    get :index
    assert_response :success
  end

  def test_検索
    get :index, params: {finder: {fiscal_year: 2016, bank_account_id: 3}}
    assert_response :success
  end

  def test_追加では購入が初期値で設定される
    get :new, xhr: true
    assert_response :success
    assert_equal SECURITIES_TRANSACTION_TYPE_BUYING, assigns(:investment).buying_or_selling
  end

  def test_手数料が0円でも追加と更新ができること
    params = { yyyymmdd: '2016-03-27', bank_account_id: bank_account.id, customer_id: '1', buying_or_selling: SECURITIES_TRANSACTION_TYPE_BUYING, for_what: '1', shares: '20', trading_value: '100000', charges: '0' }
    assert_difference('Investment.count') do
      post :create, xhr: true, params: { investment: params }
      assert_response :success
      assert_template 'common/reload'
    end
    assert_equal '有価証券情報を追加しました。', flash[:notice]
    assert_no_difference('Investment.count') do
      patch :update, xhr: true, params: { investment: params, id: Investment.last.id }
      assert_response :success
      assert_template 'common/reload'
    end
    assert_equal '有価証券情報を更新しました。', flash[:notice]
  end

  def test_更新_エラー
    assert_no_difference('Investment.count') do
      patch :update, xhr: true, params: {
        investment: { yyyymmdd: '2015-03-27', bank_account_id: '3', customer_id: '1', buying_or_selling: SECURITIES_TRANSACTION_TYPE_BUYING, for_what: '1', shares: '0', trading_value: '240000', charges: '0' },
        id: 1
      }
      assert_response :success
      assert_template 'edit'
    end
  end

end
