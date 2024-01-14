もし /^Hyaccインストール後の最初のアクセス時に、初期設定が表示される$/ do
  system('bundle exec rake db:seed')
  assert_visit '/'
end

もし /^会社情報を登録$/ do |ast_table|
  @user = User.new

  normalize_table(ast_table).each do |row|
    case row[0]
    when '会社名'
      fill_in 'company_name', :with => row[1]
    when '都道府県'
      select row[1], :from => 'company_business_offices_attributes_0_prefecture_code'
    when '住所1'
      fill_in 'company_business_offices_attributes_0_address1', :with => row[1]
    when '住所2'
      fill_in 'company_business_offices_attributes_0_address2', :with => row[1]
    when '事業開始年月日'
      fill_in 'company_founded_date', with: row[1]
      find_field('company_founded_date').native.send_keys :tab
    when '事業形態'
      select row[1], :from => 'company_type_of'
    when '消費税'
      select row[1], :from => 'fy_tax_management_type'
    when '代表者　姓'
      fill_in 'e_last_name', :with => row[1]
    when '代表者　名'
      fill_in 'e_first_name', :with => row[1]
    when '性別'
      select row[1], :from => 'e_sex'
    when '生年月日'
      fill_in 'e_birth', with: row[1]
      find_field('e_birth').native.send_keys :tab
    when 'ログインID'
      @user.login_id = row[1]
      fill_in 'u_login_id', :with => @user.login_id
    when 'パスワード'
      @user.password = row[1]
      fill_in 'u_password', :with => @user.password
    when 'メールアドレス'
      @user.email = row[1]
      fill_in 'u_email', :with => @user.email
    else
      raise "想定していないフィールド #{row[0]}"
    end
  end
  capture

  click_on '登録'
  assert_equal '/users/sign_in', current_path
end

もし /^ログイン画面が表示されるので、登録したログインIDとパスワードでログイン$/ do
  assert @user

  fill_in 'ログインID', with: @user.login_id
  fill_in 'パスワード', with: @user.password
  capture

  click_on 'ログイン'
  assert_url '/$'
end
