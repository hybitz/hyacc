class CareerStatementController < Base::HyaccController
  view_attribute :title => '業務経歴書'
  
  def index
    @employees = Employee.where(:company_id => current_user.company_id).paginate(:page => params[:page], :per_page => 20)
  end

  def show
    @employee = Employee.find(params[:id])
  end
end
