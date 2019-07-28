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
  
  def test_編集
    assert skill = Skill.find_by(employee_id: employee.id, qualification_id: qualification.id)
    
    get edit_mm_skill_path(skill), xhr: true
    assert_response :success
    assert_equal "/mm/skills/#{skill.id}/edit", path
  end

  def test_更新
    assert skill = Skill.find_by(employee_id: employee.id, qualification_id: qualification.id)

    assert_no_difference 'EmployeeQualification.count' do
      patch mm_skill_path(skill), xhr: true, params: {
        skill: {
          qualified_on: skill.qualified_on - 1.day
        }
      }
    end

    assert_response :success
    assert_template 'common/reload'
    assert @skill = assigns(:skill)
    assert_not_equal skill.qualified_on, @skill.qualified_on
  end

  def test_削除
    assert skill = Skill.find_by(employee_id: employee.id, qualification_id: qualification.id)
    assert_not skill.deleted?

    assert_no_difference 'EmployeeQualification.count' do
      delete mm_skill_path(skill), xhr: true
    end

    assert @skill = assigns(:skill)
    assert @skill.deleted?
    assert_response :success
    assert_template 'common/reload'
  end

end
