class VUnpaidEmployee
  include HyaccConstants

  VIEW = <<EOS
    select
      jh.company_id,
      jd.dc_type,
      jd.account_id,
      jd.sub_account_id,
      jd.branch_id,
      sum(jd.amount) as amount
    from journal_details jd
    inner join journal_headers jh on (jh.id = jd.journal_header_id)
    inner join accounts a on (a.id = jd.account_id)
    inner join employees e on (e.id = jd.sub_account_id)
    inner join branches b on (b.id = jd.branch_id)
    group by jh.company_id, jd.dc_type, jd.account_id, jd.sub_account_id, jd.branch_id
EOS

  def self.account
    Account.find_by_code(ACCOUNT_CODE_UNPAID_EMPLOYEE)
  end

  def self.find_by_sql(args)
    JournalDetail.find_by_sql(args)
  end
  
  def self.net_sums_by_branch(employee, options = {})
    sql = SqlBuilder.new
    sql.append('where company_id = ?', employee.company_id)
    sql.append('  and account_id = ? ', account.id)
    sql.append('  and sub_account_id = ?', employee.id)
    
    if options[:order]
      sql.append('order by ' + options[:order])
    end

    conditions = sql.to_a
    sums = find_by_sql(["select * from (#{VIEW}) as unpaid_employee #{conditions[0]}"] + conditions[1..-1])

    ret = {}
    sums.each do |sum|
      if ret[sum.branch_id]
        if sum.dc_type == account.dc_type
          ret[sum.branch_id].amount += sum.amount
        else
          ret[sum.branch_id].amount -= sum.amount
        end
      else
        ret[sum.branch_id] = sum
      end
    end

    ret.values
  end
  
end
