module Login

  def sign_in(options = {})
    if options[:login_id]
      assert user = User.where(login_id: options[:login_id]).not_deleted.first
    elsif options[:name]
      assert user = Employee.name_is(options[:name]).not_deleted.first.user
    else
      fail "未知のユーザ情報です。options=#{options}"
    end

    if @_current_user and @_current_user.login_id != user.login_id and has_link?('ログアウト')
      click_on 'ログアウト'
    end

    @_current_user = user

    visit '/users/sign_in'
    fill_in 'ログインID', with: @_current_user.login_id
    fill_in 'パスワード', with: 'testtest'
    click_on 'ログイン'

    assert has_link?('ログアウト')
  end

  def current_user
    @_current_user
  end

  def current_company
    @_current_user.employee.company
  end
end

World(Login)
