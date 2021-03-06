ならば /^元帳に遷移する$/ do
  assert has_title?('元帳')
  assert_url '/ledgers'
end

もし /^勘定科目に(.*?)を選択して表示する$/ do |account_name|
  assert @account = Account.find_by_name(account_name)
  select @account.code_and_name, :from => 'finder_account_id'
  click_on '表示'
end

ならば /^現金仕訳の月別累計が表示される$/ do
  assert_url '/ledgers'
end
