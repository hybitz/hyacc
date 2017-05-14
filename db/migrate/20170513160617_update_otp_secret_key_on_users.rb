class UpdateOtpSecretKeyOnUsers < ActiveRecord::Migration[5.0]
  def up
    User.find_each do |u|
      u.otp_secret_key = nil
      u.save!
    end
  end
  
  def down
  end
end
