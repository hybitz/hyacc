class FirstBootController < ApplicationController
  require 'active_record/fixtures'
  include HyaccDateUtil
  include Base::ExceptionHandler
  include FirstBoot

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

    unless @c.valid? && @u.valid?
      render :index and return
    end

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
    @b.name = '本店'
    @b.is_head_office = true

    @be = BranchEmployee.new
    @be.cost_ratio = 100
    @be.default_branch = true

    @c.transaction do
      # マスタデータをロード
      load_fixtures

      @c.save!

      @fy.company_id = @c.id
      @fy.save!

      @b.company_id = @c.id
      @b.save!

      @e.company_id = @c.id
      @u.company_id = @c.id
      @u.employee = @e
      @u.save!

      @be.branch_id = @b.id
      @be.employee_id = @e.id
      @be.save!
    end

    redirect_to root_path
  end

  private

  def company_params
    params.require(:c).permit(:name, :founded_date, :type_of)
  end

  def fiscal_year_params
    params.require(:fy).permit(:tax_management_type)
  end

  def employee_params
    params.require(:e).permit(:last_name, :first_name, :sex, :birth)
  end

  def user_params
    params.require(:u).permit(:login_id, :password, :email)
  end

  def load_fixtures
    now = Time.now
    dir = File.join(Rails.root, 'config', 'first_boot')

    # 勘定科目、勘定科目制御の初期データロード
    ActiveRecord::FixtureSet.create_fixtures(dir, "accounts")
    if @c.personal?
      Account.delete_all(['company_only =?', true])
      Account.where('depreciable = ?', true).update_all(['depreciation_method = ?', DEPRECIATION_METHOD_FIXED_AMOUNT])
    else
      Account.delete_all(['personal_only = ?', true])
      Account.where('depreciable = ?', true).update_all(['depreciation_method = ?', DEPRECIATION_METHOD_FIXED_RATE])
    end
    Account.update_all(['created_at = ?, updated_at = ?', now, now])

    # 補助科目の初期データロード
    ActiveRecord::FixtureSet.create_fixtures(dir, "sub_accounts")
    if @c.personal?
      SubAccount.update_all(['social_expense_number_of_people_required = ?', false])
    end
    SubAccount.update_all(['created_at = ?, updated_at = ?', now, now])

    # 簡易入力テンプレートの初期データロード
    ActiveRecord::FixtureSet.create_fixtures(dir, "simple_slip_templates")
    SimpleSlipTemplate.update_all(['created_at = ?, updated_at = ?', now, now])

    # 事業区分の初期データロード
    ActiveRecord::FixtureSet.create_fixtures(dir, "business_types")
    BusinessType.update_all(['created_at = ?, updated_at = ?', now, now])
  end

  def current_company
    @company
  end

end
