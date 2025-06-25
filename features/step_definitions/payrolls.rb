ならば /^賃金台帳の一覧に遷移する$/ do
  with_capture do
    assert has_title?('賃金台帳')
    assert has_selector?('#finder_employee_id')
  end
end

ならば /^賃金台帳が表示される$/ do
  assert_url '/payrolls(\?.*)?'
end