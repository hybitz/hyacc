class CareerStatementsController < Base::HyaccController

  helper_method :finder

  def index
    @employees = finder.list
  end

  def show
    @employee = Employee.find(params[:id])
  end

  private

  def finder
    @finder ||= EmployeeFinder.new(finder_params)
    @finder.company_id = current_company.id
    @finder.disabled ||= 'false'
    @finder.page = params[:page]
    @finder.per_page = 20
    @finder
  end
  
  def finder_params
    if params[:finder]
      params.require(:finder).permit(:disabled)
    end
  end

end
