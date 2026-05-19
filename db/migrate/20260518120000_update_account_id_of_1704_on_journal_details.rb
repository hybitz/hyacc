class UpdateAccountIdOf1704OnJournalDetails < ActiveRecord::Migration[8.1]
  def up
    from = Account.find_by_code('1704')
    to = Account.find_by_code('1703')
    return unless from && to

    JournalDetail.where(account_id: from.id).update_all(account_id: to.id, account_name: to.name)
  end

  def down
  end
end
