module VisitPage

  def visit_account_transfers(options = {})
    assert current_user || sign_in(User.first)

    visit '/'
    click_on '伝票管理'
    click_on '科目振替'
    assert has_title?('科目振替')
  end

  def visit_simple_slip(options = {})
    assert current_user || sign_in(User.first)

    visit '/'
    click_on options[:account].name
    assert has_title?(options[:account].name)
    assert has_selector? '.tax_type_ready'
  end

end

World(VisitPage)