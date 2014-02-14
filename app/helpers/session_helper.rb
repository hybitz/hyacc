# coding: UTF-8
#
# $Id: session_helper.rb 3350 2014-02-06 12:11:35Z ichy $
# Product: hyacc
# Copyright 2013-2014 by Hybitz.co.ltd
# ALL Rights Reserved.
#
module SessionHelper

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id].present?
  end

end
