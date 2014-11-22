class Exemption < ActiveRecord::Base
  belongs_to :employee
  
  def self.get(employee_id, calendar_year)
    Exemption.where(:employee_id => employee_id, :yyyy => calendar_year).first
  end
end
