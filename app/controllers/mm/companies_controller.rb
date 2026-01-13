class Mm::CompaniesController < Base::HyaccController

  def index
    redirect_to [:mm, current_company]
  end

  def show
    @company = Company.find(current_company.id)
    @include_disabled = params[:include_disabled] == 'true'

    @business_offices = if @include_disabled
      BusinessOffice.where(company_id: @company.id, deleted: false).order(:id)
    else
      @company.business_offices.where(disabled: false)
    end
    
    # 資本金を算出する
    unless @company.personal?
      @capital = get_capital_stock( @company.fiscal_year )
    end
  end

  def show_logo
    @company = Company.find(current_company.id)
    if @company.logo.present?
      case params[:version]
      when 'icon'
        send_file(@company.logo.icon.path)
      else
        send_file(@company.logo.thumb.path)
      end
    else
      send_file(File.join('app', 'assets', 'images', 'rails.png'))
    end
  end

  def edit
    @company = Company.find(current_company.id)
    render "edit_#{params[:field]}", layout: false
  end

  def update
    @company = Company.find(current_company.id)
    @company.attributes = company_params

    begin
      @company.transaction do
        @company.save!
      end

      render :js => 'document.location.reload();'

    rescue => e
      handle(e)
      render :js => "alert('#{flash.discard :notice}');"
    end
  end

  private

  def company_params
    permitted = [
      :logo, :business_type_id, :day_of_pay_day_definition, :month_of_pay_day_definition, :enterprise_number, :labor_insurance_number, :social_insurance_number, :employment_insurance_type, :retirement_savings_after
    ]
   
    ret = params.require(:company).permit(permitted)

    if ret[:month_of_pay_day_definition].present?
      ret = ret.merge(:pay_day_definition => ret[:month_of_pay_day_definition] + "," + ret[:day_of_pay_day_definition])
    end

    ret
  end

end
