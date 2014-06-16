class EmployeeHistory < ActiveRecord::Base
  belongs_to :employee
  
  def self.get_current(employee_id)
    get_at(employee_id, Date.today)
  end
  
  def self.get_at(employee_id, date)
    EmployeeHistory.where('employee_id=? and start_date <= ?', employee_id, date).order('start_date desc').first
  end
  
end
