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
  fy = FiscalYear.where(company_id: 1).pluck(:fiscal_year).sort
  (fy.first..fy.last).map{|y| FiscalYear.find_by(company_id: 1, fiscal_year: y).blank? ? FiscalYear.create!(company_id: 1, fiscal_year: y) : next}
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

もし /^ダイアログ内の扶養親族等追加のフォームを表示する$/ do
  click_on '追加'

  assert wait_until { has_selector?("div.ui-dialog", visible: true) }
  assert has_selector?("span.ui-dialog-title", text: /所得税控除.*/)

  click_on '扶養親族等追加'
  assert wait_until { has_selector?("select.exemption_type")}
end

ならば /^国内居住者を選択すれば非居住区分は無効化され、送信値は空になる$/ do
  check 'exemption_dependent_family_members_attributes_0_non_resident'
  assert find('#exemption_dependent_family_members_attributes_0_non_resident_code').disabled?
  assert_equal '', find('#exemption_dependent_family_members_attributes_0_non_resident_code').value
  assert has_selector?('input[type="hidden"][name="exemption[dependent_family_members_attributes][0][non_resident_code]"][value=""]', visible: false)
end

かつ /^控除区分が(.*?)である場合は控除親族等区分と非居住者区分は無効化され、送信値は空になる$/ do |exemption_type|
  select exemption_type, from: 'exemption[dependent_family_members_attributes][0][exemption_type]'
  assert find('select#exemption_dependent_family_members_attributes_0_family_sub_type').disabled?
  assert find('select#exemption_dependent_family_members_attributes_0_non_resident_code').disabled?

  fsc_hiddens = all("input[type='hidden'][name='exemption[dependent_family_members_attributes][0][family_sub_type]']", visible: false)
  assert_equal 1, fsc_hiddens.size
  assert_equal '', fsc_hiddens.first.value

  nrc_hiddens = all("input[type='hidden'][name='exemption[dependent_family_members_attributes][0][non_resident_code]']", visible: false)
  assert_equal 1, nrc_hiddens.size
  assert_equal '', nrc_hiddens.first.value
end

かつ /^控除区分が控除対象扶養親族等で非居住を選択すれば以下の組み合わせで選択項目を制限される$/ do |ast_table|
  select '控除対象扶養親族等', from: 'exemption[dependent_family_members_attributes][0][exemption_type]'
  uncheck 'exemption_dependent_family_members_attributes_0_non_resident'
  assert_not find('select#exemption_dependent_family_members_attributes_0_family_sub_type').disabled?
  assert_not find('select#exemption_dependent_family_members_attributes_0_non_resident_code').disabled?

  rows = normalize_table(ast_table)

  rows[1..-1].each do |r|
    current_family_sub_type = r[0]
    new_non_resident_code = r[1]
    new_non_resident_ui = r[2]

    select current_family_sub_type, from: 'exemption[dependent_family_members_attributes][0][family_sub_type]'

    case new_non_resident_code
    when '30歳未満または70歳以上に固定'
      assert_equal '01', find("#exemption_dependent_family_members_attributes_0_non_resident_code").value
      assert find('#exemption_dependent_family_members_attributes_0_non_resident_code').disabled?
      assert has_selector?('input[type="hidden"][name="exemption[dependent_family_members_attributes][0][non_resident_code]"][value="01"]', visible: false)
    when '選択不可'
      assert_equal "", find("#exemption_dependent_family_members_attributes_0_non_resident_code").value
      assert find('#exemption_dependent_family_members_attributes_0_non_resident_code').disabled?
      assert_not has_selector?('input[type="hidden"][name="exemption[dependent_family_members_attributes][0][non_resident_code]"]:not([value=""])', visible: false)
    when '制限しない'
      assert_not find('#exemption_dependent_family_members_attributes_0_non_resident_code').disabled?
      assert_not has_selector?('input[type="hidden"][name="exemption[dependent_family_members_attributes][0][non_resident_code]"]:not([value=""])', visible: false)
    end

    case new_non_resident_ui
    when '国内居住者に固定'
      assert find('#exemption_dependent_family_members_attributes_0_non_resident').checked?
      assert find('#exemption_dependent_family_members_attributes_0_non_resident').disabled?
      assert has_selector?('input[type="hidden"][name="exemption[dependent_family_members_attributes][0][non_resident]"][value="0"]', visible: false)
    when '制限しない'
      assert_not find('#exemption_dependent_family_members_attributes_0_non_resident').disabled?
    end
  end
end