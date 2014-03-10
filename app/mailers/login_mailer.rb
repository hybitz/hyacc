# -*- encoding : utf-8 -*-
class LoginMailer < ActionMailer::Base
  default :from => 'info@hybitz.co.jp'
  
  def invoice_login(to, params = {})
    @time = params[:now]
    @user = params[:who]
    mail(
      :subject => '【Hyacc】 ログイン通知',
      :to => to
    )
  end
  
  def invoice_login_fail(to, params = {})
    @time = params[:now]
    @user = params[:who]
    mail(
      :subject => '【Hyacc】 ログイン失敗通知！！！',
      :to => to
    )
  end
end
