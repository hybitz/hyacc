もし /^金融機関を登録$/ do
  assert User.count > 0

  sign_in User.first
  click_on 'マスタメンテ'
  click_on '金融機関'
  capture 'マスタメンテ - 金融機関'

  @bank = Bank.new(:code => '0005', :name => '三菱東京UFJ銀行')
  @bank_office = @bank.bank_offices.build(:code => '433', :name => '新橋支店')
  assert has_no_selector?('.banks', :text => @bank.name)
  
  click_on '追加'
  within '.ui-dialog' do
    fill_in 'bank[code]', :with => @bank.code
    fill_in 'bank[name]', :with => @bank.name
    within '.bank_offices' do
      click_on '追加'
      assert has_selector?('tbody tr', count: 1)

      within 'tbody tr:last-child' do
        code_field = find('input[id*="code"]')
        name_field = find('input[id*="name"]')
        fill_in code_field['id'], with: @bank_office.code
        fill_in name_field['id'], with: @bank_office.name
      end
    end

    capture '銀行情報を入力して登録'
    click_on '登録'
  end

  assert has_selector?('.banks', :text => @bank.name)
  capture '登録完了'
end
