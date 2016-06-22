class UsersController < Base::HyaccController
  view_attribute :title => 'ユーザ'
         
  def index
    @users = User.paginate :page => params[:page], :per_page => current_user.slips_per_page
  end

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
    @user.employee = Employee.new
  end

  def create
    @user = User.new(user_params)

    begin
      @user.transaction do
        @user.company_id = @user.employee.company_id = current_user.company_id
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
        @user.update_attributes!(user_params)
      
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

  private

  def user_params
    user_attributes = [
      :login_id, :company_id, :email, :slips_per_page, :password,
      :google_account, :google_password, :employee_id, :account_count_of_frequencies,
      :yahoo_api_app_id, :show_details
    ]
    employee_attributes = [
      :id, :company_id, :first_name, :last_name, :employment_date,
      :zip_code, :address, :sex, :business_office_id, :birth, :my_number
    ]

    params.require(:user).permit(user_attributes, :employee_attributes => employee_attributes)
  end
end
