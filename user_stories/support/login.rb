module Login

  def sign_in(user, options = {})
    sign_out if options.fetch(:force, false)
    sign_out if @_current_user&.login_id != user.login_id and has_link?('ログアウト')

    unless @_current_user&.login_id == user.login_id
      visit '/users/sign_in'
      assert has_selector?('form.new_user')
      fill_in 'ログインID', with: user.login_id
      fill_in 'パスワード', with: 'testtest'
      click_on 'ログイン'
      assert has_link?('ログアウト')
    end

    @_current_user = user
  end

  def sign_out
    click_on 'ログアウト' if has_link?('ログアウト')
    assert has_selector?('form.new_user')
    @_current_user = nil
  end

  def current_user
    @_current_user
  end

  def current_company
    @_current_user.try(:employee).try(:company)
  end
end

World(Login)
