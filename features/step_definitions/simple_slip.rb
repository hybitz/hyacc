# coding: UTF-8

前提 /^(小口現金|普通預金|未払金（従業員）)の一覧を表示している$/ do |account_name|
  @account = Account.find_by_name(account_name)
  assert_visit "/simple/#{@account.code}"
end

もし /^以下の簡易入力伝票(を|に)(登録|更新)する$/ do |prefix, action, ast_table|
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
    when '領収書'
      system "rm -f #{Rails.root}/#{UPLOAD_DIRECTORY}/receipt/#{@slip.ym.to_i * 100 + @slip.day.to_i}/#{value}"
      path = "#{Rails.root}/tmp/#{value}"
      FileUtils.mkdir_p File.dirname(path)
      system "echo '領収書テスト' > #{path}"
      @slip.receipt_file = path
    else
      fail "不明なフィールドです。field_name=#{field_name}"
    end
  end
  
  form_selector = action == '登録' ? '#slip_new_form' : "#slip_edit_form"
  within form_selector do
    fill_in 'slip_ym', :with => @slip.ym
    fill_in 'slip_day', :with => @slip.day
    fill_in 'slip_remarks', :with => @slip.remarks
    select Account.find(@slip.account_id).name, :from => 'slip_account_id'
    select Branch.find(@slip.branch_id).name, :from => 'slip_branch_id'
    fill_in 'slip_amount_increase', :with => @slip.amount_increase
    fill_in 'slip_amount_decrease', :with => @slip.amount_decrease
    attach_file 'slip_receipt_file', @slip.receipt_file if @slip.receipt_file.present?
  end

  capture
  click_on action
end

もし /^領収書を削除して(更新)する$/ do |action|
  click_on '領収書削除'
  assert page.has_no_selector?('input[type=button][value=領収書削除]', :visible => true)
  capture
  click_on action
end

もし /^任意の簡易伝票の(参照|編集|削除|コピー)をクリックする$/ do |action|
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
  @account = Account.find_by_name(account_name)
  assert_url "/simple/#{@account.code}"
end

ならば /^簡易伝票の(参照|編集)ダイアログが表示される$/ do |action|
  wait_until { page.has_selector?("#slip_edit_form", :visible => true) }
  capture
end

かつ /^電子領収書(も|が)(登録|削除)されている$/ do |prefix, action|
  find('#slipTable').all('tr[slip_id]').each do |tr|
    if tr.text.include?(@slip.remarks)
      assert page.has_link?('(電子)') if action == '登録'
      assert page.has_no_link?('(電子)') if action == '削除'
      break
    end
  end
end
