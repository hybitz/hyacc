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

もし /^受注した仕事にかかった経費を計上$/ do |ast_table|
  normalize_table(ast_table)[1..-1].each do |row|
    assert_equal row[3], row[5]

    ymd = row[0]
    remarks = row[1]
    account = Account.where(:name => row[2], :deleted => false).first!
    amount = row[3].gsub(',', '')
    simple_slip = row[4]

    click_on simple_slip
    assert has_title? simple_slip
    count = all('#slipTable tbody tr').count

    fill_in 'slip_ym', :with => ymd.split('-').slice(0, 2).join
    fill_in 'slip_day', :with => ymd.split('-').last
    fill_in 'slip_remarks', :with => remarks
    select account.code_and_name, :from =>  'slip_account_id'
    fill_in 'slip_amount_decrease', :with => amount
    click_on '登録'
    assert has_selector?('#slipTable tbody tr', :count => count + 1)
    capture
  end
end
