require 'test_helper'

class SkillTest < ActiveSupport::TestCase

  def test_資格取得日が空のときは日本語でエラーになる
    skill = Skill.find_by(employee_id: 1, qualification_id: 1)
    skill.qualified_on = nil

    assert_not skill.valid?
    assert_includes skill.errors.full_messages, '資格取得日を入力してください'
  end

end
