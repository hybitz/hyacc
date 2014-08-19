ならば /^交際費管理に遷移する$/ do
  assert_url '/social_expenses'
end

ならば /^交際費管理の一覧が表示される$/ do
  assert page.has_selector?('tr[social_expense=true]')
  assert_url '/social_expenses'
end
