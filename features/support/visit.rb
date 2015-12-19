module Visit
  
  def visit_mv
    sign_in user unless current_user
    click_on 'マスタビューア'
    assert has_title?('マスタビューア')
  end

  def visit_social_insurances
    visit_mv
    click_on '社会保険料'
    assert has_title?('社会保険料')
    assert_url '/mv/social_insurances(\?.*)?'
  end
end

World(Visit)