# -*- encoding : utf-8 -*-
#
# $Id: bank_office.rb 2471 2011-03-23 14:59:36Z ichy $
# Product: hyacc
# Copyright 2009 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class BankOffice < ActiveRecord::Base
  belongs_to :bank
  LABELS = {:name => '営業店名称', :code => '営業店コード', :deleted => '状態'}
  def self.label(col)
    LABELS[col]
  end
end
