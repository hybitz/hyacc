前提 /^振替伝票を表示している$/ do
  assert_visit '/journals'
end

もし /^任意の振替伝票の(編集|削除)をクリックする$/ do |action|
  assert has_selector?('#journals_table tr')

  all('#journals_table tbody tr').each do |tr|
    within tr do
      find('td a').click
    end
    
    assert has_dialog?(/振替伝票.*/)
    assert has_selector?('.ui-dialog-buttonset')
    within '.ui-dialog-buttonset' do
      if has_selector?('button', text: action)
        case action
        when '削除'
          accept_confirm do
            find('button', text: action).click
          end
        when '編集'
          find('button', text: action).click
        end
      else
        next
      end
    end
  end
end

もし /^任意の振替伝票の摘要をクリックする$/ do
  selector = '#journals_table tbody tr'
  assert has_selector?(selector)

  within first(selector) do
    click_on all('td')[3].text.strip
  end
end

もし /^以下の振替伝票(を|に)(登録|更新)する$/ do |prefix, action, ast_table|
  table = normalize_table(ast_table)
  header = table[1]
  details = [table[4], table[5]]

  @journal = Journal.new
  @journal.ym = header[0]
  @journal.day = header[1]
  @journal.remarks = header[2]

  if header[3].present?
    path = File.join(Rails.root, 'tmp', header[3])
    FileUtils.mkdir_p File.dirname(path)
    FileUtils.touch(path)
    @journal.build_receipt(file: File.new(path))
  end

  details.each do |d|
    account = Account.find_by_name(d[1])
    branch = Branch.find_by_name(d[3])

    detail = @journal.journal_details.build
    detail.dc_type = DC_TYPES.invert[d[0]]
    detail.account_id = account.id
    detail.account_name = account.name
    detail.branch_id = branch.id
    detail.branch_name = branch.name
    detail.input_amount = d[4]

    account.sub_accounts.each do |sa|
      if sa.name == d[2]
        detail.sub_account_id = sa.id
        detail.sub_account_name = sa.name
      end
    end if d[2].present?
  end

  with_capture do
    within '#journal_form' do
      fill_in 'journal[ym]', with: @journal.ym
      fill_in 'journal[day]', with: @journal.day
      fill_in 'journal[remarks]', with: @journal.remarks
      attach_file '領収書', @journal.receipt.file.path if @journal.receipt.present?

      @journal.journal_details.each_with_index do |detail, i|
        prefix = "journal[journal_details_attributes][#{i}]"

        select detail.dc_type_name, from: "#{prefix}[dc_type]"
        select detail.account_name, from: "#{prefix}[account_id]"
        assert has_selector?(".journal_details [data-index=\"#{i}\"].sub_account_ready")
        select detail.sub_account_name, from: "#{prefix}[sub_account_id]" if detail.sub_account_id.present?
        select detail.branch_name, from: "#{prefix}[branch_id]"
        fill_in "#{prefix}[input_amount]", with: detail.input_amount
      end
    end
  end

  click_on action
end

ならば /^振替伝票の一覧に遷移する$/ do
  assert has_title?('振替伝票')
  assert has_no_selector?('.notice')
  assert_url '/journals'
end

ならば /^振替伝票の(参照|追加|編集)ダイアログが表示される$/ do |action|
  assert has_selector?("div.ui-dialog", :visible => true)
  capture
end

もし /^振替伝票の追加ダイアログを開きます。$/ do
  sign_in :login_id => user.login_id
  click_on '振替伝票'
  assert has_title?('振替伝票')
  click_on '追加'
  assert has_dialog?(/振替伝票.*/)
  capture
end

もし /^伝票ヘッダを入力します。$/ do
  ym = current_company.current_fiscal_year.start_year_month

  fill_in 'journal[ym]', with: ym
  fill_in 'journal[day]', with: 1
  fill_in 'journal[remarks]', with: '家賃等の支払い'
  capture
end

もし /^借方に家賃と光熱費を入力します。$/ do
  with_capture do
    select '借方', from: 'journal[journal_details_attributes][0][dc_type]'
    select '地代家賃', from: 'journal[journal_details_attributes][0][account_id]'
    fill_in 'journal[journal_details_attributes][0][input_amount]', with: 78000

    select '借方', from: 'journal[journal_details_attributes][1][dc_type]'
    select '光熱費', from: 'journal[journal_details_attributes][1][account_id]'
    fill_in 'journal[journal_details_attributes][1][input_amount]', with: 15000
  end
