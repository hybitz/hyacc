ならば /^帳票出力に遷移する$/ do
  assert has_title?('帳票出力')
  assert_url '/report(\?.*)?'
end

ならば /^源泉徴収に遷移する$/ do
  assert has_title?('源泉徴収')
  assert_url '/withholding_slip(\?.*)?'
end

ならば /^給与所得の源泉徴収等の法定調書合計表の一覧に遷移する$/ do
  assert_url '/withholding_slip(\?.*)?'
end

かつ /^メッセージ「(.*?)」が表示(される|されない)$/ do |message, result|
  case result
    when 'される'
      assert has_text?(message)
    when 'されない'
      assert has_no_text?(message)
  end
end

かつ /^エラーメッセージ「(.*?)」が表示(される|されない)$/ do |message, result|
  case result
    when 'される'
      assert has_selector?('.error', message)
    when 'されない'
      assert has_no_text?(message)
  end
end

もし /^以下の検索条件に入力し$/ do |ast_table|
  rows = normalize_table(ast_table)
  @finder = WithholdingSlipFinder.new(current_user)
  employee_name = ""
  report_type = ""
  rows.each do |row|
    case row[0]
    when '従業員'
      employee_name = row[1]
    when '帳票様式'
      report_type = row[1]
    else
      fail "想定外の項目 #{row[0]} です。"
    end
  end

  form_selector = "#finders"
  within form_selector do
    select '2009', :from => 'finder_calendar_year'
    select employee_name, :from => 'finder_employee_id'
    select report_type, :from => 'finder_report_type'  end
end
