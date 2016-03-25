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

    selector = '.bank_offices tbody tr'
    assert has_no_selector?(selector)
    click_on '追加'
    assert has_selector?(selector, :count => 1)

    capture
    click_on '登録'
  end

  assert has_selector?('table.mm.banks td', :text => @bank_params[:name])
  capture
end

もし /^金融機関および営業店が登録される$/ do
  assert has_selector?('.notice')
  assert @bank_params
  assert @bank = Bank.find_by_name(@bank_params[:name])
  assert @bank.bank_offices.present?
end
