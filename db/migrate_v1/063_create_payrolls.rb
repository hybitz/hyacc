# -*- encoding : utf-8 -*-
require 'migration_helpers'
require 'date'

class CreatePayrolls < ActiveRecord::Migration
 extend MigrationHelpers
 include HyaccConstants
  
  def self.up
    create_table :payrolls do |t|
      t.integer :ym, :limit => 6, :null => false
      t.integer :user_id, :limit => 6, :null => false
      t.integer :payroll_journal_header_id, :limit => 11
      t.integer :pay_journal_header_id, :limit => 11
      t.integer :days_of_work, :limit => 2, :default => 0
      t.integer :hours_of_work, :limit => 5, :default => 0
      t.integer :hours_of_day_off_work, :limit => 5, :default => 0
      t.integer :hours_of_early_for_work, :limit => 5, :default => 0
      t.integer :hours_of_late_night_work, :limit => 5, :default => 0

      t.timestamps
    end
    
    add_index :payrolls, :ym
    add_index :payrolls, :user_id
    foreign_key :payrolls, :payroll_journal_header_id, :journal_headers
    foreign_key :payrolls, :pay_journal_header_id, :journal_headers
    
    update_hybitz_user
    
  end

  def self.down
    Payroll.delete_all
    drop_foreign_key :payrolls, :pay_journal_header_id
    drop_foreign_key :payrolls, :payroll_journal_header_id
    remove_index :payrolls, :ym
    remove_index :payrolls, :user_id
    drop_table :payrolls
  end

  private
  def self.update_hybitz_user
    # 給与明細の検索
    conditions = []
    conditions[0] = "remarks like ? AND (remarks like ? OR remarks like ?) AND day > ?"
    conditions << '%給与%'
    conditions << '%ICHY%'
    conditions << '%ＩＣＨＹ%'
    conditions << 20
    JournalHeader.find(:all, :conditions=>conditions).each do | jh |
      yyyymm = jh.ym + 1
      # 振込日付の計算
      if yyyymm.to_s[4,2] == '13'
        yyyymm = jh.ym - 11 + 100
      end
      # 振込明細の検索
      conditions2 = []
      conditions2[0] = "remarks like ? AND (remarks like ? OR remarks like ?) AND day < ? AND ym >= ?"
      conditions2 << '%給与%'
      conditions2 << '%ICHY%'
      conditions2 << '%ＩＣＨＹ%'
      conditions2 << 10
      conditions2 << yyyymm
      jh2 = JournalHeader.find(:first, :conditions=>conditions2, :order=>"ym")
      pj = Payroll.new
      pj.ym = jh.ym
      pj.user_id = '1'
      pj.payroll_journal_header_id = jh.id
      if jh2 != nil
        pj.pay_journal_header_id = jh2.id
      end
      pj.days_of_work = Date.new(jh.ym/100, jh.ym%100, -1).day
      pj.save!
      
      # 伝票区分の更新
      jh.update_attributes(:slip_type => SLIP_TYPE_AUTO_TRANSFER_LEDGER_REGISTRATION) if jh != nil
      jh2.update_attributes(:slip_type => SLIP_TYPE_AUTO_TRANSFER_LEDGER_REGISTRATION) if jh2 != nil
    end
    
    # 給与明細の検索
    conditions = []
    conditions[0] = "remarks like ? AND (remarks like ? OR remarks like ?) AND day > ?"
    conditions << '%給与%'
    conditions << '%HIRO%'
    conditions << '%ＨＩＲＯ%'
    conditions << 20
    JournalHeader.find(:all, :conditions=>conditions).each do | jh |
      yyyymm = jh.ym + 1
      # 振込日付の計算
      if yyyymm.to_s[4,2] == '13'
        yyyymm = jh.ym - 11 + 100
      end
      # 振込明細の検索
      conditions2 = []
      conditions2[0] = "remarks like ? AND (remarks like ? OR remarks like ?) AND day < ? AND ym >= ?"
      conditions2 << '%給与%'
      conditions2 << '%HIRO%'
      conditions2 << '%ＨＩＲＯ%'
      conditions2 << 10
      conditions2 << yyyymm
      jh2 = JournalHeader.find(:first, :conditions=>conditions2, :order=>"ym")
      pj = Payroll.new
      pj.ym = jh.ym
      pj.user_id = '2'
      pj.payroll_journal_header_id = jh.id
      if jh2 != nil
        pj.pay_journal_header_id = jh2.id
      end
      pj.days_of_work = Date.new(jh.ym/100, jh.ym%100, -1).day
      pj.save!
      
      # 伝票区分の更新
      jh.update_attributes(:slip_type => SLIP_TYPE_AUTO_TRANSFER_LEDGER_REGISTRATION) if jh != nil
      jh2.update_attributes(:slip_type => SLIP_TYPE_AUTO_TRANSFER_LEDGER_REGISTRATION) if jh2 != nil
    end
  end
end
