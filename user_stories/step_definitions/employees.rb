もし /^従業員 (.*) を登録$/ do |name, ast_table|
  @user = to_user(ast_table)

  visit_employees

  click_on '追加'
  within_dialog('ユーザ　追加') do
    with_capture do
      fill_in 'ログインID', with: @user.login_id
      fill_in 'パスワード', with: @user.password
      fill_in 'メールアドレス', with: @user.email
      fill_in '姓', with: @user.employee.last_name
      fill_in '名', with: @user.employee.first_name
      select @user.employee.sex_name, from: '性別'
      fill_in '生年月日', with: @user.employee.birth
      find_field('生年月日').native.send_keys :tab
      fill_in '入社日', with: @user.employee.employment_date
      find_field('入社日').native.send_keys :tab
    end
    click_on '登録'
  end
  
  with_capture do
    assert has_no_dialog?
    assert has_selector?('.notice')
  end
end

もし /^(.*?)を(.*?)に配属$/ do |first_name, branch_name|
  assert @employee = Employee.where(first_name: first_name, deleted: false).first

  visit_employees

  with_capture do
    find_tr '.employees', @employee.fullname do
      click_on '編集'
    end
    assert has_dialog?
  end

  within_dialog do
    with_capture do
      assert has_selector?('#branch_employees_table')
      click_on '部門追加'
      assert has_selector?('#branch_employees_table tbody tr', count: 1)

      within first('#branch_employees_table tbody tr') do
        select branch_name, from: find('[name*="\[branch_id\]"]')['id']
        check find('[name*="\[default_branch\]"]')['id']
      end
    end
    click_on '更新'
  end

  with_capture do
    assert has_no_dialog?
    assert has_selector?('.notice')
  end

  sign_in(@employee.user, force: true)
  with_capture { visit_profile }
  [ ACCOUNT_CODE_CASH, ACCOUNT_CODE_ORDINARY_DIPOSIT, ACCOUNT_CODE_RECEIVABLE ].each_with_index do |account_code, i|
    add_shortcut("Ctrl+#{i+1}", account_code)
  end
end
