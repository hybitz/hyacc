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

  private

  def user_params
    permitted = [
      :login_id, :email, :slips_per_page, :password,
      :google_account, :account_count_of_frequencies,
      :yahoo_api_app_id, :show_details,
      employee_attributes: [
        :id, :first_name, :last_name, :employment_date,
        :zip_code, :address, :sex, :business_office_id, :birth, :my_number
      ]
    ]

    ret = params.require(:user).permit(permitted)

    if ret[:employee_attributes].present?
      ret[:employee_attributes].merge!(company_id: current_company.id)
    end

    ret
  end
end
