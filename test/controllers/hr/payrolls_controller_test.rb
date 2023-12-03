require 'test_helper'

class Hr::PayrollsControllerTest < ActionController::TestCase

  def test_一覧
    sign_in admin
    get :index
    assert_response :success
    assert_template 'index'

    get :index, params: {commit: "表示", finder: {fiscal_year: 2009, branch_id: 2, employee_id: 2}}
    assert_response :success
    assert_template 'index'
  end

  def test_追加
    sign_in admin
    get :new, xhr: true, params: {ym: 200904, employee_id: 2}
    assert_response :success
    assert_template 'new'
  end

  def test_登録
    sign_in admin
    post :create, params: {payroll: payroll_params.merge(ym: 200904)}, xhr: true
    assert assigns(:payroll).errors.empty?
    assert_response :success
    assert_template 'common/reload'
  end

  def test_編集
    sign_in admin

    finder = PayrollFinder.new(current_user)
    finder.fiscal_year = 2009
    finder.employee_id = 2
    @request.session[PayrollFinder] = finder

    get :edit, params: {id: 45}, xhr: true
    assert_response :success
    assert_template 'edit'
  end

  # 前月の情報取得
  def test_should_get_new_pre_month
    sign_in admin

    get :new, params: {ym: 200811, employee_id: 1}, xhr: true

    assert_response :success
    assert_template 'new'
    assert_equal JournalDetail.find(17735).amount, assigns(:payroll).base_salary
    assert_equal 8100, assigns(:payroll).inhabitant_tax
  end

  def test_should_get_create_deposits_received
    sign_in admin

    finder = PayrollFinder.new(current_user)
    finder.fiscal_year = 2009
    finder.employee_id = 2
    @request.session[PayrollFinder] = finder

    ym = 200902
    employee_id = 2
    post :create, xhr: true, params: {
        payroll: {
          :ym => ym, :employee_id => employee_id,
          :days_of_work => 28, :hours_of_work => 224,
          :hours_of_day_off_work => 100, :hours_of_early_work => 101,
          :hours_of_late_night_work => 102, :base_salary => '394000',
          :health_insurance => '10000', :welfare_pension => '20000',
          :income_tax => '1000', :inhabitant_tax => '8400',
          :accrued_liability => '120000', :pay_day => '2009-03-06'}
        }
    assert_response :success
    assert assigns(:payroll).errors.empty?, assigns(:payroll).errors.full_messages.join("\n")
    assert_template 'common/reload'

    # 登録された仕訳をチェック
    pr = Payroll.find_by_ym_and_employee_id(ym, employee_id)
    deposits_received = Account.find_by_code(ACCOUNT_CODE_DEPOSITS_RECEIVED)
    income_tax = deposits_received.get_sub_account_by_code(SUB_ACCOUNT_CODE_INCOME_TAX)
    health_insurance = deposits_received.get_sub_account_by_code(SUB_ACCOUNT_CODE_HEALTH_INSURANCE)
    welfare_pension = deposits_received.get_sub_account_by_code(SUB_ACCOUNT_CODE_WELFARE_PENSION)
    inhabitant_tax = deposits_received.get_sub_account_by_code(SUB_ACCOUNT_CODE_INHABITANT_TAX)
    jd = JournalDetail.where(journal_id: pr.payroll_journal.id, account_id: deposits_received.id, sub_account_id: income_tax.id)
    assert_equal 1, jd.count
    jd = JournalDetail.where(journal_id: pr.payroll_journal.id, account_id: deposits_received.id, sub_account_id: health_insurance.id)
    assert_equal 1, jd.count
    jd = JournalDetail.where(journal_id: pr.payroll_journal.id, account_id: deposits_received.id, sub_account_id: welfare_pension.id)
    assert_equal 1, jd.count
    jd = JournalDetail.where(journal_id: pr.payroll_journal.id, account_id: deposits_received.id, sub_account_id: inhabitant_tax.id)
    assert_equal 1, jd.count
  end

  def test_inhabitant_tax
    sign_in admin

    finder = PayrollFinder.new(current_user)
    finder.fiscal_year = 2009
    finder.employee_id = 2
    @request.session[PayrollFinder] = finder

    ym = 200904
    employee_id = 2
    post :create, xhr: true, params: {
        payroll: payroll_params(ym: ym, employee_id: employee_id, accrued_liability: 0)
      }
    assert_response :success
    assert_template 'common/reload'
    assert @payroll = assigns(:payroll) 
    assert @payroll.errors.empty?

    # 登録された仕訳をチェック
    pr = Payroll.find(@payroll.id)
    deposits_received = Account.find_by_code(ACCOUNT_CODE_DEPOSITS_RECEIVED)
    temp_pay_tax = Account.find_by_code(ACCOUNT_CODE_TEMP_PAY_TAX)
    income_tax = deposits_received.get_sub_account_by_code(SUB_ACCOUNT_CODE_INCOME_TAX)
    health_insurance = deposits_received.get_sub_account_by_code(SUB_ACCOUNT_CODE_HEALTH_INSURANCE)
    welfare_pension = deposits_received.get_sub_account_by_code(SUB_ACCOUNT_CODE_WELFARE_PENSION)
    inhabitant_tax = deposits_received.get_sub_account_by_code(SUB_ACCOUNT_CODE_INHABITANT_TAX)

    jd = JournalDetail.where("journal_id=? and account_id=? and sub_account_id=?",
            pr.payroll_journal.id, deposits_received.id, income_tax.id)
    assert_equal 1, jd.count

    jd = JournalDetail.where("journal_id=? and account_id=? and sub_account_id=?",
            pr.payroll_journal.id, deposits_received.id, health_insurance.id)
    assert_equal 1, jd.count

    jd = JournalDetail.where("journal_id=? and account_id=? and sub_account_id=?",
              pr.payroll_journal.id, deposits_received.id, welfare_pension.id)
    assert_equal 1, jd.count

    jd = JournalDetail.where("journal_id=? and account_id=? and sub_account_id=?",
              pr.payroll_journal.id, deposits_received.id, inhabitant_tax.id)
    assert_equal 1, jd.count

    # 仮払消費税として登録されていること
    jd = JournalDetail.where("journal_id=? and account_id=?", pr.commission_journal.id, temp_pay_tax.id)
    assert_equal 1, jd.count
    assert_equal 25, jd[0].amount, jd[0].attributes.to_yaml
  end

  def test_should_get_create_with_errors
    sign_in admin

    finder = PayrollFinder.new(current_user)
    finder.fiscal_year = 2009
    finder.employee_id = 2
    @request.session[PayrollFinder] = finder

    post :create, xhr: true, params: {
        payroll: {:ym => 200902, :employee_id => 2,
                  :days_of_work => 28, :hours_of_work => 224,
                  :hours_of_day_off_work => 100, :hours_of_early_work => 101,
                  :hours_of_late_night_work => 102, :base_salary => '',
                  :health_insurance => '', :welfare_pension => '',
                  :income_tax => '', :inhabitant_tax => '',
                  :accrued_liability => '', :pay_day => '20090332'}
        }
    assert_response :success
    assert_equal 7, assigns(:payroll).errors.size, assigns(:payroll).errors.full_messages.join("\n")
    assert_template 'new'
  end

  def test_should_get_create_with_errors2
    sign_in admin

    finder = PayrollFinder.new(current_user)
    finder.fiscal_year = 2009
    finder.employee_id = 2
    @request.session[PayrollFinder] = finder

    post :create, :xhr => true, :params => {
        :payroll => {:ym => 200912, :employee_id => 2,
                     :days_of_work => 28, :hours_of_work => 224,
                     :hours_of_day_off_work => 100, :hours_of_early_work => 101,
                     :hours_of_late_night_work => 102, :base_salary => '100000',
                     :health_insurance => '50000', :welfare_pension => '0',
                     :income_tax => '0',
                     :inhabitant_tax => 'x',
                     :accrued_liability => '0', :annual_adjustment=>'0',
                     :pay_day => '2010-01-25'}
        }
    assert_response :success
    assert assigns(:payroll).errors[:inhabitant_tax].any?, assigns(:payroll).errors.full_messages.join("\n")
    assert_template 'new'
  end

  def test_更新
    sign_in admin
    patch :update, xhr: true, params: {id: payroll.id, payroll: payroll_params}
    assert assigns(:payroll).errors.empty?
    assert_response :success
    assert_template 'common/reload'
  end

  def test_get_branch_employees
    sign_in admin
    get :get_branch_employees, xhr: true, params: {fiscal_year: current_company.fiscal_year, branch_id: current_company.branches.first.id}
    assert_response :success
    assert_template 'payrolls/_get_branch_employees'
  end

  def test_should_get_auto_calc
    sign_in admin

    finder = PayrollFinder.new(current_user)
    finder.fiscal_year = 2009
    finder.employee_id = 2
    @request.session[PayrollFinder] = finder

    post :auto_calc, params: {payroll: {ym: 200904, employee_id: 2, base_salary: 394000}}, xhr: true

    assert_response :success
    assert json = ActiveSupport::JSON.decode(response.body)
    assert json.has_key?('health_insurance')
    assert json.has_key?('welfare_pension')
    assert json.has_key?('employment_insurance')
    assert json.has_key?('income_tax')
  end

  def test_should_get_auto_calc_insurance
    sign_in admin

    finder = PayrollFinder.new(current_user)
    finder.fiscal_year = 2008
    finder.employee_id = 1
    @request.session[PayrollFinder] = finder

    get :auto_calc, params: {payroll: {ym: 200811, employee_id: 1, base_salary: 424000 }}, xhr: true

    assert_response :success
    assert json = ActiveSupport::JSON.decode(response.body)
    assert_equal 15580, json['health_insurance']
  end

  def test_削除
    sign_in admin

    @payroll = payroll
    assert @payroll.payroll_journal.present?
    assert @payroll.pay_journal.present?

    assert_difference 'Payroll.count', -1 do
      delete :destroy, params: {id: @payroll.id}, xhr: true
      assert_response :success
      assert_template 'common/reload'
    end

    assert Journal.where(payroll_id: @payroll.id).empty?
  end

end
