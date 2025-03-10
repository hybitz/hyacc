class RemoveColumnYahooApiAppIdOnUsers < ActiveRecord::Migration[6.1]
  def change
    remove_column :users, :yahoo_api_app_id, :string
  end
end
