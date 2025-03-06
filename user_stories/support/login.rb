module Login

  def sign_in(user, options = {})
    if options.fetch(:force, false)
      sign_out if has_link?('ログアウト')
    end

    visit '/users/sign_in'
    assert has_selector?('form.new_user')
    fill_in 'ログインID', :with => user.login_id
    fill_in 'パスワード', :with => 'testtest'
    click_on 'ログイン'

    @_current_user = user
  end

  def sign_out
    click_on 'ログアウト'
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
