class BusinessOfficesController < Base::HyaccController
  view_attribute :title => '事業所'
  before_filter :setup_view_attributes

  def new
    @bo = BusinessOffice.new(:company_id => params[:company_id])
  end

  def create
    begin
      @bo = BusinessOffice.new(business_office_params)
      @bo.transaction do
        @bo.prefecture_name = TaxJp::Prefecture.find_by_code(@bo.prefecture_code).name
        @bo.save!
      end

      flash[:notice] = '事業所を登録しました。'
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
        @bo.prefecture_name = TaxJp::Prefecture.find_by_code(@bo.prefecture_code).name
        @bo.save!
      end

      flash[:notice] = '事業所を更新しました。'
      render 'common/reload'
    rescue => e
      handle(e)
      render :action => 'edit'
    end
  end
  
  def destroy
    begin
      @bo = BusinessOffice.find(params[:id])

      unless @bo.destroy
        raise HyacccException.new(ERR_DB)
      end
      
      flash[:notice] = '事業所を削除しました。'
    rescue => e
      handle(e)
    end
    
    redirect_to mm_companies_path
  end

  private

  def business_office_params
    params.require(:business_office).permit(
        :company_id, :name, :prefecture_code, :prefecture_name, 
        :address1, :address2, :lock_version, :tel, :is_head)
  end

  def setup_view_attributes
    @prefectures = TaxJp::Prefecture.all
  end

end
