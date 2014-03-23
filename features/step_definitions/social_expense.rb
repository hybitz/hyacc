# coding: UTF-8

ならば /^交際費管理に遷移する$/ do
  assert_url '/social_expense'
end

ならば /^交際費管理の一覧が表示される$/ do
  assert_url '/social_expense'
  assert page.has_selector?('tr[social_expense=true]')
end
