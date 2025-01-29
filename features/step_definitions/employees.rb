前提 /^退職金積立開始時期が入社から(.*?)年目に登録されている$/ do |year|
  Company.first.update!(retirement_savings_after: year)
end

もし /^マスタメンテから従業員のメニューを選択する$/ do
  with_capture do
    current_user || sign_in(admin)
    click_on 'マスタメンテ'
    assert has_link?('従業員', exact: true)
    click_on '従業員'
    assert has_selector?('.employees')
  end
end

もし /^従業員一覧から対象の従業員を選択して無効化する$/ do
  assert has_selector?('.employees')

  with_capture do
    within '.employees' do
      within all('tbody tr').find{|tr| tr.text.exclude?(current_user.employee.name) } do
        accept_alert do
          click_on '無効'
        end
      end
    end
    
    assert has_selector?('.notice')
  end
end

もし /^従業員の詳細ダイアログに以下のように表示される$/ do |ast_table|
  rows = normalize_table(ast_table)
  rows[1..-1].each do |r|
    name = r[0]
    date = Date.parse(r[1])
    employment_date_year = date.strftime("%Y")
    employment_date_month = date.strftime("%-m")
    employment_date_day = date.strftime("%-d")
    start_ym_of_retirement_savings  = r[2]

    click_on name
    assert wait_until { has_selector?("div.ui-dialog", visible: true) }
    capture
    
    within ("#employee_employment_date_1i") do
      assert has_selector?("option[selected='selected']", text: employment_date_year)
    end

    within ("#employee_employment_date_2i") do
      assert has_selector?("option[selected='selected']", text: employment_date_month)
    end

    within ("#employee_employment_date_3i") do
      assert has_selector?("option[selected='selected']", text: employment_date_day)
    end

    within(find('#evaluation_table').all('tr').last) do 
      assert has_selector?("td", text: start_ym_of_retirement_savings)
    end

    click_on '閉じる'
  end

end
