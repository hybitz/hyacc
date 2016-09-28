class FirstBootController < ApplicationController
  include HyaccConstants
  include Base::ExceptionHandler
  include FirstBoot

  helper_method :current_company

  def index
    @c = Company.new(:founded_date => Date.today, :type_of => COMPANY_TYPE_PERSONAL)
    @c.business_offices.build
    @fy = FiscalYear.new
    @u = User.new
  end
  
  def create
    @c = Company.new(company_params)
    @fy = FiscalYear.new(fiscal_year_params)
    @e = Employee.new(employee_params)
    @u = User.new(user_params)

    unless @c.valid? && @u.valid?
      Rails.logger.info @c.errors.full_messages.join("\n")
      Rails.logger.info @u.errors.full_messages.join("\n")
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

    @c.transaction do
      # マスタデータをロード
      load_fixtures

      @c.save!

      @fy.company_id = @c.id
      @fy.save!

      @b = @c.branches.build(:business_office => @c.business_offices.first)
      @b.code = '100'
      @b.name = '本店'
      @b.save!

      @e.company_id = @c.id
      @u.company_id = @c.id
      @u.employee = @e
      @u.save!

      @be = BranchEmployee.new(:branch => @b, :employee => @e)
      @be.default_branch = true
      @be.cost_ratio = 100
      @be.save!
    end

    redirect_to root_path
  end

  private

  def company_params
    permitted = [
      :name, :founded_date, :type_of,
      :business_offices_attributes => [:prefecture_code, :address1, :address2]
    ]

    ret = params.require(:company).permit(permitted)
    ret[:business_offices_attributes]['0'].merge!(:name => '本社')
    ret
  end

  def fiscal_year_params
    params.require(:fy).permit(:tax_management_type)
  end

  def employee_params
    params.require(:e).permit(:last_name, :first_name, :sex, :birth).merge(:executive => true)
  end

  def user_params
    params.require(:u).permit(:login_id, :password, :email)
  end

  # 初期データロード
  def load_fixtures
    ['accounts.csv', 'sub_accounts.csv', 'simple_slip_templates.csv', 'business_types.csv'].each do |fixture|
      csv = ERB.new(File.read(File.join(Rails.root, 'config', 'first_boot', fixture))).result
      klass = File.basename(fixture, File.extname(fixture)).singularize.camelize.constantize

      CSV.parse(csv, :headers => true).each do |row|
        klass.create!(row.to_hash)
      end
    end

    if @c.personal?
      Account.where(:company_only => true).delete_all
      Account.where('depreciable = ?', true).update_all(['depreciation_method = ?', DEPRECIATION_METHOD_FIXED_AMOUNT])
      SubAccount.update_all(['social_expense_number_of_people_required = ?', false])
    else
      Account.where(:personal_only => true).delete_all
      Account.where('depreciable = ?', true).update_all(['depreciation_method = ?', DEPRECIATION_METHOD_FIXED_RATE])
    end
  end

  def current_company
    @company
  end

end
