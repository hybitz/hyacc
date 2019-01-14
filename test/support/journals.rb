module Journals
  include HyaccConstants

  def journal
    unless @_journal
      assert c = Company.first
      assert fy = c.fiscal_years.where(tax_management_type: TAX_MANAGEMENT_TYPE_EXCLUSIVE).first
      assert @_journal = Journal.where('company_id = ? and ym >= ? and ym <= ?', c.id, fy.start_year_month, fy.end_year_month).first
    end
    @_journal
  end

  def create_journal(options = {})
    c = options[:company]
    b = options[:branch]
    e = options[:employee]

    ret = Journal.new
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