# -*- encoding : utf-8 -*-
#
# $Id: mail_sender.rb 2471 2011-03-23 14:59:36Z ichy $
# Product: hyacc
# Copyright 2011 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class LoginNotice < ActionMailer::Base
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
