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
  wait_until { page.has_selector?("div.ui-dialog", :visible => true) }
  assert page.has_selector?("span.ui-dialog-title", :text => /#{'振替伝票.*' + action}/)
  capture
end
