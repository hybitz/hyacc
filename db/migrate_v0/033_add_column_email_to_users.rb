# -*- encoding : utf-8 -*-
class AddColumnEmailToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, "email", :string, :default=>""

    # 既存のユーザのメールアドレスを更新
    #User.update_all(["email=?", "info@hybitz.co.jp" ])
    user = { 1 => { "email" => "ichy@hybitz.co.jp" }, 2 => { "email" => "hiroyuki@hybitz.co.jp"} }
    User.update(user.keys, user.values)
  end

  def self.down
    remove_column :users, "email"
  end
end
