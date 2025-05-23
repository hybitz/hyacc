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
