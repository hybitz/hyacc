class LoginMailer < ApplicationMailer
  
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
