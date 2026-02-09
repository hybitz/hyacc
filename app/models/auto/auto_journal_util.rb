module Auto
  module  AutoJournalUtil
    include HyaccConst
  
    def self.do_auto_transfers(jh)
      clear_auto_journals(jh)
  
      # 明細単位で発生する自動仕訳
      jh.journal_details.each do |jd|
        jd.auto_journal_types.each do |ajt|
          param = Auto::TransferJournal::TransferFromDetailParam.new(ajt, jd)
          factory = Auto::AutoJournalFactory.get_instance( param )
          factory.make_journals
        end
      end
  
      # 内部取引
      param = Auto::TransferJournal::InternalTradeParam.new(jh)
      factory = Auto::AutoJournalFactory.get_instance(param)
      factory.make_journals
    end
  
    def self.clear_auto_journals(jh)
      clear_auto_journals_internal(jh)
      jh.journal_details.each do |jd|
        clear_auto_journals_internal(jd)
      end
    end
  
    def self.clear_auto_journals_internal(src)
      src.transfer_journals.each do |tj|
        tj.mark_for_destruction if tj.auto?
      end
    end
  end
end
