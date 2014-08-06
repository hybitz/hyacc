class HouseworkDetail < ActiveRecord::Base
  belongs_to :account
  belongs_to :housework
  has_many :journal_details, :dependent=>:destroy
  validates_presence_of :business_ratio

  def net_sum_amount
    fy = FiscalYear.find_by_company_id_and_fiscal_year(housework.company_id, housework.fiscal_year)
    ret = VMonthlyLedger.get_net_sum_amount(fy.start_year_month, fy.end_year_month, account_id, 0, 0, :include_children => false)
    ret += housework_amount
  end
  
  def housework_amount
    journal_details.inject(0){|ret, jd|
      if jd.account_id == account_id
        ret += jd.amount
      else
        ret
      end
    }
  end
  
  def sub_account
    account.get_sub_account_by_id(sub_account_id)
  end
end
