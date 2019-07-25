class SkillFinder
  include ActiveModel::Model
  include Pagination
  include EmployeeAware

  def list
    return [] unless employee

    qualifications = company.qualifications.order(:name)
    ret = Hash[*qualifications.map{|q| [q.name => Skill.new(employee: employee, qualification: q)] }.flatten]

    Array(employee.employee_qualifications).each do |eq|
      ret[eq.qualification.name] = eq
    end
    
    ret.values
  end

end
