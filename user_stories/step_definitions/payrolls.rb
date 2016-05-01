もし /^賃金台帳に今月分の給与を登録$/ do |ast_table|
  sign_in User.first unless current_user

  @ym = 201309
  @salary = normalize_table(ast_table)[0][1].to_ai

  click_on '賃金台帳'
  assert has_title?('賃金台帳')
  assert has_no_selector?('#payroll_table')

  click_on '表示'
  assert has_selector?('#payroll_table')

  click_on @ym
  within '.ui-dialog' do
    begin
      fill_in '基本給', :with => @salary
      assert has_selector?('form[insurance_loaded]');

      fill_in '住民税', :with => 0
    ensure
      capture
    end

    accept_confirm do
      click_on '登録'
    end
  end

  begin
    assert has_no_selector?('.ui-dialog')
    find_tr '#payroll_table', '基本給' do
      assert has_selector?('td', :text => @salary.to_as, :count => 2)
    end
  ensure
    capture
  end
end

もし /^税金および保険料は以下のとおり$/ do |ast_table|
  assert @ym
  assert @salary

  normalize_table(ast_table).each do |row|
    find_tr '#payroll_table', row[0] do
      assert has_selector?('td', :text => row[1], :count => 2)
    end
  end
end

もし /^健康保険は (.*?) 円$/ do |amount|
  assert @ym
  assert @salary

  find_tr '#payroll_table', '健康保険料' do
    assert has_selector?('td', :text => amount, :count => 2)
  end
end

もし /^厚生年金は (.*?) 円$/ do |amount|
  assert @ym
  assert @salary

  find_tr '#payroll_table', '厚生年金保険料' do
    assert has_selector?('td', :text => amount, :count => 2)
  end
end

もし /^所得税は (.*?) 円$/ do |amount|
  assert @ym
  assert @salary

  find_tr '#payroll_table', '所得税' do
    assert has_selector?('td', :text => amount, :count => 2)
  end
end
