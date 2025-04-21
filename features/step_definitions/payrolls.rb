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


