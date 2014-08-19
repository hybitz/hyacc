module Auto

  class AutoJournalFactory
    include HyaccUtil

    def self.get_instance( auto_journal_param )
      factory_class_name = AUTO_JOURNAL_TYPES[auto_journal_param.auto_journal_type] if auto_journal_param
      factory_class_name ||= 'Auto::NilFactory'
      factory_class = eval(factory_class_name)
      factory_class.new(auto_journal_param)
    end

    def initialize( auto_journal_param )
      @auto_journal_param = auto_journal_param
    end
    
    def make_journals
      raise HyaccException.new(ERR_OVERRIDE_NEEDED)
    end

    protected

    def reverse_detail(jd)
      ret = JournalDetail.new
      ret.detail_no = jd.detail_no
      ret.dc_type = opposite_dc_type( jd.dc_type )
      ret.account_id = jd.account_id
      ret.branch_id = jd.branch_id
      ret.sub_account_id = jd.sub_account_id
      ret.social_expense_number_of_people = jd.social_expense_number_of_people 
      ret.amount = jd.amount
      ret.tax_type = jd.tax_type 
      ret.tax_rate = jd.tax_rate
      ret
    end
  end
  
  class NilFactory < AutoJournalFactory
    def make_journals
    end
  end

end
