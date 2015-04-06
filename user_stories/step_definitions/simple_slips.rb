もし /^資本金の仕訳を登録します$/ do |ast_table|
  assert row = normalize_table(ast_table).last
  assert_equal row[1], row[3]

  click_on row[0]
  capture row[0]

  within '#slip_new_form' do
    fill_in 'slip_remarks', :with => '営業を開始'
    select row[2], :from => 'slip_account_id'
    fill_in 'slip_amount_increase', :with => row[1]
  end
  capture '仕訳を登録'
  click_on '登録'

  capture
end
