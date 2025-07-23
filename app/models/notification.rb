class Notification < ApplicationRecord
  has_many :user_notifications
  has_many :users, through: :user_notifications
end