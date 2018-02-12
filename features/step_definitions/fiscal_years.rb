前提 /^会計年度の一覧を表示している$/ do
  assert_visit '/fiscal_years'
end

ならば /^会計年度の一覧に遷移する$/ do
  assert has_title?('会計年度')
  assert_url '/fiscal_years$'
end

ならば /^会計年度が翌年の状態でダイアログが表示される$/ do
  assert wait_until { has_selector?("div.ui-dialog", :visible => true) }
  assert has_selector?("span.ui-dialog-title", :text => /会計年度.*追加/)
  capture
  
  @expected = current_company.last_fiscal_year.fiscal_year + 1
end

ならば /^翌年度が登録され、一覧に表示される$/ do
  assert wait_until { has_no_selector?('div.ui-dialog') }
  capture
  
  found = false
  find('.fiscal_years tbody').all('tr').each do |tr|
    if tr.first('td').text.to_i == @expected
      found = true
      break
    end
  end
  assert found, "翌年度 #{@expected} が表示されていること"
end