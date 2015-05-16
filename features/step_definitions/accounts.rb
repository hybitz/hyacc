ならば /^勘定科目の一覧表示に遷移する$/ do
  assert has_title?('勘定科目')
  assert_url '/accounts'
end
