class Exemption < ActiveRecord::Base
  has_many :dependent_family_members, :dependent => :destroy
  has_many :spouse_family_members, -> { where exemption_type: EXEMPTION_TYPE_SPOUSE }, class_name: "DependentFamilyMember"
  has_many :family_members, -> { where exemption_type: EXEMPTION_TYPE_FAMILY }, class_name: "DependentFamilyMember"
  has_many :under16_family_members, -> { where exemption_type: EXEMPTION_TYPE_UNDER_16 }, class_name: "DependentFamilyMember"
  belongs_to :employee
  validates :employee_id, uniqueness: {scope: [:yyyy]}
        

  accepts_nested_attributes_for :dependent_family_members, :allow_destroy => true

  def self.get(employee_id, calendar_year)
    Exemption.where(:employee_id => employee_id, :yyyy => calendar_year).first
  end

  def life_insurance_premium
    ret = 0

    # 旧契約のみで4万円を越える場合は、旧契約の限度額5万円の範囲を控除額とする
    if life_insurance_premium_old.to_i > 40_000
      ret = life_insurance_premium_old.to_i
      ret = [ret, 50_000].min
    else
      ret = life_insurance_premium_old.to_i + life_insurance_premium_new.to_i
      ret = [ret, 40_000].min
    end
    
    ret
  end
end
