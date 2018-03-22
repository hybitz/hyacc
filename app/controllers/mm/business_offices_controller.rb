class Mm::BusinessOfficesController < Base::HyaccController
  before_action :setup_view_attributes

  def new
    @bo = BusinessOffice.new(company_id: current_company.id)
  end

  def create
    begin
      @bo = BusinessOffice.new(business_office_params)
      @bo.transaction do
        @bo.save!
      end

      flash[:notice] = "{@bo.name} を登録しました。"
      render 'common/reload'

    rescue => e
      handle(e)
      render :action => 'new'
    end
  end

  def edit
    @bo = BusinessOffice.find(params[:id])
  end
  
  def update
    begin
      @bo = BusinessOffice.find(params[:id])
      @bo.transaction do
        @bo.attributes = business_office_params
        @bo.save!
      end

      flash[:notice] = "{@bo.name} を更新しました。"
      render 'common/reload'
    rescue => e
      handle(e)
      render :action => 'edit'
    end
  end
  
  def destroy
    begin
      @bo = BusinessOffice.find(params[:id])

      @bo.transaction do
        @bo.destroy_logically!
      end
      
      flash[:notice] = "#{@bo.name} を削除しました。"
    rescue => e
      handle(e)
    end
    
    redirect_to mm_companies_path
  end

  private

  def business_office_params
    permitted = [
      :name, :name_effective_at, :prefecture_code, :zip_code,
      :address1, :address2, :tel, :lock_version,
      :names_attributes => [:id, :_destroy],
    ]

    ret = params.require(:business_office).permit(permitted)

    case action_name
    when 'create'
      ret = ret.merge(:company_id => current_company.id)
    end

    ret
  end

  def setup_view_attributes
    @prefectures = TaxJp::Prefecture.all
  end

end
