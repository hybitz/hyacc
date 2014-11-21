class ProfilesController < Base::HyaccController
  before_filter :check_current_user

  view_attribute :title => '個人設定'
  view_attribute :accounts, :conditions=>['account_type in (?, ?) and journalizable=? and tax_type=? and deleted=?',
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
        google_password = params[:profile].delete(:google_password)
        
        @profile.attributes = profile_params
        @profile.password = password if password.present?
        @profile.google_password = google_password if google_password.present?
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
    sss = SimpleSlipSetting.new(:user_id => params[:id], :shortcut_key => 'Ctrl+')
    render :partial => 'simple_slip_setting_fields', :locals => {:sss => sss, :index => params[:index]}
  end

  private

  def check_current_user
    unless params[:id].to_i == current_user.id
      redirect_to :action => 'edit', :id => current_user.id
      return false
    end
  end

  def profile_params
    params[:profile].permit!
  end

end
