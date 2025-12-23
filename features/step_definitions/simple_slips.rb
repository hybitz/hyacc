前提 /^(.*?)が(小口現金|普通預金|未払金（従業員）)の一覧を表示している$/ do |user_name, account_name|
  assert a = Account.find_by_name(account_name)

  sign_in name: user_name
  assert has_no_title?(a.name)

  with_capture do
    within '.menu' do
      assert has_link?(a.name)
      click_on a.name
    end
    assert has_selector?('#slipTable')
    assert has_title?(a.name)
  end
end

もし /^以下の簡易入力伝票(を|に)(登録|更新)する$/ do |prefix, action, ast_table|
  assert @account = Account.find_by_name(page.title)
  @slip ||= Slips::Slip.new(account_code: @account.code)

  normalize_table(ast_table).each do |row|
    field_name = row[0]
    value = row[1]

    case field_name
    when '年月'
      @slip.ym = value
    when '日'
      @slip.day = value
    when '摘要'
      @slip.remarks = value
    when '金額'
      if @account.debit?
        @slip.amount_decrease = value
      elsif @account.credit?
        @slip.amount_increase = value
      else
        fail '貸借区分が不明です。'
      end
    when '勘定科目'
      @slip.account_id = Account.find_by_name(value).id
    when '計上部門'
      @slip.branch_id = Branch.where(company_id: current_company.id, name: value).first!.id
    else
      fail "不明なフィールドです。field_name=#{field_name}"
    end
  end

  with_capture do
    form_selector = action == '登録' ? '#new_simple_slip' : "#edit_simple_slip"
    account = Account.find(@slip.account_id)
    branch = Branch.find(@slip.branch_id)

    within form_selector do
      fill_in 'simple_slip_ym', with: @slip.ym
      fill_in 'simple_slip_day', with: @slip.day
      fill_in 'simple_slip_remarks', with: @slip.remarks
      find(:select, 'simple_slip_account_id').first(:option, account.code_and_name).select_option
      assert has_select?('simple_slip_sub_account_id') if account.has_sub_accounts?

      select branch.name, from: 'simple_slip_branch_id'
      fill_in 'simple_slip_amount_increase', with: @slip.amount_increase
      fill_in 'simple_slip_amount_decrease', with: @slip.amount_decrease

      unless current_company.get_tax_type_for(account) == TAX_TYPE_NONTAXABLE
        assert has_field?('simple_slip_tax_rate_percent', with: /[0-9]+/)
      end
    end
  end

  click_on action
end

もし /^任意の簡易伝票の(コピー)をクリックする$/ do |action|
  assert @account = Account.find_by_name(page.title)

  assert tr = first('#slipTable tbody tr')
  within tr do
    @slip = Slips::Slip.new(:account_code => @account.code)
    @slip.id = tr['slip_id'].to_i
    @slip.remarks = find('td.remarks').text

    click_on action
  end
end

