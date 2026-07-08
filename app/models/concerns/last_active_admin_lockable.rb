module LastActiveAdminLockable
  extend ActiveSupport::Concern

  included do
    before_save :lock_last_active_admin_company
  end

  private

  def lock_last_active_admin_company
    return unless admin_becoming_inactive?
    lockable_company.touch
  end
end
