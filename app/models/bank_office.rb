class BankOffice < ApplicationRecord
  belongs_to :bank, inverse_of: 'bank_offices'
end
