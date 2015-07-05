もし /^金融機関をクリックし、一覧を表示する$/ do
  click_on '金融機関'
  assert has_title?('金融機関')
  capture
end

もし /^金融機関情報を入力し、登録する$/ do
  @bank_params = valid_bank_params
  assert has_no_selector?('table.mm.banks td', :text => @bank_params[:name])

  within '.ui-dialog' do
    fill_in Bank.human_attribute_name(:code), :with => @bank_params[:code]
    fill_in Bank.human_attribute_name(:name), :with => @bank_params[:name]
    capture
    click_on '登録'
  end

  assert has_selector?('table.mm.banks td', :text => @bank_params[:name])
  capture
end
