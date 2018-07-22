module ProfilesSupport

  def visit_profile
    assert current_user || sign_in(User.first)

    visit '/'
    within '.header' do
      click_on current_user.employee.fullname
    end
    assert has_title?('個人設定')
  end
  
  def add_shortcut(shortcut_key, account_code)
    assert account = Account.where(code: account_code).first
    assert has_title?('個人設定')

    with_capture do
      count = find('table.simple_slip_settings tbody').all('tr').count
      click_on '勘定科目追加'
      assert has_selector?('table.simple_slip_settings tbody tr', count: count + 1)
  
      within 'table.simple_slip_settings tbody tr:last-child' do
        select account.name, from: find('select[name*="\[account_id\]"]')['id']
        fill_in find('input[name*="\[shortcut_key\]"]')['id'], with: shortcut_key
      end
  
      click_on '更新'
      assert has_selector?('.notice')
    end
  end

end

World(ProfilesSupport)