もし /^賃金台帳に今月分の給与を登録$/ do
  sign_in User.first unless current_user

  begin
    click_on '賃金台帳'
    assert has_title?('賃金台帳')
    assert has_no_selector?('#payroll_table')

    click_on '表示'
    assert has_selector?('#payroll_table')

    click_on '201309'
    assert has_selector?('.ui-dialog')
  ensure
    capture
  end
end
