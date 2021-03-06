もし /^賃金台帳に今月分の給与を登録$/ do |ast_table|
  table = normalize_table(ast_table)

  @ym = table[0][1].split('-').join
  @salary = table[1][1].to_ai

  visit_payrolls
  with_capture do
    click_on '表示'
    assert has_selector?('#payroll_table')

    click_on @ym
    within_dialog do
      fill_in 'payroll[base_salary]', with: @salary
      fill_in 'payroll[monthly_standard]', with: @salary
      fill_in 'payroll[commuting_allowance]', with: 0
      fill_in 'payroll[inhabitant_tax]', with: 0 # blur

      click_on '登録'
    end
  end

  with_capture do
    assert has_no_selector?('.ui-dialog')
    assert col = find('#payroll_table thead tr').all('th').index{|th| th.has_link?(@ym) }

    find_tr '#payroll_table', '基本給' do |tr|
      assert_equal @salary.to_as, tr.all('td')[col].text
    end
    capture

    pay_day = current_company.get_actual_pay_day_for(@ym).strftime('%m月%d日')
    click_on pay_day
    assert has_selector?('.ui-dialog')
  end
end

もし /^税金および保険料は以下のとおり$/ do |ast_table|
  assert @ym
  assert col = find('#payroll_table thead tr').all('th').index{|th| th.has_link?(@ym) }

  normalize_table(ast_table).each do |row|
    find_tr '#payroll_table', row[0] do |tr|
      case row[0]
      when '健康保険'
        rowspan = 1
      else
        rowspan = 0
      end

      expected = tr.all('td')[col + rowspan].text
      assert row[1] == expected, "#{row[0]} の金額 #{row[1]} が #{expected} と一致しません"
    end
  end
end

もし /^各従業員の (.*?) 分の給与を登録$/ do |ym, ast_table|
  ym = ym.split('-').join
  rows = normalize_table(ast_table)[1..-1]

  rows.each do |row|
    base_salary = row[2].to_ai
    extra_pay = row[3].to_ai
    commuting_allowance = row[4].to_ai
    housing_allowance = row[5].to_ai
    withheld_tax = row[6].to_ai
    health_insurance = row[7].to_ai
    welfare_pension = row[8].to_ai
    employment_insurance = row[9].to_ai

    visit_payrolls
    assert employee = current_company.employees.find_by_first_name(row[1])

    with_capture "#{employee.name} #{ym} の給与" do
      select row[0], from: 'finder[branch_id]'
      select employee.name, from: 'finder[employee_id]'
      click_on '表示'
      assert has_selector?('#payroll_table')

      click_on ym
      within_dialog do
        fill_in 'payroll[base_salary]', with: base_salary
        fill_in 'payroll[extra_pay]', with: extra_pay
        fill_in 'payroll[commuting_allowance]', with: commuting_allowance
        fill_in 'payroll[housing_allowance]', with: housing_allowance
        if Payroll.where(employee_id: employee.id).empty?
          fill_in 'payroll[monthly_standard]', with: base_salary + extra_pay + commuting_allowance + housing_allowance
        end
        fill_in 'payroll[inhabitant_tax]', with: 0 # blur

        click_on '登録'
      end
      assert has_no_dialog?
      assert has_selector?('.notice')
    end

    with_capture "#{employee.name} #{ym} の給与支払" do
      assert col = find('#payroll_table thead tr').all('th').index{|th| th.has_link?(ym) }

      { '基本給' => base_salary,
        '所定時間外割増賃金' => extra_pay,
        '通勤手当' => commuting_allowance,
        '住宅手当' => housing_allowance,
        '所得税' => withheld_tax,
        '健康保険料' => health_insurance,
        '厚生年金保険料' => welfare_pension,
        '雇用保険料' => employment_insurance
      }.each do |key, expected|
        case key
        when '通勤手当', '健康保険料'
          rowspan = 1
        else
          rowspan = 0
        end

        find_tr '#payroll_table', key do |tr|
          value = tr.all('td')[col + rowspan].text.to_ai
          assert value == expected, "#{employee.name} の #{key} の金額 #{value} が #{expected} と一致しません"
        end
      end
  
      pay_day = current_company.get_actual_pay_day_for(ym).strftime('%m月%d日')
      click_on pay_day
      assert has_dialog?
    end
  end
end
