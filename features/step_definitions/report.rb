ならば /^帳票出力に遷移する$/ do
  assert has_title?('帳票出力')
  assert_url '/report$'
end