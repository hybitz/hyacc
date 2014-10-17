module Login

  def sign_in(options = {})
    if options[:login_id]
      @_current_user = User.where(:login_id => options[:login_id]).not_deleted.first!
    elsif options[:name]
      @_current_user = Employee.name_is(options[:name]).where(:deleted => false).first!.users.where(:deleted => false).first!
    else
      fail "未知のユーザ情報です。options=#{options}"
    end

    visit '/users/sign_in'
    fill_in 'ログインID', :with => @_current_user.login_id
    fill_in 'パスワード', :with => 'testtest'
    click_on 'ログイン'
  end

  def current_user
    @_current_user
  end  
end

World(Login)
