class InhabitantTaxesController < Base::BasicMasterController
  view_attribute :title => '住民税'
  view_attribute :ym_list, :only => :index

  def create
    InhabitantCsv.create_csv(params)
    redirect_to :action => 'index', :finder => params[:finder], :commit => ''
  end
  
  def confirm
    file = params[:file]
    @finder_year = params[:finder_year]
    finder = {:year => @finder_year}
    if file.nil?
      redirect_to :action => 'index', :finder => finder, :commit => ''
    else
      @list, @linked = InhabitantCsv.load(file.tempfile, current_company)
    end
  end

  def inhabitant_tax_params
    params.require(:inhabitant_tax).permit(:employee_id, :amount)
  end

end
