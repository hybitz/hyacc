class ProfilesController < Base::HyaccController
  before_action :check_current_user

  view_attribute :accounts, :conditions => ['account_type in (?, ?) and journalizable=? and tax_type=? and deleted=?',
      ACCOUNT_TYPE_ASSET, ACCOUNT_TYPE_DEBT, true, TAX_TYPE_NONTAXABLE, false]

  def edit
    @profile = Profile.find(params[:id])
  end

  def update
    @profile = Profile.find(params[:id])

    # ログインIDの更新は不可
    params[:profile].delete(:login_id)

    begin
      @profile.transaction do
        password = params[:profile].delete(:password)
        
        @profile.attributes = profile_params
        @profile.password = password if password.present?
        @profile.save!
      end

      session[:google_service] = nil
      flash[:notice] = '個人設定を更新しました。'
      redirect_to :action => 'edit', :id => @profile.id

    rescue => e
      handle(e)
      render :edit
    end
  end

  def add_simple_slip_setting
    sss = SimpleSlipSetting.new(user_id: params[:id], shortcut_key: 'Ctrl+')
    render partial: 'simple_slip_setting_fields', locals: {sss: sss, index: params[:index]}
  end

  private

  def check_current_user
    unless params[:id].to_i == current_user.id
      redirect_to action: 'edit', id: current_user.id
      return false
    end
  end

  def profile_params
    permitted = [
      :login_id, :password, :email, :slips_per_page, :account_count_of_frequencies, :show_details,
      :google_account,
      :simple_slip_settings_attributes => [
        :id, :account_id, :shortcut_key, :_destroy
      ]
    ]
    
    params.require(:profile).permit(*permitted)
  end

end
