もし /^資本金の仕訳を登録します$/ do |ast_table|
  assert row = normalize_table(ast_table).last
  assert_equal row[1], row[3]

  click_on row[0]
  capture row[0]
  assert has_no_selector?('#slipTable tbody tr')

  within '#slip_new_form' do
    fill_in 'slip_ym', :with => current_user.company.founded_year_month
    fill_in 'slip_day', :with => current_user.company.founded_date.day
    fill_in 'slip_remarks', :with => '営業を開始'
    select row[2], :from => 'slip_account_id'
    fill_in 'slip_amount_increase', :with => row[1].gsub(',', '')
  end
  capture '仕訳を登録'
  click_on '登録'

  capture
  assert has_selector?('#slipTable tbody tr', :count => 1, :text => '営業を開始')
end
