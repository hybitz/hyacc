# coding: UTF-8
#
# Product: hyacc
# Copyright 2011-2014 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class BusinessOffice < ActiveRecord::Base
  belongs_to :company

  validates :name, :presence => true
  validates :prefecture_id, :presence => true
end
