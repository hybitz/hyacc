class Mm::CompaniesController < Base::HyaccController
  view_attribute :title => '会社'
  
  def index
    redirect_to [:mm, current_company]
  end

  def show
    @company = Company.find(current_company.id)
    
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
    render "edit_#{params[:field]}", :layout => false
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
      :logo, :admin_email, :business_type_id, :day_of_payday, :month_of_payday, :enterprise_number, :employment_insurance_type
    ]
   
    ret = params.require(:company).permit(permitted)

    if ret[:month_of_payday].present?
      ret = ret.merge(:payday => ret[:month_of_payday] + "," + ret[:day_of_payday])
    end

    ret
  end

end
