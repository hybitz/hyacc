require 'test_helper'

class JournalUtilTest < ActiveSupport::TestCase

  def test_make_capitation
    c = create_company

    assert b = c.branches.create(code: 'TEST', name: 'テスト', formal_name: 'テスト')
    assert e = create_employee(company: c, branch: b)
    be = e.branch_employees.last
    assert be.update(default_branch: false)
    error = assert_raises RuntimeError do 
      JournalUtil.make_capitation(100, b.reload.self_and_descendants, b.id)
    end
    assert_equal ERR_NO_CAPITATION_TARGET_BRANCH_EXISTS, error.message

    assert be.update(default_branch: true)
    error = assert_raises RuntimeError do 
      JournalUtil.make_capitation(100, b.reload.self_and_descendants, b.id)
    end
    assert_equal ERR_NO_CAPITATION_TARGET_BRANCH_EXISTS, error.message

    assert b_2 = c.branches.create(code: 'TEST', name: 'テスト2', formal_name: 'テスト2', parent: b)
    assert create_employee(company: c, branch: b_2)
    ret = JournalUtil.make_capitation(100, b.reload.self_and_descendants, b.id)
    assert_equal 2, ret.size
    assert_equal 50, ret[b]
    assert_equal 50, ret[b_2]

    assert b_2_2 = c.branches.create(code: 'TEST', name: 'テスト2_2', formal_name: 'テスト2_2', parent: b_2)
    assert create_employee(company: c, branch: b_2_2)
    ret = JournalUtil.make_capitation(100, b.reload.self_and_descendants, b.id)
    assert_equal 3, ret.size
    assert_equal 34, ret[b]
    assert_equal 33, ret[b_2]
    assert_equal 33, ret[b_2_2]

    assert b_3 = c.branches.create(code: 'TEST', name: 'テスト3', formal_name: 'テスト3', parent: b)
    assert create_employee(company: c, branch: b_3)
    ret = JournalUtil.make_capitation(100, b.reload.self_and_descendants, b.id)
    assert_equal 4, ret.size
    assert_equal 25, ret[b]
    assert_equal 25, ret[b_2]
    assert_equal 25, ret[b_2_2]
    assert_equal 25, ret[b_3]

    b_3.employees.update_all(deleted: true)
    ret = JournalUtil.make_capitation(100, b.reload.self_and_descendants, b.id)
    assert_equal 3, ret.size
    assert_not_includes ret.keys, b_3
    assert_equal 34, ret[b]
    assert_equal 33, ret[b_2]
    assert_equal 33, ret[b_2_2]

    ret = JournalUtil.make_capitation(1, b.self_and_descendants, b.id)
    assert_equal 3, ret.size
    assert_equal 0, ret[b]
    assert_equal 1, ret[b_2]
    assert_equal 0, ret[b_2_2]

    ret = JournalUtil.make_capitation(2, b.self_and_descendants, b.id)
    assert_equal 3, ret.size
    assert_equal 0, ret[b]
    assert_equal 2, ret[b_2]
    assert_equal 0, ret[b_2_2]

    ret = JournalUtil.make_capitation(3, b.self_and_descendants, b.id)
    assert_equal 3, ret.size
    assert_equal 1, ret[b]
    assert_equal 1, ret[b_2]
    assert_equal 1, ret[b_2_2]

    b_2_2.branch_employees.update_all(deleted: true)
    ret = JournalUtil.make_capitation(100, b.reload.self_and_descendants, b.id)
    assert_equal 2, ret.size
    assert_not_includes ret.keys, b_2_2
    assert_equal 50, ret[b]
    assert_equal 50, ret[b_2]

    b_2.employees.update_all(disabled: true)
    error = assert_raises RuntimeError do 
      JournalUtil.make_capitation(100, b.reload.self_and_descendants, b.id)
    end
    assert_equal ERR_NO_CAPITATION_TARGET_BRANCH_EXISTS, error.message
  end

  def test_make_capitation_when_parent_branch_has_more_employees
    c = create_company
    assert b = c.branches.create(code: 'TEST', name: 'テスト', formal_name: 'テスト')
    assert create_employee(company: c, branch: b).branch_employees.last.update(default_branch: true)
    assert create_employee(company: c, branch: b).branch_employees.last.update(default_branch: true)
    assert_equal 2, b.employees.where(deleted: false, disabled: false).size

    assert b_2 = c.branches.create(code: 'TEST', name: 'テスト2', formal_name: 'テスト2', parent: b)
    assert create_employee(company: c, branch: b_2)
    assert_equal 1, b_2.employees.where(deleted: false, disabled: false).size

    ret = JournalUtil.make_capitation(100, b.reload.self_and_descendants, b.id)
    assert_equal 2, ret.size
    assert_equal 67, ret[b]
    assert_equal 33, ret[b_2]

    ret = JournalUtil.make_capitation(2, b.reload.self_and_descendants, b.id)
    assert_equal 2, ret.size
    assert_equal 1, ret[b]
    assert_equal 1, ret[b_2]

    ret = JournalUtil.make_capitation(1, b.reload.self_and_descendants, b.id)
    assert_equal 2, ret.size
    assert_equal 0, ret[b]
    assert_equal 1, ret[b_2]
  end
end
