class BankOffice < ApplicationRecord
  belongs_to :bank, inverse_of: 'bank_offices'

  validates_with Validators::ReferencedOnDeletionValidator
  validates_with Validators::ReferencedOnDisableValidator
  validate :active_on_create, on: :create

  private

  def active_on_create
    if disabled? || deleted?
      errors.add(:base, HyaccErrors::ERR_BANK_OFFICE_INACTIVE_ON_CREATE)
    end
  end
end
