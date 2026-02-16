module Login

  def sign_in(options = {})
    if options[:login_id]
      assert user = User.where(login_id: options[:login_id]).not_deleted.first
    elsif options[:name]
      assert user = Employee.name_is(options[:name]).not_deleted.first.user
    else
      fail "未知のユーザ情報です。options=#{options}"
    end

    if @_current_user&.login_id != user.login_id and has_link?('ログアウト')
      click_on 'ログアウト'
      assert has_no_link?('ログアウト')
    end

    unless @_current_user&.login_id == user.login_id
      visit '/users/sign_in'
      fill_in 'ログインID', with: user.login_id
      fill_in 'パスワード', with: 'testpassword20260217'
      click_on 'ログイン'
    end

    assert has_link?('ログアウト')
    @_current_user = user
  end

  def current_user
    @_current_user
  end

  def current_company
    @_current_user.employee.company
  end
end

World(Login)
