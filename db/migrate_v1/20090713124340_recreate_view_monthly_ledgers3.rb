# -*- encoding : utf-8 -*-
class RecreateViewMonthlyLedgers3 < ActiveRecord::Migration
  include HyaccConstants
  
  def self.up
    drop_view :v_monthly_ledgers
    create_view :v_monthly_ledgers,
      "select
          `jh`.`ym` AS `ym`,
          `jd`.`dc_type` AS `dc_type`,
          `jd`.`account_id` AS `account_id`,
          `a`.`sub_account_type` AS `sub_account_type`,
          `a`.`path` AS `path`,
          `jd`.`sub_account_id` AS `sub_account_id`,
          `jd`.`branch_id` AS `branch_id`,
          sum(`jd`.`amount`) AS `amount`
        from `journal_headers` `jh` join `accounts` `a` join `journal_details` `jd`
        where `jh`.`id` = `jd`.`journal_header_id`
          and `jd`.`account_id` = `a`.`id`
        group by `jh`.`ym`,`jd`.`dc_type`,`jd`.`account_id`,`jd`.`sub_account_id`,`jd`.`branch_id`", :force => true do |v|
      v.column :ym
      v.column :dc_type
      v.column :account_id
      v.column :sub_account_type
      v.column :path
      v.column :sub_account_id
      v.column :branch_id
      v.column :amount
    end
  end

  def self.down
    drop_view :v_monthly_ledgers
    create_view :v_monthly_ledgers,
      "select
          `jh`.`ym` AS `ym`,
          `jd`.`dc_type` AS `dc_type`,
          `jd`.`account_id` AS `account_id`,
          `jd`.`account_name` AS `account_name`,
          `a`.`sub_account_type` AS `sub_account_type`,
          `a`.`path` AS `path`,
          `jd`.`sub_account_id` AS `sub_account_id`,
          `jd`.`sub_account_name` AS `sub_account_name`,
          `jd`.`branch_id` AS `branch_id`,
          `jd`.`branch_name` AS `branch_name`,
          sum(`jd`.`amount`) AS `amount`
        from `journal_headers` `jh` join `accounts` `a` join `journal_details` `jd`
        where `jh`.`id` = `jd`.`journal_header_id`
          and `jd`.`account_id` = `a`.`id`
        group by `jh`.`ym`,`jd`.`dc_type`,`jd`.`account_id`,`jd`.`account_name`,
          `jd`.`sub_account_id`,`jd`.`sub_account_name`,`jd`.`branch_id`,`jd`.`branch_name`", :force => true do |v|
      v.column :ym
      v.column :dc_type
      v.column :account_id
      v.column :account_name
      v.column :sub_account_type
      v.column :path
      v.column :sub_account_id
      v.column :sub_account_name
      v.column :branch_id
      v.column :branch_name
      v.column :amount
    end
  end
end
