前提 /^伝票管理を表示している$/ do
  assert_visit '/journal_admin'
end

ならば /^消費税管理に遷移する$/ do
  assert has_title?('消費税管理')
  assert_url '^/taxes$'
end