class ConsumptionTaxStatementsController < Base::HyaccController
  helper_method :finder

  def index
    if params[:commit]
      report_type = finder.report_type
      
      logic = "Reports::#{report_type.camelize}Logic".constantize.new(finder)
      @model = logic.build_model
  
      template = nil
      Dir[File.join(Rails.root, 'app', 'views', controller_name, report_type, '*.html.erb')].sort.reverse.each do |t|
        ymd = File.basename(t).split('.').first
        next if ymd > logic.end_ymd
        template = ymd
        break
      end
  
      render "#{controller_name}/#{report_type}/#{template}"
    end
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
      params.require(:finder).permit(:fiscal_year, :branch_id, :report_type)
    end
  end

end
