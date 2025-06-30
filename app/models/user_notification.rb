class UserNotification < ApplicationRecord
  belongs_to :user
  belongs_to :notification

  validates :notification_id, uniqueness: { scope: :user_id, message: 'ユーザとお知らせの紐づけは重複して行えません。' }
end