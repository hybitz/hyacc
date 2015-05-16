ならば /^資産管理の一覧に遷移する$/ do
  assert has_title?('資産管理')
  assert_url '/assets$'
end
