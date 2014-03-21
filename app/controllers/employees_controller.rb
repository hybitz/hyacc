class EmployeesController < Base::HyaccController
  available_for :type => :company_type, :except => COMPANY_TYPE_PERSONAL
  view_attribute :title => '従業員'
  view_attribute :finder, :class=>EmployeeFinder, :only=>:index
  view_attribute :branches, :except=>[:index, :show, :destroy]
  
  def index
    @employees = finder.list
    setup_view_attributes
  end
  
  def add_employee_history
    @employee_history = EmployeeHistory.new
  end

  def add_branch
    @branches_employee = BranchesEmployee.new
  end
 
  def edit
    @e = Employee.find(params[:id])
    setup_view_attributes
  end

  def update
    @e = Employee.find(params[:id])

    begin
      @e.transaction do
        EmployeeHistory.delete_all("employee_id=#{@e.id}")
        BranchesEmployee.delete_all("employee_id=#{@e.id}")
        @e.attributes = params[:employee]
        @e.save!
      end

      flash[:notice] = '従業員を更新しました。'
      render 'common/reload'

    rescue Exception => e
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
      redirect_to :controller => :login, :action => :logout
    else
      flash[:notice] = '従業員を削除しました。'
      redirect_to :action => :index
    end
  end

  private

  def setup_view_attributes
    @business_offices = current_user.company.business_offices
  end
end
