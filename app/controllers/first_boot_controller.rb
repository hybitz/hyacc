class FirstBootController < ApplicationController
  require 'active_record/fixtures'
  include HyaccDateUtil
  include Base::ExceptionHandler
  
  before_action :check_first_boot

  helper_method :current_company

  def index
    @c = Company.new(:founded_date => Date.today, :type_of => COMPANY_TYPE_PERSONAL)
    @fy = FiscalYear.new
    @u = User.new
  end
  
  def create
    @c = Company.new(company_params)
    @fy = FiscalYear.new(fiscal_year_params)
    @e = Employee.new(employee_params)
    @u = User.new(user_params)

    valid = @c.valid? && @u.valid?
    render :index and return unless valid

    # 事業開始年月
    # 個人事業主の事業開始月は1月固定（所得税法）
    if @c.personal?
      @c.start_month_of_fiscal_year = 1
      @c.fiscal_year = @c.founded_date.year
    else
      @c.start_month_of_fiscal_year = @c.founded_date.month
      @c.fiscal_year = @c.get_fiscal_year_int(@c.founded_date.year * 100 + @c.founded_date.month)
    end

    @fy.fiscal_year = @c.fiscal_year
    @fy.closing_status = CLOSING_STATUS_OPEN

    @e.employment_date = @c.founded_date

    @b = Branch.new
    @b.code = '100'
    @b.name = '本社'
    @b.is_head_office = true

    @be = BranchesEmployee.new
    @be.cost_ratio = 100
    @be.default_branch = true

    @c.transaction do
      @c.save!
      @fy.company_id = @c.id
      @fy.save!
      @b.company_id = @c.id
      @b.save!
      @u.company_id = @c.id
      @u.save!
      @e.company_id = @c.id
      @e.users << @u
      @e.save!
      @be.branch_id = @b.id
      @be.employee_id = @e.id
      @be.save!

      # マスタデータをロード
      load_fixtures

      # デフォルトの簡易入力設定
      load_simple_slip_settings
    end

    redirect_to :action => 'show', :id => @c.id
  end

  def show
    @company = Company.find(params[:id])
  end

  private

  def company_params
    params.require(:c).permit(:name, :founded_date, :type_of)
  end

  def fiscal_year_params
    params.require(:fy).permit(:tax_management_type)
  end

  def employee_params
    params.require(:e).permit(:last_name, :first_name, :sex)
  end

  def user_params
    params.require(:u).permit(:login_id, :password, :email)
  end

  def load_fixtures
    now = Time.now
    dir = File.join(Rails.root, 'config', 'first_boot')

    # 勘定科目、勘定科目制御の初期データロード
    ActiveRecord::FixtureSet.create_fixtures(dir, "accounts")
    ActiveRecord::FixtureSet.create_fixtures(dir, "account_controls")
    if @c.personal?
      Account.delete_all(['company_only =?', true])
      Account.where('depreciable = ?', true).update_all(['depreciation_method = ?', DEPRECIATION_METHOD_FIXED_AMOUNT])
    else
      Account.delete_all(['personal_only = ?', true])
      Account.where('depreciable = ?', true).update_all(['depreciation_method = ?', DEPRECIATION_METHOD_FIXED_RATE])
    end
    Account.update_all(['created_on = ?, updated_on = ?', now, now])

    # 補助科目の初期データロード
    ActiveRecord::FixtureSet.create_fixtures(dir, "sub_accounts")
    if @c.personal?
      SubAccount.update_all(['social_expense_number_of_people_required = ?', false])
    end
    SubAccount.update_all(['created_on = ?, updated_on = ?', now, now])

    # 簡易入力テンプレートの初期データロード
    ActiveRecord::FixtureSet.create_fixtures(dir, "simple_slip_templates")
    SimpleSlipTemplate.update_all(['created_at = ?, updated_at = ?', now, now])

    # 耐用年数の初期データロード
    ActiveRecord::FixtureSet.create_fixtures(dir, "depreciation_rates")
    DepreciationRate.update_all(['created_at = ?, updated_at = ?', now, now])

    # 事業区分の初期データロード
    ActiveRecord::FixtureSet.create_fixtures(dir, "business_types")
    DepreciationRate.update_all(['created_at = ?, updated_at = ?', now, now])
  end

  def load_simple_slip_settings
      SimpleSlipSetting.new(
        :user_id=>@u.id,
        :account_id=>Account.get_by_code(ACCOUNT_CODE_CASH).id,
        :shortcut_key=>'Ctrl+1').save!
      SimpleSlipSetting.new(
        :user_id=>@u.id,
        :account_id=>Account.get_by_code(ACCOUNT_CODE_ORDINARY_DIPOSIT).id,
        :shortcut_key=>'Ctrl+2').save!
      SimpleSlipSetting.new(
        :user_id=>@u.id,
        :account_id=>Account.get_by_code(ACCOUNT_CODE_RECEIVABLE).id,
        :shortcut_key=>'Ctrl+3').save!
  end

  # インストール済みかどうかチェックする
  def check_first_boot
    if User.count > 0
      redirect_to new_session_path
    end
  end

  def current_company
    @company
  end

end
