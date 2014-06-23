# coding: UTF-8

include HyaccConstants

前提 /^振替伝票の一覧を表示している$/ do
  assert_visit '/journal/list'
end

もし /^任意の振替伝票の(参照|編集|削除)をクリックする$/ do |action|
  all('#journals_table tr').each do |tr|
    if tr.has_link?(action)
      click_on action
      confirm if action == '削除'
      break
    end
  end
end

もし /^以下の振替伝票(を|に)(登録|更新)する$/ do |prefix, action, ast_table|
  table = normalize_table(ast_table)
  header = table[1]
  details = [table[4], table[5]]
  
  @journal_header = JournalHeader.new
  @journal_header.ym = header[0]
  @journal_header.day = header[1]
  @journal_header.remarks = header[2]
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
    
    @journal_header.journal_details << detail
  end
  
  fill_in 'journal_header_ym', :with => @journal_header.ym
  fill_in 'journal_header_day', :with => @journal_header.day
  fill_in 'journal_header_remarks', :with => @journal_header.remarks
  @journal_header.journal_details.each_with_index do |detail, i|
    select detail.dc_type_name, :from => "journal_details_#{i+1}_dc_type"
    select detail.account_name, :from => "journal_details_#{i+1}_account_id"
    select detail.sub_account_name, :from => "journal_details_#{i+1}_sub_account_id" if detail.sub_account_id.present?
    select detail.branch_name, :from => "journal_details_#{i+1}_branch_id"
    fill_in "journal_details_#{i+1}_input_amount", :with => detail.input_amount
  end
  
  find('#journal_header_ym').click # キャプチャ前にフォーカスイベントを発生させたいだけ
  capture
  click_on action
end

ならば /^振替伝票の一覧に遷移する$/ do
  assert_url '/journal/list'
end

ならば /^振替伝票の(参照|追加|編集)ダイアログが表示される$/ do |action|
  page.has_selector?("div.ui-dialog", :visible => true)
  assert page.has_selector?("span.ui-dialog-title", :text => /#{'振替伝票.*' + action}/)
  capture
end

もし /^振替伝票の追加ダイアログを開きます。$/ do
  sign_in :login_id => user.login_id
  click_on '振替伝票'
  assert_equal '/journal/list', current_path
  click_on '追加'
  assert page.has_selector?("div.ui-dialog", :visible => true)
  capture
end

もし /^伝票ヘッダを入力します。$/ do
  ym = current_user.company.current_fiscal_year.start_year_month

  fill_in 'journal_header_ym', :with => ym
  fill_in 'journal_header_day', :with => 1
  fill_in 'journal_header_remarks', :with => '家賃等の支払い'
  capture
end

もし /^借方に家賃と光熱費を入力します。$/ do
  select '借方', :from => "journal_details_1_dc_type"
  select '地代家賃', :from => "journal_details_1_account_id"
  fill_in 'journal_details_1_input_amount', :with => 78000

  select '借方', :from => "journal_details_2_dc_type"
  select '光熱費', :from => "journal_details_2_account_id"
  fill_in 'journal_details_2_input_amount', :with => 15000
  
  capture
end

もし /^明細を追加して町内会費を入力します。$/ do
  click_on '明細追加'

  select '借方', :from => "journal_details_3_dc_type"
  select '諸会費', :from => "journal_details_3_account_id"
  fill_in 'journal_details_3_input_amount', :with => 3000
  fill_in 'journal_details_3_note', :with => '町内会費として'

  capture
end

もし /^明細をもう１つ追加して、現金での支払いを入力します。$/ do
  click_on '明細追加'
  
  select '貸方', :from => "journal_details_4_dc_type"
  select '小口現金', :from => "journal_details_4_account_id"
  fill_in 'journal_details_4_input_amount', :with => 96000

  capture
end

もし /^登録して終了です。$/ do
  click_on '登録する'
  assert wait_until{ page.has_no_selector?("div.ui-dialog", :visible => true) }
  assert page.has_selector?('#journals_table')
  capture
end
