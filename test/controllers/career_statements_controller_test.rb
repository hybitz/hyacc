require 'test_helper'

class CareerStatementsControllerTest < ActionDispatch::IntegrationTest

  def test_一覧
    sign_in user
    get career_statements_path
    assert_response :success
    assert_template :index
  end

  def test_参照
    sign_in user
    get career_statement_path(user)
    assert_response :success
    assert_template :show
  end

end
