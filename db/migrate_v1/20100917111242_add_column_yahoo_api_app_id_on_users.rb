# -*- encoding : utf-8 -*-
class AddColumnYahooApiAppIdOnUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :yahoo_api_app_id, :string
  end

  def self.down
    remove_column :users, :yahoo_api_app_id
  end
end
