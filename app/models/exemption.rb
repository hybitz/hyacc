class Exemption < ApplicationRecord
  has_many :dependent_family_members, :dependent => :destroy
  has_many :spouse_family_members, -> { where exemption_type: EXEMPTION_TYPE_SPOUSE }, class_name: "DependentFamilyMember"
  has_many :family_members, -> { where exemption_type: EXEMPTION_TYPE_FAMILY }, class_name: "DependentFamilyMember"
  has_many :under16_family_members, -> { where exemption_type: EXEMPTION_TYPE_UNDER_16 }, class_name: "DependentFamilyMember"
  has_many :dependents_19_23, -> { where(exemption_type: EXEMPTION_TYPE_FAMILY, family_sub_type: FAMILY_SUB_TYPE_DEPENDENTS_19_23) }, class_name: "DependentFamilyMember"
  has_many :dependents_over_70_with, -> { where(exemption_type: EXEMPTION_TYPE_FAMILY, family_sub_type: FAMILY_SUB_TYPE_DEPENDENTS_OVER_70_WITH) }, class_name: "DependentFamilyMember"
  has_many :dependents_over_70, -> { where(exemption_type: EXEMPTION_TYPE_FAMILY, family_sub_type: [FAMILY_SUB_TYPE_DEPENDENTS_OVER_70_WITH, FAMILY_SUB_TYPE_DEPENDENTS_OVER_70_WITHOUT]) }, class_name: "DependentFamilyMember"
  has_many :dependents_other, -> { where(exemption_type: EXEMPTION_TYPE_FAMILY, family_sub_type: FAMILY_SUB_TYPE_DEPENDENTS_OTHER) }, class_name: "DependentFamilyMember"
  has_many :specified_family_members, -> { where(exemption_type: EXEMPTION_TYPE_FAMILY, family_sub_type: FAMILY_SUB_TYPE_SPECIFIED) }, class_name: "DependentFamilyMember"
  belongs_to :employee
  validates :employee_id, uniqueness: {scope: [:yyyy], case_sensitive: false}
  validates_with ExemptionValidator
        

  accepts_nested_attributes_for :dependent_family_members, :allow_destroy => true

  def self.get(employee_id, calendar_year)
    Exemption.where(:employee_id => employee_id, :yyyy => calendar_year).first
  end

  def life_insurance_deduction
    life_insurance_premium + care_insurance + private_pension_insurance
  end

  # https://www.nta.go.jp/taxanswer/shotoku/1140.htm
  def life_insurance_premium
    calc_insurance(life_insurance_premium_old, life_insurance_premium_new)
  end
  
  def care_insurance
    new_calc_insurance(care_insurance_premium)
  end
  
  def private_pension_insurance
    calc_insurance(private_pension_insurance_old, private_pension_insurance_new)
  end
  
  def fiscal_year_for_december_of_calendar_year
    yyyymm = yyyy * 100 + 12
    Company.find(company_id).get_fiscal_year(yyyymm)
  end

  private

  def calc_insurance(old_amount, new_amount)
    ans = 0
    new_ans = new_calc_insurance(new_amount)
    old_ans = old_calc_insurance(old_amount)
    # 新旧両方の適用を受ける場合は4万が限度
    if old_ans >= 40_000
      ans = old_ans
    else
      ans = [new_ans + old_ans, 40_000].min
    end
    ans
  end

  def new_calc_insurance(amount)
    ans = 0
    if amount.to_i < 20_000
      ans = amount.to_i
    elsif amount.to_i.between?(20_001, 40_000)
      ans = amount.to_i.fdiv(2).ceil + 10_000
    elsif amount.to_i.between?(40_001, 80_000)
      ans = amount.to_i.fdiv(4).ceil + 20_000
    else
      ans = 40_000
    end
    ans
  end

  def old_calc_insurance(amount)
    ans = 0
    if amount.to_i < 25_000
      ans = amount.to_i
    elsif amount.to_i.between?(25_001, 50_000)
      ans = amount.to_i.fdiv(2).ceil + 12_500
    elsif amount.to_i.between?(50_001, 100_000)
      ans = amount.to_i.fdiv(4).ceil + 25_000
    else
      ans = 50_000
    end
    ans
  end

end
