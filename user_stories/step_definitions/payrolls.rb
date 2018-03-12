もし /^賃金台帳に今月分の給与を登録$/ do |ast_table|
  table = normalize_table(ast_table)

  @ym = table[0][1].split('-').join
  @salary = table[1][1].to_ai

  visit_payrolls
  click_on '表示'
  assert has_selector?('#payroll_table')

  click_on @ym
  with_capture do
    within '.ui-dialog' do
      fill_in 'payroll[base_salary]', :with => @salary
      assert has_selector?('form[insurance_loaded]');
      fill_in 'payroll[inhabitant_tax]', :with => 0
    end

    accept_confirm do
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
    employee_name = row[1]
    salary = row[2].to_ai
    withheld_tax = row[3].to_ai
    health_insurance = row[4].to_ai
    pension = row[5].to_ai

    with_capture "#{employee_name} #{ym} の給与" do
      visit_payrolls
      select row[0], :from => 'finder_branch_id'
      assert has_selector?('#finder_employee_id option', :text => employee_name)
      click_on '表示'
      assert has_selector?('#payroll_table')

      click_on ym
      within_dialog do
        fill_in '基本給', :with => salary
        fill_in '住民税', :with => 0
        assert has_selector?('form[insurance_loaded]')
    
        accept_confirm do
          click_on '登録'
        end
      end
      assert has_no_dialog?
      assert has_selector?('#finder_employee_id option', :text => employee_name)
    end

    with_capture "#{employee_name} #{ym} の給与支払" do
      assert col = find('#payroll_table thead tr').all('th').index{|th| th.has_link?(ym) }

      { '基本給' => salary.to_as,
        '所得税' => withheld_tax.to_as,
        '健康保険料' => health_insurance.to_as,
        '厚生年金保険料' => pension.to_as
      }.each do |key, value|
        case key
        when '健康保険料'
          rowspan = 1
        else
          rowspan = 0
        end

        find_tr '#payroll_table', key do |tr|
          expected = tr.all('td')[col + rowspan].text
          assert value == expected, "#{employee_name} の #{key} の金額 #{value} が #{expected} と一致しません"
        end
      end
  
      pay_day = current_company.get_actual_pay_day_for(ym).strftime('%m月%d日')
      click_on pay_day
      assert has_dialog?
    end
  end
end
