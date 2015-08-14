もし /^賃金台帳に今月分の給与を登録$/ do |ast_table|
  sign_in User.first unless current_user

  salary = normalize_table(ast_table).first[1]

  click_on '賃金台帳'
  assert has_title?('賃金台帳')
  assert has_no_selector?('#payroll_table')

  click_on '表示'
  assert has_selector?('#payroll_table')

  click_on '201309'
  within '.ui-dialog' do
    begin
      fill_in '基本給', :with => salary.gsub(',', '')
      assert has_selector?('form[insurance_loaded]');

      fill_in '住民税', :with => 0
    ensure
      capture
    end

    click_on '登録'
    confirm
  end

  assert has_no_selector?('.ui-dialog')
  begin
    find_tr '#payroll_table', '基本給' do
      assert has_selector?('td', :text => salary, :count => 2)
    end
  ensure
    capture
  end
end
