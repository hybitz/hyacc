class Notification < ApplicationRecord
  has_many :user_notifications
  has_many :users, through: :user_notifications

  enum category: {
    report_submission: 1,
    annual_determination: 2,
    ad_hoc_revision: 3
  }

  validates :category, presence: true
end