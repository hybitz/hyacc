class Report::LedgersController < ReportController

  def index
    @fiscal_years = current_company.fiscal_years.order('fiscal_year desc')
  end

  def show
    @fiscal_year = current_company.fiscal_years.where(fiscal_year: params[:id]).first
    render pdf: "元帳-#{@fiscal_year.fiscal_year}",
        disposition: 'attachment',
        encoding: 'UTF-8',
        layout: 'application',
        print_media_type: true,
        show_as_html: params[:debug]
  end

end
