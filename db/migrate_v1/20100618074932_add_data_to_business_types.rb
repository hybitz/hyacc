# -*- encoding : utf-8 -*-
#
# $Id: 20100618074932_add_data_to_business_types.rb 2484 2011-03-23 15:51:29Z ichy $
# Product: hyacc
# Copyright 2009 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class AddDataToBusinessTypes < ActiveRecord::Migration
  require 'active_record/fixtures'

  def self.up
    now = Time.now
    dir = dir = File.join(RAILS_ROOT, "config/first_boot")
    Fixtures.create_fixtures(dir, "business_types")
    BusinessType.update_all(["created_at=?, updated_at=?", now, now ])
  end

  def self.down
    BusinessType.delete_all
  end
end
