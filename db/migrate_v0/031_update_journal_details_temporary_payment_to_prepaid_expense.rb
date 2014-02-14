# -*- encoding : utf-8 -*-
class UpdateJournalDetailsTemporaryPaymentToPrepaidExpense < ActiveRecord::Migration
  include HyaccConstants

  def self.up
    temporary = Account.find_by_code( ACCOUNT_CODE_TEMPORARY_PAYMENT )
    prepaid = Account.find_by_code( ACCOUNT_CODE_PREPAID_EXPENSE )
    debt_to_owner = Account.find_by_code( ACCOUNT_CODE_DEBT_TO_OWNER )
    unpaid = Account.find_by_code( ACCOUNT_CODE_UNPAID )
   
    JournalHeader.find(:all, :conditions=>["finder_key rlike '.*-#{temporary.code},[0-9]*,[0-9]*-.*'"]).each do | jh |
      jh.journal_details.each do | jd |
        if jd.account_id == temporary.id
          jd.account_id = prepaid.id
          jd.save!
        end
      end
      print "updating journal #{jh.id}"
      print "\n"
      jh.save!
    end

    JournalHeader.find(:all, :conditions=>["finder_key rlike '.*-#{debt_to_owner.code},[0-9]*,[0-9]*-.*'"]).each do | jh |
      jh.journal_details.each do | jd |
        if jd.account_id == debt_to_owner.id
          jd.account_id = unpaid.id
          jd.save!
        end
      end
      print "updating journal #{jh.id}"
      print "\n"
      jh.save!
    end
    
    # 事業主借、事業主貸は廃止
    debt_to_owner.destroy
    Account.find(11).destroy
    
    # 創立費をやめて創立費償却で一括費用計上する
    start_expense = Account.find(35)
    start_expense.code = '8831'
    start_expense.name = '創立費償却'
    start_expense.account_type = ACCOUNT_TYPE_EXPENSE
    start_expense.parent_id = 51
    start_expense.save!
  end

  def self.down
  end
end
