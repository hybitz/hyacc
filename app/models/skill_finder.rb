class SkillFinder
  include ActiveModel::Model
  include Pagination
  include EmployeeAware

  def list
    return [] unless employee

    ret = {}
    company.qualifications.order(:name).each do |q|
      ret[q.name] = Skill.new(qualification: q)
    end

    employee.skills.each do |s|
      ret[s.qualification.name] = s
    end

    ret.values
  end

end
