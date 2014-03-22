class LoginController < Base::HyaccController
  include LoginHelper
  
  layout false
  
  def index
    render :action => 'login'
  end
  
  def login
    unless params[:user]
      render :action => 'login' and return
    end
    
    @user = User.new( params[:user] )
    user_on_db = User.where(:login_id => @user.login_id).not_deleted.first
    if user_on_db.nil? or ! user_on_db.authoricate(@user.login_id, @user.password)
      # ログイン失敗時にメールを送信
      to = get_alert_mail_to(user_on_db)
      if to.present?
        assigns = {:now=>Time.now.strftime("%Y/%m/%d %H:%M:%S"), :who=>@user}
        LoginMailer.invoice_login_fail(to, assigns).deliver
      end

      render :action => 'login' and return
    end
    
    session[:user_id] = user_on_db.id
    
    # ログイン成功時にメールを送信
    assigns = {:now=>Time.now.strftime("%Y/%m/%d %H:%M:%S"), :who=>@user}
    LoginMailer.invoice_login(user_on_db.email, assigns).deliver

    jump_to_user_page
  end
  
  def logout
    reset_session
    redirect_to root_path
  end

  private

  # ログイン後の画面に遷移します。
  def jump_to_user_page
    if session[:jump_to].nil?
      redirect_to :controller=>'notification' and return
    end
    
    jump_to = session[:jump_to]
    session[:jump_to] = nil
    redirect_to jump_to and return
  end
end
