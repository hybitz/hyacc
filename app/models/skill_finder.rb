class SkillFinder
  include ActiveModel::Model
  include Pagination
  include EmployeeAware

  def list
    return [] unless employee

    qualifications = company.qualifications.order(:name)
    ret = {}
    company.qualifications.order(:name).each do |q|
      ret[q.name] = Skill.new(employee: employee, qualification: q)
    end

    Array(employee.skills).each do |s|
      ret[s.qualification.name] = s
    end
    
    ret.values
  end

end
