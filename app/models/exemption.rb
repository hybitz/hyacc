class Exemption < ActiveRecord::Base
  belongs_to :employee
  validates :employee_id, uniqueness: {scope:[:yyyy]}
  validates_presence_of :small_scale_mutual_aid, :life_insurance_premium, :earthquake_insurance_premium,
        :special_tax_for_spouse, :spouse, :dependents, :disabled_persons, :basic
  
  def self.get(employee_id, calendar_year)
    Exemption.where(:employee_id => employee_id, :yyyy => calendar_year).first
  end
end
