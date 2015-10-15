もし /^正しくは支払手数料なので、一括で訂正$/ do |ast_table|
  assert @account

  table = normalize_table(ast_table)
  assert account = Account.find_by_name(table[1][0])
  assert sub_account = account.sub_accounts.find{|sa| sa.name == table[1][1] }
  assert tax_type_name = table[1][2]
  assert amount = table[1][3].gsub(',', '').to_i

  begin
    visit_account_transfers
    fill_in 'finder_ym', :with => '2013-09'
    select @account.code_and_name, :from => 'finder_account_id'
    choose '一般振替と簡易入力'
    click_on '検索'
    assert has_selector?('#journal_container')

    select account.code_and_name, :from => 'finder_to_account_id'
    assert has_selector?('#finder_to_sub_account_id.ready')
    select sub_account.name, :from => 'finder_to_sub_account_id'
    click_on 'レ'
    click_on '一括振替'
    assert has_selector?('.notice')
  ensure
    capture
  end
end
