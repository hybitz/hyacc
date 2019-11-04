class Insurance
  include ActiveModel::Model

  attr_accessor :valid_from, :valid_until
  attr_accessor :grade, :pension_grade
  attr_accessor :salary_from, :salary_to
  attr_accessor :monthly_standard, :daily_standard
  attr_accessor :health_insurance_all, :health_insurance_half, :health_insurance_all_care, :health_insurance_half_care
  attr_accessor :welfare_pension_insurance_all, :welfare_pension_insurance_half, :welfare_pension2_insurance_all, :welfare_pension2_insurance_half
end
