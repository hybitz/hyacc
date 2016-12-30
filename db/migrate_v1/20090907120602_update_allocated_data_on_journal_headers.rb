# -*- encoding : utf-8 -*-
require 'app/helpers/journal_helper'

class A
  include JournalHelper
end

class Debt
  def initialize
    @d = Hash::new
  end
  def add(branch_id, sub_account_id, amount)
    key = branch_id.to_s + sub_account_id.to_s
    if @d.has_key?(key)
      @d[key] += amount
    else
      @d[key] = amount
    end
  end
  def get
    @d
  end
end

class UpdateAllocatedDataOnJournalHeaders < ActiveRecord::Migration
  include HyaccConstants
  def self.up
    a1 = Account.find_by_code(ACCOUNT_CODE_HEAD_OFFICE_COST)
    a2 = Account.find_by_code(ACCOUNT_CODE_HEAD_OFFICE_COST_SHARE)

    journal_helper = A.new

    # 本社費用負担、本社費用配賦を削除
    jhs = JournalHeader.find(:all, :conditions=>["finder_key like ? or finder_key like ?","%" + ACCOUNT_CODE_HEAD_OFFICE_COST + "%","%" + ACCOUNT_CODE_HEAD_OFFICE_COST_SHARE + "%"])
    puts "Head office cost #{jhs.size.to_s} match."
    jhs.each do |jh|
      new_jd = []
      jh.journal_details.each do |jd|
        unless jd.account_id == a1.id or jd.account_id == a2.id
          new_jd << jd
        end
      end
      jh.journal_details = new_jd
      jh.save!
    end

    # ハイビッツ経費を検索し、費用配賦する
    jhs = JournalHeader.find(:all, :conditions=>["finder_key like ? ","-%8___,,1%"])
    puts "Hybitz cost #{jhs.size.to_s} match."
    jhs.each do |jh|
      flag1 = 0
      flag2 = 0
      # 例外処理
      unless jh.remarks.index('外注費').nil? and
        jh.remarks.index('国民生活金融公庫').nil? and
        jh.remarks.index('公庫返済').nil? and
        jh.remarks.index('業務委託費').nil? and
        jh.remarks.index('住民税の納付').nil? and
        jh.remarks.index('道民税・事業税・市民税の支払').nil? and # 1884
        jh.remarks.index('道民税・事業税の支払').nil? # 4748

        # 以下手動で修正する必要あり
        # 2008/5/18 2732 資産配賦必要なし
        # 2009/2/2 4748 事業税のみ配賦
        # 2009/1/28 1884 事業税のみ配賦
        # 2009/1/5 4496 支払手数料のみ配賦
        # 2008/8/7 3372 不要

        next
      end
      # 配賦対象の仕訳を検索
      jh.journal_details.each do |jd|
        if journal_helper.is_real_cost(jd.account_id) and jd.branch_id == 1
          # 費用
          flag1 += 1
          jd.is_allocated_cost = JournalDetail::ALLOCATE_TYPE_ON
        elsif journal_helper.can_allocate_assets(jd.account_id, jd.dc_type)
          # 資産
          flag2 += 1
          jd.is_allocated_assets = JournalDetail::ALLOCATE_TYPE_ON
        end
      end
      if flag1 == 0 and flag2 == 0
        # 配賦なし
      elsif flag1 >= 1 and flag2 >= 1
        allocate(jh)
      elsif flag2 == 0
        puts "NG:Unable to allocate assets -#{jh.id.to_s}"
      elsif flag1 == 0
        puts "NG:Unable to allocate cost -#{jh.id.to_s}"
      else
        puts "NG:Unable to allocate assets and cost -#{jh.id.to_s}"
      end
    end

    # 社会保険料の更新　※補助科目ありのため別実施
    jhs = JournalHeader.find(:all, :conditions=>["finder_key like ? ","-%8___,_,1%"])
    puts "Hybitz cost #{jhs.size.to_s} match."
    jhs.each do |jh|
      # 配賦対象の仕訳を検索
      jh.journal_details.each do |jd|
        if journal_helper.is_real_cost(jd.account_id) and jd.branch_id == 1
          jd.is_allocated_cost = JournalDetail::ALLOCATE_TYPE_ON
        elsif journal_helper.can_allocate_assets(jd.account_id, jd.dc_type)
          # 児童手当分のみ配賦
          if jd.branch_id == 1
            jd.is_allocated_assets = JournalDetail::ALLOCATE_TYPE_ON
          end
        end
      end
      allocate(jh)
    end

    check

  end

  def self.allocate(jh)
    # 通常配賦
    puts "OK-" + jh.id.to_s
    # 自動仕訳をクリア
    jh.transfer_journals.clear
    # 費用配賦
    param = Auto::TransferJournal::AllocatedCostParam.new( jh )
    factory = Auto::AutoJournalFactory.get_instance( param )
    factory.make_journals() unless factory.nil?
    # 資産配賦
    param = Auto::TransferJournal::AllocatedAssetsParam.new( jh )
    factory = Auto::AutoJournalFactory.get_instance( param )
    factory.add_journals() unless factory.nil?
    # 内部取引
    param = Auto::TransferJournal::InternalTradeParam.new( jh )
    factory = Auto::AutoJournalFactory.get_instance( param )
    factory.add_journals() unless factory.nil?
    jh.save!
  end

  def self.check
    # 仮負債の検索
    fy2007 = Debt.new
    fy2008 = Debt.new
    fy2009 = Debt.new

    jhs = JournalHeader.find(:all, :conditions=>["finder_key like ? ","%3501%"])
    puts "Temporary debt #{jhs.size.to_s} match."
    jhs.each do |jh|
      fy = fy2007
      fy = fy2008 if jh.ym > 200711
      fy = fy2009 if jh.ym > 200811
      jh.journal_details.each do |jd|
        # 仮負債
        if jd.account_id == 85
          fy.add(jd.branch_id, jd.sub_account_id, jd.amount)
        end
      end
    end
    fy2007.get.each {|key, value|
      puts "FY2007:#{key} - #{value}"
    }
    fy2008.get.each {|key, value|
      puts "FY2008:#{key} - #{value}"
    }
    fy2009.get.each {|key, value|
      puts "FY2009:#{key} - #{value}"
    }
  end

  def self.down
  end

end
