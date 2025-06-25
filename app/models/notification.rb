class Notification < ApplicationRecord
  has_many :user_notifications, dependent: :destroy
  has_many :users, through: :user_notifications

  def formatted_message
    message.gsub(/(\d{1,2}月\d{1,2}日)/) do |match| 
      "<span style='color: red;'>#{match}</span>"
    end
  end
end