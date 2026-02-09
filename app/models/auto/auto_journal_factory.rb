module Auto
  class AutoJournalFactory
    include HyaccConst
    include HyaccErrors

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

    def reverse_detail(auto, reverse)
      reverse.detail_no = auto.detail_no
      reverse.dc_type =  HyaccUtil.opposite_dc_type(auto.dc_type)
      reverse.account_id = auto.account_id
      reverse.branch_id = auto.branch_id
      reverse.sub_account_id = auto.sub_account_id
      reverse.social_expense_number_of_people = auto.social_expense_number_of_people 
      reverse.amount = auto.amount
      reverse.tax_type = auto.tax_type 
      reverse.tax_rate = auto.tax_rate
      reverse
    end
  end
  
  class NilFactory < AutoJournalFactory
    def make_journals
    end
  end

end
