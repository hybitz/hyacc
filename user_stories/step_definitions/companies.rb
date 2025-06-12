もし /^給与支払日を翌月7日に設定$/ do
  visit_companies

  find_tr '.company', '給与支払日' do
    click_on '変更'
  end
  assert has_selector?('.edit_company')
  within '.edit_company' do
    select '翌月', :from => 'company_month_of_pay_day_definition'
    fill_in 'company_day_of_pay_day_definition', :with => '7'
  end
  capture

  click_on '更新'
  assert has_no_selector?('.edit_company')
  capture
end
