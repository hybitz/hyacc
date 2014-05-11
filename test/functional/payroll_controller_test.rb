require 'test_helper'

class PayrollControllerTest < ActionController::TestCase
  include HyaccConstants
    
  setup do
    sign_in user
  end
  
  def test_一覧
    get :index
    assert_response :success
    assert_template 'index'
    get :index, :commit => "表示", :finder => {:fiscal_year => 2009, :branch_id => 2, :employee_id => 2}
    assert_response :success
    assert_template 'index'
  end
  
  def test_should_get_new
    finder = PayrollFinder.new(User.find(session[:user_id]))
    finder.fiscal_year = 2009
    finder.employee_id = 2
    @request.session[PayrollFinder] = finder

    get :new, :ym => 200904, :format => 'js'
    assert_response :success
    assert_template 'new'
  end
  
  # 編集画面表示
  def test_should_get_edit
    finder = PayrollFinder.new(User.find(session[:user_id]))
    finder.fiscal_year = 2009
    finder.employee_id = 2
    @request.session[PayrollFinder] = finder

    get :edit, :ym => 200812, :employee_id => 2, :format => 'js'
    assert_response :success
    assert_template 'edit'
    # 基本給
    assert_equal JournalDetail.find(11578).amount, assigns(:payroll).base_salary
    # 健康保険料
    assert_equal JournalDetail.find(11583).amount, assigns(:payroll).insurance
    # 厚生年金保険料
    assert_equal JournalDetail.find(11573).amount, assigns(:payroll).pension
    # 所得税
    assert_equal JournalDetail.find(11581).amount, assigns(:payroll).income_tax
    # 住民税
    assert_equal JournalDetail.find(11582).amount, assigns(:payroll).inhabitant_tax
    # 年末調整額（過払分）
    assert_equal JournalDetail.find(11574).amount, assigns(:payroll).year_end_adjustment_liability
  end
  
  
  # 前月の情報取得
  def test_should_get_new_pre_month
    finder = PayrollFinder.new(User.find(session[:user_id]))
    finder.fiscal_year = 2010
    finder.employee_id = 1
    @request.session[PayrollFinder] = finder

    get :new, :ym => 200811, :format => 'js'
    assert_response :success
    assert_template 'new'
    assert_equal JournalDetail.find(17735).amount, assigns(:payroll).base_salary
    assert_equal 8100, assigns(:payroll).inhabitant_tax
  end
  
  def test_should_get_create_deposits_received
    finder = PayrollFinder.new(current_user)
    finder.fiscal_year = 2009
    finder.employee_id = 2
    @request.session[PayrollFinder] = finder

    ym = 200902
    employee_id = 2
    xhr :post, :create,
        :payroll => {:ym => ym, :employee_id => employee_id,
                      :days_of_work => 28, :hours_of_work => 224,
                      :hours_of_day_off_work => 100, :hours_of_early_for_work => 101,
                      :hours_of_late_night_work => 102, :base_salary => '394000',
                      :insurance => '10000', :pension => '20000',
                      :income_tax => '1000', :inhabitant_tax => '8400',
                      :accrued_liability => '120000', :pay_day => '2009-03-06',
                      :credit_account_type_of_income_tax => Payroll::CREDIT_ACCOUNT_TYPE_DEPOSITS_RECEIVED,
                      :credit_account_type_of_insurance => Payroll::CREDIT_ACCOUNT_TYPE_DEPOSITS_RECEIVED,
                      :credit_account_type_of_pension => Payroll::CREDIT_ACCOUNT_TYPE_DEPOSITS_RECEIVED,
                      :credit_account_type_of_inhabitant_tax => Payroll::CREDIT_ACCOUNT_TYPE_DEPOSITS_RECEIVED}
    assert_response :success
    assert assigns(:payroll).errors.size == 0
    assert_template 'common/_reload_dialog'

    # 登録された仕訳をチェック
    pr = Payroll.find_by_ym_and_employee_id(ym, employee_id)
    assert_equal Payroll::CREDIT_ACCOUNT_TYPE_DEPOSITS_RECEIVED, pr.credit_account_type_of_income_tax
    assert_equal Payroll::CREDIT_ACCOUNT_TYPE_DEPOSITS_RECEIVED, pr.credit_account_type_of_insurance
    assert_equal Payroll::CREDIT_ACCOUNT_TYPE_DEPOSITS_RECEIVED, pr.credit_account_type_of_pension
    assert_equal Payroll::CREDIT_ACCOUNT_TYPE_DEPOSITS_RECEIVED, pr.credit_account_type_of_inhabitant_tax
    deposits_received = Account.get_by_code(ACCOUNT_CODE_DEPOSITS_RECEIVED)
    income_tax = deposits_received.get_sub_account_by_code(SUB_ACCOUNT_CODE_INCOME_TAX_OF_DEPOSITS_RECEIVED)
    insurance = deposits_received.get_sub_account_by_code(SUB_ACCOUNT_CODE_HEALTH_INSURANCE_OF_DEPOSITS_RECEIVED)
    pension = deposits_received.get_sub_account_by_code(SUB_ACCOUNT_CODE_EMPLOYEES_PENSION_OF_DEPOSITS_RECEIVED)
    inhabitant_tax = deposits_received.get_sub_account_by_code(SUB_ACCOUNT_CODE_INHABITANT_TAX_OF_DEPOSITS_RECEIVED)
    jd = JournalDetail.find(:all, :conditions=>["journal_header_id=? and account_id=? and sub_account_id=?",
                                            pr.payroll_journal_header_id, deposits_received.id, income_tax.id])
    assert_equal 1, jd.length
    jd = JournalDetail.find(:all, :conditions=>["journal_header_id=? and account_id=? and sub_account_id=?",
                                            pr.payroll_journal_header_id, deposits_received.id, insurance.id])
    assert_equal 1, jd.length
    jd = JournalDetail.find(:all, :conditions=>["journal_header_id=? and account_id=? and sub_account_id=?",
                                            pr.payroll_journal_header_id, deposits_received.id, pension.id])
    assert_equal 1, jd.length
    jd = JournalDetail.find(:all, :conditions=>["journal_header_id=? and account_id=? and sub_account_id=?",
                                            pr.payroll_journal_header_id, deposits_received.id, inhabitant_tax.id])
    assert_equal 1, jd.length
  end
  
  def test_should_get_create_advance_money
    finder = PayrollFinder.new(current_user)
    finder.fiscal_year = 2009
    finder.employee_id = 2
    @request.session[PayrollFinder] = finder
    
    ym = 200902
    employee_id = 2
    xhr :post, :create,
        :payroll => {:ym => ym, :employee_id => employee_id,
                     :days_of_work => 28, :hours_of_work => 224,
                     :hours_of_day_off_work => 100, :hours_of_early_for_work => 101,
                     :hours_of_late_night_work => 102, :base_salary => '394000',
                     :insurance => '10000', :pension => '20000',
                     :income_tax => '1000', :inhabitant_tax => '8400',
                     :accrued_liability => '120000', :pay_day => '2009-03-06',
                     :credit_account_type_of_income_tax => Payroll::CREDIT_ACCOUNT_TYPE_ADVANCE_MONEY,
                     :credit_account_type_of_insurance => Payroll::CREDIT_ACCOUNT_TYPE_ADVANCE_MONEY,
                     :credit_account_type_of_pension => Payroll::CREDIT_ACCOUNT_TYPE_ADVANCE_MONEY,
                     :credit_account_type_of_inhabitant_tax => Payroll::CREDIT_ACCOUNT_TYPE_ADVANCE_MONEY}
    assert_response :success
    assert assigns(:payroll).errors.size == 0
    assert_template 'common/_reload_dialog'

    # 登録された仕訳をチェック
    pr = Payroll.find_by_ym_and_employee_id(ym, employee_id)
    assert_equal Payroll::CREDIT_ACCOUNT_TYPE_ADVANCE_MONEY, pr.credit_account_type_of_income_tax
    assert_equal Payroll::CREDIT_ACCOUNT_TYPE_ADVANCE_MONEY, pr.credit_account_type_of_insurance
    assert_equal Payroll::CREDIT_ACCOUNT_TYPE_ADVANCE_MONEY, pr.credit_account_type_of_pension
    assert_equal Payroll::CREDIT_ACCOUNT_TYPE_ADVANCE_MONEY, pr.credit_account_type_of_inhabitant_tax
    advance_money = Account.find_by_code(ACCOUNT_CODE_ADVANCE_MONEY)
    temp_pay_tax = Account.find_by_code(ACCOUNT_CODE_TEMP_PAY_TAX)
    income_tax = advance_money.get_sub_account_by_code(SUB_ACCOUNT_CODE_INCOME_TAX_OF_ADVANCE_MONEY)
    insurance = advance_money.get_sub_account_by_code(SUB_ACCOUNT_CODE_HEALTH_INSURANCE_OF_ADVANCE_MONEY)
    pension = advance_money.get_sub_account_by_code(SUB_ACCOUNT_CODE_EMPLOYEES_PENSION_OF_ADVANCE_MONEY)
    inhabitant_tax = advance_money.get_sub_account_by_code(SUB_ACCOUNT_CODE_INHABITANT_TAX_OF_ADVANCE_MONEY)

    jd = JournalDetail.where("journal_header_id=? and account_id=? and sub_account_id=?",
            pr.payroll_journal_header_id, advance_money.id, income_tax.id)
    assert_equal 1, jd.count

    jd = JournalDetail.where("journal_header_id=? and account_id=? and sub_account_id=?",
            pr.payroll_journal_header_id, advance_money.id, insurance.id)
    assert_equal 1, jd.count

    jd = JournalDetail.where("journal_header_id=? and account_id=? and sub_account_id=?",
              pr.payroll_journal_header_id, advance_money.id, pension.id)
    assert_equal 1, jd.count

    jd = JournalDetail.where("journal_header_id=? and account_id=? and sub_account_id=?",
              pr.payroll_journal_header_id, advance_money.id, inhabitant_tax.id)
    assert_equal 1, jd.count

    # 仮払消費税として登録されていること
    jd = JournalDetail.where("journal_header_id=? and account_id=?", pr.pay_journal_header_id, temp_pay_tax.id)
    assert_equal 1, jd.count
    assert_equal 25, jd[0].amount
  end
  
  def test_should_get_create_with_errors
    finder = PayrollFinder.new(User.find(session[:user_id]))
    finder.fiscal_year = 2009
    finder.employee_id = 2
    @request.session[PayrollFinder] = finder
    
    post :create, :format => 'js',
                  :payroll => {:ym => 200902, :employee_id => 2,
                               :days_of_work => 28, :hours_of_work => 224,
                               :hours_of_day_off_work => 100, :hours_of_early_for_work => 101,
                               :hours_of_late_night_work => 102, :base_salary => '',
                               :insurance => '', :pension => '',
                               :income_tax => '', :inhabitant_tax => '',
                               :accrued_liability => '', :pay_day => '20090332',
                               :credit_account_type_of_income_tax => Payroll::CREDIT_ACCOUNT_TYPE_ADVANCE_MONEY,
                               :credit_account_type_of_insurance => Payroll::CREDIT_ACCOUNT_TYPE_ADVANCE_MONEY,
                               :credit_account_type_of_pension => Payroll::CREDIT_ACCOUNT_TYPE_ADVANCE_MONEY,
                               :credit_account_type_of_inhabitant_tax => Payroll::CREDIT_ACCOUNT_TYPE_ADVANCE_MONEY}
    assert_response :success
    assert assigns(:payroll).errors.size == 7
    assert_template 'new'
  end
  
  def test_should_get_create_with_errors2
    finder = PayrollFinder.new(User.find(session[:user_id]))
    finder.fiscal_year = 2009
    finder.employee_id = 2
    @request.session[PayrollFinder] = finder
    
    post :create, :format => 'js',
                  :payroll => {:ym => 200912, :employee_id => 2,
                               :days_of_work => 28, :hours_of_work => 224,
                               :hours_of_day_off_work => 100, :hours_of_early_for_work => 101,
                               :hours_of_late_night_work => 102, :base_salary => '100000a',
                               :insurance => '5@000', :pension => 'x',
                               :income_tax => 'x', :inhabitant_tax => 'x',
                               :accrued_liability => 'x', :year_end_adjustment_liability=>'x',
                               :pay_day => 'x',
                               :credit_account_type_of_income_tax => Payroll::CREDIT_ACCOUNT_TYPE_ADVANCE_MONEY,
                               :credit_account_type_of_insurance => Payroll::CREDIT_ACCOUNT_TYPE_ADVANCE_MONEY,
                               :credit_account_type_of_pension => Payroll::CREDIT_ACCOUNT_TYPE_ADVANCE_MONEY,
                               :credit_account_type_of_inhabitant_tax => Payroll::CREDIT_ACCOUNT_TYPE_ADVANCE_MONEY}
    assert_response :success
    assert assigns(:payroll).errors.size == 8
    assert_template 'new'
  end
  
  def test_should_get_auto_calc
    finder = PayrollFinder.new(User.find(session[:user_id]))
    finder.fiscal_year = 2009
    finder.employee_id = 2
    @request.session[PayrollFinder] = finder

    post :auto_calc, :payroll => {:ym => 200904, :employee_id=>2, :base_salary => 394000}
    assert_response :success
    assert_template '_auto_calc'
  end
  
  def test_should_get_auto_calc_insurance
    finder = PayrollFinder.new(User.find(session[:user_id]))
    finder.fiscal_year = 2008
    finder.employee_id = 1
    @request.session[PayrollFinder] = finder

    post :auto_calc, :payroll => {:ym => 200811, :employee_id => 1, :base_salary => 424000 }
    assert_response :success
    assert_template '_auto_calc'
    assert_equal insurances(:insurance_00120)["health_insurance_half"], assigns(:payroll).insurance
  end
end
