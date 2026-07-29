module LastActiveAdminLockable
  extend ActiveSupport::Concern

  included do
    attr_accessor :company_lock_version
    before_save :lock_last_active_admin_company
  end

  private

  def lock_last_active_admin_company
    return unless will_change_admin_disabled_or_deleted?
    return unless admin_becoming_inactive?
    raise HyaccException.new(HyaccErrors::ERR_ILLEGAL_STATE) if company_lock_version.nil?

    company = lockable_company
    company.lock_version = company_lock_version.to_i
    company.touch
  end

  def will_change_admin_disabled_or_deleted?
    %i[admin disabled deleted].any? do |attr|
      has_attribute?(attr) && will_save_change_to_attribute?(attr)
    end
  end
end
