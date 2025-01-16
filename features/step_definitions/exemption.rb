前提 /^会計年度の締め状態は下記の通り設定されている$/ do |ast_table|
  rows = normalize_table(ast_table)
  rows[1..-1].each do |r|
    year = r[0]
    case r[1]
    when '本締'
      new_closing_status = CLOSING_STATUS_CLOSED
    when '仮締'
      new_closing_status = CLOSING_STATUS_CLOSING
    when '通常'
      new_closing_status = CLOSING_STATUS_OPEN
    end    
    FiscalYear.find_by(company_id: 1, fiscal_year: year).update!(closing_status: new_closing_status)
  end
end

前提 /^所得税控除の暦年は会計年度マスタに登録されている$/ do
  years = Exemption.where(company_id: 1).pluck(:yyyy)
  years.map{|y| FiscalYear.find_by(company_id: 1, fiscal_year: y).blank? ? Exemption.where(yyyy: y).delete_all : next }
end

前提 /^人事労務から所得税控除のメニューを選択する$/ do
  click_on '人事労務'
  assert has_link?('所得税控除', exact: true)
  click_on '所得税控除'
end

もし /^編集と削除ボタンは以下のように表示もしくは非表示に切り替わる$/ do |ast_table|
  rows = normalize_table(ast_table)
  rows[1..-1].each do |r|
    year = r[0]
    employee = r[1]
    display = r[2]

    select year, from: 'finder[calendar_year]'
    select employee, from: 'finder[employee_id]'
    find('input[name="commit"]').click

    case display
    when '表示'
      assert has_link? '編集'
      assert has_link? '削除'
    when '非表示'
      assert_not has_link? '編集'
      assert_not has_link? '削除'
    end
  end
end

もし /^ダイアログ内の暦年のセレクトボックスは以下のように有効もしくは無効に切り替わる$/ do |ast_table|
  rows = normalize_table(ast_table)
  rows[1..-1].each do |r|
    action = r[0]
    availability = r[1]

    click_on action, match: :first 

    assert wait_until { has_selector?("div.ui-dialog", visible: true) }
    assert has_selector?("span.ui-dialog-title", text: /所得税控除.*#{action}/)
    
    case availability
    when '無効'
      assert find('#exemption_yyyy').disabled?
    when '有効'
      assert_not find('#exemption_yyyy').disabled?
    end

    click_on '閉じる'
    
  end
end