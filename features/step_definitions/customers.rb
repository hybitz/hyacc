もし '取引先をクリックし、一覧画面に遷移する' do
  click_on '取引先'
  assert has_title?('取引先')
end

ならば '追加ボタンが表示されている' do
  with_capture do
    assert has_link?('追加')
  end
end
