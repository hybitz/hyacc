require 'auto/auto_journal_factory'
require 'auto/transfer_journal/internal_trade_param'
require 'auto/transfer_journal/transfer_from_detail_param'

module Auto::AutoJournalUtil
  include HyaccConstants

  def self.do_auto_transfers(jh)
    # 自動仕訳をクリア
    slip_types = [
      SLIP_TYPE_AUTO_TRANSFER_PREPAID_EXPENSE,
      SLIP_TYPE_AUTO_TRANSFER_ACCRUED_EXPENSE,
      SLIP_TYPE_AUTO_TRANSFER_EXPENSE,
      SLIP_TYPE_AUTO_TRANSFER_ALLOCATED_COST,
      SLIP_TYPE_AUTO_TRANSFER_ALLOCATED_ASSETS,
      SLIP_TYPE_AUTO_TRANSFER_INTERNAL_TRADE
    ]
    clear_auto_journals(jh, slip_types)

    # 明細単位で発生する自動仕訳
    jh.journal_details.each do |jd|
      jd.auto_journal_types.each do |ajt|
        param = Auto::TransferJournal::TransferFromDetailParam.new(ajt, jd)
        factory = Auto::AutoJournalFactory.get_instance( param )
        factory.make_journals
      end
    end

    # 内部取引
    param = Auto::TransferJournal::InternalTradeParam.new( jh )
    factory = Auto::AutoJournalFactory.get_instance( param )
    factory.make_journals
  end

  def self.clear_auto_journals(jh, slip_types)
    clear_auto_journals_internal(jh, slip_types)
    jh.journal_details.each do |jd|
      clear_auto_journals_internal(jd, slip_types)
    end
  end

  def self.clear_auto_journals_internal(src, slip_types)
    src.transfer_journals.each do |tj|
      tj.mark_for_destruction if slip_types.include?(tj.slip_type)
    end
  end
end
