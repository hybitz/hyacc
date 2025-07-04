class Notification < ApplicationRecord
  has_many :user_notifications, dependent: :destroy
  has_many :users, through: :user_notifications
end