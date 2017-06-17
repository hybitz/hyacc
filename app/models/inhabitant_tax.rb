class InhabitantTax < ApplicationRecord
  belongs_to :employee
  
  validates :ym, presence: true
  validates :employee_id, presence: true
  validates :amount, presence: true, numericality: { only_integer: true }
  
end
