class EmployeesController < Base::HyaccController
  view_attribute :title => '従業員'
  view_attribute :branches, :except=>[:index, :show, :destroy]

  helper_method :finder

  def index
    @employees = finder.list
    setup_view_attributes
  end

  def add_employee_history
    @employee_history = EmployeeHistory.new
  end

  def add_branch
    @be = BranchesEmployee.new
    render :partial => 'branch_employee_fields', :locals => {:be => @be, :index => params[:index]}
  end

  def edit
    @e = Employee.find(params[:id])
    setup_view_attributes
  end

  def update
    @e = Employee.find(params[:id])

    begin
      @e.transaction do
        @e.attributes = employee_params
        @e.save!
      end

      flash[:notice] = '従業員を更新しました。'
      render 'common/reload'

    rescue => e
      handle(e)
      setup_view_attributes
      render :action => 'edit'
    end
  end

  def destroy
    @employee = Employee.find(params[:id])
    @employee.destroy_logically!

    # 削除したユーザがログインユーザ自身の場合は、ログアウト
    if current_user.employee.id == @employee.id
      reset_session
      redirect_to root_path
    else
      flash[:notice] = '従業員を削除しました。'
      redirect_to :action => :index
    end
  end

  private

  def employee_params
    employee_attributes = [
      :company_id, :first_name, :last_name, :employment_date,
      :zip_code, :address, :sex, :business_office_id
    ]
    employee_histories_attributes = [:id, :_destroy, :num_of_dependent, :start_date]
    branch_employees_attributes = [:id, :_destroy, :branch_id, :cost_ratio, :default_branch]

    params.require(:employee).permit(
      employee_attributes,
      :employee_histories_attributes => employee_histories_attributes,
      :branch_employees_attributes => branch_employees_attributes)
  end

  def setup_view_attributes
    @business_offices = current_user.company.business_offices
  end

  def finder
    @finder ||= EmployeeFinder.new(params[:finder])
    @finder.page = params[:page]
    @finder.per_page = current_user.slips_per_page
    @finder
  end

end
