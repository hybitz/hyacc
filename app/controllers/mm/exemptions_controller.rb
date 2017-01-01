class Mm::ExemptionsController < Base::HyaccController
  view_attribute :title => '所得税控除'
  helper_method :finder

  def index
    @exemptions = finder.list
  end

  def new
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
    @finder.company_id = current_company.id
    @finder.page = params[:page] || 1
    @finder.per_page = current_user.slips_per_page
    @finder
  end

  def exempiton_params
    permitted = [:employee_id, :yyyy, :small_scale_mutual_aid, :life_insurance_premium_old, :earthquake_insurance_premium,
      :special_tax_for_spouse, :spouse, :dependents, :disabled_persons, :basic]

    ret = params.require(:exemption).permit(permitted)
    ret.merge!(:company_id => current_company.id)
  end

end
