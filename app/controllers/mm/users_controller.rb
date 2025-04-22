class Mm::UsersController < Base::HyaccController

  def index
    @users = User.paginate :page => params[:page], :per_page => current_user.slips_per_page
  end

  def show
    @user = User.find(params[:id])
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
      sort_by_display_order(e)
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
      
        flash[:notice] = 'ユーザを更新しました。'
        render 'common/reload'
      end
    rescue => e
      handle(e)
      render :edit
    end
  end

  def destroy
    id = params[:id].to_i
    User.find(id).destroy_logically!

    # 削除したユーザがログインユーザ自身の場合は、ログアウト
    if current_user.id == id
      redirect_to new_user_session_path
    else
      flash[:notice] = 'ユーザを削除しました。'
      redirect_to :action => :index
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
    params.require(:employee).permit(permitted).merge(branch_ids: [])
  end

  def sort_by_display_order(e)
    return if e.record.errors.size < 2
    messages = e.record.errors.messages
    e.record.errors.clear
    display_order = [
      :login_id, :password, :email, :"employee.last_name", :"employee.first_name", :"employee.sex", 
      :"employee.birth", :"employee.employment_date", :"employee.zip_code", :"employee.my_number", :base, :"employee.base"
    ]
    display_order.each do |d|
      m = messages[d]
      next if m.blank?
      e.record.errors.add(d, m[0])
    end
  end
end