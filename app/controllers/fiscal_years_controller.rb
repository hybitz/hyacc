class FiscalYearsController < Base::HyaccController
  view_attribute :accounts

  def index
    @fiscal_years = current_company.fiscal_years.order(fiscal_year: 'desc')
  end

  def new
    @fiscal_year = current_company.new_fiscal_year
  end

  def create
    begin
      @fiscal_year = current_company.fiscal_years.build(fiscal_year_params)
      @fiscal_year.transaction do
        @fiscal_year.save!
      end

      flash[:notice] = '会計年度を登録しました。'
      render 'common/reload'

    rescue => e
      handle(e)
      render :new
    end
  end

  def edit
    @fiscal_year = current_company.fiscal_years.find(params[:id])
  end

  def update
    @fiscal_year = current_company.fiscal_years.find(params[:id])

    begin
      @fiscal_year.transaction do
        @fiscal_year.update!(fiscal_year_params)
      end
      
      flash[:notice] = '会計年度を更新しました。'
      render 'common/reload'

    rescue => e
      handle(e)
      render :edit
    end
  end

  def edit_current_fiscal_year
    @c = Company.find(current_company.id)
  end
  
  def update_current_fiscal_year
    @c = Company.find(params[:company_id])

    begin
      @c.transaction do
        @c.update!(update_current_fiscal_year_params)
      end
      
      flash[:notice] = '会計年度を変更しました。'
      render 'common/reload'
    rescue => e
      handle(e)
      render :edit_current_fiscal_year
    end
  end

  private

  def fiscal_year_params
    permitted_params = [
        :closing_status, :tax_management_type, :consumption_entry_type,
        :accepted_amount_of_excess_depreciation, :approved_loss_amount_of_business_tax,
        :annual_adjustment_account_id
    ]

    case action_name
    when 'create'
      permitted_params << :fiscal_year
    end

    params.require(:fiscal_year).permit(*permitted_params)
  end

  def update_current_fiscal_year_params
    params.require(:c).permit(:fiscal_year, :lock_version)
  end

end
