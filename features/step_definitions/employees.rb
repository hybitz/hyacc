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

もし /^任意の参照ダイアログの編集をクリックして編集ダイアログを開く$/ do
  assert has_selector?('.employees')

  assert has_no_dialog?

  assert tr = first('.employees tbody tr')
  within tr do
    first('td a').click
  end
  
  assert has_dialog?('従業員　参照')

  within '.ui-dialog-buttonset' do
    find('button', text: '編集')
  end

  assert has_dialog?('従業員　編集')
end