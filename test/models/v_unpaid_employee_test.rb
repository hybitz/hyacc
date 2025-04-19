require 'test_helper'

class VUnpaidEmployeeTest < ActiveSupport::TestCase

  def test_部門別の未払金（従業員）
    c = company
    assert c.branches.size > 1

    e = create_employee(company: c)

    sums = VUnpaidEmployee.net_sums_by_branch(e)
    assert_equal 0, sums.size
    
    jh1 = create_journal(company: c, employee: e, branch: c.branches.first, amount: 2000)
    jh2 = create_journal(company: c, employee: e, branch: c.branches.second, amount: 4000)
    sums = VUnpaidEmployee.net_sums_by_branch(e)
    assert_equal 2, sums.size
    
    assert sum1 = sums.find{|sum| sum[0] == c.branches.first.id }
    assert_equal 2000, sum1[1]

    assert sum2 = sums.find{|sum| sum[0] == c.branches.second.id }
    assert_equal 4000, sum2[1]
  end

end
