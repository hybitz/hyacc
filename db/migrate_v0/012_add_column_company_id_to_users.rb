# -*- encoding : utf-8 -*-
class AddColumnCompanyIdToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, "company_id", :integer, :default=>0

    # 既存のユーザの属する会社を更新
    User.update_all(["company_id=?", 1 ])
  end

  def self.down
    remove_column :users, "company_id"
  end
end
