もし /^建て替えた費用を計上するための勘定科目は、(.*?)$/ do |name|
  with_capture do
    visit_accounts
    select '負債', from: 'finder[account_type]'
    click_on '表示'
    assert has_selector?('tr', text: name)

    within find('tr', text: name) do
      click_on name
    end
    assert has_dialog?('勘定科目　参照')
  end
end
