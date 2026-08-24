class InhabitantTax < ApplicationRecord
  belongs_to :employee
  
  validates :ym, presence: true
  validates :employee_id, presence: true
  validates :amount, presence: true, numericality: { only_integer: true, allow_blank: true }

  def self.ym_range(year)
    year = year.to_i
    %w[06 07 08 09 10 11 12 01 02 03 04 05].each_with_index.map do |mm, i|
      ((i <= 6 ? year : year + 1).to_s + mm).to_i
    end
  end
end
