class CompaniesController < Base::HyaccController
  layout false
  view_attribute :title => '会社'

  def index
    @company = Company.find(current_user.company_id)
    
    # 資本金を算出する
    unless @company.type_of_personal
      @capital = get_capital_stock( @company.fiscal_year )
    end

    render :layout => 'application'
  end

  def show_logo
    @company = Company.find(current_user.company_id)
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
  
  def edit_business_type
    @company = Company.find(current_user.company_id)
  end
  
  def edit_logo
    @company = Company.find(current_user.company_id)
  end
    
  def edit_admin
    @company = Company.find(current_user.company_id)
  end

  def update
    @company = Company.find(current_user.company_id)
    @company.attributes = params[:company]

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
  
end
