class UpdateCategoryOnNotifications < ActiveRecord::Migration[6.1]
  def change
    Notification.where(category: nil).update_all(category: :report_submission)  
  end
end
