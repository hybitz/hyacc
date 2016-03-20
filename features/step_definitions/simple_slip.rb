前提 /^(小口現金|普通預金|未払金（従業員）)の一覧を表示している$/ do |account_name|
  sign_in user unless current_user

  within '.menu' do
    click_on account_name
  end
  assert has_title?(account_name)
  assert has_selector? '.tax_type_ready'
end

もし /^以下の簡易入力伝票(を|に)(登録|更新)する$/ do |prefix, action, ast_table|
  @account = Account.find_by_name(page.title)
  @slip ||= Slips::Slip.new(:account_code => @account.code)

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
      @slip.branch_id = Branch.where(:company_id => current_user.company_id, :name => value).first!.id
    else
      fail "不明なフィールドです。field_name=#{field_name}"
    end
  end

  form_selector = action == '登録' ? '#slip_new_form' : "#slip_edit_form"
  account = Account.find(@slip.account_id)
  branch = Branch.find(@slip.branch_id)

  within form_selector do
    fill_in 'slip_ym', :with => @slip.ym
    fill_in 'slip_day', :with => @slip.day
    fill_in 'slip_remarks', :with => @slip.remarks

    select account.name, :from => 'slip_account_id'
    assert has_select?('slip_tax_type', :selected => account.tax_type_name)

    select branch.name, :from => 'slip_branch_id'

    fill_in 'slip_amount_increase', :with => @slip.amount_increase
    fill_in 'slip_amount_decrease', :with => @slip.amount_decrease
  end

  capture
  click_on action
end

もし /^任意の簡易伝票の(参照|編集|削除|コピー)をクリックする$/ do |action|
  assert @account = Account.find_by_name(page.title)

  within '#slipTable' do
    tr = all('tr.cashRow')[1]
    @slip = Slips::Slip.new(:account_code => @account.code)
    @slip.id = tr['slip_id'].to_i

    within tr do
      @slip.remarks = find('td.remarks').text
      click_on action
      confirm if action == '削除'
    end
  end
end

ならば /^(小口現金|普通預金|未払金（従業員）)の一覧に遷移する$/ do |account_name|
  assert account = Account.where(:name => account_name).first

  assert has_title?(account.name)
  assert has_selector?('.tax_type_ready');
  capture
end

ならば /^簡易伝票の(参照|編集)ダイアログが表示される$/ do |action|
  wait_until { has_selector?("#slip_edit_form", :visible => true) }
  capture
end
