# -*- encoding : utf-8 -*-
class ImportDataOnSubAccounts < ActiveRecord::Migration
  SUB_ACCOUNT_CODES = {HyaccConstants::SUB_ACCOUNT_CODE_MEALS_OF_SOCIAL_EXPENSE=>'飲食等',
                       HyaccConstants::SUB_ACCOUNT_CODE_GIFT_OF_SOCIAL_EXPENSE=>'土産',
                       '900'=>'その他'}
  
  def self.up
    a = Account.find_by_code(HyaccConstants::ACCOUNT_CODE_SOCIAL_EXPENSE)
    SUB_ACCOUNT_CODES.each_pair{|key, value|
      sa = SubAccount.new( :code => key, :name => value )
      sa.account = a
      sa.save!
    }
  end

  def self.down
    transaction do
      a = Account.find_by_code(HyaccConstants::ACCOUNT_CODE_SOCIAL_EXPENSE)
      a.sub_accounts_all.each do |sa|
        if SUB_ACCOUNT_CODES.key?(sa.code)
          if JournalDetail.count(:conditions=>["account_id = ? and sub_account_id = ? ", a.id, sa.id]) > 0
            raise HyaccException.new(HyaccErrors::ERR_SUB_ACCOUNT_ALREADY_USED)
          else
            sa.destroy
          end
        end
      end
    end
  end
end