end

もし /^明細を追加して町内会費を入力します。$/ do
  with_capture do
    click_on '明細追加'

    select '借方', from: 'journal[journal_details_attributes][2][dc_type]'
    select '諸会費', from: 'journal[journal_details_attributes][2][account_id]'
    fill_in 'journal[journal_details_attributes][2][input_amount]', with: 3000
    fill_in 'journal[journal_details_attributes][2][note]', with: '町内会費として'
  end
end

もし /^明細をもう１つ追加して、現金での支払いを入力します。$/ do
  with_capture do
    click_on '明細追加'

    select '貸方', from: 'journal[journal_details_attributes][3][dc_type]'
    select '小口現金', from: 'journal[journal_details_attributes][3][account_id]'
    fill_in 'journal[journal_details_attributes][3][input_amount]', with: 96000
  end
end

もし /^登録して終了です。$/ do
  with_capture do
    assert has_no_selector?('.notice')
    within_dialog do
      click_on '登録'
    end
    pause 3
    assert has_no_dialog?
    assert has_selector?('.notice')
  end
end

もし /^以下のような振替日は不正$/ do |ast_table|
  sign_in login_id: user.login_id unless current_user
  click_on '振替伝票'
  assert has_title?('振替伝票')
  click_on '追加'
  assert has_dialog?(/振替伝票.*追加/)

  normalize_table(ast_table).each do |row|
    prefix = 'journal_journal_details_attributes_1'
    year, month, day = row[0].split('-')

    fill_in "#{prefix}_auto_journal_year", with: year
    fill_in "#{prefix}_auto_journal_month", with: month
    fill_in "#{prefix}_auto_journal_day", with: day
    capture
    accept_alert do
      click_on '登録'
    end
  end
end

もし /^以下のような年月は6桁に変換される$/ do |ast_table|
  sign_in login_id: user.login_id unless current_user
  click_on '振替伝票'
  assert has_title?('振替伝票')
  click_on '追加'
  assert has_dialog?(/振替伝票.*追加/)

  normalize_table(ast_table).each do |row|
    input_val = row[0]

    fill_in 'journal_ym', with: input_val
    find('#journal_ym').send_keys(:tab)

    val = find('#journal_ym').value
    assert_equal 6, val.length
  end
end

もし /^以下のような年月は変換されない$/ do |ast_table|
  assert has_dialog?(/振替伝票.*追加/)

  normalize_table(ast_table).each do |row|
    input_val = row[0]

    fill_in 'journal_ym', with: input_val
    find('#journal_ym').send_keys(:tab)

    val = find('#journal_ym').value
    assert_equal input_val, val
  end
end

もし /^消費税に外税、金額に10000を入力する$/ do
  sign_in login_id: user.login_id unless current_user
  click_on '振替伝票'
  assert has_title?('振替伝票')
  click_on '追加'
  assert has_dialog?(/振替伝票.*追加/)

  select '外税', from: 'journal_journal_details_attributes_0_tax_type'

  fill_in 'journal_journal_details_attributes_0_input_amount', with: '10000'
end

もし /^以下のように年月の入力があると税率と税額が更新される$/ do |ast_table|
  rows = normalize_table(ast_table)
  rows[1..-1].each do |r|
    ym_input        = r[0]
    expected_rate   = r[1]
    expected_amount = r[2]

    fill_in 'journal_ym', with: ym_input
    find('#journal_ym').send_keys(:tab)

    actual_rate = find('#journal_journal_details_attributes_0_tax_rate_percent').value
    assert_equal expected_rate, actual_rate

    actual_tax_amount = find('#journal_journal_details_attributes_0_tax_amount').value
    assert_equal expected_amount, actual_tax_amount
  end
end

かつ /^電子領収書(も|が)(登録|削除)されている$/ do |prefix, action|
  find('#journals_table tbody').all('tr').each do |tr|
    if tr.text.include?(@journal.remarks)
      assert has_link?('(電子)') if action == '登録'
      assert has_no_link?('(電子)') if action == '削除'
      break
    end
  end
end
