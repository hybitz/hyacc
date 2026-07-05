module Validators

  class LastActiveAdminValidator < ActiveModel::Validator

    def validate(record)
      case record
      when User
        validate_user(record)
      when Employee
        validate_employee(record)
      else
        raise ArgumentError,
              "LastActiveAdminValidator: #{record.class.name} は対応外です"
      end
    end

    private

    def validate_user(user)
      return unless user.will_save_change_to_deleted? && user.deleted?
      return unless user.would_remove_last_active_admin?

      user.errors.add(:base, HyaccErrors::ERR_LAST_ACTIVE_ADMIN_DELETE)
    end

    def validate_employee(employee)
      user = employee.user
      return unless user

      becoming_inactive = (employee.will_save_change_to_disabled? && employee.disabled?) ||
                          (employee.will_save_change_to_deleted? && employee.deleted?)
      return unless becoming_inactive
      return unless user.would_remove_last_active_admin?

      error = if employee.will_save_change_to_disabled? && employee.disabled?
                HyaccErrors::ERR_LAST_ACTIVE_ADMIN_DISABLE
              else
                HyaccErrors::ERR_LAST_ACTIVE_ADMIN_DELETE
              end
      employee.errors.add(:base, error)
    end

  end
end
