# -*- encoding : utf-8 -*-
class ImportDataAdvanceMoneyOnSubAccounts < ActiveRecord::Migration
  include HyaccConstants
  include HyaccErrors
  SUB_ACCOUNT_CODES = {SUB_ACCOUNT_CODE_INCOME_TAX_OF_ADVANCE_MONEY=>'源泉所得税',
                       SUB_ACCOUNT_CODE_HEALTH_INSURANCE_OF_ADVANCE_MONEY=>'健康保険料',
                       SUB_ACCOUNT_CODE_EMPLOYEES_PENSION_OF_ADVANCE_MONEY=>'厚生年金',
                       SUB_ACCOUNT_CODE_INHABITANT_TAX_OF_ADVANCE_MONEY=>'住民税'}
  
  def self.up
    a = Account.find_by_code(ACCOUNT_CODE_ADVANCE_MONEY)
    SUB_ACCOUNT_CODES.each_pair{|key, value|
      sa = SubAccount.new( :code => key, :name => value )
      sa.account = a
      sa.save!
    }
    sub_account_of_inhabitant_tax = Account.find_by_code(ACCOUNT_CODE_ADVANCE_MONEY).get_sub_account_by_code(SUB_ACCOUNT_CODE_INHABITANT_TAX_OF_ADVANCE_MONEY)
    JournalDetail.find(:all,:conditions=>["account_id = ?", a.id]).each do |jd|
      jd.sub_account_id = sub_account_of_inhabitant_tax.id
      jd.sub_account_id = sub_account_of_inhabitant_tax.id
      jd.sub_account_name = sub_account_of_inhabitant_tax.name
      jd.save!
    end
  end

  def self.down
    transaction do
      a = Account.find_by_code(ACCOUNT_CODE_ADVANCE_MONEY)
      a.sub_accounts_all.each do |sa|
        if SUB_ACCOUNT_CODES.key?(sa.code)
          if JournalDetail.count(:conditions=>["account_id = ? and sub_account_id = ? ", a.id, sa.id]) > 0
            raise HyaccException.new(ERR_SUB_ACCOUNT_ALREADY_USED)
          else
            sa.destroy
          end
        end
      end
    end
  end
end
