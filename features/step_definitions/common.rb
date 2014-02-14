# coding: UTF-8

前提 /^(.*?)がログインしている$/ do |name|
  sign_in :name => name
  capture
end

前提 /^(.*?)が(.*?)を表示している$/ do |name, page|
  sign_in :name => name
  click_on page
  capture  
end

ならば /^当該伝票が(登録|更新|削除)される$/ do |action|
  if @slip
    if action == '更新'
      assert page.has_no_selector?("#slip_edit_form")
      assert page.has_no_text?('ロード中')
    end
    assert page.has_text?("伝票を#{action}しました。")
    assert_url "^/simple/#{@account.code}$"
  else
    if action == '登録' or action == '更新'
      assert page.has_no_selector?("div.dojoxDialogTitleBar[title=振替伝票　#{action}]")
      assert page.has_no_text?('ロード中')
    end
    assert page.has_text?("伝票を#{action}しました。")
    assert_url "^/journal/list$"
  end
end

ならば /^伝票管理に遷移する$/ do
  assert_url '/journal_admin'
end

かつ /^検索条件の初期値は以下の通りである$/ do |ast_table|
  rows = normalize_table(ast_table)
  rows.each do |row|
    case row[0]
    when '年度'
      assert_equal '本年度', row[1]
      assert_equal current_user.company.current_fiscal_year_int, page.find('#finder_fiscal_year').value.to_i
    when '部門'
      assert_equal 'デフォルト部門', row[1]
      assert_equal current_user.employee.default_branch.id, page.find('#finder_branch_id').value.to_i
    when '従業員'
      assert_equal 'ログインユーザ', row[1]
      assert_equal current_user.employee.id, page.find('#finder_employee_id').value.to_i
    when '勘定科目'
      assert_equal 'ブランク', row[1]
      assert page.find('#finder_account_id').value.blank? 
    else
      fail "想定外の項目 #{row[0]} です。"
    end
  end
end
