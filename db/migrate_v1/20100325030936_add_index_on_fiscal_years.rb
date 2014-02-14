# -*- encoding : utf-8 -*-
#
# $Id: 20100325030936_add_index_on_fiscal_years.rb 2484 2011-03-23 15:51:29Z ichy $
# Product: hyacc
# Copyright 2009 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class AddIndexOnFiscalYears < ActiveRecord::Migration
  def self.up
    add_index :fiscal_years, [:company_id, :fiscal_year], :unique=>true,
        :name=>'index_fiscal_yeras_on_company_id_and_fiscal_year'
  end

  def self.down
    remove_index :fiscal_years, :name=>'index_fiscal_yeras_on_company_id_and_fiscal_year'
  end
end
