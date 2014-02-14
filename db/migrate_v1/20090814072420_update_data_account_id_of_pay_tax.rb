# -*- encoding : utf-8 -*-
class UpdateDataAccountIdOfPayTax < ActiveRecord::Migration
  include HyaccConstants
  def self.up
    a = Account.find_by_code(ACCOUNT_CODE_TEMP_PAY_TAX)
    JournalDetail.find(:all, :conditions=>["note='振込手数料の消費税'"]).each do |jd|
      jd.account_id = a.id
      jd.account_name = a.name
      print("updating journal [#{jd.id.to_s}]\n")
      jd.save!
    end
  end

  def self.down
  end
end
