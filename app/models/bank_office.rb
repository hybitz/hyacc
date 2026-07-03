class BankOffice < ApplicationRecord
  belongs_to :bank, inverse_of: 'bank_offices'

  validates_with Validators::ReferencedOnDeletionValidator
  validates_with Validators::ReferencedOnDisableValidator
end
