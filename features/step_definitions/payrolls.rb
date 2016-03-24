ならば /^賃金台帳の一覧に遷移する$/ do
  assert has_title?('賃金台帳')
  assert_url '/payrolls(\?.*)?'
end

ならば /^賃金台帳が表示される$/ do
  assert_url '/payrolls(\?.*)?'
end
