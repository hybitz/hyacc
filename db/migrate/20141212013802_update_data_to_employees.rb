class UpdateDataToEmployees < ActiveRecord::Migration
  def change
    e = Employee.find(1)
    e.birth = "1977-8-21".to_date
    e.save!
    e = Employee.find(2)
    e.birth = "1978-10-13".to_date
    e.save!
  end
end
