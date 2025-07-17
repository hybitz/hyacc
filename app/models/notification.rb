class Notification < ApplicationRecord
  has_many :user_notifications
  has_many :users, through: :user_notifications

  after_update :sync_user_notifications_with_deleted_flag, if: :saved_change_to_deleted?

  private

  def sync_user_notifications_with_deleted_flag
    user_notifications.includes(:user).find_each do |un|
      next if un.user.deleted?

      un.update!(deleted: deleted)
    end
  end

end