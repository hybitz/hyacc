# -*- encoding : utf-8 -*-
class CreateTableSubAccounts < ActiveRecord::Migration
  def self.up
    create_table :sub_accounts do |t|
      t.column "code", :string, :null => false
      t.column "name", :string, :null => false
      t.column "account_id", :integer, :null => false
      t.column "deleted", :boolean, :null => false, :default => false
      t.column "created_on", :datetime
      t.column "updated_on", :datetime
    end
    
    # 初期データの投入
    dir = File.join(File.dirname(__FILE__), "fixtures/015")
    Fixtures.create_fixtures(dir, "sub_accounts")
    now = Time.now
    SubAccount.update_all(["created_on=?, updated_on=?", now, now ])
    
    # 普通預金の補助科目のaccount_idの設定
    sa = SubAccount.find(1)
      sa.account_id = Account.find_by_sql("select id from accounts where code='#{HyaccConstants::ACCOUNT_CODE_ORDINARY_DIPOSIT}'")[0].id
    sa.save!
    
    # 預り金の補助科目のaccount_idの設定
    [ 2, 3, 4, 5 ].each do | id |
      sa = SubAccount.find( id )
      sa.account_id = Account.find_by_sql("select * from accounts where code='#{HyaccConstants::ACCOUNT_CODE_DEPOSITS_RECEIVED}'")[0].id
      sa.save!
    end
    
    
  end

  def self.down
    drop_table :sub_accounts
  end
end
