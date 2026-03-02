もし '寄付先をクリックし、一覧画面に遷移する' do
  click_on '寄付先'
  assert has_selector?('.subMenu .selected', text: '寄付先')
end
