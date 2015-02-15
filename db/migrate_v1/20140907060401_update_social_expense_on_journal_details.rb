class UpdateSocialExpenseOnJournalDetails < ActiveRecord::Migration
  include HyaccConstants

  def up
    accounts = Account.where(:code => [ACCOUNT_CODE_SOCIAL_EXPENSE, ACCOUNT_CODE_SALE, ACCOUNT_CODE_RENT, ACCOUNT_CODE_CORPORATE_TAXES_PAYABLE])

    JournalDetail.where(:account_id => accounts.map(&:id)).find_each do |jd|
      print '.'

      a = Account.find(jd.account_id)

      if a.code == ACCOUNT_CODE_SOCIAL_EXPENSE and jd.sub_account_id.to_i == 0
        sub_accounts = SubAccount.where(:account_id => a.id).order(:code)

        if jd.social_expense_number_of_people.to_i > 0
          sa = sub_accounts.where(:social_expense_number_of_people_required => true).first
        else
          sa = sub_accounts.where(:social_expense_number_of_people_required => false).first
        end
        
        jd.update_columns(:sub_account_id => sa.id, :sub_account_name => sa.name)

        puts
        puts "sub_account_id for social_expense fixed for #{jd.id} to #{jd.sub_account_id}: #{jd.sub_account_name}"
      end

      if jd.sub_account_id.to_i == 0
        if a.code == ACCOUNT_CODE_SALE
          puts
          puts "sub_account_id for sale cannot be fixed for #{jd.id}"
        elsif a.code == ACCOUNT_CODE_RENT
          puts
          puts "sub_account_id for rent cannot be fixed for #{jd.id}"
        elsif a.code == ACCOUNT_CODE_CORPORATE_TAXES_PAYABLE
          puts
          puts "sub_account_id for corporate_taxes_payable cannot be fixed for #{jd.id}"
        end
      end
    end
    puts
  end

  def down
  end
end
