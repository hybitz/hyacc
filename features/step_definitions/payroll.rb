# coding: UTF-8

ならば /^賃金台帳の一覧に遷移する$/ do
  assert_url '/payroll$'
end

ならば /^賃金台帳が表示される$/ do
  assert_url '/payroll$'
end
