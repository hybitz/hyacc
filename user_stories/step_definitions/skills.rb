もし /^(.*?)が(.*?)に合格$/ do |name, qualification_name|
  assert @employee = current_company.employees.find_by(first_name: name)
  assert @qualification = current_company.qualifications.find_by(name: qualification_name)
  
  with_capture do
    visit_skills(employee: @employee)
  end
  with_capture do
    find_tr '#skill_container', @qualification.name do
      click_on '追加'
    end
    within_dialog do
      fill_in '資格取得日', with: '2014-04-10'
      first('label', text: '資格').click # blur
      click_on '登録'
    end
    assert has_no_dialog?
  end
end