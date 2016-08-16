class UpdateNumOfDependentOnEmployees < ActiveRecord::Migration
  def up
    EmployeeHistory.find_each do |eh|
      e = eh.employee
      e.num_of_dependent = eh.num_of_dependent
      e.num_of_dependent_effective_at = eh.start_date
      e.save!
    end
  end
  def down
  end
end
