ならば /^社会保険料の一覧画面に遷移する$/ do
  assert has_title?('社会保険料')
  assert_url '/mv/social_insurances(\?.*)?'
end

もし /^都道府県と年月を指定して表示をクリックすると$/ do
  visit_social_insurances

  begin
    select '北海道', :from => '都道府県'
    fill_in '年月', :with => '2009-08'
    click_on '表示'
  rescue => e
    capture
    raise e
  end
end

ならば /^都道府県別に保険料が表示されます$/ do
  begin
    assert has_selector?('.social_insurances')
  ensure
    capture
  end
end
