# -*- encoding : utf-8 -*-
class UpdateTaxTypesOnAccounts < ActiveRecord::Migration
  include HyaccConstants

  def self.up
    # 課税対象の勘定科目の税区分を内税で更新
    tax_accounts = []
    tax_accounts << '2161'
    tax_accounts << '6121'
    tax_accounts << '8451'
    tax_accounts << '8471'
    tax_accounts << '8481'
    tax_accounts << '8491'
    tax_accounts << '8521'
    tax_accounts << '8551'
    tax_accounts << '8591'
    tax_accounts << '8611'
    tax_accounts << '8621'
    tax_accounts << '8661'
    tax_accounts << '8681'
    tax_accounts << '8711'
    tax_accounts << '8461'
    tax_accounts << '8811'
    tax_accounts << '8361'
    tax_accounts << '8691'
    tax_accounts << '8721'
    tax_accounts << '2251'
    tax_accounts << '8722'
    tax_accounts << '8332'
    tax_accounts << '8342'

    tax_accounts.each do |ta|
      a = Account.find_by_code(ta)
      a.tax_type = TAX_TYPE_INCLUSIVE
      a.save!
    end    
  end

  def self.down
  end
end
