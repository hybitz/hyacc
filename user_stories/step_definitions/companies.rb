もし /^事業所に本社を登録$/ do
  sign_in User.first unless current_user

  visit '/mm/companies'
  assert has_selector?('.company')

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

  assert has_selector?('#business_offices_table', :text => '本社')
  capture
end
