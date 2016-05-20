もし /^簡易入力に、未払金（従業員）を追加$/ do
  with_capture do
    visit_profile
  end

  count = find('table.simple_slip_settings tbody').all('tr').count
  with_capture do
    click_on '勘定科目追加'
    assert has_selector?('table.simple_slip_settings tbody tr', :count => count + 1)

    within 'table.simple_slip_settings tbody tr:last-child' do
      select '未払金（従業員）', :from => find('select[name*="\[account_id\]"]')['id']
      fill_in find('input[name*="\[shortcut_key\]"]')['id'], :with => 'Ctrl+4'
    end

    click_on '更新'
    assert has_selector?('.notice')
  end
end
