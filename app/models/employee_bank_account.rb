class EmployeeBankAccount < ApplicationRecord
  belongs_to :employee
  belongs_to :bank, optional: true
  belongs_to :bank_office, optional: true

  before_validation :mark_for_destruction_if_persisted_incomplete

  validates :bank_id, :bank_office_id, :code, presence: true, unless: :marked_for_destruction?

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

end
