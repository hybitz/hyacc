class Mm::UsersController < Base::HyaccController

  def index
    @users = User.includes(:employee).paginate page: params[:page], per_page: current_user.slips_per_page
  end

  def show
    @user = User.includes(employee: { branch_employees: :branch }).find(params[:id])
    @branch_employees = @user.employee.branch_employees
  end

  def new
    @user = User.new
    @user.build_employee
  end

  def create
    @user = User.new(user_params)

    begin
      @user.transaction do
        @user.save!
      end

      flash[:notice] = 'ユーザを追加しました。'
      render 'common/reload'

    rescue => e
      handle(e)
      render :new
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    # ログインIDの更新は不可
    params[:user].delete( :login_id ) if params[:user]

    @user = User.find(params[:id])
    begin
      @user.transaction do
        @user.update!(user_params)
      end

      flash[:notice] = 'ユーザを更新しました。'
      render 'common/reload'
    rescue => e
      handle(e)
      render :edit
    end
  end

  def grant_admin
    @user = User.find(params[:id])
    begin
      @user.transaction do
        @user.update!(admin: true)
      end

      flash[:notice] = '管理権限を付与しました。'
      redirect_after_admin_change
    rescue => e
      handle(e)
      redirect_after_admin_change
    end
  end

  def revoke_admin
    @user = User.find(params[:id])
    begin
      @user.transaction do
        @user.update!(admin: false)
      end

      flash[:notice] = '管理権限を解除しました。'
      if current_user.id == @user.id
        redirect_to root_path
      else
        redirect_after_admin_change
      end
    rescue => e
      handle(e)
      redirect_after_admin_change
    end
  end

  def destroy
    id = params[:id].to_i
    user = User.find(id)

    begin
      user.transaction do
        user.destroy_logically!
      end

    # 削除したユーザがログインユーザ自身の場合は、ログアウト
      if current_user.id == id
        reset_session
        redirect_to new_user_session_path
      else
        flash[:notice] = 'ユーザを削除しました。'
        redirect_to action: :index
      end
    rescue => e
      handle(e)
      redirect_to action: :index
    end
  end

  def add_branch
    @be = BranchEmployee.new
    render partial: 'mm/employees/branch_employee_fields', locals: {be: @be, index: params[:index]}
  end

  private

  def user_params
    permitted = [
      :login_id, :email, :slips_per_page, :password,
      :google_account, :account_count_of_frequencies,
      :show_details,
      employee_attributes: [
        :id, :first_name, :last_name, :employment_date,
        :zip_code, :address, :sex, :business_office_id, :birth, :my_number
      ]
    ]
    permitted << :admin if current_user.admin? && action_name == 'create'

    ret = params.require(:user).permit(permitted)

    if ret[:employee_attributes].present?
      ret[:employee_attributes].merge!(company_id: current_company.id).merge!(employee_params)
    end

    ret
  end

  def employee_params
    return {} unless params.dig(:employee)
    permitted = [
      branch_employees_attributes: [
        :id, :branch_id, :deleted, :default_branch]
    ]
    params.require(:employee).permit(permitted)
  end

  def redirect_after_admin_change
    if current_company.personal?
      redirect_to action: 'index'
    else
      redirect_to mm_employees_path
    end
  end
end

