class UpdateSubAccountIdFor2999OnJournalDetails < ActiveRecord::Migration[5.1]
  include HyaccConst
  
  def up
    a = Account.find_by_code(ACCOUNT_CODE_BRANCH_OFFICE)
    a.update_column(:sub_account_type, SUB_ACCOUNT_TYPE_BRANCH)

    JournalDetail.where(account_id: a.id).find_each do |jd|
      puts "#{jd.id}"

      sa = SubAccount.where(account_id: a.id, id: jd.sub_account_id).first
      if sa
        b = Branch.where(code: sa.code).first
      else
        b = Branch.where(id: jd.sub_account_id).first
      end

      next if jd.sub_account_id == b.id

      puts "\t#{jd.account.name} #{jd.sub_account_id} => #{b.id}"
      jd.update_column(:sub_account_id, b.id)
    end
  end
  
  def down
  end
end
