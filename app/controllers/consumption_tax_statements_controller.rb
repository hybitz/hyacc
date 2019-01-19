class ConsumptionTaxStatementsController < Base::HyaccController
  helper_method :finder

  def index
  end
  
  def show
    report_name = File.basename(params[:id])
    
    logic = "Reports::#{report_name.camelize}Logic".constantize.new(finder)
    @model = logic.build_model

    template = nil
    Dir[File.join(Rails.root, 'app', 'views', controller_name, report_name, '*.html.erb')].sort.reverse.each do |t|
      ymd = File.basename(t).split('.').first
      next if ymd > logic.end_ymd
      template = ymd
      break
    end

    render "#{controller_name}/#{report_name}/#{template}"
  end

  private
  
  def finder
    @finder ||= TaxReportFinder.new(finder_params)
    @finder.company_id = current_company.id
    @finder.page = params[:page]
    @finder.per_page = current_user.slips_per_page
    @finder
  end
  
  def finder_params
    if params[:finder]
      params.require(:finder).permit(
        :fiscal_year,
        :branch_id
      )
    end
  end

end
