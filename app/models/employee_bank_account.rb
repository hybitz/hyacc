class EmployeeBankAccount < ApplicationRecord
  include HyaccErrors

  belongs_to :employee
  belongs_to :bank, optional: :marked_for_destruction?
  belongs_to :bank_office, optional: :marked_for_destruction?

  before_validation :mark_for_destruction_if_persisted_incomplete

  validate :require_complete_account, unless: :marked_for_destruction?

  def bank_name
    bank.try(:name)
  end

  def bank_office_name
    bank_office.try(:name)
  end

  private

  def mark_for_destruction_if_persisted_incomplete
    return if new_record?
    return if bank_id.present? && bank_office_id.present? && code.present?

    mark_for_destruction
  end

  def require_complete_account
    return if bank_id.present? && bank_office_id.present? && code.present?

    errors.delete(:bank)
    errors.delete(:bank_office)
    errors.add(:base, ERR_EMPLOYEE_BANK_ACCOUNT_INCOMPLETE)
  end

end
