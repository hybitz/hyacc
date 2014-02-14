# -*- encoding : utf-8 -*-
#
# $Id: account_finder.rb 2471 2011-03-23 14:59:36Z ichy $
# Product: hyacc
# Copyright 2009 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class AccountFinder < Base::Finder
  
  attr_reader :account_type
  attr_reader :leaf_only
  
  def setup_from_params( params )
    super(params)
    if params
      @account_type = params[:account_type].to_i
      @leaf_only = params[:leaf_only].to_i
    end
  end
  
  def list
    return unless @account_type.to_i > 0
    
    ret = Account.find(:all, :conditions=>["account_type=?", @account_type], :order=>'path')
    if @leaf_only == 1
      ret.select{|a| a.is_leaf}
    else
      ret
    end
  end
end
