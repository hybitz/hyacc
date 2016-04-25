module Login

  def sign_in(user)
    visit '/users/sign_in'
    assert has_selector?('form.new_user')
    fill_in 'ログインID', :with => user.login_id
    fill_in 'パスワード', :with => 'testtest'
    click_on 'ログイン'

    if user.use_two_factor_authentication?
      fill_in 'code', :with => User.find(user.id).otp_code
      click_on 'Submit'
    end

    @_current_user = user
  end

  def current_user
    @_current_user
  end
end

World(Login)
