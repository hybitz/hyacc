module Qualifications

  def qualification
    @_qualification ||= Qualification.first
  end
  
end