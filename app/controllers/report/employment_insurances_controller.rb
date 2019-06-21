class Report::EmploymentInsurancesController < ReportController
  helper_method :finder

  def index
    if finder.calendar_year.present?
      logic = Reports::EmploymentInsuranceLogic.new(finder)
      @model = logic.build_model
      render find_template(logic)
    end if params[:commit]
  end

  private

  def find_template(logic)
    template_dir = File.join(Rails.root, 'app', 'views', 'report', 'employment_insurances') 
    Dir[File.join(template_dir, '*.html.erb')].sort.reverse.each do |t|
      ymd = File.basename(t).split('.').first
      next if ymd > logic.end_ymd
      return ymd
    end
  end
  
  def finder
    if @finder.nil?
      @finder = EmploymentInsuranceFinder.new(finder_params)
      @finder.company_id = current_company.id
      @finder.calendar_year ||= Date.today.year
    end

    @finder
  end
  
  def finder_params
    (params[:finder] || ActionController::Parameters.new).permit(:calendar_year)
  end

end
