もし /^金融口座をクリックし、一覧を表示する$/ do
  click_on '金融口座'
  assert has_title?('金融口座')
  assert_url '/bank_accounts(\?.*)?'
end

もし /^口座情報を入力し、登録をクリック$/ do
  @name = 'テスト' + time_string
  fill_in '口座番号', :with => '1234567'
  fill_in '口座名', :with => @name
  fill_in '口座名義', :with => '名義人'
  capture
  click_on '登録'
end

もし /^口座が登録される$/ do
  assert has_no_selector?('.ui-dialog')
  assert has_selector?('.notice')
  assert find_tr '.bank_accounts', @name, false
  capture
end
