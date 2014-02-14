# coding: UTF-8
#
# $Id: auto_journal_factory.rb 3063 2013-06-21 03:13:57Z ichy $
# Product: hyacc
# Copyright 2009-2013 by Hybitz.co.ltd
# ALL Rights Reserved.
#
module Auto
  
  class AutoJournalFactory
    include HyaccUtil
    
    def self.get_instance( auto_journal_param )
      return NilFactory.new unless auto_journal_param
      
      factory_class_name = AUTO_JOURNAL_TYPES[auto_journal_param.auto_journal_type]
      return NilFactory.new unless factory_class_name

      factory_class = eval(factory_class_name)
      factory_class.new(auto_journal_param)
    end
    
    def initialize( auto_journal_param = nil )
      @auto_journal_param = auto_journal_param
    end
    
    def make_journals()
      # サブクラスでの実装が必要
      raise HyaccException.new(ERR_OVERRIDE_NEEDED)
    end
  end
  
  class NilFactory < AutoJournalFactory
    def make_journals()
    end
  end
end
