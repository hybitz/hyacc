class LoginMailer < ActionMailer::Base
  default :from => 'info@hybitz.co.jp'
  
  def mail(headers = {})
    m = super
    m.transport_encoding = '8bit'
    m
  end

  def invoice_login(user, params = {})
    @user = user

    mail(
      :subject => "【Hyacc】#{Rails.env} ログイン通知",
      :to => @user.email
    )
  end
  
  def invoice_login_fail(user, params = {})
    @user = user

    mail(
      :subject => "【Hyacc】#{Rails.env} ログイン失敗通知！！！",
      :to => @user.email
    )
  end
end
