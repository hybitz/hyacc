class InsertSubCodeOfDividendToSubAccounts < ActiveRecord::Migration
  def up
    SubAccount.new(:code => 100, :account_id=>102, :name => '完全子法人株式').save!
    SubAccount.new(:code => 200, :account_id=>102, :name => '関係法人株式').save!
    SubAccount.new(:code => 300, :account_id=>102, :name => 'その他法人株式').save!
    s = SubAccount.where(:account_id=>102, :code=>300).first
    JournalDetail.where(:account_id=>102).update_all(:sub_account_id=>s.id, :sub_account_name=>'その他法人株式')
  end
  def down
    SubAccount.where(:account_id => 102).delete_all
    JournalDetail.where(:account_id=>102).update_all(:sub_account_id=>nil, :sub_account_name=>nil)
  end
end
