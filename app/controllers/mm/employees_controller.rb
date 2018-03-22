class Mm::EmployeesController < Base::HyaccController

  helper_method :finder

  def index
    @employees = finder.list
  end

  def show
    @e = Employee.find(params[:id])
  end

  def new
    @e = new_employee
  end
  
  def create
    @e = new_employee
    @e.attributes = employee_params

    begin
      @e.transaction do
        @e.save!
      end

      flash[:notice] = "#{@e.name} を登録しました。"
      render 'common/reload'

    rescue => e
      handle(e)
      render :action => 'edit'
    end
  end

  def edit
    @e = Employee.find(params[:id])
  end
  
  def update
    @e = Employee.find(params[:id])
    @e.attributes = employee_params

    begin
      @e.transaction do
        @e.save!
      end

      flash[:notice] = "#{@e.name} を更新しました。"
      render 'common/reload'

    rescue => e
      handle(e)
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
      flash[:notice] = "#{@employee.name} を削除しました。"
      redirect_to :action => :index
    end
  end

  def add_branch
    @be = BranchEmployee.new
    render partial: 'branch_employee_fields', locals: {be: @be, index: params[:index]}
  end

  private

  def new_employee
    current_company.employees.build
  end
  
  def employee_params
    permitted = [
      :first_name, :last_name, :employment_date,
      :sex, :business_office_id, :birth, :my_number, :executive, :position,
      :num_of_dependent, :num_of_dependent_effective_at,
      :zip_code, :zip_code_effective_at,
      :address, :address_effective_at,
      :num_of_dependents_attributes => [:id, :_destroy],
      :zip_codes_attributes => [:id, :_destroy],
      :addresses_attributes => [:id, :_destroy],
      :branch_employees_attributes => [:id, :deleted, :branch_id, :default_branch]
    ]

    ret = params.require(:employee).permit(permitted)
    ret = ret.merge(company_id: current_company.id)
    ret
  end

  def finder
    @finder ||= EmployeeFinder.new(finder_params)
    @finder.company_id = current_company.id
    @finder.page = params[:page]
    @finder.per_page = current_user.slips_per_page
    @finder
  end
  
  def finder_params
    if params[:finder]
      params.require(:finder).permit
    end
  end

end
