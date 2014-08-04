module FiscalYearsHelper
  include HyaccConstants
  
  def calc_carry_forward_revenue_amount(jh)
    a = Account.get_by_code(ACCOUNT_CODE_EARNED_SURPLUS_CARRIED_FORWARD)

    jh.journal_details.each do |jd|
      next if jd.account_id != a.id
      
      # 利益がプラスで繰り越されてるということは、昨年度は赤字だったので元入金で補填したということ
      if jd.dc_type == DC_TYPE_CREDIT
        return jd.amount * -1
      # 利益がマイナスで繰り越されているということは、昨年度は黒字だったので元入金に振り替えたということ
      else
        return jd.amount
      end
    end
    
    jh.amount
  end
end
