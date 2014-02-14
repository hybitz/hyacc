# -*- encoding : utf-8 -*-
#
# $Id: 20100512110541_delete_company_only_accunts_for_personal.rb 2484 2011-03-23 15:51:29Z ichy $
# Product: hyacc
# Copyright 2009 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class DeleteCompanyOnlyAccuntsForPersonal < ActiveRecord::Migration
  def self.up
    Company.find(:all).each do |c|
      unless c.type_of_personal
        p '個人事業主ではないので科目削除は行いません。'
        return
      end
    end
    
    accounts = ['3185', '1851', '1831', '3501', '8888', '8889', '2999', '4999', '8911', '4311', '3171']
    accounts.each do |code|
      a = Account.find_by_code(code)
      if a
        p "削除します。[#{a.name}]"
        a.destroy
      end
    end
  end

  def self.down
  end
end
