# coding: UTF-8

module Login

  def sign_in(options = {})
    if options[:login_id]
      @current_user = User.where(:login_id => login_id, :deleted => false).first!
    elsif options[:name]
      @current_user = Employee.name_is(options[:name]).where(:deleted => false).first!.users.where(:deleted => false).first!
    else
      fail "未知のユーザ情報です。options=#{options}"
    end

    visit '/login'
    fill_in 'ID', :with => @current_user.login_id
    fill_in 'パスワード', :with => 'testtest'
    click_on 'ログイン'
  end

  def current_user
    @current_user
  end  
end

World(Login)
