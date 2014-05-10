def sign_in(user)
  @request.session[:user_id] = user.id
  @_current_user = user
end

def current_user
  @_current_user
end
