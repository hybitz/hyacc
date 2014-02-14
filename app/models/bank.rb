# coding: UTF-8
#
# $Id: bank.rb 3296 2014-01-24 04:00:10Z ichy $
# Product: hyacc
# Copyright 2009-2012 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class Bank < ActiveRecord::Base
  include HyaccConstants
  LABELS = {:name => '金融機関名称', :code => '金融機関コード', :deleted => '状態'}

  validates :code, :presence => true

  has_many :bank_offices, :dependent=>:destroy
  accepts_nested_attributes_for :bank_offices

  def self.label(col)
    LABELS[col]
  end
end
