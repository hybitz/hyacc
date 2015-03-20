もし /^金融機関を登録します$/ do
  assert User.count > 0

  sign_in User.first
  click_on 'マスタメンテ'
  click_on '金融機関'
  capture 'マスタメンテ - 金融機関'

  @bank = Bank.new(:code => '0005', :name => '三菱東京UFJ銀行')
  @bank_office = @bank.bank_offices.build(:code => '433', :name => '新橋支店')
  
  click_on '追加'
  fill_in '金融機関コード', :with => @bank.code
  fill_in '金融機関名', :with => @bank.name
  within_table '金融機関営業店' do
    click_link '追加'
    assert has_selector?('tr', :count => 3)

    all('input').each do |input|
      case input['id']
      when /code/
        fill_in input['id'], :with => @bank_office.code
      when /name/
        fill_in input['id'], :with => @bank_office.name
      end
    end
  end
  capture '銀行情報を入力して登録'

  click_on '登録'
  assert has_selector?('table.banks', :text => @bank.name)
  capture '登録完了'
end
