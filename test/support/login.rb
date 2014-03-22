# coding: UTF-8

def sign_in(user)
  @request.session[:user_id] = user.id
end

def current_user
  @_current_user ||= User.find(@request.session[:user_id])
end