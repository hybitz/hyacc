require 'test_helper'

class BranchTest < ActiveSupport::TestCase

  def test_parent
    ichy = Branch.find(2)
    head = Branch.find(1)
    parent = ichy.parent
    assert_equal head.id, parent.id
  end

  def test_business_office
    ichy = Branch.find(2)
    head = Branch.find(1)
    
    assert_equal head.business_office, ichy.business_office
  end

  def test_validates_code_presence
    branch = company.branches.build(branch_params.merge(code: ''))
    assert_not branch.valid?
    assert branch.errors[:code].present?
  end

  def test_validates_formal_name_presence
    branch = company.branches.build(branch_params.merge(formal_name: ''))
    assert_not branch.valid?
    assert branch.errors[:formal_name].present?
  end
end
