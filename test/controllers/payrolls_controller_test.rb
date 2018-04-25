require 'test_helper'

class PayrollsControllerTest < ActionController::TestCase

  def test_個人事業主は利用不可
    sign_in freelancer
    get :index
    assert_response :forbidden
  end

  def test_一覧
    sign_in user
    get :index
    assert_response :success
    assert_template 'index'

    get :index, :params =>  {:commit => "表示", :finder => {:fiscal_year => 2009, :branch_id => 2, :employee_id => 2}}
    assert_response :success
    assert_template 'index'
  end

  def test_追加
    sign_in user
    get :new, :params => {ym: 200904, employee_id: 2}, :xhr => true
    assert_response :success
    assert_template 'new'
  end

  def test_登録
    sign_in user
    post :create, :params => {:payroll => payroll_params.merge(ym: 200904)}, :xhr => true
    assert assigns(:payroll).errors.empty?
    assert_response :success
    assert_template 'common/reload'
  end

  def test_編集
    sign_in user

    finder = PayrollFinder.new(current_user)
    finder.fiscal_year = 2009
    finder.employee_id = 2
    @request.session[PayrollFinder] = finder

    get :edit, :params => {:id => 45}, :xhr => true
    assert_response :success
    assert_template 'edit'

    # 所得税
    assert_equal JournalDetail.find(11581).amount, assigns(:payroll).income_tax
    # 住民税
    assert_equal JournalDetail.find(11582).amount, assigns(:payroll).inhabitant_tax
  end

  # 前月の情報取得
  def test_should_get_new_pre_month
    sign_in user

    get :new, :params => {ym: 200811, employee_id: 1}, :xhr => true

    assert_response :success
    assert_template 'new'
    assert_equal JournalDetail.find(17735).amount, assigns(:payroll).base_salary
    assert_equal 8100, assigns(:payroll).inhabitant_tax
  end

  def test_should_get_create_deposits_received
    sign_in user

    finder = PayrollFinder.new(current_user)
    finder.fiscal_year = 2009
    finder.employee_id = 2
    @request.session[PayrollFinder] = finder

    ym = 200902
    employee_id = 2
    post :create, :xhr => true, :params => {
        :payroll => {:ym => ym, :employee_id => employee_id,
                      :days_of_work => 28, :hours_of_work => 224,
                      :hours_of_day_off_work => 100, :hours_of_early_work => 101,
                      :hours_of_late_night_work => 102, :base_salary => '394000',
                      :health_insurance => '10000', :welfare_pension => '20000',
                      :income_tax => '1000', :inhabitant_tax => '8400',
                      :accrued_liability => '120000', :pay_day => '2009-03-06',
                      :credit_account_type_of_inhabitant_tax => Payroll::CREDIT_ACCOUNT_TYPE_DEPOSITS_RECEIVED}
                      }
    assert_response :success
    assert assigns(:payroll).errors.empty?, assigns(:payroll).errors.full_messages.join("\n")
    assert_template 'common/reload'

    # 登録された仕訳をチェック
    pr = Payroll.find_by_ym_and_employee_id(ym, employee_id)
    assert_equal Payroll::CREDIT_ACCOUNT_TYPE_DEPOSITS_RECEIVED, pr.credit_account_type_of_inhabitant_tax
    deposits_received = Account.find_by_code(ACCOUNT_CODE_DEPOSITS_RECEIVED)
    income_tax = deposits_received.get_sub_account_by_code(SUB_ACCOUNT_CODE_INCOME_TAX)
    health_insurance = deposits_received.get_sub_account_by_code(SUB_ACCOUNT_CODE_HEALTH_INSURANCE)
    welfare_pension = deposits_received.get_sub_account_by_code(SUB_ACCOUNT_CODE_WELFARE_PENSION)
    inhabitant_tax = deposits_received.get_sub_account_by_code(SUB_ACCOUNT_CODE_INHABITANT_TAX)
    jd = JournalDetail.where(journal_header_id: pr.payroll_journal_header_id, account_id: deposits_received.id, sub_account_id: income_tax.id)
    assert_equal 1, jd.count
    jd = JournalDetail.where(journal_header_id: pr.payroll_journal_header_id, account_id: deposits_received.id, sub_account_id: health_insurance.id)
    assert_equal 1, jd.count
    jd = JournalDetail.where(journal_header_id: pr.payroll_journal_header_id, account_id: deposits_received.id, sub_account_id: welfare_pension.id)
    assert_equal 1, jd.count
    jd = JournalDetail.where(journal_header_id: pr.payroll_journal_header_id, account_id: deposits_received.id, sub_account_id: inhabitant_tax.id)
    assert_equal 1, jd.count
  end

  def test_should_get_create_advance_money_for_inhabitant_tax
    sign_in user

    finder = PayrollFinder.new(current_user)
    finder.fiscal_year = 2009
    finder.employee_id = 2
    @request.session[PayrollFinder] = finder

    ym = 200904
    employee_id = 2
    post :create, params: {payroll: payroll_params(ym: ym, employee_id: employee_id)}, xhr: true
    assert_response :success
    assert assigns(:payroll).errors.empty?
    assert_template 'common/reload'

    # 登録された仕訳をチェック
    pr = Payroll.find_by_ym_and_employee_id(ym, employee_id)
    assert_equal Payroll::CREDIT_ACCOUNT_TYPE_ADVANCE_MONEY, pr.credit_account_type_of_inhabitant_tax
    advance_money = Account.find_by_code(ACCOUNT_CODE_ADVANCE_MONEY)
    deposits_received = Account.find_by_code(ACCOUNT_CODE_DEPOSITS_RECEIVED)
    temp_pay_tax = Account.find_by_code(ACCOUNT_CODE_TEMP_PAY_TAX)
    income_tax = deposits_received.get_sub_account_by_code(SUB_ACCOUNT_CODE_INCOME_TAX)
    health_insurance = deposits_received.get_sub_account_by_code(SUB_ACCOUNT_CODE_HEALTH_INSURANCE)
    welfare_pension = deposits_received.get_sub_account_by_code(SUB_ACCOUNT_CODE_WELFARE_PENSION)
    inhabitant_tax = advance_money.get_sub_account_by_code(SUB_ACCOUNT_CODE_INHABITANT_TAX)

    jd = JournalDetail.where("journal_header_id=? and account_id=? and sub_account_id=?",
            pr.payroll_journal_header_id, deposits_received.id, income_tax.id)
    assert_equal 1, jd.count

    jd = JournalDetail.where("journal_header_id=? and account_id=? and sub_account_id=?",
            pr.payroll_journal_header_id, deposits_received.id, health_insurance.id)
    assert_equal 1, jd.count

    jd = JournalDetail.where("journal_header_id=? and account_id=? and sub_account_id=?",
              pr.payroll_journal_header_id, deposits_received.id, welfare_pension.id)
    assert_equal 1, jd.count

    jd = JournalDetail.where("journal_header_id=? and account_id=? and sub_account_id=?",
              pr.payroll_journal_header_id, advance_money.id, inhabitant_tax.id)
    assert_equal 1, jd.count

    # 仮払消費税として登録されていること
    jd = JournalDetail.where("journal_header_id=? and account_id=?", pr.commission_journal_header_id, temp_pay_tax.id)
    assert_equal 1, jd.count
    assert_equal 25, jd[0].amount
  end

  def test_should_get_create_with_errors
    sign_in user

    finder = PayrollFinder.new(current_user)
    finder.fiscal_year = 2009
    finder.employee_id = 2
    @request.session[PayrollFinder] = finder

    post :create, :xhr => true, :params => {
        :payroll => {:ym => 200902, :employee_id => 2,
                     :days_of_work => 28, :hours_of_work => 224,
                     :hours_of_day_off_work => 100, :hours_of_early_work => 101,
                     :hours_of_late_night_work => 102, :base_salary => '',
                     :health_insurance => '', :welfare_pension => '',
                     :income_tax => '', :inhabitant_tax => '',
                     :accrued_liability => '', :pay_day => '20090332',
                     :credit_account_type_of_inhabitant_tax => Payroll::CREDIT_ACCOUNT_TYPE_ADVANCE_MONEY}
                     }
    assert_response :success
    assert_equal 3, assigns(:payroll).errors.size, assigns(:payroll).errors.full_messages.join("\n")
    assert_template 'new'
  end

  def test_should_get_create_with_errors2
    sign_in user

    finder = PayrollFinder.new(current_user)
    finder.fiscal_year = 2009
    finder.employee_id = 2
    @request.session[PayrollFinder] = finder

    post :create, :xhr => true, :params => {
        :payroll => {:ym => 200912, :employee_id => 2,
                     :days_of_work => 28, :hours_of_work => 224,
                     :hours_of_day_off_work => 100, :hours_of_early_work => 101,
                     :hours_of_late_night_work => 102, :base_salary => '100000a',
                     :health_insurance => '5@000', :welfare_pension => 'x',
                     :income_tax => 'x', :inhabitant_tax => 'x',
                     :accrued_liability => 'x', :annual_adjustment=>'x',
                     :pay_day => 'x',
                     :credit_account_type_of_inhabitant_tax => Payroll::CREDIT_ACCOUNT_TYPE_ADVANCE_MONEY}
                     }
    assert_response :success
    assert assigns(:payroll).errors[:inhabitant_tax].any?, assigns(:payroll).errors.full_messages.join("\n")
    assert_template 'new'
  end

  def test_更新
    sign_in user
    patch :update, :params => {:id => payroll.id, :payroll => payroll_params}, :xhr => true
    assert assigns(:payroll).errors.empty?
    assert_response :success
    assert_template 'common/reload'
  end

  def test_get_branch_employees
    sign_in user
    get :index
    get :get_branch_employees, :xhr => true, :params => {
          :finder => {:branch_id => current_company.branches.first.id}
          }
    assert_response :success
    assert_template 'payrolls/_get_branch_employees'
  end

  def test_should_get_auto_calc
    sign_in user

    finder = PayrollFinder.new(current_user)
    finder.fiscal_year = 2009
    finder.employee_id = 2
    @request.session[PayrollFinder] = finder

    post :auto_calc, :params => {:payroll => {:ym => 200904, :employee_id => 2, :base_salary => 394000}}, :xhr => true

    assert_response :success
    assert json = ActiveSupport::JSON.decode(response.body)
    assert json.has_key?('health_insurance')
    assert json.has_key?('welfare_pension')
    assert json.has_key?('employment_insurance')
    assert json.has_key?('income_tax')
  end

  def test_should_get_auto_calc_insurance
    sign_in user

    insurances = YAML.load_file(File.join('test', 'data', 'insurances.yml'))

    finder = PayrollFinder.new(current_user)
    finder.fiscal_year = 2008
    finder.employee_id = 1
    @request.session[PayrollFinder] = finder

    get :auto_calc, :params => {:payroll => {:ym => 200811, :employee_id => 1, :base_salary => 424000 }}, :xhr => true

    assert_response :success
    assert json = ActiveSupport::JSON.decode(response.body)
    assert_equal insurances['insurance_00120']['health_insurance_half'], json['health_insurance']
  end

  def test_削除
    sign_in user

    @payroll = payroll
    assert @payroll.payroll_journal_header.present?
    assert @payroll.pay_journal_header.present?

    assert_difference 'Payroll.count', -1 do
      delete :destroy, :params => {:id => payroll}, :xhr => true
      assert_response :success
      assert_template 'common/reload'
    end

    assert Journal.where(:id => [@payroll.payroll_journal_header_id, @payroll.pay_journal_header_id]).empty?
  end

end
