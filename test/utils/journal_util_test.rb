require 'test_helper'

class JournalUtilTest < ActiveSupport::TestCase

  def test_make_capitation
    c = create_company

    assert b = c.branches.create(code: 'TEST', name: 'テスト', formal_name: 'テスト')
    assert e = create_employee(company: c, branch: b)
    be = e.branch_employees.last
    assert be.update(default_branch: false)
    ret = JournalUtil.make_capitation(100, b.reload.self_and_descendants)
    assert_equal 0, ret.size
    
    assert be.update(default_branch: true)
    ret = JournalUtil.make_capitation(100, b.reload.self_and_descendants)
    assert_equal 1, ret.size
    assert_equal 100, ret[b]

    assert b_2 = c.branches.create(code: 'TEST', name: 'テスト2', formal_name: 'テスト2', parent: b)
    assert create_employee(company: c, branch: b_2)
    ret = JournalUtil.make_capitation(100, b.reload.self_and_descendants)
    assert_equal 2, ret.size
    assert_equal 50, ret[b]
    assert_equal 50, ret[b_2]

    assert b_2_2 = c.branches.create(code: 'TEST', name: 'テスト2_2', formal_name: 'テスト2_2', parent: b_2)
    assert create_employee(company: c, branch: b_2_2)
    ret = JournalUtil.make_capitation(100, b.reload.self_and_descendants)
    assert_equal 3, ret.size
    assert_equal 34, ret[b]
    assert_equal 33, ret[b_2]
    assert_equal 33, ret[b_2_2]

    assert b_3 = c.branches.create(code: 'TEST', name: 'テスト3', formal_name: 'テスト3', parent: b)
    assert create_employee(company: c, branch: b_3)
    ret = JournalUtil.make_capitation(100, b.reload.self_and_descendants)
    assert_equal 4, ret.size
    assert_equal 25, ret[b]
    assert_equal 25, ret[b_2]
    assert_equal 25, ret[b_2_2]
    assert_equal 25, ret[b_3]
  end
end
