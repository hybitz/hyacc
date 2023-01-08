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
        detail.number_of_employees = bo.employees(end_day).count
        ret.add_detail(detail)
      end
      
      ret.fill_details(10)
      ret
    end

  end

  class SaleModel
    attr_accessor :details

    def add_detail(detail)
      self.details ||= []
      self.details << detail
    end

    def fill_details(min_count)
      (details.size ... min_count).each do
        add_detail(SaleDetailModel.new)
      end
    end

    def total_sale_amount
      details.inject(0){|sum, detail| sum += detail.sale_amount.to_i }
    end

    def total_number_of_employees
      details.inject(0){|sum, detail| sum += detail.number_of_employees.to_i }
    end
  end
  
  class SaleDetailModel
    attr_accessor :business_office
    attr_accessor :sale_amount
    attr_accessor :number_of_employees

    def responsible_person_name
      business_office&.responsible_person&.fullname
    end
    
    def responsible_person_relation
      business_office&.responsible_person&.executive? ? '本人' : nil
    end    
  end
end