もし /^任意の簡易伝票の(編集|削除)をクリックする$/ do |action|
  assert @account = Account.find_by_name(page.title)

  assert has_no_dialog?

  assert tr = first('#slipTable tbody tr')
  within tr do
    @slip = Slips::Slip.new(account_code: @account.code)
    @slip.id = tr['slip_id'].to_i
    @slip.remarks = find('td.remarks').text
    find('td a.show').click
  end
  assert has_dialog?(/#{@account.name}.*/)
  assert has_selector?('.ui-dialog-buttonset')

  within '.ui-dialog-buttonset' do
    case action
    when '削除'
      accept_confirm do
        find('button', text: action).click
      end
    when '編集'
      find('button', text: action).click
    end
  end
end

もし /^任意の簡易伝票をクリックする$/ do
  assert @account = Account.find_by_name(page.title)

  assert tr = first('#slipTable tbody tr')
  within tr do
    @slip = Slips::Slip.new(account_code: @account.code)
    @slip.id = tr['slip_id'].to_i
    @slip.remarks = find('td.remarks').text

    click_on @slip.remarks
  end
end

もし /^登録画面で以下のような年月は6桁に変換される$/ do |ast_table|
  sign_in login_id: user.login_id unless current_user
  assert a = Account.find_by_name('小口現金')

  within '.menu' do
    assert has_link?(a.name)
    click_on a.name
  end

  form_selector ='#new_simple_slip'
  assert has_selector?(form_selector)

  normalize_table(ast_table).each do |row|
    input_val = row[0]

    within form_selector do
      fill_in 'simple_slip_ym', with: input_val
      find('#simple_slip_ym').send_keys(:tab)
      val = find('#simple_slip_ym').value
      assert_equal 6, val.length
    end
  end
end

もし /^編集画面で以下のような年月は6桁に変換される$/ do |ast_table|
  sign_in login_id: user.login_id unless current_user
  assert a = Account.find_by_name('小口現金')

  within '.menu' do
    assert has_link?(a.name)
    click_on a.name
  end

  if all('#slipTable tbody tr').empty?
    within '#new_simple_slip' do
      fill_in 'simple_slip_ym', with: '202401'
      fill_in 'simple_slip_day', with: '1'
      fill_in 'simple_slip_remarks', with: 'テスト'
      fill_in 'simple_slip_amount_increase', with: '1000'
    end
    click_on '登録'
    assert has_selector?('#slipTable tbody tr')
  end

  assert tr = first('#slipTable tbody tr')
  within tr do
    find('td a.show').click
  end
  assert has_dialog?(/#{a.name}.*/)
  within '.ui-dialog-buttonset' do
    find('button', text: '編集').click
  end

  form_selector = '#edit_simple_slip'
  assert has_selector?(form_selector)

  normalize_table(ast_table).each do |row|
    input_val = row[0]
    within form_selector do
      fill_in 'simple_slip_ym', with: input_val
      find('#simple_slip_ym').send_keys(:tab)
      val = find('#simple_slip_ym').value
      assert_equal 6, val.length
    end
  end
end

もし /^(登録|編集)画面で以下のような年月は変換されない$/ do |action, ast_table|
  form_selector = action == '登録' ? '#new_simple_slip' : "#edit_simple_slip"
  assert has_selector?(form_selector)

  normalize_table(ast_table).each do |row|
    input_val = row[0]

    within form_selector do
      fill_in 'simple_slip_ym', with: input_val
      find('#simple_slip_ym').send_keys(:tab)

      val = find('#simple_slip_ym').value
      assert_equal input_val, val
    end
  end
end

もし /^(登録|編集)画面で1月31日に年月に2を入力した場合は2月に変換される$/ do |action|
  form_selector = action == '登録' ? '#new_simple_slip' : "#edit_simple_slip"
  assert has_selector?(form_selector)
  within form_selector do
    page.execute_script <<~JS
      window._originalDate = Date;
      window.Date = function(...args) {
        if (args.length === 0) {
          return new window._originalDate(2025, 0, 31);
        }
        return new window._originalDate(...args);
      };
    JS

    fill_in 'simple_slip_ym', with: '2'
    find('#simple_slip_ym').send_keys(:tab)

    val = find('#simple_slip_ym').value
    assert_match(/\d{4}02/, val)

    page.execute_script <<~JS
      if (window._originalDate) {
        window.Date = window._originalDate;
        delete window._originalDate;
      }
    JS
  end
end

もし /^(登録|編集)画面で消費税に(外税|内税)、(増加|減少)金額に10000を入力する$/ do |action, tax_type, amount_type|
  form_selector = action == '登録' ? '#new_simple_slip' : '#edit_simple_slip'
  amount_selector = amount_type == '増加' ? 'simple_slip_amount_increase' : 'simple_slip_amount_decrease'
  assert has_selector?(form_selector)
  within form_selector do
    fill_in 'simple_slip_amount_increase', with: ''
    fill_in 'simple_slip_amount_decrease', with: ''
    select tax_type, from: 'simple_slip_tax_type'
    fill_in amount_selector, with: '10000'
  end
end

もし /^(登録|編集)画面で以下のように年月の入力があると税率、税額、合計が更新される$/ do |action, ast_table|
  form_selector = action == '登録' ? '#new_simple_slip' : "#edit_simple_slip"
  assert has_selector?(form_selector)
  rows = normalize_table(ast_table)
  rows[1..-1].each do |r|
    ym_input        = r[0]
    expected_rate   = r[1]
    expected_amount = r[2]
    expected_total_amount = r[3]
    within form_selector do
      fill_in 'simple_slip_ym', with: ym_input
      find('#simple_slip_ym').send_keys(:tab)

      actual_rate = find('#simple_slip_tax_rate_percent').value
      assert_equal expected_rate, actual_rate

      side = find('#simple_slip_amount_increase').value.present? ? 'increase' : 'decrease'
      actual_tax_amount = find("#simple_slip_tax_amount_#{side}").value
      assert_equal expected_amount, actual_tax_amount

      actual_total_amount = find("div.sum_amount_#{side}").text.delete(',')
      assert_equal expected_total_amount, actual_total_amount
    end
  end
end

もし /^簡易伝票の一覧を開く$/ do
  sign_in login_id: user.login_id unless current_user
  assert a = Account.find_by_name('小口現金')

  within '.menu' do
    assert has_link?(a.name)
    click_on a.name
  end

  assert has_selector?('#new_simple_slip')
end

もし /^日の入力欄にフォーカスされている$/ do
  form_selector = page.has_selector?('#edit_simple_slip') ? '#edit_simple_slip' : '#new_simple_slip'

  within form_selector do
    assert_equal 'simple_slip_day', page.evaluate_script('document.activeElement.id')
  end
end

もし /^(.*?)を押すと(.*?)の入力欄にフォーカスが移動する$/ do |keys, ymd|
  form_selector = page.has_selector?('#edit_simple_slip') ? '#edit_simple_slip' : '#new_simple_slip'
  key = keys == 'Ctrl + Y' ? 'y' : 'd'
  input = ymd == '年月' ? 'simple_slip_ym' : 'simple_slip_day'
  within form_selector do
    page.driver.browser.action.key_down(:control).send_keys(key).key_up(:control).perform
    assert_equal input, page.evaluate_script('document.activeElement.id')
  end
end

もし /^簡易伝票の編集ダイアログを開く$/ do
  sign_in login_id: user.login_id unless current_user
  assert a = Account.find_by_name('小口現金')

  within '.menu' do
    assert has_link?(a.name)
    click_on a.name
  end

  if all('#slipTable tbody tr').empty?
    within '#new_simple_slip' do
      fill_in 'simple_slip_ym', with: '202401'
      fill_in 'simple_slip_day', with: '1'
      fill_in 'simple_slip_remarks', with: 'テスト'
      fill_in 'simple_slip_amount_increase', with: '1000'
    end
    click_on '登録'
    assert has_selector?('#slipTable tbody tr')
  end

  assert tr = first('#slipTable tbody tr')
  within tr do
    find('td a.show').click
  end
  assert has_dialog?(/#{a.name}.*/)
  within '.ui-dialog-buttonset' do
    find('button', text: '編集').click
  end

  assert has_selector?('#edit_simple_slip')
end

もし /^簡易伝票の編集ダイアログを閉じる$/ do
  assert has_selector?('#edit_simple_slip')
  within('.ui-dialog-buttonpane') do
    click_on '閉じる'
  end
  assert has_no_selector?('#edit_simple_slip')
end

ならば /^(小口現金|普通預金|未払金（従業員）)の一覧に遷移する$/ do |account_name|
  assert account = Account.where(:name => account_name).first

  with_capture do
    assert has_title?(account.name)
  end
end

ならば /^簡易伝票の(参照|編集)ダイアログが表示される$/ do |action|
  with_capture do
    case action
    when '参照'
      assert has_selector?('#show_simple_slip')
    when '編集'
      assert has_selector?('#edit_simple_slip')
    end
  end
end
