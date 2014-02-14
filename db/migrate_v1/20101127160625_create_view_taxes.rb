# -*- encoding : utf-8 -*-
#
# $Id: 20101127160625_create_view_taxes.rb 2727 2011-12-09 06:17:17Z ichy $
# Product: hyacc
# Copyright 2010 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class CreateViewTaxes < ActiveRecord::Migration
  def self.up
    create_view "v_taxes",
      "select
        `jh`.`ym` AS `ym`,
        `jd`.`dc_type` AS `dc_type`,
        `jd`.`account_id` AS `account_id`,
        `a`.`path` AS `path`,
        `jd`.`sub_account_id` AS `sub_account_id`,
        `jd`.`branch_id` AS `branch_id`,
        `jd`.`settlement_type` AS `settlement_type`,
        sum(`jd`.`amount`) AS `amount`
      from ((`journal_headers` `jh` join `accounts` `a`) join `journal_details` `jd`)
      where (`jh`.`id` = `jd`.`journal_header_id`) and (`jd`.`account_id` = `a`.`id`)
        and (`a`.`is_tax_account`=1)
      group by `jh`.`ym`,`jd`.`dc_type`,`jd`.`account_id`,`jd`.`sub_account_id`,`jd`.`branch_id`,`jd`.`settlement_type`", :force => true do |v|
      v.column :ym
      v.column :dc_type
      v.column :account_id
      v.column :path
      v.column :sub_account_id
      v.column :branch_id
      v.column :settlement_type
      v.column :amount
    end
  end

  def self.down
    drop_view "v_taxes"
  end
end
