class UpdateDirectorSalaryOnJournalDetails < ActiveRecord::Migration
  include HyaccConstants

  def up
    a = Account.find_by_code(ACCOUNT_CODE_DIRECTOR_SALARY)
    
    JournalDetail.where(:account_id => a.id).find_each do |jd|
      puts "#{jd.id}: #{jd.account_name}"

      jd.sub_account_id = jd.branch.employees.first.user_id
      jd.save!
    end
  end

  def down
  end
end
