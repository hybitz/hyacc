require 'test_helper'

class VUnpaidEmployeeTest < ActiveSupport::TestCase

  def test_部門別の未払金（従業員）
    c = company
    assert c.branches.size > 1

    e = create_employee(company: c)
    assert e.save, e.errors.full_messages.join("\n")

    sums = VUnpaidEmployee.net_sums_by_branch(e)
    assert_equal 0, sums.size
    
    jh1 = create_journal(company: c, employee: e, branch: c.branches.first, amount: 2000)
    jh2 = create_journal(company: c, employee: e, branch: c.branches.second, amount: 4000)
    sums = VUnpaidEmployee.net_sums_by_branch(e)
    assert_equal 2, sums.size
    
    assert sum1 = sums.find{|sum| sum.branch_id == c.branches.first.id }
    assert_equal 2000, sum1.amount

    assert sum2 = sums.find{|sum| sum.branch_id == c.branches.second.id }
    assert_equal 4000, sum2.amount
  end

  private

  def create_journal(options = {})
    c = options[:company]
    b = options[:branch]
    e = options[:employee]

    ret = JournalHeader.new
    ret.company = options[:company]
    ret.date = c.current_fiscal_year.start_day + rand(365).days
    ret.remarks = 'テスト'
    ret.slip_type = SLIP_TYPE_TRANSFER
    ret.create_user_id = ret.update_user_id = e.user_id
    
    jd = ret.journal_details.build
    jd.detail_no = ret.journal_details.size
    jd.dc_type = DC_TYPE_DEBIT
    jd.account = expense_account
    jd.branch = b
    jd.amount = options[:amount]

    jd = ret.journal_details.build
    jd.detail_no = ret.journal_details.size
    jd.dc_type = DC_TYPE_CREDIT
    jd.account = Account.find_by_code(ACCOUNT_CODE_UNPAID_EMPLOYEE)
    jd.sub_account_id = e.id
    jd.branch = b
    jd.amount = options[:amount]
    
    assert ret.save, ret.errors.full_messages.join("\n")
    ret
  end
end
