ならば /^業務経歴書の一覧に遷移する$/ do
  assert has_title?('業務経歴書')
  assert_url '/career_statements$'
end