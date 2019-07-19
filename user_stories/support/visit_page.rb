module VisitPage

  def visit_accounts(options = {})
    assert current_user || sign_in(User.first)

    visit '/'
    click_on 'マスタメンテ'
    click_on '勘定科目'
    assert has_title?('勘定科目')
  end

  def visit_assets(options = {})
    assert current_user || sign_in(User.first)

    visit '/'
    click_on '資産管理'
    assert has_title?('資産管理')
    click_on '減価償却'
    assert has_title?('減価償却')

    if options[:branch]
      select options[:branch].name, from: 'finder[branch_id]'
      click_on '表示'
    end

    assert has_selector?('#asset_container')
  end

  def visit_branches
    assert current_user || sign_in(User.first)

    visit '/'
    click_on 'マスタメンテ'
    click_on '部門'
    assert has_title?('部門')
    assert has_selector?('#branch_tree')
  end

  def visit_companies
    assert current_user || sign_in(User.first)

    visit '/'
    click_on 'マスタメンテ'
    click_on '会社', :exact => true
    assert has_selector?('.company')
  end

  def visit_employees
    assert current_user || sign_in(User.first)

    visit '/'
    click_on 'マスタメンテ'
    click_on '従業員', :exact => true
    assert has_title?('従業員')
  end

  def visit_journals
    assert current_user || sign_in(User.first)

    visit '/'
    click_on '振替伝票'
    assert has_title?('振替伝票')
  end

  def visit_payrolls
    assert current_user || sign_in(User.first)

    visit '/'
    click_on '賃金台帳'
    assert has_title?('賃金台帳')
    assert has_selector?('#branch_employees select')
    assert has_button?('表示')
    assert has_no_selector?('.notice')
    assert has_no_selector?('#payroll_table')
  end
  
  def visit_qualifications
    assert current_user || sign_in(User.first)

    visit '/'
    click_on 'マスタメンテ'
    click_on Qualification.model_name.human
    assert has_title?(Qualification.model_name.human)
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
