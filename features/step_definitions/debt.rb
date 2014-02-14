# coding: UTF-8

前提 /^仮負債精算の一覧を表示している$/ do
  visit '/debt'
  click_on '表示'
  assert_url '/debt'
  assert page.has_selector?('#debt_table')
end

かつ /^任意の伝票の(精算)をクリックする$/ do |action|
  assert page.has_selector?('#debt_table')
  
  find('#debt_table').all('tr').each do |tr|
    if tr.has_button?(action)
      @debt_id = tr['id'].to_s.split('_').last
      within tr do
        click_on '精算'
      end
      confirm
      break
    end
  end
  
  assert_not_nil @debt_id
end

ならば /^仮負債精算に遷移する$/ do
  assert_url '/debt'
end

ならば /^仮負債精算の一覧が表示される$/ do
  assert_url '/debt'
  assert page.has_selector?('#debt_table')
end

ならば /^当該伝票が(精算)済みになる$/ do |action|
  found = false

  find('#debt_table').all('tr').each do |tr|
    if tr['id'].to_s.split('_').last == @debt_id
      assert tr.has_no_button?(action)
      found = true
      break
    end
  end
  
  capture
  assert found
end
