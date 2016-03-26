前提 /^振替伝票の一覧を表示している$/ do
  assert_visit '/journals'
end

もし /^任意の振替伝票の(参照|編集|削除)をクリックする$/ do |action|
  all('#journals_table tr').each do |tr|
    next unless tr.has_link?(action)
    within tr do
      case action
      when '削除'
        accept_confirm do
          click_on action
        end
      else
        click_on action
      end
    end
    break
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
    @journal.build_receipt(:file => File.new(path))
  end

  details.each do |d|
    account = Account.find_by_name(d[1])
    branch = Branch.find_by_name(d[3])

    detail = JournalDetail.new
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

    @journal.journal_details << detail
  end

  begin
    within '#journal_form' do
      fill_in 'journal_ym', :with => @journal.ym
      fill_in 'journal_day', :with => @journal.day
      fill_in 'journal_remarks', :with => @journal.remarks
      attach_file '領収書', @journal.receipt.file.path if @journal.receipt.present?

      @journal.journal_details.each_with_index do |detail, i|
        prefix = "journal_journal_details_attributes_#{i}_"

        select detail.dc_type_name, :from => "#{prefix}_dc_type"
        select detail.account_name, :from => "#{prefix}_account_id"
        select detail.sub_account_name, :from => "#{prefix}_sub_account_id" if detail.sub_account_id.present?
        select detail.branch_name, :from => "#{prefix}_branch_id"
        fill_in "#{prefix}_input_amount", :with => detail.input_amount
      end

      find('#journal_ym').click # キャプチャ前にフォーカスイベントを発生させたいだけ
    end

    click_on action
  ensure
    capture
  end
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
  ym = current_user.company.current_fiscal_year.start_year_month

  fill_in 'journal_ym', :with => ym
  fill_in 'journal_day', :with => 1
  fill_in 'journal_remarks', :with => '家賃等の支払い'
  capture
end

もし /^借方に家賃と光熱費を入力します。$/ do
  select '借方', :from => "journal_journal_details_attributes_0__dc_type"
  select '地代家賃', :from => "journal_journal_details_attributes_0__account_id"
  fill_in 'journal_journal_details_attributes_0__input_amount', :with => 78000

  select '借方', :from => "journal_journal_details_attributes_1__dc_type"
  select '光熱費', :from => "journal_journal_details_attributes_1__account_id"
  fill_in 'journal_journal_details_attributes_1__input_amount', :with => 15000

  capture
end

もし /^明細を追加して町内会費を入力します。$/ do
  click_on '明細追加'

  select '借方', :from => 'journal_journal_details_attributes_2__dc_type'
  select '諸会費', :from => 'journal_journal_details_attributes_2__account_id'
  fill_in 'journal_journal_details_attributes_2__input_amount', :with => 3000
  fill_in 'journal_journal_details_attributes_2__note', :with => '町内会費として'

  capture
end

もし /^明細をもう１つ追加して、現金での支払いを入力します。$/ do
  click_on '明細追加'

  select '貸方', :from => "journal_journal_details_attributes_3__dc_type"
  select '小口現金', :from => "journal_journal_details_attributes_3__account_id"
  fill_in 'journal_journal_details_attributes_3__input_amount', :with => 96000

  capture
end

もし /^登録して終了です。$/ do
  begin
    click_on '登録'
    assert has_no_selector?("div.ui-dialog", :visible => true)
    assert has_selector?('.notice')
  ensure
    capture
  end
end

もし /^以下のような振替日は不正$/ do |ast_table|
  sign_in :login_id => user.login_id unless current_user
  click_on '振替伝票'
  assert has_title?('振替伝票')
  click_on '追加'
  assert has_dialog?(/振替伝票.*追加/)

  normalize_table(ast_table).each do |row|
    prefix = 'journal_journal_details_attributes_1_'
    year, month, day = row[0].split('-')

    fill_in "#{prefix}_auto_journal_year", :with => year
    fill_in "#{prefix}_auto_journal_month", :with => month
    fill_in "#{prefix}_auto_journal_day", :with => day
    capture
    accept_alert do
      click_on '登録'
    end
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
