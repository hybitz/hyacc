class Mm::InhabitantTaxesController < Base::BasicMasterController
  helper_method :finder

  def index
    @list = finder.list
  end

  def confirm
    file = params[:file]
    if file.nil?
      redirect_to action: 'index', finder: {year: finder.year}
    else
      @list, @linked = InhabitantCsv.load(file, current_company)
      unless @linked
        flash[:is_error_message] = true
        flash[:notice] = "従業員マスタと紐づけできませんでした。従業員マスタに登録してください。"
      end
    end
  end

  def create
    if InhabitantCsv.create_csv(params)
      flash[:notice] = "住民税データを登録しました。"
    else
      flash[:is_error_message] = true
      flash[:notice] = "従業員マスタと紐づけできませんでした。従業員マスタに登録してください。"
    end
    redirect_to action: 'index', finder: {year: finder.year}
  end

  def destroy
    data = InhabitantTax.find(params[:id])
    name = data.employee.fullname
    ym = data.ym
    data.destroy

    flash[:notice] = "#{name}（#{ym}）の住民税を削除しました。"
    render 'common/reload'
  end

  private

  def finder
    if @finder.nil?
      @finder = InhabitantTaxFinder.new(finder_params)
      @finder.company_id = current_company.id
      @finder.page = params[:page]
      @finder.per_page = current_user.slips_per_page
    end
    
    @finder
  end

  def finder_params
    return {} unless params[:finder].present?

    params.require(:finder).permit(:year, :employee_id)
  end

  def inhabitant_tax_params
    params.require(:inhabitant_tax).permit(:amount)
  end

end
