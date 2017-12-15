module Base
  class Finder
    attr_reader :start_month_of_fiscal_year
    attr_reader :slips_per_page
    attr_reader :login_user_id
    attr_accessor :account_id
    attr_accessor :commit
    attr_accessor :deleted
    attr_accessor :page
    attr_accessor :ym
    attr_accessor :fiscal_year
    attr_accessor :branch_id
    attr_accessor :sub_account_id
    attr_accessor :business_office_id
    attr_accessor :employee_id
    attr_accessor :prefecture_code
    attr_accessor :remarks
    attr_accessor :company_id
    attr_accessor :user_id
  
    def initialize(user)
      @start_month_of_fiscal_year = user.company.start_month_of_fiscal_year
      @founded_date = user.company.founded_date
      @slips_per_page = user.slips_per_page
      @login_user_id = user.id
      @commit = nil
      @page = 0
      @ym = nil
      @company_id = user.company_id
      @fiscal_year = user.company.current_fiscal_year.fiscal_year
      @branch_id = user.employee.default_branch.id
      @account_id = 0
      @sub_account_id = 0
      @business_office_id = 0
      @employee_id = 0
      @remarks = nil
      @user_id = 0
      @deleted = nil
    end

    def setup_from_params( params )
      return unless params
  
      @ym = params[:ym]
      @fiscal_year = params[:fiscal_year].to_i
      @account_id = params[:account_id].to_i
      @branch_id = params[:branch_id].to_i
      @business_office_id = params[:business_office_id].to_i
      @deleted = params[:deleted].to_s.size == 0 ? nil : params[:deleted] == 'true'
      @employee_id = params[:employee_id].to_i
      @prefecture_code = params[:prefecture_code]
      @remarks = params[:remarks]
      @sub_account_id = params[:sub_account_id].to_i
      @user_id = params[:user_id].to_i
    end
    
    # 従業員IDを検索条件に含めるか
    def employee_id_enabled?
      true
    end

    def start_year_month_of_fiscal_year
      HyaccDateUtil.get_start_year_month_of_fiscal_year(@fiscal_year, @start_month_of_fiscal_year)
    end
    
    def end_year_month_of_fiscal_year
      HyaccDateUtil.get_end_year_month_of_fiscal_year(@fiscal_year, @start_month_of_fiscal_year)
    end
    
    def start_year_month_day_of_fiscal_year
      yyyymm = start_year_month_of_fiscal_year
      yyyymmdd = (yyyymm.to_s + "01").to_i
      start_day = HyaccDateUtil.to_int(@founded_date)
      start_day > yyyymmdd ? start_day : yyyymmdd
    end
    
    def end_year_month_day_of_fiscal_year
      yyyymm = end_year_month_of_fiscal_year
      d = Date.new(yyyymm / 100, yyyymm % 100, 1).end_of_month
      d.strftime("%Y%m%d").to_i
    end
  end
end
