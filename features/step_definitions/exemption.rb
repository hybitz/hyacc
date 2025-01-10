前提 /^本店 一郎の会社の会計年度の締め状態は下記の通り設定されている$/ do |ast_table|
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

前提 /^マスタメンテから所得税控除のメニューを選択する$/ do
  current_user || sign_in(admin)
  click_on 'マスタメンテ'
  assert has_link?('所得税控除', exact: true)
  click_on '所得税控除'
end

もし /^暦年が(.*?)年、従業員が(.*?)の所得税控除の情報を取得する$/ do |year, employee|
  select year, from: 'finder[calendar_year]'
  select employee, from: 'finder[employee_id]'
  find('input[name="commit"]').click
end

ならば /^編集と削除ボタンは(表示される|表示されない)$/ do |display|
  capture
  case display
  when '表示される'
    assert has_link? '編集'
    assert has_link? '削除'
  when '表示されない'
    assert_not has_link? '編集'
    assert_not has_link? '削除'
  end
end