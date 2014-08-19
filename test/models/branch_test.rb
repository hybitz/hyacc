require 'test_helper'

class BranchTest < ActiveSupport::TestCase
  include HyaccUtil
  fixtures :branches

  def test_parent
    ichy = Branch.find(2)
    head = Branch.find(1)
    parent = ichy.parent
    assert_equal head.id, parent.id
  end
  
  def test_sub_branches
    head = Branch.find(1)
    sub_branches = head.sub_branches
    assert_equal 2, sub_branches.length
    s1 = sub_branches.find(2)
    assert_not_nil s1
    s2 = sub_branches.find(3)
    assert_not_nil s2
  end
end
