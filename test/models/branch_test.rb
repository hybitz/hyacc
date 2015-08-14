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
end
