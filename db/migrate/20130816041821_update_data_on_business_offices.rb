# -*- encoding : utf-8 -*-
#
# $Id: 20130816041821_update_data_on_business_offices.rb 3130 2013-08-16 05:26:57Z hiro $
# Product: hyacc
# Copyright 2013 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class UpdateDataOnBusinessOffices < ActiveRecord::Migration
  def up
    # 本社フラグを立てる
    b = BusinessOffice.find(1)
    b.is_head = true
    b.save!
  end

  def down
  end
end
