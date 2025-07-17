class UserNotification < ApplicationRecord
  belongs_to :user
  belongs_to :notification

  validates :notification_id, uniqueness: { scope: :user_id, message: 'ユーザとお知らせの紐づけは重複して行えません。' }

  before_update :sync_visibility_with_deleted_flag, if: :will_save_change_to_deleted?

  private

  def sync_visibility_with_deleted_flag
    self.visible = !deleted
  end

end