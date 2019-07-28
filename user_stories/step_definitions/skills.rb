もし /^(.*?)が(.*?)に合格$/ do |name, qualification_name|
  assert @employee = current_company.employees.find_by(first_name: name)
  assert @qualification = current_company.qualifications.find_by(name: qualification_name)
  
  # TODO
end