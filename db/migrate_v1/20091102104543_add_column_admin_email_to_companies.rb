# -*- encoding : utf-8 -*-
#
# $Id: 20091102104543_add_column_admin_email_to_companies.rb 2484 2011-03-23 15:51:29Z ichy $
# Product: hyacc
# Copyright 2009 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class AddColumnAdminEmailToCompanies < ActiveRecord::Migration
  def self.up
    add_column :companies, :admin_email, :string
  end

  def self.down
    remove_column :companies, :admin_email
  end
end
