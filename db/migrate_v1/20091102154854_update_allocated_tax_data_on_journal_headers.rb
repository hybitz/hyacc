# -*- encoding : utf-8 -*-
require 'app/models/auto/auto_journal_util'

class A
  include Auto::AutoJournalUtil
end

class UpdateAllocatedTaxDataOnJournalHeaders < ActiveRecord::Migration
  include HyaccConstants
  def self.up
    jhs = JournalHeader.find(:all, :conditions=>["finder_key like ?","%" + ACCOUNT_CODE_CORPORATE_TAXES + "%"])
    puts "Head office tax cost #{jhs.size.to_s} match."
    jhs.each do |jh|
      puts "recreate journal header id :  #{jh.id.to_s}"
      do_auto_transfers(jh)
    end
  end
  
  def self.down
    raise HyaccException.new("法人税配賦を行った伝票を戻す必要がある。")
  end
  
  def self.do_auto_transfers( jh )
    auto_journal_util = A.new
    # 自動仕訳をクリア
    slip_types = [
      SLIP_TYPE_AUTO_TRANSFER_PREPAID_EXPENSE,
      SLIP_TYPE_AUTO_TRANSFER_ACCRUED_EXPENSE,
      SLIP_TYPE_AUTO_TRANSFER_EXPENSE,
      SLIP_TYPE_AUTO_TRANSFER_ALLOCATED_COST,
      SLIP_TYPE_AUTO_TRANSFER_ALLOCATED_ASSETS,
      SLIP_TYPE_AUTO_TRANSFER_INTERNAL_TRADE]
    auto_journal_util.clear_auto_journals(jh, slip_types)

    # 明細単位で発生する自動仕訳
    jh.journal_details.each do |jd|
      jd.auto_journal_types.each do |ajt|
        param = Auto::TransferJournal::TransferFromDetailParam.new( ajt, jd )
        factory = Auto::AutoJournalFactory.get_instance( param )
        factory.make_journals()
      end
    end
    
    # 内部取引
    param = Auto::TransferJournal::InternalTradeParam.new( jh )
    factory = Auto::AutoJournalFactory.get_instance( param )
    factory.make_journals()
  end
end
