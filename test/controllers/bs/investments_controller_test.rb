require 'test_helper'

class Bs::InvestmentsControllerTest < ActionController::TestCase
  
  def setup
    sign_in user
  end

  def test_relateで証券口座と投資目的がロックされる
    jh = Journal.find(200)
    get :relate, xhr: true, params: { journal_id: jh.id, format: :js }
    assert_response :success
    related = assigns(:investment)
    assert related.linked_to_transfer_slip?
    assert_equal BankAccount.find(3).id, related.bank_account_id
    doc = Nokogiri::HTML.parse(extract_dialog_html(response.body))
    # disabledはフォーム送信されないため、hiddenで値が送れることまで担保する
    assert_select doc, 'select[name="investment[bank_account_id]"][disabled]'
    assert_select doc, "input[type=\"hidden\"][name=\"investment[bank_account_id]\"][value=\"#{BankAccount.find(3).id}\"]", 1

    assert_select doc, 'input[type="radio"][name="investment[buying_or_selling]"][disabled]', 2
    assert_select doc, "input[type=\"hidden\"][name=\"investment[buying_or_selling]\"][value=\"1\"]", 1

    assert_select doc, 'input[type="radio"][name="investment[for_what]"][disabled]', 2
    assert_select doc, "input[type=\"hidden\"][name=\"investment[for_what]\"][value=\"#{HyaccConst::SECURITIES_TYPE_FOR_TRADING}\"]", 1

    # 関連付け先の伝票IDが送信されること
    assert_select doc, "input[type=\"hidden\"][name=\"investment[journal_id]\"][value=\"#{jh.id}\"]", 1

    # readonlyでロックされる項目（値は送信されるが編集できない）
    assert_select doc, 'input[name="investment[yyyymmdd]"][readonly].readonly-as-disabled', 1
    assert_select doc, 'input[name="investment[trading_value]"][readonly].readonly-as-disabled', 1
    assert_select doc, 'input[name="investment[gains]"][readonly].readonly-as-disabled', 1
    assert_select doc, 'input[name="investment[charges]"][readonly].readonly-as-disabled', 1
  end

  def test_relate経由で振替伝票の値を引き継いで投資先と株数を追加して保存できる
    jh = Journal.find(200)
    get :relate, xhr: true, params: { journal_id: jh.id }
    related = assigns(:investment)
    expected_yyyymmdd = jh.ym.to_s.insert(4, '-') + '-' + "%02d" % jh.day.to_s
    expected_bank_account_id = BankAccount.find(3).id
    assert_difference('Investment.count', 1) do
      post :create, xhr: true, params: {
        investment: {
          yyyymmdd: related.yyyymmdd, bank_account_id: related.bank_account_id, customer_id: '1',
          buying_or_selling: related.buying_or_selling, for_what: related.for_what, shares: '10',
          trading_value: related.trading_value, charges: related.charges || 0, journal_id: jh.id
        }
      }
    end
    assert_response :success
    investment = Investment.order(:id).last
    jh.reload
    assert_equal investment.id, jh.investment_id

    # 振替伝票（既存伝票）から引き継ぐ値が正しいこと
    assert_equal expected_yyyymmdd, related.yyyymmdd
    assert_equal expected_yyyymmdd, investment.yyyymmdd
    assert_equal jh.ym, investment.ym
    assert_equal jh.day, investment.day

    assert_equal expected_bank_account_id, related.bank_account_id
    assert_equal expected_bank_account_id, investment.bank_account_id

    assert_equal '1', related.buying_or_selling
    assert_equal '1', investment.buying_or_selling
    assert investment.buying?

    assert_equal SECURITIES_TYPE_FOR_TRADING, related.for_what
    assert_equal SECURITIES_TYPE_FOR_TRADING, investment.for_what

    assert_equal 50_000, related.trading_value
    assert_equal 50_000, investment.trading_value
    assert_equal 0, investment.charges
    assert_equal 0, investment.gains

    # 有価証券で新たに追加する情報が正しく登録されること
    assert_equal 1, investment.customer_id
    assert_equal 10, investment.shares

    # 既存の振替伝票と紐付いていること（自動仕訳伝票ではない）
    assert_equal jh.id, investment.journal.id
    assert_equal SLIP_TYPE_TRANSFER, jh.slip_type
  end

  def test_振替伝票に紐づく有価証券を削除すると伝票は残り未関連に戻る
    jh = Journal.find(200) # test/data/journals.csv
    get :relate, xhr: true, params: { journal_id: jh.id }
    related = assigns(:investment)
    post :create, xhr: true, params: {
      investment: {
        yyyymmdd: related.yyyymmdd, bank_account_id: related.bank_account_id, customer_id: '1',
        buying_or_selling: related.buying_or_selling, for_what: related.for_what, shares: '10',
        trading_value: related.trading_value, charges: related.charges || 0, journal_id: jh.id
      }
    }
    assert_response :success
    investment = Investment.order(:id).last
    journal_id = jh.id
    delete :destroy, params: { id: investment.id }
    assert_redirected_to action: :index
    assert_nil Investment.find_by(id: investment.id)
    jh_after = Journal.find_by(id: journal_id)
    assert jh_after.present? && jh_after.investment_id.nil?
    get :not_related
    assert_includes assigns(:journals).map(&:id), journal_id
  end

  def test_削除で3階層が連鎖して物理削除される
    post :create, xhr: true, params: {
      investment: { yyyymmdd: '2016-03-27', bank_account_id: bank_account.id, customer_id: '1', buying_or_selling: '1', for_what: '1', shares: '20', trading_value: '100000', charges: '0' }
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
        investment: { yyyymmdd: '2016-03-27', bank_account_id: bank_account.id, customer_id: '1', buying_or_selling: '1', for_what: '1', shares: '20', trading_value: '100000', charges: '0' }
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
        investment: { yyyymmdd: '2016-03-27', bank_account_id: bank_account.id, customer_id: '1', buying_or_selling: '0', for_what: '1', shares: '20', trading_value: '100000', charges: '0', gains: '0' }
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

  def test_追加
    get :new, xhr: true
    assert_response :success
  end

  def test_手数料が0円でも追加と更新ができること
    params = { yyyymmdd: '2016-03-27', bank_account_id: bank_account.id, customer_id: '1', buying_or_selling: '1', for_what: '1', shares: '20', trading_value: '100000', charges: '0' }
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

  def test_not_related
    JournalDetail.first.update(account_id: Account.find_by(code: ACCOUNT_CODE_TRADING_SECURITIES).id)
    get :not_related
    assert_response :success
  end

  def test_更新_エラー
    assert_no_difference('Investment.count') do
      patch :update, xhr: true, params: {
        investment: { yyyymmdd: '2015-03-27', bank_account_id: '3', customer_id: '1', buying_or_selling: '1', for_what: '1', shares: '0', trading_value: '240000', charges: '0' },
        id: 1
      }
      assert_response :success
      assert_template 'edit'
    end
  end

  private

  def extract_dialog_html(js)
    raw = js.match(/\.show\('(?<html>.*)'\);/m)&.[]('html')
    assert raw.present?
    raw = raw.gsub(/\\u([0-9a-fA-F]{4})/) { [$1.to_i(16)].pack('U') }
    raw = raw
      .gsub('\\n', "\n")
      .gsub("\\'", "'")
      .gsub('\\"', '"')
      .gsub('\\\\', '\\')
    raw.gsub('<\/script>', '</script>').gsub('<\/', '</')
  end

end
