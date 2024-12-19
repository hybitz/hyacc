前提 /^減価償却の一覧を表示している$/ do
  visit '/bs'
  click_on '減価償却'
  assert_url '/bs/assets$'
  assert page.has_selector?('table#asset_container')
end

もし /^資産管理の減価償却をクリックする$/ do
  click_on '資産管理'
  click_on '減価償却'
end

ならば /^減価償却の一覧に遷移する$/ do
  assert has_title?('減価償却')
  assert_url '/bs/assets$'
end

もし /^減価償却の一覧から編集をクリックする$/ do
  click_on '編集'
end

もし /^.*償却限度額を(.*?)円に変更した状態で、償却方法を(.*?)に変更する$/ do |limit, method|
  fill_in 'asset[depreciation_limit]', with: limit
  select method, from: 'asset[depreciation_method]'
end

もし /^.*償却方法を(.*?)に変更する$/ do |method|
  select method, from: 'asset[depreciation_method]'
end

ならば /^資産の編集ダイアログが表示される$/ do
  assert wait_until { has_selector?("div.ui-dialog", :visible => true) }
  assert has_selector?("span.ui-dialog-title", :text => /減価償却　編集/)
end

ならば /^.*償却限度額は(.*?)円(に変換される|のまま)$/ do |limit, text|
  assert_equal limit, find("#asset_depreciation_limit").value
end