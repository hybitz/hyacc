class Exemption < ApplicationRecord
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

  # https://www.nta.go.jp/taxanswer/shotoku/1140.htm
  def life_insurance_premium
    ret = 0
    old = 0
    new = 0
    # 旧契約
    if life_insurance_premium_old.to_i < 25_000
      old = life_insurance_premium_old.to_i
    elsif life_insurance_premium_old.to_i.between?(25_001, 50_000)
      old = life_insurance_premium_old.to_i/2 + 12_500
    elsif life_insurance_premium_old.to_i.between?(50_001, 100_000)
      old = life_insurance_premium_old.to_i/4 + 25_000
    else
      old = 50_000
    end
    # 新契約
    if life_insurance_premium_new.to_i < 20_000
      new = life_insurance_premium_new.to_i
    elsif life_insurance_premium_new.to_i.between?(20_001, 40_000)
      new = life_insurance_premium_new.to_i/2 + 10_000
    elsif life_insurance_premium_new.to_i.between?(40_001, 80_000)
      new = life_insurance_premium_new.to_i/4 + 20_000
    else
      new = 40_000
    end
    
    # 新旧両方の適用を受ける場合は4万が限度
    if old >= 40_000
      ret = old
    else
      ret = [new + old, 40_000].min
    end

    ret
  end
end
