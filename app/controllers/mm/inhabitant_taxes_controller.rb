class Mm::InhabitantTaxesController < Base::BasicMasterController
  helper_method :finder

  def index
    # if params[:commit]
    #   @list = finder.list
    # end
    @list = finder.list if params[:commit] || params[:action] == "index"
  end

  def confirm
    file = params[:file]
    @finder_year = params[:finder_year]
    if file.nil?
      redirect_to action: 'index', finder: {year: finder.year}
    else
      @list, @linked = InhabitantCsv.load(file, current_company)
    end
  end

  def create
    InhabitantCsv.create_csv(params)
    redirect_to action: 'index', finder: {year: finder.year}
  end

  def destroy
    InhabitantTax.find(params[:id]).destroy

    # 削除後、indexにリダイレクトしてリスト表示
    redirect_to action: 'index', finder: { year: finder.year }
  end

  private

  def finder
    if @finder.nil?
      @finder = InhabitantTaxFinder.new(finder_params)
    end
    
    @finder
  end

  def finder_params
    return {} unless params[:finder].present?
      
    params.require(:finder).permit(:year)
  end

  def inhabitant_tax_params
    params.require(:inhabitant_tax).permit(:employee_id, :amount, :ym)
  end

end
