もし /^法務局に提出する「商業・法人登記申請」に記した本社を登録$/ do
  begin
    visit_companies

    within '#business_offices_table' do
      click_on '追加'
    end

    assert has_selector?('.ui-dialog')
    within '.ui-dialog' do
      begin
        fill_in '事業所名', :with => '本社'
        select '北海道', :from => '都道府県'
        fill_in '住所１', :with => '北海道札幌市中央区'
        fill_in '電話番号', :with => '011-1234-5678'
        check '本社フラグ'
      ensure
        capture
      end

      click_on '登録'
    end

    assert has_no_selector?('.ui-dialog')
    assert has_selector?('#business_offices_table', :text => '本社')
  ensure
    capture
  end
end

もし /^給与支払日を翌月7日に設定$/ do
  visit_companies

  find_tr '.company', '給与支払日' do
    click_on '変更'
  end
  assert has_selector?('.edit_company')
  within '.edit_company' do
    select '翌月', :from => 'company_month_of_payday'
    fill_in 'company_day_of_payday', :with => '7'
  end
  capture

  click_on '更新'
  assert has_no_selector?('.edit_company')
  capture
end
