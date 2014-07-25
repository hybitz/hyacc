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
  end
  
  class NilFactory < AutoJournalFactory
    def make_journals
    end
  end

end
