# coding: UTF-8
#
# $Id: sub_account.rb 3310 2014-01-27 13:20:06Z ichy $
# Product: hyacc
# Copyright 2009-2014 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class SubAccount < ActiveRecord::Base
  belongs_to :account

  validates :code, :presence => true
  validates :name, :presence => true
end
