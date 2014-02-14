# -*- encoding : utf-8 -*-
#
# $Id: 20091203135711_create_simple_slip_settings.rb 2484 2011-03-23 15:51:29Z ichy $
# Product: hyacc
# Copyright 2009 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class CreateSimpleSlipSettings < ActiveRecord::Migration
  include HyaccConstants
  
  def self.up
    create_table :simple_slip_settings do |t|
      t.integer :user_id, :null => false
      t.integer :account_id, :null => false
      t.string :shortcut_key, :null => false, :limit=>10
      t.timestamps
    end
    
    # デフォルトは、現金と普通預金を設定しときますか
    User.find(:all).each do |u|
      u.simple_slip_settings << SimpleSlipSetting.new(
        :account_id => Account.find_by_code(ACCOUNT_CODE_CASH).id,
        :shortcut_key => 'Ctrl+1'
      )
      
      u.simple_slip_settings << SimpleSlipSetting.new(
        :account_id => Account.find_by_code(ACCOUNT_CODE_ORDINARY_DIPOSIT).id,
        :shortcut_key => 'Ctrl+2'
      )
      
      u.save!
    end
  end

  def self.down
    drop_table :simple_slip_settings
  end
end
