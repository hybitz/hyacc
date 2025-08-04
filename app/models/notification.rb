class Notification < ApplicationRecord
  belongs_to :employee, optional: true

  has_many :user_notifications

  enum category: {
    report_submission: 1,
    annual_determination: 2,
    ad_hoc_revision: 3
  }

  validates :category, presence: true

  scope :with_active_or_no_employee, -> {
    left_outer_joins(:employee)
    .where(Notification.arel_table[:employee_id].eq(nil)
    .or(Employee.arel_table[:deleted].eq(false)))
  }

  scope :visible_to_user, ->(user) {
  joins(:user_notifications)
    .where(
      deleted: false,
      user_notifications: {user_id: user.id, visible: true}
    )
  }
end