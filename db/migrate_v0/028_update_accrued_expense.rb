# -*- encoding : utf-8 -*-
class UpdateAccruedExpense < ActiveRecord::Migration
  include HyaccConstants
  
  def self.up
    Account.find_by_code( ACCOUNT_CODE_ACCRUED_EXPENSE ).update_attributes( :system_required=>true )
  end

  def self.down
    Account.find_by_code( ACCOUNT_CODE_ACCRUED_EXPENSE ).update_attributes( :system_required=>false )
  end
end
