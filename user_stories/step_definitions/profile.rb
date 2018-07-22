もし /^よく使う科目にショートカットキーを設定$/ do
  with_capture { visit_profile }

  [ ACCOUNT_CODE_CASH, ACCOUNT_CODE_ORDINARY_DIPOSIT, ACCOUNT_CODE_RECEIVABLE ].each_with_index do |account_code, i|
    add_shortcut("Ctrl+#{i+1}", account_code)
  end
end

もし /^簡易入力に、未払金（従業員）を追加$/ do
  with_capture { visit_profile }
  add_shortcut("Ctrl+4", ACCOUNT_CODE_UNPAID_EMPLOYEE)
end
