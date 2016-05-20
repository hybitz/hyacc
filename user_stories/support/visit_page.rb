module VisitPage

  def visit_accounts(options = {})
    assert current_user || sign_in(User.first)

    visit '/'
    click_on 'マスタメンテ'
    click_on '勘定科目'
    assert has_title?('勘定科目')
  end

  def visit_account_transfers(options = {})
    assert current_user || sign_in(User.first)

    visit '/'
    click_on '伝票管理'
    click_on '科目振替'
    assert has_title?('科目振替')
  end

  def visit_companies
    assert current_user || sign_in(User.first)

    visit '/'
    click_on 'マスタメンテ'
    click_on '会社', :exact => true
    assert has_selector?('.company')
  end

  def visit_payrolls
    assert current_user || sign_in(User.first)

    visit '/'
    click_on '賃金台帳'
    assert has_title?('賃金台帳')
    assert has_no_selector?('#payroll_table')
  end

  def visit_profile
    assert current_user || sign_in(User.first)

    visit '/'
    within '.header' do
      click_on current_user.employee.fullname
    end
    assert has_title?('個人設定')
  end

  def visit_simple_slip(options = {})
    assert current_user || sign_in(User.first)

    visit '/'
    click_on options[:account].name
    assert has_title?(options[:account].name)
    assert has_no_selector?('span.notice')
    assert has_selector? '.tax_type_ready'
  end

  def visit_users
    assert current_user || sign_in(User.first)

    visit '/'
    click_on 'マスタメンテ'
    click_on 'ユーザ'
    assert has_title?('ユーザ')
  end

end

World(VisitPage)
