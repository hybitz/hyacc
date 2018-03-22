class CareerStatementsController < Base::HyaccController

  def index
    @employees = Employee.where(:company_id => current_company.id).paginate(:page => params[:page], :per_page => 20)
  end

  def show
    @employee = Employee.find(params[:id])
  end
end
