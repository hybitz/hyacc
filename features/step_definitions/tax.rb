# coding: UTF-8

前提 /^伝票管理を表示している$/ do
  assert_visit '/journal_admin'
end

ならば /^消費税管理に遷移する$/ do
  assert_url '/tax$'
end