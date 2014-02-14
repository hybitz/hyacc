# -*- encoding : utf-8 -*-
class CreateTableBankAccounts < ActiveRecord::Migration
  def self.up
    create_table :bank_accounts do |t|
      t.column "name", :string, :null => false
      t.column "deleted", :boolean, :null => false, :default => false
      t.column "created_on", :datetime
      t.column "updated_on", :datetime
    end
    
    # 初期データの投入
    dir = File.join(File.dirname(__FILE__), "fixtures/004")
    Fixtures.create_fixtures(dir, "bank_accounts")
    now = Time.now
    BankAccount.update_all(["created_on=?, updated_on=?", now, now ])
  end

  def self.down
    drop_table :bank_accounts
  end
end
