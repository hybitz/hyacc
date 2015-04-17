もし /^受注元となる取引先を登録します$/ do |ast_table|
  rows = normalize_table(ast_table)

  sign_in User.first unless current_user

  click_on 'マスタメンテ'
  click_on '取引先'
  assert has_selector?('table.customers tbody tr', :count => 0)
  capture '取引先はまだ登録されていない'

  click_on '追加'
  within '.ui-dialog' do
    rows.each do |row|
      name, value = *row
      case name
      when '取引先コード', '取引先名（正式名）', '取引先名（省略名）', '住所'
        fill_in name, :with => value
      when '受注フラグ', '発注フラグ'
        select value, :from => name
      else
        raise "予期していない項目です。#{name}: #{value}"
      end
    end

    capture '取引先情報を入力して登録'
    click_on '登録'
  end
  
  assert has_selector?('table.customers tbody tr', :count => 1)
  capture
end
