class Qualification < ApplicationRecord
  belongs_to :company, inverse_of: 'qualifications'
end
