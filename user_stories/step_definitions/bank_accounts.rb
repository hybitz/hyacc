もし /^口座を登録します$/ do
  assert @bank
  assert @bank_office

  click_on '金融口座'
  assert has_title?('金融口座')
  capture 'マスタメンテ - 金融口座'

  @bank_account = BankAccount.new(:bank => @bank, :bank_office => @bank_office)
  @bank_account.code = '1234567'
  @bank_account.name = 'メイン口座'
  @bank_account.financial_account_type = FINANCIAL_ACCOUNT_TYPE_SAVING
  @bank_account.holder_name = current_user.employee.full_name('')
  assert has_no_selector?('.bank_accounts', :text => @bank_account.name)

  click_on '追加'
  within '.new_bank_account' do
    select @bank_account.bank.name, :from => '金融機関'
    select @bank_account.bank_office.name, :from => '支店'
    select @bank_account.financial_account_type_name, :from => '区分'
    fill_in '口座番号', :with => @bank_account.code
    fill_in '口座名', :with => @bank_account.name
    fill_in '口座名義', :with => @bank_account.holder_name
  end
  capture '口座情報を入力して登録'

  click_on '登録'
  assert has_selector?('.bank_accounts', :text => @bank_account.name)
  capture '登録完了'
end
