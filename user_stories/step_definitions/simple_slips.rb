もし /^資本金の仕訳を登録$/ do |ast_table|
  assert row = normalize_table(ast_table).last
  assert_equal row[1], row[3]

  click_on row[0]
  assert has_title?(row[0])
  capture row[0]
  assert has_no_selector?('#slipTable tbody tr')

  within '#new_simple_slip' do
    fill_in 'simple_slip_ym', :with => current_user.company.founded_year_month
    fill_in 'simple_slip_day', :with => current_user.company.founded_date.day
    fill_in 'simple_slip_remarks', :with => '営業を開始'
    select row[2], :from => 'simple_slip_account_id'
    fill_in 'simple_slip_amount_increase', :with => row[1].gsub(',', '')
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
    assert has_no_selector? 'span.notice'
    assert has_selector? '.tax_type_ready'

    begin
      count = all('#slipTable tbody tr').count
      within '#new_simple_slip' do
        fill_in 'simple_slip_ym', :with => ymd.split('-').slice(0, 2).join
        fill_in 'simple_slip_day', :with => ymd.split('-').last
        fill_in 'simple_slip_remarks', :with => remarks
        find(:select, 'simple_slip_account_id').first(:option, account.code_and_name).select_option
        fill_in 'simple_slip_amount_decrease', :with => amount
        click_on '登録'
      end
      assert has_selector? 'span.notice'
      assert has_selector?('#slipTable tbody tr', :count => count + 1)
    ensure
      capture
    end
  end
end

もし /^売上を計上$/ do |ast_table|
  normalize_table(ast_table)[1..-1].each do |row|
    with_capture do
      assert_equal row[3], row[5]

      ymd = row[0]
      remarks = row[1]
      simple_slip = row[2]
      amount = row[3].to_ai
      account = Account.where(:name => row[4], :deleted => false).first!

      visit_simple_slip(:account => Account.find_by_name(simple_slip))

      count = all('#slipTable tbody tr').count
      within '#new_simple_slip' do
        fill_in 'simple_slip_ym', :with => ymd.split('-').slice(0, 2).join
        fill_in 'simple_slip_day', :with => ymd.split('-').last
        fill_in 'simple_slip_remarks', :with => remarks
        find(:select, 'simple_slip_account_id').first(:option, account.code_and_name).select_option
      end
      assert has_selector?('.sub_account_ready')
      within '#new_simple_slip' do
        fill_in 'simple_slip_amount_increase', :with => amount
        click_on '登録'
      end
      assert has_selector?('#slipTable tbody tr', :count => count + 1)
    end
  end
end

もし /^取引先からの入金$/ do |ast_table|
  normalize_table(ast_table)[1..-1].each do |row|
    assert_equal row[3], row[5]

    ym = row[0].split('-').slice(0, 2).join
    day = row[0].split('-').last
    remarks = row[1]
    simple_slip = row[2]
    amount = row[3].gsub(',', '')
    assert account = Account.where(:name => row[4], :deleted => false).first

    with_capture do
      visit_simple_slip(:account => Account.find_by_name(simple_slip))

      count = all('#slipTable tbody tr').count
      within '#new_simple_slip' do
        fill_in 'simple_slip_ym', :with => ym
        fill_in 'simple_slip_day', :with => day
        fill_in 'simple_slip_remarks', :with => remarks
        find(:select, 'simple_slip_account_id').first(:option, account.code_and_name).select_option
        fill_in 'simple_slip_amount_increase', :with => amount
        sleep 3
        click_on '登録'
      end
      assert has_selector?('span.notice')
      assert has_selector?('#slipTable tbody tr', :count => count + 1)
    end
  end
end

もし /^数回にわたり、ATM手数料を間違って支払利息として登録してしまった$/ do |ast_table|
  table = normalize_table(ast_table)
  assert @account = Account.find_by_name(table[1][0])
  assert tax_type_name = table[1][2]
  assert amount = table[1][3].gsub(',', '').to_i

  4.times do |i|
    with_capture do
      visit_simple_slip(:account => Account.find_by_code(ACCOUNT_CODE_ORDINARY_DIPOSIT))

      count = all('#slipTable tbody tr').count
      fill_in 'simple_slip_ym', :with => '201308'
      fill_in 'simple_slip_day', :with => i + 1
      fill_in 'simple_slip_remarks', :with => "ATM手数料（科目間違い #{i+1} 回目）"
      find(:select, 'simple_slip_account_id').first(:option, @account.code_and_name).select_option
      assert has_selector?('.tax_type_ready')
      select tax_type_name, :from => 'simple_slip_tax_type'
      fill_in 'simple_slip_amount_decrease', :with => amount
      click_on '登録'
      assert has_selector?('#slipTable tbody tr', :count => count + 1)
    end
  end
end

もし /^出経費を従業員が立て替えて支払い$/ do |ast_table|
  assert @account = Account.find_by_name('未払金（従業員）')

  normalize_table(ast_table)[1..-1].each do |row|
    ym = row[0].split('-')[0..1].join
    day = row[0].split('-').last
    remarks = row[1]
    assert account = Account.where(:name => row[2], :deleted => false).first
    amount = row[3].to_ai

    with_capture do
      visit_simple_slip(:account => @account)

      count = all('#slipTable tbody tr').count
      within '#new_simple_slip' do
        fill_in 'simple_slip_ym', :with => ym
        fill_in 'simple_slip_day', :with => day
        fill_in 'simple_slip_remarks', :with => remarks
        find(:select, 'simple_slip_account_id').first(:option, account.code_and_name).select_option
        fill_in 'simple_slip_amount_increase', :with => amount
        click_on '登録'
      end
      assert has_selector?('.notice')
      assert has_selector?('#slipTable tbody tr', :count => count + 1)
    end
  end
end

もし /^(.*?)の実績$/ do |branch_name, ast_table|
  assert @branch = Branch.where(:name => branch_name).first

  sign_out if current_user
  sign_in(@branch.employees.first.user)

  @simple_slips = to_simple_slips(ast_table)
  @simple_slips.each do |ss|
    create_simple_slip(ss)
  end
end

もし /^(.*?)で(パソコン|サーバマシン)を購入$/ do |branch_name, what, ast_table|
  assert @branch = Branch.where(:name => branch_name).first
  row = normalize_table(ast_table)[1]

  ss = SimpleSlip.new
  ss.ym = row[0].split('-')[0..1].join
  ss.day = row[0].split('-').last
  ss.remarks = row[1]
  ss.my_account_id = Account.where(:name => row[4], :deleted => false).first.id
  ss.account_id = Account.where(:name => row[2], :deleted => false).first.id
  ss.branch_id = @branch.id
  ss.amount_decrease = row[5].to_ai

  create_simple_slip(ss)

  with_capture do
    find_tr '#slipTable', ss.remarks do
      click_on '参照'
    end
    assert has_dialog?
    
    within '#edit_simple_slip' do
      assert has_selector?('#account_detail')
      assert @asset_code = find('#account_detail').text.split('：').last
    end
  end
end
