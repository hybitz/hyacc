require 'test_helper'

class QualificationTest < ActiveSupport::TestCase

  def test_validates_name_presence
    q = company.qualifications.build(name: '', allowance: 0)

    assert_not q.valid?
    assert q.errors[:name].present?
  end

  def test_validates_allowance_presence
    q = company.qualifications.build(name: 'テスト資格', allowance: nil)

    assert_not q.valid?
    assert q.errors[:allowance].present?
  end

end
