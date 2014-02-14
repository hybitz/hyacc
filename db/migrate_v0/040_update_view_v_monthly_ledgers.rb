# -*- encoding : utf-8 -*-
class UpdateViewVMonthlyLedgers < ActiveRecord::Migration
  def self.up
    drop_view :v_monthly_ledgers
    create_view :v_monthly_ledgers, 
      "select
        jh.ym,
        jd.dc_type,
        a.id,
        a.name,
        a.path,
        sa.id,
        sa.name,
        b.id,
        b.name,
        sum( jd.amount )
      from journal_headers jh, accounts a, branches b, journal_details jd
      left outer join sub_accounts sa on jd.sub_account_id = sa.id
      where jh.id = jd.journal_header_id
        and jd.account_id = a.id
        and jd.branch_id = b.id
      group by jh.ym, jd.account_id, jd.sub_account_id, jd.dc_type, jd.branch_id" do |t|
        
        t.column :ym
        t.column :dc_type
        t.column :account_id
        t.column :account_name
        t.column :path
        t.column :sub_account_id
        t.column :sub_account_name
        t.column :branch_id
        t.column :branch_name
        t.column :amount
    end
  end

  def self.down
    drop_view :v_monthly_ledgers
    create_view :v_monthly_ledgers, 
      "select
        jh.ym 'ym',
        a.id 'account_id',
        a.name 'account_name',
        a.path 'path',
        jd.dc_type 'dc_type',
        b.id 'branch_id',
        b.name 'branch_name',
        sum( jd.amount ) 'amount'
      from journal_headers jh, journal_details jd, accounts a, branches b
      where jh.id = jd.journal_header_id
        and jd.account_id = a.id
        and jd.branch_id = b.id
      group by jh.ym, jd.account_id, jd.dc_type, jd.branch_id" do |t|
        
        t.column :ym
        t.column :account_id
        t.column :account_name
        t.column :path
        t.column :dc_type
        t.column :branch_id
        t.column :branch_name
        t.column :amount
    end
  end
end
