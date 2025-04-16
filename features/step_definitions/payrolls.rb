ならば /^賃金台帳の一覧に遷移する$/ do
  with_capture do
    assert has_title?('賃金台帳')
    assert has_selector?('#finder_employee_id')
  end
end

ならば /^賃金台帳が表示される$/ do
  assert_url '/payrolls(\?.*)?'
end

もし /^検索条件の年度を(.*?)年に変更し、表示をクリックする$/ do |year|
  select year, from: 'finder[fiscal_year]'
  click_on '表示'
end

ならば /^(.*?)年度の賃金台帳の一覧が表示される$/ do |year|
  ym = FiscalYear.find_by(company: current_company, fiscal_year: year).start_year_month
  within all('#payroll_table thead tr th')[1] do
    assert has_selector?('a', text: ym)
  end
end

もし /^基本給を変更した時、以下のように自動変更される$/ do |ast_table|
  rows = normalize_table(ast_table)
  rows[1..-1].each do |r|
    ym = r[0] if r[0].present?
    status = r[1]
    base_salary = r[2]
    monthly_standard = r[3]
    health_insurance = r[4]
    welfare_pension = r[5]

    case status
    when '初期値'
      click_on ym
      assert has_selector?('.ui-dialog')
      within ('.ui-dialog') do
        assert_equal base_salary, find('#payroll_base_salary').value
        assert_equal monthly_standard, find('#payroll_monthly_standard').value
        assert_equal health_insurance, find('#payroll_health_insurance').value
        assert_equal welfare_pension, find('#payroll_welfare_pension').value
      end

    when '変更後'
      fill_in 'payroll[base_salary]', with: base_salary
      # changeメソッドを発火させる
      fill_in 'payroll[commuting_allowance]', with: 0

      within ('.ui-dialog') do
        assert_equal monthly_standard, find('#payroll_monthly_standard').value
        assert_equal health_insurance, find('#payroll_health_insurance').value
        assert_equal welfare_pension, find('#payroll_welfare_pension').value
        click_on '登録'
      end
    end
  end
end

もし /^給与支給日を変更した時、以下のように自動変更される$/ do |ast_table|
  rows = normalize_table(ast_table)
  rows[1..-1].each do |r|
    ym = r[0] if r[0].present?
    status = r[1]
    base_salary = r[2]
    monthly_standard = r[3]
    health_insurance = r[4]
    welfare_pension = r[5]
    pay_day = r[6]

    case status
    when '変更前'
      click_on ym
      assert has_selector?('.ui-dialog')
      within ('.ui-dialog') do
        fill_in 'payroll[base_salary]', with: base_salary
        # changeメソッドを発火させる
        fill_in 'payroll[commuting_allowance]', with: 0
        assert_equal base_salary, find('#payroll_base_salary').value
        assert_equal monthly_standard, find('#payroll_monthly_standard').value
        assert_equal health_insurance, find('#payroll_health_insurance').value
        assert_equal welfare_pension, find('#payroll_welfare_pension').value
        assert_equal pay_day, find('#payroll_pay_day').value
      end

    when '変更後'
      fill_in 'payroll[pay_day]', with: pay_day
      # changeメソッドを発火させる
      fill_in 'payroll[commuting_allowance]', with: 0

      within ('.ui-dialog') do
        assert_equal base_salary, find('#payroll_base_salary').value
        assert_equal monthly_standard, find('#payroll_monthly_standard').value
        assert_equal health_insurance, find('#payroll_health_insurance').value
        assert_equal welfare_pension, find('#payroll_welfare_pension').value
        assert_equal pay_day, find('#payroll_pay_day').value
      end
    end
  end
end


