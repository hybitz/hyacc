# coding: UTF-8

def user
  @_user_cache ||= User.first
end