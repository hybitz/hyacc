# coding: UTF-8
#
# $Id: account.rb 3310 2014-01-27 13:20:06Z ichy $
# Product: hyacc
# Copyright 2009-2014 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class Account < ActiveRecord::Base
  include HyaccConstants
  include HyaccErrors
  include Accounts::SubAccountsSupport
  
  acts_as_cached :includes => 'accounts/account_cache'
  acts_as_tree :order => 'display_order'

  has_one :account_control, :dependent=>:destroy
  accepts_nested_attributes_for :account_control

  validates_presence_of :name, :code
  validate :validate_account_type, :validate_dc_type
  
  validates_with Validators::UniqueSubAccountsValidator

  before_save :update_path

  def code_and_name
    self.code + ':' + self.name
  end

  def account_type_name
    ACCOUNT_TYPES[account_type]
  end
  
  def dc_type_name
    DC_TYPES[dc_type]
  end
  
  def debit?
    self.dc_type == DC_TYPE_DEBIT
  end

  def credit?
    self.dc_type == DC_TYPE_CREDIT
  end

  def depreciation_method_name
    DEPRECIATION_METHODS[depreciation_method]
  end
  
  def sub_account_type_name
    SUB_ACCOUNT_TYPES[sub_account_type]
  end
  
  def tax_type_name
    TAX_TYPES[tax_type]
  end

  def trade_type_name
    TRADE_TYPES[trade_type]
  end
  
  def is_leaf
    children.size == 0
  end
  
  def is_leaf_on_settlement_report
    # リーフの場合は、親をチェック
    if is_leaf
      if parent.is_leaf_on_settlement_report
        false
      else
        is_settlement_report_account
      end
    else    
      # 子供のうち1つでも決算書科目でなければtrueを返す
      leaf_on_settlement_report = false
      children.each do |child|
        unless child.is_settlement_report_account
          leaf_on_settlement_report = true
        end
      end
      
      leaf_on_settlement_report
    end
  end

  def is_node
    ! is_leaf
  end
  
  def node_level
    path.count('/')
  end

  # 負債かどうか
  def is_debt
    account_type == ACCOUNT_TYPE_DEBT
  end
  
  # 収益かどうか
  def is_profit
    account_type == ACCOUNT_TYPE_PROFIT
  end
  
  # 資本かどうか
  def is_capital
    account_type == ACCOUNT_TYPE_CAPITAL
  end

  # 費用の部
  def is_expense?
    path.index(ACCOUNT_CODE_EXPENSE) != nil
  end
  
  # 流動資産の部
  def is_current_assets?
    path.index(ACCOUNT_CODE_CURRENT_ASSETS) != nil
  end
  
  # 接待交際費かどうか
  def is_social_expense
    path.include? ACCOUNT_CODE_SOCIAL_EXPENSE
  end

  # 法人税かどうか
  def is_corporate_tax
    sub_account_type == SUB_ACCOUNT_TYPE_CORPORATE_TAX
  end
  
private
  def validate_account_type
    unless parent.nil?
      if parent.account_type != self.account_type
        errors.add( :account_type, ERR_INVALID_ACCOUNT_TYPE )
      end
    end
  end
  
  def validate_dc_type
    unless parent.nil?
      if parent.dc_type != self.dc_type
        errors.add( :dc_type, ERR_INVALID_DC_TYPE )
      end
    end
  end
  
  def update_path
    self.path = get_absolute_path( self )
  end
  
  def get_absolute_path( account )
    ret = '/' + account.code
    
    unless account.parent.nil?
      ret = get_absolute_path( account.parent ) + ret
    end
    
    ret
  end
end
