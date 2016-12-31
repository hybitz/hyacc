class Mm::ExemptionsController < Base::HyaccController
  view_attribute :title => '所得税控除'
  view_attribute :employees
  helper_method :finder

  def index
    @exemptions = finder.list
  end

  def new
    setup_view_attributes
    @c = Exemption.new(exempiton_params)
    @c.yyyy = Date.today.year if @c.yyyy.blank?
  end

  def create
    @c = Exemption.new(exempiton_params)
    begin
      @c.transaction do
        @c.save!
      end

      flash[:notice] = '所得税控除情報を追加しました。'
      render 'common/reload'
    rescue => e
      setup_view_attributes
      handle(e)
      render 'new'
    end
  end

  def edit
    setup_view_attributes
    @c = Exemption.find(params[:id])
  end

  def update
    @c = Exemption.find(params[:id])

    begin
      @c.transaction do
        @c.update_attributes!(exempiton_params)
      end

      flash[:notice] = '所得税控除情報を更新しました。'
      render 'common/reload'
    rescue => e
      setup_view_attributes
      handle(e)
      render 'edit'
    end
  end

  def destroy
    c = Exemption.find(params[:id])
    c.destroy
    flash[:notice] = '所得税控除情報を削除しました。'
    redirect_to :action => 'index'
  end

  private

  def finder
    @finder ||= ExemptionFinder.new(params[:finder])
    @finder.page = params[:page] || 1
    @finder.per_page = current_user.slips_per_page
    @finder
  end

  def setup_view_attributes
    @cy_list = get_cy_select
  end
  
  def exempiton_params
    params.require(:exemption).permit(
        :employee_id, :yyyy, :small_scale_mutual_aid, :life_insurance_premium, :earthquake_insurance_premium,
        :special_tax_for_spouse, :spouse, :dependents, :disabled_persons, :basic)
  end

end
