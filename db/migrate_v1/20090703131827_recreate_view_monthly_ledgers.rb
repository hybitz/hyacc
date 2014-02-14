# -*- encoding : utf-8 -*-
class RecreateViewMonthlyLedgers < ActiveRecord::Migration
  include HyaccConstants
  
  def self.up
    drop_view :v_monthly_ledgers
    create_view :v_monthly_ledgers,
      "select
          `jh`.`ym` AS `ym`,
          `jd`.`dc_type` AS `dc_type`,
          `a`.`id` AS `account_id`,
          `a`.`name` AS `account_name`,
          `a`.`sub_account_type` AS `sub_account_type`,
          `a`.`path` AS `path`,
          `sa`.`id` AS `sub_account_id`,
          `sa`.`name` AS `sub_account_name`,
          `b`.`id` AS `branch_id`,
          `b`.`name` AS `branch_name`,
          sum(`jd`.`amount`) AS `amount`
        from (((`journal_headers` `jh`
          join `accounts` `a`)
          join `branches` `b`)
          join (`journal_details` `jd` left join `sub_accounts` `sa` on((`jd`.`sub_account_id` = `sa`.`id`))))
        where ((`jh`.`id` = `jd`.`journal_header_id`)
          and (`jd`.`account_id` = `a`.`id`
          and `a`.sub_account_type = #{SUB_ACCOUNT_TYPE_NORMAL})
          and (`jd`.`branch_id` = `b`.`id`))
        group by `jh`.`ym`,`jd`.`account_id`,`jd`.`sub_account_id`,`jd`.`dc_type`,`jd`.`branch_id`
       union
       select
          `jh`.`ym` AS `ym`,
          `jd`.`dc_type` AS `dc_type`,
          `a`.`id` AS `account_id`,
          `a`.`name` AS `account_name`,
          `a`.`sub_account_type` AS `sub_account_type`,
          `a`.`path` AS `path`,
          `u`.`id` AS `sub_account_id`,
          `u`.`login_id` AS `sub_account_name`,
          `b`.`id` AS `branch_id`,
          `b`.`name` AS `branch_name`,
          sum(`jd`.`amount`) AS `amount`
        from (((`journal_headers` `jh`
          join `accounts` `a`)
          join `branches` `b`)
          join (`journal_details` `jd` left join `users` `u` on((`jd`.`sub_account_id` = `u`.`id`))))
        where ((`jh`.`id` = `jd`.`journal_header_id`)
          and (`jd`.`account_id` = `a`.`id`
          and `a`.sub_account_type = #{SUB_ACCOUNT_TYPE_EMPLOYEE})
          and (`jd`.`branch_id` = `b`.`id`))
        group by `jh`.`ym`,`jd`.`account_id`,`jd`.`sub_account_id`,`jd`.`dc_type`,`jd`.`branch_id`
       union
       select
          `jh`.`ym` AS `ym`,
          `jd`.`dc_type` AS `dc_type`,
          `a`.`id` AS `account_id`,
          `a`.`name` AS `account_name`,
          `a`.`sub_account_type` AS `sub_account_type`,
          `a`.`path` AS `path`,
          `c`.`id` AS `sub_account_id`,
          `c`.`name` AS `sub_account_name`,
          `b`.`id` AS `branch_id`,
          `b`.`name` AS `branch_name`,
          sum(`jd`.`amount`) AS `amount`
        from (((`journal_headers` `jh`
          join `accounts` `a`)
          join `branches` `b`)
          join (`journal_details` `jd` left join `customers` `c` on((`jd`.`sub_account_id` = `c`.`id`))))
        where ((`jh`.`id` = `jd`.`journal_header_id`)
          and (`jd`.`account_id` = `a`.`id`
          and `a`.sub_account_type = #{SUB_ACCOUNT_TYPE_CUSTOMER})
          and (`jd`.`branch_id` = `b`.`id`))
        group by `jh`.`ym`,`jd`.`account_id`,`jd`.`sub_account_id`,`jd`.`dc_type`,`jd`.`branch_id`
       union
       select
          `jh`.`ym` AS `ym`,
          `jd`.`dc_type` AS `dc_type`,
          `a`.`id` AS `account_id`,
          `a`.`name` AS `account_name`,
          `a`.`sub_account_type` AS `sub_account_type`,
          `a`.`path` AS `path`,
          `ba`.`id` AS `sub_account_id`,
          `ba`.`name` AS `sub_account_name`,
          `b`.`id` AS `branch_id`,
          `b`.`name` AS `branch_name`,
          sum(`jd`.`amount`) AS `amount`
        from (((`journal_headers` `jh`
          join `accounts` `a`)
          join `branches` `b`)
          join (`journal_details` `jd` left join `bank_accounts` `ba` on((`jd`.`sub_account_id` = `ba`.`id`))))
        where ((`jh`.`id` = `jd`.`journal_header_id`)
          and (`jd`.`account_id` = `a`.`id`
          and `a`.sub_account_type = #{SUB_ACCOUNT_TYPE_SAVING_ACCOUNT})
          and (`jd`.`branch_id` = `b`.`id`))
        group by `jh`.`ym`,`jd`.`account_id`,`jd`.`sub_account_id`,`jd`.`dc_type`,`jd`.`branch_id`
       union
       select
          `jh`.`ym` AS `ym`,
          `jd`.`dc_type` AS `dc_type`,
          `a`.`id` AS `account_id`,
          `a`.`name` AS `account_name`,
          `a`.`sub_account_type` AS `sub_account_type`,
          `a`.`path` AS `path`,
          `r`.`id` AS `sub_account_id`,
          `r`.`name` AS `sub_account_name`,
          `b`.`id` AS `branch_id`,
          `b`.`name` AS `branch_name`,
          sum(`jd`.`amount`) AS `amount`
        from (((`journal_headers` `jh`
          join `accounts` `a`)
          join `branches` `b`)
          join (`journal_details` `jd` left join `rents` `r` on((`jd`.`sub_account_id` = `r`.`id`))))
        where ((`jh`.`id` = `jd`.`journal_header_id`)
          and (`jd`.`account_id` = `a`.`id`
          and `a`.sub_account_type = #{SUB_ACCOUNT_TYPE_RENT})
          and (`jd`.`branch_id` = `b`.`id`))
        group by `jh`.`ym`,`jd`.`account_id`,`jd`.`sub_account_id`,`jd`.`dc_type`,`jd`.`branch_id`", :force => true do |v|
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

  def self.down
    drop_view :v_monthly_ledgers
    create_view :v_monthly_ledgers,
      "select
          `jh`.`ym` AS `ym`,
          `jd`.`dc_type` AS `dc_type`,
          `a`.`id` AS `account_id`,
          `a`.`name` AS `account_name`,
          `a`.`path` AS `path`,
          `sa`.`id` AS `sub_account_id`,
          `sa`.`name` AS `sub_account_name`,
          `b`.`id` AS `branch_id`,
          `b`.`name` AS `branch_name`,
          sum(`jd`.`amount`) AS `amount`
        from (((`journal_headers` `jh`
          join `accounts` `a`)
          join `branches` `b`)
          join (`journal_details` `jd` left join `sub_accounts` `sa` on((`jd`.`sub_account_id` = `sa`.`id`))))
        where ((`jh`.`id` = `jd`.`journal_header_id`) and (`jd`.`account_id` = `a`.`id`) and (`jd`.`branch_id` = `b`.`id`))
        group by `jh`.`ym`,`jd`.`account_id`,`jd`.`sub_account_id`,`jd`.`dc_type`,`jd`.`branch_id`", :force => true do |v|
      v.column :ym
      v.column :dc_type
      v.column :account_id
      v.column :account_name
      v.column :path
      v.column :sub_account_id
      v.column :sub_account_name
      v.column :branch_id
      v.column :branch_name
      v.column :amount
    end
  end
end
