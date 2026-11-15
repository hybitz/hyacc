require 'test_helper'

class Mm::SkillsControllerTest < ActionDispatch::IntegrationTest

  def setup
    sign_in admin
  end

  def test_一覧_資格ありなら前提案内なし
    get mm_skills_path
    assert_response :success
    assert_equal '/mm/skills', path
    assert_select '.alert-info', count: 0
  end

  def test_一覧_資格なし・会社に取得情報ありなら前提案内と検索
    Qualification.update_all(deleted: true)

    get mm_skills_path
    assert_response :success
    assert_select '.alert-info', text: /スキルシートを追加するには資格の登録が必要です/
    assert_select '.alert-info a[href=?]', mm_qualifications_path, text: '資格管理へ'
    assert_select '.search'
    assert_select '.alert-warning', count: 0
  end

  def test_一覧_資格なし・会社に取得情報なしなら前提案内だけ
    Qualification.update_all(deleted: true)
    Skill.update_all(deleted: true)

    get mm_skills_path
    assert_response :success
    assert_template 'check_qualifications'
    assert_select '.alert-info', text: /スキルシートを追加するには資格の登録が必要です/
    assert_select '.alert-info a[href=?]', mm_qualifications_path, text: '資格管理へ'
    assert_select '.alert-warning', count: 0
    assert_select '.search', count: 0
  end

  def test_一覧_資格なし・会社に取得情報あり・従業員未選択で表示しても前提案内と検索
    Qualification.update_all(deleted: true)

    get mm_skills_path, params: { skill_finder: { employee_id: '' }, commit: '表示' }
    assert_response :success
    assert_select '.alert-info', text: /スキルシートを追加するには資格の登録が必要です/
    assert_select '.search'
    assert_select '#skill_container', count: 0
    assert_select '.alert-warning', count: 0
  end

  def test_一覧_資格なし・会社に取得情報あり・選択従業員は取得情報なしなら前提案内だけ
    Qualification.update_all(deleted: true)

    get mm_skills_path, params: { skill_finder: { employee_id: admin.employee.id }, commit: '表示' }
    assert_response :success
    assert_select '.search'
    assert_select '#skill_container', count: 0
    assert_select '.alert-info', text: /スキルシートを追加するには資格の登録が必要です/
    assert_select '.alert-info a[href=?]', mm_qualifications_path, text: '資格管理へ'
    assert_select '.alert-warning', count: 0
  end

  def test_一覧_資格なし・会社に取得情報あり・選択従業員に取得情報ありなら行と前提案内
    Qualification.update_all(deleted: true)
    skill = Skill.where(deleted: false).first

    get mm_skills_path, params: { skill_finder: { employee_id: skill.employee_id }, commit: '表示' }
    assert_response :success
    assert_select '.search'
    assert_select '#skill_container'
    assert_select '.alert-info', text: /スキルシートを追加するには資格の登録が必要です/
    assert_select '.alert-warning', count: 0
  end

  def test_追加
    get new_mm_skill_path, xhr: true, params: {employee_id: employee.id, qualification_id: qualification.id}
    assert_response :success
    assert_equal '/mm/skills/new', path
  end
  
  def test_登録
    assert_difference 'Skill.count', 1 do
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

  def test_登録_入力エラー
    assert_no_difference 'Skill.count' do
      post mm_skills_path, xhr: true, params: {
        skill: {
          employee_id: employee.id,
          qualification_id: qualification.id,
          qualified_on: ''
        }
      }
    end

    assert_response :success
    assert_template :new
    assert assigns(:skill).errors[:qualified_on].present?
  end
  
  def test_編集
    assert skill = Skill.find_by(employee_id: employee.id, qualification_id: qualification.id)
    
    get edit_mm_skill_path(skill), xhr: true
    assert_response :success
    assert_equal "/mm/skills/#{skill.id}/edit", path
  end

  def test_更新
    assert skill = Skill.find_by(employee_id: employee.id, qualification_id: qualification.id)

    assert_no_difference 'Skill.count' do
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

  def test_更新_入力エラー
    skill = Skill.find_by(employee_id: employee.id, qualification_id: qualification.id)

    patch mm_skill_path(skill), xhr: true, params: {
      skill: { qualified_on: '' }
    }

    assert_response :success
    assert_template :edit
    assert assigns(:skill).errors[:qualified_on].present?
  end

  def test_削除
    assert skill = Skill.find_by(employee_id: employee.id, qualification_id: qualification.id)
    assert_not skill.deleted?

    assert_no_difference 'Skill.count' do
      delete mm_skill_path(skill), xhr: true
    end

    assert @skill = assigns(:skill)
    assert @skill.deleted?
    assert_response :success
    assert_template 'common/reload'
  end

end
