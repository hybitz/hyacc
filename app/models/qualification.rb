class Qualification < ApplicationRecord
  belongs_to :company, inverse_of: 'qualifications'

  validates :name, presence: true
  validates :allowance, presence: true
end
