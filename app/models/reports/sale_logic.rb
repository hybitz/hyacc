module Reports
  class SaleLogic < BaseLogic

    def build_model
      ret = SaleModel.new
      
      a = Account.find_by_code(ACCOUNT_CODE_SALE)
      sale_by_branch = VMonthlyLedger.term_net_sums_by_branch(start_ym, end_ym, company, a)
      sale_by_business_office = {}
      sale_by_branch.each do |branch_id, amount|
        b = company.branches.find(branch_id)
        Rails.logger.debug "#{branch_id} => #{b.business_office.id} => #{amount}"
        sale_by_business_office[b.business_office.id] ||= 0
        sale_by_business_office[b.business_office.id] += amount 
      end
      
      company.business_offices.each do |bo|
        detail = SaleDetailModel.new
        detail.business_office = bo
        detail.sale_amount = sale_by_business_office[bo.id]
        ret.add_detail(detail)
      end
      
      ret
    end

  end

  class SaleModel
    attr_accessor :details

    def add_detail(detail)
      self.details ||= []
      self.details << detail
    end
  end
  
  class SaleDetailModel
    attr_accessor :business_office
    attr_accessor :sale_amount

    def responsible_person_name
      business_office.responsible_person&.fullname
    end
    
    def responsible_person_relation
      business_office.responsible_person&.executive? ? '本人' : nil
    end    
  end
end
