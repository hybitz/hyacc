もし /^配属先となる(.*?)を登録$/ do |branch_name|
  visit_branches
  click_on '本店'
  within_dialog('部門　参照') do
    click_on '子部門追加'
  end

  within_dialog('部門　追加') do
    with_capture do
      select '本社', :from => '事業所'
      fill_in '部門コード', :with => '200'
      fill_in '部門名', :with => branch_name
    end
    click_on '登録'
  end
  
  with_capture do
    assert has_selector?('.notice')
    within '#branch_tree' do
      first('a').click
      pause 3
    end
  end
end
