# -*- encoding : utf-8 -*-
#
# $Id: 20101129123552_updaet_is_tax_account_on_accounts.rb 2727 2011-12-09 06:17:17Z ichy $
# Product: hyacc
# Copyright 2010 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class UpdaetIsTaxAccountOnAccounts < ActiveRecord::Migration
  def self.up
    # 仮払法人税等
    Account.update_all(['is_tax_account=?', true], ['name=?', '仮払法人税等'])
  end

  def self.down
  end
end
