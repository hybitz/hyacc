require 'test_helper'

class Report::EmploymentInsurancesControllerTest < ActionDispatch::IntegrationTest

  def test_index
    sign_in user
    get report_employment_insurances_path
    assert_response :success
    assert_template :index
  end
  
  def test_集計表の表示
    sign_in user
    get report_employment_insurances_path(finder: {calendar_year: '2018'}, commit: true)
    assert_response :success
    assert_template '00000000'
  end
  
end
