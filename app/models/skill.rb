class Skill < ApplicationRecord
  belongs_to :employee, inverse_of: 'skills'
  belongs_to :qualification

  validates :qualified_on, presence: true
end
