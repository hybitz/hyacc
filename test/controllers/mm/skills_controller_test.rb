require 'test_helper'

class Mm::SkillsControllerTest < ActionDispatch::IntegrationTest

  def setup
    sign_in admin
  end

  def test_一覧
    get mm_skills_path
    assert_response :success
    assert_equal '/mm/skills', path
  end

  def test_追加
    get new_mm_skill_path, xhr: true, params: {employee_id: employee.id, qualification_id: qualification.id}
    assert_response :success
    assert_equal '/mm/skills/new', path
  end
  
  def test_登録
    assert_difference 'EmployeeQualification.count', 1 do
      post mm_skills_path, xhr: true, params: {
        skill: {
          employee_id: employee.id,
          qualification_id: qualification.id,
          qualified_on: Date.today.to_s
        }
      }
    end
    
    assert_response :success
    assert_template 'common/reload'
  end
  
end
