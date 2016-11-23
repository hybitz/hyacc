前提 /^(.*?)がログインしている$/ do |name|
  sign_in :name => name
  capture
end

前提 /^(.*?)が(.*?)を表示している$/ do |name, page|
  sign_in :name => name
  click_on page
  assert has_title?(page)
  capture
end

もし /^(.*?)を表示している$/ do |page|
  begin
    sign_in user unless current_user
    click_on page
    assert has_title?(page)
  ensure
    capture
  end
end

もし /^マスタメンテを表示する$/ do
  sign_in user unless current_user
  click_on 'マスタメンテ'
  assert has_title?('マスタメンテ')
  capture
end

ならば /^当該伝票が(登録|更新|削除)される$/ do |action|
  with_capture do
    if @slip
      if action == '登録'
        assert has_selector?('.notice', :text => "伝票を#{action}しました。")
      elsif action == '更新'
        assert has_no_selector?('#edit_simple_slip')
        assert has_no_selector?('.reload_dialog')
      end
      assert has_selector?('#new_simple_slip')
      assert has_selector?('.account_ready')
    else
      case action
      when '登録', '更新'
        assert has_no_dialog?(/振替伝票.*/)
      end
      assert has_selector?('.notice')
    end
  end
end

ならば /^伝票管理に遷移する$/ do
  assert has_title?('伝票管理')
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
    when '暦年'
      assert_equal '今年', row[1]
      #assert_equal ?, page.find('#finder_calendar_year').value.to_i
    else
      fail "想定外の項目 #{row[0]} です。"
    end
  end
end

もし /^追加をクリックし、ダイアログを表示$/ do
  click_on '追加'
  assert page.has_selector?('.ui-dialog')
  capture
end
