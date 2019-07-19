もし /^推奨する資格を登録$/ do |ast_table|
  @qualifications = to_qualifications(ast_table)

  with_capture do
    @qualifications.each do |q|
      visit_qualifications
      assert has_no_selector?('.notice')
      click_on '追加'
      within_dialog do
        fill_in 'qualification[name]', with: q.name
        fill_in 'qualification[allowance]', with: q.allowance
      end
      capture
      click_on '登録'
      assert has_selector?('.notice')
    end
  end
end