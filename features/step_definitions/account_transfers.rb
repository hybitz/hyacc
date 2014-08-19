前提 /^科目振替の一覧を表示している$/ do
  visit '/account_transfers'
  click_on '検索'
  assert page.has_selector?('#journal_container')
  capture
end

もし /^(.*?)の明細にチェックを入れる$/ do |account_name|
  find_tr '#journal_container', account_name do |tr|
    checkbox = tr.first('input[type=checkbox]')
    @journal_header_id = checkbox['id'].split('_')[3].to_i
    assert_check checkbox['id'] 
  end
end

かつ /^勘定科目を(.*?)に一括精算する$/ do |account_name|
  assert_select 'finder_to_account_id', account_name
  click_on '一括振替'
end

ならば /^科目振替に遷移する$/ do
  assert_url '/account_transfers'
end

ならば /^科目振替の一覧が表示される$/ do
  assert_url '/account_transfer'
  assert page.has_selector?('#journal_container')
end

ならば /^当該明細の勘定科目が(.*?)に更新される$/ do |account_name|
  capture
  assert_not_nil find_tr('#journal_container', account_name, false), "#{account_name}の明細が存在すること"
end
