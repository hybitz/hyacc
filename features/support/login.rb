module Login

  def sign_in(options = {})
    if options[:login_id]
      assert @_current_user = User.where(:login_id => options[:login_id]).not_deleted.first
    elsif options[:name]
      assert @_current_user = Employee.name_is(options[:name]).not_deleted.first.user
    else
      fail "未知のユーザ情報です。options=#{options}"
    end

    visit '/users/sign_in'
    fill_in 'ログインID', :with => @_current_user.login_id
    fill_in 'パスワード', :with => 'testtest'
    click_on 'ログイン'

    if @_current_user.use_two_factor_authentication?
      assert has_text?('Enter the code')
      fill_in 'code', :with => User.find(current_user.id).direct_otp
      click_on 'Submit'
    end

    assert_equal '/', current_path
  end

  def current_user
    @_current_user
  end

  def current_company
    @_current_user.employee.company
  end
end

World(Login)
