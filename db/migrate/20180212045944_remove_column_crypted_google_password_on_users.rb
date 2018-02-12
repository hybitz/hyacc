class RemoveColumnCryptedGooglePasswordOnUsers < ActiveRecord::Migration[5.1]
  def change
    remove_column :users, :crypted_google_password, :string
  end
end
