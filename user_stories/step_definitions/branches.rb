もし /^新しい部門を追加$/ do
  visit_branches

  with_capture do
    click_on '本店'

    within_dialog('部門　参照') do
      click_on '子部門追加'
    end

    within_dialog('部門　追加') do
      select '本社', :from => '事業所'
      fill_in '部門コード', :with => '200'
      fill_in '部門名', :with => '営業部'
      click_on '登録'
    end
    assert has_selector?('.notice')
  end
  
  with_capture do
    within '#branch_tree' do
      first('a').click
      click_on '営業部'
    end
    assert has_dialog?('部門　参照')
  end
end
