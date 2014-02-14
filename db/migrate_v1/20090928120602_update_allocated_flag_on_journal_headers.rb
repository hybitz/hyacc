# -*- encoding : utf-8 -*-
#
# UpdateAllocatedDataOnJournalHeadersを実施した時に配賦フラグが更新されていなかったため
# データパッチを作成。
# 前回同様の条件で該当する伝票に対し、配賦フラグをセットする。
# ただし、対象伝票は2009年08月以前とする
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

class UpdateAllocatedFlagOnJournalHeaders < ActiveRecord::Migration
  include HyaccConstants
  
  def self.up
    journal_helper = A.new
    
    # ハイビッツ経費を検索し、費用配賦する
    jhs = JournalHeader.find(:all, :conditions=>["ym < 200909 and finder_key like ? ","-%8___,,1%"])
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
      
      # 配賦対象の仕分けを検索
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
        #allocate(jh)
        puts "OK-" + jh.id.to_s
        jh.save!
      elsif flag2 == 0
        puts "NG:Unable to allocate assets -#{jh.id.to_s}"
      elsif flag1 == 0
        puts "NG:Unable to allocate cost -#{jh.id.to_s}"
      else
        puts "NG:Unable to allocate assets and cost -#{jh.id.to_s}"
      end
    end

    # 社会保険料の更新　※補助科目ありのため別実施
    jhs = JournalHeader.find(:all, :conditions=>["ym < 200909 and finder_key like ? ","-%8___,_,1%"])
    puts "Hybitz cost #{jhs.size.to_s} match."
    jhs.each do |jh|
      
      # 手動で登録した伝票は問題ないため処理対象外とする
      if jh.id == 1884 || jh.id == 2732 || jh.id == 4496 || jh.id == 4748
        next
      end
      
      # 配賦対象の仕分けを検索
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
      #allocate(jh)
      puts "OK-" + jh.id.to_s
      jh.save!
    end
  end

  def self.down
  end

end
